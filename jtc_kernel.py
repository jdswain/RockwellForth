#!/usr/bin/env python3
"""
JTC (JPI-Threaded Code) conversion for ForthKernel-L28.asm

Converts from DTC to JTC:
- Add DV (Dispatch Vector) self-pointer: LABEL: DATA.W (LABEL+2)
- JSR DOCOL → PHI for colon words
- DATA.W WORD → JPI WORD in thread bodies
- JMP NEXT → TIP for primitive exits
- Inline data → 3-byte data slots with filler byte
- Rewrite SEMIS with interrupt check
- Update LIT/CLIT/BRAN/ZBRAN with INI filler skip
- Update BUMP to skip 3-byte data slot
- Fix JMP/branch targets that hit DVs
"""

import re
import sys

# ── Word classification ──────────────────────────────────────────────

# All Forth words that need a DV (Dispatch Vector)
FORTH_WORDS = {
    # Primitives
    'LIT', 'CLIT', 'EXECUTE', 'BRAN', 'ZBRAN', 'LOOP', 'PLOOP',
    'DO', 'DIGIT', 'FIND', 'ENCLOSE',
    'EMIT', 'KEY', 'QTERM', 'CR', 'CMOVE',
    'USTAR', 'USLAS', 'ANDD', 'OR', 'XOR',
    'SPAT', 'SPSTO', 'RPSTO', 'PUSHS', 'SEMIS', 'LEAVE',
    'GTR', 'RFROM', 'R',
    'ZEQ', 'ZLT', 'PLUS', 'DPLUS', 'NEGATE', 'DNEGATE',
    'OVER', 'DROP', 'TWODROP', 'SWAP', 'DUP', 'TWODUP', 'BOUNDS',
    'PSTORE', 'TOGGL', 'AT', 'CAT', 'STORE', 'CSTOR',
    'ONEPLUS', 'TWOPLUS', 'ONEMINUS', 'TWOMINUS',
    'ULESS', 'LESS', 'ROT', 'MUL',
    'SELECT', 'DREAD', 'DWRITE', 'INIT', 'SEEK',
    'EECSTORE', 'BANKPSH', 'BANKPOP',
    'L2149',
    # Constants (JSR DOCON)
    'ZERO', 'ONE', 'TWO', 'THREE', 'FOUR', 'BL',
    # User variables (JSR DOUSE)
    'TIB', 'SZ', 'RZ', 'UCL', 'UPAD', 'URW', 'BASE',
    'CLDWRM', 'IN', 'DPL', 'HLD',
    # Colon words (JSR DOCOL)
    'CL', 'PAD', 'SUB', 'EQUAL', 'GT', 'PICK', 'SPACE', 'DDUP',
    'HEX', 'DECIMAL', 'COUNT', 'TYPE', 'DTRAI', 'PDOTQ',
    'EXPECT', 'QUERY', 'FILL_', 'ERASE', 'BLANKS',
    'HOLD', 'LTNUMBER', 'STOD', 'PM', 'DPLUS1', 'ABS', 'DABS',
    'MIN', 'MAX', 'MMUL', 'MDIV', 'DIVMOD', 'DIV_', 'MOD_',
    'MULDIVMOD', 'MULDIV', 'MDIVMOD', 'DISK',
    'SPACES', 'LEQ', 'HASHGT', 'SIGN', 'DIG', 'HASHS',
    'DDOTR', 'DDOT', 'DOTR', 'DOT', 'Q',
    'BANKCSTOR', 'BANKCAT', 'BANKEECS', 'BANKEXEC',
    'CTLRQ', 'MMON',
}

# Words that consume inline data from thread
INLINE_DATA_WORDS = {'LIT', 'CLIT', 'BRAN', 'ZBRAN', 'LOOP', 'PLOOP', 'PDOTQ'}

# ── Helpers ──────────────────────────────────────────────────────────

