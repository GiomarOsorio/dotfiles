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

# Set screen resolutions (add additional screens here)
xrandr --output VGA-0 --mode 1280x1024 --rate 60 &

# Set the background image
xwinwrap -g 1280x1024+0+0 -ni -s -nf -b -un -argb -ov -- gifview -w WID ~/Pictures/wallpaper.gif -a

# Wait to let the X-Session start up correctly
sleep 1

# XFCE
# Power Manager
[[ $(is_running 'xfce4-power-manager') ]] || xfce4-power-manager &
# Polkit agent Authentication
[[ $(is_running 'polkit-gnome') ]] || /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &
# Daemon
[[ $(is_running 'xfsettingsd') ]] || xfsettingsd &
# ScreenSaver 
[[ $(is_running 'xfce4-screensaver') ]] || xfce4-screensaver &

# Compton visual compositing but not for qtile as it messes things up
if ! [[ $RUNNING_QTILE ]]; then
  [[ $(is_running 'compton') ]] || compton -CG &
else
  [[ $(is_running 'picom') ]] || picom -CG &
fi;

# Network manager
[[ $(is_running 'nm-applet') ]] || nm-applet &

# Auto-mount external drives
[[ $(is_running 'udiskie') ]] || udiskie -a -n -t &

# Start the keyring daemon for managing ssh keys
[[ $(is_running 'gnome-keyring-daemon') ]] || gnome-keyring-daemon -s &

# Start xautolock using my wrapper around i3lock
# NOTE :: lock-screen is my custom screen lock script in ~/bin
# [[ $(is_running 'xautolock') ]] || xautolock -detectsleep -time 3 -locker "lock-screen"  -notify 30 -notifier "notify-send -u critical -t 10000 -- 'LOCKING screen in 30 seconds...'" &

# Notification daemon : first kill the default mate daemon if it has spun up
# [[ $(is_running 'mate-notification-daemon') ]] || killall mate-notification-daemon 
[[ $(is_running 'dunst') ]] || dunst &

# Megasync
[[ $(is_running 'megasync') ]] || megasync &

# Screen Shot
[[ $(is_running 'flameshot') ]] || flameshot &

# Protect Eyes
[[ $(is_running 'redshift') ]] || redshift &

# Discord
[[ $(is_running 'discord') ]] || discord &


#
# Music server
#[[ $(is_running 'mopidy') ]] || python2 -m mopidy &

# polybar for i3
# [[ $(is_running 'polybar') ]] || polybar top
