#!/bin/sh

touch $HOME/.local/share/iso.db
DIR=$HOME/Downloads

fedora_check ()
{
	SITE=$(lynx -dump -nonumbers -nolist "https://torrent.fedoraproject.org/")
	DATE=$(echo "$SITE" | sed -n "/$1\./ {n;p}" | awk '{print $NF}')
	PREVDATE=$(awk "/$1/ {print \$2}" $HOME/.local/share/iso.db)
	if [ "$PREVDATE" = "" ]; then #No iso found
		rm -r $DIR/$1* 2>/dev/null
		aria2c -d $DIR --seed-time=$2 "https://torrent.fedoraproject.org/torrents/$1.torrent" && \
		echo "$1 $DATE" >> $HOME/.local/share/iso.db
		return 0
	fi
	if [ "$DATE" != "$PREVDATE" ]; then #Get latest iso
		rm -r $DIR/$1* 2>/dev/null
		aria2c -d $DIR --seed-time=$2 "https://torrent.fedoraproject.org/torrents/$1.torrent" && \
		sed -i "s/$1 $PREVDATE/$1 $DATE/" $HOME/.local/share/iso.db
	fi
	return 0
}

arch_check ()
{
	SITE=$(lynx -dump -nonumbers -nolist "https://archlinux.org/releng/releases/")
	DATE=$(echo "$SITE" | awk '/Magnet/ {print $4}' | head -1)
	PREVDATE=$(awk '/Arch-Linux-x86_64/ {print $2}' $HOME/.local/share/iso.db)
	if [ "$PREVDATE" = "" ]; then
		rm -r $DIR/archlinux* 2>/dev/null
		aria2c -d $DIR --seed-time=$1 "https://archlinux.org/releng/releases/$DATE/torrent" && \
		echo "Arch-Linux-x86_64 $DATE" >> $HOME/.local/share/iso.db
		return 0
	fi
	if [ "$DATE" != "$PREVDATE" ]; then
		rm -r $DIR/archlinux* 2>/dev/null
		aria2c -d $DIR --seed-time=$1 "https://archlinux.org/releng/releases/$DATE/torrent" && \
		sed -i "s/Arch-Linux-x86_64 $PREVDATE/Arch-Linux-x86_64 $DATE/" $HOME/.local/share/iso.db
	fi
	return 0
}

fedora_check "Fedora-Workstation-Live-x86_64-34" 0
fedora_check "Fedora-Workstation-Live-x86_64-35" 0
arch_check 0

exit 0
