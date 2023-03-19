library(readxl)
library(data.table)
data <- read.csv("US_Accidents_Dec21_updated.csv")
data <- data.table(data)
summary(data)

data.names <- names(data)
for(i in data.names[30:47]){
  data[[i]] <- as.factor(data[[i]])
}

data$Side <- as.factor(data$Side)
data$Wind_Direction <- as.factor(data$Wind_Direction)

#注意到Turning_Loop列结果竟然全是“false”，将该列删除
library(dplyr)
data <- select(data,-Turning_Loop)
#最后四个不同晨昏度的列，as.factor直接把NA值化为“”作为一个factor
#只有2867条数据同时缺少最后四组数据，将其直接删除
data <- subset(data,data$Sunrise_Sunset != "")
data <- subset(data,data$Side != "N")
data$Start_Time <- as.Date(data$Start_Time)
data$End_Time <- as.Date(data$End_Time)

str(data)
head(data)
tail(data)

library(ggplot2)
#观察到wind_Direction转化为因子后有25个值，浅浅画一个bar看下分布
#发现出现W、west这种同义词不同表达的情况怎么处理之后再说qwq
ggplot(data,aes(x = Wind_Direction)) +
  geom_bar()

ggplot(data,aes(x = Side)) +
  geom_bar()




