#!/usr/bin/env python

import pygtk
pygtk.require('2.0')
import gtk
import subprocess

class EclipseChooser:
    i = 1
    commands = ["ec-java-indigo.sh","ec-java-kepler.sh","ec-jee-indigo.sh","ec-rcp-indigo.sh"]

    def callback(self, widget, data):
        self.i = data

    def __init__(self):
        dialog = gtk.Dialog("Eclipse Environment Chooser", None, 0, (gtk.STOCK_CANCEL, gtk.RESPONSE_CANCEL, gtk.STOCK_OK, gtk.RESPONSE_OK))
        dialog.set_default_size(250, 300)
        label = gtk.Label("Choose:")
        
        dialog.vbox.pack_start(label, True, True, 0)

        button1 = gtk.RadioButton(None, "JDT Indigo SR2")
        button1.connect("toggled", self.callback, 1)
        #button.set_active(True)
        dialog.vbox.pack_start(button1, True, True, 0)
        #button.show()

        button2 = gtk.RadioButton(button1, "JDT Kepler SR1")
        button2.connect("toggled", self.callback, 2)
        dialog.vbox.pack_start(button2, True, True, 0)
        #button.show()

        button3 = gtk.RadioButton(button1, "Java EE Indigo SR2")
        button3.connect("toggled", self.callback, 3)
        dialog.vbox.pack_start(button3, True, True, 0)
        #button.show()

        button4 = gtk.RadioButton(button1, "RCP/PDE Indigo SR2")
        button4.connect("toggled", self.callback, 4)
        dialog.vbox.pack_start(button4, True, True, 0)
        #button.show()
        
        dialog.show_all()

        response = dialog.run()
        
        if response == gtk.RESPONSE_OK:
            cmd = "/home/yusiwen/" + self.commands[self.i-1]
            #print(self.i)
            #print(cmd)
            subprocess.Popen([cmd])
        
        dialog.destroy()
      

if __name__ == "__main__":
	EclipseChooser()
