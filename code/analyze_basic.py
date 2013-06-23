#!/usr/bin/env python

filename = "./data/train_triplets.txt"

f = open(filename, 'r')
song_to_count = dict()
song_to_plays = dict()
user_to_songs = dict()
user_to_plays = dict()
for line in f:
  user, song, count = line.strip().split('\t')
  if song in song_to_count:
    song_to_count[song] += 1
  else:
    song_to_count[song] = 1

  if song in song_to_plays:
    song_to_plays[song] += int(float(count))
  else:
    song_to_plays[song] = 0
    song_to_plays[song] += int(float(count))

  if user in user_to_songs:
    user_to_songs[user] += 1
  else:
    user_to_songs[user] = 1

  if user in user_to_plays:
    user_to_plays[user] += int(float(count))
  else:
    user_to_plays[user] = 0 
    user_to_plays[user] += int(float(count))

f.close()

out = open('song_counts.txt', 'w')

for key, value in song_to_count.iteritems():
  out.write("\t".join(map(str, [key, value])) + "\n")

out.close()

out = open('song_plays.txt', 'w')

for key, value in song_to_plays.iteritems():
  out.write("\t".join(map(str, [key, value])) + "\n")

out.close()

out = open('user_songs.txt', 'w')

for key, value in user_to_songs.iteritems():
  out.write("\t".join(map(str, [key, value])) + "\n")

out.close()

out = open('user_plays.txt', 'w')

for key, value in user_to_plays.iteritems():
  out.write("\t".join(map(str, [key, value])) + "\n")

out.close()
