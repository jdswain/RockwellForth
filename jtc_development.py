#!/usr/bin/env python3
"""
JTC (JPI-Threaded Code) conversion for ForthDevelopment-L28.asm

Converts from DTC to JTC:
- PFAPTR values: WORD+3 → WORD
- JSR DOCOL → DV (DATA.W (LABEL+2)) + PHI for colon words
- JSR DOCON/DOUSE/DOES → DV + JSR DOxxx for non-colon words
- DATA.W WORD → JPI (WORD) in thread bodies
- Inline data → 3-byte data slots with filler byte
- JMP to Forth words with DVs → +2
- Semantic changes: CFA, CREATE, DCSTOR, COLON, COMPILE, INTERPRET,
  LITERAL, PSEMICODE, DOESGT, HWORD
"""

import re
import sys

# ── All Forth words (kernel + dev ROM) that have DVs ──────────────────

# Kernel words (already converted, have DVs)
KERNEL_WORDS = {
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
    'ZERO', 'ONE', 'TWO', 'THREE', 'FOUR', 'BL',
    'TIB', 'SZ', 'RZ', 'UCL', 'UPAD', 'URW', 'BASE',
    'CLDWRM', 'IN', 'DPL', 'HLD',
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

# Dev ROM words that will get DVs
DEV_WORDS = set()  # Built dynamically during scan

# Words that consume inline data from thread
INLINE_DATA_WORDS = {'LIT', 'CLIT', 'BRAN', 'ZBRAN', 'LOOP', 'PLOOP', 'PDOTQ'}

# Internal routines that do NOT get DVs (not dispatched via JPI)
INTERNAL_ROUTINES = {
    'PUSH', 'PUT_', 'POP', 'POPTWO', 'BINARY', 'PUSH0A', 'SETUP',
    'DOCOL', 'DOCON', 'DOUSE', 'DOVAR', 'DOES',
    'CODE1', 'CODE2', 'L3906', 'L3922',
}

# Kernel Forth words that now have DVs and need +2 for JMP targets
FORTH_WORDS_WITH_DV = set()  # Union of KERNEL_WORDS + DEV_WORDS, built later


# ── Helpers ──────────────────────────────────────────────────────────

def get_label(line):
    """Extract label name from line start. Returns (label, rest_of_line)."""
    m = re.match(r'^(\w+):\s*(.*)', line)
    if m:
        return m.group(1), m.group(2)
    m = re.match(r'^(\.\w+)\s*(.*)', line)
    if m:
        return m.group(1), m.group(2)
    # Bare labels at column 0
    m = re.match(r'^([A-Za-z_]\w*)\s{2,}(.*)', line)
    if m:
        word = m.group(1).upper()
        if word not in {'DATA', 'FILL', 'ORG', 'ALIGN', 'MESSAGE',
                        'CPU', 'MACHINE', 'ENTRY', 'INCLUDE', 'SECTION',
                        'TEXT', 'TYA', 'PHA', 'PLA', 'PLI', 'PHI',
                        'LDA', 'LDX', 'LDY', 'STA', 'STX', 'STY',
                        'INY', 'DEY', 'INX', 'DEX', 'TSX',
                        'CLC', 'SEC', 'BIT', 'BEQ', 'BNE', 'BCC', 'BCS',
                        'BMI', 'BPL', 'BVS', 'BVC', 'BRA', 'JMP', 'JSR',
                        'RTS', 'AND', 'ORA', 'EOR', 'ADC', 'SBC', 'CMP',
                        'LSR', 'ASR', 'ASL', 'ROR', 'ROL', 'ADD', 'NOP',
                        'TIP', 'INI', 'LAN', 'STI', 'JPI'}:
            return m.group(1), m.group(2)
    return None, line


def strip_comment(text):
    """Split into (code, comment)."""
    in_quote = False
    for i, ch in enumerate(text):
        if ch == '"':
            in_quote = not in_quote
        elif ch == ';' and not in_quote:
            return text[:i].rstrip(), text[i:]
    return text, ''


def extract_data_w_word(code):
    """If code contains 'DATA.W WORDNAME' (single word ref), return WORDNAME."""
    m = re.search(r'DATA\.W\s+(\w+)\s*$', code.strip(), re.IGNORECASE)
    if m:
        word = m.group(1)
        if word in FORTH_WORDS_WITH_DV:
            return word
    return None


# ── Phase 1: Scan for all dev ROM word labels ────────────────────────

def scan_dev_words(lines):
    """Find all Forth word labels defined in dev ROM."""
    words = set()
    for i, line in enumerate(lines):
        label, rest = get_label(line)
        if not label:
            continue
        code = strip_comment(rest)[0].strip()
        # Colon words
        if code == 'JSR DOCOL':
            words.add(label)
        # Constants
        elif code == 'JSR DOCON':
            words.add(label)
        # User variables
        elif code == 'JSR DOUSE':
            words.add(label)
        # DOES-based words
        elif code == 'JSR DOES':
            words.add(label)
        # Primitives with TYA/PHA/LDA etc (FMTRK, FIP, etc.)
        # Check if they have headers (text.7 before them)
        elif label in ('FMTRK', 'FIP', 'FW', 'FN', 'FUP'):
            words.add(label)
        # I word (JMP R)
        elif label == 'I' and 'JMP R' in code:
            words.add(label)
        # LFA (JMP TWOMINUS)
        elif label == 'LFA' and 'JMP TWOMINUS' in code:
            words.add(label)
    return words


# ── Phase 2: Main conversion ─────────────────────────────────────────

def convert(input_lines):
    lines = list(input_lines)
    out = []
    i = 0
    in_thread = False
    after_inline = None
    current_word = None  # Track which word we're inside
    stats = {'dv': 0, 'phi': 0, 'jpi': 0, 'pfaptr': 0, 'slot': 0}

    while i < len(lines):
        line = lines[i]
        label, rest = get_label(line)
        code, comment = strip_comment(rest if label else line)
        code_s = code.strip()

        # ════════════════════════════════════════════════════════════
        # 0. Pass through: kernel include, section directives, etc.
        # ════════════════════════════════════════════════════════════
        if code_s.startswith('Include') or code_s.startswith('section') or \
           code_s.startswith('org') or code_s.startswith('message') or \
           code_s.startswith('entry') or code_s.startswith('FILL'):
            out.append(line)
            i += 1
            continue

        # Header lines (text.7, link data.w _WORD) — pass through
        if 'text.7' in code_s.lower() or re.match(r'^text\.7\b', code_s, re.IGNORECASE):
            out.append(line)
            i += 1
            continue

        # Link fields: data.w _WORD (underscore prefix = NFA reference)
        if re.search(r'data\.w\s+_\w+', code_s, re.IGNORECASE) and 'link' in comment.lower():
            out.append(line)
            i += 1
            continue

        # ════════════════════════════════════════════════════════════
        # 1. PFAPTR fields: WORD+3 → WORD
        # ════════════════════════════════════════════════════════════
        if 'PFAPTR' in comment and re.search(r'data\.w\s+\w+\+3', code_s, re.IGNORECASE):
            # Change WORD+3 to WORD
            new_line = re.sub(r'(data\.w\s+)(\w+)\+3', r'\1\2', line, flags=re.IGNORECASE)
            out.append(new_line)
            stats['pfaptr'] += 1
            i += 1
            continue

        # Special PFAPTR: _DIGIT (= I+3, used as PFAPTR for I word)
        if label is None and 'PFAPTR' in comment and '_DIGIT' in code_s:
            new_line = line.replace('_DIGIT', 'I')
            out.append(new_line)
            stats['pfaptr'] += 1
            i += 1
            continue

        # Special PFAPTR: _CFA (= LFA+3, used as PFAPTR for LFA word)
        if label is None and 'PFAPTR' in comment and '_CFA' in code_s:
            new_line = line.replace('_CFA', 'LFA')
            out.append(new_line)
            stats['pfaptr'] += 1
            i += 1
            continue

        # ════════════════════════════════════════════════════════════
        # 2. Handle inline data from previous JPI
        # ════════════════════════════════════════════════════════════
        if after_inline:
            word = after_inline
            after_inline = None

            if word == 'PDOTQ':
                out.append(line)
                i += 1
                continue

            elif word == 'CLIT':
                # DATA.B byte → DATA.B $00, byte, $00
                m = re.match(r'^(\s*(?:\.\w+\s+|\w+:?\s+)?)(data\.b\s+)(.+?)(\s*;.*)?$',
                             line, re.IGNORECASE)
                if m:
                    prefix = m.group(1)
                    byte_val = m.group(3).strip()
                    cmt = m.group(4) or ''
                    out.append(f'{prefix}data.b $00, {byte_val}, $00{cmt}')
                    stats['slot'] += 1
                else:
                    out.append(line + '  ; WARNING: CLIT data not converted')
                i += 1
                continue

            elif word == 'LIT':
                # DATA.W value → DATA.B $00 + DATA.W value
                m = re.match(r'^(\s*)((?:\.\w+\s+|\w+:?\s+)?)(data\.w\s+)(.+?)(\s*;.*)?$',
                             line, re.IGNORECASE)
                if m:
                    indent = m.group(1)
                    lbl_part = m.group(2).rstrip()
                    value = m.group(4).strip()
                    cmt = m.group(5) or ''
                    if lbl_part:
                        out.append(f'{indent}{lbl_part}\tdata.b $00')
                    else:
                        out.append(f'{indent}\t\t\tdata.b $00')
                    out.append(f'{indent}\t\t\tdata.w {value}{cmt}')
                    stats['slot'] += 1
                else:
                    out.append(line + '  ; WARNING: LIT data not converted')
                i += 1
                continue

            elif word in ('BRAN', 'ZBRAN', 'LOOP', 'PLOOP'):
                m = re.match(r'^(\s*)((?:\.\w+\s+|\w+:?\s+)?)(data\.w\s+)(.+?)(\s*;.*)?$',
                             line, re.IGNORECASE)
                if m:
                    indent = m.group(1)
                    lbl_part = m.group(2).rstrip()
                    offset_expr = m.group(4).strip()
                    cmt = m.group(5) or ''
                    if lbl_part:
                        out.append(f'{indent}{lbl_part}\tdata.b $00')
                    else:
                        out.append(f'{indent}\t\t\tdata.b $00')
                    out.append(f'{indent}\t\t\tdata.w {offset_expr}{cmt}')
                    stats['slot'] += 1
                else:
                    out.append(line + '  ; WARNING: branch data not converted')
                i += 1
                continue

        # ════════════════════════════════════════════════════════════
        # 2b. Bare JSR DOCOL (no label) → PHI
        # ════════════════════════════════════════════════════════════
        if label is None and code_s == 'JSR DOCOL':
            indent = re.match(r'^(\s*)', line).group(1)
            # Check if next line has KSTART label
            if i+1 < len(lines):
                next_label, _ = get_label(lines[i+1])
                if next_label == 'KSTART':
                    # Move KSTART label to the PHI line
                    out.append(f'KSTART:\t\t\tPHI')
                    stats['phi'] += 1
                    i += 1
                    # Skip the next line's label and convert its DATA.W
                    i += 1  # skip the KSTART: data.w LIT line
                    # Now we're in thread mode, process from the data.w LIT
                    # Actually, output the JPI for LIT
                    out.append('\t\t\tJPI (LIT)')
                    stats['jpi'] += 1
                    after_inline = 'LIT'
                    in_thread = True
                    continue

            # Other bare JSR DOCOL (e.g., in FORGET)
            out.append(f'{indent}\t\t\tPHI')
            stats['phi'] += 1
            in_thread = True
            i += 1
            continue

        # ════════════════════════════════════════════════════════════
        # 3. Special word: CFA — semantic change
        # ════════════════════════════════════════════════════════════
        if label == 'CFA' and 'JSR DOCOL' in code_s:
            out.append(f'CFA:\tDATA.W (CFA+2)')
            out.append('\t\t\tPHI')
            out.append('\t\t\tJPI (AT)')
            out.append('\t\t\tJPI (SEMIS)')
            stats['dv'] += 1
            stats['phi'] += 1
            stats['jpi'] += 2
            i += 1
            # Skip old thread body (AT LIT $0003 SUB SEMIS)
            while i < len(lines):
                cs = strip_comment(lines[i])[0].strip().lower()
                if 'data.w semis' in cs.lower() or 'data.w SEMIS' in lines[i]:
                    i += 1
                    break
                i += 1
            in_thread = False
            current_word = 'CFA'
            continue

        # ════════════════════════════════════════════════════════════
        # 4. Special word: DCSTOR — write DV + JSR at CFA
        # ════════════════════════════════════════════════════════════
        if label == 'DCSTOR' and 'JSR DOCOL' in code_s:
            out.append(f'DCSTOR:\tDATA.W (DCSTOR+2)')
            out.append('\t\t\tPHI')
            # Get CFA (= DV address) of latest word
            out.append('\t\t\tJPI (LATEST)')
            out.append('\t\t\tJPI (PFAPTR)')
            out.append('\t\t\tJPI (CFA)')
            # Write DV self-pointer: CFA+2 at CFA
            out.append('\t\t\tJPI (DUP)')       # ( handler cfa cfa )
            out.append('\t\t\tJPI (TWOPLUS)')   # ( handler cfa cfa+2 )
            out.append('\t\t\tJPI (OVER)')      # ( handler cfa cfa+2 cfa )
            out.append('\t\t\tJPI (STORE)')     # ( handler cfa ) write DV
            # Write JSR opcode at CFA+2
            out.append('\t\t\tJPI (TWOPLUS)')   # ( handler cfa+2 )
            out.append('\t\t\tJPI (DUP)')       # ( handler cfa+2 cfa+2 )
            out.append('\t\t\tJPI (LIT)')
            out.append('\t\t\tdata.b $00')
            out.append('\t\t\tdata.w $0020')    # JSR opcode
            out.append('\t\t\tJPI (SWAP)')      # ( handler $20 cfa+2 )
            out.append('\t\t\tJPI (CSTOR)')     # write $20 at cfa+2
            # Write handler address at CFA+3
            out.append('\t\t\tJPI (ONEPLUS)')   # ( handler cfa+3 )
            out.append('\t\t\tJPI (STORE)')     # write handler
            # Pop caller's return
            out.append('\t\t\tJPI (RFROM)')
            out.append('\t\t\tJPI (DROP)')
            out.append('\t\t\tJPI (SEMIS)')
            stats['dv'] += 1
            stats['phi'] += 1
            i += 1
            # Skip old DCSTOR body
            while i < len(lines):
                if 'data.w SEMIS' in lines[i] or 'data.w semis' in lines[i].lower():
                    i += 1
                    break
                i += 1
            in_thread = False
            continue

        # ════════════════════════════════════════════════════════════
        # 5. Special word: COLON — write DV + PHI directly
        # ════════════════════════════════════════════════════════════
        if label == 'COLON' and 'JSR DOCOL' in code_s:
            out.append(f'COLON:\tDATA.W (COLON+2)')
            out.append('\t\t\tPHI')
            out.append('\t\t\tJPI (QEXEC)')
            out.append('\t\t\tJPI (STORCSP)')
            out.append('\t\t\tJPI (CURRENT)')
            out.append('\t\t\tJPI (AT)')
            out.append('\t\t\tJPI (CONTEXT)')
            out.append('\t\t\tJPI (STORE)')
            out.append('\t\t\tJPI (CREATE)')
            out.append('\t\t\tJPI (RBRAC)')
            # Write DV self-pointer: HERE 2+ ,
            out.append('\t\t\tJPI (HERE)')
            out.append('\t\t\tJPI (TWOPLUS)')
            out.append('\t\t\tJPI (COMMA)')
            # Write PHI opcode
            out.append('\t\t\tJPI (LIT)')
            out.append('\t\t\tdata.b $00')
            out.append('\t\t\tdata.w $00cb')    # PHI opcode = $cb
            out.append('\t\t\tJPI (CCOMMA)')
            # Pop COLON's caller
            out.append('\t\t\tJPI (RFROM)')
            out.append('\t\t\tJPI (DROP)')
            out.append('\t\t\tJPI (SEMIS)')
            stats['dv'] += 1
            stats['phi'] += 1
            i += 1
            # Skip old COLON body
            while i < len(lines):
                if 'data.w DCSTOR' in lines[i] or 'data.w dcstor' in lines[i].lower():
                    i += 1
                    break
                i += 1
            in_thread = False
            continue

        # ════════════════════════════════════════════════════════════
        # 6. Special word: CREATE — adjust PFA/PFAPTR computation
        # ════════════════════════════════════════════════════════════
        if label == 'CREATE' and 'JSR DOCOL' in code_s:
            out.append(f'CREATE:\tDATA.W (CREATE+2)')
            out.append('\t\t\tPHI')
            in_thread = True
            current_word = 'CREATE'
            stats['dv'] += 1
            stats['phi'] += 1
            i += 1
            # Process CREATE body with specific changes
            while i < len(lines):
                ll = lines[i]
                cs = strip_comment(ll)[0].strip()

                # Handle inline data
                if after_inline:
                    word = after_inline
                    after_inline = None
                    if word == 'CLIT':
                        m = re.match(r'^(\s*)(data\.b\s+)(.+?)(\s*;.*)?$', ll, re.IGNORECASE)
                        if m:
                            out.append(f'{m.group(1)}data.b $00, {m.group(3).strip()}, $00{m.group(4) or ""}')
                            stats['slot'] += 1
                        else:
                            out.append(ll)
                        i += 1
                        continue
                    elif word == 'LIT':
                        m = re.match(r'^(\s*)((?:\w+:?\s+)?)(data\.w\s+)(.+?)(\s*;.*)?$', ll, re.IGNORECASE)
                        if m:
                            indent = m.group(1)
                            lbl = m.group(2).rstrip()
                            val = m.group(4).strip()
                            cmt = m.group(5) or ''
                            # Change $0003 to $0002 (DV is 2 bytes, not CFA 3 bytes)
                            if val == '$0003':
                                val = '$0002'
                            if lbl:
                                out.append(f'{indent}{lbl}\tdata.b $00')
                            else:
                                out.append(f'{indent}\t\t\tdata.b $00')
                            out.append(f'{indent}\t\t\tdata.w {val}{cmt}')
                            stats['slot'] += 1
                        else:
                            out.append(ll)
                        i += 1
                        continue
                    elif word in ('BRAN', 'ZBRAN', 'LOOP', 'PLOOP'):
                        m = re.match(r'^(\s*)((?:\.\w+\s+|\w+:?\s+)?)(data\.w\s+)(.+?)(\s*;.*)?$', ll, re.IGNORECASE)
                        if m:
                            indent = m.group(1)
                            lbl = m.group(2).rstrip()
                            val = m.group(4).strip()
                            cmt = m.group(5) or ''
                            if lbl:
                                out.append(f'{indent}{lbl}\tdata.b $00')
                            else:
                                out.append(f'{indent}\t\t\tdata.b $00')
                            out.append(f'{indent}\t\t\tdata.w {val}{cmt}')
                            stats['slot'] += 1
                        else:
                            out.append(ll)
                        i += 1
                        continue
                    elif word == 'PDOTQ':
                        out.append(ll)
                        i += 1
                        continue

                # End of CREATE: replace DUP CCOMMA COMMA with HERE 2+ COMMA
                # Old: DUP COMMADIV DUP CCOMMA COMMA SEMIS
                # New: DUP COMMADIV HERE TWOPLUS COMMA SEMIS
                # The DUP COMMADIV writes PFAPTR value
                # In JTC, PFAPTR = CFA = DV address = HERE (at time of COMMADIV)
                # Then allocate DV: HERE 2+ , (writes self-pointer)
                if re.search(r'data\.w\s+DUP\s*$', cs, re.IGNORECASE) and \
                   i+1 < len(lines) and 'CCOMMA' in lines[i+1]:
                    # This is the DUP before CCOMMA COMMA — replace
                    # Old: DUP / CCOMMA / COMMA / SEMIS
                    # New: HERE / TWOPLUS / COMMA / SEMIS
                    indent = re.match(r'^(\s*)', ll).group(1)
                    out.append(f'{indent}\t\t\tJPI (HERE)')
                    out.append(f'{indent}\t\t\tJPI (TWOPLUS)')
                    stats['jpi'] += 2
                    i += 1  # skip DUP
                    i += 1  # skip CCOMMA
                    # COMMA and SEMIS will be converted normally
                    continue

                # Convert thread entries
                word_ref = extract_data_w_word(cs)
                if word_ref:
                    m_dw = re.search(r'data\.w\s+\w+\s*$', cs, re.IGNORECASE)
                    prefix = cs[:m_dw.start()].rstrip() if m_dw else ''
                    indent = re.match(r'^(\s*)', ll).group(1)
                    if prefix:
                        out.append(f'{indent}{prefix}\tJPI ({word_ref})')
                    else:
                        out.append(f'{indent}\t\t\tJPI ({word_ref})')
                    if word_ref in INLINE_DATA_WORDS:
                        after_inline = word_ref
                    stats['jpi'] += 1
                    i += 1
                    if 'data.w SEMIS' in ll or 'data.w semis' in ll.lower():
                        pass  # don't exit thread at SEMIS
                    continue

                # Exit at next header
                if 'text.7' in ll.lower():
                    out.append(ll)
                    i += 1
                    in_thread = False
                    current_word = None
                    break

                # Pass through non-thread lines (labels, comments, etc)
                out.append(ll)
                i += 1
                # Exit CREATE processing when we hit the next word definition
                lab2, _ = get_label(ll)
                if lab2 and lab2 != current_word and not lab2.startswith('.') and \
                   not lab2.startswith('L_'):
                    in_thread = False
                    current_word = None
                    break
                continue

            continue

        # ════════════════════════════════════════════════════════════
        # 7. Special word: COMPILE — read/emit 3-byte JPI
        # ════════════════════════════════════════════════════════════
        if label == 'COMPILE' and 'JSR DOCOL' in code_s:
            out.append(f'COMPILE:\tDATA.W (COMPILE+2)')
            out.append('\t\t\tPHI')
            out.append('\t\t\tJPI (QCOMP)')
            out.append('\t\t\tJPI (RFROM)')     # ( -- I ) return addr
            out.append('\t\t\tJPI (DUP)')
            out.append('\t\t\tJPI (LIT)')
            out.append('\t\t\tdata.b $00')
            out.append('\t\t\tdata.w $0003')    # 3 bytes to skip
            out.append('\t\t\tJPI (PLUS)')
            out.append('\t\t\tJPI (GTR)')       # advance return by 3
            # Emit JPI opcode
            out.append('\t\t\tJPI (LIT)')
            out.append('\t\t\tdata.b $00')
            out.append('\t\t\tdata.w $000c')    # JPI opcode $0C
            out.append('\t\t\tJPI (CCOMMA)')    # emit $0C
            # Read and emit operand (skip filler byte, read 2-byte addr)
            out.append('\t\t\tJPI (ONEPLUS)')   # skip filler byte
            out.append('\t\t\tJPI (AT)')        # read 2-byte operand
            out.append('\t\t\tJPI (COMMA)')     # emit operand
            out.append('\t\t\tJPI (SEMIS)')
            stats['dv'] += 1
            stats['phi'] += 1
            i += 1
            # Skip old COMPILE body
            while i < len(lines):
                if 'data.w SEMIS' in lines[i] or 'data.w semis' in lines[i].lower():
                    i += 1
                    break
                i += 1
            in_thread = False
            continue

        # ════════════════════════════════════════════════════════════
        # 8. Special word: LITERAL — emit JPI + 3-byte data slot
        # ════════════════════════════════════════════════════════════
        if label == 'LITERAL' and 'JSR DOCOL' in code_s:
            out.append(f'LITERAL:\tDATA.W (LITERAL+2)')
            out.append('\t\t\tPHI')
            out.append('\t\t\tJPI (STATE)')
            out.append('\t\t\tJPI (AT)')
            out.append('\t\t\tJPI (ZBRAN)')
            out.append('\t\t\tdata.b $00')
            out.append('\t\t\tdata.w (L_LITERAL_1 - addr)')
            # Check if fits in byte (high byte = 0)
            out.append('\t\t\tJPI (DUP)')
            out.append('\t\t\tJPI (LIT)')
            out.append('\t\t\tdata.b $00')
            out.append('\t\t\tdata.w $ff00')
            out.append('\t\t\tJPI (ANDD)')
            out.append('\t\t\tJPI (ZBRAN)')
            out.append('\t\t\tdata.b $00')
            out.append('\t\t\tdata.w (CREATE5 - addr)')
            # Full 16-bit: emit JPI (LIT) + data slot
            out.append('\t\t\tJPI (COMPILE)')
            out.append('\t\t\tJPI (LIT)')       # compile word reads this
            out.append('\t\t\tdata.b $00')      # filler
            # Emit data slot: $00 + value as DATA.B $00 / DATA.W val
            out.append('\t\t\tJPI (LIT)')
            out.append('\t\t\tdata.b $00')
            out.append('\t\t\tdata.w $0000')    # filler byte value
            out.append('\t\t\tJPI (CCOMMA)')    # emit $00 filler
            out.append('\t\t\tJPI (COMMA)')     # emit value (16-bit)
            out.append('\t\t\tJPI (SEMIS)')
            out.append(';;')
            out.append(';;')
            out.append(';;')
            # 8-bit path: emit JPI (CLIT) + data slot
            out.append('CREATE5:\tJPI (COMPILE)')
            out.append('\t\t\tJPI (CLIT)')      # compile word reads this
            out.append('\t\t\tdata.b $00')      # filler
            # Emit 3-byte data slot: $00, value, $00
            out.append('\t\t\tJPI (LIT)')
            out.append('\t\t\tdata.b $00')
            out.append('\t\t\tdata.w $0000')    # filler byte
            out.append('\t\t\tJPI (CCOMMA)')    # emit $00 filler
            out.append('\t\t\tJPI (CCOMMA)')    # emit value byte
            out.append('\t\t\tJPI (LIT)')
            out.append('\t\t\tdata.b $00')
            out.append('\t\t\tdata.w $0000')    # padding byte
            out.append('\t\t\tJPI (CCOMMA)')    # emit $00 padding
            out.append('L_LITERAL_1\t\t\tJPI (SEMIS)')
            stats['dv'] += 1
            stats['phi'] += 1
            i += 1
            # Skip old LITERAL + CREATE5 body through L_LITERAL_1 SEMIS
            while i < len(lines):
                ll = lines[i]
                lab, _ = get_label(ll)
                if lab == 'L_LITERAL_1' or (lab is not None and 'data.w SEMIS' in ll):
                    i += 1
                    if lab == 'L_LITERAL_1':
                        break
                    continue
                i += 1
                # Stop at next text.7 header
                if 'text.7' in ll.lower():
                    break
            in_thread = False
            continue

        # ════════════════════════════════════════════════════════════
        # 8a. Special word: BRACCOMPILE — emit JPI + CFA
        # ════════════════════════════════════════════════════════════
        if label == 'BRACCOMPILE' and 'JSR DOCOL' in code_s:
            out.append(f'BRACCOMPILE:\tDATA.W (BRACCOMPILE+2)')
            out.append('\t\t\tPHI')
            out.append('\t\t\tJPI (SUBFIND)')
            out.append('\t\t\tJPI (ZEQ)')
            out.append('\t\t\tJPI (ZERO)')
            out.append('\t\t\tJPI (QERROR)')
            out.append('\t\t\tJPI (DROP)')
            # Emit JPI opcode + CFA (DV address)
            out.append('\t\t\tJPI (LIT)')
            out.append('\t\t\tdata.b $00')
            out.append('\t\t\tdata.w $000c')    # JPI opcode
            out.append('\t\t\tJPI (CCOMMA)')
            out.append('\t\t\tJPI (CFA)')
            out.append('\t\t\tJPI (COMMA)')
            out.append('\t\t\tJPI (SEMIS)')
            stats['dv'] += 1
            stats['phi'] += 1
            i += 1
            while i < len(lines):
                if 'data.w SEMIS' in lines[i]:
                    i += 1
                    break
                i += 1
            in_thread = False
            continue

        # ════════════════════════════════════════════════════════════
        # 8b. Special word: INTERPRET — emit JPI in compile mode
        # ════════════════════════════════════════════════════════════
        if label == 'INTERPRET' and 'JSR DOCOL' in code_s:
            out.append(f'INTERPRET:\tDATA.W (INTERPRET+2)')
            out.append('\t\t\tPHI')
            # Thread body: SUBFIND ZBRAN ...
            out.append('L_INTERPRET_7\t\t\tJPI (SUBFIND)')
            out.append('\t\t\tJPI (ZBRAN)')
            out.append('\t\t\tdata.b $00')
            out.append('\t\t\tdata.w (L_INTERPRET_1 - addr)')
            # Found word: check STATE
            out.append('\t\t\tJPI (STATE)')
            out.append('\t\t\tJPI (AT)')
            out.append('\t\t\tJPI (LESS)')
            out.append('\t\t\tJPI (ZBRAN)')
            out.append('\t\t\tdata.b $00')
            out.append('\t\t\tdata.w (L_INTERPRET_2 - addr)')
            # Compile mode: emit JPI opcode + CFA (DV address)
            out.append('\t\t\tJPI (LIT)')
            out.append('\t\t\tdata.b $00')
            out.append('\t\t\tdata.w $000c')      # JPI opcode $0C
            out.append('\t\t\tJPI (CCOMMA)')       # emit $0C
            out.append('\t\t\tJPI (CFA)')
            out.append('\t\t\tJPI (COMMA)')        # emit DV address
            out.append('\t\t\tJPI (BRAN)')
            out.append('\t\t\tdata.b $00')
            out.append('\t\t\tdata.w (L_INTERPRET_3 - addr)')
            # Execute mode
            out.append('L_INTERPRET_2\t\t\tJPI (CFA)')
            out.append('\t\t\tJPI (EXECUTE)')
            out.append('L_INTERPRET_3\t\t\tJPI (QSTACK)')
            out.append('\t\t\tJPI (BRAN)')
            out.append('\t\t\tdata.b $00')
            out.append('\t\t\tdata.w (L_INTERPRET_4 - addr)')
            # Number handling
            out.append('L_INTERPRET_1\t\t\tJPI (HERE)')
            out.append('\t\t\tJPI (NUMBER)')
            out.append('\t\t\tJPI (DPL)')
            out.append('\t\t\tJPI (AT)')
            out.append('\t\t\tJPI (ONEPLUS)')
            out.append('\t\t\tJPI (ZBRAN)')
            out.append('\t\t\tdata.b $00')
            out.append('\t\t\tdata.w (L_INTERPRET_5 - addr)')
            out.append('\t\t\tJPI (DLITERAL)')
            out.append('\t\t\tJPI (BRAN)')
            out.append('\t\t\tdata.b $00')
            out.append('\t\t\tdata.w (L_INTERPRET_6 - addr)')
            out.append('L_INTERPRET_5\t\t\tJPI (DROP)')
            out.append('\t\t\tJPI (LITERAL)')
            out.append('L_INTERPRET_6\t\t\tJPI (QSTACK)')
            out.append('L_INTERPRET_4\t\t\tJPI (BRAN)')
            out.append('\t\t\tdata.b $00')
            out.append('\t\t\tdata.w (L_INTERPRET_7 - addr)')
            stats['dv'] += 1
            stats['phi'] += 1
            i += 1
            # Skip old INTERPRET body
            while i < len(lines):
                ll = lines[i]
                lab, _ = get_label(ll)
                if 'text.7' in ll.lower():
                    break
                i += 1
            in_thread = False
            continue

        # ════════════════════════════════════════════════════════════
        # 9. Special word: PSEMICODE — write JMP at DV+2
        # ════════════════════════════════════════════════════════════
        if label == 'PSEMICODE' and 'JSR DOCOL' in code_s:
            out.append(f'PSEMICODE:\tDATA.W (PSEMICODE+2)')
            out.append('\t\t\tPHI')
            out.append('\t\t\tJPI (RFROM)')       # code address from caller
            out.append('\t\t\tJPI (LATEST)')
            out.append('\t\t\tJPI (PFAPTR)')
            out.append('\t\t\tJPI (CFA)')         # DV address
            # Write DV self-pointer
            out.append('\t\t\tJPI (DUP)')         # ( code dv dv )
            out.append('\t\t\tJPI (TWOPLUS)')     # ( code dv dv+2 )
            out.append('\t\t\tJPI (OVER)')        # ( code dv dv+2 dv )
            out.append('\t\t\tJPI (STORE)')       # write DV self-pointer
            # Write JMP at DV+2
            out.append('\t\t\tJPI (TWOPLUS)')     # ( code dv+2 )
            out.append('\t\t\tJPI (DUP)')         # ( code dv+2 dv+2 )
            out.append('\t\t\tJPI (LIT)')
            out.append('\t\t\tdata.b $00')
            out.append('\t\t\tdata.w $004c')      # JMP opcode
            out.append('\t\t\tJPI (SWAP)')
            out.append('\t\t\tJPI (CSTOR)')       # write $4C
            out.append('\t\t\tJPI (ONEPLUS)')     # dv+3
            out.append('\t\t\tJPI (STORE)')       # write code address
            out.append('\t\t\tJPI (SEMIS)')
            stats['dv'] += 1
            stats['phi'] += 1
            i += 1
            while i < len(lines):
                if 'data.w SEMIS' in lines[i]:
                    i += 1
                    break
                i += 1
            in_thread = False
            continue

        # ════════════════════════════════════════════════════════════
        # 10. Special word: HWORD — check byte at DV+2
        # ════════════════════════════════════════════════════════════
        if label == 'HWORD' and 'JSR DOCOL' in code_s:
            out.append(f'HWORD:\tDATA.W (HWORD+2)')
            out.append('\t\t\tPHI')
            in_thread = True
            current_word = 'HWORD'
            stats['dv'] += 1
            stats['phi'] += 1
            i += 1
            # Process HWORD body — need to change primitive detection
            # Old: CFA DUP CAT LIT $0020 EQUAL ZEQ ZBRAN
            # New: CFA TWOPLUS DUP CAT LIT $0020 EQUAL SWAP CAT LIT $00cb EQUAL OR ZEQ ZBRAN
            # Actually simpler: just check if byte at CFA+2 is $20 (JSR) or $cb (PHI)
            # But let's just convert mechanically and fix the one comparison
            while i < len(lines):
                ll = lines[i]
                cs = strip_comment(ll)[0].strip()

                if after_inline:
                    word = after_inline
                    after_inline = None
                    if word == 'CLIT':
                        m = re.match(r'^(\s*)(data\.b\s+)(.+?)(\s*;.*)?$', ll, re.IGNORECASE)
                        if m:
                            out.append(f'{m.group(1)}data.b $00, {m.group(3).strip()}, $00{m.group(4) or ""}')
                            stats['slot'] += 1
                        else:
                            out.append(ll)
                    elif word == 'LIT':
                        m = re.match(r'^(\s*)((?:\w+:?\s+)?)(data\.w\s+)(.+?)(\s*;.*)?$', ll, re.IGNORECASE)
                        if m:
                            indent = m.group(1)
                            lbl = m.group(2).rstrip()
                            val = m.group(4).strip()
                            cmt = m.group(5) or ''
                            if lbl:
                                out.append(f'{indent}{lbl}\tdata.b $00')
                            else:
                                out.append(f'{indent}\t\t\tdata.b $00')
                            out.append(f'{indent}\t\t\tdata.w {val}{cmt}')
                            stats['slot'] += 1
                        else:
                            out.append(ll)
                    elif word in ('BRAN', 'ZBRAN', 'LOOP', 'PLOOP'):
                        m = re.match(r'^(\s*)((?:\.\w+\s+|\w+:?\s+)?)(data\.w\s+)(.+?)(\s*;.*)?$', ll, re.IGNORECASE)
                        if m:
                            indent = m.group(1)
                            lbl = m.group(2).rstrip()
                            val = m.group(4).strip()
                            cmt = m.group(5) or ''
                            if lbl:
                                out.append(f'{indent}{lbl}\tdata.b $00')
                            else:
                                out.append(f'{indent}\t\t\tdata.b $00')
                            out.append(f'{indent}\t\t\tdata.w {val}{cmt}')
                            stats['slot'] += 1
                        else:
                            out.append(ll)
                    elif word == 'PDOTQ':
                        out.append(ll)
                    i += 1
                    continue

                # HWORD primitive detection: after CFA, insert TWOPLUS
                # Old thread: ... CFA DUP CAT LIT $0020 EQUAL ZEQ ...
                # New: CFA gets DV addr. DV+2 = code. Check first byte there.
                # We need: CFA TWOPLUS DUP CAT ... (check byte at DV+2)
                # Insert TWOPLUS after CFA in thread
                if re.search(r'data\.w\s+CFA\s*$', cs, re.IGNORECASE):
                    indent = re.match(r'^(\s*)', ll).group(1)
                    out.append(f'{indent}\t\t\tJPI (CFA)')
                    out.append(f'{indent}\t\t\tJPI (TWOPLUS)')  # DV+2 = code start
                    stats['jpi'] += 2
                    i += 1
                    continue

                # Change $0020 check to check both $20 (JSR) and $cb (PHI)
                # Old: LIT $0020 EQUAL ZEQ ZBRAN
                # New: DUP LIT $0020 EQUAL SWAP LIT $00cb EQUAL OR ZEQ ZBRAN
                # This detects both JSR-based words and colon words (PHI)
                if re.search(r'data\.w\s+LIT\s*$', cs, re.IGNORECASE):
                    # Check if next line is $0020
                    if i+1 < len(lines) and '$0020' in lines[i+1]:
                        indent = re.match(r'^(\s*)', ll).group(1)
                        out.append(f'{indent}\t\t\tJPI (DUP)')
                        out.append(f'{indent}\t\t\tJPI (LIT)')
                        out.append(f'{indent}\t\t\tdata.b $00')
                        out.append(f'{indent}\t\t\tdata.w $0020')
                        out.append(f'{indent}\t\t\tJPI (EQUAL)')
                        out.append(f'{indent}\t\t\tJPI (SWAP)')
                        out.append(f'{indent}\t\t\tJPI (LIT)')
                        out.append(f'{indent}\t\t\tdata.b $00')
                        out.append(f'{indent}\t\t\tdata.w $00cb')  # PHI opcode
                        out.append(f'{indent}\t\t\tJPI (EQUAL)')
                        out.append(f'{indent}\t\t\tJPI (OR)')
                        stats['jpi'] += 7
                        stats['slot'] += 2
                        i += 1  # skip LIT
                        i += 1  # skip $0020
                        # Next should be EQUAL — skip it (already emitted)
                        if i < len(lines) and 'EQUAL' in lines[i]:
                            i += 1
                        continue

                word_ref = extract_data_w_word(cs)
                if word_ref:
                    indent = re.match(r'^(\s*)', ll).group(1)
                    m_dw = re.search(r'data\.w\s+\w+\s*$', cs, re.IGNORECASE)
                    prefix = cs[:m_dw.start()].rstrip() if m_dw else ''
                    if prefix:
                        out.append(f'{indent}{prefix}\tJPI ({word_ref})')
                    else:
                        out.append(f'{indent}\t\t\tJPI ({word_ref})')
                    if word_ref in INLINE_DATA_WORDS:
                        after_inline = word_ref
                    stats['jpi'] += 1
                    i += 1
                    continue

                # Exit HWORD handler at next header or word definition
                if 'text.7' in ll.lower():
                    out.append(ll)
                    i += 1
                    in_thread = False
                    current_word = None
                    break

                out.append(ll)
                i += 1
                lab2, _ = get_label(ll)
                if lab2 and lab2 != 'HWORD' and not lab2.startswith('.') and \
                   not lab2.startswith('L_'):
                    in_thread = False
                    current_word = None
                    break
            continue

        # ════════════════════════════════════════════════════════════
        # 11. Special words: I, LFA — JMP to Forth word needs +2
        # ════════════════════════════════════════════════════════════
        if label == 'I' and 'JMP R' in code_s:
            out.append(f'I:\tDATA.W (I+2)')
            out.append('\t\t\tJMP R+2')
            stats['dv'] += 1
            i += 1
            in_thread = False
            continue

        if label == 'LFA' and 'JMP TWOMINUS' in code_s:
            out.append(f'LFA:\tDATA.W (LFA+2)')
            out.append('\t\t\tJMP TWOMINUS+2')
            stats['dv'] += 1
            i += 1
            in_thread = False
            continue

        # ════════════════════════════════════════════════════════════
        # 12. JMP ZEQ → JMP ZEQ+2 (and any other JMP to DV'd word)
        # ════════════════════════════════════════════════════════════
        jmp_match = re.search(r'\bJMP\s+(\w+)\b', code_s)
        if jmp_match and not line.lstrip().startswith(';'):
            target = jmp_match.group(1)
            if target in FORTH_WORDS_WITH_DV and f'{target}+' not in code_s:
                new_line = line.replace(f'JMP {target}', f'JMP {target}+2')
                out.append(new_line)
                i += 1
                continue

        # ════════════════════════════════════════════════════════════
        # 13. Regular colon words: JSR DOCOL → DV + PHI
        # ════════════════════════════════════════════════════════════
        if label and label in DEV_WORDS and 'JSR DOCOL' in code_s:
            out.append(f'{label}:\tDATA.W ({label}+2)')
            out.append('\t\t\tPHI')
            in_thread = True
            current_word = label
            stats['dv'] += 1
            stats['phi'] += 1
            i += 1
            continue

        # ════════════════════════════════════════════════════════════
        # 14. Constants/User vars/DOES: JSR DOxxx → DV + JSR DOxxx
        # ════════════════════════════════════════════════════════════
        if label and label in DEV_WORDS:
            doxxx_match = re.match(r'JSR\s+(DO(?:CON|USE|ES|VAR))', code_s)
            if doxxx_match:
                out.append(f'{label}:\tDATA.W ({label}+2)')
                out.append(f'\t\t\tJSR {doxxx_match.group(1)}\t{comment}')
                stats['dv'] += 1
                i += 1
                in_thread = False
                continue

        # ════════════════════════════════════════════════════════════
        # 15. Primitives with DVs (FMTRK, FIP, etc.)
        # ════════════════════════════════════════════════════════════
        if label and label in DEV_WORDS and label not in INTERNAL_ROUTINES:
            if not ('JSR DOCOL' in code_s or re.match(r'JSR\s+DO', code_s)):
                out.append(f'{label}:\tDATA.W ({label}+2)')
                if code_s:
                    out.append(f'\t\t\t{code_s}\t{comment}')
                stats['dv'] += 1
                i += 1
                in_thread = False
                continue

        # ════════════════════════════════════════════════════════════
        # 16. Convert thread entries: DATA.W WORD → JPI (WORD)
        # ════════════════════════════════════════════════════════════
        if in_thread:
            full_code = strip_comment(line)[0].strip()
            word_ref = extract_data_w_word(full_code)
            if word_ref:
                m_dw = re.search(r'data\.w\s+\w+\s*$', full_code, re.IGNORECASE)
                prefix = full_code[:m_dw.start()].rstrip() if m_dw else ''
                indent = re.match(r'^(\s*)', line).group(1)
                if prefix:
                    out.append(f'{indent}{prefix}\tJPI ({word_ref})')
                else:
                    out.append(f'{indent}\t\t\tJPI ({word_ref})')
                if word_ref in INLINE_DATA_WORDS:
                    after_inline = word_ref
                stats['jpi'] += 1
                i += 1
                continue

        # ════════════════════════════════════════════════════════════
        # 17. Track word boundaries for thread mode
        # ════════════════════════════════════════════════════════════
        if label and label in DEV_WORDS and not label.startswith('.') and \
           not label.startswith('L_'):
            in_thread = False
            current_word = None

        # ════════════════════════════════════════════════════════════
        # 18. Default: pass through unchanged
        # ════════════════════════════════════════════════════════════
        out.append(line)
        i += 1

    return out, stats


# ── Verification ─────────────────────────────────────────────────────

def verify(lines):
    """Check for common issues."""
    issues = []
    for i, line in enumerate(lines):
        code = strip_comment(line)[0].strip()
        if line.lstrip().startswith(';'):
            continue

        # Unconverted JSR DOCOL (should be DV+PHI)
        if 'JSR DOCOL' in code:
            issues.append(f"Line {i+1}: Unconverted JSR DOCOL: {line.rstrip()}")

        # PFAPTR still has +3
        if '+3' in code and 'PFAPTR' in strip_comment(line)[1]:
            issues.append(f"Line {i+1}: PFAPTR still +3: {line.rstrip()}")

        # JPI without parens
        if re.search(r'\bJPI\s+[A-Za-z]', code) and '(' not in code:
            issues.append(f"Line {i+1}: JPI without parens: {line.rstrip()}")

    return issues


# ── Main ─────────────────────────────────────────────────────────────

def main():
    infile = 'src/ForthDevelopment-L28.asm'

    # Make backup
    import shutil
    backup = infile + '.dtc-backup'
    shutil.copy2(infile, backup)
    print(f"Backup saved to {backup}")

    with open(infile, 'rb') as f:
        content = f.read().decode('latin-1')
    lines = content.split('\n')
    print(f"Read {len(lines)} lines from {infile}")

    # Phase 1: Scan for dev ROM words
    global DEV_WORDS, FORTH_WORDS_WITH_DV
    DEV_WORDS = scan_dev_words(lines)
    FORTH_WORDS_WITH_DV = KERNEL_WORDS | DEV_WORDS
    print(f"Found {len(DEV_WORDS)} dev ROM words with DVs")
    print(f"Total words with DVs: {len(FORTH_WORDS_WITH_DV)}")

    # Phase 2: Convert
    result, stats = convert(lines)
    print(f"\nConversion: {len(result)} lines (was {len(lines)})")
    print(f"  DVs inserted: {stats['dv']}")
    print(f"  JSR DOCOL -> PHI: {stats['phi']}")
    print(f"  DATA.W -> JPI: {stats['jpi']}")
    print(f"  PFAPTR +3 -> +0: {stats['pfaptr']}")
    print(f"  Inline data slots: {stats['slot']}")

    # Phase 3: Verify
    issues = verify(result)
    if issues:
        print(f"\nVerification found {len(issues)} issues:")
        for issue in issues[:30]:
            print(f"  {issue}")
        if len(issues) > 30:
            print(f"  ... and {len(issues) - 30} more")
    else:
        print("\nVerification passed -- no issues found")

    # Write output
    with open(infile, 'wb') as f:
        f.write('\n'.join(result).encode('latin-1'))
    print(f"\nWrote {len(result)} lines to {infile}")


if __name__ == '__main__':
    main()
