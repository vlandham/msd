setwd('~/code/msd_vis')
opar <- par(col = "#88C2F1", fg = "#8C9195", bg = "#ffffff", family = "sans")

library('ggplot2')

library(scales)

outdir <- "out"

song_counts <- read.table("song_counts.txt", header = FALSE, sep = "\t")
colnames(song_counts) <- c("song", "count")

song_plays <- read.table("song_plays.txt", header = FALSE, sep = "\t")
colnames(song_plays) <- c("song", "plays")

user_songs <- read.table("user_songs.txt", header = FALSE, sep = "\t")
colnames(user_songs) <- c("user", "song_count")

user_plays <- read.table("user_plays.txt", header = FALSE, sep = "\t")
colnames(user_plays) <- c("user", "play_count")

user_song_plays <- merge(user_songs, user_plays, by = "user")
song_counts_plays <- merge(song_counts, song_plays, by = "song")

write.table(user_song_plays, "user_song_plays.txt", sep = "\t",  quote = FALSE, col.names = TRUE, row.names = FALSE)
write.table(song_counts_plays, "song_counts_plays.txt", sep = "\t",  quote = FALSE, col.names = TRUE, row.names = FALSE)


sorted_song_counts <- song_counts[with(song_counts, order(-count)),]
write.table(sorted_song_counts, "sorted_song_counts.txt", sep = "\t",  quote = FALSE, col.names = TRUE, row.names = FALSE)

sorted_user_songs <- user_songs[with(user_songs, order(-song_count)),]
write.table(sorted_user_songs, "sorted_user_songs.txt", sep = "\t",  quote = FALSE, col.names = TRUE, row.names = FALSE)

top_users <- sorted_user_songs[1:2000,]
write.table(top_users, "top_users.txt", sep = "\t",  quote = FALSE, col.names = TRUE, row.names = FALSE)

p <- ggplot(top_users, aes(x = song_count))
p + geom_histogram()
            

p <- ggplot(song_counts, aes(x = count)) + theme_bw() + xlab("Number of Listeners") + labs(title = "Number of Users Song is Listened To By")  + scale_x_continuous(labels = comma) + scale_y_continuous(labels = comma)
p <- p + geom_histogram()
#p
image.name <- paste("./", outdir, "/song_counts_all", ".png", sep = "")
png(image.name, height=800, width=1200)
temppar <- par(col = "#88C2F1", fg = "#8C9195", bg = "#ffffff", family = "sans", cex.axis = 1.3, las = 2, mar = c(12,6,1,1), mgp = c(4.5,1,0))
print(p)
par(temppar)
dev.off()

#p <- ggplot(subset(song_counts, count < 500), aes(x = count)) + theme_bw() + xlab("Number of Listeners - ") + labs(title = "Song Counts")  + scale_x_continuous(labels = comma) + scale_y_continuous(labels = comma)
#p + geom_histogram()

p <- ggplot(song_counts, aes(x = log(count))) + theme_bw() + xlab("Number of Listeners (log scale)") + labs(title = "Log10 Number of Users Song is Listened To By")  + scale_x_continuous(labels = comma) + scale_y_continuous(labels = comma)
p <- p + geom_histogram(binwidth = 0.4)
#p

image.name <- paste("./", outdir, "/song_counts_log", ".png", sep = "")
png(image.name, height=800, width=1200)
temppar <- par(col = "#88C2F1", fg = "#8C9195", bg = "#ffffff", family = "sans", cex.axis = 1.3, las = 2, mar = c(12,6,1,1), mgp = c(4.5,1,0))
print(p)
par(temppar)
dev.off()

#p <- ggplot(subset(song_counts, count > 200 & count < 1500), aes(x = count)) + theme_bw() + xlab("Number of Times Song is Listed") + labs(title = "Song Counts")  + scale_x_continuous(labels = comma) + scale_y_continuous(labels = comma)
#p + geom_histogram(binwidth = 5)

#qplot(count, data=song_counts, geom="histogram")

#p <- qplot(plays, data=song_plays, geom="histogram")
#p

#p <- ggplot(song_plays, aes(x = plays))
#p + geom_histogram()

#p <- ggplot(song_plays, aes(x = log(plays)))
#p + geom_histogram(binwidth = 0.3)

p <- ggplot(user_songs, aes(x = song_count)) + theme_bw() + xlab("Songs Per User") + labs(title = "Number of Songs Users Listen To")  + scale_x_continuous(labels = comma) + scale_y_continuous(labels = comma)
p <- p + geom_histogram()
#p

image.name <- paste("./", outdir, "/user_songs", ".png", sep = "")
png(image.name, height=800, width=1200)
temppar <- par(col = "#88C2F1", fg = "#8C9195", bg = "#ffffff", family = "sans", cex.axis = 1.3, las = 2, mar = c(12,6,1,1), mgp = c(4.5,1,0))
print(p)
par(temppar)
dev.off()

p <- ggplot(user_songs, aes(x = log(song_count))) + theme_bw() + xlab("Songs Per User (log)") + labs(title = "Number of Songs Users Listen To - Log Scale") + scale_x_continuous(labels = comma) + scale_y_continuous(labels = comma)
p <- p + geom_histogram()

image.name <- paste("./", outdir, "/user_songs_log", ".png", sep = "")
png(image.name, height=800, width=1200)
temppar <- par(col = "#88C2F1", fg = "#8C9195", bg = "#ffffff", family = "sans", cex.axis = 1.3, las = 2, mar = c(12,6,1,1), mgp = c(4.5,1,0))
print(p)
par(temppar)
dev.off()

p <- ggplot(user_song_plays, aes(song_count, play_count))+ theme_bw() + xlab("Number of Songs User Listens to") + ylab("Total User Play Count for All Songs")+ labs(title = "User Song Count vs Play Count") + scale_x_continuous(labels = comma) + scale_y_continuous(labels = comma)
p <- p + geom_point()

image.name <- paste("./", outdir, "/user_songs_vs_plays", ".png", sep = "")
png(image.name, height=1000, width=1200)
temppar <- par(col = "#88C2F1", fg = "#8C9195", bg = "#ffffff", family = "sans", cex.axis = 1.3, las = 2, mar = c(12,6,1,1), mgp = c(4.5,1,0))
print(p)
par(temppar)
dev.off()

p <- ggplot(song_counts_plays, aes(count, plays)) + theme_bw() + xlab("Number Users Listened to Song") + ylab("Total Number of Plays for Song")+ labs(title = "Song Users Count vs Number of Plays") + scale_x_continuous(labels = comma) + scale_y_continuous(labels = comma)
p <- p + geom_point()  + stat_smooth(method="lm", se=FALSE)
#p
image.name <- paste("./", outdir, "/song_count_vs_plays", ".png", sep = "")
png(image.name, height=1000, width=1200)
temppar <- par(col = "#88C2F1", fg = "#8C9195", bg = "#ffffff", family = "sans", cex.axis = 1.3, las = 2, mar = c(12,6,1,1), mgp = c(4.5,1,0))
print(p)
par(temppar)
dev.off()

#p <- ggplot(song_counts_plays, aes(1,count))
#p + geom_boxplot()