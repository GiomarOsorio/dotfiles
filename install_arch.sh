#!/bin/bash
# --------------------------------------------------------
checkefi(){
    dmesg |grep efi: > /dev/null
    if [ "$?" == "1" ]; then
    if [ "${eficomputer}" != "1" ]; then
        eficomputer=0
    fi
    else
        eficomputer=1
    fi
}
# --------------------------------------------------------
setkeymap(){
	showtitle "LOADING KEYMAP"
	echo ">loadkeys ${keymap}"
	echo ""
	loadkeys $keymap
}

# --------------------------------------------------------
chooseeditor(){
    showtitle "SETTING EDITOR"
	echo ">export EDITOR=${editor}"
	echo ""
	export EDITOR=${editor}
	EDITOR=${editor}
}

# --------------------------------------------------------
selectdisk(){
	showtitle "SELECTING HARD DISK"
    tput setaf 3
    echo "Select the installation hard drive on the next screen"	
    tput setaf 2
    pressanykey
    items=$(lsblk -d -p -n -l -o NAME,SIZE -e 7,11)
    options=()
    IFS_ORIG=$IFS
    IFS=$'\n'
    for item in ${items}
    do  
        options+=("${item}" "")
    done
    IFS=$IFS_ORIG
    while [ -z "$device" ]; do
        device=$(whiptail --backtitle "Arch Install Script" --title "${title_hd}" --menu "${menu_hd}" 0 0 0 "${options[@]}" 3>&1 1>&2 2>&3);
    done
    clear
    device=${device%%\ *}
    echo ">select "${device}
    echo ""
}
# --------------------------------------------------------
selectswapsize(){
    showtitle "SELECTING SWAP SIZE"
    tput setaf 6
    echo -e "${txt_swap}"
    tput setaf 3
	echo -e "Select the size of the swap partition on the next screen"	
    tput setaf 2
	pressanykey
    swap_size=$(whiptail --backtitle "Arch Install Script" --inputbox "${menu_swap}" 8 39 ${default_swapsize} --title "${title_swap}" 3>&1 1>&2 2>&3)
    clear
    [[ $swap_size =~ ^[0-9]+$ ]] || swap_size=$default_swapsize
	echo ">have selected "${swap_size%%\ *}"MB in swap size"
	echo ""
}
# --------------------------------------------------------
diskpart(){
    re='^[1-3]$'
    showtitle "PARTIATING DEVICE"
    options="[1] Auto Partition (dos)\n"
    options+="[2] Auto Partition (gpt)\n"
    if [ "${eficomputer}" == "1" ]; then
        options+="[3] Auto Partition (gpt,efi)\n"
    fi
    echo -e "${txt_diskpart}"
    echo -e "${options}"
    while true;do
        echo -e "Select one option: "
        read partitiontable
        if ! [[ $partitiontable =~ $re ]] ; then
            echo -e "Invalid option, try again\n"
        else
            echo ""
            break 
        fi
    done
    case ${partitiontable} in
        "1")
            #"[1] Auto Partition (dos)\n"
            diskpartautodos
        ;;
        "2")
            #"[2] Auto Partition (gpt)\n"
            diskpartautogpt
        ;;
        "3")
            #"[3] Auto Partition (gpt,efi)\n"
            diskpartautogptefi
        ;;
    esac
    if [ "bootdev::" == "/dev/nvm" ]; then
	    isnvme=1
    fi
    if [ "bootdev::" == "/dev/nvm" ]; then
	    isnvme=1
    fi
}
# --------------------------------------------------------
diskpartautodos(){
    tput setaf 6
    echo "${txtautopartclear}"
    tput setaf 2
    parted ${device} mklabel msdos
    sleep 1
    tput setaf 6
    echo "${txtautopartcreate//%1/boot}"
    tput setaf 2
    echo -e "n\np\n\n\n+512M\na\nw" | fdisk ${device}
    sleep 1
    tput setaf 6
    echo "${txtautopartcreate//%1/swap}"
    tput setaf 2
    echo -e "n\np\n\n\n+${swap_size}"M"\nt\n\n82\nw" | fdisk ${device}
    sleep 1
    tput setaf 6
    echo "${txtautopartcreate//%1/root}"
    tput setaf 2
    echo -e "n\np\n\n\n\nw" | fdisk ${device}
    sleep 1
    echo ""
    if [ "${device::8}" == "/dev/nvm" ]; then
        bootdev=${device}"p1"
        swapdev=${device}"p2"
        rootdev=${device}"p3"
    else
        bootdev=${device}"1"
        swapdev=${device}"2"
        rootdev=${device}"3"
    fi
    efimode="0"
}
# --------------------------------------------------------
diskpartautogpt(){
    tput setaf 6
    echo "${txtautopartclear}"
    tput setaf 2
    parted ${device} mklabel gpt
    tput setaf 6
    echo "${txtautopartcreate//%1/BIOS boot}"
    tput setaf 2
    sgdisk ${device} -n=1:0:+31M -t=1:ef02
    tput setaf 6
    echo "${txtautopartcreate//%1/boot}"
    tput setaf 2
    sgdisk ${device} -n=2:0:+512M
    tput setaf 6
    echo "${txtautopartcreate//%1/swap}"
    tput setaf 2
    sgdisk ${device} -n=3:0:+${swap_size}"M" -t=3:8200
    tput setaf 6
    echo "${txtautopartcreate//%1/root}"
    tput setaf 2
    sgdisk ${device} -n=4:0:0
    echo ""
    if [ "${device::8}" == "/dev/nvm" ]; then
        bootdev=${device}"p2"
        swapdev=${device}"p3"
        rootdev=${device}"p4"
    else
        bootdev=${device}"2"
        swapdev=${device}"3"
        rootdev=${device}"4"
    fi
    efimode="0"
}
# --------------------------------------------------------
diskpartautogptefi(){
    tput setaf 6
    echo "${txtautopartclear}"
    tput setaf 2
    parted ${device} mklabel gpt
    tput setaf 6
    echo "${txtautopartcreate//%1/EFI boot}"
    tput setaf 2
    sgdisk ${device} -n=1:0:+1024M -t=1:ef00
    tput setaf 6
    echo "${txtautopartcreate//%1/swap}"
    tput setaf 2
    sgdisk ${device} -n=2:0:+${swap_size}"M" -t=2:8200
    tput setaf 6
    echo "${txtautopartcreate//%1/root}"
    tput setaf 2
    sgdisk ${device} -n=3:0:0
    echo ""
    if [ "${device::8}" == "/dev/nvm" ]; then
        bootdev=${device}"p1"
        swapdev=${device}"p2"
        rootdev=${device}"p3"
    else
        bootdev=${device}"1"
        swapdev=${device}"2"
        rootdev=${device}"3"
    fi
    efimode="1"
}
# --------------------------------------------------------
formatdevice(){
    showtitle "FORMATTING PARTITIONS"
    if [ ! "${bootdev}" = "" ]; then
        formatbootdevice boot ${bootdev}
    fi
    if [ ! "${swapdev}" = "" ]; then
        formatswapdevice swap ${swapdev}
    fi
    formatrootdevice root ${rootdev}
    if [ ! "${homedev}" = "" ]; then
        formatrootdevice home ${homedev}
    fi
}
# --------------------------------------------------------
formatbootdevice(){
    options=""
    re='^[1-3]$'
    if [ "${efimode}" == "1" ]||[ "${efimode}" = "2" ]; then
        re='^[0-3]$'
        options+="[0] fat32 (EFI)\n"
    fi
    options+="[1] ext2\n"
    options+="[2] ext3\n"
    options+="[3] ext4\n"
    echo -e "${txtselectpartformat//%1/${1} (${2})}"
    echo -e "${options}"
    while true;do
        echo -e "Select one option: "
        read sel 
        if ! [[ $sel =~ $re ]] ; then
            echo -e "Invalid option, try again\n"
        else
            case ${sel} in
                "0")
                    formatboot="fat32"
                    ;;
                "1")
                    formatboot="ext2"
                    ;;
                "2")
                    formatboot="ext3"
                    ;;
                "3")
                    formatboot="ext4"
                    ;;
            esac
            echo ""
            break 
        fi
    done
    tput setaf 6
    echo -e "\n${txtformatingpart//%1/${2}} ${formatboot}"
    echo -e "----------------------------------------------"
    tput setaf 2
    case ${formatboot} in
        "ext2")
            echo ">mkfs.ext2 ${2}"
            mkfs.ext2 ${2}
        ;;
        "ext3")
            echo ">mkfs.ext3 ${2}"
            mkfs.ext3 ${2}
        ;;
        "ext4")
            echo ">mkfs.ext4 ${2}"
            mkfs.ext4 ${2}
        ;;
        "fat32")
            fspkgs="${fspkgs[@]} dosfstools"
            echo ">mkfs.fat ${2}"
            mkfs.fat ${2}
        ;;
    esac
    echo ""
}
# --------------------------------------------------------
formatswapdevice(){
    tput setaf 6
    echo "${txtformatingpart//%1/${swapdev}} swap"
    echo "----------------------------------------------------"
    tput setaf 2
    echo ">mkswap ${swapdev}"
    mkswap ${swapdev}
    echo ""
    }
