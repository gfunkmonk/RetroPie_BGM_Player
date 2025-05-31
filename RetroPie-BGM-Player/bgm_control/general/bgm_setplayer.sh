#!/bin/bash 
#####################################################################
#Project		:	RetroPie_BGM_Player
#Git			:	https://github.com/Naprosnia/RetroPie_BGM_Player
#####################################################################
#Script Name	:	bgm_setplayer.sh
#Date			:	20190222	(YYYYMMDD)
#Description	:	BGM Player select player menu.
#Usage			:	Should be called from bgm_control.sh.
#Author       	:	Luis Torres aka Naprosnia
#####################################################################
#Credits		:	crcerror : https://github.com/crcerror
#####################################################################

BGM="$HOME/RetroPie-BGM-Player"
BGMSETTINGS="$BGM/bgm_settings.ini"
VERSION="$BGM/version.sh"
BGMCONTROL="$BGM/bgm_control"
BGMCONTROLGENERAL="$BGMCONTROL/general"
source $VERSION >/dev/null 2>&1

function description() {
infobox=
infobox="${infobox}___________________________________________________________________________\n\n"
infobox="${infobox}RetroPie BGM Player Player Select\n\n"
infobox="${infobox}Set BGM Player. Music or Game Audio Files .\n"
infobox="${infobox}___________________________________________________________________________\n\n"

dialog --backtitle "RetroPie BGM Player v.$bgm_version" --title "BGM Player Select Description" --msgbox "${infobox}" 0 0
}
#description

function main_menu() {
    local choice

    while true; do
	
		source $BGMSETTINGS >/dev/null 2>&1
		[ "$bgm_player" == "mp3" ] && mp3="X" || mp3=" "
		[ "$bgm_player" == "emu" ] && emu="X"  || emu=" "
		[ "$bgm_player" == "custom" ] && custom="X"  || custom=" "
		[ "$bgm_player" == "both" ] && both="X"  || both=" "
		
        choice=$(dialog --backtitle "RetroPie BGM Player v.$bgm_version" --title "Player Select" \
            --ok-label "Select" --cancel-label "Back" --no-tags --default-item "$bgm_player" \
            --menu "Select your Player" 25 75 20 \
            "mp3" "1 [$mp3] Music Files Player" \
			"emu" "2 [$emu] Game Audio Files Player" \
			"both" "3 [$both] Both Players" \
			"custom" "4 [$custom] Custom File Types" \
            2>&1 > /dev/tty)

        opt=$?
		[ $opt -eq 1 ] && exit
		
		if [ $choice == "custom" ]; then
			bash $BGMCONTROLGENERAL/bgm_setplayercustom.sh
		else
			bash $BGM/bgm_system.sh -setsetting bgm_player $choice
			bash $BGM/bgm_system.sh -i
		fi
		
    done
}

main_menu
