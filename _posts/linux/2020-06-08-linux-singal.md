https://blog.csdn.net/whatday/article/details/90136670



ctrl+c terminal
ctrl+z suspend
ctrl+d exit

Question:

1：kill信号无法杀死内核态进程 什么是内核态
	网络阻塞是内核态吗

2：kill命令默认发送的信号是什么 

3：实测sock阻塞状态kill默认信号能处理 那么能否自定义其他信号打破这个阻塞状态

4. kill -9 似乎直接关闭程序 而kill默认信号则能执行关闭sock等一些收尾动作
这两个信号还有什么区别