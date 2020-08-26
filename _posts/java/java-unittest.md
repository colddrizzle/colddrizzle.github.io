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

其他日程：

测试替身里面还有一类叫
Test-Specific Subclass
http://xunitpatterns.com/Test-Specific%20Subclass.html
这个名词是在看[Poor Man's Humble Object](http://xunitpatterns.com/Humble%20Object.html#Poor%20Man)时提到的。
似乎这些类能打破原有类的封装（原文：This approach is the "poor man's" Humble Object and it works fine if there are no obstacles to instantiating the Humble Object (e.g. automatically starting its thread, no public constructor, unsatisfiable dependencies, etc..) Use of a Test-Specific Subclass can also help break these dependencies by providing a test-friendly constructor and exposing private methods to the test.），看看为什么要用这种东西


