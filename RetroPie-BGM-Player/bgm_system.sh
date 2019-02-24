#!/bin/bash 
#####################################################################
#Project		:	RetroPie_BGM_Player
#Git			:	https://github.com/Naprosnia/RetroPie_BGM_Player
#####################################################################
#Script Name	:	bgm_system.sh
#Date			:	20190224	(YYYYMMDD)
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
				(bgm_init "$2") &
				;;
			-p)
				bgm_play
				;;
			-s)
				bgm_stop
				;;
			-setsetting)
				bgm_setsetting "$2" "$3"
				;;
			-m3u)
				generatem3u
				;;
			-seq)
				generatesequence
				;;
			-lists)
				generatelists
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
BGMLAUNCHER="$BGM/bgm_launcher"


LAUNCHER="bgm_launcher.sh"
LAUNCHERID=$(pgrep $LAUNCHER)

BGMBOTH="$BGMLAUNCHER/both"
BGMVGMPLAYER="$BGMLAUNCHER/vgmplayer"
BGMMP3PLAYER="$BGMLAUNCHER/mp3player"

VGMPLAYSETTINGS="$BGMVGMPLAYER/VGMPlay.ini"

# settings area
source $BGMSETTINGS >/dev/null 2>&1
# end of settings area

# ALSA related vars
readonly CHANNEL="PCM"
# get current volume
CHANNELVOLUME=$(amixer -M get $CHANNEL | grep -o "...%]")
CHANNELVOLUME=${CHANNELVOLUME//[^[:alnum:].]/}
# volume commands
VOLUMEZERO="amixer -q -M set $CHANNEL 0%"
VOLUMERESET="amixer -q -M set $CHANNEL $CHANNELVOLUME%"
FADEVOLUME=
VOLUMESTEP=

#convert volume for mp3player
bgm_mp3volume=$(( 32768*$bgm_volume/100 ))

function bgm_init(){

	# if script called from autostart.sh, wait for omxplayer (splashscreen) to end
	if [ "$1" == "--autostart" ]; then
		while pgrep omxplayer >/dev/null; do sleep 1; done
		generatelists
		sleep $bgm_delay
	fi
	
	(pgrep -x $LAUNCHER > /dev/null) && bgm_kill
	
	# start player (always)
	./$BGMLAUNCHER/$LAUNCHER
	
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

function generatelists(){
	chmod -R a+rwx $BGMMUSICS/*.*
	generatem3u
	generatesequence
}

##generates, if no files found, do not create lists
function generatem3u(){
		
	types=("vgm" "vgz" "cmf" "dro")

	for type in "${types[@]}"; do
		find $BGMMUSICS -type f -iname "*.$type" >> $BGMVGMPLAYER/templist.m3u
	done
	
	if [ -s $BGMVGMPLAYER/templist.m3u ]; then
	
		cat $BGMVGMPLAYER/templist.m3u | shuf > $BGMVGMPLAYER/playlist.m3u
		#for run in {1..10}; do cat $BGMVGMPLAYER/shuftemplist.m3u; done > $BGMVGMPLAYER/playlist.m3u
		chmod -R a+rwx $BGMVGMPLAYER/*.m3u >/dev/null 2>&1
		
	fi
	
	rm -f $BGMVGMPLAYER/templist.m3u >/dev/null 2>&1

}
function generatesequence(){
	
	types=("vgm" "vgz" "cmf" "dro" "mp3")
	
	for type in "${types[@]}"; do
		
		case "$type" in
			mp3)
				find $BGMMUSICS -type f -iname "*.$type" | sed "s/.*/mpg123 -q -f $bgm_mp3volume -Z & >\/dev\/null 2>\&1/" >> $BGMBOTH/sequencelist
				;;
			*)
				find $BGMMUSICS -type f -iname "*.$type" | sed "s/.*/bash \/home\/pi\/RetroPie-BGM-Player\/bgm_launcher\/vgmplayer\/vgmplay &  >\/dev\/null 2>\&1/" >> $BGMBOTH/sequencelist
				;;
		esac
	done
	
	if [ -s $BGMBOTH/sequencelist ]; then
	
		cat $BGMBOTH/sequencelist | shuf > $BGMBOTH/sequence
		#for run in {1..10}; do cat $BGM/shufbothlist; done > $BGM/both
		chmod -R a+rwx $BGMBOTH/sequencelist $BGMBOTH/sequence >/dev/null 2>&1
		
		sed -i "1i \#\!\/bin\/bash" $BGMBOTH/sequence
	
	fi

	rm -f $BGMBOTH/sequencelist >/dev/null 2>&1
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
		vgm_volume=$(perl -E "say $2/100")
		[ "$vgm_volume" == "1" ] && vgm_volume="1.0"
		bgm_setvgmsetting "Volume" "$vgm_volume"
	fi

}

function bgm_setvgmsetting(){
	sed -i "s/^$1.*/$1 = $2/g" $VGMPLAYSETTINGS
}
# end of option menu related functions

function pkillstop(){
	pkill -P -STOP $LAUNCHERID >/dev/null 2>&1
}
function pkillcont(){
	pkill -P -CONT $LAUNCHERID >/dev/null 2>&1
}

function bgm_kill(){
	kill -SIGKILL -- -$LAUNCHERID >/dev/null 2>&1
}

function bgm_restart(){
	
	bgm_kill
	sleep 0.2
	bgm_init
}

execute "$@"