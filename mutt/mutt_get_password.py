#!/usr/bin/env python

import keyring
import sys

if len(sys.argv) != 2:
  print 'mutt_get_password.py mailbox_name'
  sys.exit(1)

mailbox = sys.argv[1]
passwd = ""

if mailbox == "gmail":
  passwd = keyring.get_password("mutt","yusiwen@gmail.com")
elif mailbox == "qq":
  passwd = keyring.get_password("mutt","siwen.yu@foxmail.com")
else:
  passwd = ""

print 'set imap_pass = "%s"' % (passwd,)
print 'set smtp_pass = "%s"' % (passwd,)
