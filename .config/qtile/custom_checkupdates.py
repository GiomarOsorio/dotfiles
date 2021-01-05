import os
from subprocess import CalledProcessError, Popen

from libqtile.log_utils import logger
from libqtile.widget import base


class ArchCheckUpdates(base.ThreadedPollText):
    """Shows number of pending updates in arch using YAY as default"""
    orientations = base.ORIENTATION_HORIZONTAL
    defaults = [
        ("distro", "Arch_yay", "Name of your distribution"),
        ("custom_command", None, "Custom shell command for checking updates (counts the lines of the output)"),
        ("update_interval", 300, "Update interval in seconds."),
        ('execute', None, 'Command to execute on click'),
        ("display_format", "Updates: {updates}", "Display format if updates available"),
        ("colour_no_updates", "ffffff", "Colour when there's no updates."),
        ("colour_have_updates", "ffffff", "Colour when there are updates."),
        ("restart_indicator", "", "Indicator to represent reboot is required. (Ubuntu only)"),
        ("no_update_string", "", "String to display if no updates available")
    ]

    def __init__(self, **config):
        base.ThreadedPollText.__init__(self, **config)
        self.add_defaults(ArchCheckUpdates.defaults)

        # format: "Distro": ("cmd", "number of lines to subtract from output")
        self.cmd_dict = {"Arch": ("pacman -Qu", 0),
                         "Arch_checkupdates": ("checkupdates", 0),
                         "Arch_Sup": ("pacman -Sup", 1),
                         "Arch_yay": ("yay -Qu", 0),
                         }

        # Check if distro name is valid.
        try:
            self.cmd = self.cmd_dict[self.distro][0].split()
            self.subtr = self.cmd_dict[self.distro][1]
        except KeyError:
            distros = sorted(self.cmd_dict.keys())
            logger.error(self.distro + ' is not a valid distro name. ' +
                         'Use one of the list: ' + str(distros) + '.')
            self.cmd = None

        if self.execute:
            self.add_callbacks({'Button1': self.do_execute})

    def _check_updates(self):
        # type: () -> str
        try:
            if self.custom_command is None:
                updates = self.call_process(self.cmd)
            else:
                updates = self.call_process(self.custom_command, shell=True)
                self.subtr = 0
        except CalledProcessError:
            updates = ""
        num_updates = len(updates.splitlines()) - self.subtr
        
        self._set_colour(num_updates)

        if num_updates == 0:
            return self.no_update_string

        return self.display_format.format(**{"updates": str(num_updates)})

    def _set_colour(self, num_updates):
        # type: (str) -> None
        if num_updates > 0:
            self.layout.colour = self.colour_have_updates
        else:
            self.layout.colour = self.colour_no_updates

    def poll(self):
        # type: () -> str
        if not self.cmd:
            return "N/A"
        return self._check_updates()

    def do_execute(self):
        self._process = Popen(self.execute, shell=True)
        self.timeout_add(1, self._refresh_count)

    def _refresh_count(self):
        if self._process.poll() is None:
            self.timeout_add(1, self._refresh_count)
        else:
            self.tick()