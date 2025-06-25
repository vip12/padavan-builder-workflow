#!/bin/bash

NEW_IP="192.168.31.1"
NEW_SSID="Xiaomi_B477"
NEW_HOSTNAME="miwifi.com"

echo "Applying network settings: IP=$NEW_IP, SSID=$NEW_SSID, Hostname=$NEW_HOSTNAME"

# 1. Изменение IP-адреса
find padavan-ng/trunk/configs/boards -type f -exec sed -i \
  "s|192\.168\.1\.1|$NEW_IP|g;
   s|192\.168\.0\.1|$NEW_IP|g;
   s|192\.168\.2\.1|$NEW_IP|g;
   s|10\.0\.0\.1|$NEW_IP|g" {} +

# 2. Изменение BOARD_PID в board.h
BOARD_H="padavan-ng/trunk/configs/boards/XIAOMI/MI-3/board.h"
if [[ -f "$BOARD_H" ]]; then
  sed -i \
    -e "s/BOARD_PID[[:space:]]\+\".*\"/BOARD_PID \"$NEW_SSID\"/" \
    -e "s/BOARD_NAME[[:space:]]\+\".*\"/BOARD_NAME \"$NEW_SSID\"/" \
    "$BOARD_H"
else
  echo "ERROR: board.h not found at $BOARD_H"
  exit 1
fi

# 3. Прямое изменение SSID в скрипте инициализации Wi-Fi
WIFI_SCRIPT="padavan-ng/trunk/user/shared/scripts/set_wifi.sh"
if [[ -f "$WIFI_SCRIPT" ]]; then
  # Для 2.4GHz - только имя, без суффикса
  sed -i "s|ssid_24g=\${ssid_24g:-.*}|ssid_24g=\${ssid_24g:-'$NEW_SSID'}|" "$WIFI_SCRIPT"
  
  # Для 5GHz - имя + "_5G"
  sed -i "s|ssid_5g=\${ssid_5g:-.*}|ssid_5g=\${ssid_5g:-'${NEW_SSID}_5G'}|" "$WIFI_SCRIPT"
else
  echo "WARNING: Wi-Fi init script not found at $WIFI_SCRIPT"
fi

# 4. Изменение домена по умолчанию
DEFAULTS_FILE="padavan-ng/trunk/user/shared/defaults.sh"
if [[ -f "$DEFAULTS_FILE" ]]; then
  sed -i \
    -e "s|DEFAULT_LAN_IP=.*|DEFAULT_LAN_IP='$NEW_IP'|" \
    -e "s|DEFAULT_DOMAIN_NAME=.*|DEFAULT_DOMAIN_NAME='$NEW_HOSTNAME'|" \
    "$DEFAULTS_FILE"
fi

# 5. Дополнительная замена в других местах
find padavan-ng/trunk/user/www \( -name '*.js' -o -name '*.html' \) -exec sed -i "s|my\.router|$NEW_HOSTNAME|g" {} +

# 6. Обновление конфига сборки (только IP)
sed -i "s|IPWRT=.*|IPWRT=$NEW_IP|" build.config

echo "Configuration applied successfully!"
