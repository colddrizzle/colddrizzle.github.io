<--
	网络：信号

日程：固有与非固有难度的测试代码

固有难度：
	异步测试


日程：java testng简明入门


日程：testng启动异步线程去测试，线程里面报错会怎么样


学习testng
	之前 
		-- ant简明教程
		-- maven简明教程
		-- Ivy简明教程


由ant引出的是java 类加载

有类加载 类加载的具体过程

		---- 目前还是想先做完类加载

				-------------
				了解到jdk9取消了bootclasspath，又联想到jdk11取消了jre，于是决定花一天了解下java模块化。

				了解java模块化就需要读JLS，因此有决定做一个JLS文档，用python的urllib与http协议

				了解urllib之前又决定学习下HTTP1.1
					因此又接触到BNF  √
						由BNF由涉及到文法体系 √
							目前在搞文法体系  √

		---- 做类加载的过程中了解几个classloader的默认加载路径
		---- 了解到bootclasspath相关
		---- 因而决定搞一下system properties 与env

			--- 随便了解下java调优的资料


引出常量池 引出一些奇怪的invoke字段

引出class文件格式

引出jvm规范 连接 加载 执行

由读取class文件格式引出java.io  @

到pumpedin与pumpedout 单独分析  @

从其中&0xFF引出java基本类型，引出浮点数 √

引出java 核心与jls 到最后我想给java core笔记，给jls写git代码注解

java 核心目前已基本完成了第三章

jls注解想从第5章 类型转换开始


而我想写jls笔记的原因在于这篇文章：https://blog.csdn.net/weixin_36554701/article/details/78570568

想要弄清楚什么时候发生类型转换，目前已知的是要参考JLS 第5章与第15章中相应的表达式小节



其他日程：

测试替身里面还有一类叫
Test-Specific Subclass
http://xunitpatterns.com/Test-Specific%20Subclass.html
这个名词是在看[Poor Man's Humble Object](http://xunitpatterns.com/Humble%20Object.html#Poor%20Man)时提到的。
似乎这些类能打破原有类的封装（原文：This approach is the "poor man's" Humble Object and it works fine if there are no obstacles to instantiating the Humble Object (e.g. automatically starting its thread, no public constructor, unsatisfiable dependencies, etc..) Use of a Test-Specific Subclass can also help break these dependencies by providing a test-friendly constructor and exposing private methods to the test.），看看为什么要用这种东西


