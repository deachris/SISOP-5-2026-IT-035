#!/bin/bash

wget https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.1.1.tar.xz

tar -xvf linux-6.1.1.tar.xz

cd linux-6.1.1

make tinyconfig
make menuconfig

make -j$(nproc)

cp arch/x86/boot/bzImage ../osboot/