def get_label(line):
    """Extract label name from line start. Returns (label, rest_of_line)."""
    # Match LABEL: rest
    m = re.match(r'^(\w+):\s*(.*)', line)
    if m:
        return m.group(1), m.group(2)
    # Match .LABEL rest (local labels)
    m = re.match(r'^(\.\w+)\s*(.*)', line)
    if m:
        return m.group(1), m.group(2)
    # Match bare labels at column 0: WORD<whitespace>instruction
    # Requires 2+ whitespace chars between label and instruction
    m = re.match(r'^([A-Za-z_]\w*)\s{2,}(.*)', line)
    if m:
        word = m.group(1).upper()
        # Exclude assembler directives and instructions
        if word not in {'DATA', 'FILL', 'ORG', 'ALIGN', 'MESSAGE',
                        'CPU', 'MACHINE', 'ENTRY', 'INCLUDE'}:
            return m.group(1), m.group(2)
    return None, line

def strip_comment(text):
    """Split into (code, comment). Comment starts at ; outside quotes."""
    in_quote = False
    for i, ch in enumerate(text):
        if ch == '"':
            in_quote = not in_quote
        elif ch == ';' and not in_quote:
            return text[:i].rstrip(), text[i:]
    return text, ''

def extract_data_w_word(code):
    """If code contains 'DATA.W WORDNAME' (single word), return WORDNAME. Else None."""
    # Use re.search to handle lines with label prefixes like 'L1170  DATA.W BASE'
    m = re.search(r'DATA\.W\s+(\w+)\s*$', code.strip(), re.IGNORECASE)
    if m:
        word = m.group(1)
        if word in FORTH_WORDS:
            return word
    return None


# ── Main conversion ─────────────────────────────────────────────────

