library(reshape)
library(ggplot2)
library(plyr)
library(car)
library(RColorBrewer)

basepath = ''
if (Sys.getenv('HOSTNAME') == 'u15342564.onlinehome-server.com'){
  basepath = '/home/mmcauliffe/data'
} else {
  basepath = 'D:/Data'
}

addResourcePath("audio", paste(basepath, "/audio", sep = '/'))

gg_color_hue <- function(n) {
  hues = seq(15, 375, length=n+1)
  hcl(h=hues, l=65, c=100)[1:n]
}

averageAll = read.csv(paste(basepath, "averageAll.txt", sep = '/'),sep = "\t")
averageAll= subset(averageAll, !is.na(smoothedPitch))
perception = read.csv(paste(basepath, "perception.txt", sep = '/'),sep = "\t")
perception = subset(perception,!is.na(Contour))
d=read.csv(paste(basepath, "responses.txt", sep = '/'),sep = "\t")


