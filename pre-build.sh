#!/bin/bash

# Конфигурация
NEW_IP="192.168.31.1"
NEW_SSID="Xiaomi_B477"

echo "Applying network settings: IP=$NEW_IP, SSID=$NEW_SSID"

# 1. Изменение IP-адреса
find padavan-ng/trunk/configs/boards -type f -exec sed -i \
  "s|192\.168\.1\.1|$NEW_IP|g;
   s|192\.168\.2\.1|$NEW_IP|g;
   s|192\.168\.0\.1|$NEW_IP|g" {} +

# 2. Изменение SSID
sed -i \
  -e "s/ssid='[^']*'/ssid='$NEW_SSID'/" \
  -e "s/ssid=\${ssid:-[^}]*}/ssid=\${ssid:-$NEW_SSID}/" \
  padavan-ng/trunk/configs/boards/ralink.mt7620.profile

# 3. Обновление конфига сборки
sed -i \
  -e "s|CONFIG_FIRMWARE_PRODUCT_ID=.*|CONFIG_FIRMWARE_PRODUCT_ID=\"$NEW_SSID\"|" \
  -e "s|IPWRT=.*|IPWRT=$NEW_IP|" \
  build.config