def convert(input_lines):
    lines = list(input_lines)
    out = []
    i = 0
    in_thread = False      # Are we inside a thread body?
    after_inline = None    # Which inline-data word was just emitted?
    stats = {'dv': 0, 'phi': 0, 'jpi': 0, 'tip': 0, 'slot': 0}

    while i < len(lines):
        line = lines[i]
        label, rest = get_label(line)
        code, comment = strip_comment(rest if label else line)
        code_s = code.strip()

        # ════════════════════════════════════════════════════════════
        # 0. Vector table and end-of-file: pass through unchanged
        # ════════════════════════════════════════════════════════════
        if label in ('JSB0','JSB1','JSB2','JSB3','JSB4','JSB5','JSB6','JSB7',
                      'IRQ0','IRQ1','IRQ2','IRQ3','IRQ4','IRQ5','NMI'):
            out.append(line)
            i += 1
            continue
        # RESET at end of file is the vector table entry, not code
        if label == 'RESET' and 'DATA.W' in line and 'FFFE' in comment:
            out.append(line)
            i += 1
            continue
        # FILL directive, entry directive
        if code_s.startswith('FILL') or code_s.startswith('entry'):
            out.append(line)
            i += 1
            continue

        # ════════════════════════════════════════════════════════════
        # 1. Handle expected inline data from previous JPI
        # ════════════════════════════════════════════════════════════
        if after_inline:
            word = after_inline
            after_inline = None

            if word == 'PDOTQ':
                # Counted string — pass through unchanged
                out.append(line)
                i += 1
                continue

            elif word == 'CLIT':
                # DATA.B byte → DATA.B $00, byte, $00
                m = re.match(r'^(\s*(?:\.\w+\s+|\w+:?\s+)?)(DATA\.B\s+)(.+?)(\s*;.*)?$',
                             line, re.IGNORECASE)
                if m:
                    prefix = m.group(1)
                    byte_val = m.group(3).strip()
                    cmt = m.group(4) or ''
                    out.append(f'{prefix}DATA.B $00, {byte_val}, $00{cmt}')
                    stats['slot'] += 1
                else:
                    out.append(line + '  ; WARNING: CLIT data not converted')
                i += 1
                continue

            elif word == 'LIT':
                # DATA.W value → DATA.B $00 + DATA.W value (on separate lines)
                m = re.match(r'^(\s*)((?:\.\w+\s+|\w+:?\s+)?)(DATA\.W\s+)(.+?)(\s*;.*)?$',
                             line, re.IGNORECASE)
                if m:
                    indent = m.group(1)
                    lbl_part = m.group(2).rstrip()
                    value = m.group(4).strip()
                    cmt = m.group(5) or ''
                    if lbl_part:
                        out.append(f'{indent}{lbl_part}\tDATA.B $00')
                    else:
                        out.append(f'{indent}\t\tDATA.B $00')
                    out.append(f'{indent}\t\tDATA.W {value}{cmt}')
                    stats['slot'] += 1
                else:
                    out.append(line + '  ; WARNING: LIT data not converted')
                i += 1
                continue

            elif word in ('BRAN', 'ZBRAN', 'LOOP', 'PLOOP'):
                # DATA.W (offset) → DATA.B $00 + DATA.W (offset)
                m = re.match(r'^(\s*)((?:\.\w+\s+|\w+:?\s+)?)(DATA\.W\s+)(.+?)(\s*;.*)?$',
                             line, re.IGNORECASE)
                if m:
                    indent = m.group(1)
                    lbl_part = m.group(2).rstrip()
                    offset_expr = m.group(4).strip()
                    cmt = m.group(5) or ''
                    if lbl_part:
                        out.append(f'{indent}{lbl_part}\tDATA.B $00')
                    else:
                        out.append(f'{indent}\t\tDATA.B $00')
                    out.append(f'{indent}\t\tDATA.W {offset_expr}{cmt}')
                    stats['slot'] += 1
                else:
                    out.append(line + '  ; WARNING: branch data not converted')
                i += 1
                continue

        # ════════════════════════════════════════════════════════════
        # 2. Special words: handle individually
        # ════════════════════════════════════════════════════════════

        # ── PUT_: add TIP after last STA (used to fall through to NEXT) ──
        if label == 'PUT_':
            out.append(f'PUT_: \t\t{code_s}\t{comment}')
            i += 1
            # Copy PLA and STA stack,Y lines, then add TIP
            while i < len(lines):
                ll = lines[i]
                cs = strip_comment(ll)[0].strip()
                out.append(ll)
                i += 1
                if cs.startswith('STA stack,Y'):
                    out.append('\t\tTIP')
                    break
            continue

        # ── NEXT routine: comment out ──
        if label == 'NEXT' and 'BIT INTFLAG' in code_s:
            out.append(';; -- NEXT routine removed (JTC uses JPI/TIP) --')
            out.append(';; Interrupt check moved to SEMIS')
            i += 1
            # Skip NEXT, NOINT, HANDLEINT lines
            while i < len(lines):
                ll = lines[i]
                lab, _ = get_label(ll)
                if lab == 'CLIT' or (lab and lab not in ('NOINT','HANDLEINT','NEXT')
                                     and not ll.startswith('\t') and not ll.startswith(' ')
                                     and not ll.startswith(';')):
                    break
                # Comment out old lines
                if ll.strip() and not ll.startswith(';;'):
                    out.append(';; ' + ll)
                else:
                    out.append(ll)
                i += 1
            continue

        # ── SEMIS: rewrite with DV + interrupt check ──
        if label == 'SEMIS' and label in FORTH_WORDS:
            out.append(';;')
            out.append(';;    ;S (SEMIS) -- exit colon definition')
            out.append(';;    JTC: PLI + TIP with cooperative interrupt check')
            out.append(';;')
            out.append('SEMIS:\tDATA.W (SEMIS+2)\t; DV')
            out.append('\t\tBIT INTFLAG\t\t\t; Check interrupt flag')
            out.append('\t\tBMI .handle_int')
            out.append('\t\tPLI \t\t\t\t; restore I from return stack')
            out.append('\t\tTIP \t\t\t\t; return to caller')
            out.append('.handle_int:')
            out.append('\t\tBVS .no_int\t\t\t; interrupts disabled?')
            out.append('\t\tLDA INTVEC')
            out.append('\t\tSTA W')
            out.append('\t\tLDA INTVEC+1')
            out.append('\t\tSTA W+1')
            out.append('\t\tSTI #$40, INTFLAG')
            out.append('\t\tJMP (W)')
            out.append('.no_int\t\tPLI')
            out.append('\t\tTIP')
            stats['dv'] += 1
            i += 1
            # Skip original SEMIS lines (PLI / JMP NEXT)
            while i < len(lines):
                ll = lines[i]
                c = strip_comment(ll)[0].strip()
                if c in ('PLI', 'JMP NEXT') or 'restore I register' in ll:
                    i += 1
                else:
                    break
            continue

        # ── LIT: DV + INI + existing code ──
        if label == 'LIT' and 'LAN' in code_s:
            out.append('LIT:\tDATA.W (LIT+2)\t\t; DV')
            out.append('\t\tINI \t\t\t\t; skip data slot filler byte')
            # Emit original LIT code (LAN / PHA / LAN / L31 NOP / BRA PUSH)
            out.append(line.replace('LIT:', '\t\t').replace('LIT:\t', '\t\t'))
            stats['dv'] += 1
            i += 1
            continue

        # ── CLIT: DV + INI + code + INI for padding ──
        if label == 'CLIT' and 'LAN' in code_s:
            out.append('CLIT:\tDATA.W (CLIT+2)\t\t; DV')
            out.append('\t\tINI \t\t\t\t; skip data slot filler byte')
            out.append('\t\tLAN \t\t\t\t; byte from (I), I+1')
            i += 1
            # Next line should be PHA
            if i < len(lines) and 'PHA' in lines[i]:
                out.append(lines[i])
                i += 1
            out.append('\t\tINI \t\t\t\t; skip data slot padding byte')
            # Next should be LDA #0
            if i < len(lines) and 'LDA #0' in lines[i]:
                out.append(lines[i])
                i += 1
            # Next should be BRA L31
            if i < len(lines):
                out.append(lines[i])
                i += 1
            stats['dv'] += 1
            continue

        # ── BRAN: DV + INI before PHI ──
        if label == 'BRAN' and 'PHI' in code_s:
            out.append('BRAN:\tDATA.W (BRAN+2)\t\t; DV')
            out.append('\t\tINI \t\t\t\t; skip data slot filler byte')
            # Emit original PHI line
            out.append(line.replace('BRAN:', '\t\t').replace('BRAN:\t\t', '\t\t'))
            stats['dv'] += 1
            i += 1
            continue

        # ── ZBRAN: DV only (no INI — filler handled by BRAN or BUMP) ──
        if label == 'ZBRAN' and 'INY' in code_s:
            out.append('ZBRAN:\tDATA.W (ZBRAN+2)\t; DV')
            # No INI here! BRAN's INI handles filler for branch case,
            # BUMP's 3x INI handles filler for no-branch case
            out.append(f'\t\t{code_s}\t{comment}')
            stats['dv'] += 1
            i += 1
            continue

        # ── BUMP: INI INI → INI INI INI (3-byte data slot) ──
        if label == 'BUMP' and 'INI' in code_s:
            out.append('BUMP   \t\tINI \t\t\t\t; skip filler byte')
            i += 1
            # Next should be INI
            if i < len(lines) and 'INI' in strip_comment(lines[i])[0].strip():
                out.append(lines[i].replace(';', '; skip offset lo ;'))
                out.append('\t\t\tINI \t\t\t\t; skip offset hi (3-byte data slot)')
                i += 1
            continue

        # ── BANKPOP: JMP SEMIS → DV + PLI + TIP ──
        if label == 'BANKPOP' and 'JMP SEMIS' in code_s:
            out.append('BANKPOP:\tDATA.W (BANKPOP+2)\t; DV')
            out.append('\t\tPLI')
            out.append('\t\tTIP')
            stats['dv'] += 1
            i += 1
            continue

        # ── unkn2: already has DV, skip ──
        if label == 'unkn2' and 'DATA.W unkn2+2' in code_s:
            out.append(line)
            i += 1
            continue

        # ── unkn6 + surrounding code: leave unchanged with warning ──
        if label == 'unkn6':
            out.append(line + '\t; WARNING: JTC indirect semantics differ from DTC')
            i += 1
            continue

        # ── DSKBOOT: bare thread, convert entries ──
        if label == 'DSKBOOT':
            # DSKBOOT: DATA.W CR → DSKBOOT: JPI CR
            m = re.match(r'DATA\.W\s+(\w+)', code_s)
            if m:
                word = m.group(1)
                out.append(f'DSKBOOT:\tJPI ({word})')
                in_thread = True
                if word in INLINE_DATA_WORDS:
                    after_inline = word
                stats['jpi'] += 1
                i += 1
                continue

        # ── L2149: needs DV, has JMP SELECT that needs +2 ──
        if label == 'L2149' and 'LDA' in code_s:
            out.append(f'L2149:\tDATA.W (L2149+2)\t; DV')
            out.append(f'\t\t{code_s}\t{comment}')
            stats['dv'] += 1
            i += 1
            continue

        # ════════════════════════════════════════════════════════════
        # 3. DV insertion for other Forth words
        # ════════════════════════════════════════════════════════════
        if label and label in FORTH_WORDS:
            # Check if this is a colon word (JSR DOCOL on this line)
            if 'JSR DOCOL' in code_s:
                out.append(f'{label}:\tDATA.W ({label}+2)')
                out.append('\t\tPHI')
                in_thread = True
                stats['dv'] += 1
                stats['phi'] += 1
                i += 1
                continue
            # Check for JSR DOCON / DOVAR / DOUSE
            elif re.match(r'JSR\s+DO(CON|VAR|USE)', code_s):
                out.append(f'{label}:\tDATA.W ({label}+2)')
                out.append(f'\t\t{code_s}\t{comment}')
                stats['dv'] += 1
                i += 1
                continue
            # Primitive: DV + code
            else:
                out.append(f'{label}:\tDATA.W ({label}+2)')
                if code_s:
                    out.append(f'\t\t{code_s}\t{comment}')
                stats['dv'] += 1
                i += 1
                continue

        # ════════════════════════════════════════════════════════════
        # 4. Convert thread entries: DATA.W WORD → JPI WORD
        # ════════════════════════════════════════════════════════════
        if in_thread:
            # Use full line text for matching (handles bare labels like L1170)
            full_code = strip_comment(line)[0].strip()

            word = extract_data_w_word(full_code)
            if word:
                # Extract any label prefix before DATA.W
                m_dw = re.search(r'DATA\.W\s+\w+\s*$', full_code)
                prefix = full_code[:m_dw.start()].rstrip() if m_dw else ''

                if prefix:
                    out.append(f'{prefix}\tJPI ({word})')
                else:
                    indent = re.match(r'^(\s*)', line).group(1)
                    out.append(f'{indent}JPI ({word})')

                # Don't exit thread mode at SEMIS - words can have
                # multiple branches each ending with SEMIS
                if word in INLINE_DATA_WORDS:
                    after_inline = word
                stats['jpi'] += 1
                i += 1
                continue

        # ════════════════════════════════════════════════════════════
        # 5. Convert JMP NEXT → TIP
        # ════════════════════════════════════════════════════════════
        if re.search(r'\bJMP\s+NEXT\b', line) and not line.lstrip().startswith(';'):
            new_line = re.sub(r'JMP\s+NEXT', 'TIP', line)
            out.append(new_line)
            stats['tip'] += 1
            i += 1
            continue

        # ════════════════════════════════════════════════════════════
        # 6. Fix JMP SELECT → JMP SELECT+2 (skip DV)
        # ════════════════════════════════════════════════════════════
        if re.search(r'\bJMP\s+SELECT\b', line) and 'SELECT+' not in line:
            out.append(line.replace('JMP SELECT', 'JMP SELECT+2'))
            i += 1
            continue

        # ════════════════════════════════════════════════════════════
        # 7. Fix branch targets to BRAN: BEQ/BPL/BVS BRAN → BRAN+2
        # ════════════════════════════════════════════════════════════
        if re.search(r'\b(BEQ|BPL|BVS)\s+BRAN\b', line) and 'BRAN+' not in line:
            new_line = re.sub(r'\b(BEQ|BPL|BVS)\s+BRAN\b', r'\1 BRAN+2', line)
            out.append(new_line)
            i += 1
            continue

        # ════════════════════════════════════════════════════════════
        # 8. Update header comments
        # ════════════════════════════════════════════════════════════
        if 'Direct-threaded code (DTC)' in line:
            out.append(line.replace('Direct-threaded code (DTC)',
                                   'JPI-threaded code (JTC)'))
            i += 1
            continue
        if 'NXT opcode implements direct-threaded NEXT' in line:
            out.append(line.replace('NXT opcode implements direct-threaded NEXT',
                                   'JPI dispatches words, TIP returns'))
            i += 1
            continue
        if 'Colon defs use JSR DOCOL, constants use JSR DOCON, etc.' in line:
            out.append(line.replace(
                'Colon defs use JSR DOCOL, constants use JSR DOCON, etc.',
                'Colon defs use DV+PHI, constants use DV+JSR DOCON, etc.'))
            i += 1
            continue

        # ════════════════════════════════════════════════════════════
        # 9. Default: pass through unchanged
        # ════════════════════════════════════════════════════════════
        out.append(line)
        i += 1

    return out, stats


