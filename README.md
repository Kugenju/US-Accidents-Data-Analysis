# US-Accidents-Data-Analysis
##对目前的一些讨论进行一个汇总
还没有认真排版

1.real-time car accident prediction(时间)
哪些月份/时间段是事故高发期
Start_Time， End_Time

2.car accidents hotspot locations（地点）
事故高发地
longitude, latitude

与道路左右侧的关系
Side

3/16  by lxy
2.1如果有可能的话，将事故高发地的经纬度高频出现的区域在谷歌地图上标记出来，或许能做个可视化什么的。可能会得出学校，写字楼什么的，繁华的街道之类的会高发。

2.2 可以注意一下traffic-calming的相关设施。比如bump的反向因果，是事故高发才设置bump吗？如果有可能的话对比一下其他条件相似的情况下，bump的设置有没有降低事故率。

是否有便利设施（可能停靠？）、斑马线、节点、出口...
Amenity， Crossing， Junction， No_Exit...

交通设施情况：交通减速标志、交通信号、环形回车道
Traffic_Calming， Traffic_Signal， Turning_Loop
by lxy

3.对交通秩序影响的程度
Severity, Distance
虽然已经有severity 了，也不妨开始结束时间减一下看看交通具体被影响了多久

4.extracting cause and effect rules to predict car accidents（因果）
突然变速...
Bump...

5.studying the impact of precipitation or other environmental stimuli on accident occurrence.
（自然因素）如温度、风、湿度、气压、可见度...

3/16 by lxy
Temperature(F)， Wind_Chill(F)， Humidity(%)...
可视度那里也可以参考一下最后三列的晨昏蒙影，也会影响可视度。结合1中的时间，个人猜测晨昏蒙影那一段也可能高发，如果是的话也可以用来验证
by lxy

6.the impact of COVID-19 on traffic behavior and accidents
"
3/15 by lxt
