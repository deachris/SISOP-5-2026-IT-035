#!/bin/sh

case "$1" in
  --single)
    cd osboot
    qemu-system-x86_64 \
       -smp 2 \
       -m 512 \
       -display curses \
       -vga std \
       -netdev user,id=net0,net=10.0.2.0/24,host=10.0.2.2,dns=10.0.2.3 \
       -device virtio-net-pci,netdev=net0 \
       -kernel bzImage \
       -initrd single.gz
   ;;

  --multi)
    cd osboot
    qemu-system-x86_64 \
       -smp 2 \
       -m 512 \
       -display curses \
       -vga std \
       -netdev user,id=net0,net=10.0.2.0/24,host=10.0.2.2,dns=10.0.2.3 \
       -device virtio-net-pci,netdev=net0 \
       -kernel bzImage \
       -initrd multi.gz
   ;;

  --all)
    cd osboot
    qemu-system-x86_64 \
       -smp 2 \
       -m 512 \
       -display curses \
       -vga std \
       -netdev user,id=net0,net=10.0.2.0/24,host=10.0.2.2,dns=10.0.2.3 \
       -device virtio-net-pci,netdev=net0 \
       -cdrom farewell.iso \
       -boot d
   ;;

  *)
  echo "Usage: $0 --single / --multi / --all"
  exit 1
  ;;
esac
