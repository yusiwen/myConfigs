#!/usr/bin/env python
import os
import pygtk
pygtk.require('2.0')
import gtk
import subprocess

class EclipseChooser:
    i = 1
    eclipse_dir = "/opt/eclipse"
    eclipse_args = ['eclipse', '-vm', '/opt/java/jdk1.7.0_75/jre/bin/java', '-nosplash']
    idea_dir = '/opt/intellij'
    idea_args = ['bin/idea.sh']

    commands = []
    
    def check_env(self):
        # Linux is the default os
        # Windows ?
        if os.name == 'nt':
            self.eclipse_dir = 'j:/eclipse'
            self.eclipse_args[0] = 'eclipse.exe'
            self.eclipse_args[2] = 'j:/java/jdk1.7.0_65/jre/bin/javaw.exe'
            self.idea_dir = 'j:/intellij'
            self.idea_args = ['bin/idea.exe']

    def find(self, path, args):
        if os.path.exists(path):
            names = os.listdir(path)
            for name in names:
                tmp_path = os.path.join(path, name)
                if os.path.isdir(tmp_path):
                    temp_list = []
                    temp_list.append(name)
                    temp_args_list = list(args)
                    temp_args_list[0] = os.path.join(tmp_path, temp_args_list[0])
                    temp_list.append(temp_args_list)
                    # print(temp_args_list)
                    self.commands.append(temp_list)

    def find_ideas(self, path):
        names = os.listdir(path)
        for name in names:
            tmp_path = os.path.join(path, name)
            if os.path.isdir(tmp_path):
                temp_list = []
                temp_list.append(name)
                temp_args_list = list(self.idea_args)
                temp_args_list[0] = os.path.join(tmp_path, temp_args_list[0])
                temp_list.append(temp_args_list)
                self.commands.append(temp_list)

    def callback(self, widget, data):
        self.i = data

    def __init__(self):
        
        self.check_env()
        
        self.find(self.eclipse_dir, self.eclipse_args)
        self.find(self.idea_dir, self.idea_args)

        dialog = gtk.Dialog("Eclipse Environment Chooser", None, 0, (gtk.STOCK_CANCEL, gtk.RESPONSE_CANCEL, gtk.STOCK_OK, gtk.RESPONSE_OK))
        dialog.set_default_size(250, 300)
        label = gtk.Label("Choose:")

        dialog.vbox.pack_start(label, True, True, 0)

        button = None
        offset = 1
        for x in self.commands:
            temp_button = gtk.RadioButton(button, x[0])
            temp_button.connect("toggled", self.callback, offset)
            dialog.vbox.pack_start(temp_button, True, True, 0)
            button = temp_button
            offset = offset + 1

        dialog.show_all()

        response = dialog.run()

        if response == gtk.RESPONSE_OK:
            cmd = self.commands[self.i-1][1]
            subprocess.Popen(cmd)
        
        dialog.destroy()

if __name__ == "__main__":
    EclipseChooser()
