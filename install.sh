#!/bin/bash

###############################################################################
#
#   DECLARATION OF FUNCTIONS
#
###############################################################################


func_install() {
	if pacman -Qi $1 &> /dev/null; then
		tput setaf 2
  		echo "###############################################################################"
  		echo "################## The package "$1" is already installed"
      	echo "###############################################################################"
      	echo
		tput sgr0
	else
    	tput setaf 3
    	echo "###############################################################################"
    	echo "##################  Installing package "  $1
    	echo "###############################################################################"
    	echo
    	tput sgr0
    	su pacman -S --noconfirm --needed $1
    fi
}

func_install_aur() {
	if yay -Qia $1 &> /dev/null; then
		tput setaf 2
  		echo "###############################################################################"
  		echo "################## The package "$1" is already installed"
      	echo "###############################################################################"
      	echo
		tput sgr0
	else
    	tput setaf 3
    	echo "###############################################################################"
    	echo "##################  Installing package "  $1
    	echo "###############################################################################"
    	echo
    	tput sgr0
        su -u aurbuilder yay -S --needed $1
    fi
}

cd ~
set -e
tput setaf 11
echo "#####################################"
echo "###     ENABLE MULTILIB REPO      ###"
echo "#####################################"
su sed -i '/\[multilib\]/s/^#//g' /etc/pacman.conf
su sed -i '/\[multilib\]/{n;s/^#//g}' /etc/pacman.conf
tput setaf 11
echo "#####################################"
echo "###     INSTALL BASE PACKAGES     ###"
echo "#####################################"
tput sgr0
su pacman -Syyu --noconfirm
su pacman -S --noconfirm --needed neovim git curl wget base base-devel

###############################################################################
#Install LightDM and XFCE4

tput setaf 11
echo "#####################################"
echo "###       INSTALLING XFCE4        ###"
echo "#####################################"

list_xfce=(
    lightdm
    lightdm-gtk-greeter
    lightdm-gtk-greeter-settings
    xfce4
    xfce4-goodies
)

count=0

for name in "${list_xfce[@]}" ; 
	count=$[count+1]
	tput setaf 3;echo "Installing package nr.  "$count " " $name;tput sgr0;
	func_install $name
ne

su systemctl enable lightdm.service -f
su systemctl set-default graphical.target

## Main Desktop installed

#Creating personal directories
list_personald=(
    xdg-user-dirs
    xdg-user-dirs-gtk
)

for name in "${list_aur_packages[@]}" ; 
	count=$[count+1]
	tput setaf 3;echo "Installing package nr.  "$count " " $name;tput sgr0;
	func_install_aur $name
ne

xdg-user-dirs-update
xdg-user-dirs-update --force

[ -d $HOME"/.icons" ] || mkdir -p $HOME"/.icons"
[ -d $HOME"/.themes" ] || mkdir -p $HOME"/.themes"
[ -d $HOME"/.fonts" ] || mkdir -p $HOME"/.fonts"

###############################################################################
#Install Sound

tput setaf 11
echo "#####################################"
echo "###       INSTALLING SOUND        ###"
echo "#####################################"

list_sound=(
pulseaudio
pulseaudio-alsa
pavucontrol
alsa-utils
alsa-plugins
alsa-lib
alsa-firmware
gstreamer
gst-plugins-good
gst-plugins-bad
gst-plugins-base
gst-plugins-ugly
volumeicon
playerctl
)

count=0

for name in "${list_sound[@]}" ; 
	count=$[count+1]
	tput setaf 3;echo "Installing package nr.  "$count " " $name;tput sgr0;
	func_install $name
ne

###############################################################################
#Install printing stuff

tput setaf 11
echo "#####################################"
echo "###      INSTALLING PRINTERS      ###"
echo "#####################################"

list_printers=(
    cups
    cups-pdf
    ghostscript
    gsfonts gutenprint
    gtk3-print-backends
    libcups
    hplip
    system-config-printer
)

count=0

for name in "${list_printers[@]}" ; 
	count=$[count+1]
	tput setaf 3;echo "Installing package nr.  "$count " " $name;tput sgr0;
	func_install $name
ne
su systemctl start cups
su systemctl enable cups
#su systemctl enable org.cups.cupsd.service

###############################################################################
#Install Console stuff

tput setaf 11
echo "#####################################"
echo "###      INSTALLING CONSOLE       ###"
echo "#####################################"

list_console=(
    pacman-contrib
    base-devel
    bash-completion
    usbutils
    dmidecode
    dialog
    gpm
)

count=0

for name in "${list_console[@]}" ; 
	count=$[count+1]
	tput setaf 3;echo "Installing package nr.  "$count " " $name;tput sgr0;
	func_install $name
ne

###############################################################################
#Install Compression Tools

tput setaf 11
echo "#####################################"
echo "###  INSTALLING COMPRESION TOOLS  ###"
echo "#####################################"

list_compressiont=(
    zip
    unzip
    unrar
    p7zip
    lzop
)

count=0

for name in "${list_compressiont[@]}" ; 
	count=$[count+1]
	tput setaf 3;echo "Installing package nr.  "$count " " $name;tput sgr0;
	func_install $name
ne

###############################################################################
#Install Kernel Stuff

tput setaf 11
echo "#####################################"
echo "###    INSTALLING SYSTEM STUFF    ###"
echo "#####################################"

list_system=(
    linux
    linux-headers
)

count=0

for name in "${list_system[@]}" ; 
	count=$[count+1]
	tput setaf 3;echo "Installing package nr.  "$count " " $name;tput sgr0;
	func_install $name
ne

###############################################################################
#Install Services

