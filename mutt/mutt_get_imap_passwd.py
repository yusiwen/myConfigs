#!/usr/bin/env python

import keyring

passwd = keyring.get_password("gmail","yusiwen@gmail.com")
print 'set imap_pass = "%s"' % (passwd,)
print 'set smtp_pass = "%s"' % (passwd,)
