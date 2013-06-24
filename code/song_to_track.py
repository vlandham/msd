#!/usr/bin/env python

import sys 
import os

input_filename = sys.argv[1]

file_name, file_extension = os.path.splitext(input_filename)
output_filename = file_name + "_with_tracks" + file_extension

song_to_track_filename = 'data/taste_profile_song_to_tracks.txt'


song_to_track = dict()

f = open(song_to_track_filename, 'r')
for line in f:
  fields = line.strip().split('\t')
  if len(fields) >= 2:
    song = fields[0]
    track = fields[1]
    song_to_track[song] = track

f.close()

ignored = 0

out = open(output_filename, 'w')
f = open(input_filename, 'r')
for line in f:
  user, song, count = line.strip().split('\t')
  track = ""

  if song_to_track[song]:
    track = song_to_track[song]
    out.write("\t".join(map(str, [user,track,count])) + "\n")
  else:
    print "ERROR: no track for " + song + "\n"
    ignored += 1

f.close()
out.close()

print "Ignored: " + str(ignored) + "\n"

