# Get the Data

# Read in with tidytuesdayR package 
# This loads the readme and all the datasets for the week of interest

#libraries
library(tidyverse)
library(rgl)
library(plot3D)
library(magick)

setwd(dirname(rstudioapi::getActiveDocumentContext()$path)) #set working directory to source file location

#Read in the data manually
members <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-09-22/members.csv')
expeditions <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-09-22/expeditions.csv')
peaks <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-09-22/peaks.csv')
peak_co <- readr::read_csv("./HimalayanMountains.csv") #sources: https://nepalhimalpeakprofile.org/ [accessed 21.11.2021] and https://www.wikipedia.org/ [accessed 21/11/2021]

#subset the data
dead_members <- filter(members, died == "TRUE")
tomb_peaks <- unique(dead_members$peak_id)
year <- sort(unique(dead_members$year), decreasing = FALSE)

#convert coordinates to decimal
peak_co$Lat_dec <- with(peak_co, (Lat_d+(Lat_min/60)+(Lat_s/3600)))
peak_co$Long_dec <- with(peak_co, (Long_d+(Long_min/60)+(Long_s/3600)))
death_co <- merge(peak_co, dead_members) #merge coordinates with fatality data

#create rotatable 3d plot
red_scale <- ramp.col(col = c("darkblue", "red"), n = length(year), alpha = 1) 
col_scale <- data.frame(year, red_scale)
death_co <- merge(death_co, col_scale) #merge coordinates with colour
with(death_co, plot3d(Long_dec, Lat_dec,
                      death_height_metres,
                      type = "h",
                      xlim = c(80, 89),
                      ylim = c(27, 30.2),
                      zlim = c(0, 9000),
                      xlab = "Longitude",
                      ylab = "Latitude",
                      zlab = "Height of Fatality"
                      ))
with(death_co, points3d(Long_dec, Lat_dec,
                      death_height_metres,
                      size = 10, col = death_co$red_scale))
legend3d("topright", 
         legend = paste(c("1905", "2019")), 
         pch = 16, 
         col = c("#00008BFF", "#FF0000FF"), 
         cex=2.5, 
         inset=c(0.05))

aspect3d(1639/666, 1,1) #define correct aspect ratio

#add map background (source: GoogleMaps)
show2d(expression, 
       face = "z-", line = 0, 
       reverse = FALSE, rotate = 0, 
       x = NULL, y = NULL, z = NULL, 
       width = 1639, height = 666, 
       filename = "./NepalMap.png", 
       ignoreExtent = TRUE, 
       color = "white", specular = "black", lit = FALSE, 
       texmipmap = TRUE, texminfilter = "linear.mipmap.linear",
       expand = 1,
       texcoords = matrix(c(0, 1, 1, 0, 0, 0, 1, 1), ncol = 2))
peak_text <- merge(peaks, peak_co)
peak_text <- filter(peak_text, peak_name == "Annapurna I" | peak_name == "Everest" | peak_name == "Manaslu" | peak_name == "Kanjiroba North" | peak_name == "Api Main" | peak_name == "Ganesh I"| peak_name == "Kangchenjunga")
with(peak_text, text3d(Long_dec, Lat_dec, height_metres+500, peak_name ))

#### save as a rotating gif
movie3d(spin3d(axis = c(0,0,1), rpm = 2.5), duration = 24, dir = getwd(), fps = 5, convert = FALSE, clean = FALSE)
frames <- NULL
for(j in 0:120){
  if(j == 1){
    frames <- image_read(sprintf("%s%03d.png", "movie", j))
  } else {
    frames <- c(frames, image_read(sprintf("%s%03d.png", "movie", j)))
  }
}
animation <- image_animate(frames, fps = 10, optimize = TRUE)
image_write(animation, path = "FatalitiesHimalayas.gif")
for(j in 0:120){
  unlink(sprintf("%s%03d.png", "movie", j))
}

