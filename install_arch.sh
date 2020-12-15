
#!/bin/bash

# --------------------------------------------------------
setkeymap(){
    echo "################################################################"
    echo "LOADING KEYMAP"
    echo "################################################################"
	echo "loadkeys ${keymap}"
	loadkeys $keymap
	pressanykey
}

# --------------------------------------------------------
chooseeditor(){
    echo "################################################################"
    echo "SETTING EDITOR"
    echo "################################################################"
	echo "export EDITOR=${editor}"
	export EDITOR=${editor}
	EDITOR=${editor}
	pressanykey
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
	hd=$(whiptail --backtitle "${APPTITLE}" --title "${1}" --menu "" 0 0 0 "${options[@]}" 3>&1 1>&2 2>&3)
	echo ${hd%%\ *}   
}
# --------------------------------------------------------
pressanykey(){
	read -n1 -p "${txtpressanykey}"
}

loadconfigs(){
    # keymap ---------------------------------------------
    keymap = "us"
    
    # editor ---------------------------------------------
    editor = "vim"

    # hard disk ---------------------------------------------
    hd = ""
    
    txtpressanykey="Press any key to continue."
}

selectdisk