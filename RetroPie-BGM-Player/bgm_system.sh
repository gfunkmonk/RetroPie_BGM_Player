#!/bin/bash 
#####################################################################
#Project		:	RetroPie_BGM_Player
#Git			:	https://github.com/Naprosnia/RetroPie_BGM_Player
#####################################################################
#Script Name	:	bgm_system.sh
#Date			:	20190227	(YYYYMMDD)
#Description	:	This script contain all functions needed by BGM.
#Usage			:	It should be called from other scripts using arguments.
#Author       	:	Luis Torres aka Naprosnia
#####################################################################
#Credits		:	crcerror : https://github.com/crcerror
#####################################################################

# Avoid multiple starts, so force close
[[ "$(pgrep -c -f $(basename $0))" -gt 1 ]] && exit

# read arguments and execute functions
function execute() {
	if [ "$#" -gt 0 ]; then

		case "$1" in
			-i)
				(bgm_init "$2" &)
				;;
			-p)
				bgm_play
				;;
			-s)
				(bgm_stop &)
				;;
			-setsetting)
				bgm_setsetting "$2" "$3"
				;;
			-reload)
				reloadaudiofiles
				;;
			-reloadc)
				reloadcustom
				;;
			-r)
				bgm_restart
				;;
			-k)
				bgm_kill
				;;
			*)
				exit
				;;
		esac
	else
		exit
	fi
}

# shorten paths
RP="$HOME/RetroPie"
RPMENU="$RP/retropiemenu"
RPSETUP="$HOME/RetroPie-Setup"
RPCONFIGS="/opt/retropie/configs/all"

BGM="$HOME/RetroPie-BGM-Player"
BGMCONTROL="$BGM/bgm_control"
BGMSETTINGS="$BGM/bgm_settings.ini"
BGMMUSICS="$RP/roms/music"
BGMLISTS="$BGM/bgm_lists"
BGMBOTH="$BGMLISTS/both"
BGMEMU="$BGMLISTS/emu"
BGMMP3="$BGMLISTS/mp3"
BGMCUSTOM="$BGMLISTS/custom"

AUD="$HOME/.config/audacious"
AUDSETTINGS="$AUD/config"

MUSICPLAYER="audacious"

mp3files=("mp3")
emufiles=("ay" "gbs" "gym" "hes" "kss" "nsf" "nsfe" "sap" "spc" "vgm" "vgz" "vtx" "2sf" "psf" "psf2")


# settings area
source $BGMSETTINGS >/dev/null 2>&1
# end of settings area

