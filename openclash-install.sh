#!/bin/sh

RED_COLOR='\e[1;31m'
GREEN_COLOR='\e[1;32m'
YELLOW_COLOR='\e[1;33m'
SHAN='\e[1;33;5m'
RES='\e[0m'

NOTE='\e[1;36m
==========================================================================
                     A Clash Client For OpenWrt
                    Only Support Cooluc Firmware
==========================================================================
\e[0m';

echo -e "$NOTE"

echo -ne "${SHAN}Press ENTER to installation${RES}"
read

# temp
temp=$(mktemp -d) || exit 1

# github mirror
ip_info=$(curl -sk https://ip.cooluc.com)
country_code=$(echo $ip_info | sed -r 's/.*country_code":"([^"]*).*/\1/')
if [ $country_code = "CN" ]; then
	google_status=$(curl -I -4 -m 3 -o /dev/null -s -w %{http_code} http://www.google.com/generate_204)
	if [ ! $google_status = "204" ];then
		mirror="https://gh.cooluc.com/"
	fi
fi

# get latest version
latest_version=`curl -sk "https://r5s.cooluc.com/openclash/releases.json" | grep browser_download_url | head -1 | awk '{print $2}' | sed 's/\"//g'`
echo -e "${GREEN_COLOR}Download $mirror$latest_version ...${RES}"
curl --connect-timeout 30 -m 600 -kLo "$temp/openclash.ipk" $mirror$latest_version
if [ $? -ne 0 ]; then
	echo -e "${RED_COLOR}Error! download $mirror$latest_version failed.${RES}"
	rm -rf $temp
	exit 1
else
	echo -e "\r\n${GREEN_COLOR}Install Packages ...${RES}\r\n"
	opkg update
	opkg install libcap libcap-bin ruby ruby-yaml
	opkg install $temp/openclash.ipk
	if [ $? -eq 0 ]; then
		echo -e "\r\n${GREEN_COLOR}Install Done!${RES}\r\n"
		echo -ne "${SHAN}Press ENTER to reboot${RES}"
		read
		reboot
	else
		echo -e "${RED_COLOR}Install Error!${RES}"
	fi
fi
