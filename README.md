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
