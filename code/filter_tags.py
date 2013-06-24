#!/usr/bin/env python

import sys
import os

min_count = 10

input_filename = sys.argv[1]

file_name, file_extension = os.path.splitext(input_filename)
output_filename = file_name + "_filtered_" + str(min_count) + file_extension


print(output_filename)

f = open(input_filename, 'r')

tag_counts = dict()

for line in f:
  #print(line)
  fields = line.strip().split("\t")
  if len(fields) < 3:
    continue
  tag = fields[0]
  track = fields[1]
  count = fields[2]
  #tag, track, count = fields
  if tag in tag_counts:
    tag_counts[tag] += 1
  else:
    tag_counts[tag] = 0
    tag_counts[tag] += 1

f.close()

out = open(output_filename, 'w')
f = open(input_filename, 'r')
for line in f:
  fields = line.strip().split("\t")
  if len(fields) < 3:
    continue
  tag = fields[0]
  track = fields[1]
  count = fields[2]
  tag_count = tag_counts[tag]
  if tag_count > min_count:
    out.write(line)

f.close()
out.close()
