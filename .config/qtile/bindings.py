'''
My mouse and key bindings.

String names for non-alpha-numeric keys can be found here:
>>> https://github.com/qtile/qtile/blob/develop/libqtile/xkeysyms.py

It is possible to bind keys to multiple actions (see the swap panes bindings).
When this is done, all actions are sent and the layout/window/group acts on
those that it knows about and ignores those that it doesn't.
- I've used this to group logical behaviour between layouts where they use
  different method names (in the case of moving windows) and to chain
  actions together (move group to screen and follow with focus).

I'm not being 100% consistent but in general:
    M-...  :: qtile / environment commands
    M-S... :: qtile window/group management commands (movement of windows etc)
    M-C... :: program launching
    M-A... :: utility launching

Anything bound to arrow keys is movement based. I'm having problems binding
`M-C={h,j,k,l}` which is preventing me using that for movement. (Though this
may be something to do with my own ez_keys function...!)
'''
import os
import re

from libqtile.config import Click, Drag, EzKey, Key
from libqtile.command import lazy

from settings import MOD, TERMINAL, K_LAYOUTS, COLOR_SCHEME
from helpers import script, notify, run
from groups import groups


# def toggle_klayout(qtile):
#    """Change the keyboard layout taking into account the positions defined in K_LAYOUTS"""
#    query = run('setxkbmap -query', with_output=True)
#    search_layout = re.search('\\nlayout:(.*)\\n', query)
#    current_layout = search_layout.group(1).strip()
#    search_variant = re.search('\\nvariant:(.*)\\n', query)
#    current_layout = '{} {}'.format(current_layout, search_variant.group(1).strip()) if search_layout else current_layout
#    next_layout = K_LAYOUTS.index(current_layout) + 1
#    if next_layout >= len(K_LAYOUTS):
#        next_layout = 0
#    command = "setxkbmap {}".format(K_LAYOUTS[next_layout])
#    run(command, with_output=False)

def toggle_klayout(qtile):
    """Change the keyboard layout taking into account the positions defined in K_LAYOUTS"""
    query = run('setxkbmap -print', with_output=True)
    search_layout = re.search('\+(.*)\+', query).group(1)
    current_layout = re.sub(r"\)", "", re.sub(r"\(", " ", search_layout))
    next_layout = K_LAYOUTS.index(current_layout) + 1
    if next_layout >= len(K_LAYOUTS):
        next_layout = 0
    command = "setxkbmap {}".format(K_LAYOUTS[next_layout])
    run(command, with_output=False)


def to_scratchpad(window):
    '''
    Mark the current window as a scratchpad. This resises it, sets it to
    floating and moves it to the hidden `scratchpad` group.
    '''
    try:
        window.togroup('scratchpad')
        window.on_scratchpad = True
    except Exception as e:
        # No `scratchpad` group
        notify((
            'You are attempting to use scratchpads without a `scratchpad`'
            ' group being defined! Define one in your config and restart'
            ' qtile to enable scratchpads.'
        ))

    window.floating = True
    screen = window.group.screen

    window.tweak_float(
        x=int(screen.width / 10),
        y=int(screen.height / 10),
        w=int(screen.width / 1.2),
        h=int(screen.height / 1.2),
    )


def show_scratchpad(qtile):
    '''
    Cycle through any current scratchpad windows on the current screen.
    '''
    scratchpad = qtile.groupMap.get('scratchpad')
    if scratchpad is None:
        notify((
            'You are attempting to use scratchpads without a `scratchpad`'
            ' group being defined! Define one in your config and restart'
            ' qtile to enable scratchpads.'
        ))

    for w in list(qtile.currentGroup.windows):
        if not hasattr(w, 'on_scratchpad'):
            # Ensure that we don't get an attribute error
            w.on_scratchpad = False

        if w.on_scratchpad:
            w.togroup('scratchpad')

    if scratchpad.focusHistory:
        # We have at least one scratchpad window to display so show that last
        # one to be focused. This will cause us to cycle through all scratchpad
        # windows in reverse order.
        last_window = scratchpad.focusHistory[-1]
        last_window.togroup(qtile.currentGroup.name)


