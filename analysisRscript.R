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


#End_Time-Start_Time ----influence on traffic flow----measured by interval(seconds)
library(lubridate)
?lubridate
starttime <- data$Start_Time
endtime <- data$End_Time
se.interval <- interval(start = starttime, end = endtime)
se.length <- int_length(se.interval)   
summary(se.length)

#试图探索车祸对交通的影响时长和严重程度关系,画个含凹槽的箱线图。
#若两个箱的凹槽互不重叠，则表明它们的中位数有显著差异
#varwidth=TRUE则使箱线图的宽度与它们各自的样本大小成正比
boxplot(se.length ~ data$Severity, data = Severity.Length,
        notch = TRUE,
        varwidth = TRUE,
        col = "red",
        main = "影响交通时长与严重程度",
        xlab = "严重程度",
        ylab = "影响交通时长")

#秒为单位是不是太小，换成分钟试试
min.length <- se.length/60
minsl <- data.frame(data$Severity, min.length)
boxplot(min.length ~ data$Severity, data = minsl,
        notch = TRUE,
        varwidth = TRUE,
        col = "red",
        main = "影响时长与严重程度",
        xlab = "严重程度",
        ylab = "影响时长")

#月份、小时作为变量，探究与severity、影响时长的关系（聚类、分类、参考书）







