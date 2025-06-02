# RetroPie BGM Player v2.2
UPDATE
I forked this from Naprosnia who is the one who wrote this. All i did was fix it with the help from thesickkness who posted the fix to make the fade work again
Im just the one who is going to do my best to maintain this

A simple background music player with emulation support, to implement on RetroPie and Emulation Station based on [this](https://retropie.org.uk/forum/topic/9133/quick-and-easy-guide-for-adding-music-to-emulatonstation-on-retropie-noob-friendly) guide from RetroPie forum.



## Installation
1. `wget -N https://raw.githubusercontent.com/Exarkuniv/RetroPie_BGM_Player/master/install.sh`
2. `chmod +x install.sh`
3. `./install.sh`

## Usage
* ES setting `OTHER SETTINGS / PARSE GAMELISTS ONLY` should be `OFF`, otherwise you can not see `RetroPie-BGM-Player` options menu.
* To change settings, go to `RetroPie-BGM-Player` on RetroPie settings menu.
* Fade effect is disabled by default, go to `RetroPie-BGM-Player` settings menu to enable it.
* You don't like my music?! Easy for you, simply go to your roms folder, and inside you will find a new folder called "music", you can put there the musics you want. *You can now organize your files with subfolders as you wish.*

## Supported File Types
Emulator / Name | Extension
:---: | :---:
MPEG-2 Audio Layer III | .mp3 .ogg .flac .aac
Spectrum ZX | .ay
Sega Genesis / Megadrive | .gym
NEC PC Engine / TurboGrafx-16 | .hes
MSX / Other Z80 | .kss
GameBoy | .gbs
Nintendo | .nsf
Nintendo Ext. Support | .nsfe
Nintendo DS | .2sf
Atari SAP | .sap
Super Nintendo | .spc
Sega VGM / VGZ | .vgm / .vgz
Vortex | .vtx
Playstation Audio | .psf / .psf2

## Options
* `General Settings`
  * `Player` - Change BGM player or select what file extensions you want to play.
    * `MP3 Player`
    * `Game Music Emulator`
    * `Both Players`
    * `Custom File Types`
  * `Volume` - Change BGM Player volume.
  * `Toggle` - Set BGM Player ON/OFF.
* `Play Settings`
  * `Fade Effect` - This option enables the fading effect when music start or stop playing.
  * `Non Stop` - This option keep BGM Player playing while you play games.
  * `Delay` - Change the amount of seconds that you want to delay the BGM Player start when EmulationStation load.
* `Player Stuff`
  * `Reload Audio Files` - If you add new songs/files, this option reload them, or restart your system to reload automatically.
* `BGM Update` - Update RetroPie BGM Player

## Next Release Preview
* Add support to more file types.

## Video
[![RetroPie BGM Player](https://img.youtube.com/vi/CP-Kz6OAueM/0.jpg)](https://www.youtube.com/watch?v=CP-Kz6OAueM)

## Uninstall
1. `wget -N https://raw.githubusercontent.com/Exarkuniv/RetroPie_BGM_Player/master/uninstall.sh`
2. `chmod +x uninstall.sh`
3. `./uninstall.sh`

## Donate
You want to buy me a burger? Click the button below.

[![paypal](https://www.paypalobjects.com/en_US/i/btn/btn_donate_SM.gif)](https://www.paypal.me/naprosnia)
