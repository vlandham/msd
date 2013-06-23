

# number of user ID's in the file
cat train_triplets.txt | cut -f 1 | uniq | wc -l
# 1019318
# 1,019,318

# number of song ID's in the file
cat train_triplets.txt | cut -f 2 | uniq | wc -l
# 48373586
# 48,373,586


# count up of all playcounts

cat train_triplets.txt | cut -f 3 | awk '{total += $0} END{print "sum="total}'
# sum=138680243
# sum=138,680,243

