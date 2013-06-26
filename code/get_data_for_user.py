#!/usr/bin/env python

import os
import sys 
import sqlite3
import unicodedata
import json
from faker import name

def dict_factory(cursor, row):
    d = {}
    for idx, col in enumerate(cursor.description):
        d[col[0]] = row[idx]
    return d

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

def load_tag_averages(filename):
  f = open(filename, 'r')
  tag_counts = dict()
  raw_tags = []
  for line in f:
    tag, avg_count, avg_count_per_track, avg_count_per_tags = line.strip().split("\t")
    t = {'tag': tag, 'avg_count': float(avg_count), 'avg_count_per_user_tracks': float(avg_count_per_track), 'avg_count_per_user_tags': float(avg_count_per_tags)}
    #tag, count, plays, count_ratio, play_ratio = line.strip().split("\\t")
    #t = {'tag': tag, 'count': int(count), 'plays': int(plays), 'count_ratio': float(count_ratio), 'play_ratio': float(play_ratio)}
    raw_tags.append(t)
  sorted_tags = sorted(raw_tags, key = lambda t: t['avg_count'], reverse = True)
  for idx, tag in enumerate(sorted_tags):
    tag['rank'] = idx + 1
    tag_counts[tag['tag']] = tag
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

def get_all_tags(tracks, tag_counts):
  global tag_conn
  global meta_conn
  tags_data = dict()
  all_tracks = []
  track_count = 0
  play_count = 0
  for track, plays in tracks.iteritems():
    track_count += 1
    play_count += int(plays)
    track_meta = get_meta(track, meta_conn)
    track_meta['play_count'] = plays
    all_tracks.append(track_meta)
    tags = get_tags(track, tag_conn)
    for tag in tags:
      if len(tag) == 0:
        continue
      if tag in tags_data:
        tags_data[tag]['tracks'].append(track_meta)
      else:
        tag_stats = {}
        if tag in tag_counts:
          #print(tag + "\\n")
          tag_stats = tag_counts[tag]
        tag_data = {'id':tag, 'all_stats':tag_stats, 'tracks':[track_meta]}
        tags_data[tag] = tag_data

  all_tags = tags_data.values()

  sorted_tracks = sorted(all_tracks, key = lambda t: int(t['play_count']), reverse = True)
  top_tracks = sorted_tracks[0:30]

  # sort tags by number of tracks they have
  sorted_tags = sorted(all_tags, key = lambda t: len(t['tracks']), reverse = True)
  tag_count = len(sorted_tags)
  # add some stats for each tag group
  for idx, tag in enumerate(sorted_tags):
    # sort tracks by play count
    tag['tracks'] = sorted(tag['tracks'], key = lambda t: t['play_count'], reverse = True)
    tag_track_count = len(tag['tracks'])
    
    tag_play_count = sum(map(lambda x: x['play_count'], tag['tracks']))
    tag_count_ratio = tag_track_count / float(track_count)
    tag_play_ratio = tag_play_count / float(play_count)
    tag_stats = {'count':tag_track_count, 'plays':tag_play_count, 'count_ratio': tag_count_ratio, 'play_ratio': tag_play_ratio, 'rank': idx + 1}
    tag['tag_stats'] = tag_stats

    # now limit the size of the tracks array
    max_track_num = 35
    tag['tracks'] = tag['tracks'][0:max_track_num]


  # now limit the number of tags we stor.
  # right now, just use constant

  sorted_tags = sorted_tags[0:50]
  return sorted_tags, top_tracks, tag_count


def get_all_data(user, user_id, tracks, tag_counts):
  tag_data = dict()
  user_name = name.find_name()
  tags, top_tracks, tag_count = get_all_tags(tracks, tag_counts)
  user_data = {'name': user_name, 'id':user_id, 'tags':tags, 'top_tracks':top_tracks, 'total_tracks':len(tracks), 'total_tags':tag_count}
  return user_data

def output_data(user_id, user_data, output_dir):
  output_filename = output_dir + "/" + str(user_id) + ".json"
  out = open(output_filename, 'w')
  out.write(json.dumps(user_data))
  out.close()

output_dir = "vis/data/users"
os.system("mkdir -p " + output_dir)

output_index_file = output_dir + "/all.csv"

tag_database = "data/lastfm_tags.db"
tag_conn = sqlite3.connect(tag_database)

meta_conn = sqlite3.connect('./data/track_metadata.db')
#meta_conn.row_factory = sqlite3.Row
meta_conn.row_factory = dict_factory

#tag_counts_filename = 'data/tag_counts.txt'
tag_counts_filename = 'data/tag_averages_100.txt'
user_data_filename = 'data/top_users_data_filtered_valid_with_tracks.txt'
users_filename = 'data/top_users_short.txt'

tag_counts = load_tag_averages(tag_counts_filename)
all_user_data = load_user_data(user_data_filename)
users = load_users(users_filename)


print str(len(all_user_data))
out = open(output_index_file, 'w')
out.write(",".join(["index", "name"]) + "\n")
for idx, user in enumerate(users):
  print(user + "\n")
  tracks = all_user_data[user]

  user_data = get_all_data(user, idx, tracks, tag_counts)

  output_data(idx, user_data, output_dir)
  out.write(",".join([str(idx), user_data["name"]]) + "\n")

tag_conn.close()
meta_conn.close()
out.close()
