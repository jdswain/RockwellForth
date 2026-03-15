#!/usr/bin/env python3
"""Fix absolute hex branch targets in ForthDevelopment-L28.asm.

Replace stale ITC-era absolute addresses with symbolic labels.
"""

import re

filepath = 'src/ForthDevelopment-L28.asm'

with open(filepath, 'rb') as f:
    raw = f.read()
lines = raw.decode('latin-1').split('\n')

# Map ITC hex addresses to the source lines they target.
# Each entry: hex_addr -> (line_number_1based, label_name)
# These were determined by cross-referencing the ITC listing.

# FMTRK routine: each hex addr targets a BIT DSK_CTL instruction
fmtrk_targets = {
    '$d6c2': (3661, '.Lfmt1'),
    '$d6cd': (3666, '.Lfmt2'),
    '$d6d7': (3670, '.Lfmt3'),
    '$d6e1': (3674, '.Lfmt4'),
    '$d6eb': (3678, '.Lfmt5'),
    '$d6f3': (3681, '.Lfmt6'),
    '$d6fd': (3685, '.Lfmt7'),
    '$d707': (3689, '.Lfmt8'),
    '$d713': (3694, '.Lfmt9'),
    '$d71e': (3699, '.Lfmt10'),
    '$d72a': (3704, '.Lfmt11'),
    '$d735': (3709, '.Lfmt12'),
    '$d741': (3714, '.Lfmt13'),
    '$d74c': (3719, '.Lfmt14'),
    '$d758': (3724, '.Lfmt15'),
    '$d762': (3728, '.Lfmt16'),
    '$d76d': (3733, '.Lfmt17'),
    '$d777': (3737, '.Lfmt18'),
    '$d783': (3742, '.Lfmt19'),
    '$d78e': (3747, '.Lfmt20'),
    '$d79b': (3753, '.Lfmt21'),
    '$d7a7': (3758, '.Lfmt22'),
    '$d7b2': (3762, '.Lfmt23'),   # LDY #$4e (end of sector loop)
    '$d7b4': (3763, '.Lfmt24'),   # BIT DSK_CTL (final wait loop)
    '$d7c1': (3768, '.Lfmt25'),   # PLA (exit point)
}

# $d6ab -> .L3658 (existing label, no new label needed)
jmp_d6ab_label = '.L3658'

# Lines near 3909-3916
other_targets = {
    '$d8bb': (3911, '.Lnc1'),     # PLA (no-carry skip)
    '$d8c7': (3918, '.Lhex1'),    # JMP $f5ec (hex output)
}

# Merge all targets
all_targets = {}
all_targets.update(fmtrk_targets)
all_targets.update(other_targets)

# Step 1: Add labels to target lines
# Build a map: 0-based line index -> label to prepend
label_map = {}  # line_idx -> label
for hex_addr, (line_num, label) in all_targets.items():
    idx = line_num - 1  # convert to 0-based
    label_map[idx] = label

# Step 2: Process lines
output = []
changes = 0

for i, line in enumerate(lines):
    # Add label if this line is a target
    if i in label_map:
        label = label_map[i]
        # Check if line already has a label
        s = line.lstrip()
        if s and not s.startswith('.') and not re.match(r'^\w+:', s):
            # No label - prepend one. Preserve the instruction's indentation style
            # Replace leading whitespace with label + tab alignment
            stripped = line.lstrip()
            line = f"{label} \t\t\t{stripped}"
            changes += 1

    # Replace hex addresses in branch/jump instructions
    # Match: BVS/BNE/BEQ/BCC/BPL/JMP followed by $xxxx
    m = re.search(r'\b(BVS|BNE|BEQ|BCC|BPL|JMP)\s+(\$[0-9a-f]{4})\b', line, re.IGNORECASE)
    if m:
        instr = m.group(1)
        hex_addr = m.group(2).lower()

        if hex_addr == '$d6ab':
            # Special case: existing label
            new_target = jmp_d6ab_label
            line = line[:m.start(2)] + new_target + line[m.end(2):]
            changes += 1
        elif hex_addr == '$f5ec':
            # ROM address - keep as-is
            pass
        elif hex_addr in all_targets:
            _, new_target = all_targets[hex_addr]
            line = line[:m.start(2)] + new_target + line[m.end(2):]
            changes += 1

    output.append(line)

print(f"Changes made: {changes}")

with open(filepath, 'wb') as f:
    f.write('\n'.join(output).encode('latin-1'))

print(f"Written to {filepath}")
