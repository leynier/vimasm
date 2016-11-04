# NASM Compiler
AS = nasm
AS_FLAGS = -f elf32 -I src/

# C Compiler
CC = gcc
CC_FLAGS =

# Linker
LD = ld
LD_FLAGS = -m elf_i386 -nostdlib -T linker.ld

# Kernel
KERNEL = snakasm.elf

# All my source code
SRC = $(wildcard src/*.asm)

# Translate all .asm to .o
# ej. src/main.asm -> src/main.o
OBJ = $(SRC:%.asm=%.o)

kernel: $(KERNEL)

$(KERNEL): $(OBJ)
	$(LD) $(LD_FLAGS) -o $@ $^

%.o: %.asm
	$(AS) $(AS_FLAGS) -o $@ $^

%.o: %.c
	$(CC) $(CC_FLAGS) -o $@ $^

# QEMU

QEMU = qemu-system-i386
QEMU_FLAGS =

qemu: $(KERNEL)
	$(QEMU) $(QEMU_FLAGS) -kernel $<

clean:
	rm -rf $(OBJ)
