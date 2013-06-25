#!/usr/bin/env python

#filename = "./data/train_triplets.txt"

import sys 
import sqlite3
import unicodedata
import json

def chunks(l,n):
  for i in xrange(0, len(l), n):
    yield l[i:i+n]

def get_tags(track, conn):
  """
  pull out tags for a track from the db
  """
  sql = "SELECT tags.tag FROM tid_tag, tags, tids WHERE tids.ROWID=tid_tag.tid AND tid_tag.tag=tags.ROWID AND tids.tid='%s'" % track
  res = conn.execute(sql)
  data = res.fetchall()
  return map(lambda x: unicodedata.normalize('NFKD', x[0]).encode('ascii','ignore').lower(), data)

def get_all_tags(tracks, conn):
  """
  pull out tags for a track from the db
  """
  all_data = []
  for chunk in chunks(tracks, 100):
    sql = "SELECT tags.tag FROM tid_tag, tags, tids WHERE tids.ROWID=tid_tag.tid AND tid_tag.tag=tags.ROWID AND tids.tid in ({seq})".format(seq =','.join(['?'] * len(chunk)))
    res = conn.execute(sql, chunk)
    data = res.fetchall()
    all_data.extend(map(lambda x: unicodedata.normalize('NFKD', x[0]).encode('ascii','ignore').lower(), data))
  return all_data

tag_database = "data/lastfm_tags.db"
tag_conn = sqlite3.connect(tag_database)

users_filename = sys.argv[1]
tags_filename = sys.argv[2]


output_filename = "data/tag_averages.txt"

user_to_tracks = dict()
f = open(users_filename, 'r')
for line in f:
  user, track, count = line.strip().split('\t')
  if user in user_to_tracks:
    user_to_tracks[user].append(track)
  else:
    user_to_tracks[user] = []
    user_to_tracks[user].append(track)
f.close()

print("tracks loaded")

tag_counts = dict()
tag_track_ratios = dict()
tag_all_tag_ratios = dict()

f = open(tags_filename, 'r')
for line in f:
  fields = line.strip().split('\t')
  if int(fields[1]) > 100:
    tag_counts[fields[0]] = []
    tag_track_ratios[fields[0]] = []
    tag_all_tag_ratios[fields[0]] = []
f.close()

print("tags loaded")
print(str(len(tag_counts.keys())))

#user_to_tags = dict()
user_count = 0
for user in user_to_tracks.keys():
  user_count += 1
  if user_count % 100 == 0:
    print str(user_count)

  tracks = user_to_tracks[user]
  tags = get_all_tags(tracks, tag_conn)
  #print(str(len(tags)))
  track_count = len(user_to_tracks[user])
  all_tag_count = len(tags)
  for tag in tag_counts.keys():
    tag_count = tags.count(tag)
    #print(str(tag_count))
    tag_counts[tag].append(tag_count)
    tag_track_ratios[tag].append(tag_count / float(track_count))
    tag_all_tag_ratios[tag].append(tag_count / float(all_tag_count))
  #print("done")

  #user_to_tags[user] = get_all_tags(tracks, tag_conn)

#for tag in tag_counts.keys():
#  for user, tags in user_to_tags.iteritems():
#    track_count = len(user_to_tracks[user])
#    all_tag_count = len(tags)
#    tag_count = tags.count(tag)

    #tag_counts[tag].append(tag_count)
    #tag_track_ratios[tag].append(tag_count / float(track_count))
    #tag_all_tag_ratios[tag].append(tag_count / float(all_tag_count))


out = open(output_filename, 'w')
for tag in tag_counts.keys():
  counts = tag_counts[tag]
  track_ratio = tag_track_ratios[tag]
  tag_ratio = tag_all_tag_ratios[tag]
  avg_count = sum(counts) / float(len(counts))
  avg_track_ratio = sum(track_ratio) / float(len(track_ratio))
  avg_tag_ratio = sum(tag_ratio) / float(len(tag_ratio))

  out.write("\t".join(map(str, [tag, avg_count, avg_track_ratio, avg_tag_ratio])) + "\n")

out.close()

#tracks = user_to_tracks[user_to_tracks.keys()[0]]
#tags = get_all_tags(tracks, tag_conn)
#
#print ",".join(tags)
#
#print str(len(tracks))
#print str(len(tags))
