#!/bin/bash
echo "🚀 JobClass Symlink Kaldırma ve Uploads Ayarı Başlıyor..."

FILESYSTEMS_FILE="config/filesystems.php"

# 1. uploads disk tanımı ekle
if grep -q "uploads" "$FILESYSTEMS_FILE"; then
    echo "✅ uploads diski zaten ekli."
else
    sed -i "/'disks' => \[/a\ \ \ \ 'uploads' => [\n        'driver' => 'local',\n        'root' => public_path('uploads'),\n        'url' => env('APP_URL').'/uploads',\n        'visibility' => 'public',\n    ]," $FILESYSTEMS_FILE
    echo "✅ uploads diski eklendi."
fi

# 2. default disk ayarını değiştir
sed -i "s/'default' => env('FILESYSTEM_DISK', 'public')/'default' => env('FILESYSTEM_DISK', 'uploads')/g" $FILESYSTEMS_FILE

# 3. .env dosyasına ekle
if grep -q "FILESYSTEM_DISK" .env; then
    sed -i "s/FILESYSTEM_DISK=.*/FILESYSTEM_DISK=uploads/g" .env
else
    echo "FILESYSTEM_DISK=uploads" >> .env
fi

# 4. uploads klasörü oluştur
mkdir -p public/uploads
chmod -R 775 public/uploads

# 5. Var olan dosyaları taşı
if [ -d "storage/app/public" ]; then
    cp -r storage/app/public/* public/uploads/ 2>/dev/null
    echo "✅ Var olan dosyalar taşındı."
fi

# 6. Laravel cache temizle
php artisan config:clear
php artisan cache:clear
php artisan route:clear

echo "🎉 İşlem tamamlandı! Artık storage:link gerekmez."
echo "📂 Yüklenen dosyalar: public/uploads"