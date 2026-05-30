#!/bin/sh

cd osboot

mkdir -p isodir/boot/grub

cp bzImage isodir/boot
cp single.gz isodir/boot
cp multi.gz isodir/boot

cat > isodir/boot/grub/grub.cfg << 'EOF'
set timeout=5
set default=0

menuentry "Farewell OS Single User" {
	linux /boot/bzImage
	initrd /boot/single.gz
}

menuentry "Farewell OS Multi User" {
	linux /boot/bzImage
	initrd /boot/multi.gz
}
EOF

grub-mkrescue -o farewell.iso isodir

rm -rf isodir


