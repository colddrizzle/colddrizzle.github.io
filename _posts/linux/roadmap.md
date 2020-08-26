https://www.cnblogs.com/tcicy/p/8461344.html


X windows CS概念以及设法实现远程桌面
https://blog.csdn.net/qq_27825451/article/details/88735264

linux终端窗口管理工具
https://linux.cn/article-10962-1.html
http://c.biancheng.net/linux/tmux.html


Thread Local Storage，线程本地存储，大神Ulrich Drepper有篇PDF文档是讲TLS的，我曾经努力过三次尝试搞清楚TLS的原理，均没有彻底搞清楚。这一次是第三次，我沉浸glibc的源码和kernel的源码中，做了一些实验，也有所得。对Linux的线程有了进一步的理解。
线程也是需要栈空间的这句话是废话，呵呵。对于属于同一个进程（或者说是线程组）的多个线程他们是共享一份虚拟内存地址的，如下图所示。这也就决定了，你不能无限制创建线，因为纵然你什么都不做，每个线程默认耗费8M的空间（事实上还不止，还有管理结构，后面陈述）。Ulrich Drepper大神有篇文章《Thread numbers and stacks》，分析了线程栈空间方面的计算。

systemd入门教程：http://www.ruanyifeng.com/blog/2016/03/systemd-tutorial-commands.html


linux下进程的退出：
https://blog.csdn.net/GerryLee93/article/details/106476301
http://blog.chinaunix.net/uid-31415216-id-5755884.html
https://blog.csdn.net/weixin_43886592/article/details/85249092

linux pthread:
	https://blog.csdn.net/hairetz/article/details/4535920
	线程的取消：
	https://www.cnblogs.com/lijunamneg/archive/2013/01/25/2877211.html
	https://wiki.sei.cmu.edu/confluence/display/c/POS47-C.+Do+not+use+threads+that+can+be+canceled+asynchronously

linux X windows概念以及远程桌面
https://blog.csdn.net/qq_27825451/article/details/88735264
https://www.cnblogs.com/youxia/p/linux003.html

调试手段backtrace:
https://www.cnblogs.com/sky-heaven/p/9235100.html
