#!/bin/bash 
#####################################################################
#Project		:	RetroPie_BGM_Player
#Git			:	https://github.com/Naprosnia/RetroPie_BGM_Player
#####################################################################
#Script Name	:	bgm_udater
#Date			:	20190302	(YYYYMMDD)
#Description	:	BGM Player updater
#Usage			:	Should be called from bgm_control.sh.
#Author       	:	Luis Torres aka Naprosnia
#####################################################################
#Credits		:	crcerror : https://github.com/crcerror
#####################################################################

BGM="$HOME/RetroPie-BGM-Player"
VERSION="$BGM/version.sh"
BGMSETTINGS="$BGM/bgm_settings.ini"

source $BGMSETTINGS >/dev/null 2>&1
source $VERSION >/dev/null 2>&1

GITVERSION="https://raw.githubusercontent.com/gfunkmonk/RetroPie_BGM_Player/$bgm_gitbranch/RetroPie-BGM-Player/version.sh"
GITINSTALL="https://raw.githubusercontent.com/gfunkmonk/RetroPie_BGM_Player/$bgm_gitbranch/install.sh"

bgm_curversion=$bgm_version
bgm_curdate=$bgm_date



function main_menu() {
	[ "$1" == "--reboot" ] && rebootsys
	
	infobox=
	infobox="${infobox}___________________________________________________________________________\n\n"
	infobox="${infobox}RetroPie BGM Player Updater\n\n"
	infobox="${infobox}Info: RetroPie BGM Player version: $bgm_curversion from $bgm_curdate \n\n"
	infobox="${infobox}Do you want to check for updates?\n"
	infobox="${infobox}___________________________________________________________________________\n\n"

	dialog --backtitle "RetroPie BGM Player v.$bgm_curversion" --title "BGM Updater" --ok-label "Check" --extra-button --extra-label "Reinstall" --yesno "${infobox}" 0 0
	
	opt=$?
	[ $opt -eq 1 ] && exit
	[ $opt -eq 3 ] && updateinstall
	
	dlversion
			
}

function dlversion(){
	clear
	echo -e "[Checking for updates...]"
	cd $HOME
	if wget -N -q --show-progress $GITVERSION; then
		chmod a+rwx $HOME/version.sh
		source $HOME/version.sh >/dev/null 2>&1
		bgm_newversion=$bgm_version
		bgm_newdate=$bgm_date
		rm -rf $HOME/version.sh
		versioncompare $bgm_curversion $bgm_newversion
		[ $? -eq 2 ]  && update || msgbox "BGM Updater Up-To-Date" "Your version: $bgm_curversion from $bgm_curdate is up-to-date."
	else
		msgbox "BGM Updater Error" "It was not possible to check the version available online"
	fi
}

function msgbox(){
	infobox=
	infobox="${infobox}___________________________________________________________________________\n\n"
	infobox="${infobox}RetroPie BGM Player Updater\n\n"
	infobox="${infobox}$2\n"
	infobox="${infobox}___________________________________________________________________________\n\n"

	dialog --backtitle "RetroPie BGM Player v.$bgm_curversion" --title "$1" --msgbox "${infobox}" 0 0
	exit
}
function update(){
	infobox=
	infobox="${infobox}___________________________________________________________________________\n\n"
	infobox="${infobox}RetroPie BGM Player Updater\n\n"
	infobox="${infobox}New version avaliable!\n"
	infobox="${infobox}Version: $bgm_curversion to $bgm_newversion\n\n"
	infobox="${infobox}Do you want to update?\n"
	infobox="${infobox}___________________________________________________________________________\n\n"

	dialog --backtitle "RetroPie BGM Player v.$bgm_curversion" --title "BGM Updater New Version Found" --yesno "${infobox}" 0 0
	
	opt=$?
	[ $opt -eq 1 ] && exit
	updateinstall
}

function updateinstall(){
	clear
	cd $HOME
	echo -e "[Downloading Installation File]\n\n"
	if wget -N -q --show-progress $GITINSTALL; then
		chmod a+rwx $HOME/install.sh
		./install.sh --update
	else
		msgbox "BGM Updater Error" "It was not possible to download the installation file."
	fi
}

function rebootsys(){
	infobox=
	infobox="${infobox}___________________________________________________________________________\n\n"
	infobox="${infobox}RetroPie BGM Player Updater\n\n"
	infobox="${infobox}Updated to version $bgm_curversion !\n\n"
	infobox="${infobox}Your system will reboot now.\n"
	infobox="${infobox}___________________________________________________________________________\n\n"

	dialog --backtitle "RetroPie BGM Player v.$bgm_curversion" --title "BGM Updater Reboot" --msgbox "${infobox}" 0 0
	#kill es to save metadata
	killall emulationstation >/dev/null 2>&1
	sudo reboot
}

function versioncompare() {
    if [[ $1 == $2 ]]
    then
        return 0
    fi
    local IFS=.
    local i ver1=($1) ver2=($2)
    # fill empty fields in ver1 with zeros
    for ((i=${#ver1[@]}; i<${#ver2[@]}; i++))
    do
        ver1[i]=0
    done
    for ((i=0; i<${#ver1[@]}; i++))
    do
        if [[ -z ${ver2[i]} ]]
        then
            # fill empty fields in ver2 with zeros
            ver2[i]=0
        fi
        if ((10#${ver1[i]} > 10#${ver2[i]}))
        then
            return 1
        fi
        if ((10#${ver1[i]} < 10#${ver2[i]}))
        then
            return 2
        fi
    done
    return 0
	
	# return 0 - x=y  | 1 - x>y | 2 - x<y
}
main_menu $@
