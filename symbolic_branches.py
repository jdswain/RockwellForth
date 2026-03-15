#!/usr/bin/env python3
"""Convert numeric branch offsets to symbolic (label - addr) expressions.

Strategy: Parse the listing file to find all branch offsets and their targets,
then apply changes to the source file by matching branch instructions in order.
Uses branch source line positions for label disambiguation.
"""

import re
import sys

LISTING = 'src/ForthDevelopment-L28.lst'
SOURCE = 'src/ForthDevelopment-L28.asm'
DEV_ADDR_START = 0xc000  # Development section start address
DEV_ADDR_END = 0xf000    # Kernel starts here, development ends before this

BRANCH_OPS = {'ZBRAN', 'BRAN', 'LOOP', 'PLOOP', 'XLOOP'}


def get_lst_source(lst_line):
    """Extract source text from listing line."""
    content = lst_line.rstrip('\n')
    if '→' in content:
        content = content.split('→', 1)[1]
    content = content.strip()
    if not re.match(r'[0-9a-f]{4}:', content):
        return ''
    rest = content[5:]
    pos = 0
    while pos + 3 <= len(rest):
        chunk = rest[pos:pos+3]
        if chunk[0] == ' ' and re.match(r'[0-9a-f]{2}', chunk[1:3]):
            pos += 3
        else:
            break
    source = rest[pos:]
    if source.strip():
        return source.lstrip()
    if pos == 0 and rest.strip():
        return rest.strip()
    return ''


def get_lst_addr(lst_line):
    """Extract hex address from listing line."""
    content = lst_line.strip()
    if '→' in content:
        content = content.split('→', 1)[1].strip()
    m = re.match(r'([0-9a-f]{4}):', content)
    if m:
        return int(m.group(1), 16)
    return None


def get_lst_hex(lst_line):
    """Extract hex bytes from listing line as a byte array."""
    content = lst_line.rstrip('\n')
    if '→' in content:
        content = content.split('→', 1)[1]
    content = content.strip()
    if not re.match(r'[0-9a-f]{4}:', content):
        return b''
    rest = content[5:]
    hex_bytes = []
    pos = 0
    while pos + 3 <= len(rest):
        chunk = rest[pos:pos+3]
        if chunk[0] == ' ' and re.match(r'[0-9a-f]{2}', chunk[1:3]):
            hex_bytes.append(int(chunk[1:3], 16))
            pos += 3
        else:
            break
    return bytes(hex_bytes)


def is_compile_preceded(lines, i, get_source_fn):
    """Check if line i is preceded by a COMPILE instruction."""
    for k in range(i - 1, max(i - 5, -1), -1):
        prev = get_source_fn(lines[k]).strip()
        if not prev or prev.startswith(';;'):
            continue
        if re.search(r'\bdata\.w\s+COMPILE\b', prev, re.IGNORECASE):
            return True
        return False
    return False


