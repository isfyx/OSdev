ASM = nasm

run: bootblock.bin
	qemu-system-i386 -hda bootblock.bin

bootblock.bin: bootblock.asm
	$(ASM) $< -f bin -o bootblock.bin

clean:
	rm -f *.o *.bin
	rm -f bootblock
