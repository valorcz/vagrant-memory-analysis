#!/bin/bash

firmware_path=/opt/homebrew/share/qemu
disk_file_location=~/.vagrant.d/boxes/generic-VAGRANTSLASH-alma9/4.3.12/arm64/libvirt/box_0.img

qemu-system-aarch64 \
	-cpu max -M virt -m 2048 -nographic \
        -machine virt,accel=hvf,highmem=on \
	-display none -vga none -monitor none \
        -drive "if=pflash,format=raw,file=${firmware_path}/edk2-aarch64-code.fd,readonly=on" \
        -drive "if=pflash,format=raw,file=${firmware_path}/edk2-arm-vars.fd,discard=on" \
        -drive "if=virtio,format=qcow2,file=${disk_file_location}" \
        -device virtio-net-device,netdev=net0 \
	-netdev user,id=net0,hostfwd=tcp::50024-:22 \
	-serial telnet::4444,server,wait=off \
	-no-reboot

exit

qemu-system-aarch64 \
	-cpu max -M virt -m 2048 -nographic \
        -machine virt,accel=hvf,highmem=on \
	-display none -vga none -monitor none \
        -drive "if=pflash,format=raw,file=${firmware_path}/edk2-aarch64-code.fd,readonly=on" \
        -drive "if=pflash,format=raw,file=${firmware_path}/edk2-arm-vars.fd,discard=on" \
        -drive "if=virtio,format=qcow2,file=${disk_file_location}" \
        -D qemu-log.txt \
	-net nic \
	-net user,hostfwd=tcp::50024-:22 \
	-serial telnet::4444,server,wait=off \
	-no-reboot

exit

qemu-system-aarch64 \
         -machine virt,accel=hvf,highmem=on \
         -cpu max -smp 2 -m 4G \
         -device qemu-xhci \
         -device usb-kbd \
         -device virtio-net-device,netdev=net0 \
	 -netdev user,id=net0,hostfwd=tcp::50024-:22 \
         -D qemu-log.txt \
	 -display none -vga none -monitor none \
         -drive "if=pflash,format=raw,file=${firmware_path}/edk2-aarch64-code.fd,readonly=on" \
         -drive "if=pflash,format=raw,file=${firmware_path}/edk2-arm-vars.fd,discard=on" \
         -drive "if=virtio,format=qcow2,file=${disk_file_location}" \
         -chardev qemu-vdagent,id=spice,name=vdagent,clipboard=on \
         -device virtio-serial-pci \
         -device virtserialport,chardev=spice,name=com.redhat.spice.0 \
	 -chardev socket,id=mon0,path=qemu_socket,server=on,wait=off \
	 -chardev socket,id=ser0,path=qemu_socket_serial,server=on,wait=off \
	 -serial chardev:ser0 \
	 -serial telnet::4444,server,wait=off -nographic \
	 -boot order=d,menu=off

#	 -serial telnet::4444,server -nographic \
#	 -mon chardev=mon0,mode=readline \
