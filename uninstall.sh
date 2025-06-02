#!/bin/bash 
#####################################################################
#Project		:	RetroPie_BGM_Player
#Git			:	https://github.com/Naprosnia/RetroPie_BGM_Player
#####################################################################
#Script Name	:	uninstall.sh
#Date			:	20190227	(YYYYMMDD)
#update   : 2-3-2021
#Description	:	The removal script.
#Usage			:	wget -N https://raw.githubusercontent.com/gfunkmonk/RetroPie_BGM_Player/master/uninstall.sh
#				:	chmod +x uninstall.sh
#				:	bash uninstall.sh
#Author       	:	Luis Torres aka Naprosnia
#Updater	:	Eric Ceisel aka Exarkuniv
#####################################################################
#Credits		:	crcerror : https://github.com/crcerror
#####################################################################

clear
echo -e "####################################"
echo -e "#  Uninstall RetroPie_BGM_Player  #"
echo -e "####################################\n"



RP="$HOME/RetroPie"
RPMENU="$RP/retropiemenu"
RPSETUP="$HOME/RetroPie-Setup"
RPCONFIGS="/opt/retropie/configs/all"
BGM="$HOME/RetroPie-BGM-Player"
BGMMUSICS="$RP/roms/music"
BGMOLD="$RPCONFIGS/retropie_bgm_player"
AUD="$HOME/.config/audacious"
SCRIPTPATH=$(realpath $0)
MUSICPLAYER=("mpg123" "audacious")

########################
##    kill player     ##
########################
echo -e "[Stopping Player]"
killall ${MUSICPLAYER[@]} >/dev/null 2>&1
sleep 1
########################
########################

########################
##remove older version##
########################
echo -e "[Remove older version]"
sleep 1
rm -rf $BGMOLD
[ -e $RPMENU/Background\ Music\ Settings.sh ] && rm -f $RPMENU/Background\ Music\ Settings.sh
#use sudo because, owner can be root or file created incorrectly for any reason
sudo chmod 777 $RPCONFIGS/runcommand-onstart.sh $RPCONFIGS/runcommand-onend.sh $RPCONFIGS/autostart.sh >/dev/null 2>&1
sed -i "/retropie_bgm_player\/bgm_stop.sh/d" $RPCONFIGS/runcommand-onstart.sh >/dev/null 2>&1
sed -i "/retropie_bgm_player\/bgm_play.sh/d" $RPCONFIGS/runcommand-onend.sh >/dev/null 2>&1
sed -i "/retropie_bgm_player\/bgm_init.sh/d" $RPCONFIGS/autostart.sh >/dev/null 2>&1
########################
########################

########################
##remove newer version##
########################
echo -e "[Remove newer version]"
sleep 1
rm -rf $BGM
rm -rf $AUD
[ -e $RPMENU/RetroPie-BGM-Player.sh ] && rm -f $RPMENU/RetroPie-BGM-Player.sh
sed -i "/bgm_system.sh/d" $RPCONFIGS/runcommand-onstart.sh >/dev/null 2>&1
sed -i "/bgm_system.sh/d" $RPCONFIGS/runcommand-onend.sh >/dev/null 2>&1
sed -i "/bgm_system.sh/d" $RPCONFIGS/autostart.sh >/dev/null 2>&1
rm -rf $BGMMUSICS
########################
########################

########################
##  mpg123 uninstall  ##
########################
echo -e "[Remove Music Player]\n"
sleep 1
sudo apt-get --purge remove -y ${MUSICPLAYER[@]}

echo -e "\n[Removal finished.]\n"
sleep 1
########################
########################

########################
##       Restart      ##
########################
echo -e "[Restart System]"
echo -e "-To finish, we need to reboot.\n"
read -n 1 -s -r -p "Press any key to Restart."
echo -e "\n"
(rm -f $SCRIPTPATH; sudo reboot)
########################
########################
