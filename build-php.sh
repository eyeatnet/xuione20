#!/bin/bash

echo -e "\n🔧 التحقق من إصدار النظام..."

# تحقق أن النظام هو Ubuntu 20.04 فقط
if grep -q "20.04" /etc/os-release; then
    echo "✅ النظام هو Ubuntu 20.04"
else
    echo "❌ هذا السكربت مخصص فقط لأوبنتو 20.04"
    exit 1
fi

echo -e "\n📦 تثبيت المتطلبات الأساسية..."
apt update
apt install -y \
    build-essential \
    libxml2-dev \
    libssl-dev \
    libcurl4-openssl-dev \
    libjpeg-dev \
    libpng-dev \
    libfreetype6-dev \
    libonig-dev \
    libzip-dev \
    libsqlite3-dev \
    libreadline-dev \
    libxslt1-dev \
    pkg-config \
    unzip \
    wget \
    tar \
    patch \
    chattr

# إنشاء مجلد العمل
mkdir -p /root/phpbuild/
cd /root/phpbuild/

echo -e "\n⬇️ تحميل PHP 7.4.33..."
wget --no-check-certificate https://www.php.net/distributions/php-7.4.33.tar.gz -O php-7.4.33.tar.gz
tar -xvf php-7.4.33.tar.gz
cd php-7.4.33

echo -e "\n📦 تحميل الباتش لدعم OpenSSL 3.0..."
wget --no-check-certificate "https://launchpad.net/~ondrej/+archive/ubuntu/php/+sourcefiles/php7.3/7.3.33-2+ubuntu22.04.1+deb.sury.org+1/php7.3_7.3.33-2+ubuntu22.04.1+deb.sury.org+1.debian.tar.xz" -O ../debian.tar.xz
tar -xf ../debian.tar.xz -C ..
patch -p1 < ../debian/patches/0060-Add-minimal-OpenSSL-3.0-patch.patch

echo -e "\n⚙️ تهيئة إعدادات البناء..."
./configure \
    --prefix=/home/xui/bin/php \
    --with-fpm-user=xui \
    --with-fpm-group=xui \
    --enable-gd \
    --with-jpeg \
    --with-freetype \
    --enable-static \
    --disable-shared \
    --enable-opcache \
    --enable-fpm \
    --without-sqlite3 \
    --without-pdo-sqlite \
    --enable-mysqlnd \
    --with-mysqli \
    --with-curl \
    --disable-cgi \
    --with-zlib \
    --enable-sockets \
    --with-openssl \
    --enable-shmop \
    --enable-sysvsem \
    --enable-sysvshm \
    --enable-sysvmsg \
    --enable-calendar \
    --disable-rpath \
    --enable-inline-optimization \
    --enable-pcntl \
    --enable-mbregex \
    --enable-exif \
    --enable-bcmath \
    --with-mhash \
    --with-gettext \
    --with-xmlrpc \
    --with-xsl \
    --with-libxml \
    --with-pdo-mysql

echo -e "\n🔨 بدء عملية البناء..."
make -j$(nproc) || { echo "❌ فشل في البناء"; exit 1; }

echo -e "\n🧹 إيقاف أي عملية PHP قديمة..."
killall php php-fpm 2>/dev/null

echo -e "\n📥 تثبيت PHP..."
make install

echo -e "\n🧹 تنظيف الملفات المؤقتة..."
cd /root
rm -rf /root/phpbuild/

echo -e "\n🔐 حماية الملفات النهائية..."
chattr +i /home/xui/bin/php/sbin/php-fpm
chattr +i /home/xui/bin/php/bin/php

echo -e "\n✅ تم بناء PHP 7.4.33 وتثبيته بنجاح في /home/xui/bin/php"
