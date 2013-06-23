#!/usr/bin/env python

from pyechonest import config
config.ECHO_NEST_API_KEY="ODF7R3CSWAICT8V7K"

from pyechonest import artist
bk = artist.Artist('bikini kill')
print "Artists similar to: %s:" % (bk.name,)
for similar_artist in bk.similar: print "\t%s" % (similar_artist.name,)
