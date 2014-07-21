#!/usr/bin/env python

import keyring

passwd = keyring.get_password("mutt","siwen.yu@foxmail.com")
print 'set imap_pass = "%s"' % (passwd,)
print 'set smtp_pass = "%s"' % (passwd,)
