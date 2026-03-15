#!/usr/bin/env python3
"""Fix corrupted branch offsets in pre-symbolic backup.

Copy correct offset values from .bak (ITC original) to pre-symbolic (DTC).
Thread layout is identical between ITC and DTC, so offsets are the same.
"""

import re

BRANCH_OPS = {'ZBRAN', 'BRAN', 'LOOP', 'PLOOP', 'XLOOP'}

def find_branch_offsets(lines):
    """Return list of (line_index, hex_value_str) for branch offset lines."""
    results = []
    i = 0
    while i < len(lines):
        s = lines[i].strip()
        is_branch = False
        for op in BRANCH_OPS:
            if re.search(rf'\bdata\.w\s+{op}\b', s, re.IGNORECASE):
                is_branch = True
                break
        if is_branch:
            is_compile = False
            for k in range(i - 1, max(i - 5, -1), -1):
                prev = lines[k].strip()
                if not prev or prev.startswith(';;'):
                    continue
                if re.search(r'\bdata\.w\s+COMPILE\b', prev, re.IGNORECASE):
                    is_compile = True
                break
            if not is_compile:
                for j in range(i + 1, min(i + 5, len(lines))):
                    ns = lines[j].strip()
                    if not ns or ns.startswith(';;'):
                        continue
                    m = re.match(r'(.*data\.w\s+)\$([0-9a-f]{4})(\s*)$', lines[j], re.IGNORECASE)
                    if m:
                        results.append((j, m.group(2)))
                    break
        i += 1
    return results


with open('src/ForthDevelopment-L28.asm.bak', 'rb') as f:
    bak = f.read().decode('latin-1').split('\n')
with open('src/ForthDevelopment-L28.asm.pre-symbolic', 'rb') as f:
    cur = f.read().decode('latin-1').split('\n')

bak_offsets = find_branch_offsets(bak)
cur_offsets = find_branch_offsets(cur)

print(f'BAK: {len(bak_offsets)} branch offsets')
print(f'CUR: {len(cur_offsets)} branch offsets')

fixes = 0
for idx in range(min(len(bak_offsets), len(cur_offsets))):
    _, bval = bak_offsets[idx]
    cli, cval = cur_offsets[idx]
    if bval != cval:
        old = cur[cli]
        new = re.sub(r'(data\.w\s+)\$[0-9a-f]{4}', rf'\g<1>${bval}', old, flags=re.IGNORECASE)
        cur[cli] = new
        fixes += 1
        print(f'  [{idx}] line {cli+1}: ${cval} → ${bval}')

print(f'\nFixed {fixes} offsets')

with open('src/ForthDevelopment-L28.asm.pre-symbolic', 'wb') as f:
    f.write('\n'.join(cur).encode('latin-1'))
print('Written to pre-symbolic backup')
