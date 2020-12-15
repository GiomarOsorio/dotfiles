
#!/bin/bash

# --------------------------------------------------------
setkeymap(){
    #showmessage ${title_swap} ${txt_swap}
    #echo "################################################################"
    #echo "LOADING KEYMAP"
    #echo "################################################################"
	#echo "loadkeys ${keymap}"
    showmessage ${title_keymap} ${txt_keymap}
	loadkeys $keymap
	#pressanykey
}

# --------------------------------------------------------
chooseeditor(){
    #echo "################################################################"
    #echo "SETTING EDITOR"
    #echo "################################################################"
	#echo "export EDITOR=${editor}"
    showmessage ${title_editor} ${txt_editor}
	export EDITOR=${editor}
	EDITOR=${editor}
	#pressanykey
}

# --------------------------------------------------------
selectdisk(){
    echo "################################################################"
    echo "SELECTING HARD DISK"
    echo "################################################################"
	items=$(lsblk -d -p -n -l -o NAME,SIZE -e 7,11)
	options=()
	IFS_ORIG=$IFS
	IFS=$'\n'
	for item in ${items}
	do  
			options+=("${item}" "")
	done
	IFS=$IFS_ORIG
	hd=$(whiptail --backtitle "Arch Install Script" --title "${title_hd}" --menu "{$menu_hd}" 0 0 0 "${options[@]}" 3>&1 1>&2 2>&3)
	echo ${hd%%\ *}   
}
# --------------------------------------------------------
selectswapsize(){
    echo "################################################################"
    echo "SELECTING SWAP SIZE"
    echo "################################################################"
<<<<<<< HEAD
    showmessage ${title_swap} ${txt_swap}
=======
    showmessage "$title_swap" "$txt_swap"
>>>>>>> 0f06f468e88a51532f2c1bfdc680fde652d06b86
    swap_size=$(whiptail --backtitle "Arch Install Script" --inputbox "${menu_swap}" 8 39 ${default_swap_size} --title "${title_swap}" 3>&1 1>&2 2>&3)
    [[ $swap_size =~ ^[0-9]+$ ]] || swap_size=$default_size
	#hd=$(whiptail --backtitle "Arch Install Script" --title "${title_hd}" --menu "{$menu_hd}" 0 0 0 "${options[@]}" 3>&1 1>&2 2>&3)
	echo ${swap_size%%\ *}   
}
# --------------------------------------------------------
pressanykey(){
	read -n1 -p "${txtpressanykey}"
}

showmessage(){
<<<<<<< HEAD
    whiptail --title "$1" --msgbox "$2" 15 80
=======
	whiptail --title "$1" --msgbox "$2" 8 78
>>>>>>> 0f06f468e88a51532f2c1bfdc680fde652d06b86
}

loadconfigs(){
    # keymap ---------------------------------------------
    keymap="us"
    title_keymap="Loading Keymap"
    menu_keymap="loadkeys ${keymap}"
    
    # editor ---------------------------------------------
    editor="vim"
    title_editor="Setting Editor"
    menu_editor="export EDITOR=${editor}"

    # hard disk ------------------------------------------
    hd=""
    title_hd="Choose your hard drive"
    menu_hd="Where do you want to install your new system?\n\nSelect with SPACE, valid with ENTER.\n\nWARNING: Everything will be DESTROYED on the hard disk!"
    
    #Swap ------------------------------------------------
    default_swap_size="6"
    title_swap="Choose your swap size"
    menu_swap="Enter the size of swap partition in GB (only numbers)"
    
    # messages ------------------------------------------
    txtpressanykey="Press any key to continue."
    txt_swap="The boot will be 512M\nThe root will be the rest of the hard disk\nEnter partitionsize in gb for the Swap. \n\nIf you dont enter anything: \nswap -> ${default_size}G \n\n"
}

loadconfigs
setkeymap
chooseeditor
selectdisk
selectswapsize
