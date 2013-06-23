#!/usr/bin/env python
"""
Thierry Bertin-Mahieux (2011) Columbia University
tb2332@columbia.edu


This code shows how to use the SQLite database made with tags
from the Last.fm dataset.
Code developed using python 2.6 on an Ubuntu machine, utf-8 by default.

This is part of the Million Song Dataset project from
LabROSA (Columbia University) and The Echo Nest.


Copyright 2011, Thierry Bertin-Mahieux <tb2332@columbia.edu>

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
"""

import os
import sys
import sqlite3


def sanitize(tag):
    """
    sanitize a tag so it can be included or queried in the db
    """
    tag = tag.replace("'","''")
    return tag


def die_with_usage():
    """ HELP MENU """
    print 'demo_tags_db.py'
    print '  by T. Bertin-Mahieux (2011) tb2332@columbia.edu'
    print ''
    print 'Shows how to use the SQLite database made from tags'
    print 'in the Last.fm dataset.'
    print ''
    print 'USAGE:'
    print '  ./demo_tags_db.py <tags.db>'
    sys.exit(0)


if __name__ == '__main__':

    if len(sys.argv) != 2:
        die_with_usage()

    # param
    dbfile = sys.argv[1]

    # sanity check
    if not os.path.isfile(dbfile):
        print 'ERROR: db file %s does not exist?' % dbfile
        die_with_usage()

    # open connection
    conn = sqlite3.connect(dbfile)

    # EXAMPLE 1
    print '************** DEMO 1 **************'
    print 'Get the list of all unique tags'
    sql = "SELECT tag FROM tags"
    res = conn.execute(sql)
    data = res.fetchall()
    for k in range(10):
        print data[k]
    print '...'
    print '(total number of tags: %d)' % len(data)

    # EXAMPLE 2
    print '************** DEMO 2 **************'
    print 'We get all tracks with at least one tag'
    sql = "SELECT tid FROM tids"
    res = conn.execute(sql)
    data = res.fetchall()
    for k in range(10):
        print data[k]
    print '...'
    print '(total number of track IDs: %d)' % len(data)

    # EXAMPLE 3
    print '************** DEMO 3 **************'
    tid = 'TRCCOFQ128F4285A9E'
    print 'We get all tags (with value) for track: %s' % tid
    sql = "SELECT tags.tag, tid_tag.val FROM tid_tag, tids, tags WHERE tags.ROWID=tid_tag.tag AND tid_tag.tid=tids.ROWID and tids.tid='%s'" % tid
    res = conn.execute(sql)
    data = res.fetchall()
    print data

    # EXAMPLE 4
    print '************** DEMO 4 **************'
    tag = 'Acid Smurfs'
    print 'We get all tracks for the tag: %s' % tag
    sql = "SELECT tids.tid FROM tid_tag, tids, tags WHERE tids.ROWID=tid_tag.tid AND tid_tag.tag=tags.ROWID AND tags.tag='%s'" % sanitize(tag)
    res = conn.execute(sql)
    data = res.fetchall()
    print map(lambda x: x[0], data)

    # EXAMPLE 5
    print '************** DEMO 5 **************'
    print "We get all tags and the number of tracks they're applied to"
    sql = "SELECT tags.tag, COUNT(tid_tag.tid) FROM tid_tag, tags WHERE tid_tag.tag=tags.ROWID GROUP BY tags.tag"
    res = conn.execute(sql)
    data = res.fetchall()
    data = sorted(data, key=lambda x: x[1], reverse=True)
    print 'after sorting...'
    for k in range(10):
        print data[k]
    print '...'


    # done, close connection
    conn.close()
    

