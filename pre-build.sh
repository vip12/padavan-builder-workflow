#!/bin/bash

# Конфигурация
NEW_IP="192.168.31.1"
NEW_SSID="Xiaomi_B477"

echo "Applying network settings: IP=$NEW_IP, SSID=$NEW_SSID"

# 1. Изменение IP-адреса (для всех вендоров)
find padavan-ng/trunk/configs/boards -type f -name "board.*" -exec sed -i \
  "s|192\.168\.1\.1|$NEW_IP|g;
   s|192\.168\.0\.1|$NEW_IP|g;
   s|192\.168\.2\.1|$NEW_IP|g;
   s|10\.0\.0\.1|$NEW_IP|g" {} +

# 2. Изменение SSID (новый путь для Xiaomi MI-3)
BOARD_PROFILE="padavan-ng/trunk/configs/boards/XIAOMI/MI-3/board.h"
if [[ -f "$BOARD_PROFILE" ]]; then
  sed -i \
    -e "s|#define\s\+BOARD_SSID\s\+\".*\"|#define BOARD_SSID \"$NEW_SSID\"|" \
    -e "s|#define\s\+BOARD_SSID0\s\+\".*\"|#define BOARD_SSID0 \"$NEW_SSID\"|" \
    -e "s|#define\s\+BOARD_SSID1\s\+\".*\"|#define BOARD_SSID1 \"$NEW_SSID\"|" \
    "$BOARD_PROFILE"
else
  echo "ERROR: Board profile not found at $BOARD_PROFILE"
  echo "Available boards:"
  find padavan-ng/trunk/configs/boards -name "board.h" | sed 's/^/ - /'
  exit 1
fi

# 3. Обновление конфига сборки
sed -i \
  -e "s|CONFIG_FIRMWARE_PRODUCT_ID=.*|CONFIG_FIRMWARE_PRODUCT_ID=\"$NEW_SSID\"|" \
  -e "s|IPWRT=.*|IPWRT=$NEW_IP|" \
  build.config

# 4. Дополнительно: обновление defaults.sh
DEFAULTS_FILE="padavan-ng/trunk/user/shared/defaults.sh"
if [[ -f "$DEFAULTS_FILE" ]]; then
  sed -i "s|DEFAULT_LAN_IP=.*|DEFAULT_LAN_IP='$NEW_IP'|" "$DEFAULTS_FILE"
fi

echo "Configuration applied successfully!"
