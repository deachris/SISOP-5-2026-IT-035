#!/bin/bash

mkdir -p rootfs/{bin,dev,proc,sys,etc,tmp,root,home/henn,home/hann,home/viii,home/kids}

cp -a /dev/null rootfs/dev
cp -a /dev/tty* rootfs/dev
cp -a /dev/zero rootfs/dev
cp -a /dev/console rootfs/dev
mknod -m 666 rootfs/dev/fuse c 10 229

cp /usr/bin/busybox rootfs/bin
cd rootfs/bin
./busybox --install .
cd ../..

ROOTPASS=$(openssl passwd -1 root123)
HENNPASS=$(openssl passwd -1 henn123)
HANNPASS=$(openssl passwd -1 hann123)
VIIIPASS=$(openssl passwd -1 viii123)
KIDSPASS=$(openssl passwd -1 kids123)

cat > rootfs/etc/passwd << EOF
root:$ROOTPASS:0:0:root:/root:/bin/sh
henn:$HENNPASS:1001:100:henn:/home/henn:/bin/sh
hann:$HANNPASS:1002:101:hann:/home/hann:/bin/sh
viii:$VIIIPASS:1003:101:viii:/home/viii:/bin/sh
kids:$KIDSPASS:1004:101:kids:/home/kids:/bin/sh
EOF

cat > rootfs/etc/group << EOF
root:x:0:
henn:x:100:henn
hann:x:101:hann,viii
kids:x:102:hann,viii,kids
EOF

cat > rootfs/etc/profile << 'EOF'
echo "======================================================================="
echo " _____    __      _____   ______  _        _  ______  _      _"
echo "|  ___|  /  \    |  __ \ |  ____|| |      | ||  ____|| |    | |"
echo "| |___  / /\ \   | |__) )| |___  | |  __  | || |___  | |    | |"
echo "|  ___|/ /__\ \  |  _  / |  ___| | | /  \ | ||  ___| | |    | |"
echo "| |   /  ____  \ | | \ \ | |____ \ \/ /\ \/ /| |____ | |___ | |___"
echo "|_|  /__/    \__\|_|  \_\|______| \__/  \__/ |______||_____||_____|"
echo " "
echo "            _____    __      _____  _______ ___    ___"
echo "           |  __ \  /  \    |  __ \|__   __|\  \  /  /"
echo "           | |__) )/ /\ \   | |__) )  | |    \  \/  /"
echo "           |  ___// /__\ \  |  _  /   | |     \    /"
echo "           | |   /  ____  \ | | \ \   | |      |  |"
echo "           |_|  /__/    \__\|_|  \_\  |_|      |__|"
echo " "
echo "======================================================================="

echo "Welcome, $(whoami)!"
EOF

echo "check_certificate = off" > rootfs/etc/wgetrc

chown -R 0:0 rootfs/root
chown -R 1001:100 rootfs/home/henn
chown -R 1002:101 rootfs/home/hann
chown -R 1003:101 rootfs/home/viii
chown -R 1004:102 rootfs/home/kids

# Akses root
chmod 700 rootfs/root

# Akses henn
chmod 755 rootfs/home/henn

# Akses hann
chmod 775 rootfs/home/hann

# Akses viii
chmod 775 rootfs/home/viii

# Akses kids
chmod 770 rootfs/home/kids

chmod 1777 rootfs/tmp

chmod 755 rootfs/home
chmod 555 rootfs/bin
chmod 555 rootfs/etc

cat > rootfs/init << 'EOF'
#!/bin/sh
/bin/mount -t proc none /proc
/bin/mount -t sysfs none /sys
/bin/mount -t devpts devpts /dev/pts
mkdir -p /var/lib/dpkg/updates /var/lib/dpkg/info /var/log/apt /var/cache/apt/archives
touch /var/lib/dpkg/status /var/lib/dpkg/available
ifconfig lo 127.0.0.1 up
ifconfig eth0 up
ip addr add 10.0.2.15/24 dev eth0
ip route add default via 10.0.2.2
echo "nameserver 8.8.8.8" > /etc/resolv.conf

while true
do
    /bin/getty -L tty1 115200 vt100
    sleep 1
done
EOF

chmod +x rootfs/init

