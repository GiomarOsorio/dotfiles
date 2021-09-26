import re
import subprocess
from os import statvfs

import cairocffi

from libqtile.widget import base

__all__ = [
    'VolumeBar',
]

re_vol = re.compile(r'\[(\d?\d?\d?)%\]')

class _Line(base._Widget):
    fixed_upper_bound = False
    defaults = [
        ("line_width", 3, "Line width"),
        ("rounded", True, "To round or not to round line borders"),
        ("background", None, "Widget background color"),
        ("line_color", "18BAEB", "Line color"),
        ("fill_color", "1667EB.3", "Fill color for linefill line"),
        ("margin_x", 3, "Margin X"),
        ("margin_y", 3, "Margin Y"),
        ("start_pos", "bottom", "Drawer starting position ('bottom'/'top')"),
    ]

    def __init__(self, width=100, **config):
        base._Widget.__init__(self, width, **config)
        self.add_defaults(_Line.defaults)
        self.value = 0

    def _configure(self, qtile, bar):
        super()._configure(qtile, bar)
        if self.rounded:
            self.drawer.ctx.set_antialias(cairocffi.ANTIALIAS_NONE)

    @property
    def graphwidth(self):
        return self.width - self.border_width * 2 - self.margin_x * 2

    @property
    def graphheight(self):
        return self.bar.height - self.margin_y * 2 - self.border_width * 2

    def _prepare_context(self):
        if self.fill_color is not None:
            self.drawer.set_source_rgb(self.fill_color)
        self.drawer.ctx.set_line_width(self.line_width)

    def draw_line(self, x, y, val):
        self._prepare_context()
        self.drawer.ctx.line_to(x - self.val(val), y)
        self.drawer.ctx.stroke()

    def val(self, val):
        if self.start_pos == 'bottom':
            return val
        elif self.start_pos == 'top':
            return -val
        else:
            raise ValueError("Unknown starting position: %s." % self.start_pos)

    def draw(self):
        self.drawer.clear(self.background or self.bar.background)
        x = self.margin_x
        y = self.margin_y
        if self.start_pos == 'bottom':
            y += self.line_width
        elif not self.start_pos == 'top':
            raise ValueError("Unknown starting position: %s." % self.start_pos)
        scaled = self.line_width * self.value

        self.draw_line(x, y, scaled)
        self.drawer.draw(offsetx=self.offset, width=self.width)

    def update(self, value):
        self.value=value
        self.draw()

class VolumeBar(_Line):
    """Widget that display and change volume

    By default, this widget uses ``amixer`` to get and set the volume so users
    will need to make sure this is installed. Alternatively, users may set the
    relevant parameters for the widget to use a different application.

    """
    orientations = base.ORIENTATION_HORIZONTAL
    defaults = [
        ("cardid", None, "Card Id"),
        ("device", "default", "Device Name"),
        ("channel", "Master", "Channel"),
        ("padding", 3, "Padding left and right. Calculated if None."),
        ("update_interval", 0.2, "Update time in seconds."),
        ("mute_command", None, "Mute command"),
        ("volume_app", None, "App to control volume"),
        ("volume_up_command", None, "Volume up command"),
        ("volume_down_command", None, "Volume down command"),
        ("get_volume_command", None, "Command to get the current volume"),
        ("step", 2, "Volume change for up an down commands in percentage."
                    "Only used if ``volume_up_command`` and ``volume_down_command`` are not set.")
    ]

    def __init__(self, **config):
        _Line.__init__(self, width=100, **config)
        self.add_defaults(VolumeBar.defaults)
        self.volume = 0

        self.add_callbacks({
            'Button1': self.cmd_mute,
            'Button3': self.cmd_run_app,
            'Button4': self.cmd_increase_vol,
            'Button5': self.cmd_decrease_vol,
        })

    def timer_setup(self):
        self.timeout_add(self.update_interval, self.update)

    def create_amixer_command(self, *args):
        cmd = ['amixer']

        if (self.cardid is not None):
            cmd.extend(['-c', str(self.cardid)])

        if (self.device is not None):
            cmd.extend(['-D', str(self.device)])

        cmd.extend([x for x in args])
        return cmd

    def button_press(self, x, y, button):
        _Line.button_press(self, x, y, button)
        self.draw()

    def update(self):
        vol = self.get_volume()
        if vol != self.volume:
            self.volume = vol
            self.bar.draw()
        self.timeout_add(self.update_interval, self.update)

    def get_volume(self):
        try:
            get_volume_cmd = self.create_amixer_command('sget',
                                                        self.channel)

            if self.get_volume_command:
                get_volume_cmd = self.get_volume_command

            mixer_out = self.call_process(get_volume_cmd)
        except subprocess.CalledProcessError:
            return -1

        if '[off]' in mixer_out:
            return -1

        volgroups = re_vol.search(mixer_out)
        if volgroups:
            return int(volgroups.groups()[0])
        else:
            # this shouldn't happen
            return -1

    def draw(self):
        _Line.draw(self)

    def cmd_increase_vol(self):
        if self.volume_up_command is not None:
            subprocess.call(self.volume_up_command, shell=True)
        else:
            subprocess.call(self.create_amixer_command('-q',
                                                       'sset',
                                                       self.channel,
                                                       '{}%+'.format(self.step)))

    def cmd_decrease_vol(self):
        if self.volume_down_command is not None:
            subprocess.call(self.volume_down_command, shell=True)
        else:
            subprocess.call(self.create_amixer_command('-q',
                                                       'sset',
                                                       self.channel,
                                                       '{}%-'.format(self.step)))

    def cmd_mute(self):
        if self.mute_command is not None:
            subprocess.call(self.mute_command, shell=True)
        else:
            subprocess.call(self.create_amixer_command('-q',
                                                       'sset',
                                                       self.channel,
                                                       'toggle'))

    def cmd_run_app(self):
        if self.volume_app is not None:
             subprocess.Popen(self.volume_app, shell=True)
