#!/bin/sh

touch $HOME/.local/share/iso.db

fedora_check ()
{
	SITE=$(lynx -dump -nonumbers -nolist "https://torrent.fedoraproject.org/")
	DATE=$(echo "$SITE" | sed -n "/$1\./ {n;p}" | awk '{print $NF}')
	PREVDATE=$(grep "$1" $HOME/.local/share/iso.db | awk '{print $2}')
	if [ "$PREVDATE" = "" ]; then #No iso found
		rm -r $1* 2>/dev/null
		aria2c --seed-time=$2 "https://torrent.fedoraproject.org/torrents/$1.torrent" && \
		echo "$1 $DATE" >> $HOME/.local/share/iso.db
		return 0
	fi
	if [ "$DATE" != "$PREVDATE" ]; then #Get latest iso
		rm -r $1* 2>/dev/null
		aria2c --seed-time=$2 "https://torrent.fedoraproject.org/torrents/$1.torrent" && \
		sed -i "s/$1 $PREVDATE/$1 $DATE/" $HOME/.local/share/iso.db
	fi
	return 0
}

arch_check ()
{
	SITE=$(lynx -dump -nonumbers -nolist "https://archlinux.org/releng/releases/")
	DATE=$(echo "$SITE" | awk '/Magnet/ {print $4}' | head -1)
	PREVDATE=$(grep Arch-Linux-x86_64 $HOME/.local/share/iso.db | awk '{print $2}')
	if [ "$PREVDATE" = "" ]; then
		rm -r archlinux* 2>/dev/null
		aria2c --seed-time=$1 "https://archlinux.org/releng/releases/$DATE/torrent" && \
		echo "Arch-Linux-x86_64 $DATE" >> $HOME/.local/share/iso.db
		return 0
	fi
	if [ "$DATE" != "$PREVDATE" ]; then
		rm -r archlinux* 2>/dev/null
		aria2c --seed-time=$1 "https://archlinux.org/releng/releases/$DATE/torrent" && \
		sed -i "s/Arch-Linux-x86_64 $PREVDATE/Arch-Linux-x86_64 $DATE/" $HOME/.local/share/iso.db
	fi
	return 0
}

fedora_check "Fedora-Workstation-Live-x86_64-34" 0
fedora_check "Fedora-Workstation-Live-x86_64-35_Beta" 0
arch_check 0

exit 0
