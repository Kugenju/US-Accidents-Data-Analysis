library(readxl)
library(data.table)
data <- fread("US_Accidents_Dec21_updated.csv")
setwd('C:/Users/Etoiles/Desktop/数据科学与数据分析/US-Accidents-Data-Analysis')
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

#使用bar观察到了不同时区的事故发生数有明显的不同是否有什么因素
#导致了这一现象
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


#列联表
mytable <- xtabs(~V1, data=Severity.Length)
mytable
#severity=2的数据太多

#月份、小时作为变量，探究与severity、影响时长的关系（聚类、分类)
library(lubridate)
mon <- month(starttime, label = T)
mon_severity <- data.frame(cbind(Month = mon, Severity = data$Severity))
library(ggplot2)

ggplot(mon_severity, aes(x = Month, y = Severity))+
  geom_violin()
#发现11月，12月，1月异常——这三个月的车祸严重程度在Severity=1上没有分布
#猜测与冬天气温、天气等有关

#月份和天气的关系
attach(data)
mon_temp <- data.frame(cbind(month = mon, temp = data$`Temperature(F)`))
ggplot(mon_temp, aes(x=as.factor(month), y=temp))+
  geom_boxplot()

#月份和可见度的关系
mon_vis <- data.frame(cbind(month = mon, visibility = data$`Visibility(mi)`))
ggplot(mon_vis, aes(x=as.factor(month), y=visibility))+
  geom_boxplot()+
  coord_cartesian(ylim = c(0,50))
#11,12,1月可见度确实比其他低





int <- sample(2,nrow(data),replace = TRUE,prob = c(0.01,0.99))
traindata <- data[int == 1, ]
testdata <-  data[int == 2, ]


library(stats)
#对气候变量进行一个聚类分析
#获取需要聚类的变量
varibles <- traindata[,.(`Temperature(F)`,`Humidity(%)`,`Pressure(in)`,`Visibility(mi)`,`Wind_Speed(mph)`)]
#对变量进行标准化
scaled.varibles <-scale(varibles)


library(cluster)
set.seed(1234)
fit.pam <- pam(scaled.varibles,k = 4,stand = TRUE)
fit.pam$medoids


library(factoextra)
set.seed(123)
fviz_nbclust(scaled.varibles, kmeans, method = "wss") +
  geom_vline(xintercept = 4, linetype = 2)

km.res <- kmeans(scaled.varibles,4,nstart = 25)
km.res$size
km.res$centers
plot(varibles, col = km.res$cluster, pch = 19, 
     main = "K-means with k = 4")
points(km.res$centers, col = 1:2, pch = 8, cex = 3)

aggregate(varibles, by=list(cluster=km.res$cluster), mean)
fviz_cluster(km.res, data = cluster)



# 政策管制因素
# While all states share basic driving rules, such as
# driving on the right side of the road, 
# there are other differences like:
# 1.speed limits,
# 2.safety requirements----alcohol, seatbelt
# 3.insurance minimums,
# 4.vehicle registration regulations.

library(readxl)
drivelaw <- read_excel("drivelaw.xlsx")
drivelaw$Var1 <- as.factor(drivelaw$`POSTAL ABBREVIATION`)
drivelaw <- drivelaw[,-2]
state.ac <- as.data.frame(table(data$State))
state.law <- as.data.frame(cbind(state.ac, drivelaw))
state.law <- state.law[,-c(5,6,11)]

#因子-->数值
library(forcats)
state.law$ALCOHOL <- as.numeric(fct_collapse(state.law$ALCOHOL,
                  "0"="No",
                  "2"="Permanent",
                  "1"=c("2 Years","3 Years","Annual","Annual or Single Trip")))
state.law$SEATBELT <- as.numeric(fct_collapse(state.law$`SEAT BELT Primary enforcement?`,
                                                           "0"=c("no","no law"),
                                                           "1"="yes"))
state.law$CarR <- as.numeric(fct_collapse(state.law$`Car Registration Required?`,
                                                                      "0"="no",
                                                                      "1"="yes"))
state.law <- state.law[,-c(7,8)]
colnames(state.law) <- c("abbr","count","fullname","alcohol","speedlim","insurancemin","seatbelt","carregis")

#poisson regression
attach(state.law)
fit <- glm(count ~ alcohol + speedlim + insurancemin + seatbelt + carregis, 
           data=state.law, family=poisson())
summary(fit)
exp(coef(fit))

#解释模型参数
# 1.对驾车携带酒类的管制越宽松的州，发生交通事故越频繁---符合常识
# 2.限速越高的州，发生交通事故越频繁---符合常识

# 3.强制最低保险费用越高的的州，发生交通事故越频繁---符合常识
#一般来说，最低保险费用分为上路的基本费用和额外费用，保险费用高是因为包含了medical coverage等等
#而人口稀少的地区往往保险费用低，人口密集、交通流量大的地方保险费用高

# 4.强制安全带的州，发生交通事故越频繁---难道是因为事故频繁所以强制安全带？
# 5.要求汽车信息登记的州，发生交通事故越频繁---难道是因为事故频繁所以强制信息登记？