# ALSA related vars
readonly CHANNEL="HDMI"
# get current volume
CHANNELVOLUME=$(amixer -M get $CHANNEL | grep -o "...%]")
CHANNELVOLUME=${CHANNELVOLUME//[^[:alnum:].]/}
# volume commands
VOLUMEZERO="amixer -q -M set $CHANNEL 0%"
VOLUMERESET="amixer -q -M set $CHANNEL $CHANNELVOLUME%"
FADEVOLUME=
VOLUMESTEP=

function bgm_init(){

	# if script called from autostart.sh, wait for omxplayer (splashscreen) to end
	if [ "$1" == "--autostart" ]; then
		while pgrep omxplayer >/dev/null; do sleep 1; done
		reloadaudiofiles
		sleep $bgm_delay
	fi
	
	(pgrep -x $MUSICPLAYER > /dev/null) && bgm_kill
	
	# start player (always)
	[ -s $BGMLISTS/$bgm_player/$bgm_player.m3u ] && (setsid $MUSICPLAYER -H $BGMLISTS/$bgm_player/$bgm_player.m3u >/dev/null 2>&1 &)
	
	# check bgm_toggle, if 1 = play, else = stop
	if [ "$bgm_toggle" -eq "1" ]; then
	
		# check bgm_fade, if 1 apply fade, else leave it
		if [ "$bgm_fade" -eq "1" ]; then
			vol_fade_in
		fi
		
	else
		pkillstop	
	fi
	
}

function reloadaudiofiles(){
	reloadmp3
	reloademu
	reloadboth
	reloadcustom
}

function reloader(){
	
	chmod -R a+rwx $BGMMUSICS/*.* >/dev/null 2>&1
	
	types=("$@")
	((last_id=${#types[@]} - 1))
	player=${types[last_id]}
	unset types[last_id]
	
	rm -f $BGMLISTS/$player/$player.m3u >/dev/null 2>&1
	
	for type in "${types[@]}"; do
		find $BGMMUSICS -type f -iname "*.$type" >> $BGMLISTS/$player/$player.m3u
	done
	
	chmod -R a+rwx $BGMLISTS/$player/$player.m3u >/dev/null 2>&1

}

function reloadmp3(){
	reloader ${mp3files[@]} "mp3"
}
function reloademu(){
	reloader ${emufiles[@]} "emu"
}
function reloadboth(){
	reloader ${mp3files[@]} ${emufiles[@]} "both"
}
function reloadcustom(){
	reloader ${bgm_customplayer[@]} "custom"
}

function bgm_play(){

	# check bgm_toggle, if 1 = play, else = null
	if [ "$bgm_toggle" -eq "1" ]; then
		# check bgm_nonstop, if 0 = stop, else = null
		if [ "$bgm_nonstop" -eq "0" ]; then
			# check bgm_fade, if 1 apply fade, else leave it
			if [ "$bgm_fade" -eq "1" ]; then
				vol_fade_in
			else
				pkillcont
			fi
		fi
	fi
	
}

function bgm_stop(){

	# check bgm_toggle, if 1 = stop, else = null
	if [ "$bgm_toggle" -eq "1" ]; then
		# check bgm_nonstop, if 0 = stop, else = null
		if [ "$bgm_nonstop" -eq "0" ]; then
			# check bgm_fade, if 1 apply fade, else leave it
			if [ "$bgm_fade" -eq "1" ]; then
				vol_fade_out
			else
				pkillstop
			fi
		fi
		
	fi
	
}

# fade related functions
function fade_set_step() {

	# reduce volume by steps | 100 -> 0 = slow -> fast
	case $FADEVOLUME in
		[1-4][0-9]|50) VOLUMESTEP=8 ;;
		[5-7][0-9]|80) VOLUMESTEP=5 ;;
		[8-9][0-9]|100) VOLUMESTEP=3 ;;
		*) VOLUMESTEP=5 ;;
	esac
	
}

function vol_fade_in(){

    $VOLUMEZERO
    sleep 0.2
    pkillcont
    FADEVOLUME=10
    until [[ $FADEVOLUME -ge $CHANNELVOLUME ]]; do
        fade_set_step
        FADEVOLUME=$(($FADEVOLUME+$VOLUMESTEP))
        amixer -q -M set "$CHANNEL" "${VOLUMESTEP}%+"
        sleep 0.2
    done
    $VOLUMERESET
}

function vol_fade_out(){
	FADEVOLUME=$CHANNELVOLUME
	until [[ $FADEVOLUME -le 10 ]]; do
        fade_set_step
        FADEVOLUME=$(($FADEVOLUME-$VOLUMESTEP))
        amixer -q -M set "$CHANNEL" "${VOLUMESTEP}%-"
        sleep 0.2
    done
    $VOLUMEZERO
    pkillstop
    sleep 0.2
    $VOLUMERESET
}
# end of fade related functions

# option menu related functions
function bgm_setsetting(){
	sed -i "s/^$1.*/$1=$2/g" $BGMSETTINGS
	if [ "$1" == "bgm_volume" ]; then
		chmod 0644 $AUDSETTINGS
		sleep 0.2
		bgm_audaciousvolume "sw_volume_right" "$2"
		bgm_audaciousvolume "sw_volume_left" "$2"
		sleep 0.2
		chmod 0444 $AUDSETTINGS
	fi

}

function bgm_audaciousvolume(){
	sed -i "s/^$1.*/$1=$2/g" $AUDSETTINGS
}
# end of option menu related functions

function pkillstop(){
	pkill -STOP $MUSICPLAYER >/dev/null 2>&1
}
function pkillcont(){
	pkill -CONT $MUSICPLAYER >/dev/null 2>&1
}

function bgm_kill(){
	killall $MUSICPLAYER >/dev/null 2>&1
}

function bgm_restart(){
	
	bgm_kill
	sleep 0.2
	bgm_init
}

execute "$@"
