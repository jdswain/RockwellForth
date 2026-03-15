#!/usr/bin/env python3
"""Convert ForthDevelopment-L28.asm from ITC to DTC.

Changes:
1. CFA: data.w DOCOL/DOCON/DOVAR/DOUSE/DOES → JSR DOxxx
2. Self-ref primitives: LABEL: data.w LABEL+2 → LABEL: (remove CFA cell)
3. Alias CFAs: [LABEL:] data.w TARGET+2 → [LABEL:] JMP TARGET
4. PFAPTRs: WORD+2 → WORD+3 (JSR words) or WORD (primitives)
5. Special: JMP CODE2+2 → JMP CODE2
"""

import re
import sys

DOXXX = {'DOCOL', 'DOCON', 'DOVAR', 'DOUSE', 'DOES'}


def main():
    filepath = 'src/ForthDevelopment-L28.asm'

    with open(filepath, 'rb') as f:
        raw = f.read()
    lines = raw.decode('latin-1').split('\n')

    # ===== PASS 1: Build word type map =====
    # For each label with a definition, determine its CFA type
    word_types = {}  # label → 'DOCOL'|'DOCON'|'DOVAR'|'DOUSE'|'DOES'|'self_ref'|'alias'

    for line in lines:
        s = line.strip()

        # Check DOxxx CFA: LABEL: data.w DOxxx
        m = re.match(r'^(\w+):\s+data\.w\s+(DOCOL|DOCON|DOVAR|DOUSE|DOES)\s*$', s, re.IGNORECASE)
        if m:
            word_types[m.group(1)] = m.group(2).upper()
            continue

        # Check self-ref: LABEL: data.w LABEL+2
        m = re.match(r'^(\w+):\s+data\.w\s+(\w+)\+2\s*$', s)
        if m:
            label, target = m.group(1), m.group(2)
            if label == target:
                word_types[label] = 'self_ref'
            else:
                word_types[label] = 'alias'

    print(f"Word types: {len(word_types)} words")
    print(f"  DOxxx: {sum(1 for v in word_types.values() if v in DOXXX)}")
    print(f"  self_ref: {[k for k,v in word_types.items() if v == 'self_ref']}")
    print(f"  alias: {[k for k,v in word_types.items() if v == 'alias']}")

    # ===== PASS 2: Identify PFAPTR and CFA-body lines via state machine =====
    pfaptr_indices = set()    # 0-based line indices
    cfa_body_indices = set()  # 0-based line indices (unlabeled CFA bodies after PFAPTR)

    state = 'normal'
    for i, line in enumerate(lines):
        s = line.strip()

        # Skip blank lines and comments
        if not s or s.startswith(';;'):
            continue

        if 'text.7' in s.lower():
            state = 'after_nfa'
            continue

        if state == 'after_nfa':
            if re.match(r'^data\.w\s+', s, re.IGNORECASE):
                state = 'after_lfa'
                continue
            else:
                state = 'normal'

        if state == 'after_lfa':
            if re.match(r'^data\.w\s+', s, re.IGNORECASE):
                pfaptr_indices.add(i)
                state = 'after_pfaptr'
                continue
            else:
                state = 'normal'

        if state == 'after_pfaptr':
            # Check if this is a labeled word body (has label:)
            if re.match(r'^\w+:\s+', s):
                state = 'normal'
                # Fall through to normal processing below
            elif re.match(r'^data\.w\s+\w+\+2\s*$', s, re.IGNORECASE):
                # Unlabeled CFA body (like NOT's data.w ZEQ+2)
                cfa_body_indices.add(i)
                state = 'normal'
                continue
            else:
                state = 'normal'
        else:
            if state not in ('normal',):
                state = 'normal'

    print(f"\nPFAPTR lines: {len(pfaptr_indices)}")
    print(f"CFA body lines: {len(cfa_body_indices)}")

    # ===== PASS 3: Apply transformations =====
    output = []
    stats = {'cfa_jsr': 0, 'pfaptr_plus3': 0, 'pfaptr_remove2': 0,
             'self_ref': 0, 'alias_labeled': 0, 'cfa_body_alias': 0}

    for i, line in enumerate(lines):
        s = line.strip()

        # --- Rule A: Unlabeled CFA body (e.g., NOT's data.w ZEQ+2) ---
        if i in cfa_body_indices:
            m = re.match(r'^(\s+)data\.w\s+(\w+)\+2(\s*)$', line, re.IGNORECASE)
            if m:
                indent, target, trail = m.group(1), m.group(2), m.group(3)
                new_line = f"{indent}JMP {target}{trail}"
                stats['cfa_body_alias'] += 1
                output.append(new_line)
                continue

        # --- Rule B: Self-referential primitive (LABEL: data.w LABEL+2 → LABEL:) ---
        m = re.match(r'^(\s*)(\w+):\s+data\.w\s+(\w+)\+2(\s*)$', line)
        if m and m.group(2) == m.group(3):
            indent, label = m.group(1), m.group(2)
            new_line = f"{indent}{label}:"
            stats['self_ref'] += 1
            output.append(new_line)
            continue

        # --- Rule C: Labeled alias (LABEL: data.w TARGET+2 → LABEL: JMP TARGET) ---
        # Only if NOT a PFAPTR line
        if i not in pfaptr_indices:
            m = re.match(r'^(\s*)(\w+):\s+data\.w\s+(\w+)\+2(\s*)$', line)
            if m and m.group(2) != m.group(3):
                indent, label, target = m.group(1), m.group(2), m.group(3)
                new_line = f"{indent}{label}:\t\t\tJMP {target}"
                stats['alias_labeled'] += 1
                output.append(new_line)
                continue

        # --- Rule D: DOxxx CFA conversion (data.w DOxxx → JSR DOxxx) ---
        m = re.search(r'\bdata\.w\s+(DOCOL|DOCON|DOVAR|DOUSE|DOES)\s*$', line, re.IGNORECASE)
        if m:
            doxxx = m.group(1)
            # Check if LIT argument (previous non-blank non-comment line has LIT)
            is_lit_arg = False
            for j in range(i - 1, max(i - 5, -1), -1):
                pline = lines[j].strip()
                if pline and not pline.startswith(';;'):
                    if re.search(r'\bdata\.w\s+LIT\s*$', pline, re.IGNORECASE):
                        is_lit_arg = True
                    break

            if not is_lit_arg:
                new_line = re.sub(
                    r'data\.w\s+(DOCOL|DOCON|DOVAR|DOUSE|DOES)(\s*)$',
                    r'JSR \1\2',
                    line,
                    flags=re.IGNORECASE
                )
                stats['cfa_jsr'] += 1
                output.append(new_line)
                continue

        # --- Rule E: PFAPTR update (WORD+2 → WORD+3 or WORD) ---
        if i in pfaptr_indices:
            m = re.match(r'^(\s+data\.w\s+)(\w+)\+2(\s*.*)$', line, re.IGNORECASE)
            if m:
                prefix, word, suffix = m.group(1), m.group(2), m.group(3)
                wtype = word_types.get(word)
                if wtype in DOXXX:
                    new_line = f"{prefix}{word}+3{suffix}"
                    stats['pfaptr_plus3'] += 1
                else:
                    new_line = f"{prefix}{word}{suffix}"
                    stats['pfaptr_remove2'] += 1
                output.append(new_line)
                continue

        # --- Rule F: JMP CODE2+2 → JMP CODE2 (in CODE1's body) ---
        if 'JMP CODE2+2' in line:
            new_line = line.replace('JMP CODE2+2', 'JMP CODE2')
            output.append(new_line)
            continue

        # No transformation
        output.append(line)

    print(f"\nTransformation stats:")
    for k, v in sorted(stats.items()):
        print(f"  {k}: {v}")
    print(f"  Total lines: {len(lines)}")

    # Write output
    with open(filepath, 'wb') as f:
        f.write('\n'.join(output).encode('latin-1'))

    print(f"\nDone. Written to {filepath}")


if __name__ == '__main__':
    main()
