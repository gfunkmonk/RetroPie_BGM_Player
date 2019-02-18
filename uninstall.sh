#!/bin/bash 
#####################################################################
#Project		:	RetroPie_BGM_Player
#Git			:	https://github.com/Naprosnia/RetroPie_BGM_Player
#####################################################################
#Script Name	:	uninstall.sh
#Date			:	20190218	(YYYYMMDD)
#Description	:	The removal script.
#Usage			:	wget -N https://raw.githubusercontent.com/Naprosnia/RetroPie_BGM_Player/master/uninstall.sh
#				:	chmod +x uninstall.sh
#				:	bash uninstall.sh
#Author       	:	Luis Torres aka Naprosnia
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
BGMCONTROL="$BGM/bgm_control"
BGMMUSICS="$RP/roms/music"
BGMOLD="$RPCONFIGS/retropie_bgm_player"
MUSICPLAYER="mpg123"

########################
##    kill player     ##
########################
echo -e "[Stopping Player]"
killall $MUSICPLAYER >/dev/null 2>&1
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
sudo chmod 777 $RPCONFIGS/runcommand-onstart.sh $RPCONFIGS/runcommand-onend.sh $RPCONFIGS/autostart.sh
sed -i "/retropie_bgm_player\/bgm_stop.sh/d" $RPCONFIGS/runcommand-onstart.sh
sed -i "/retropie_bgm_player\/bgm_play.sh/d" $RPCONFIGS/runcommand-onend.sh
sed -i "/retropie_bgm_player\/bgm_init.sh/d" $RPCONFIGS/autostart.sh
########################
########################

########################
##remove newer version##
########################
echo -e "[Remove newer version]"
sleep 1
rm -rf $BGM
[ -e $RPMENU/RetroPie-BGM-Player.sh ] && rm -f $RPMENU/RetroPie-BGM-Player.sh
sed -i "/bgm_system.sh/d" $RPCONFIGS/runcommand-onstart.sh
sed -i "/bgm_system.sh/d" $RPCONFIGS/runcommand-onend.sh
sed -i "/bgm_system.sh/d" $RPCONFIGS/autostart.sh
rm -rf $BGMMUSICS
########################
########################

########################
##  mpg123 uninstall  ##
########################
echo -e "[Remove Music Player]\n"
sleep 1
sudo apt-get --purge remove -y $MUSICPLAYER

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
(rm -f realpath $0; sudo reboot)
########################
########################