#!/bin/bash

# ---- Конфигурация ----
NEW_IP="192.168.31.1"
NEW_SSID="Xiaomi_B477"
# ----------------------

echo "Applying custom configuration:"
echo " - Default IP: $NEW_IP"
echo " - WiFi SSID: $NEW_SSID"

# Изменение IP-адреса
find trunk/configs/ -name 'board.*' -exec sed -i "s/192\.168\.\?1\.1/$NEW_IP/g" {} +
sed -i "s/CONFIG_FIRMWARE_PRODUCT_ID=.*/CONFIG_FIRMWARE_PRODUCT_ID=\"$NEW_SSID\"/" .config
sed -i "s/IPWRT=.*/IPWRT=$NEW_IP/g" .config

# Изменение WiFi SSID
sed -i "s/ssid='.*'/ssid='$NEW_SSID'/" trunk/configs/boards/ralink.mt7620.profile
sed -i "s/ssid=\${ssid:-.*}/ssid=\${ssid:-$NEW_SSID}/" trunk/scripts/set_wifi.sh

# Дополнительные настройки
sed -i "s/DEFAULT_LAN_IP=.*/DEFAULT_LAN_IP='$NEW_IP'/" trunk/user/shared/defaults.sh
