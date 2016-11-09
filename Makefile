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

# ISO

GENISOIMAGE = genisoimage
ISO_FLAGS = -R -b boot/grub/stage2_eltorito -no-emul-boot -boot-load-size 4 -boot-info-table
STAGE2 = stage2_eltorito

ISO = snakasm.iso

iso: $(ISO)

$(ISO): iso/boot/snakasm.elf iso/boot/grub/stage2_eltorito iso/boot/grub/menu.lst
	$(GENISOIMAGE) $(ISO_FLAGS) -o $@ iso

iso/boot/snakasm.elf: $(KERNEL)
	@mkdir -p iso/boot
	cp $< $@

iso/boot/grub/stage2_eltorito: $(STAGE2)
	@mkdir -p iso/boot/grub
	cp $< $@

iso/boot/grub/menu.lst: menu.lst
	@mkdir -p iso/boot/grub
	cp $< $@

# QEMU

QEMU = qemu-system-i386
QEMU_FLAGS = -soundhw pcspk

qemu: $(KERNEL)
	$(QEMU) $(QEMU_FLAGS) -kernel $<

qemu-iso: $(ISO)
	$(QEMU) $(QEMU_FLAGS) -cdrom $<

clean:
	rm -rf $(OBJ) iso *.elf *.iso

# Run with sudo
install_dependencies:
	apt install nasm build-essential qemu-system-x86 genisoimage
