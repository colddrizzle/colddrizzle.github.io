什么叫动态语言 有哪些特征


大架构：https://blog.csdn.net/u014162133/article/details/81911933












软件开发管理
	https://en.wanweibaike.com/wiki-Agile_software_development
	什么是敏捷， 与极限、scrum的关系。TDD只是一种编程，敏捷包括需求、协作、迭代管理等等，要宽泛的多



TDD 测试驱动开发


多线程测试


xunit网站是个宝藏

设计模式背后的原则有哪些比如开闭原则


序列化与反序列化
协议：
https://www.iteye.com/blog/yanglaoda-2218442

这些协议一般要解决的问题？比如类型？安全？ 速度？

fastjson的安全漏洞：https://www.cnblogs.com/hollischuang/p/13253321.html




软件边界实践（前后端接口、后端与数据库）中，经常需要添加字段、减少字段，这正常吗，有没有好办法应对这个？
添加字段涉及的影响很广，最大可能下至数据库，上至前段界面都需要改。如果这种改动很频繁，说明什么？假如一个应用不得不很频繁的改动？

可以作为blob存到数据库中去，中间作为xml、json等数据传输，通常这是可行的。

但是如果blob同时还有检索的需求？

		那么这引出另一个问题：什么样的检索需求可以不引入search系统






