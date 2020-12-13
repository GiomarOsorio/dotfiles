#!/bin/bash
set -e

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
    	sudo pacman -S --noconfirm --needed $1
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
        sudo -u aurbuilder yay -S --needed $1
    fi
}

cd ~
sudo pacman -Syyu --noconfirm
sudo pacman -S --noconfirm --needed neovim git curl wget base-devel

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

for name in "${list_xfce[@]}" ; do
	count=$[count+1]
	tput setaf 3;echo "Installing package nr.  "$count " " $name;tput sgr0;
	func_install $name
done

sudo systemctl enable lightdm.service -f
sudo systemctl set-default graphical.target

## Main Desktop installed

#Creating personal directories
list_personald=(
    xdg-user-dirs
    xdg-user-dirs-gtk
)

for name in "${list_aur_packages[@]}" ; do
	count=$[count+1]
	tput setaf 3;echo "Installing package nr.  "$count " " $name;tput sgr0;
	func_install_aur $name
done

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

for name in "${list_sound[@]}" ; do
	count=$[count+1]
	tput setaf 3;echo "Installing package nr.  "$count " " $name;tput sgr0;
	func_install $name
done

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

for name in "${list_printers[@]}" ; do
	count=$[count+1]
	tput setaf 3;echo "Installing package nr.  "$count " " $name;tput sgr0;
	func_install $name
done
sudo systemctl start cups
sudo systemctl enable cups
#sudo systemctl enable org.cups.cupsd.service

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

for name in "${list_console[@]}" ; do
	count=$[count+1]
	tput setaf 3;echo "Installing package nr.  "$count " " $name;tput sgr0;
	func_install $name
done

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

for name in "${list_compressiont[@]}" ; do
	count=$[count+1]
	tput setaf 3;echo "Installing package nr.  "$count " " $name;tput sgr0;
	func_install $name
done

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

for name in "${list_system[@]}" ; do
	count=$[count+1]
	tput setaf 3;echo "Installing package nr.  "$count " " $name;tput sgr0;
	func_install $name
done

###############################################################################
#Install Services

tput setaf 11
echo "#####################################"
echo "###      INSTALLING SERVICES      ###"
echo "#####################################"

list_services=(
    networkmanager
    openssh
    cronie
    xdg-user-dirs
    haveged
    intel-ucode
)

count=0

for name in "${list_services[@]}" ; do
	count=$[count+1]
	tput setaf 3;echo "Installing package nr.  "$count " " $name;tput sgr0;
	func_install $name
done

sudo systemctl enable NetworkManager
sudo systemctl enable sshd
sudo systemctl enable cronie
sudo systemctl enable haveged

###############################################################################
#Install File System Extras

tput setaf 11
echo "#####################################"
echo "### INSTALLING FILE SYSTEM EXTRAS ###"
echo "#####################################"

list_fsystem=(
    os-prober
    dosfstools
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

for name in "${list_fsystem[@]}" ; do
	count=$[count+1]
	tput setaf 3;echo "Installing package nr.  "$count " " $name;tput sgr0;
	func_install $name
done

###############################################################################
#Install Packages

tput setaf 11
echo "#####################################"
echo "###      INSTALLING PACKAGES      ###"
echo "#####################################"

list_packages=(
    alacritty
    bashmount
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
    picom
    qbittorrent
    qtile
    ranger
    ranger
    redshift
    #redshift-gtk
    sdl_ttf
    ttf-bitstream-vera
    ttf-dejavu
    ttf-liberation
    udiskie
    #udiskie
    xorg-fonts-type1
    zsh
)

count=0

for name in "${list_packages[@]}" ; do
	count=$[count+1]
	tput setaf 3;echo "Installing package nr.  "$count " " $name;tput sgr0;
	func_install $name
done

###############################################################################
#Install AUR packages

tput setaf 11
echo "#####################################"
echo "###    INSTALLING AUR PACKAGES    ###"
echo "#####################################"

#Install ADIRUR Helper (yay)
DIR_TMP="/tmp/aurbuilder/"
DIR_YAY="/tmp/aurbuilder/yay"
[ ! -d "$DIR_TMP" ] && mkdir -p "$DIR_TMP"
cd /tmp/aurbuilder
[ -d "$DIR_YAY" ] && rm -r "$DIR_YAY"
sudo git clone https://aur.archlinux.org/yay.git
cd yay
makepkg --needed -Acs
makepkg -i
cd ~

list_aur_packages=(
    aic94xx-firmware
    bashmount
    discord_arch_electron
    google-chrome
    jdownloader2
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

for name in "${list_aur_packages[@]}" ; do
	count=$[count+1]
	tput setaf 3;echo "Installing package nr.  "$count " " $name;tput sgr0;
	func_install_aur $name
done

###############################################################################
#Set up zsh

echo "######################"
echo "### SETTING UP ZSH ###"
echo "######################"

sudo pacman -S --needed  --noconfirm zsh zsh-doc zsh-autosuggestions zsh-completions zsh-lovers tig
cp ~/dotfiles/.zshrc ~/.zshrc

## Setup oh-my-zsh
cd ~
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" &
wait
[ -d $HOME"/.oh-my-zsh" ] || echo "### OH MY ZSH DIR NOT FOUND!" ; exit 1
cd ~/.oh-my-zsh/
# Its no longer necessary to copy over oh-my-zsh.zsh
cp -vf ~/dotfiles/.oh-my-zsh/custom/*.zsh ~/.oh-my-zsh/custom/
git clone https://github.com/zsh-users/zsh-history-substring-search ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-history-substring-search

git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

git clone https://github.com/softmoth/zsh-vim-mode.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-vim-mode