tput setaf 11
echo "#####################################"
echo "###      INSTALLING SERVICES      ###"
echo "#####################################"
tput sgr0

list_services=(
    networkmanager
    openssh
    cronie
    xdg-user-dirs
    haveged
    intel-ucode
)

count=0

for name in "${list_services[@]}" ; 
	count=$[count+1]
	tput setaf 3;echo "Installing package nr.  "$count " " $name;tput sgr0;
	func_install $name
ne

su systemctl enable NetworkManager
su systemctl enable sshd
su systemctl enable cronie
su systemctl enable haveged

###############################################################################
#Install File System Extras

tput setaf 11
echo "#####################################"
echo "### INSTALLING FILE SYSTEM EXTRAS ###"
echo "#####################################"
tput sgr0

list_fsystem=(
    os-prober
    sfstools
    ntfs-3g
    btrfs-progs
    exfat-utils
    gptfdisk
    autofs
    fuse2
    fuse3
    fuseiso
)

count=0

for name in "${list_fsystem[@]}" ; 
	count=$[count+1]
	tput setaf 3;echo "Installing package nr.  "$count " " $name;tput sgr0;
	func_install $name
ne

###############################################################################
#Install Packages

tput setaf 11
echo "#####################################"
echo "###      INSTALLING PACKAGES      ###"
echo "#####################################"
tput sgr0

list_packages=(
    alacritty
    bashmount
    ctags
    dunst
    firefox
    flameshot
    font-bh-ttf
    gsfonts
    hunspell
    hunspell-es_ve
    hyphen
    hyphen-es
    kolourpaint
    languagetool
    libreoffice-fresh
    mpv
    mythes-es
    ncmpcpp
    nodejs
    npm
    picom
    python-pip
    python-neovim
    qbittorrent
    qtile
    ranger
    ranger
    redshift
    sdl_ttf
    tig
    ttf-bitstream-vera
    ttf-dejavu
    ttf-liberation
    udiskie
    xorg-fonts-type1
    zsh
    zsh
    zsh-c
    zsh-autosuggestions
    zsh-completions
    zsh-lovers
)

count=0

for name in "${list_packages[@]}" ; 
	count=$[count+1]
	tput setaf 3;echo "Installing package nr.  "$count " " $name;tput sgr0;
	func_install $name
ne

###############################################################################
#Install AUR packages

tput setaf 11
echo "#####################################"
echo "###    INSTALLING AUR PACKAGES    ###"
echo "#####################################"
tput sgr0

#Install ADIRUR Helper (yay)
tmpdir="$(command mktemp -d)"
command cd "${tmpdir}" || return 1
dl_url="$(
    command curl -sfLS 'https://api.github.com/repos/Jguer/yay/releases/latest' |
    command grep 'browser_wnload_url' |
    command tail -1 |
    command cut -d '"' -f 4
)"
command wget "${dl_url}"
command tar xzvf yay_*_x86_64.tar.gz
command cd yay_*_x86_64 || return 1
./yay -Sy --nocleanmenu --nodiffmenu yay-bin
rm -rf "${tmpdir}"

list_aur_packages=(
    aic94xx-firmware
    bashmount
    discord_arch_electron
    google-chrome
    jwnloader2
    megasync
    minecraft-launcher
    nerd-fonts-ubuntu-mono
    nvidia-390xx-dkms
    nvidia-390xx-settings
    nvidia-390xx-utils
    opencl-nvidia-390xx
    runelite-launcher
    ttf-ms-fonts
    ventoy-bin
    visual-studio-code-bin
    wd719x-firmware
    zoom
)

count=0

for name in "${list_aur_packages[@]}" ; 
	count=$[count+1]
	tput setaf 3;echo "Installing package nr.  "$count " " $name;tput sgr0;
	func_install_aur $name
ne

###############################################################################
#Clone Dotfiles

cd
if [ ! -d "~/tfiles" ] ; then
    git clone https://github.com/GiomarOsorio/tfiles.git
else
    cd "~/tfiles"
    git pull origin master
fi

###############################################################################
#Set up zsh

tput setaf 11
echo "######################"
echo "### SETTING UP ZSH ###"
echo "######################"
tput sgr0

#move config to folder
cp ~/tfiles/.zshrc ~/.zshrc

## Setup oh-my-zsh
cd ~
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" &
wait
[ -d $HOME"/.oh-my-zsh" ] || echo "### OH MY ZSH DIR NOT FOUND!" ; exit 1

#install powerlevel10k
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

###############################################################################
#Setup vim with powerline that we installed before (but no plugins)

tput setaf 11
echo "######################"
echo "### SETTING UP VIM ###"
echo "######################"
tput sgr0

#Install dependencies
#Python dependencies
pip install virtualenv pynvim python-language-server flake8 pylint black jedi
#Node dependencies
npm install neovim eslint eslint-config-airbnb-base --save-dev

#copy config file
cd ~
cp -vf ~/tfiles/.config/nvim ~/.config/
cp -vf ~/tfiles/.eslintrc.json .

###############################################################################
#Set up Qtile

tput setaf 11
echo "########################"
echo "### SETTING UP QTILE ###"
echo "########################"
tput sgr0

#copy config file
cd ~
cp -vf ~/tfiles/.config/qtile ~/.config/

###############################################################################
#Setup Ranger

tput setaf 11
echo "#################################"
echo "### SETTING UP RANGER CONFIGS ###"
echo "#################################"
tput sgr0

cp -vf ~/tfiles/.config/ranger/ ~/.config/

# Add devicons to ranger
git clone https://github.com/alexanderjeurissen/ranger_devicons ~/.config/ranger/plugins/ranger_devicons

