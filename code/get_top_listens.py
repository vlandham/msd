#!/usr/bin/env python

import os 
import sys 
import re
import sqlite3
import unicodedata
import json


def dict_factory(cursor, row):
    d = {}
    for idx, col in enumerate(cursor.description):
        d[col[0]] = row[idx]
    return d


def get_meta(track, conn):
  """
  pull out meta data associated with track
  """
  sql = "SELECT songs.* FROM songs WHERE songs.track_id='%s'" % track
  res = conn.execute(sql)
  data = res.fetchone()
  return data

def output_data(data, output_filename):
  out = open(output_filename, 'w')
  out.write(json.dumps(data))
  out.close()


top_filename = "data/top_listens.txt"


song_to_track_filename = 'data/taste_profile_song_to_tracks.txt'
mismatch_filename = "data/sid_mismatches.txt"

song_to_track = dict()

f = open(song_to_track_filename, 'r')
for line in f:
  fields = line.strip().split('\t')
  if len(fields) >= 2:
    song = fields[0]
    track = fields[1]
    song_to_track[song] = track

f.close()

song_to_track_miss = dict()

f = open(mismatch_filename, 'r')
for line in f:
  match_obj = re.match(r'ERROR: <(.*) (.*)>', line)
  song = match_obj.group(1)
  track = match_obj.group(2)

  song_to_track_miss[song] = track

f.close()

top_songs = []
excluded = 0
header = False
f = open(top_filename, 'r')
for line in f:
  if not header:
    header = True
    continue
  song, count, plays, leader = line.strip().split('\t')
  if song in song_to_track_miss:
    print "excluding " + song + "\\n"
    excluded += 1
  else:
    is_leader = True if leader == 'TRUE' else False
    #track = song_to_track[song][0]
    top_songs.append({'track_id':song, 'users':int(count), 'plays':int(plays), 'leader':is_leader})

f.close()

meta_conn = sqlite3.connect('./data/track_metadata.db')
#meta_conn.row_factory = sqlite3.Row
meta_conn.row_factory = dict_factory

track_meta = get_meta(track, meta_conn)

for song in top_songs:
  track_meta = get_meta(song['track_id'], meta_conn)
  song['meta'] = track_meta
  
meta_conn.close()

output_filename = 'top/data/top_songs_with_meta.json'

output_data(top_songs, output_filename)


