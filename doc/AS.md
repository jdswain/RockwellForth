as is the assembler we use.

It is written in C.

/Users/jason/Development/1av/65/65Tools/as contains the source code. You can view the source to understand the assembler, and alter the code to fix bugs.

Some of the code is in ../shared

It has a Makefile based build system. BUILD_BASE needs to be set to /Users/jason/Development/1av/65/65Tools.

It requires a -o _outputfile_ command line to output the assembled code. It uses the output extension to set the format. No extension means ELF.

It always outputs a listing file. This is useful for looking up symbol addresses. The best way to use this is to cd to the source directory and assemble in there, then the listing file will sit alongside the source file.

