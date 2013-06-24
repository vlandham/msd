#!/usr/bin/env python

import os
import sys 
import sqlite3
import unicodedata
import json

def get_tags(track, conn):
  """
  pull out tags for a track from the db
  """
  sql = "SELECT tags.tag FROM tid_tag, tags, tids WHERE tids.ROWID=tid_tag.tid AND tid_tag.tag=tags.ROWID AND tids.tid='%s'" % track
  res = conn.execute(sql)
  data = res.fetchall()
  return map(lambda x: unicodedata.normalize('NFKD', x[0]).encode('ascii','ignore').lower(), data)

def get_meta(track, conn):
  """
  pull out meta data associated with track
  """
  sql = "SELECT songs.* FROM songs WHERE songs.track_id='%s'" % track
  res = conn.execute(sql)
  data = res.fetchone()
  return data

def load_tag_counts(filename):
  f = open(filename, 'r')
  tag_counts = dict()
  for line in f:
    tag, count, plays, count_ratio, play_ratio = line.strip().split("\t")
    t = {'tag': tag, 'count': int(count), 'plays': int(plays), 'count_ratio': float(count_ratio), 'play_ratio': float(play_ratio)}
    tag_counts[tag] = t
  f.close()
  return tag_counts

def load_user_data(filename):
  f = open(filename, 'r')
  users = dict()
  for line in f:
    user, track, count = line.strip().split("\t")
    if user in users:
      users[user][track] = int(count)
    else:
      users[user] = dict()
      users[user][track] = int(count)
  f.close()
  return users

def load_users(filename):
  f = open(filename, 'r')
  users = []
  for line in f:
    user, count = line.strip().split("\t")
    users.append(user)
  f.close()
  return users

def get_all_data(user, tracks, tag_counts):
  tag_data = dict()
  user_data = {'tracks':tracks}
  return user_data

def output_data(user_id, user_data, output_dir):
  output_filename = output_dir + "/" + str(user_id) + ".json"
  out = open(output_filename, 'w')
  out.write(json.dumps(user_data))
  out.close()

output_dir = "data/users"
os.system("mkdir -p " + output_dir)

tag_database = "data/lastfm_tags.db"
tag_conn = sqlite3.connect(tag_database)

meta_conn = sqlite3.connect('./data/track_metadata.db')
meta_conn.row_factory = sqlite3.Row

tag_counts_filename = 'data/tag_counts.txt'
user_data_filename = 'data/top_users_data_filtered_valid_with_tracks.txt'

users_filename = 'data/top_users_short.txt'

tag_counts = load_tag_counts(tag_counts_filename)
user_data = load_user_data(user_data_filename)
users = load_users(users_filename)

for idx, user in enumerate(users):
  print(user + "\n")
  tracks = user_data[user]

  user_data = get_all_data(user, tracks, tag_counts)

  output_data(idx, user_data, output_dir)

tag_conn.close()
meta_conn.close()
