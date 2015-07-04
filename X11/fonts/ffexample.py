#!/usr/bin/env python

import fontforge
import sys

# open font file
org=fontforge.open(sys.argv[1])
# select all CJK glyphs
org.selection.select(("ranges",None),0x4E00,0x9FFF)
# clear all selection
org.clear()
# save the change
org.save()


