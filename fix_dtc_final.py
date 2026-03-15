#!/usr/bin/env python3
"""Fix symbolic branch conversions back to correct numeric values.
Then properly handle DECIMAL and CTLRQ.
Also remove orphan labels added by the bad script.
"""

import re

with open('src/ForthKernel-L28.asm', 'r') as f:
    lines = f.readlines()

# ============================================================================
# Map of symbolic expressions -> correct numeric offsets
# Based on RC19 ITC values (which are the same for DTC within-word offsets)
# ============================================================================

# These are the corrections. Each entry: (line_content_pattern, replacement)
# We'll match by the expression and the surrounding word context.

fixes = [
    # DDUP: $0004
    ('(HEX - addr)', '$0004'),
    # DECIMAL: $FFF2 (adjusted from $FFF3 for DTC cross-word)
    # Already handled as (L1170 - addr), keep it symbolic since it's correct
    # TYPE: $fff8 backward loop
    ('(.TYPE1 - addr)', '$fff8'),
    # DTRAI: $0008 and $0004
    ('(.DTRAI2 - addr)', '$0008'),
    ('(.DTRAI3 - addr)', '$0004'),
    # EXPECT: $000c, $003a, $001f, $0015, $000c, $ffa9
    ('(.EXPECT4 - addr)', '$000c'),
    ('(.EXPECT5 - addr)', '$003a'),
    ('(.EXPECT6 - addr)', '$001f'),
    ('(.EXPECT7 - addr)', '$0015'),
    ('(.EXPECT8 - addr)', '$000c'),
    ('(.EXPECT9 - addr)', '$ffa9'),
    # FILL_: $0008
    ('(.FILL_10 - addr)', '$0008'),
    # LTNUMBER: $002c, $0008, $ffc6
    ('(.LTNUMBER11 - addr)', '$002c'),
    ('(.LTNUMBER12 - addr)', '$0008'),
    ('(.LTNUMBER13 - addr)', '$ffc6'),
    # PM: $0004
    ('(DPLUS1 - addr)', '$0004'),
    # DPLUS1: $0004
    ('(ABS - addr)', '$0004'),
    # MIN: $0004
    ('(.MIN14 - addr)', '$0004'),
    # MAX: $0004
    ('(.MAX15 - addr)', '$0004'),
    # DISK: $0008, $0004, $0013
    ('(.DISK16 - addr)', '$0008'),
    ('(.DISK17 - addr)', '$0004'),
    ('(SELECT - addr)', '$0013'),
    # SPACES: $000c
    ('(LEQ - addr)', '$000c'),
    # SIGN: $0007
    ('(DIG - addr)', '$0007'),
    # DIG: $0007
    ('(.DIG18 - addr)', '$0007'),
    # HASHS: $fff6
    ('(.HASHS19 - addr)', '$fff6'),
    # CTLRQ: keep the symbolic .CTLRQ_END but fix to $0004
    # Actually, let me use the numeric value for now
    ('(.CTLRQ_END - addr) ;; skip MMON if not Ctrl-R', '$0004'),
    # MMON: $ffd6
    ('(.MMON20 - addr)', '$ffd6'),
]

print("Fixing symbolic expressions back to numeric...")

for pattern, replacement in fixes:
    found = False
    for i, line in enumerate(lines):
        if pattern in line:
            # Replace the symbolic expression with the numeric value
            new_line = line.replace(pattern, replacement)
            # Also remove any ;; comment that was part of the symbolic fix
            if replacement == '$0004' and 'skip MMON' in new_line:
                new_line = re.sub(r'\s*;;.*$', '', new_line) + '\n'
            lines[i] = new_line
            print(f"  Line {i+1}: {pattern} -> {replacement}")
            found = True
            break
    if not found:
        print(f"  WARNING: Pattern not found: {pattern}")

# Fix DECIMAL: change (L1170 - addr) to $fff2 for DTC
for i, line in enumerate(lines):
    if '(L1170 - addr)' in line:
        lines[i] = line.replace('(L1170 - addr)', '$fff2')
        # Remove the comment too
        lines[i] = re.sub(r'\s*;;.*$', '', lines[i]) + '\n'
        print(f"  Line {i+1}: (L1170 - addr) -> $fff2 (DTC cross-word)")
        break

# ============================================================================
# Remove orphaned .LABELn labels that were added by the script
# ============================================================================

print("\nRemoving orphaned labels...")

# Find all .WORD labels and check if they're still referenced
i = 0
while i < len(lines):
    line = lines[i]
    # Match labels like .TYPE1, .DTRAI2, etc. at start of line
    m = re.match(r'^(\.[A-Za-z_]\w*)\s+(.*)', line)
    if m:
        label = m.group(1)
        rest = m.group(2)
        # Check if this label is referenced anywhere (other than its definition)
        referenced = False
        for j, other_line in enumerate(lines):
            if j == i:
                continue
            if label in other_line and 'DATA.W' in other_line:
                referenced = True
                break
        if not referenced:
            # Remove the label, keep the rest
            if rest.strip():
                lines[i] = '\t\t\t' + rest.lstrip()
                if not lines[i].endswith('\n'):
                    lines[i] += '\n'
            else:
                # Line was just the label and comments
                # Check if it's a comment line
                if rest.strip().startswith(';;'):
                    lines[i] = rest
                    if not lines[i].endswith('\n'):
                        lines[i] += '\n'
                else:
                    pass  # leave as-is
            print(f"  Removed orphan label {label} at line {i+1}")
    i += 1

# ============================================================================
# Verify CTLRQ has the SEMIS line
# ============================================================================

# The .CTLRQ_END label and DATA.W SEMIS line should still be there
for i, line in enumerate(lines):
    if '.CTLRQ_END' in line and 'DATA.W SEMIS' in line:
        # Keep this line but remove the .CTLRQ_END label since we're using numeric offset now
        lines[i] = "\t\t\tDATA.W SEMIS\n"
        print(f"\n  Cleaned up CTLRQ SEMIS line at {i+1}")
        break

# ============================================================================
# Write
# ============================================================================

with open('src/ForthKernel-L28.asm', 'w') as f:
    f.writelines(lines)

print("\nDone! All branch offsets restored to numeric values.")
print("DECIMAL offset adjusted to $FFF2 for DTC.")
print("CTLRQ fixed with added SEMIS and $0004 offset.")
