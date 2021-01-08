'''
Settings, customisation and tweaks.
'''
import os
from os import path
import subprocess
import json

# Colour codes for built-in qtile bar, default custom gruvbox color_scheme
#
#
THEME = 'gruvbox/gruvbox-dark'

default_theme = {
    "background": "#282828",
    "inactive_group": "#928374",
    "focus": "#fb4934",
    "urgent": "#689d6a",
    "selected": "#8ec07c",
    "foreground": "#ebdbb2",
    "active_group": "#d65d0e"
}


def load_theme(theme=''):
    qtile_path = path.join(path.expanduser('~'), ".config", "qtile")

    if not theme:
        return default_theme

    theme_file = path.join(qtile_path, "misc/themes/", f'{theme}.json')

    if not path.isfile(theme_file):
        #        message = f'"{theme}" does not exist, using default theme'
        #        run('notify-send "Qtile theme config" "%s"' %message, with_output=False)
        return default_theme

    with open(theme_file) as f:
        return json.load(f)


COLOR_SCHEME = load_theme(THEME)

# Modifier keys
ALT = "mod1"    # Left Alt
MOD = "mod4"    # Windows/Super
R_ALT = "mod3"  # Right Alt

# Directions
DIRECTIONS = ("Left", "Down", "Up", "Right")

# Keyboard Layouts
K_LAYOUTS = ['us', 'es', 'us dvp']

# Programs
TERMINAL = "alacritty"

# UI Config vars
FONT = 'Hurmit Nerd Font'
FOREGROUND = COLOR_SCHEME['foreground']
ALERT = COLOR_SCHEME['focus']
FONTSIZE = 15
PADDING = 2

# Keep all of the UI consistent
FONT_PARAMS = {
    'font': FONT,
    'fontsize': FONTSIZE,
    'foreground': FOREGROUND,
}

# Location of my script files (must have a trailing slash!)
SCRIPT_DIR = os.path.expanduser('~/.config/qtile/misc/')
ACME_SCRIPT_DIR = os.path.expanduser('~/Personal/acme-corp/scripts/')

# Whether or not the primary monitor should spawn a systray
# NOTE :: When embedding qtile inside of another desktop environment (such
#         as mate) this should be `False` as the DE systray and qtile's
#         end up fighting each other and both loose...!
WITH_SYS_TRAY = True
