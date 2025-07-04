#!/bin/bash

# تأكد أنك root
if [ "$EUID" -ne 0 ]; then
  echo "❌ يرجى تشغيل السكربت باستخدام sudo أو كمستخدم root"
  exit 1
fi

# تحقق من وجود XUI.one
[ ! -f "/etc/systemd/system/xuione.service" ] && echo "❌ XUI.one غير مثبت!" && exit 1
[ ! -d "/home/xui/config" ] && echo "❌ XUI.one غير مثبت!" && exit 1

# تحقق من وجود ملفات الكراك
[ ! -f "license" ] && echo "❌ ملف license غير موجود!" && exit 1
[ ! -f "xui.so" ] && echo "❌ ملف xui.so غير موجود!" && exit 1

# معلومات
echo -e "\n🧩 XUI.one Crack\n------------------\nAll Versions\nBy sysnull84\n------------------\n"

# إيقاف الخدمة
echo "🛑 إيقاف خدمة XUI.one..."
systemctl stop xuione

# تثبيت ملفات الكراك
echo "📥 نسخ ملفات الكراك..."
cp -r license /home/xui/config/license
cp -r xui.so /home/xui/bin/php/lib/php/extensions/no-debug-non-zts-20190902/xui.so

# تعديل ملف الإعدادات
echo "🛠️ تعديل ملف config.ini..."
sed -i 's/^license.*/license     =   "cracked"/g' /home/xui/config/config.ini

# تشغيل الخدمة
echo "✅ تشغيل خدمة XUI.one..."
systemctl start xuione

# نجاح
echo -e "\n🎉 تم تفعيل الكراك بنجاح!"
