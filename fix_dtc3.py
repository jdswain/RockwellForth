#!/usr/bin/env python3
"""Revert ALL symbolic branch conversions back to numeric offsets.
Also remove any .WORD labels that were added.
Keep the CTLRQ fix and DECIMAL fix as they were correct concepts but wrong syntax.
"""

import re

with open('src/ForthKernel-L28.asm', 'r') as f:
    lines = f.readlines()

changes = 0

i = 0
while i < len(lines):
    line = lines[i]

    # Revert any DATA.W (label - addr) back to original offset
    # We can't easily recover the original offset, so instead let's look for
    # patterns and revert them

    # Pattern 1: DATA.W (label - addr) — symbolic branch
    m = re.match(r'^(\s*)(?:(\.\w+)\s+)?DATA\.W \((\S+) - addr\)\s*$', line)
    if not m:
        m = re.match(r'^(\s*)(?:(\.\w+)\s+)?DATA\.W \((\S+) - addr\)\s*;;.*$', line)

    if m:
        # This is a symbolic branch. We need to remove it and restore numeric.
        # Problem: we don't know the original value!
        # So let's leave these and just fix the ones we know are wrong.
        pass

    # Remove labels that start with . and were added by the script
    # (like .TYPE1, .DTRAI1, .EXPECT1, etc.)
    m2 = re.match(r'^\.(\w+)\s+(DATA\.W\s+.*)', line)
    if m2:
        label_name = '.' + m2.group(1)
        rest = m2.group(2)
        # Check if this label is referenced elsewhere
        referenced = False
        for j, other_line in enumerate(lines):
            if j == i:
                continue
            if label_name in other_line:
                referenced = True
                break
        if not referenced:
            # Remove orphaned label
            lines[i] = '\t\t\t' + rest.lstrip() + '\n'
            changes += 1

    i += 1

# The real issue is the script generated wrong target labels.
# Let's just revert everything back to numeric and start fresh.
# Read the file again and find all (xxx - addr) patterns

with open('src/ForthKernel-L28.asm', 'r') as f:
    content = f.read()

# We'll keep a simple approach: just manually list the correct conversions
# For now, revert ALL symbolic branches to $0000 placeholder and mark them

# Actually, the cleanest approach: restore the original L28 file from before
# the symbolic conversion, keeping all the other DTC fixes.

print("This script is not needed. Will use a different approach.")
print("See fix_dtc4.py")
