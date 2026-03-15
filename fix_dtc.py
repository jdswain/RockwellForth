#!/usr/bin/env python3
"""Fix ForthKernel-L28.asm for direct-threaded code conversion.

This script:
1. Adds missing primitive labels (removed by the CFA removal script)
2. Fixes DROP, TWODROP, BANKPOP
3. Fixes unkn2 and L2149 CFA remnants
4. Fixes references (BRAN+2, COLD+2, COLD+5, SELECT+2, SEMIS+2)
5. Rewrites DOCOL, DOCON, DOVAR, DOUSE, DOES, BRAN for DTC
6. Removes start_offset padding
7. Adds symbolic branch labels
8. Fixes CTLRQ offset bug
"""

import re, sys

with open('src/ForthKernel-L28.asm', 'r') as f:
    lines = f.readlines()

def line_at(n):
    """Return 1-indexed line content (stripped of newline)."""
    return lines[n-1].rstrip('\n')

def assert_contains(lineno, substr):
    """Verify a line contains expected content."""
    if substr not in lines[lineno-1]:
        print(f"ERROR: Line {lineno} does not contain '{substr}'", file=sys.stderr)
        print(f"  Actual: {lines[lineno-1].rstrip()}", file=sys.stderr)
        sys.exit(1)

def set_line(lineno, content):
    """Replace a 1-indexed line."""
    lines[lineno-1] = content + '\n'

def insert_after(lineno, content):
    """Insert a line after the given 1-indexed line."""
    lines.insert(lineno, content + '\n')

def delete_line(lineno):
    """Delete a 1-indexed line."""
    del lines[lineno-1]

# ============================================================================
# PASS 1: Add missing primitive labels
# Format: (1-indexed line number, label, expected content fragment)
# ============================================================================

