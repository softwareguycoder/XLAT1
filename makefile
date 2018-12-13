XLAT1: XLAT1.o
	ld -o XLAT1 XLAT1.o
XLAT1.o: XLAT1.asm
	nasm -f elf64 -g -F stabs XLAT1.asm -l XLAT1.lst
clean:
	rm -f *.o *.lst XLAT1
