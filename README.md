# SISOP-5-2026-IT-035

**Dikerjakan oleh: Dea Chrisna Butarbutar - 5027251035**

## Reporting

### Soal 1
**Farewell Party**

#### Penjelasan
1. Membuat file dengan struktur yang sudah ditentukan dalam soal.
```
$ mkdir soal_1
$ cd soal_1
$ touch .config backup.sh iso.sh kernel.sh multi.sh qemu.sh single.sh
$ mkdir osboot 
```
Sehingga struktur menjadi seperti ini:
<img width="802" height="263" alt="image" src="https://github.com/user-attachments/assets/4eca26ef-78c5-43a6-a661-28ed3a023801" />

2. Melengkapi script kernel.sh untuk mendownload linux kernel 6.1.1 dan outputnya diarahkan ke `osboot/bzImage`.

```
#!/bin/bash

wget https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.1.1.tar.xz

tar -xvf linux-6.1.1.tar.xz

cd linux-6.1.1

make tinyconfig
make menuconfig

make -j$(nproc)

cp arch/x86/boot/bzImage ../osboot/
```
Pertama, perintah `wget` digunakan untuk mengunduh kode sumber kernel Linux versi 6.1.1. Setelah diunduh, kemudian akan diekstrak ke dalam direktori linux-6.1.1. Untuk melakukan konfigurasi sebelum melakukan kompilasi, digunakan `make tinyconfig` dan `make menuconfig` untuk mengaktifkan fitur yang diperlukan oleh sistem operasi yang akan dibuat. Setelah dikonfigurasi, selanjutnya adalah melakukan kompilasi kernel yang menghasilkan output file `bzImage`, yaitu file kernel yang siap untuk booting. Setelah selesai dikompilasi, maka file `bzImage` ada di direktori `arch/x86/boot/bzImage` yang disalin ke dalam folder `/osboot/`.

3. Membuat single filesystem pada `single.sh` dan menggunakan BusyBox untuk membuat kerangka awal filesystem dan shell environment. Hasil dari build dimasukkan ke direktori `osboot/single.gz`. File sisa hasil dari build dihapus.

```
mkdir -p rootfs/{bin,dev,proc,sys,etc,tmp,root}
```
Perintah ini digunakna untuk membuat direktori `rootfs` dengan sub-direktori `bin/`, `dev/`, `proc/`, `sys/`, `etc/`, `tmp/`, dan `root/` untuk sistem file.

```
cp -a /dev/null rootfs/dev
cp -a /dev/tty* rootfs/dev
cp -a /dev/zero rootfs/dev
cp -a /dev/console rootfs/dev
```
Kemudian, direktori `dev/` yang berisi file `null`, `tty`, `zero`, dan `console` disalin dari sistem host ke dalam direktori `dev/` di `rootfs`.

```
mknod -m 666 rootfs/dev/fuse c 10 229
```
Lalu, untuk keperluan menginstal fuse3, digunakanlah perintah ini untuk membuat device file fuse di direktori `dev/` (root filesystem). 

```
cp /usr/bin/busybox rootfs/bin
cd rootfs/bin
./busybox --install .
cd ../..
```
Selanjutnya, file Busybox disalin ke direktori `bin` yang telah dibuat di dalam `rootfs`. Lalu BusyBox pun diinstall. Maka, perintah seperti `ls`, `cp` `mv`, `mount` akan ditambahkan ke dalam direktori `bin`.

```
echo "root:x:0:0:root:/root:/bin/sh" > rootfs/etc/passwd
echo "root:x:0:" > rootfs/etc/group
echo "check_certificate = off" > rootfs/etc/wgetrc
```
Perintah ini membuat user bernama `root` dengan akses ke manapun. Lalu membuat grup root ysng berisi user root saja. Kemudian perintah terakhir menonaktifkan pemeriksaan sertifikat SSL saat pengunduhan file.

```
cat > rootfs/init << 'EOF'
#!/bin/sh
/bin/mount -t proc none /proc
/bin/mount -t sysfs none /sys
/bin/mount -t devpts devpts /dev/pts
/bin/mount -t tmpfs tmpfs /var
mkdir -p /var/lib/dpkg/updates /var/lib/dpkg/info /var/log/apt /var/cache/apt/archives
touch /var/lib/dpkg/status /var/lib/dpkg/available
echo "Init started"
ifconfig lo 127.0.0.1 up
ifconfig eth0 up
ip addr add 10.0.2.15/24 dev eth0
ip route add default via 10.0.2.2
echo "nameserver 8.8.8.8" > /etc/resolv.conf

exec /bin/sh
EOF
```
Di direktori `rootfs`, file init dibuat dan akan dijalankan pertama kali ketika booting. File ini akan melakukan mounting untuk `proc`, `sysfs`, `devpts` yang digunakan untuk komunikasi antara sistem dengan kernel. Mount `tmpfs`  di direktori `/var` untuk membuat filesystem sementara di RAM. 
Selanjutnya adalah membuat direktori package manager untuk `dpkg` dan `apt`.
Kemudian untuk menjalankan akses internet, maka dilakukan konfigurasi jaringan yang dijalan ketika sistem operasi selesai booting. Interfase loopback diaktifkan dengan alamat `127.0.0.1` kemudian interface jaringan utamanya `eth0` diaktifkan dan diberikan alamat IP `10.0.2.15/24`. File `resolv.conf` berisi server `8.8.8.8`. 

```
chmod +x rootfs/init
```
Kemudian, agar file `init` dapat dijalankan, maka dilakuukanlah izin eksekusi dengan chmod.

