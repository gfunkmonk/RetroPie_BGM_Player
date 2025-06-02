#!/bin/bash 
#####################################################################
#Project		:	RetroPie_BGM_Player
#Git			:	https://github.com/Naprosnia/RetroPie_BGM_Player
#####################################################################
#Script Name	:	bgm_setvolume.sh
#Date			:	20190222	(YYYYMMDD)
#Description	:	BGM Player volume setting menu.
#Usage			:	Should be called from bgm_control.sh.
#Author       	:	Luis Torres aka Naprosnia
#####################################################################
#Credits		:	crcerror : https://github.com/crcerror
#####################################################################

BGM="$HOME/RetroPie-BGM-Player"
BGMSETTINGS="$BGM/bgm_settings.ini"
VERSION="$BGM/version.sh"
source $VERSION >/dev/null 2>&1

function description() {
infobox=
infobox="${infobox}___________________________________________________________________________\n\n"
infobox="${infobox}RetroPie BGM Player Volume\n\n"
infobox="${infobox}Change BGM Player volume.\n"
infobox="${infobox}___________________________________________________________________________\n\n"

dialog --backtitle "RetroPie BGM Player v.$bgm_version" --title "BGM Volume Description" --msgbox "${infobox}" 0 0
}
#description

function main_menu() {
    local choice

    while true; do
	
		source $BGMSETTINGS >/dev/null 2>&1
		
        choice=$(dialog --backtitle "RetroPie BGM Player v.$bgm_version" --title "BGM Volume" \
            --ok-label "Select" --cancel-label "Back" --no-tags --default-item "$bgm_volume"\
            --menu "Set volume level" 25 75 20 \
            100 "1 Volume 100%" \
            90 "2 Volume 90% (Default)" \
            80 "3 Volume 80%" \
            70 "4 Volume 70%" \
            60 "5 Volume 60%" \
            50 "6 Volume 50%" \
            40 "7 Volume 40%" \
            30 "8 Volume 30%" \
            20 "9 Volume 20%" \
            10 "10 Volume 10%" \
            2>&1 > /dev/tty)
			
			opt=$?
			[ $opt -eq 1 ] && exit
			
			bash $BGM/bgm_system.sh -setsetting bgm_volume $choice
			bash $BGM/bgm_system.sh -i
			
    done
}

main_menu

