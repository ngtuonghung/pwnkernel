#!/bin/bash

# Package the filesystem into a compressed archive
pushd fs
# find all files and compress them into initramfs.cpio.gz
find . -print0 | cpio --null -ov --format=newc | gzip -9 > ../initramfs.cpio.gz
popd

# Start the virtual machine
/usr/bin/qemu-system-x86_64 \
	-enable-kvm \
	-kernel ./linux-5.4/arch/x86/boot/bzImage \
	-initrd $PWD/initramfs.cpio.gz \
	-fsdev local,security_model=passthrough,id=fsdev0,path=$HOME/pwnkernel/ \
	-device virtio-9p-pci,id=fs0,fsdev=fsdev0,mount_tag=hostshare \
	-nographic \
	-monitor none \
	-s \
	-append "console=ttyS0 nokaslr"
# -enable-kvm: makes VM faster
# -kernel: which kernel to run
# -initrd: the filesystem to use
# -fsdev + -device: let VM access host files
# -nographic: show output in terminal
# -monitor none: don't open extra control window
# -s: let debugger attach on port 1234
# -append: turn off address randomization, output to terminal
