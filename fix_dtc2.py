#!/usr/bin/env python3
"""Fix the broken symbolic branch conversion in ForthKernel-L28.asm.

The first script used incorrect syntax (DATA.W label - * ; comment).
The correct syntax is DATA.W (label - addr) with no semicolon comment
(use ;; for comments).

This script:
1. Reverts all bad symbolic branch conversions back to numeric
2. Removes orphaned .BRn labels
3. Re-applies symbolic conversions with correct syntax
4. Fixes the CTLRQ line
5. Fixes the DECIMAL line
"""

import re

with open('src/ForthKernel-L28.asm', 'r') as f:
    lines = f.readlines()

# ============================================================================
# PASS 1: Revert bad symbolic conversions and remove .BRn labels
# ============================================================================

print("Pass 1: Reverting bad symbolic conversions...")

reverted = 0
removed = 0

i = 0
while i < len(lines):
    line = lines[i]

    # Revert "DATA.W .BRn - *	; was $xxxx" back to "DATA.W $xxxx"
    m = re.match(r'^(\s+)DATA\.W \.BR\d+ - \*\s*;\s*was \$([0-9a-fA-F]{4})\s*$', line)
    if m:
        indent = m.group(1)
        hex_val = m.group(2)
        lines[i] = f"{indent}DATA.W ${hex_val}\n"
        reverted += 1
        i += 1
        continue

    # Revert "DATA.W DATA - *	; was $xxxx" or similar bad conversions
    m = re.match(r'^(\s+)DATA\.W \S+ - \*\s*;\s*was \$([0-9a-fA-F]{4})\s*$', line)
    if m:
        indent = m.group(1)
        hex_val = m.group(2)
        lines[i] = f"{indent}DATA.W ${hex_val}\n"
        reverted += 1
        i += 1
        continue

    # Remove .BRn: label lines (they were added to comment lines)
    if re.match(r'^\.BR\d+:\s', line):
        # Check if the rest of the line is just a comment
        rest = re.sub(r'^\.BR\d+:\s*', '', line)
        if rest.strip().startswith(';;') or rest.strip() == '':
            lines[i] = rest if rest.strip() else '\n'
            removed += 1
        else:
            # Label was added to a non-comment line — just remove the label prefix
            lines[i] = '\t\t\t' + rest.lstrip()
            removed += 1

    i += 1

print(f"  Reverted {reverted} bad symbolic conversions")
print(f"  Removed {removed} orphaned .BRn labels")

# Also fix the DECIMAL line that used wrong syntax
for i, line in enumerate(lines):
    if 'DATA.W L1170 - *' in line:
        lines[i] = "    \t\tDATA.W (L1170 - addr)\t;; branch into HEX body\n"
        print(f"  Fixed DECIMAL branch at line {i+1}")
        break

# Fix the CTLRQ line
for i, line in enumerate(lines):
    if '.CTLRQ_END - *' in line:
        lines[i] = "    \t\tDATA.W (.CTLRQ_END - addr) ;; skip MMON if not Ctrl-R\n"
        print(f"  Fixed CTLRQ branch at line {i+1}")
        break

# ============================================================================
# PASS 2: Convert numeric offsets to symbolic with correct syntax
# ============================================================================

print("\nPass 2: Converting branch offsets to symbolic labels...")

# Strategy: for each branch offset (after ZBRAN, BRAN, LOOP, PLOOP),
# calculate the target by counting bytes forward/backward through thread entries.
# Add a label at the target and replace the offset with (label - addr).

def count_line_bytes(line_text):
    """Count how many bytes a thread line assembles to."""
    stripped = line_text.strip()

    # Skip comments and blank lines
    if stripped == '' or stripped.startswith(';;') or stripped.startswith(';') or stripped.startswith('*'):
        return 0

    # DATA.W = 2 bytes
    if stripped.startswith('DATA.W') or 'DATA.W' in stripped:
        # Could be labeled: "LABEL  DATA.W ..."
        # Just count DATA.W occurrences
        return 2

    # DATA.B - count actual bytes
    if 'DATA.B' in stripped:
        # Extract everything after DATA.B
        m = re.search(r'DATA\.B\s+(.*)', stripped)
        if m:
            data_part = m.group(1)
            # Remove comments (;; or ;)
            data_part = re.split(r'\s*;;', data_part)[0]
            data_part = data_part.strip().rstrip(',')
            byte_count = 0
            in_string = False
            j = 0
            while j < len(data_part):
                c = data_part[j]
                if c == '"':
                    in_string = not in_string
                    j += 1
                elif in_string:
                    byte_count += 1
                    j += 1
                elif c in ', \t':
                    j += 1
                elif c == "'":
                    # character literal like '-'
                    byte_count += 1
                    j += 1
                    while j < len(data_part) and data_part[j] != "'":
                        j += 1
                    if j < len(data_part):
                        j += 1  # skip closing quote
                else:
                    # Must be a numeric value
                    byte_count += 1
                    while j < len(data_part) and data_part[j] not in ', \t':
                        j += 1
            return byte_count
        return 1

    # JSR = 3 bytes
    if 'JSR' in stripped:
        return 3

    # Everything else (instructions) — but in thread body we shouldn't see these
    return 0


