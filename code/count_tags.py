#!/usr/bin/env python

import sys
import os
import operator


input_filename = sys.argv[1]

output_filename = "data/tag_counts.txt"

f = open(input_filename, 'r')

tag_counts = dict()
tag_plays  = dict()

total_count = 0
total_plays = 0

for line in f:
  #print(line)
  fields = line.strip().split("\t")
  if len(fields) < 3:
    continue
  tag = fields[0]
  track = fields[1]
  count = fields[2]

  total_count += 1
  total_plays += int(count)

  #tag, track, count = fields
  if tag in tag_counts:
    tag_counts[tag] += 1
  else:
    tag_counts[tag] = 0
    tag_counts[tag] += 1

  if tag in tag_plays:
    tag_plays[tag] += int(count)
  else:
    tag_plays[tag] = 0
    tag_plays[tag] += int(count)

f.close()

tags_ordered = sorted(tag_counts.iteritems(), key=operator.itemgetter(1), reverse=True)

out = open(output_filename, 'w')
for tag, count in tags_ordered:
  count = tag_counts[tag]
  plays = tag_plays[tag]
  count_ratio = count / float(total_count)
  play_ratio = plays / float(total_plays)
  out.write("\t".join(map(str, [tag, count, plays, count_ratio, play_ratio])) + "\n")

out.close()
