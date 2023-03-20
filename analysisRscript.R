library(readxl)
library(data.table)
data <- fread("US_Accidents_Dec21_updated.csv")
#吹爆这个fread函数不仅读入数据比老师介绍的快的多
#还直接把start_time与end_time直接读入为POSIXct模式
data <- data.table(data)
summary(data)

#将最后18个属性转化为因子类型
data.names <- names(data)
for(i in data.names[30:47]){
  data[[i]] <- as.factor(data[[i]])
}

data$Severity <- as.factor(data$Severity)
data$Side <- as.factor(data$Side)
data$Wind_Direction <- as.factor(data$Wind_Direction)
data$Timezone <- as.factor(data$Timezone)

#注意到Turning_Loop列结果竟然全是“false”，将该列删除
library(dplyr)
data <- select(data,-Turning_Loop)
#最后四个不同晨昏度的列，as.factor直接把NA值化为“”作为一个factor
#只有2867条数据同时缺少最后四组数据，将其直接删除
data <- subset(data,data$Sunrise_Sunset != "")
data <- subset(data,data$Side != "N")

#该部分对表征一系列事故发生时的气象信息的数据中的缺失值进行了处理
#经过处理的几列数据缺失值的量都较少，采用直接删除法，经过删除后数据集剩余266万条
data <- subset(data,!is.na(data$`Temperature(F)`))
data <- subset(data,!is.na(data$`Visibility(mi)`))
data <- subset(data,!is.na(data$`Humidity(%)`))
data <- subset(data,!is.na(data$`Wind_Speed(mph)`))
data <- subset(data,!is.na(data$`Pressure(in)`))
#仍然存在Wind_Chill.F.和Precipitation.in. 两个属性缺失较大
#有30-40万条，不宜直接删除，建议暂缓对其的分析

str(data)
head(data)
tail(data)
summary(data)


library(ggplot2)
#观察到wind_Direction转化为因子后有25个值，浅浅画一个bar看下分布
#发现出现W、west这种同义词不同表达的情况怎么处理之后再说qwq
ggplot(data,aes(x = Wind_Direction)) +
  geom_bar()

ggplot(data,aes(x = Side)) +
  geom_bar()

ggplot(data, aes(x = Timezone)) +
  geom_bar()

ggplot(data, aes(x = Weather_Condition)) +
  geom_bar()


ggplot(data,aes(x = Severity, y = `Temperature(F)`)) +
  geom_violin() 








