#!/usr/bin/env python

top_filename = "./data/top_users.txt"
filename = "./data/train_triplets.txt"

output_filename = "./data/top_users_data.txt"

top_users = []
f = open(top_filename, 'r')
for line in f:
  user, count = line.strip().split('\t')
  top_users.append(user)
f.close()


out = open(output_filename, 'w')
f = open(filename, 'r')
for line in f:
  user, song, count = line.strip().split('\t')
  if user in top_users:
    out.write(line)
f.close()

out.close()
