#!/usr/bin/env python

import os 
import sys 
import re

mismatch_filename = "data/sid_mismatches.txt"

input_file = sys.argv[1]

file_name, file_extension = os.path.splitext(input_file)
output_filename = file_name + "_filtered_valid" + file_extension

print output_filename

song_to_track = dict()

f = open(mismatch_filename, 'r')
for line in f:
  match_obj = re.match(r'ERROR: <(.*) (.*)>', line)
  song = match_obj.group(1)
  track = match_obj.group(2)

  song_to_track[song] = track

  #print(song + "-" + track + "\\n")

f.close()

print "mismatches: " + str(len(song_to_track)) + "\n"

out = open(output_filename, 'w')

excluded = 0
f = open(input_file, 'r')
for line in f:
  user, song, count = line.strip().split('\t')
  if song in song_to_track:
    #print "excluding " + song + "\\n"
    excluded += 1
  else:
    out.write(line)

f.close()
out.close()

print "excluded: " + str(excluded) + "\n"
