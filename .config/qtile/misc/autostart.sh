#!/bin/bash
# -------------------------------------
# Bootsrap the start of a qtile session
# >> This get's run on restart as well!
# -------------------------------------

# pgrep -x doesn't seem to work for this. No idea why...
# This is used to make sure that things only get executed once
is_running() {
    ps -aux | awk "!/grep/ && /$1/" 
}
export PRIMARY_DISPLAY="$(xrandr | awk '/ primary/{print $1}')"

# Set screen resolutions (add additional screens here)
xrandr --output VGA-0 --mode 1280x1024 --rate 60 &

# Set the wallpaper
~/.fehbg &
# Gif wallpaper
#[[ $(is_running 'xwinwrap') ]] || nice xwinwrap -b -s -fs -st -sp -nf -ov -fdt -- gifview -w WID ~/.config/qtile/misc/wallpaper.gif -a &

# Wait to let the X-Session start up correctly
sleep 1

# XFCE
# Power Manager
#[[ $(is_running 'xfce4-power-manager') ]] || xfce4-power-manager &
# Polkit agent Authentication
[[ $(is_running 'polkit-gnome') ]] || /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &
# Daemon
[[ $(is_running 'xfsettingsd') ]] || xfsettingsd &
# ScreenSaver 
#[[ $(is_running 'xfce4-screensaver') ]] || xfce4-screensaver &

# Compton visual compositing but not for qtile as it messes things up
if ! [[ $RUNNING_QTILE ]]; then
  [[ $(is_running 'compton') ]] || compton -CG &
else
  #[[ $(is_running 'picom') ]] || picom -CG &
  [[ $(is_running 'picom') ]] || picom &
fi;

# Network manager
[[ $(is_running 'nm-applet') ]] || nm-applet &

# Auto-mount external drives
[[ $(is_running 'udiskie') ]] || udiskie -a -n -t &

# Start the keyring daemon for managing ssh keys
[[ $(is_running 'gnome-keyring-daemon') ]] || gnome-keyring-daemon -s &

# Start xidlehook using betterlockscreen
#[[ ! $(is_running 'xidlehook') ]] killall xidlehook &
#with suspend after 60 minuts
#[[ $(is_running 'xidlehook') ]] || xidlehook  --not-when-fullscreen --not-when-audio --timer 300 'betterlockscreen --off 15 -t "LOCKED" -l' '' --timer 3600 'betterlockscreen -s blur' '' &
#without suspend
[[ $(is_running 'xidlehook') ]] || xidlehook  --not-when-fullscreen --not-when-audio --timer 300 'betterlockscreen --off 15 -t "LOCKED" -l' '' &

# Notification daemon : first kill the default mate daemon if it has spun up
[[ $(is_running 'dunst') ]] || dunst -config ~/.config/dunst/dunstrc &

# Megasync
[[ $(is_running 'megasync') ]] || megasync &

# Screen Shot
[[ $(is_running 'flameshot') ]] || flameshot &

# Protect Eyes
[[ $(is_running 'redshift') ]] || redshift &

# Discord
[[ $(is_running 'discord') ]] || discord &

#Music Player Daemon
[[ $(is_running 'mpd') ]] || mpd &