cp /usr/bin/dpkg rootfs/bin/party
mkdir -p rootfs/lib/x86_64-linux-gnu rootfs/lib64
cp /lib/x86_64-linux-gnu/libmd.so.0 rootfs/lib/x86_64-linux-gnu/
cp /lib/x86_64-linux-gnu/libselinux.so.1 rootfs/lib/x86_64-linux-gnu/
cp /lib/x86_64-linux-gnu/libpcre2-8.so.0 rootfs/lib/x86_64-linux-gnu/
cp /lib/x86_64-linux-gnu/libc.so.6 rootfs/lib/x86_64-linux-gnu/
cp /lib/x86_64-linux-gnu/libcap.so.2 rootfs/lib/x86_64-linux-gnu/
cp /lib/x86_64-linux-gnu/libgpg-error.so.0 rootfs/lib/x86_64-linux-gnu/
cp /lib/x86_64-linux-gnu/libz.so.1 rootfs/lib/x86_64-linux-gnu/
cp /lib/x86_64-linux-gnu/liblzma.so.5 rootfs/lib/x86_64-linux-gnu/
cp /lib/x86_64-linux-gnu/libzstd.so.1 rootfs/lib/x86_64-linux-gnu/
cp /lib/x86_64-linux-gnu/libbz2.so.1.0 rootfs/lib/x86_64-linux-gnu/
cp /lib/x86_64-linux-gnu/libfuse3.so.* rootfs/lib/x86_64-linux-gnu/
cp /lib/x86_64-linux-gnu/libfuse.so.* rootfs/lib/x86_64-linux-gnu/
mkdir -p rootfs/usr/bin
cp /usr/bin/tar rootfs/usr/bin/
ln -sf /usr/bin/tar rootfs/bin/tar
cp /lib/x86_64-linux-gnu/libacl.so.1 rootfs/lib/x86_64-linux-gnu/
cp /lib64/ld-linux-x86-64.so.2 rootfs/lib64/

mkdir -p rootfs/usr/bin
cp /usr/bin/tar rootfs/usr/bin/
ln -sf /usr/bin/tar rootfs/bin/tar
cp /usr/bin/dpkg* rootfs/usr/bin/
rm -f rootfs/bin/dpkg
ln -sf /usr/bin/dpkg rootfs/bin/dpkg
mkdir -p rootfs/usr/share
cp -r /usr/share/dpkg rootfs/usr/share/
mkdir -p rootfs/var/lib/dpkg
chmod 777 rootfs/var/lib/dpkg
touch rootfs/var/lib/dpkg/status
touch rootfs/var/lib/dpkg/available
mkdir -p rootfs/var/lib/dpkg/updates
mkdir -p rootfs/var/lib/dpkg/info
chmod 777 rootfs/var/lib/dpkg/updates
chmod 777 rootfs/var/lib/dpkg/info

cat > rootfs/etc/os-release << EOF
NAME="FarewellOS"
ID=farewell
VERSION="1.0"
EOF
cp /lib/x86_64-linux-gnu/libmd.so.0 rootfs/lib/x86_64-linux-gnu/
cp /lib/x86_64-linux-gnu/libselinux.so.1 rootfs/lib/x86_64-linux-gnu/
cp /lib/x86_64-linux-gnu/libpcre2-8.so.0 rootfs/lib/x86_64-linux-gnu/
cp /lib/x86_64-linux-gnu/libc.so.6 rootfs/lib/x86_64-linux-gnu/
cp /lib/x86_64-linux-gnu/libcap.so.2 rootfs/lib/x86_64-linux-gnu/
cp /lib/x86_64-linux-gnu/libgpg-error.so.0 rootfs/lib/x86_64-linux-gnu/
cp /lib64/ld-linux-x86-64.so.2 rootfs/lib64/

ar x fuse3_3.10.5-1build1_amd64.deb
zstd -d data.tar.zst -o data.tar.fuse
tar -xf data.tar.fuse ./bin/fusermount3 ./sbin/mount.fuse3
cp bin/fusermount3 rootfs/bin/
cp sbin/mount.fuse3 rootfs/sbin/ 2>/dev/null || cp sbin/mount.fuse3 rootfs/bin/
rm -rf bin sbin data.tar.fuse control.tar.zst debian-binary data.tar.zst
mkdir -p rootfs/sbin
ln -sf busybox rootfs/sbin/ldconfig

cp fuse rootfs/bin/
cd rootfs
find . | cpio -o -H newc | gzip > ../osboot/multi.gz

cd ..

rm -rf rootfs