```
cp /usr/bin/dpkg rootfs/bin/party
mkdir -p rootfs/lib/x86_64-linux-gnu rootfs/lib64
```
Perintah di atas adalah untuk menambah package manager `dpkg` dengan menyalin `dpkg` ke rootfs dengan nama `party`. Kemudian, direktori untuk library dibuat untuk lokasi penyimpanan shared library.

```
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
```
Library di atas adalah library yang disalin agar package manager dapat berjalan nantinya.

```
mkdir -p rootfs/usr/bin
cp /usr/bin/tar rootfs/usr/bin/
ln -sf /usr/bin/tar rootfs/bin/tar
cp /lib/x86_64-linux-gnu/libacl.so.1 rootfs/lib/x86_64-linux-gnu/
cp /lib64/ld-linux-x86-64.so.2 rootfs/lib64/
```
Kemudian, tar ditambahkan untuk menyalin program yang digunakan untuk mengekstrak arsip. Symnlink dibuat agar user dapat menjalankan `tar` tanpa path lengkap.

```
cp /usr/bin/dpkg* rootfs/usr/bin/
rm -f rootfs/bin/dpkg
ln -sf /usr/bin/dpkg rootfs/bin/dpkg
```
Perintah ini untuk memasang package manager ke dalam root filesystem dan membuatnya dapat dipanggil dengan perintah `dpkg` dari shell. Kemudian, file symlink `dpkg` yang lama dihapus dan membuat symlink baru untuk membersihkan kemungkinan file/symlink lama di `/bin/dpkg`.

```
mkdir -p rootfs/usr/share
cp -r /usr/share/dpkg rootfs/usr/share/
```
Perintah ini kemudian digunakan untuk menyalin data pendukung yang dibutuhkan `dpkg`. 
Kemudian, seluruh isi direktori `dpkg` disalin ke `rootfs`.

```
mkdir -p rootfs/var/lib/dpkg
chmod 777 rootfs/var/lib/dpkg
touch rootfs/var/lib/dpkg/status
touch rootfs/var/lib/dpkg/available
mkdir -p rootfs/var/lib/dpkg/updates
mkdir -p rootfs/var/lib/dpkg/info
chmod 777 rootfs/var/lib/dpkg/updates
chmod 777 rootfs/var/lib/dpkg/info
mkdir -p rootfs/var/log/apt
```
Kode di atas adalah untuk menyiapkan struktur database di dalam root filesystem. 
Pertama adalah membuat direktori utama database `dpkg` sebagai package manager. Kemudian hak aksesnya diberikan kepada semua user.
Untuk file `status` digunakan untuk daftar paket yang terunduh. 
File `available` digunakan untuk menyimpan informasi paket yang terunduh.
Direktori `updates` untuk menyimpan update sementara terhadap database dengan bebas akses.
Direktori `info` digunakan untuk metadata paket.
Direktori `log/apt` untuk menyimpan log aktivitas package manager.

```
wget http://archive.ubuntu.com/ubuntu/pool/main/f/fuse3/fuse3_3.10.5-1build1_amd64.deb
ar x fuse3_3.10.5-1build1_amd64.deb
zstd -d data.tar.zst -o data.tar.fuse
tar -xf data.tar.fuse ./bin/fusermount3 ./sbin/mount.fuse3
cp bin/fusermount3 rootfs/bin/
cp sbin/mount.fuse3 rootfs/sbin/ 2>/dev/null || cp sbin/mount.fuse3 rootfs/bin/
rm -rf bin sbin data.tar.fuse control.tar.zst debian-binary data.tar.zst
mkdir -p rootfs/sbin
ln -sf busybox rootfs/sbin/ldconfig
```
Untuk fuse sendiri, diunduh pada perintah di atas. Paket kemudian diekstrak dan dibuat menjadi fuse yang berisi file asli paket. Kemudian `fusermount3` disalin ke `rootfs` dan menempatkan file executable ke dalam sistem operasi ini.
Kemudian file hasil ekstraksi dihapus. Untuk `ldconfig` sendiri adalah symlink untuk memperbarui cache shared library sehingga dapat menjaga kesesuaian sistem dengan program yang memanggil perintah tersebut.

```
cp fuse rootfs/bin/
cd rootfs
find . | cpio -o -H newc | gzip > ../osboot/single.gz

cd ..

rm -rf rootfs
```
Setelah proses selesai, maka executable file fuse disalin ke dalam direktori bin. Setelah itu masuk ke direktori rootfs, kemudian mengumpulkan file-file tersebut menggunakan perintah `cpio` dan mengompresnya dengan `gzip` untuk membuat image single sehingga menghasilkan file `single.gz` yang berisi file untuk booting. File hasil build kemudian dihapus.

4. Membuat multi filesystem pada file `multi.sh` dan menggunakan BusyBox.

```
mkdir -p rootfs/{bin,dev,proc,sys,etc,tmp,root,home/henn,home/hann,home/viii,home/kids}
```
Perintah ini digunakna untuk membuat direktori `rootfs` dengan sub-direktori `bin/`, `dev/`, `proc/`, `sys/`, `etc/`, `tmp/`, `root/`, `home/henn`, `home/hann`, `home/viii`, `home/kids` untuk sistem file.

```
cp -a /dev/null rootfs/dev
cp -a /dev/tty* rootfs/dev
cp -a /dev/zero rootfs/dev
cp -a /dev/console rootfs/dev
```
Kemudian, direktori `dev/` yang berisi file `null`, `tty`, `zero`, dan `console` disalin dari sistem host ke dalam direktori `dev/` di `rootfs`.