# qtile actually has an emacs style `EzKey` helper that makes specifying
# key bindings a lot nicer than the default.
keys = [Key(k[0], k[1], k[2]) for k in [
    # .: Movement :.
    # Swtich focus between panes
    ([MOD], "Up", lazy.layout.up()),
    ([MOD], "Down", lazy.layout.down()),
    ([MOD], "Left", lazy.layout.left()),
    ([MOD], "Right", lazy.layout.right()),

    ([MOD], "h", lazy.layout.left()),
    ([MOD], "j", lazy.layout.down()),
    ([MOD], "k", lazy.layout.up()),
    ([MOD], "l", lazy.layout.right()),

    # Swap panes: target relative to active.
    # NOTE :: The `swap` commands are for XMonad
    ([MOD, "shift"], "Up", lazy.layout.shuffle_up()),
    ([MOD, "shift"], "Down", lazy.layout.shuffle_down()),
    ([MOD, "shift"], "Left", lazy.layout.shuffle_left(), lazy.layout.swap_left()),
    ([MOD, "shift"], "Right", lazy.layout.shuffle_right(), lazy.layout.swap_right()),

    ([MOD, "shift"], "h", lazy.layout.shuffle_left(), lazy.layout.swap_left()),
    ([MOD, "shift"], "j", lazy.layout.shuffle_down()),
    ([MOD, "shift"], "k", lazy.layout.shuffle_up()),
    ([MOD, "shift"], "l", lazy.layout.shuffle_right(), lazy.layout.swap_right()),

    ## .: Program Launchers :. #
    ([MOD], "Return", lazy.spawn(TERMINAL)),
    ([MOD, "shift"], "Return", lazy.spawn(
        "dmenu_run -b -p 'λ' -sb '{}' -sf '{}' -nb '{}' -nf '{}'".format(
            COLOR_SCHEME["selected"],
            COLOR_SCHEME["active_group"],
            COLOR_SCHEME["background"],
            COLOR_SCHEME["foreground"],)
    )
    ),
    ([MOD], "w", lazy.spawn('rofi -show window')),
    ([MOD], "b", lazy.spawn("google-chrome-stable")),
    ([MOD], "r", lazy.spawn(TERMINAL + ' -e "ranger"')),
    ([MOD], "d", lazy.spawn("dolphin")),
    ([], "XF86AudioLowerVolume", lazy.spawn("pamixer --decrease 5")),
    ([], "XF86AudioRaiseVolume", lazy.spawn("pamixer --increase 5")),
    ([], "XF86AudioMute", lazy.spawn("pamixer --toggle-mute")),
    (["shift"], "F12", lazy.spawn("pamixer --decrease 5")),
    (["shift"], "F11", lazy.spawn("pamixer --increase 5")),
    ([], "Print", lazy.spawn("flameshot gui")),

    # Scratchpad toggles
    #("M-<slash>", lazy.group['scratchpad'].dropdown_toggle('term')),
    #("M-S-<slash>", lazy.group['scratchpad'].dropdown_toggle('ipython')),
    ## ("M-<slash>", lazy.window.function(to_scratchpad)),
    ## ("M-S-<slash>", lazy.function(show_scratchpad)),

    ## .: Layout / Focus Manipulation :. #
    ([MOD], "f", lazy.window.toggle_fullscreen()),
    # Toggle between the available layouts.
    ([MOD], "Tab", lazy.next_layout()),
    ([MOD, "shift"], "Tab", lazy.prev_layout()),
    # Close the current window: NO WARNING!
    ([MOD], "w", lazy.window.kill()),

    ## .: Sys + Utils :. #
    # Restart qtile in place and pull in config changes (check config before
    # doing this with `check-qtile-conf` script to avoid crashes)
    ([MOD, "shift"], "r", lazy.restart()),
    # Shut down qtile.
    ([MOD, "shift"], "Escape", lazy.shutdown()),
    ([MOD, "shift"], "l", lazy.spawn("dm-tool switch-to-greeter")),
    ([MOD], "space", lazy.function(toggle_klayout))
    #([MOD,"shift"],"Delete", lazy.spawn(script("power-menu.sh"))),

]]

# .: Jump between groups and also throw windows to groups :. #
for ix, group in enumerate(groups, 1):
    keys.extend([Key(k[0], k[1], k[2]) for k in [
        # ("M-%d" % ix, lazy.group[group.name].toscreen()),
        ([MOD], str(ix), lazy.group[group.name].toscreen()),
        # M-S-ix = switch to & move focused window to that group
        ([MOD, "shift"], str(ix), lazy.window.togroup(group.name)),
    ]])

# .: Use the mouse to drag floating layouts :. #
mouse = [
    Drag([MOD], "Button1", lazy.window.set_position_floating(),
         start=lazy.window.get_position()),
    Drag([MOD], "Button3", lazy.window.set_size_floating(),
         start=lazy.window.get_size()),
    Click([MOD], "Button2", lazy.window.bring_to_front())
]