primitives = [
    (186, 'LIT',       'LAN'),           # LIT: LAN
    (221, 'CLIT',      'LAN'),           # CLIT: LAN
    (241, 'EXECUTE',   'LDA stack,Y'),   # EXECUTE: LDA stack,Y
    # BRAN handled separately (rewrite)
    (284, 'ZBRAN',     'LDA stack,Y'),   # ZBRAN: LDA stack,Y
    (297, 'LOOP',      'TSX'),           # LOOP: TSX
    (317, 'PLOOP',     'LDA stack+1,Y'), # PLOOP: LDA stack+1,Y
    (343, 'DO',        'LDA stack+3,Y'), # DO: LDA stack+3,Y
    (361, 'DIGIT',     'SEC'),           # DIGIT: SEC
    (386, 'FIND',      'LDA #$02'),      # FIND: LDA #$02
    (443, 'ENCLOSE',   'LDA #$02'),      # ENCLOSE: LDA #$02
    (506, 'EMIT',      'LDA stack,Y'),   # EMIT: LDA stack,Y
    (526, 'KEY',       'JSR L517'),      # KEY: JSR L517
    (537, 'QTERM',     'LDA ACIA_STATUS'),# QTERM: LDA ACIA_STATUS
    (543, 'CR',        'LDA #$0d'),      # CR: LDA #$0d
    (553, 'CMOVE',     'LDA #3'),        # CMOVE: LDA #3
    (575, 'USTAR',     'LDA stack+2,Y'), # USTAR: LDA stack+2,Y
    (621, 'USLAS',     'LDA stack+2,Y'), # USLAS: LDA stack+2,Y
    (680, 'ANDD',      'LDA stack,Y'),   # ANDD: LDA stack,Y
    (692, 'OR',        'LDA stack,Y'),   # OR: LDA stack,Y
    (701, 'XOR',       'LDA stack,Y'),   # XOR: LDA stack,Y
    (710, 'SPAT',      'TYA'),           # SPAT: TYA
    (718, 'SPSTO',     'LDX #2'),        # SPSTO: LDX #2
    (725, 'RPSTO',     'LDX #$04'),      # RPSTO: LDX #$04
    (733, 'PUSHS',     'TSX'),           # PUSHS: TSX
    (740, 'SEMIS',     'PLI'),           # SEMIS: PLI
    (745, 'LEAVE',     'TSX'),           # LEAVE: TSX
    (754, 'GTR',       'LDA stack+1,Y'), # GTR: LDA stack+1,Y
    (762, 'RFROM',     'DEY'),           # RFROM: DEY
    (772, 'R',         'TSX'),           # R: TSX
    (780, 'ZEQ',       'LDA stack+1,Y'), # ZEQ: LDA stack+1,Y
    (795, 'ZLT',       'LDA stack+1,Y'), # ZLT: LDA stack+1,Y
    (806, 'PLUS',      'CLC'),           # PLUS: CLC
    (816, 'DPLUS',     'CLC'),           # DPLUS: CLC
    (833, 'NEGATE',    'SEC'),           # NEGATE: SEC
    (844, 'DNEGATE',   'SEC'),           # DNEGATE: SEC
    (855, 'OVER',      'LDA stack+2,Y'), # OVER: LDA stack+2,Y
    (870, 'SWAP',      'LDA stack+2,Y'), # SWAP: LDA stack+2,Y
    (883, 'DUP',       'LDA stack,Y'),   # DUP: LDA stack,Y
    (890, 'TWODUP',    'DEY'),           # TWODUP: DEY
    (903, 'BOUNDS',    'LDX stack+3,Y'), # BOUNDS: LDX stack+3,Y
    (922, 'PSTORE',    'LDA stack,Y'),   # PSTORE: LDA stack,Y
    (943, 'TOGGL',     'LDA stack+2,Y'), # TOGGL: LDA stack+2,Y
    (957, 'AT',        'LDA stack,Y'),   # AT: LDA stack,Y
    (969, 'CAT',       'LDA stack,Y'),   # CAT: LDA stack,Y
    (982, 'STORE',     'LDA stack,Y'),   # STORE: LDA stack,Y
    (995, 'CSTOR',     'LDA stack,Y'),   # CSTOR: LDA stack,Y
    (1161, 'ONEPLUS',  'LDA stack,Y'),   # ONEPLUS: LDA stack,Y
    (1173, 'TWOPLUS',  'CLC'),           # TWOPLUS: CLC
    (1185, 'ONEMINUS', 'LDA stack,Y'),   # ONEMINUS: LDA stack,Y
    (1199, 'TWOMINUS', 'SEC'),           # TWOMINUS: SEC
    (1225, 'ULESS',    'SEC'),           # ULESS: SEC
    (1239, 'LESS',     'LDA stack+2,Y'), # LESS: LDA stack+2,Y
    (1263, 'ROT',      'LDA stack+4,Y'), # ROT: LDA stack+4,Y
    (1563, 'COLD',     'LDA #0'),        # COLD: LDA #0
    (1869, 'SELECT',   'LDA stack,Y'),   # SELECT: LDA stack,Y (with leading spaces/tab)
    (1880, 'DREAD',    'JSR CALCSEC'),   # DREAD: JSR CALCSEC
    (1946, 'DWRITE',   'JSR CALCSEC'),   # DWRITE: JSR CALCSEC
    (1973, 'INIT',     'LDA DSK_STATUS'),# INIT: LDA DSK_STATUS
    (1991, 'SEEK',     'LDX DISKNO'),    # SEEK: LDX DISKNO
    (2137, 'EECSTORE', 'LDX #4'),        # EECSTORE: LDX #4
    (2183, 'BANKPSH',  'JMP POP'),       # BANKPSH: JMP POP
]

