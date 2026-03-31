#!/usr/bin/env python3
"""
Convert column-based FONT5X7 (5 bytes/char, bit0=top row) to
row-based format (8 bytes/char, bit4=col0 ... bit0=col4) for ST7586S.
"""

import re
import sys

def parse_font_data(filename):
    """Extract 256 characters x 5 bytes from assembly source."""
    chars = []
    in_font = False
    with open(filename) as f:
        for line in f:
            if 'FONT5X7:' in line:
                in_font = True
                continue
            if in_font:
                if 'End of font table' in line or (line.strip() and not line.strip().startswith('DATA.B') and not line.strip().startswith(';')):
                    break
                m = re.findall(r'\$([0-9A-Fa-f]{2})', line)
                if len(m) == 5:
                    chars.append([int(x, 16) for x in m])
    return chars

def convert_char(col_bytes):
    """Convert 5 column bytes to 8 row bytes.
    col_bytes[i] is column i, bit j is row j (bit0=top).
    Output: row_bytes[j] has bit4=col0[j], bit3=col1[j], ..., bit0=col4[j].
    """
    rows = []
    for row in range(8):
        val = 0
        for col in range(5):
            if col_bytes[col] & (1 << row):
                val |= (1 << (4 - col))
        rows.append(val)
    return rows

def main():
    filename = sys.argv[1] if len(sys.argv) > 1 else 'src/ForthKernel-L28.asm'
    chars = parse_font_data(filename)
    if len(chars) != 256:
        print(f"Warning: found {len(chars)} characters, expected 256", file=sys.stderr)
        return

    # Output assembly DATA.B lines
    for i, col_bytes in enumerate(chars):
        row_bytes = convert_char(col_bytes)
        hex_str = ', '.join(f'${b:02X}' for b in row_bytes)
        if i >= 32 and i < 127:
            comment = f"  ; {i:3d} '{chr(i)}'"
        else:
            comment = f"  ; {i:3d}"
        print(f'\tDATA.B {hex_str}{comment}')

if __name__ == '__main__':
    main()