# --------------------------------------------------------
formatrootdevice(){
    re='^[1-8]$'
    options=""
    options+="[1] btrfs\n"
    options+="[2] ext4\n"
    options+="[3] ext3\n"
    options+="[4] ext2\n"
    options+="[5] xfs\n"
    options+="[6] f2fs\n"
    options+="[7] jfs\n"
    options+="[8] reiserfs\n"
    echo -e "${txtselectpartformat//%1/${1} (${2})}"
    echo -e "${options}"
    while true;do
        echo -e "Select one option: "
        read sel 
        if ! [[ $sel =~ $re ]] ; then
            echo -e "Invalid option, try again\n"
        else
            case ${sel} in
                "1")
                    formatroot="btrfs"
                    ;;
                "2")
                    formatroot="ext4"
                    ;;
                "3")
                    formatroot="ext3"
                    ;;
                "4")
                    formatroot="ext2"
                    ;;
                "5")
                    formatroot="xfs"
                    ;;
                "6")
                    formatroot="f2fs"
                    ;;
                "7")
                    formatroot="jfs"
                    ;;
                "8")
                    formatroot="reiserfs"
                    ;;
            esac
            echo ""
            break 
        fi
    done
    tput setaf 6
    echo "${txtformatingpart//%1/${2}} ${formatroot}"
    echo "----------------------------------------------"
    tput setaf 2
    case ${formatroot} in
        "btrfs")
            fspkgs="${fspkgs[@]} btrfs-progs"
            echo "mkfs.btrfs -f ${2}"
            mkfs.btrfs -f ${2}
            if [ "${1}" = "root" ]; then
                echo "mount ${2} /mnt"
                echo "btrfs subvolume create /mnt/root"
                echo "btrfs subvolume set-default /mnt/root"
                echo "umount /mnt"
                mount ${2} /mnt
                btrfs subvolume create /mnt/root
                btrfs subvolume set-default /mnt/root
                umount /mnt
            fi
        ;;
        "ext4")
            echo ">mkfs.ext4 ${2}"
            mkfs.ext4 ${2}
        ;;
        "ext3")
            echo ">mkfs.ext3 ${2}"
            mkfs.ext3 ${2}
        ;;
        "ext2")
            echo ">mkfs.ext2 ${2}"
            mkfs.ext2 ${2}
        ;;
        "xfs")
            fspkgs="${fspkgs[@]} xfsprogs"
            echo ">mkfs.xfs -f ${2}"
            mkfs.xfs -f ${2}
        ;;
        "f2fs")
            fspkgs="${fspkgs[@]} f2fs-tools"
            echo ">mkfs.f2fs -f $2"
            mkfs.f2fs -f $2
        ;;
        "jfs")
            fspkgs="${fspkgs[@]} jfsutils"
            echo ">mkfs.jfs -f ${2}"
            mkfs.jfs -f ${2}
        ;;
        "reiserfs")
            fspkgs="${fspkgs[@]} reiserfsprogs"
            echo ">mkfs.reiserfs -f ${2}"
            mkfs.reiserfs -f ${2}
        ;;
    esac
    echo ""
    }