```
mknod -m 666 rootfs/dev/fuse c 10 229
```
Lalu, untuk keperluan menginstal fuse3, digunakanlah perintah ini untuk membuat device file fuse di direktori `dev/` (root filesystem). 

```
cp /usr/bin/busybox rootfs/bin
cd rootfs/bin
./busybox --install .
cd ../..
```
Selanjutnya, file Busybox disalin ke direktori `bin` yang telah dibuat di dalam `rootfs`. Lalu BusyBox pun diinstall. Maka, perintah seperti `ls`, `cp` `mv`, `mount` akan ditambahkan ke dalam direktori `bin`.

```
ROOTPASS=$(openssl passwd -1 root123)
HENNPASS=$(openssl passwd -1 henn123)
HANNPASS=$(openssl passwd -1 hann123)
VIIIPASS=$(openssl passwd -1 viii123)
KIDSPASS=$(openssl passwd -1 kids123)
```
Untuk membuat password user yang dienkripsi digunakan perintah `openssl` untuk masing-masing password user yang sesuai ketentuan pada soal.

```
cat > rootfs/etc/passwd << EOF
root:$ROOTPASS:0:0:root:/root:/bin/sh
henn:$HENNPASS:1001:100:henn:/home/henn:/bin/sh
hann:$HANNPASS:1002:101:hann:/home/hann:/bin/sh
viii:$VIIIPASS:1003:103:viii:/home/viii:/bin/sh
kids:$KIDSPASS:1004:102:kids:/home/kids:/bin/sh
EOF
```
Perintah di atas adalah membuat file `passwd` di direktori `etc` untuk menyimpan informasi tentang akun root dan user lainnya. 
Pada root:
`root:$ROOTPASS:0:0:root:/root:/bin/sh`
Username: `root`
Password: `$ROOTPASS` yang dienkripsi sebelumnya
UID: 0 (Root memiliki akses penuh)
GID: 0 (Root tidak masuk ke grup manapun)
Home: `/root`
Shell: `/bin/sh`

```
cat > rootfs/etc/group << EOF
root:x:0:
henn:x:100:henn
hann:x:101:hann
viii:x:103:viii
kids:x:102:hann,viii,kids
EOF
```
Selanjutnya, membuat file `/group` di direktori `/etc` yang berisi pengaturan grup untuk user yang dibuat pada filesystem ini.
Untuk user root:
` root:x:0:`
Nama grup: `root`
GID: 0
`root` digunakan oleh administrator sistem.

```
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
```
Di atas adalah tampilan untuk saat login ke setiap user.

```
chown -R 0:0 rootfs/root
chown -R 1001:100 rootfs/home/henn
chown -R 1002:101 rootfs/home/hann
chown -R 1003:101 rootfs/home/viii
chown -R 1004:102 rootfs/home/kids
```
Perintah di atas adalah untuk mengatur kepemilikan folder dari setiap user dan hak akses. Misalnya pada user `henn`, `henn` dimiliki oleh user dengan UID 1001 yaitu `henn` dan GID 100 yang anggotanya hanya `henn`. Untuk user `hann` dan `viii` berada dalam satu grup yang sama dengan GID 101. 

```
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
```
Di direktori `rootfs`, file init dibuat dan akan dijalankan pertama kali ketika booting. File ini akan melakukan mounting untuk `proc`, `sysfs`, `devpts` yang digunakan untuk komunikasi antara sistem dengan kernel. Mount `tmpfs`  di direktori `/var` untuk membuat filesystem sementara di RAM. 
Selanjutnya adalah membuat direktori package manager untuk `dpkg` dan `apt`.
Kemudian untuk menjalankan akses internet, maka dilakukan konfigurasi jaringan yang dijalan ketika sistem operasi selesai booting. Interfase loopback diaktifkan dengan alamat `127.0.0.1` kemudian interface jaringan utamanya `eth0` diaktifkan dan diberikan alamat IP `10.0.2.15/24`. File `resolv.conf` berisi server `8.8.8.8`. 

```
while true
do
    /bin/getty -L tty1 115200 vt100
    sleep 1
done
EOF
```
Perintah ini akan menunggu input login dari user melalui konsol agar bisa login sesuai user dan password masing-masing.

```
chmod +x rootfs/init
```
Kemudian, agar file `init` dapat dijalankan, maka dilakuukanlah izin eksekusi dengan chmod.

```
cp /usr/bin/dpkg rootfs/bin/party
mkdir -p rootfs/lib/x86_64-linux-gnu rootfs/lib64
```
Perintah di atas adalah untuk menambah package manager `dpkg` dengan menyalin `dpkg` ke rootfs dengan nama `party`. Kemudian, direktori untuk library dibuat untuk lokasi penyimpanan shared library.

```
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
cp /lib/x86_64-linux-gnu/libacl.so.1 rootfs/lib/x86_64-linux-gnu/
cp /lib64/ld-linux-x86-64.so.2 rootfs/lib64/
```
Library di atas adalah library yang disalin agar package manager dapat berjalan nantinya.

```
mkdir -p rootfs/usr/bin
cp /usr/bin/tar rootfs/usr/bin/
ln -sf /usr/bin/tar rootfs/bin/tar
```
Kemudian, tar ditambahkan untuk menyalin program yang digunakan untuk mengekstrak arsip. Symnlink dibuat agar user dapat menjalankan `tar` tanpa path lengkap.

