* L28
x Did we start with the 6501 version of the 65C02 version. If 01 then we have some untangling to do of the stack.
x Check the listing to make sure the vectors are correct.
Optimise by making use of all new instructions.
Move useful functions (and drivers) into kernel ROM, use up the 8k. Include Console, Font etc. so Basic and others can use a simple console.

Define all L28 registers
Update em16 to be comprehensive L28 emulator

# IO
## Serial
## LCD
Init
fill
moveto
lineto
drawstring
scroll
setfont

## Keyboard
interrupt on keypress
scankey

## Disk
Should be easy


Update so kernel is 8k and Development is 8k