# ── Post-processing: add JPI unkn2 after JPI SEEK in DSKBOOT ──────

def post_process(lines):
    """Fix up things that are easier to do in a second pass."""
    out = []
    for i, line in enumerate(lines):
        out.append(line)
        # After JPI SEEK in DSKBOOT thread, add JPI unkn2
        if 'JPI (SEEK)' in line and i > 0:
            # Check context: are we in DSKBOOT? Look for nearby DSKBOOT
            for j in range(max(0, i-10), i):
                if 'DSKBOOT' in lines[j]:
                    out.append('\t\tJPI (unkn2)\t\t\t; continue to ROM loader')
                    break

    # Fix PUT_ ending: ensure it ends with TIP (not falling through to removed NEXT)
    out2 = []
    i = 0
    while i < len(out):
        line = out[i]
        out2.append(line)

        # After PUT_'s last STA, ensure TIP follows
        if 'PUT_:' in line or (i > 0 and 'PUT_' in out[i-1] if i > 0 else False):
            pass  # handled in main convert

        i += 1

    return out


# ── Verification ─────────────────────────────────────────────────────

def verify(lines):
    """Check for common issues."""
    issues = []
    for i, line in enumerate(lines):
        # Check for unconverted DATA.W in thread bodies
        # (hard to detect without state, skip for now)

        # Check for JMP NEXT (should all be TIP)
        if re.search(r'\bJMP\s+NEXT\b', line) and not line.lstrip().startswith(';'):
            issues.append(f"Line {i+1}: Unconverted JMP NEXT: {line.rstrip()}")

        # Check for unconverted JSR DOCOL
        if 'JSR DOCOL' in line and not line.lstrip().startswith(';'):
            issues.append(f"Line {i+1}: Unconverted JSR DOCOL: {line.rstrip()}")

        # Check for JMP to Forth word without +2
        for word in ('SELECT', 'SEMIS', 'BRAN'):
            if re.search(rf'\bJMP\s+{word}\b', line) and f'{word}+' not in line:
                if not line.lstrip().startswith(';'):
                    issues.append(f"Line {i+1}: JMP {word} without +2: {line.rstrip()}")

        # Check for JPI without parentheses (assembler requires AbsoluteIndirect)
        if re.search(r'\bJPI\s+[A-Za-z]', line) and '(' not in line:
            if not line.lstrip().startswith(';'):
                issues.append(f"Line {i+1}: JPI without parens: {line.rstrip()}")

    return issues