def main():
    with open(LISTING, 'r', encoding='latin-1') as f:
        lst_lines = f.readlines()
    with open(SOURCE, 'rb') as f:
        src_lines = f.read().decode('latin-1').split('\n')

    # ===== STEP 1: Parse listing to build complete address maps =====

    addr_to_lst = {}  # addr → listing line index (first occurrence)
    addr_to_source = {}  # addr → source text at that address
    addr_to_label = {}  # addr → label name

    for i, line in enumerate(lst_lines):
        addr = get_lst_addr(line)
        if addr is None:
            continue
        src = get_lst_source(line)

        if addr not in addr_to_lst:
            addr_to_lst[addr] = i

        if src.strip():
            addr_to_source[addr] = src.strip()

            m = re.match(r'^([\w][\w.]*)\s*:', src)
            if m:
                addr_to_label[addr] = m.group(1)
            m = re.match(r'^(\.[\w]+)\s', src)
            if m:
                addr_to_label[addr] = m.group(1)

    print(f"Parsed listing: {len(addr_to_lst)} addresses, {len(addr_to_label)} labels")

    # ===== STEP 2: Find all branch offsets in listing =====

    listing_branches = []  # list of (offset_addr, offset_value, target_addr, branch_type)

    for i, line in enumerate(lst_lines):
        addr = get_lst_addr(line)
        if addr is None or addr < DEV_ADDR_START or addr >= DEV_ADDR_END:
            continue

        src = get_lst_source(line).strip()
        if not src:
            continue

        branch_type = None
        for op in BRANCH_OPS:
            if re.search(rf'\bDATA\.W\s+{op}\b', src, re.IGNORECASE):
                branch_type = op
                break

        if not branch_type:
            continue

        if is_compile_preceded(lst_lines, i, get_lst_source):
            continue

        for j in range(i + 1, min(i + 10, len(lst_lines))):
            next_addr = get_lst_addr(lst_lines[j])
            hex_data = get_lst_hex(lst_lines[j])
            next_src = get_lst_source(lst_lines[j]).strip()
            if next_addr is not None and len(hex_data) >= 2:
                if not re.match(r'.*data\.w\s+\$[0-9a-f]{4}\s*$', next_src, re.IGNORECASE):
                    break
                if len(hex_data) > 2:
                    break
                offset_value = hex_data[0] | (hex_data[1] << 8)
                signed_offset = offset_value - 0x10000 if offset_value >= 0x8000 else offset_value
                target_addr = (next_addr + signed_offset) & 0xFFFF
                listing_branches.append((next_addr, offset_value, target_addr, branch_type))
                break

    print(f"Found {len(listing_branches)} branch offsets in listing")


    # ===== STEP 3: Pair listing branches with source lines (dry run) =====
    # Walk source to find branch source line positions without modifying anything.

    branch_src_lines = {}  # listing_branch_idx → source_line_of_offset

    src_branch_idx = 0
    i = 0
    while i < len(src_lines):
        s = src_lines[i].strip()
        is_branch = any(re.search(rf'\bdata\.w\s+{op}\b', s, re.IGNORECASE) for op in BRANCH_OPS)

        if is_branch and src_branch_idx < len(listing_branches):
            if is_compile_preceded(src_lines, i, lambda x: x):
                i += 1
                continue

            for j in range(i + 1, min(i + 5, len(src_lines))):
                ns = src_lines[j].strip()
                if not ns or ns.startswith(';;'):
                    continue
                m = re.match(r'.*data\.w\s+\$[0-9a-f]{4}\s*$', ns, re.IGNORECASE)
                if m:
                    branch_src_lines[src_branch_idx] = j
                    src_branch_idx += 1
                break
        i += 1

    print(f"Paired {len(branch_src_lines)} branches with source lines")

    # Build sorted list of (listing_addr, source_line) known correspondences
    known_points = []  # sorted by listing_addr
    for idx in sorted(branch_src_lines):
        offset_addr = listing_branches[idx][0]
        src_line = branch_src_lines[idx]
        known_points.append((offset_addr, src_line))
    known_points.sort()

    def estimate_src_line(target_addr):
        """Estimate source line for a target address using known correspondences."""
        # Find bracketing known points
        prev_addr, prev_src = None, None
        next_addr, next_src = None, None
        for ka, ks in known_points:
            if ka <= target_addr:
                prev_addr, prev_src = ka, ks
            if ka >= target_addr and next_addr is None:
                next_addr, next_src = ka, ks
        if prev_addr is not None and next_addr is not None and prev_addr != next_addr:
            # Interpolate
            frac = (target_addr - prev_addr) / (next_addr - prev_addr)
            return prev_src + frac * (next_src - prev_src)
        elif prev_addr is not None:
            return prev_src
        elif next_addr is not None:
            return next_src
        return len(src_lines) / 2

    # ===== STEP 4: Create labels and find target source lines =====

    label_counter = {}

    def get_word_name_at(addr):
        """Find the enclosing word name for an address by scanning backwards."""
        for a in range(addr, max(addr - 200, DEV_ADDR_START), -1):
            if a in addr_to_source:
                m = re.match(r'^([\w]+)\s*:.*JSR\s+(DOCOL|DOES|DOCON)', addr_to_source[a], re.IGNORECASE)
                if m:
                    return m.group(1)
        return 'UNK'

    target_labels = {}  # target_addr → label_name
    target_src_lines = {}  # target_addr → source_line_index for new label

    for offset_addr, offset_value, target_addr, branch_type in listing_branches:
        if target_addr in target_labels:
            continue
        if target_addr in addr_to_label:
            target_labels[target_addr] = addr_to_label[target_addr]
            continue

        # Need to create a new label
        word_name = get_word_name_at(target_addr)
        if word_name not in label_counter:
            label_counter[word_name] = 0
        label_counter[word_name] += 1
        label = f'L_{word_name}_{label_counter[word_name]}'
        target_labels[target_addr] = label
        addr_to_label[target_addr] = label

        # Find the correct source line for this label
        if target_addr not in addr_to_source:
            print(f"  WARNING: no source text at target ${target_addr:04x} for {label}")
            continue

        target_text = addr_to_source[target_addr].strip()

        candidates = [si for si, sl in enumerate(src_lines) if sl.strip() == target_text]

        if len(candidates) == 0:
            print(f"  WARNING: cannot find '{target_text[:40]}' in source for {label}")
            continue

        if len(candidates) == 1:
            target_src_lines[target_addr] = candidates[0]
        else:
            # Disambiguate using estimated source line from listing address
            est = estimate_src_line(target_addr)

            # Also use branch direction to filter candidates
            # Find a branch that references this target
            ref_src_line = None
            ref_signed_off = None
            for idx2, (oa2, ov2, ta2, bt2) in enumerate(listing_branches):
                if ta2 == target_addr and idx2 in branch_src_lines:
                    ref_src_line = branch_src_lines[idx2]
                    ref_signed_off = ov2 - 0x10000 if ov2 >= 0x8000 else ov2
                    break

            if ref_src_line is not None:
                if ref_signed_off >= 0:
                    # Forward branch: target must be AFTER the branch
                    valid = [c for c in candidates if c > ref_src_line]
                else:
                    # Backward branch: target must be BEFORE the branch
                    valid = [c for c in candidates if c < ref_src_line]
                if valid:
                    best = min(valid, key=lambda c: abs(c - est))
                else:
                    best = min(candidates, key=lambda c: abs(c - est))
            else:
                best = min(candidates, key=lambda c: abs(c - est))

            target_src_lines[target_addr] = best

    new_labels = {addr: name for addr, name in target_labels.items()
                  if name.startswith('L_')}
    print(f"Target labels: {len(target_labels)} total, {len(new_labels)} new")

    # ===== STEP 5: Add new labels to source file =====

    labels_added = 0
    for target_addr in sorted(target_src_lines):
        label_name = target_labels[target_addr]
        if not label_name.startswith('L_'):
            continue  # existing label, don't add

        si = target_src_lines[target_addr]
        old_line = src_lines[si]

        # If line already has a label, use the existing label instead
        if re.match(r'^[\w.]', old_line):
            m = re.match(r'^([\w.]+)', old_line)
            if m:
                existing = m.group(1).rstrip(':')
                target_labels[target_addr] = existing
                print(f"  Using existing label '{existing}' instead of '{label_name}'")
                continue

        src_lines[si] = f"{label_name}\t\t\t{old_line.lstrip()}"
        labels_added += 1

    print(f"Labels added: {labels_added}")

    # ===== STEP 6: Replace numeric offsets in source =====

    src_branch_idx = 0
    replacements = 0

    i = 0
    while i < len(src_lines):
        s = src_lines[i].strip()

        is_branch = any(re.search(rf'\bdata\.w\s+{op}\b', s, re.IGNORECASE) for op in BRANCH_OPS)

        if is_branch and src_branch_idx < len(listing_branches):
            if is_compile_preceded(src_lines, i, lambda x: x):
                i += 1
                continue

            for j in range(i + 1, min(i + 5, len(src_lines))):
                ns = src_lines[j].strip()
                if not ns or ns.startswith(';;'):
                    continue

                m = re.match(r'(.*?data\.w\s+)\$([0-9a-f]{4})(\s*)$', src_lines[j], re.IGNORECASE)
                if m:
                    offset_addr, offset_value, target_addr, branch_type = listing_branches[src_branch_idx]

                    src_hex = int(m.group(2), 16)
                    if src_hex != offset_value:
                        print(f"  WARNING: value mismatch at line {j+1}: src=${src_hex:04x} vs lst=${offset_value:04x}")
                        src_branch_idx += 1
                        break

                    label = target_labels.get(target_addr)
                    if label:
                        prefix = m.group(1)
                        suffix = m.group(3)
                        src_lines[j] = f"{prefix}({label} - addr){suffix}"
                        replacements += 1

                    src_branch_idx += 1
                break
        i += 1

    print(f"Replacements: {replacements}/{len(listing_branches)}")

    with open(SOURCE, 'wb') as f:
        f.write('\n'.join(src_lines).encode('latin-1'))

    print(f"Written to {SOURCE}")


if __name__ == '__main__':
    main()
