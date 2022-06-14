library(readr)
df <- read_csv("/Users/amithnair/Documents/Assignments/Sem2/Applied Statistical Modelling/Final assignment/data/analysis.csv")
white_df <- df[c("White.Player", "White.ACPL", "Year", "PreDeepBlue")]
white_df["Is.White"] <-1
black_df <- df[c("Black.Player", "Black.ACPL", "Year", "PreDeepBlue")]
black_df["Is.White"] <-0
col_names <- c("Player", "ACPL", "Year", "PreDeepBlue", "Is.White")
colnames(white_df) <- col_names
colnames(black_df) <- col_names
data <- rbind(white_df,black_df)
library(dplyr)
library(ggplot2)
ggplot(data, aes(ACPL)) + stat_bin()
ggplot(data) + geom_boxplot(aes(x = reorder(Year, Year, median), ACPL))+theme(axis.text.x=element_text(angle=90, hjust=1))
data$Year <- scale(data$Year)
data$ACPL <- scale(data$ACPL)
data$Player <- factor(data$Player)
ad<-aggregate(cbind(data$ACPL, data$PreDeepBlue), by = list(data$Year, data$Player), FUN = mean)
colnames(ad)<-c("Year", "Player", "ACPL", "PreDeepBlue")

lm1 <- lm(ACPL~PreDeepBlue, ad)
summary(lm1)
step(lm1)

lm2 <- lm(ACPL~Year, ad)
summary(lm2)
step(lm2)


lm3 <- lm(ACPL~exp(-0.5*(min(Year) + Year)), ad)
summary(lm3)
step(lm3)

lm3 <- lm(ACPL~exp(-2*Year), ad)
summary(lm3)
step(lm3)

lm3 <- lm(ACPL~exp(-0.4*Year), ad)
summary(lm3)
step(lm3)

lm4 <- lm(ACPL~exp(-0.4*Year) + PreDeepBlue, ad)
summary(lm4)
step(lm4)


lm5 <- lm(ACPL~exp(-0.4*Year) + Player, ad)
summary(lm5)
step(lm5)




coef_list <- coef(lm5)
coef_list <- coef_list[-c(1, 2)]

name_list <- names(coef_list)
library(stringr)
for (i in 1:38){
name_list[i] = str_replace(name_list[i], 'Player','')
}
names(coef_list) <- name_list


install.packages("tidytext")
library(tidytext)
library(dplyr)
library(tidyr)


output <- enframe(as.list(coef_list)) %>% unnest
colnames(output) <- c("Player", "ACPL_Difference")
ggplot(output, aes(Player, ACPL_Difference)) +
geom_bar(stat = "identity", aes(fill = Player), show.legend = FALSE)+
theme(axis.text.x=element_text(angle=90, hjust=1))