```
cp /usr/bin/dpkg* rootfs/usr/bin/
rm -f rootfs/bin/dpkg
ln -sf /usr/bin/dpkg rootfs/bin/dpkg
```
Perintah ini untuk memasang package manager ke dalam root filesystem dan membuatnya dapat dipanggil dengan perintah `dpkg` dari shell. Kemudian, file symlink `dpkg` yang lama dihapus dan membuat symlink baru untuk membersihkan kemungkinan file/symlink lama di `/bin/dpkg`.

```
mkdir -p rootfs/usr/share
cp -r /usr/share/dpkg rootfs/usr/share/
```
Perintah ini kemudian digunakan untuk menyalin data pendukung yang dibutuhkan `dpkg`. 
Kemudian, seluruh isi direktori `dpkg` disalin ke `rootfs`.

```
mkdir -p rootfs/var/lib/dpkg
chmod 777 rootfs/var/lib/dpkg
touch rootfs/var/lib/dpkg/status
touch rootfs/var/lib/dpkg/available
mkdir -p rootfs/var/lib/dpkg/updates
mkdir -p rootfs/var/lib/dpkg/info
chmod 777 rootfs/var/lib/dpkg/updates
chmod 777 rootfs/var/lib/dpkg/info
mkdir -p rootfs/var/log/apt
```
Kode di atas adalah untuk menyiapkan struktur database di dalam root filesystem. 
Pertama adalah membuat direktori utama database `dpkg` sebagai package manager. Kemudian hak aksesnya diberikan kepada semua user.
Untuk file `status` digunakan untuk daftar paket yang terunduh. 
File `available` digunakan untuk menyimpan informasi paket yang terunduh.
Direktori `updates` untuk menyimpan update sementara terhadap database dengan bebas akses.
Direktori `info` digunakan untuk metadata paket.
Direktori `log/apt` untuk menyimpan log aktivitas package manager.

```
wget http://archive.ubuntu.com/ubuntu/pool/main/f/fuse3/fuse3_3.10.5-1build1_amd64.deb
ar x fuse3_3.10.5-1build1_amd64.deb
zstd -d data.tar.zst -o data.tar.fuse
tar -xf data.tar.fuse ./bin/fusermount3 ./sbin/mount.fuse3
cp bin/fusermount3 rootfs/bin/
cp sbin/mount.fuse3 rootfs/sbin/ 2>/dev/null || cp sbin/mount.fuse3 rootfs/bin/
rm -rf bin sbin data.tar.fuse control.tar.zst debian-binary data.tar.zst
mkdir -p rootfs/sbin
ln -sf busybox rootfs/sbin/ldconfig
```
Untuk fuse sendiri, diunduh pada perintah di atas. Paket kemudian diekstrak dan dibuat menjadi fuse yang berisi file asli paket. Kemudian `fusermount3` disalin ke `rootfs` dan menempatkan file executable ke dalam sistem operasi ini.
Kemudian file hasil ekstraksi dihapus. Untuk `ldconfig` sendiri adalah symlink untuk memperbarui cache shared library sehingga dapat menjaga kesesuaian sistem dengan program yang memanggil perintah tersebut.

```
cp fuse rootfs/bin/
cd rootfs
find . | cpio -o -H newc | gzip > ../osboot/single.gz

cd ..

rm -rf rootfs
```
Setelah proses selesai, maka executable file fuse disalin ke dalam direktori bin. Setelah itu masuk ke direktori rootfs, kemudian mengumpulkan file-file tersebut menggunakan perintah `cpio` dan mengompresnya dengan `gzip` untuk membuat image single sehingga menghasilkan file `single.gz` yang berisi file untuk booting. File hasil build kemudian dihapus.

5. Membuat ISO bootable dengan file `iso.sh` yang dapat melakukan load kedua filesystem yaitu single dan multi filesystem user. Outputnya ada pada `osboot/farewell.iso`

```
#!/bin/sh

cd osboot

mkdir -p isodir/boot/grub
```
Pertama, masuk ke direktori `osboot`, kemudian membuat struktur direktori ISO

```
cp bzImage isodir/boot
cp single.gz isodir/boot
cp multi.gz isodir/boot
```
Kemudian, file kernel, root single maupun multi filesystem disalin.

```
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
```
Pada perintah di atas, file konfigurasi `grub.cfg` dibuat dan file akan membuat menu GRUB yang menampilkan pilihan boot bernama "Farewell OS Single User" dan "Farewell OS Multi User", kemudian mengarahkan sistem untuk menggunakan kernel dan initrd yang sudah diberikan.

```
grub-mkrescue -o farewell.iso isodir
rm -rf isodir
```
Perintah di atas untuk membuat file ISO bootable dari folder `isodir` dan outputnya adalah file `farewell.iso`. File inilah yang akan digunakan untuk boot langsung sebagai sistem operasi.
Setelah ISO sudah siap, folder `isodir` dihapus.

6. Membuat file `qemu.sh` untuk booting OS yang dibuat.

```
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
```
Perintah di atas adalah untuk menjalankan Farewell OS dengan kondisi (case) argumen `--single`, `--multi`, dan `--all`. 
Setelah membaca argumen antara ketiganya, selanjutnya masuk ke direktori tempat menyimpan file hasil build yaitu `osboot/`. Kemudian, perintah-perintah di bawahnya akan digunakan untuk menjalankan QEMU dengan konfigurasi tertentu.
Alokasi memori yang diberikan adalah sebesar 512 MB, menampilkan output dalam mode teks, kernel yang digunakan untuk booting adalah `bzImage`, kemudian `initrd` untuk menentukan root filesystem yang akan dimuat.
Untuk argumen `--all` akan memilih akan booting ke single atau multi filesystem.

