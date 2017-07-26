t <- data.frame(timepoint=seq(1,10), pitch = seq(1,10), sound='a')
t <- rbind(t,data.frame(timepoint=seq(1,10), pitch = seq(10,1,-1), sound='b'))
t <- rbind(t,data.frame(timepoint=seq(1,10), pitch = 5, sound='c'))
write.csv(t, 'data/dummy.txt',quote = F,row.names = F)
