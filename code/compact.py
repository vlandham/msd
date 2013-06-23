#!/usr/bin/env python

import time

start = time.clock()
filename = "./data/train_triplets.txt"

f = open(filename, 'r')
song_to_count = dict()
song_to_index = dict()
user_to_index = dict()

user_index = 0
song_index = 0
for line in f:
  user, song, count = line.strip().split('\t')
  if song in song_to_count:
    song_to_count[song] += 1
  else:
    song_to_count[song] = 1

  if user in user_to_index:
    d = 1
  else:
    user_to_index[user] = user_index
    user_index += 1

  if song in song_to_index:
    d = 1
  else:
    song_to_index[song] = song_index
    song_index += 1

f.close()

out = open('compressed_triplets.txt', 'w')
f = open(filename, 'r')
for line in f:
  user, song, count = line.strip().split('\t')
  user_id = user_to_index[user]
  song_id = song_to_index[song]
  ll = [user_id, song_id, count]
  out.write("\t".join(map(str, ll)) + "\n")


f.close()
out.close()

#songs_ordered = sorted(song_to_count.keys(), key=lambda s: song_to_count[s], reverse=True)

elapsed = (time.clock() - start)
print elapsed