print("Pass 1: Adding primitive labels...")
for lineno, label, expected in primitives:
    assert_contains(lineno, expected)
    old = lines[lineno-1]
    # Replace leading whitespace with label
    stripped = old.lstrip()
    # Determine tab alignment
    label_str = f"{label}:"
    if len(label_str) < 8:
        label_str = label_str + '\t' * ((8 - len(label_str) + 7) // 8)
    else:
        label_str = label_str + '\t'
    set_line(lineno, f"{label_str}{stripped.rstrip()}")

# ============================================================================
# PASS 2: Fix DROP, TWODROP, BANKPOP
# ============================================================================

print("Pass 2: Fixing DROP, TWODROP, BANKPOP...")

# DROP: DATA.W POP -> JMP POP
assert_contains(862, 'DROP:')
assert_contains(862, 'DATA.W POP')
set_line(862, "DROP:\t\tJMP POP")

# TWODROP: DATA.W POPTWO -> JMP POPTWO
assert_contains(866, 'TWODROP:')
assert_contains(866, 'DATA.W POPTWO')
set_line(866, "TWODROP:\tJMP POPTWO")

# BANKPOP: JMP SEMIS+2 -> JMP SEMIS (and add label - done in Pass 1 NOT, handle here)
assert_contains(2187, 'JMP SEMIS+2')
set_line(2187, "BANKPOP:\tJMP SEMIS")

# ============================================================================
# PASS 3: Fix unkn2 and L2149
# ============================================================================

print("Pass 3: Fixing unkn2 and L2149...")

# unkn2: add label and fix reference
assert_contains(1667, 'DATA.W unkn2+4')
set_line(1667, "unkn2:\t\tDATA.W unkn2+2")

# L2149: remove the DATA.W L2149+2 line (it's a CFA remnant)
# L2149 label is on this line, move it to next line
assert_contains(2246, 'L2149')
assert_contains(2246, 'DATA.W L2149+2')
assert_contains(2247, 'LDA #$20')
set_line(2247, "L2149:\t\tLDA #$20")
delete_line(2246)
# Note: all subsequent line numbers in later passes shift by -1 after this delete
# But since we process top to bottom and this is near the end, the impact is manageable
# Line numbers after 2246 are now off by 1

# ============================================================================
# PASS 4: Fix references
# ============================================================================

print("Pass 4: Fixing references...")

# Fix BRAN+2 -> BRAN (lines 288, 306, 307)
# Line 288: BEQ BRAN+2
assert_contains(288, 'BEQ BRAN+2')
set_line(288, "    \t\tBEQ BRAN\t\t\t; if zero, take branch")

# Line 306: BPL BRAN+2
assert_contains(306, 'BPL BRAN+2')
set_line(306, "L316\t\tBPL BRAN")

# Line 307: BVS BRAN+2
assert_contains(307, 'BVS BRAN+2')
set_line(307, "    \t\tBVS BRAN")

# Fix COLD+2 -> COLD (lines 1599, 1603)
assert_contains(1599, 'COLD+2')
set_line(1599, "L1505\t\tLDA #<COLD")
assert_contains(1603, 'COLD+2')
set_line(1603, "  \t\t\tLDA #>COLD")

# Fix COLD+5 -> L1485 (line 2308, shifted to 2307 after L2149 delete)
# Actually let me check: the L2149 delete was at line 2246. Line 2308 is after,
# so it's now at 2307.
assert_contains(2307, 'COLD+5')
set_line(2307, "RESET:\t\tDATA.W L1485")

# Fix entry := COLD+2 -> COLD (line 2311, now 2310)
assert_contains(2310, 'entry := COLD+2')
set_line(2310, "\tentry := COLD")

# Fix JMP SELECT+2 (line 2259, now 2258 after L2149 delete)
assert_contains(2258, 'JMP SELECT+2')
set_line(2258, "    \t\tJMP SELECT")

# ============================================================================
# PASS 5: Rewrite DOCOL for DTC (JSR-based entry)
# ============================================================================

print("Pass 5: Rewriting DOCOL...")

# Current DOCOL is lines 1006-1019
# Replace the entire block
docol_start = 1006
docol_end = 1019
assert_contains(docol_start, 'DOCOL:')
assert_contains(docol_end, 'JMP NEXT')

new_docol = """\
DOCOL:\t\tPHI \t\t\t\t; save current I on return stack
    \t\tPLA \t\t\t\t; ret_lo (JSR pushed PC+2)
    \t\tCLC
    \t\tADC #1\t\t\t\t; PFA_lo = ret_lo + 1
    \t\tSTA N\t\t\t\t; save PFA_lo
    \t\tPLA \t\t\t\t; ret_hi
    \t\tADC #0\t\t\t\t; PFA_hi = ret_hi + carry
    \t\tPHA \t\t\t\t; push PFA_hi (for PLI)
    \t\tLDA N
    \t\tPHA \t\t\t\t; push PFA_lo (for PLI)
    \t\tPLI \t\t\t\t; I = PFA (parameter field)
    \t\tJMP NEXT"""

lines[docol_start-1:docol_end] = [l + '\n' for l in new_docol.split('\n')]
# This changes line count. Compute delta.
old_count = docol_end - docol_start + 1  # was 14 lines
new_count = len(new_docol.split('\n'))    # 12 lines
delta_docol = new_count - old_count       # -2

# Track cumulative line offset for subsequent edits after DOCOL
offset = delta_docol

# ============================================================================
# PASS 6: Rewrite DOCON for DTC
# ============================================================================

print("Pass 6: Rewriting DOCON...")

docon_start = 1023 + offset  # adjusted
docon_end = 1032 + offset
assert_contains(docon_start, 'DOCON:')
assert_contains(docon_end, 'JMP PUSH')

new_docon = """\
DOCON:\t\tPLA \t\t\t\t; ret_lo
    \t\tCLC
    \t\tADC #1\t\t\t\t; PFA_lo
    \t\tSTA N
    \t\tPLA \t\t\t\t; ret_hi
    \t\tADC #0\t\t\t\t; PFA_hi
    \t\tSTA N+1
    \t\tLDA (N)\t\t\t\t; const lo
    \t\tPHA
    \t\tLDX #1
    \t\tLDA (N),X\t\t\t; const hi
    \t\tJMP PUSH"""

lines[docon_start-1:docon_end] = [l + '\n' for l in new_docon.split('\n')]
old_count2 = docon_end - docon_start + 1  # was 10 lines
new_count2 = len(new_docon.split('\n'))   # 12 lines
offset += new_count2 - old_count2

# ============================================================================
# PASS 7: Rewrite DOVAR for DTC
# ============================================================================

print("Pass 7: Rewriting DOVAR...")

dovar_start = 1036 + offset
dovar_end = 1042 + offset
assert_contains(dovar_start, 'DOVAR:')
assert_contains(dovar_end, 'JMP PUSH')

new_dovar = """\
DOVAR:\t\tPLA \t\t\t\t; ret_lo
    \t\tCLC
    \t\tADC #1\t\t\t\t; PFA_lo
    \t\tSTA N
    \t\tPLA \t\t\t\t; ret_hi
    \t\tADC #0\t\t\t\t; PFA_hi
    \t\tDEY
    \t\tDEY
    \t\tSTA stack+1,Y\t\t; push PFA_hi
    \t\tLDA N
    \t\tSTA stack,Y\t\t\t; push PFA_lo
    \t\tJMP NEXT"""

lines[dovar_start-1:dovar_end] = [l + '\n' for l in new_dovar.split('\n')]
old_count3 = dovar_end - dovar_start + 1  # was 7 lines
new_count3 = len(new_dovar.split('\n'))   # 12 lines
offset += new_count3 - old_count3

# ============================================================================
# PASS 8: Rewrite DOUSE for DTC
# ============================================================================

print("Pass 8: Rewriting DOUSE...")

douse_start = 1046 + offset
douse_end = 1057 + offset
assert_contains(douse_start, 'DOUSE:')
assert_contains(douse_end, 'JMP PUSH')

new_douse = """\
DOUSE:\t\tPLA \t\t\t\t; ret_lo
    \t\tCLC
    \t\tADC #1\t\t\t\t; PFA_lo
    \t\tSTA N
    \t\tPLA \t\t\t\t; ret_hi
    \t\tADC #0\t\t\t\t; PFA_hi
    \t\tSTA N+1
    \t\tCLC
    \t\tLDA (N)\t\t\t\t; offset byte
    \t\tADC UP\t\t\t\t; add user area base lo
    \t\tPHA \t\t\t\t; result lo for PUSH
    \t\tLDA #$00
    \t\tADC UP+1\t\t\t; result hi
    \t\tJMP PUSH"""

lines[douse_start-1:douse_end] = [l + '\n' for l in new_douse.split('\n')]
old_count4 = douse_end - douse_start + 1  # was 12 lines
new_count4 = len(new_douse.split('\n'))   # 14 lines
offset += new_count4 - old_count4

# ============================================================================
# PASS 9: Rewrite DOES for DTC
# ============================================================================

print("Pass 9: Rewriting DOES...")

does_start = 1322 + offset
does_end = 1346 + offset
assert_contains(does_start, 'DOES:')
assert_contains(does_end, 'JMP PUSH')

new_does = """\
DOES:\t\tPHI \t\t\t\t; save current I on return stack
    \t\tPLA \t\t\t\t; ret_lo
    \t\tCLC
    \t\tADC #1\t\t\t\t; PFA_lo
    \t\tSTA N
    \t\tPLA \t\t\t\t; ret_hi
    \t\tADC #0\t\t\t\t; PFA_hi
    \t\tSTA N+1\t\t\t\t; N = PFA (DOES> body ptr location)
    \t\t;; Read DOES> body IP from (N)
    \t\tLDX #1
    \t\tLDA (N),X\t\t\t; body_hi
    \t\tPHA
    \t\tLDA (N)\t\t\t\t; body_lo
    \t\tPHA
    \t\tPLI \t\t\t\t; I = DOES> body address
    \t\t;; Push PFA+2 (parameter field) onto data stack
    \t\tCLC
    \t\tLDA N
    \t\tADC #2
    \t\tPHA \t\t\t\t; param_lo for PUSH
    \t\tLDA N+1
    \t\tADC #0\t\t\t\t; param_hi
    \t\tJMP PUSH"""

lines[does_start-1:does_end] = [l + '\n' for l in new_does.split('\n')]
old_count5 = does_end - does_start + 1
new_count5 = len(new_does.split('\n'))
offset += new_count5 - old_count5

# ============================================================================
# PASS 10: Rewrite BRAN for DTC
# ============================================================================

print("Pass 10: Rewriting BRAN...")

# BRAN starts at original line 251 (before any offset adjustments from DOCOL etc.)
# But BRAN is BEFORE the DOCOL/DOCON/DOVAR/DOUSE/DOES rewrites, so offset doesn't apply!
# The offset variable only tracks changes from DOCOL onwards (line 1006+).
# Lines before 1006 are unchanged in count.

bran_start = 251  # CLC instruction (first code line of BRAN)
bran_end = 280    # JMP NEXT

# Verify
assert_contains(bran_start, 'CLC')
assert_contains(bran_end, 'JMP NEXT')

new_bran = """\
BRAN:\t\tPHI \t\t\t\t; save I (pointing at offset bytes)
    \t\tLAN \t\t\t\t; offset lo from thread, I advances
    \t\tSTA N
    \t\tLAN \t\t\t\t; offset hi from thread, I advances
    \t\tSTA N+1
    \t\tPLA \t\t\t\t; saved I_lo (original, before LANs)
    \t\tCLC
    \t\tADC N\t\t\t\t; I_lo + offset_lo
    \t\tSTA N+2
    \t\tPLA \t\t\t\t; saved I_hi
    \t\tADC N+1\t\t\t\t; I_hi + offset_hi + carry
    \t\tPHA \t\t\t\t; push new_hi (for PLI)
    \t\tLDA N+2
    \t\tPHA \t\t\t\t; push new_lo (for PLI)
    \t\tPLI \t\t\t\t; I = target address
    \t\tJMP NEXT"""

lines[bran_start-1:bran_end] = [l + '\n' for l in new_bran.split('\n')]
bran_delta = len(new_bran.split('\n')) - (bran_end - bran_start + 1)
# This affects all line numbers AFTER bran_end
# Since all our subsequent passes used line numbers > 1006 (except BRAN which is done),
# we need to add bran_delta to the offset for subsequent passes.
# But wait — the offset variable was for lines after DOCOL (1006+).
# The bran_delta applies to ALL lines after 280.
# Since DOCOL is at line 1006 > 280, the bran_delta affects it.
# But we already applied the DOCOL rewrite... so we need to be careful.
# Actually, since we're done with all the rewrites (DOCOL through DOES and BRAN),
# the remaining edits are simple line replacements that we'll find by content.
# So the line number offsets don't matter much anymore.

print(f"  BRAN delta: {bran_delta} lines")
print(f"  DOCOL+ delta: {offset} lines")

# ============================================================================
# PASS 11: Remove start_offset padding
# ============================================================================

print("Pass 11: Removing start_offset padding...")

# Find and remove the start_offset definition and FILL line
for i, line in enumerate(lines):
    if 'start_offset := $260' in line:
        lines[i] = '\n'  # blank the line
        print(f"  Blanked start_offset definition at line {i+1}")
    if 'FILL.B start_offset, $ff' in line:
        lines[i] = '\n'  # blank the line
        print(f"  Blanked FILL line at line {i+1}")

# ============================================================================
# PASS 12: Fix CTLRQ — add SEMIS after MMON, use symbolic branch
# ============================================================================

print("Pass 12: Fixing CTLRQ...")

for i, line in enumerate(lines):
    if "DATA.W $ffcb" in line:
        # Replace with symbolic offset
        lines[i] = "    \t\tDATA.W .CTLRQ_END - *\t; skip MMON if not Ctrl-R\n"
        # Find the DATA.W MMON line after this
        for j in range(i+1, min(i+5, len(lines))):
            if 'DATA.W MMON' in lines[j]:
                # Insert SEMIS after MMON
                lines.insert(j+1, ".CTLRQ_END:\tDATA.W SEMIS\n")
                print(f"  Fixed CTLRQ offset at line {i+1}, added SEMIS after line {j+1}")
                break
        break

# ============================================================================
# PASS 13: Add symbolic branch labels for all colon definitions
# ============================================================================

print("Pass 13: Converting branch offsets to symbolic labels...")

# We'll find every DATA.W with a hex offset and convert it.
# Strategy: for each colon definition, track byte positions and convert offsets.
# Since this is complex, we'll use a simpler approach:
# Find DATA.W $xxxx patterns that look like offsets (not word references)
# and convert them based on context.

# Helper: check if a DATA.W value is likely a branch offset (not a word address)
def is_branch_offset(val_str):
    """Check if a hex value is a branch offset (small positive or negative)."""
    try:
        val = int(val_str, 16)
        if val >= 0x8000:
            val -= 0x10000  # convert to signed
        return -256 <= val <= 256  # branch offsets are typically small
    except ValueError:
        return False

# For symbolic conversion, we need to know the byte offset of each thread entry
# relative to the start of the word. This requires tracking positions through the thread.
#
# A simpler approach: for each ZBRAN/BRAN/LOOP offset, compute the target line
# by counting bytes forward/backward, add a label if needed, and replace the offset.
#
# But this is extremely complex to do reliably in a script. Instead, let's use
# a targeted approach for each known word with branches.

# Convert DECIMAL's cross-word branch to L1170 symbolic label
for i, line in enumerate(lines):
    if "DATA.W $fff3" in line and i > 0 and 'BRAN' in lines[i-1]:
        lines[i] = "    \t\tDATA.W L1170 - *\t\t; branch into HEX body\n"
        print(f"  DECIMAL branch at line {i+1} -> L1170 - *")
        break

# For the remaining branch offsets, we'll add inline labels.
# Rather than computing all of them, let's convert the well-understood patterns:
#
# $0004 = skip 1 word (very common with ZBRAN)
# These skip the next DATA.W entry to the one after it.

# We'll handle these by finding ZBRAN/$0004 patterns and adding .SKIPn labels

skip_counter = 0

i = 0
while i < len(lines):
    line = lines[i]

    # Match DATA.W $xxxx where xxxx is a hex offset
    m = re.match(r'^(\s+)DATA\.W \$([0-9a-fA-F]{4})\s*(;.*)?$', line.rstrip())
    if m:
        indent = m.group(1)
        hex_val = m.group(2)
        comment = m.group(3) or ''
        val = int(hex_val, 16)
        if val >= 0x8000:
            signed_val = val - 0x10000
        else:
            signed_val = val

        # Check if this is after a ZBRAN or BRAN or LOOP entry
        # Look at previous line for context
        is_after_branch = False
        branch_type = None
        for j in range(max(0, i-1), max(0, i-3), -1):
            prev = lines[j].strip()
            if 'DATA.W ZBRAN' in prev:
                is_after_branch = True
                branch_type = 'ZBRAN'
                break
            elif 'DATA.W BRAN' in prev and 'ZBRAN' not in prev:
                is_after_branch = True
                branch_type = 'BRAN'
                break
            elif 'DATA.W LOOP' in prev and 'PLOOP' not in prev:
                is_after_branch = True
                branch_type = 'LOOP'
                break
            elif 'DATA.W PLOOP' in prev:
                is_after_branch = True
                branch_type = 'PLOOP'
                break

        if is_after_branch and is_branch_offset(hex_val):
            # This is a branch offset — convert to symbolic
            # Calculate target: offset is relative to the position of this DATA.W
            # Target line = current position + signed_val bytes
            # Each DATA.W is 2 bytes, DATA.B varies

            if signed_val > 0:
                # Forward branch: count bytes forward to find target
                target_label = f".BR{skip_counter}"
                skip_counter += 1

                # Count bytes forward from current position
                bytes_counted = 0
                target_line = i + 1
                while bytes_counted < signed_val and target_line < len(lines):
                    tl = lines[target_line].strip()
                    if tl.startswith(';;') or tl == '' or tl.startswith('*') or tl.startswith(';'):
                        target_line += 1
                        continue
                    # Count bytes for this line
                    if 'DATA.W' in tl:
                        bytes_counted += 2
                    elif 'DATA.B' in tl:
                        # Count comma-separated values plus strings
                        # Simple: count commas + 1, plus string lengths
                        parts = tl.split('DATA.B')[1].strip()
                        byte_count = 0
                        in_string = False
                        j_idx = 0
                        while j_idx < len(parts):
                            if parts[j_idx] == '"':
                                if in_string:
                                    in_string = False
                                else:
                                    in_string = True
                                j_idx += 1
                            elif in_string:
                                byte_count += 1
                                j_idx += 1
                            elif parts[j_idx] == ',':
                                j_idx += 1
                            elif parts[j_idx] in ' \t':
                                j_idx += 1
                            elif parts[j_idx] == ';':
                                break
                            else:
                                byte_count += 1
                                # Skip to next comma or end
                                while j_idx < len(parts) and parts[j_idx] not in ',;"':
                                    j_idx += 1
                        bytes_counted += byte_count
                    elif 'JSR' in tl:
                        bytes_counted += 3
                    else:
                        # Unknown — skip this approach for safety
                        target_line += 1
                        continue
                    target_line += 1

                if bytes_counted == signed_val:
                    # Found the target line — add label there if not already labeled
                    tl = lines[target_line].strip()
                    if not re.match(r'^[A-Za-z_.]', tl):
                        # No label — add one
                        lines[target_line] = f"{target_label}:\t{lines[target_line].lstrip()}"
                    else:
                        # Already has a label — use it
                        existing_label = re.match(r'^([A-Za-z_.]\w*)', tl)
                        if existing_label:
                            target_label = existing_label.group(1).rstrip(':')

                    lines[i] = f"{indent}DATA.W {target_label} - *\t; was ${hex_val}\n"
            else:
                # Backward branch: count bytes backward
                target_label = f".BR{skip_counter}"
                skip_counter += 1

                bytes_counted = 0
                target_line = i - 1
                while bytes_counted > signed_val and target_line >= 0:
                    tl = lines[target_line].strip()
                    if tl.startswith(';;') or tl == '' or tl.startswith('*') or tl.startswith(';'):
                        target_line -= 1
                        continue
                    if 'DATA.W' in tl:
                        bytes_counted -= 2
                    elif 'DATA.B' in tl:
                        parts = tl.split('DATA.B')[1].strip()
                        byte_count = 0
                        in_string = False
                        j_idx = 0
                        while j_idx < len(parts):
                            if parts[j_idx] == '"':
                                if in_string:
                                    in_string = False
                                else:
                                    in_string = True
                                j_idx += 1
                            elif in_string:
                                byte_count += 1
                                j_idx += 1
                            elif parts[j_idx] == ',':
                                j_idx += 1
                            elif parts[j_idx] in ' \t':
                                j_idx += 1
                            elif parts[j_idx] == ';':
                                break
                            else:
                                byte_count += 1
                                while j_idx < len(parts) and parts[j_idx] not in ',;"':
                                    j_idx += 1
                        bytes_counted -= byte_count
                    elif 'JSR' in tl:
                        bytes_counted -= 3
                    else:
                        target_line -= 1
                        continue
                    target_line -= 1

                target_line += 1  # went one too far

                if bytes_counted == signed_val:
                    tl = lines[target_line].strip()
                    if not re.match(r'^[A-Za-z_.]', tl):
                        lines[target_line] = f"{target_label}:\t{lines[target_line].lstrip()}"
                    else:
                        existing_label = re.match(r'^([A-Za-z_.]\w*)', tl)
                        if existing_label:
                            target_label = existing_label.group(1).rstrip(':')

                    lines[i] = f"{indent}DATA.W {target_label} - *\t; was ${hex_val}\n"
    i += 1

# ============================================================================
# PASS 14: Add FILL before vectors at end
# ============================================================================

print("Pass 14: Adding FILL padding before vectors...")

# Find the NMI/RESET/IRQ vector area and add FILL before it
for i, line in enumerate(lines):
    if 'DATA.W $ffff' in line and 'Padding' in line:
        # Replace padding marker with FILL to $FFFA
        lines[i] = "\n\t\t\tFILL ($FFFA - addr), $FF\t; pad to vectors\n\n"
        print(f"  Added FILL before vectors at line {i+1}")
        break

# ============================================================================
# PASS 15: Update header comments for DTC
# ============================================================================

print("Pass 15: Updating comments...")

# Add DTC note to header
for i, line in enumerate(lines):
    if 'NXT opcode replaces NEXT routine' in line:
        lines[i] = ";   - NXT opcode implements direct-threaded NEXT\n"
        break

for i, line in enumerate(lines):
    if "No W-1 JMP trick needed (NXT does direct threading)" in line:
        lines[i] = ";   - Direct-threaded code (DTC): primitives have no CFA\n;   - Colon defs use JSR DOCOL, constants use JSR DOCON, etc.\n"
        break

# ============================================================================
# Write output
# ============================================================================

with open('src/ForthKernel-L28.asm', 'w') as f:
    f.writelines(lines)

print("\nDone! File updated.")
print("Next: assemble with ../65Tools/bin/as to check for errors.")
