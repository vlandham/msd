#!/usr/bin/env python

import os
import sys 
import sqlite3
import unicodedata

conn = sqlite3.connect('./data/track_metadata.db')

conn.row_factory = sqlite3.Row

#res = conn_meta.execute("SELECT * FROM sqlite_master WHERE type='table'")
#print res.fetchall()

def get_meta(track, conn):
  """
  pull out meta data associated with track
  """

  sql = "SELECT songs.* FROM songs WHERE songs.track_id='%s'" % track
  res = conn.execute(sql)
  data = res.fetchone()
  return data


t = "TRPTWGR128F1452734"

data = get_meta(t, conn)
print data