def find_branch_context(lines, offset_line_idx):
    """Check if a DATA.W $xxxx line is after a ZBRAN/BRAN/LOOP/PLOOP."""
    for j in range(offset_line_idx - 1, max(0, offset_line_idx - 3), -1):
        prev = lines[j].strip()
        if 'DATA.W ZBRAN' in prev:
            return 'ZBRAN'
        if 'DATA.W BRAN' in prev and 'ZBRAN' not in prev:
            return 'BRAN'
        if 'DATA.W LOOP' in prev and 'PLOOP' not in prev:
            return 'LOOP'
        if 'DATA.W PLOOP' in prev:
            return 'PLOOP'
    return None


def is_offset_value(hex_str):
    """Check if hex string looks like a branch offset (not a word address)."""
    val = int(hex_str, 16)
    if val >= 0x8000:
        val -= 0x10000  # signed
    return -512 <= val <= 512


label_counter = 0


def get_or_create_label(lines, target_idx, word_name):
    """Get existing label at target line or create a new one."""
    global label_counter
    stripped = lines[target_idx].strip()

    # Check if line already has a label
    m = re.match(r'^([A-Za-z_.]\w*):?\s', stripped)
    if m:
        label = m.group(1).rstrip(':')
        return label

    # Create new label
    label_counter += 1
    label = f".{word_name}{label_counter}"
    lines[target_idx] = f"{label}\t{lines[target_idx].lstrip()}"
    return label


def find_current_word(lines, idx):
    """Find the name of the colon definition containing this line."""
    for j in range(idx, -1, -1):
        m = re.match(r'^(\w+):\s+JSR DOCOL', lines[j])
        if m:
            return m.group(1)
        m = re.match(r'^(\w+)\s+JSR DOCOL', lines[j])
        if m:
            return m.group(1)
    return "UNK"


converted = 0
i = 0
while i < len(lines):
    line = lines[i]

    # Match DATA.W $xxxx (hex offset)
    m = re.match(r'^(\s+)DATA\.W \$([0-9a-fA-F]{4})\s*$', line)
    if not m:
        i += 1
        continue

    indent = m.group(1)
    hex_val = m.group(2)

    # Check if this is after a branch instruction
    branch_type = find_branch_context(lines, i)
    if not branch_type:
        i += 1
        continue

    if not is_offset_value(hex_val):
        i += 1
        continue

    val = int(hex_val, 16)
    if val >= 0x8000:
        signed_val = val - 0x10000
    else:
        signed_val = val

    word_name = find_current_word(lines, i)

    if signed_val > 0:
        # Forward branch: count bytes forward
        bytes_counted = 0
        target_idx = i + 1
        while bytes_counted < signed_val and target_idx < len(lines):
            b = count_line_bytes(lines[target_idx])
            if b > 0:
                bytes_counted += b
            target_idx += 1

        if bytes_counted == signed_val and target_idx <= len(lines):
            # Target is at target_idx (first data line after we counted enough bytes)
            # Actually, target_idx-1 was the last line counted. Target is the NEXT data line.
            # Find the next non-empty line
            actual_target = target_idx
            while actual_target < len(lines) and count_line_bytes(lines[actual_target]) == 0:
                if lines[actual_target].strip().startswith(';;') or lines[actual_target].strip() == '':
                    actual_target += 1
                else:
                    break
            if actual_target >= len(lines):
                i += 1
                continue

            label = get_or_create_label(lines, actual_target, word_name)
            lines[i] = f"{indent}DATA.W ({label} - addr)\n"
            converted += 1
    else:
        # Backward branch: count bytes backward
        bytes_counted = 0
        target_idx = i - 1
        while bytes_counted > signed_val and target_idx >= 0:
            b = count_line_bytes(lines[target_idx])
            if b > 0:
                bytes_counted -= b
            target_idx -= 1

        if bytes_counted == signed_val:
            # target_idx+1 is the line where we went one too far back
            actual_target = target_idx + 1
            # Skip comment lines forward to find the actual data/code line
            while actual_target < i and count_line_bytes(lines[actual_target]) == 0:
                actual_target += 1

            if actual_target < i:
                label = get_or_create_label(lines, actual_target, word_name)
                lines[i] = f"{indent}DATA.W ({label} - addr)\n"
                converted += 1

    i += 1

print(f"  Converted {converted} branch offsets to symbolic labels")

# ============================================================================
# PASS 3: Clean up any remaining issues
# ============================================================================

# Make sure RESET vector line is DATA.W not label:DATA.W
# (should have been fixed in previous script)

# ============================================================================
# Write output
# ============================================================================

with open('src/ForthKernel-L28.asm', 'w') as f:
    f.writelines(lines)

print("\nDone!")
