#!/bin/bash

NEW_IP="192.168.31.1"
NEW_SSID="Xiaomi_B477"
NEW_HOSTNAME="miwifi.com"
NEW_COUNTRY="RU"
NEW_TIMEZONE="MSK-3"
NTP_SERVERS=("pool.ntp.org" "ntp.msk-ix.ru" "time.cloudflare.com" "time.google.com")

echo "Applying network settings:"
echo "- IP: $NEW_IP"
echo "- SSID: $NEW_SSID"
echo "- Hostname: $NEW_HOSTNAME"
echo "- Country: $NEW_COUNTRY"
echo "- Timezone: $NEW_TIMEZONE"
echo "- NTP Servers: ${NTP_SERVERS[*]}"

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

# 3. Изменение хоста в net_wan.c
NET_WAN_FILE="padavan-ng/trunk/user/rc/net_wan.c"
if [[ -f "$NET_WAN_FILE" ]]; then
  sed -i "s|\"my\.router\"|\"$NEW_HOSTNAME\"|g" "$NET_WAN_FILE"
fi

# 4. Изменение параметров в defaults.h
DEFAULTS_H="padavan-ng/trunk/user/shared/defaults.h"
if [[ -f "$DEFAULTS_H" ]]; then
  # IP и домен
  sed -i \
    -e "s|DEF_LAN_ADDR[[:space:]]\+\".*\"|DEF_LAN_ADDR \"$NEW_IP\"|" \
    -e "s|DEF_LAN_DHCP_BEG[[:space:]]\+\".*\"|DEF_LAN_DHCP_BEG \"${NEW_IP%.*}.2\"|" \
    -e "s|DEF_LAN_DHCP_END[[:space:]]\+\".*\"|DEF_LAN_DHCP_END \"${NEW_IP%.*}.244\"|" \
    -e "s|DEFAULT_DOMAIN_NAME[[:space:]]\+\".*\"|DEFAULT_DOMAIN_NAME \"$NEW_HOSTNAME\"|" \
    "$DEFAULTS_H"
  
  # Страна
  sed -i \
    -e "s|DEF_WLAN_2G_CC[[:space:]]\+\".*\"|DEF_WLAN_2G_CC \"$NEW_COUNTRY\"|" \
    -e "s|DEF_WLAN_5G_CC[[:space:]]\+\".*\"|DEF_WLAN_5G_CC \"$NEW_COUNTRY\"|" \
    "$DEFAULTS_H"
  
  # Часовой пояс
  sed -i "s|DEF_TIMEZONE[[:space:]]\+\".*\"|DEF_TIMEZONE \"$NEW_TIMEZONE\"|" "$DEFAULTS_H"
  
  # NTP серверы
  for i in {0..3}; do
    if [[ -n "${NTP_SERVERS[$i]}" ]]; then
      sed -i "s|DEF_NTP_SERVER$i[[:space:]]\+\".*\"|DEF_NTP_SERVER$i \"${NTP_SERVERS[$i]}\"|" "$DEFAULTS_H"
    fi
  done
fi

# 5. Изменение SSID в defaults.h и defaults.c
if [[ -f "$DEFAULTS_H" ]]; then
  sed -i \
    -e "s|DEF_WLAN_2G_SSID[[:space:]]\+\".*\"|DEF_WLAN_2G_SSID \"$NEW_SSID\"|" \
    -e "s|DEF_WLAN_5G_SSID[[:space:]]\+\".*\"|DEF_WLAN_5G_SSID \"${NEW_SSID}_5G\"|" \
    "$DEFAULTS_H"
fi

DEFAULTS_C="padavan-ng/trunk/user/shared/defaults.c"
if [[ -f "$DEFAULTS_C" ]]; then
  sed -i \
    -e "s|def_ssid_24g = \".*\";|def_ssid_24g = \"$NEW_SSID\";|" \
    -e "s|def_ssid_5g = \".*\";|def_ssid_5g = \"${NEW_SSID}_5G\";|" \
    "$DEFAULTS_C"
fi

# 6. Замена в веб-интерфейсе
find padavan-ng/trunk/user/www -type f \( -name '*.js' -o -name '*.html' -o -name '*.css' \) -exec grep -l "my\.router" {} + | while read file; do
  sed -i "s|my\.router|$NEW_HOSTNAME|g" "$file"
done

# 7. Обновление конфига сборки
sed -i "s|IPWRT=.*|IPWRT=$NEW_IP|" build.config

echo "Configuration applied successfully!"
