#!/usr/bin/env python

import time

start = time.clock()
filename = "./data/train_triplets.txt"

f = open(filename, 'r')
song_to_count = dict()
for line in f:
  _, song, _ = line.strip().split('\t')
  if song in song_to_count:
    song_to_count[song] += 1
  else:
    song_to_count[song] = 1

f.close()

songs_ordered = sorted(song_to_count.keys(), key=lambda s: song_to_count[s], reverse=True)

elapsed = (time.clock() - start)
print elapsed
