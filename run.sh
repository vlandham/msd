
## filter
code/filter_valid.py data/train_triplets.txt
code/song_to_track.py data/train_triplets_filtered_valid.txt

## counts
code/analyze_basic.py data/train_triplets_filtered_valid_with_tracks.txt

## top users
# the R script code/analyze_basic.R provides data/top_users.txt
code/filter_top.py #outputs top_users_data.txt
code/filter_valid.py data/top_users_data.txt
code/song_to_track.py data/top_users_data_filtered_valid.txt

## tags
code/add_tags.py data/song_counts.txt
code/count_tags.py data/tags_songs_counts.txt
# these were just doing basic counting

# i wanted to get the average user tag count
# this takes awhile...
./code/average_tags.py data/top_users_data_filtered_valid_with_tracks.txt data/tag_counts.txt
mv data/tag_averages.txt data/tag_averages_100.txt

# main program that pulls out relevant data to be displayed
# dumps in vis/data/users
./code/get_data_for_user.py

