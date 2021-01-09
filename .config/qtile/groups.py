"""
qtile calls i3-style workspaces `groups`.

Groups are a little more powerful as we can specify additional config
to apply to each group if we want:

NOTE :: Match is imported from libqtile.config
>>> Group(
        # Display name for the group
        name="my-workspace",
        # Capture spawned programs and move them to this group
        matches=[Match(wm_class=["FireFox"])],
        # Spawn these programs on start
        spawn=["my-program", "my-other-program"],
        # Layout to use (must be in the listed layouts)
        layout="MonadTall",
        # Should this group exist even when there are no windows?
        persist=True,
        # Create this group when qtile starts?
        init=True
    )
"""
from libqtile.config import Group, ScratchPad, DropDown


# Named Groups copied from i3
# >>> See https://fontawesome.com/cheatsheet for more fontawesome icons
groups = [
    Group("1 "),
    Group("2 "),
    Group("3 "),
    Group("4 "),
    Group("5 "),
    Group("6 "),
]

# Simple numbered groups
# groups = [Group(str(x+1)) for x in range(10)]

# Roman numerals + icons
# groups = [
#    Group("I "),
#    Group("II "),
#    Group("III "),
#    Group("IV "),
#    Group("V "),
#    Group("VI "),
# ]

# Roman numerals only
# groups = [
#     Group("I"),
#     Group("II"),
#     Group("III"),
#     Group("IV"),
#     Group("V"),
#     Group("VI"),
# ]

# Icons only
# groups = [
#    Group(""),
#    Group(""),
#    Group(""),
#    Group(""),
#    Group(""),
#    Group(""),
# ]

# Named
# groups = [
#     Group("WEB"),
#     Group("TERM"),
#     Group("NOTES"),
#     Group("CODE"),
#     Group("SOCIAL"),
#     Group("GAMES"),
# ]
