#!/usr/bin/env ruby

beginning_time = Time.now


filename = "./data/train_triplets.txt"

song_to_count = Hash.new(0)

File.open(filename,'r').each_line do |line|
  fields = line.split("\t")
  song_to_count[fields[1]] += 1
end

end_time = Time.now
puts "Time elapsed #{(end_time - beginning_time)} secs"

