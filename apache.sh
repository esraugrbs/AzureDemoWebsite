#!/usr/bin/env bash
set -euo pipefail

# 1) Apache kurulu değilse kur
if ! command -v apache2 >/dev/null 2>&1; then
  sudo apt-get update -y
  sudo apt-get install -y apache2
fi

# 2) Dosyaları kopyala
DOCROOT="/var/www/html"
sudo mkdir -p "$DOCROOT"
sudo cp -r /tmp/site/* "$DOCROOT"/

# 3) İzinler
sudo chown -R www-data:www-data "$DOCROOT"
sudo find "$DOCROOT" -type d -exec chmod 755 {} \;
sudo find "$DOCROOT" -type f -exec chmod 644 {} \;

# 4) Apache yeniden başlat
sudo systemctl enable apache2
sudo systemctl restart apache2
echo "✅  Deployment completed."