```
  *)
  echo "Usage: $0 --single / --multi / --all"
  exit 1
  ;;
esac
```
Perintah di atas adalah kondisi ketika argumen tidak memenuhi ketiga argumen tadi, maka akan menampilkan penggunaan yang benar agar dapat melakukan booting.

7. Membuat file untuk backup untuk menyimpan semua file `bzImage`, `single.gz`, `multi.gz`, dan `firewall.iso`. Hasilnya disimpan di direktori `osboot/`.

```
#!/bin/bash
TIMESTAMP=$(date +%d%m%Y-%H%M%S)
BACKUP="osboot/farewell_backup_[${TIMESTAMP}].zip"
zip "$BACKUP" osboot/bzImage osboot/single.gz osboot/multi.gz osboot/farewell.iso
rm -f osboot/bzImage osboot/single.gz osboot/multi.gz osboot/farewell.iso
```
Untuk nama file zipnya adalah `farewell_backup_[DDMMYYYY-HHMMSS].zip` dengan timestamp menggunakan waktu saat itu. Kemudian, file tersebut disimpan dalam bentuk zip. Setelah berhasil melakukan backup, file aslinya dihapus.

### OUTPUT
1. Menjalankan `kernel.sh`
<img width="901" height="249" alt="image" src="https://github.com/user-attachments/assets/28c2c341-2301-4406-b73e-f990fe36d9fc" />

2. Melakukan config
<img width="913" height="897" alt="image" src="https://github.com/user-attachments/assets/c343b9b0-e27a-4cc0-9b9d-a300074e074a" />

3. Tampilan ketika sudah selesai:
<img width="904" height="104" alt="image" src="https://github.com/user-attachments/assets/17086f94-00bc-47ca-91c0-cafe6bd7c19d" />

4. Menjalankan `single.sh`
<img width="901" height="426" alt="image" src="https://github.com/user-attachments/assets/9042f9a3-2001-4e56-9e30-db5bfabe8cd2" />

5. Menjalankan `multi.sh`
<img width="910" height="126" alt="image" src="https://github.com/user-attachments/assets/b54eaa4a-9f8d-464e-8e8c-4c804b090a7a" />

6. Menjalankan `iso.sh`
<img width="899" height="406" alt="image" src="https://github.com/user-attachments/assets/d754e2b6-0d42-452e-8463-eb78f1b90d90" />

7. Menjalankan `./qemu.sh --single`
<img width="861" height="285" alt="image" src="https://github.com/user-attachments/assets/15d17eb8-f3b2-44da-b4b6-ba2ea11b3ca6" />

- Membuka `/bin`
<img width="726" height="598" alt="image" src="https://github.com/user-attachments/assets/7d388adc-5056-4bcc-948b-bc8f73ebf051" />

- Membuka `/dev`
<img width="790" height="394" alt="image" src="https://github.com/user-attachments/assets/a1a90f12-8899-42bc-abad-663b1dc60585" />

- Membuka `/proc`
<img width="794" height="355" alt="image" src="https://github.com/user-attachments/assets/4560db4e-23b6-4113-8405-b031e751accd" />

- Membuka `/sys`, `etc`, `/tmp`, dan `/root`
<img width="797" height="226" alt="image" src="https://github.com/user-attachments/assets/5556e2ed-a0a4-4ab3-bf55-ec6bd8ba206d" />

7. Menjalankan `./qemu.sh --multi`
- Login sebagai `root`
<img width="748" height="570" alt="image" src="https://github.com/user-attachments/assets/ed151d4a-5ebb-458d-97a5-aeb06080d9f3" />
 
- Masuk ke direktori lain (root bisa akses apapun)
<img width="822" height="71" alt="image" src="https://github.com/user-attachments/assets/3b72147f-d520-4533-baf2-966f0a25d1f6" />

- Login user `henn`
<img width="766" height="611" alt="image" src="https://github.com/user-attachments/assets/1b354586-591a-4273-a950-f942775985b4" />

