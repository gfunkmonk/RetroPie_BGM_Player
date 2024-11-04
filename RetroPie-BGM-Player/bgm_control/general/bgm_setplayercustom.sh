#!/bin/bash 
#####################################################################
#Project		:	RetroPie_BGM_Player
#Git			:	https://github.com/Naprosnia/RetroPie_BGM_Player
#####################################################################
#Script Name	:	bgm_setplayercustom.sh
#Date			:	20190227	(YYYYMMDD)
#Description	:	BGM Player select player custom file types
#Usage			:	Should be called from bgm_control.sh.
#Author       	:	Luis Torres aka Naprosnia
#####################################################################
#Credits		:	crcerror : https://github.com/crcerror
#####################################################################

BGM="$HOME/RetroPie-BGM-Player"
BGMSETTINGS="$BGM/bgm_settings.ini"
VERSION="$BGM/version.sh"
source $VERSION >/dev/null 2>&1
filetypes=("mp3" "ogg" "ay" "gbs" "gym" "hes" "kss" "nsf" "nsfe" "sap" "spc" "vgm" "vgz" "vtx" "2sf" "psf" "psf2")

function main_menu() {
    local choice

    while true; do
	
		unset bgm_customplayer
		source $BGMSETTINGS >/dev/null 2>&1

		for filetype in "${filetypes[@]}"; do
			checkarray ${bgm_customplayer[@]} $filetype && declare ft_$filetype="X" ||  declare ft_$filetype=" "
		done
        choice=$(dialog --backtitle "RetroPie BGM Player v.$bgm_version" --title "Custom File Type Player" \
            --ok-label "Select" --cancel-label "Back" --no-tags  --default-item "$choice" \
            --menu "Select your Player" 25 75 20 \
            "mp3" " [$ft_mp3] MP3" \
            "ogg" " [$ft_ogg] OGG" \
			"ay" " [$ft_ay] Spectrum ZX (.ay)" \
			"gbs" " [$ft_gbs] GameBoy (.gbs)" \
			"gym" " [$ft_gym] Sega Genesis (.gym)" \
			"hes" " [$ft_hes] NEC PC Engine / TurboGrafx-16 (.hes)" \
			"kss" " [$ft_kss] MSX / Other Z80 (.kss)" \
			"nsf" " [$ft_nsf] NES (.nsf)" \
			"nsfe" " [$ft_nsfe] NES Extended Support (.nsfe)" \
			"sap" " [$ft_sap] Atari SAP (.sap)" \
			"spc" " [$ft_spc] SNES (.spc)" \
			"2sf" " [$ft_2sf] Nintendo DS (.2sf)" \
			"vgm" " [$ft_vgm] Sega VGM (.vgm)" \
			"vgz" " [$ft_vgz] Sega VGZ (.vgz)" \
			"vtx" " [$ft_vtx] Vortex (.vtx)" \
			"psf" " [$ft_psf] Playstation Audio (.psf)" \
			"psf2" " [$ft_psf2] Playstation Audio (.psf2)" \
            2>&1 > /dev/tty)

        opt=$?
		if [ $opt -eq 1 ]; then
			if [ ${#bgm_customplayer[@]} -gt 0 ]; then
				bash $BGM/bgm_system.sh -reloadc
				bash $BGM/bgm_system.sh -setsetting bgm_player custom
				sleep 0.5
				bash $BGM/bgm_system.sh -i
			fi
			exit
		fi
		managearray $choice
		
    done
}

function checkarray(){ 	
	array=("$@")
	((last_id=${#array[@]} - 1))
	search=${array[last_id]}
	unset array[last_id]
	local in=1
	for element in "${array[@]}"; do
		if [ $element == $search ]; then
			in=0
			break
		fi
	done
	return $in

}

function managearray(){
	ext=$1
	ft_ext="ft_$ext"
	
	if [ "${!ft_ext}" == "X" ]; then
		sed -i "/bgm_customplayer+=(\"$ext\")/d" $BGMSETTINGS
	else
		echo "bgm_customplayer+=(\"$ext\")" >> $BGMSETTINGS
	fi
}

main_menu
