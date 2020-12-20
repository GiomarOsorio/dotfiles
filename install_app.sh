#!/bin/bash
enabledmultilib(){
    showtitle "ENABLING MULTILIB REPO"
	showcommand "sudo sed -i \'/\[multilib\]/s/^#//g\' /etc/pacman.conf"
	showcommand "sudo sed -i \'/\[multilib\]/{n;s/^#//g}\' /etc/pacman.conf"
	sudo sed -i '/\[multilib\]/s/^#//g' /etc/pacman.conf
	sudo sed -i '/\[multilib\]/{n;s/^#//g}' /etc/pacman.conf
}
installdependencies(){
    dependencies="neovim git curl wget base base-devel"
    showtitle "INSTALLING DEPENDENCIES"
    installpkgs "${dependencies}"
    installyay
    cloningrepo
}
installyay(){
    showtitle "INSTALLING YAY"
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
}
cloningrepo(){
    showtitle "CLONING DOTFILES REPO"
    if [ ! -d "~/dotfiles" ] ; then
        cd
        git clone ${txturlrepo}
    else
        cd "~/dotfiles"
        git pull origin master
    fi
}
installpkgs() {
    if  [ ! "${2}" = "none"  ]; then
        showtitle "${2}"
    fi
    if  [ ! "${3}" = "none"  ]; then
        showcommand "$3 $1"
        $3 $1
    else
        showcommand "pacman -S --noconfirm --needed $1"
        pacman -S --noconfirm --needed $1
    fi
    pressanykey
}
installaurpkgs() {
    if  [ ! "${2}" = "none"  ]; then
        showtitle "${2}"
    fi
    showcommand "sudo -u aurbuilder yay -S --needed $2"
    sudo -u aurbuilder yay -S --needed $1
    pressanykey
}
helpersystemctl(){
    if [ "${1}" = "enable" ]
        for i in "${$2[@]}"; do   # The quotes are necessary here
            showcommand "systemctl enable ${i} -f"
            su systemctl "${1}" "${i}" -f
        done
	else
	    su systemctl "${1}" "{2}"
	fi
}
updatedir(){
    xdg-user-dirs-update
    xdg-user-dirs-update --force
    [ -d $HOME"/.icons" ] || mkdir -p $HOME"/.icons"
    [ -d $HOME"/.themes" ] || mkdir -p $HOME"/.themes"
    [ -d $HOME"/.fonts" ] || mkdir -p $HOME"/.fonts"
}
copy(){
    if  [  \( ! "${1}" = "none" \)  -a [  \( ! "${2}" = "none" \) ]; then
        cd ~
        cp -vf "${1}" "${2}"
    fi
}
run(){
    enabledmultilib
    installdependencies
	
    # xfce -----------------------------------------
    installpkgs "${pkgs_xfce}" "${titlexfce}"
    helpersystemctl "enable" "${services_xfce}"
    helpersystemctl "set-default" "graphical.target"
    updatedir
	
    # sound ----------------------------------------
    installpkgs "${pkgs_sound}" "${titlesound}"
	
    # printer --------------------------------------
    installpkgs "${pkgs_printer}" "${titleprinter}"
    helpersystemctl "start" "${services_printer}"
    helpersystemctl "enable" "${services_printer}"
	
    # console --------------------------------------
    installpkgs "${pkgs_console}" "${titleconsole}"
	
    # compression tools ----------------------------
    installpkgs "${pkgs_compressiontools}" "${titlecompressiontools}"
	
    # kernel --------------------------------------
    installpkgs "${pkgs_kernel}" "${titlekernel}"
	
    # kernel --------------------------------------
    installpkgs "${pkgs_kernel}" "${titlekernel}"
	
    # services ------------------------------------
    installpkgs "${pkgs_services}" "${titleservices}"
    helpersystemctl "enable" "${services_services}"
	
    # file system extras ---------------------------
    installpkgs "${pkgs_filesystemextras}" "${titlefilesystemextras}"
	
    # general packages -----------------------------
    installpkgs "${pkgs_generalpackages}" "${titlegeneralpackages}"
	
    # aur packages ---------------------------------
    installaurpkgs "${pkgs_aurpackages}" "${titleaurpackages}"
    
    # setup vim ------------------------------------
    installaurpkgs "${pkgs_pip_vim}" "${titlesvim}" "${command_pip_vim}"
    installaurpkgs "${pkgs_npm_vim}" "${titlesvim}" "${command_npm_vim}"
    copy "~/dotfiles/.config/nvim" "~/.config/"
    copy "~/dotfiles/.eslintrc.json" "~"
    
    # setup qtile ----------------------------------
    copy "~/tfiles/.config/qtile" "~/.config/"

    # setup ranger ----------------------------------
    copy "~/tfiles/.config/ranger" "~/.config/"
}
# --------------------------------------------------------
pressanykey(){
    tput setaf 3
	read -n1 -p "${txtpressanykey}"
	echo ""
	tput sgr0
}

showcommand(){
    tput setaf 2
    if [ ! "${1}" = "none" ]; then
        echo -e "${txtcommand//%1/${1}}"
    fi
	tput sgr0
}
showmessage(){
    tput setaf 6
    if [ ! "${1}" = "none" ]; then
        echo -e "${txtmessage//%1/${1}}"
    fi
	tput sgr0
}
showtitle(){
	tput setaf 5
	echo "##############################################"
	echo "${1}"
	echo "##############################################"
	echo ""
	tput sgr0
}
# --------------------------------------------------------
loadstrings(){
    # repo -----------------------------------------
    txturlrepo="https://github.com/GiomarOsorio/dotfiles.git"
	
    # xfce -----------------------------------------
    titlexfce="INSTALLING XFCE4"
    pkgs_xfce="lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings xfce4 xfce4-goodies xdg-user-dirs xdg-user-dirs-gtk"
    services_xfce=("lightdm.service")
	
	# sound ----------------------------------------
    titlesound="INSTALLING SOUND"
    pkgs_sound="pulseaudio pulseaudio-alsa pavucontrol alsa-utils alsa-plugins alsa-lib alsa-firmware gstreamer gst-plugins-good gst-plugins-bad gst-plugins-base gst-plugins-ugly volumeicon playerctl"
	
    # printer --------------------------------------
    titleprinter="INSTALLING PRINTER"
    pkgs_printer="cups cups-pdf ghostscript gsfonts gutenprint gtk3-print-backends libcups hplip system-config-printer"
    services_printer=("cups")
	
    # console --------------------------------------
    titleconsole="INSTALLING CONSOLE"
    pkgs_console="pacman-contrib base-devel bash-completion usbutils dmidecode dialog gpm"
	
    # compression tools ----------------------------
    titlecompressiontools="INSTALLING COMPRESION TOOLS"
    pkgs_compressiontools="zip unzip unrar p7zip lzop"
    
	# services -------------------------------------
    titleservices="INSTALLING SERVICES PACKAGES"
    pkgs_services="networkmanager openssh cronie haveged intel-ucode"
    services_services=("NetworkManager" "sshd" "cronie" "haveged")

    # file system extras ---------------------------
    titlefilesystemextras="INSTALLING FILE SYSTEM EXTRAS"
    pkgs_filesystemextras="os-prober sfstools ntfs-3g btrfs-progs exfat-utils gptfdisk autofs fuse2 fuse3 fuseiso"
    
    # general packages -----------------------------
    titlegeneralpackages="INSTALLING GENERAL PACKAGES"
    pkgs_generalpackages="alacritty bashmount ctags dunst firefox flameshot font-bh-ttf gsfonts hunspell hunspell-es_ve hyphen hyphen-es kolourpaint languagetool libreoffice-fresh mpv mythes-es ncmpcpp nodejs npm picom python-pip python-neovim qbittorrent qtile ranger redshift sdl_ttf tig ttf-bitstream-vera ttf-dejavu ttf-liberation udiskie xorg-fonts-type1 zsh zsh zsh-c zsh-autosuggestions zsh-completions zsh-lovers"

    # aur packages ---------------------------------
    titleaurpackages="INSTALLING AUR PACKAGES"
    pkgs_aurpackages="aic94xx-firmware bashmount discord_arch_electron google-chrome jwnloader2 megasync minecraft-launcher nerd-fonts-ubuntu-mono nvidia-390xx-dkms nvidia-390xx-settings nvidia-390xx-utils opencl-nvidia-390xx runelite-launcher ttf-ms-fonts ventoy-bin visual-studio-code-bin wd719x-firmware zoom"

	# setup vim ------------------------------------
    titlesvim="SETTING UP VIM"
    command_pip_vim="pip install"
    pkgs_pip_vim="virtualenv pynvim python-language-server flake8 pylint black jedi"
    command_npm_vim="npm install"
    pkgs_npm_vim="neovim eslint eslint-config-airbnb-base --save-dev"	
}
while (( "$#" )); do
  case $1 in
    -i|--install) install
                  exit 0;;
    --chroot) chrootoption="true";;
  esac
  shift
done
run