Membuka direktori lain yaitu /home/* dan /kids
<img width="600" height="245" alt="image" src="https://github.com/user-attachments/assets/7877a097-ba67-4f90-80fd-4553f03b3c1f" />
Untuk output ini, belum sesuai dengan soal. Yang sesuai hanya ketika user `henn` tidak dapat mengakses `/root`.

- Login user `hann`
<img width="791" height="597" alt="image" src="https://github.com/user-attachments/assets/5a2b5f93-abe2-40ea-99c8-18c997edfe62" />

User `hann` dapat mengakses ke `/home/{hann,viii,kids}` dan tidak bisa ke `/root` dan `/home/henn`
<img width="698" height="416" alt="image" src="https://github.com/user-attachments/assets/e160728f-1d25-46d2-aa65-cca4fdde512b" />

- Login user `viii`
<img width="763" height="587" alt="image" src="https://github.com/user-attachments/assets/61e0a2a7-aeb6-41d2-b969-098e9ae0ada4" />

User `viii` dapat mengakses ke `/home/{viii,kids}` dan tidak bisa ke `/root` dan `/home/{henn,hann}`
<img width="566" height="374" alt="image" src="https://github.com/user-attachments/assets/b8ed0dec-a746-4d88-82d1-07b84095c3e9" />

- Login user `kids`
<img width="789" height="584" alt="image" src="https://github.com/user-attachments/assets/e7ec89f1-132c-4fef-8836-ca30d4a9f3cc" />

User kids dapat mengakses ke /home/kids dan tidak bisa ke /root dan /home/{henn,hann,viii}
<img width="670" height="350" alt="image" src="https://github.com/user-attachments/assets/6993d0dc-3d61-44fa-a809-ee934145b20a" />

8. Test akses internet
<img width="870" height="603" alt="image" src="https://github.com/user-attachments/assets/40dc37f2-bc20-4ca9-b1b0-a8eacb4c937a" />
Pada hasil ini, OS bisa mendownload tetapi ketika menjalankan `ping 8.8.8.8`, tampilan terus seperti di screenshot.

9. Menjalankan `backup.sh`
<img width="902" height="140" alt="image" src="https://github.com/user-attachments/assets/b08ca69f-7010-43c9-bcf5-b634041f241f" />

Hasil backup akan berada di direktori `osboot`:
<img width="910" height="79" alt="image" src="https://github.com/user-attachments/assets/8217d63c-f3ff-4249-8797-c0e0286cfce0" />

#### Kendala
Belum bisa menjalankan program fuse.

### Soal 2
**Season**

#### Penjelasan
Download template zip yang diberikan pada soal dan unzip agar sesuai dengan struktur soal.
`$ gdown 14rOog6VbT6sxjp3s_GJoTW7hgE6FAtmo -O template.zip`

1. Melengkapi `kernel.asm` dan mengisi fungsi `_getChar`.

```
_getChar:
    push bp
    mov bp, sp

    mov ah, 0x00
    int 0x16

    mov ah, 0

    pop bp
    ret
```
Pada kode assembly di atas, berfungsi untuk menunggu user menginput command dan mengambil karakter dari command tersebut. Pertama, fungsi menyimpan kondisi program dengan `push bp`, `mov bp sp`. Lalu fungsi dengan BIOS menunggu dan membaca input user melalui perintah `int 0x16`. Setelah command dimasukkan, BIOS akan memberikan informasi karakter dan kode fisik tombolnya, lalu baris `mov ah, 0` membuang kode fisik tadi agar yang tersisa hanya karakternya saja. Kemudian, kondisi program dikembalikan dengan `pop bp` dan mengirim karakter hasil bacaan ke bagian program yang memanggilnya.

2. Melengkapi file `kernel.c` untuk membuat instruksi check dan mengaplikasikan fitur yang ada pada template.

Untuk instruksi check, ketika command dari user adalah `check`, maka output yang diberikan adalah `ok`.
```
if (strcmp(cmd, "check")) {
            printString("ok");
```

Fungsi `newline()`:

```
void newline() {
    int column = cursor;
    while (column >= 80) column -= 80;
    cursor = cursor + (80 - column);
}
```
Fungsi ini adalah untuk membuat newline, yaitu memindahkan kursor ke baris berikutnya. Ketika nilai `column >= 80`, maka nilai column akan dikurangi sampai kurang dari 80 untuk mencari tahu kursor sedang berada di kolom berapa. Setelah posisi kolom diketahui, selanjutnya dihitung berapa langkah yang dibutuhkan ke awal baris berikutnya.

Fungsi `readString()`:

```
void readString(char *buffer) {
    int i = 0;
    char c;
    while (1) {
        c = getChar();
        if (c == '\r') {
            buffer[i] = '\0';
            break;
        }
        else if (c == '\b' && i > 0) {
         i--;
         cursor--;
         putInMemory(0xB800, cursor * 2, ' ');
       }
       else
       {
         buffer[i] = c;
         printChar(c);
         i++;
       }
    }
}
```
Fungsi ini untuk membaca input user karakter per karakter sampai Enter. Pada perulangan while, memanggil `getChar()` untuk menunggu dan mengambil satu karakter yang ditekan user. Jika yang ditekan adalah `\r` (Enter), maka string ditutup dengan `\0` dan loop berhenti. 

Fungsi `strcmp()`
```
int strcmp(char *str1, char *str2) {
    int i = 0;
    while (str1[i] != '\0' && str2[i] != '\0') {
       if (str1[i] != str2[i]) return 0;
       i++;
    }
    return str1[i] == '\0' && str2[i] == '\0';
}
```
Fungsi ini untuk membandingkan dua string apakah isinya sama atau tidak. Perulangan tersebut akan memeriksa karakter satu per satu. 

Fungsi `startsWith()`
```
int startsWith(char *str, char *prefix) {
    int i = 0;
    while (prefix[i] != '\0') {
       if (str[i] != prefix[i]) return 0;
       i++;
    }
    return 1;
}
```
Fungsi ini akan mengecek apakah sebuah string diawali kata tertentu yang diperlukan. Perulangan ini akan membandingkan karakter dari prefix satu per satu dengan string utama, jika ada yang tidak cocok return 0. 

Fungsi `atoi()`
```
int atoi(char *str) {
    int result = 0;
    int i = 0;
    int neg = 0;
    if (str[0] == '-') {
        neg = 1;
        i = 1;
    }
    while (str[i] >= '0' && str[i] <= '9') {
       result = result * 10 + (str[i] - '0');
       i++;
    }
    if (neg) return -result;
    return result;
}
```
Fungsi atoi adalah untuk mengubah string angka menjadi bilangan bulat integer. Pertama akan dicek apakah ada tanda minus di depan, jika ada maka variabel neg = 1 dan akan dibaca dari karakter keduanya. Kemudian, setiap karakter angka dikonversi dengan mengalikan angka sebelumnya dengan 10 lalu digit baru akan ditambahkan di belakangnya.

Fungsi `intToString()`
```
void intToString(int n, char *buffer) {
   int i = 0;
   int j = 0;
   int neg = 0;
   int digit;
   int q;
   char temp[16];
   if (n == 0) {
      buffer[0] = '0';
      buffer[1] = '\0';
      return;
   }
   if (n < 0) {
      neg = 1;
      n = -n;
   }
   while (n > 0) {
      digit = n;
      q = 0;
      while (digit >= 10) {
        digit -= 10;
        q++;
      }
      temp[i++] = '0' + digit;
      n = q;
   }
   if (neg) buffer[j++] = '-';
   while (i > 0) buffer[j++] = temp[--i];
   buffer[j] = '\0';
}
```
Fungsi ini mengubah integer menjadi string kembali. Jika angkanya 0 maka akan langsung 0. Jika negatif maka tandanya disimpan lalu digit dibaca satu per satu dari belakang untuk disimpan ke array `temp`. Kemudian, di akhir array `temp` tersebut dibaca dari belakang ke depan karena urutan penyimpanannya dari belakang, sehingga urutan angkanya akan sesuai.

3. Menambahkan fitur `add` untuk fitur pertambahan pada sistem operasi.

```
else if (startsWith(cmd, "add ")) {
            i = 4;
            j = 0;
            while (cmd[i] != ' ' && j < 15) {
                a[j++] = cmd[i++];
            }
            a[j] = '\0';
            i++;
            j = 0;
            while (cmd[i] != '\0') {
                b[j++] = cmd[i++];
            }
            b[j] = '\0';
            result = atoi(a) + atoi(b);
            intToString(result, buffer);
            printString(buffer);
}
```
Kondisi ketika command user adalah `add ` dan memasukkan dua angka untuk dijumlahkan. Program akan membaca karakter setelah `add ` lalu melakukan perulangan `while (cmd[i] != ' ')` untuk membaca karakter satu per satu dan menyimpannya di array a sampai ketemu spasi sebagai angka pertama. Kemudian masuk ke loop kedua untuk membaca sisa karakter sampai akhir string dan menyimpannya ke array b sebagai angka kedua. Setelah keduanya dibaca, fungsi `atoi(a)` dan `atoi(b)` dipanggil ke variabel result agar hasilnya ditambahkan dengan bilangan bulat. Setelah itu, hasil penjumlahan diubah kembali menjadi string agar bisa ditampilkan ke user melalui `printString`. 

4. Menambahkan fitur `sub` untuk fitur pengurangan pada sistem operasi.

```
else if (startsWith(cmd, "sub ")) {
            i = 4;
            j = 0;
            while (cmd[i] != ' ' && j < 15) {
                 a[j++] = cmd[i++];
            }
            a[j] = '\0';
            i++;
            j = 0;

            while (cmd[i] != '\0') {
                b[j++] = cmd[i++];
            }
            b[j] = '\0';
            result = atoi(a) - atoi(b);
            intToString(result, buffer);
            printString(buffer);
}
```
Kondisi ketika command user adalah `sub ` dan memasukkan dua angka untuk dikurangkan. Program akan membaca karakter setelah `sub ` lalu melakukan perulangan `while (cmd[i] != ' ')` untuk membaca karakter satu per satu dan menyimpannya di array a sampai ketemu spasi sebagai angka pertama. Kemudian masuk ke loop kedua untuk membaca sisa karakter sampai akhir string dan menyimpannya ke array b sebagai angka kedua. Setelah keduanya dibaca, fungsi `atoi(a)` dan `atoi(b)` dipanggil ke variabel result agar hasil yang diubah menjadi bilangan bulat dapat dikurangkan. Setelah itu, hasil pengurangan diubah kembali menjadi string agar bisa ditampilkan ke user melalui `printString`. 

5. Menambahkan fitur factorial yaitu `fac` untuk mencari faktorial dari nilai yang diberikan dan memberikan batasan sampai 16-bit.

```
int factorial(int n) {
    int result = 1;
    int i;
    if (n == 0 || n == 1) return 1;
    for (i = 2; i <= n; i++) {
        result = result * i;
        if (result < 0) return -1;
    }
    return result;
}
```
Pertama, ada fungsi factorial untuk menghitung hasil faktorial dari angka inputan user (n). Jika `n = 0` atau `n = 1`, maka akan langsung menghasilkan angka 1. Jika tidak, maka perkalian dilakukan dari 2 sampai angka ke-n secara berurutan dan hasilnya disimpan di variabel `result`. Kemudian kondisi ketika `result < 0` adalah jika hasil perkalian sudah melebihi batas maksimum integer dan nilainya menjadi negatif, maka fungsi langsung mengembalikan -1.

```
else if (startsWith(cmd, "fac ")) {
            i = 4;
            j = 0;
            while (cmd[i] != '\0') n[j++] = cmd[i++];
            n[j] = '\0';
            result = factorial(atoi(n));
            if (result == -1) {
                printString("know your limit little bro.");
            } else {
                intToString(result, buffer);
                printString(buffer);
            }
}
```
Kemudian, perintah di sini membaca input user yaitu `fac ` dan angka yang akan difaktorialkan. Program membaca dari karakter ke 4 setelah spasi dan menyimpannya ke array `n` sebagai angka yang akan dihitung faktorialnya. Angka tersebut kemudian dikonversi dari string ke integer dengan memanggil fungsi `atoi(n)` lalu dimasukkan ke fungsi faktorial dan ke variabel `result`. Jika `result = -1`, maka akan menampilkan pesan. Jika tidak, maka hasilnya dikonversi kembali ke string untuk ditampilkan.

6. Menambahkan fitur tambahan `season` untuk memberikan warna dalam sistem: winter, spring, summer, fall, dan radiant.

```
else if (startsWith(cmd, "season ")) {
            i = 7;
            j = 0;
            while (cmd[i] != '\0') name[j++] = cmd[i++];
            name[j] = '\0';
            if (strcmp(name, "winter")) {
               color = 0x01; // blue
               printString("winter mode");
            } else if (strcmp(name, "spring")) {
               color = 0x02; // green
               printString("spring mode");
            } else if (strcmp(name, "summer")) {
               color = 0x0E; // yellow
               printString("summer mode");
            } else if (strcmp(name, "fall")) {
               color = 0x06; // orange/brown
               printString("fall mode");
            } else if (strcmp(name, "radiant")) {
               color = 0x0D; // pink
               printString("radiant mode");
            }
         }
```
Kondisi ketika command user adalah `season` untuk mengubah warna teks sesuai musim. Program akan membaca karakter ke-7 setelah `season ` termasuk spasi dan menyimpannya ke array `name` sebagai nama dari musim. Setelah itu, nama akan dibandingkan dengan `strcmp` sesuai nama season yang tersedia, jika sesuai maka variabel color diisi dengan kode warna dan menampilkan pesan mode yang aktif.

7. Menambahkan fitur `triangle` untuk mencetak segitiga sesuai baris angka yang diminta user.

```
else if (startsWith(cmd, "triangle ")) {
            i = 9;
            j = 0;
            while (cmd[i] != '\0') n[j++] = cmd[i++];
            n[j] = '\0';
            rows = atoi(n);
            for (r = 1; r <= rows; r++) {
               for (c = 0; c < r; c++) {
                  printChar('x');
               }
               newline();
            }
         }
```
Kondisi ketika command user adalah `triangle` maka program akan mencetak segitiga dari karakter `x` sesuai angka yang diinput user. Program akan membaca karakter ke-9 setelah command user, lalu menyimpannya ke array `n` sebagai angka dari jumlah baris yang diinginkan. Setelah itu dikonversi ke integer dengan `atoi(n)` dan disimpan ke variabel `rows`. Kemudian, dilakukan loop 2 dimensi, bagian luar berjalan dari 1 sampai variabel `rows` untuk setiap baris, sedangkan bagian dalam untuk mencetak karakter `x` sebanyak `r` kali di setiap barisnya. 

8. Menambahkan fitur `clear` untuk menghapus histori command dan fitur `help` untuk membantu user mengetahui command apa saja yang dapat digunakan. K

```
void clearScreen() {
    int i;
    for (i = 0; i < 2000; i++) {
        putInMemory(0xB800, i * 2, ' ');
        putInMemory(0xB800, i * 2 + 1, color);
    }
    cursor = 0;
}
```
Fungsi `clearScreen` untuk membersihkan seluruh layar. Perintah di dalamnya adalah menulis karakter spasi sebanyak 2000 kali langsung ke memory video dengan alamat `0xB800`, dengan `i * 2` untuk menyimpan karakter spasi dan `i * 2 + 1` untuk menyimpan warna yang sedang aktif. Setelah membersihkan layar, cursor kembali diletakkan di atas layar. 

```
else if (strcmp(cmd, "clear")) {
            clearScreen();
        }
```
Ini adalah kondisi ketika user memberikan command `clear` dan memanggil fungsi `clearScreen()`.

```
else if (strcmp(cmd, "help")) {
            printString("check add sub fac season triangle clear about");
        }
```
Kondisi ketika command user adalah `help`, maka akan mencetak command-command apa saja yang tersedia dan dapat dijalankan.

### OUTPUT
1. Make build
<img width="902" height="423" alt="image" src="https://github.com/user-attachments/assets/25331fc7-c05d-4c02-85aa-bcec97673b39" />

2. Make run
<img width="902" height="818" alt="image" src="https://github.com/user-attachments/assets/3a3a1a2b-e872-4486-8e09-25375a5bd6c5" />

Bochs akan muncul di atas terminal saat ini.
<img width="787" height="541" alt="image" src="https://github.com/user-attachments/assets/36fef3b8-5758-4687-9780-bed2bc649fb2" />

- Untuk command `help`:
<img width="781" height="536" alt="image" src="https://github.com/user-attachments/assets/221a2e6b-8e5a-41f7-b875-1641063c89f4" />

- Untuk command `check`, `add`, `sub`, dan `fac`:
<img width="787" height="539" alt="image" src="https://github.com/user-attachments/assets/65230131-17e2-4939-8e67-badd0ef859d1" />

- Untuk command `season`:
<img width="791" height="547" alt="image" src="https://github.com/user-attachments/assets/7ee25c2a-6862-4ad2-aef9-c6c7b81cce28" />

- Untuk command `triangle`:
<img width="774" height="550" alt="image" src="https://github.com/user-attachments/assets/a9cb4892-5c3d-4bd2-a840-3fe534cc128d" />

- Untuk command `clear`:
<img width="761" height="535" alt="image" src="https://github.com/user-attachments/assets/be5792c8-d3ab-4333-8df4-5f4ef2a3ad72" />
<img width="781" height="537" alt="image" src="https://github.com/user-attachments/assets/005a1563-d5e1-4815-804c-bb8d4afc1e19" />