# --------------------------------------------------------
mountparts(){
    showtitle "MOUNTING THE FILE SYSTEM"
    echo ">mount ${rootdev} /mnt"
    mount ${rootdev} /mnt
        echo ">mkdir /mnt/{boot,home}"
        mkdir /mnt/{boot,home} 2>/dev/null
    if [ ! "${bootdev}" = "" ]; then
        echo ">mount ${bootdev} /mnt/boot"
        mount ${bootdev} /mnt/boot
    fi
    if [ ! "${swapdev}" = "" ]; then
        echo ">swapon ${swapdev}"
        swapon ${swapdev}
    fi
    if [ ! "${homedev}" = "" ]; then
        echo ">mount ${homedev} /mnt/home"
        mount ${homedev} /mnt/home
    fi
    echo ""
}
# --------------------------------------------------------
installmenu(){
    re='^[1-2]$'
    options=""
    showtitle "INSTALATION MENU"
    options+="[1] ${txteditmirrorlist}\n"
    options+="[2] ${txtinstallarchlinux}\n"
    echo -e "${textinstallmenu}"
    echo -e "${options}"
    while true;do
        echo -e "Select one option: "
        read sel 
        if ! [[ $sel =~ $re ]] ; then
            echo -e "Invalid option, try again\n"
        else
            echo ""
            break 
        fi
    done
    case ${sel} in
        "1")
            #"${txteditmirrorlist}")
            ${editor} /etc/pacman.d/mirrorlist
            clear
        ;;
        "2")
            #"${txtinstallarchlinux}")
            installbase
	        installed=1
        ;;
    esac
    if [[ ${installed} != 0 ]]; then
        archmenu
    else
        installmenu
    fi
}
# --------------------------------------------------------
installbase(){
    re='^[1-4]$'
    pkgs="base"
    options=""
    options+="[1] linux\n"
    options+="[2] linux-lts\n"
    options+="[3] linux-zen\n"
    options+="[4] linux-hardened\n"
    echo -e "${txtinstallarchlinuxkernel}"
    echo -e "${options}"
    while true;do
        echo -e "Select one option: "
        read sel 
        if ! [[ $sel =~ $re ]] ; then
            echo -e "Invalid option, try again\n"
        else
            case ${sel} in
                "1")
                    pkgs+=" linux"
                    ;;
                "2")
                    pkgs+=" linux-lts"
                    ;;
                "3")
                    pkgs+=" linux-zen"
                    ;;
                "4")
                    pkgs+=" linux-hardened"
                    ;;
            esac
            echo ""
            break 
        fi
    done
    
    re='^[1]$'
    options=""
    options+="[1] linux-firmware\n"
    echo -e "${txtinstallarchlinuxfirmwares}"
    echo -e "${options}"
    while true;do
        echo -e "Select one option: "
        read sel 
        if ! [[ $sel =~ $re ]] ; then
            echo -e "Invalid option, try again\n"
        else
            case ${sel} in
                "1")
                    pkgs+=" linux-firmware"
                    ;;
            esac
            echo ""
            break 
        fi
    done

    options=""
    if [[ "${fspkgs}" == *"dosfstools"* ]]; then
        options+="[1] (*)dosfstools\n"
        pkgs+=" dosfstools"
    else
        options+="[1] ( )dosfstools\n"
    fi
    if [[ "${fspkgs}" == *"btrfs-progs"* ]]; then
        options+="[2] (*)btrfs-progs\n"
        pkgs+=" btrfs-progs"
    else
        options+="[2] ( )btrfs-progs\n"
    fi
    if [[ "${fspkgs}" == *"xfsprogs"* ]]; then
        options+="[3] (*)xfsprogs\n"
        pkgs+=" xfsprogs"
    else
        options+="[3] ( )xfsprogs\n"
    fi
    if [[ "${fspkgs}" == *"f2fs-tools"* ]]; then
        options+="[4] (*)f2fs-tools\n"
        pkgs+=" f2fs-tools"
    else
        options+="[4] ( )f2fs-tools\n"
    fi
    if [[ "${fspkgs}" == *"jfsutils"* ]]; then
        options+="[5] (*)jfsutils\n"
        pkgs+=" jfsutils"
    else
        options+="[5] ( )jfsutils\n"
    fi
    if [[ "${fspkgs}" == *"reiserfsprogs"* ]]; then
        options+="[6] (*)reiserfsprogs\n"
        pkgs+=" reiserfsprogs"
    else
        options+="[6] ( )reiserfsprogs\n"
    fi
    options+="[7] ( )lvm2\n"
    options+="[8] ( )dmraid\n"
    
    echo -e "${txtinstallarchlinuxfilesystems}""\n"
    echo -e "Additionally, the following packages will be installed for the file system. If you want to add more you will have to install the packages manually"
    echo -e "${options}""\n"

    echo ">pacstrap /mnt ${pkgs}"
    pacstrap /mnt ${pkgs}
    pressanykey
}
# --------------------------------------------------------
archmenu(){
   archsetkeymap
   archsetlocale
   archsettime
   hostname
   archsetrootpassword
   #archgentfstabmenu
   #archgencrypttab
   #if [ "${isnvme}" = "1" ]; then
   #    archgenmkinitcpionvme
   #fi
   #edit "/mnt/etc/fstab/"
   #edit "/mnt/etc/crypttab/"
   #archeditmkinitcpio
   #edit "/mnt/etc/pacman.d/mirrorList/"
   #archbootloadermenu
   #archextrasmenu
   #archdi
}
# --------------------------------------------------------
archchroot(){
    echo ">arch-chroot /mnt /root"
    cp ${0} /mnt/root
    chmod 775 /mnt/root/$(basename "${0}")
    arch-chroot /mnt /root/$(basename "${0}") --chroot ${1} ${2}
    rm /mnt/root/$(basename "${0}")
    echo "exit"
}
# --------------------------------------------------------
hostname(){
    re="^([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])\
	    (\.([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]{0,61}[a-zA-Z0-9]))$"
    showtitle "SETTING HOSTNAME"
    while true;do
        echo "Enter a hostname: "
        read hostname
	    if [ ${hostname} =~ ${re} ];then
		    echo -e "Valid characters for hostname are letters from a to z,"
    		echo -e "the digits from 0 to 9, and the hyphen (-). A hostname"
    		echo -e "may not start with a hyphen. Max 63 characters long."
	    else
		    echo ""
    		break
    	fi
    done
    echo -e "\n${txtsethostname}\n"
    echo -e ">echo \"${hostame}\" > /mnt/etc/hostname"
    echo "${hostname}" > /mnt/etc/hostname
    echo ""
}
# --------------------------------------------------------
archsetkeymap(){
    showtitle "SETTING KEYMAP"
    echo ""
    echo -e ">echo \"${keymap}\" > /mnt/etc/vconsole.conf"
    echo "${keymap}" > /mnt/etc/vconsole.conf
    echo ""
}
# --------------------------------------------------------
archsetlocale(){
    showtitle "SETTING LOCALE"
    echo -e "\n${txtsetlocale}\n"
    echo ">echo \"LANG=${locale}.UTF-8\" > /mnt/etc/locale.conf"
    echo "LANG=${locale}.UTF-8" > /mnt/etc/locale.conf
    echo ">echo \"LC_COLLATE=C\" >> /mnt/etc/locale.conf"
    echo "LC_COLLATE=C" >> /mnt/etc/locale.conf
    echo ">sed -i '/#${locale}.UTF-8/s/^#//g' /mnt/etc/locale.gen"
    sed -i '/#${locale}.UTF-8/s/^#//g' /mnt/etc/locale.gen
    archchroot setlocale
}
# --------------------------------------------------------
archsetlocalechroot(){
    echo ">locale-gen"
    locale-gen
    exit
}
# --------------------------------------------------------
archsettime(){
    showtitle "SETTING TIME"
    re="^[1-2]$"
    options=""
    options+="[1] UTC\n"
    options+="[2] LOCAL\n"

    echo -e "${txtsettime}\n"
    echo ">ln -sf /mnt/usr/share/zoneinfo/${timezone} /mnt/etc/localtime"
    ln -sf /mnt/usr/share/zoneinfo/${timezone} /mnt/etc/localtime
    
    echo -e ">\n${txthwclock}"
    echo -e "${options}"
    while true;do
        echo "Select a option: "
        read sel 
	    if [ ${sel} =~ ${re} ];then
            echo -e "Invalid option, try again\n"
    	else
	    	case ${sel} in
		    	"1")
			    	archchroot settimeutc
			    ;;
    			"2")
	    			archchroot settimelocal
				;;
	    	esac
		    echo ""
    		break
	    fi
    done
}
# --------------------------------------------------------
archsettimeutcchroot(){
    echo ">hwclock --systohc --utc"
    hwclock --systohc --utc
    exit
}
# --------------------------------------------------------
archsettimelocalchroot(){
    echo ">hwclock --systohc --localtime"
    hwclock --systohc --localtime
    exit
}
# --------------------------------------------------------
archsetrootpassword(){
    archchroot setrootpassword
}
# --------------------------------------------------------
archsetrootpasswordchroot(){
    echo ">passwd root"
    passed=1
    while [[ ${passed} != 0 ]]; do
	    passwd root
	    passed=$?
    done
    exit
}
# --------------------------------------------------------
unmountdevices(){
    showtitle "UNMOUNTING THE FILE SYSTEM"
    echo -e "\n>umount -R /mnt"
    umount -R /mnt
    if [ ! "${swapdev}" = "" ]; then
        echo -e "\n>swapoff ${swapdev}"
        swapoff ${swapdev}
    fi
    pressanykey
}
# --------------------------------------------------------
pressanykey(){
	tput sgr0
	read -n1 -p "${txtpressanykey}"
	echo ""
    tput setaf 2
}

