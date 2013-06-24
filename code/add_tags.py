#!/usr/bin/env python

import os
import sys 
import sqlite3
import unicodedata

input_filename = sys.argv[1]

output_filename = "data/tags_songs_counts.txt"


def sanitize(tag):
    """
    sanitize a tag so it can be included or queried in the db
    """
    tag = tag.replace("'","''")
    return tag

def get_tags(track, conn):
  """
  pull out tags for a track from the db
  """
  sql = "SELECT tags.tag FROM tid_tag, tags, tids WHERE tids.ROWID=tid_tag.tid AND tid_tag.tag=tags.ROWID AND tids.tid='%s'" % track
  res = conn.execute(sql)
  data = res.fetchall()
  return map(lambda x: unicodedata.normalize('NFKD', x[0]).encode('ascii','ignore').lower(), data)



database = "data/lastfm_tags.db"

conn = sqlite3.connect(database)


f = open(input_filename, 'r')
out = open(output_filename, 'w')

tagless = 0

for line in f:
  track, count = line.strip().split("\t")
  tags = get_tags(track, conn)
  if len(tags) == 0:
    print "no tags for " + track + "\n"
    tagless += 1
  print str(len(tags)) + "\n"
  for tag in tags:
    tag = tag
    #print str(tag) + "\\n"
    out.write("\t".join(map(str, [tag, track, count])) + "\n")

f.close()
out.close()

conn.close()

print "tagless: " + str(tagless) + "\n"
