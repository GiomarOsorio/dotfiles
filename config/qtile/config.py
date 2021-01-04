"""
My config files for qtile
>> qtile docs can be found @ http://qtile.readthedocs.io/en/latest/

There are probably some more good hooks to make use of in here:
    http://qtile.readthedocs.io/en/latest/manual/ref/hooks.html
"""
import os

# qtile internals
from libqtile import bar, widget
from libqtile.config import Screen, hook

# Settings/helpers
from settings import FONT_PARAMS, K_LAYOUTS, TERMINAL, WITH_SYS_TRAY, COLOR_SCHEME
from helpers import run_script

# Import the parts of my config defined in other files
from layouts import layouts, floating_layout    # NOQA
from bindings import keys, mouse                # NOQA
from groups import groups                       # NOQA
from widgets import ShellScript
from custom_checkupdates import Custom_CheckUpdates
#from widgets_test import Custom_CheckUpdates

# ----------------------------------------------------------------------------
# Hooks


@hook.subscribe.startup_complete
def autostart():
    """
    My startup script has a sleep in it as some of the commands depend on
    state from the rest of the init. This will cause start/restart of qtile
    to hang slightly as the sleep runs.
    """
    os.environ.setdefault('RUNNING_QTILE', 'True')
    run_script("autostart.sh")


@hook.subscribe.screen_change
def restart_on_randr(qtile, ev):
    """
    Restart and reload config when screens are changed so that we correctly
    init any new screens and correctly remove any old screens that we no
    longer need.

    There is an annoying side effect of removing a second monitor that results
    in windows being 'stuck' on the now invisible desktop...
    """
    qtile.cmd_restart()


# ----------------------------------------------------------------------------
def make_screen(systray=False):
    """Defined as a function so that I can duplicate this on other monitors"""
    blocks = [
        # Marker for the start of the groups to give a nice bg: ◢■■■■■■■◤
        widget.TextBox(
            font="Arial", foreground=COLOR_SCHEME["foreground"],
            text="◢", fontsize=50, padding=-1
        ),
        widget.GroupBox(
            other_current_screen_border=COLOR_SCHEME["selected"],
            this_current_screen_border=COLOR_SCHEME["selected"],
            other_screen_border=COLOR_SCHEME["foreground"],
            this_screen_border=COLOR_SCHEME["foreground"],
            highlight_color=COLOR_SCHEME["selected"],
            urgent_border=COLOR_SCHEME["urgent"],
            background=COLOR_SCHEME["foreground"],
            highlight_method="line",
            inactive=COLOR_SCHEME["inactive_group"],
            active=COLOR_SCHEME["active_group"],
            disable_drag=True,
            borderwidth=3,
            **FONT_PARAMS,
        ),
        # Marker for the end of the groups to give a nice bg: ◢■■■■■■■◤
        widget.TextBox(
            font="Arial", foreground=COLOR_SCHEME["foreground"],
            text="◤ ", fontsize=50, padding=-5
        ),
        # Show the title for the focused window
        widget.WindowName(**FONT_PARAMS),
        # Allow for quick command execution
        widget.Prompt(
            cursor_color=COLOR_SCHEME["foreground"],
            bell_style="visual",
            prompt="λ : ",
            **FONT_PARAMS
        ),
        widget.Sep(linewidth=2, foreground=COLOR_SCHEME["background"]),
        # Resource usage graphs
        # IP information
        # ShellScript(
        #     fname="ipadr.sh",
        #     update_interval=10,
        #     markup=True,
        #     padding=1,
        #     **FONT_PARAMS
        # ),
        # Available apt upgrades
        # ShellScript(
        #    fname="aptupgrades.sh",
        #    update_interval=600,
        #    markup=True,
        #    padding=1,
        #    **FONT_PARAMS
        # ),
        # Available pacman upgrades
        # widget.TextBox("┊", **FONT_PARAMS),
        # widget.TextBox("⟳",
        #        padding=0,
        #        mouse_callbacks={
        #            "Button1": lambda qtile: qtile.cmd_spawn(TERMINAL + " -e sudo pacman -Syu")
        #            },
        #        **FONT_PARAMS),
        # widget.Pacman(
        #        update_interval=600,
        #        mouse_callbacks={
        #            "Button1": lambda qtile: qtile.cmd_spawn(TERMINAL + " -e sudo pacman -Syu")
        #            },
        #        **FONT_PARAMS),
        widget.TextBox("┊", **FONT_PARAMS),
        # Check Updates using YAY, every 5min
        Custom_CheckUpdates(
            distro='Arch_yay',
            update_interval=300,
            display_format='聯',
            mouse_callbacks={
                "Button1": lambda qtile: qtile.cmd_spawn(TERMINAL + " -e yay -Syu")
            },
            #execute=TERMINAL + " -e yay -Syu",
            colour_no_updates=COLOR_SCHEME['focus'],
            colour_have_updates=COLOR_SCHEME['focus'],
            no_update_string='聯',
            **FONT_PARAMS),
        widget.TextBox("┊", **FONT_PARAMS),
        # Volume % : scroll mouse wheel to change volume
        widget.TextBox("", **FONT_PARAMS),
        widget.Volume(**FONT_PARAMS),
        widget.TextBox("┊", **FONT_PARAMS),
        # Current time
        widget.Clock(
            format="%I:%M %p, %a %d de %b %Y",
            **FONT_PARAMS
        ),
        # Keyboard layout
        widget.TextBox("┊", **FONT_PARAMS),
        widget.KeyboardLayout(
            configured_keyboards=K_LAYOUTS,
            **FONT_PARAMS
        ),
        widget.TextBox("┊", **FONT_PARAMS),
        # Visual indicator of the current layout for this workspace.
        widget.CurrentLayoutIcon(
            custom_icon_paths=[os.path.expanduser("~/.config/qtile/icons")],
            **FONT_PARAMS
        ),
    ]

    if systray:
        # Add in the systray and additional separator
        blocks.insert(-1, widget.Systray())
        blocks.insert(-1, widget.Sep(linewidth=2,
                                     foreground=COLOR_SCHEME["background"]))

    # return Screen(top=bar.Bar(blocks, 25, background=COLS["deus_1"]))
    return Screen(top=bar.Bar(widgets=blocks, opacity=0.9, size=25, background=COLOR_SCHEME["background"]))


# XXX : When I run qtile inside of mate, I don"t actually want a qtile systray
#       as mate handles that. (Plus, if it _is_ enabled then the mate and
#       qtile trays both crap out...)
screens = [make_screen(systray=WITH_SYS_TRAY)]

# ----------------------------------------------------------------------------
# .: Assorted additional config :.
focus_on_window_activation = "smart"
dgroups_key_binder = None
follow_mouse_focus = True
bring_front_click = False
auto_fullscreen = True
dgroups_app_rules = []
cursor_warp = False
# main = None

# XXX :: Horrible hack needed to make grumpy java apps work correctly.
#        (This is from the default config)
wmname = "LG3D"


# ----------------------------------------------------------------------------
def main(qtile):
    """Optional entry point for the config"""
    # Make sure that we have a screen / bar for each monitor that is attached
    while len(screens) < len(qtile.conn.pseudoscreens):
        screens.append(make_screen())