# ── Main ─────────────────────────────────────────────────────────────

def main():
    infile = 'src/ForthKernel-L28.asm'
    outfile = 'src/ForthKernel-L28.asm'

    with open(infile, 'rb') as f:
        content = f.read().decode('latin-1')
    lines = content.split('\n')

    print(f"Read {len(lines)} lines from {infile}")

    # Convert
    result, stats = convert(lines)
    print(f"Pass 1: {len(result)} lines")
    print(f"  DVs inserted: {stats['dv']}")
    print(f"  JSR DOCOL → PHI: {stats['phi']}")
    print(f"  DATA.W → JPI: {stats['jpi']}")
    print(f"  JMP NEXT → TIP: {stats['tip']}")
    print(f"  Inline data slots: {stats['slot']}")

    # Post-process
    result = post_process(result)
    print(f"Pass 2: {len(result)} lines")

    # Verify
    issues = verify(result)
    if issues:
        print(f"\nVerification found {len(issues)} issues:")
        for issue in issues:
            print(f"  {issue}")
    else:
        print("\nVerification passed — no issues found")

    # Write output
    with open(outfile, 'wb') as f:
        f.write('\n'.join(result).encode('latin-1'))

    print(f"\nWrote {len(result)} lines to {outfile}")

if __name__ == '__main__':
    main()