showtitle(){
	tput setaf 5
	echo "##############################################"
	echo "${1}"
	echo "##############################################"
	echo ""
	tput setaf 2 
}

showmessage(){
	whiptail --title "$1" --msgbox "$2" 8 78
}

loadconfigs(){
    # init variables ---------------------------------
    #baseurl=https://raw.githubusercontent.com/MatMoul/archfi/master
    #cpl=0
    #skipfont="0"
    fspkgs=""

    # efi variables ----------------------------------
    eficomputer=""
    efimode=""

    # keymap -----------------------------------------
    keymap="us"
    title_keymap="Loading Keymap"
    menu_keymap="loadkeys ${keymap}"

    # editor -----------------------------------------
    editor="vim"
    title_editor="Setting Editor"
    menu_editor="export EDITOR=${editor}"

    # hard disk --------------------------------------
    device=""
    title_device="Choose your hard drive"
    menu_device="Where do you want to install your new system?\n\nWARNING: Everything will be DESTROYED on the hard disk!"

    #Swap --------------------------------------------
    default_swapsize=$(cat /proc/meminfo | grep MemTotal | awk '{ print $2 }')
    default_swapsize=$((${default_swapsize}/1000))
    title_swap="Choose your swap size"
    txt_swap="The boot will be 512M\nThe root will be the rest of the hard disk\nEnter partitionsize in gb for the Swap. \n\nIf you don't enter anything: \nswap -> Same size of the ram installed\n\n"
    menu_swap="Enter the size of swap partition in MB (only numbers)"

    # diskpart ---------------------------------------
    bootdev=""
    swapdev=""
    rootdev=""
    isnvme=0
    txt_diskpart="Now you must select the type of partition for your device\n"
    txtautopartclear="Clear all partition data"
    txtautopartcreate="Create %1 partition"
    txthybridpartcreate="Set hybrid MBR"
    
    # format partition -------------------------------
    txtselectpartformat="Select partition format for %1 :"
    txtformatingpart="Formatting partition %1 as"

    # installation menu ------------------------------
    txteditmirrorlist="Edit mirrorlist"
    txtinstallarchlinux="Install Arch Linux"

    # install base -----------------------------------
    installed=0
    txtinstallarchlinuxkernel="Kernel"
    txtinstallarchlinuxfirmwares="Firmwares"
    txtinstallarchlinuxfilesystems="File Systems"
    
    # hostname ---------------------------------------
    hostname=""
    txtsethostname="Set Computer Name"

    # locale -----------------------------------------
    locale="es_VE"
    txtsetlocale="Set Locale"

    # set time ---------------------------------------
    timezone="America/Caracas"
    txtsettime="Set Time"
    txthwclock="Hardware clock: "
    txthwclockutc="UTC"
    txthwclocklocal="Local"

    # rootpassword -----------------------------------
    txtsetrootpassword="Set root password"

    # messages ---------------------------------------
    txtpressanykey="Press any key to continue..."
}

