#!/usr/bin/env python

# vim: tabstop=2 expandtab shiftwidth=2 softtabstop=2

import os
import pygtk
pygtk.require('2.0')
import gtk
import subprocess

class EclipseChooser:
  i = 1
  eclipse_dir = "/opt/eclipse"
  eclipse_args = ['eclipse', '-vm', '', '-nosplash']
  idea_dir = '/opt/intellij'
  idea_args = ['bin/idea.sh']

  commands = []

  def check_env(self):
    javahome = os.environ['JAVA_HOME']
    # Linux is the default os
    # Windows ?
    if os.name == 'nt':
      self.eclipse_dir = 'j:/eclipse'
      self.eclipse_args[0] = 'eclipse.exe'
      self.eclipse_args[2] = os.path.join(javahome, 'jre/bin/javaw.exe')
      self.idea_dir = 'j:/intellij'
      self.idea_args = ['bin/idea.exe']
    else:
      self.eclipse_args[2] = os.path.join(javahome, 'bin/java')
      print self.eclipse_args[2]
      os.environ['SWT_GTK3'] = "0"
      os.environ['UBUNTU_MENUPROXY'] = "0"

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

  def callback(self, widget, data):
    self.i = data

  def create_radio_box(self):
    radio_box = gtk.VBox()
    button = None
    offset = 1
    for x in self.commands:
      temp_button = gtk.RadioButton(button, x[0])
      temp_button.connect("toggled", self.callback, offset)
      radio_box.pack_start(temp_button, True, True, 0)
      temp_button.show()
      button = temp_button
      offset = offset + 1
    return radio_box

  def __init__(self):

    self.check_env()

    self.find(self.eclipse_dir, self.eclipse_args)
    self.find(self.idea_dir, self.idea_args)

    dialog = gtk.Dialog("Eclipse Environment Chooser", None, 0, (gtk.STOCK_CANCEL, gtk.RESPONSE_CANCEL, gtk.STOCK_OK, gtk.RESPONSE_OK))
    dialog.set_default_response(gtk.RESPONSE_OK)

    frame = gtk.Frame("Choose:")
    frame.set_label_align(0, 0.5)
    dialog.vbox.pack_start(frame, False, True, 10)
    frame.show()

    radio_box = self.create_radio_box()
    frame.add(radio_box)
    radio_box.show()

    dialog.show_all()

    response = dialog.run()
    if response == gtk.RESPONSE_OK:
      cmd = self.commands[self.i-1][1]
      subprocess.Popen(cmd)

    dialog.destroy()

if __name__ == "__main__":
  EclipseChooser()