# --------------------------------------------------------
while (( "$#" )); do
    case ${1} in
        --chroot)
            chroot=1
            command=${2}
            args=${3}
        ;;
    esac
done

if [ "${chroot}" = "1" ]; then
    case ${command} in
        'setrootpassword') archsetrootpasswordchroot;;
        'setlocale') archsetlocalechroot;;
        'settimeutc') archsettimeutcchroot;;
        'settimelocal') archsettimelocalchroot;;
        'genmkinitcpio') archgenmkinitcpiochroot;;
        'enabledhcpcd') archenabledhcpcdchroot;;
        'grubinstall') archgrubinstallchroot;;
        'grubbootloaderinstall') archgrubinstallbootloaderchroot ${args};;
        'grubbootloaderefiinstall') archgrubinstallbootloaderefichroot ${args};;
        'grubbootloaderefiusbinstall') archgrubinstallbootloaderefiusbchroot ${args};;
        'syslinuxbootloaderinstall') archsyslinuxinstallbootloaderchrrot ${args};;
        'syslinuxbootloaderefiinstall') archsyslinuxinstallbootloaderefichrrot ${args};;
        'systemdbootloaderinstall') archsystemdinstallchrrot ${args};;
        'refindbootloaderinstall') archrefindinstallchroot ${args};;
        #'');;
        #'');;
        #'');;
        #'');;
        #'');;
        #'');;
        #'');;
        #'');;
    esac
else
    pacman -S --needed arch-install-scripts wget libnewt
    loadconfigs
    checkefi
    setkeymap
    chooseeditor
    selectdisk
    selectswapsize
    diskpart
    formatdevice
    mountparts
    installmenu
    archmenu
fi
