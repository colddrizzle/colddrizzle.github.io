	凡是强类型语言，声明时必须指定最确切的类型
	而弱类型语言，声明时不必指定类型 当上下文需要他是一个int的时候，就自动转为int，当上下文需要他是一个
	string的时候，就自动转为string


python为什么不需要classloader以及泛型


java中为什么需要设计泛型
* https://docs.oracle.com/javase/tutorial/java/generics/why.html
更深层次的说，java语言的fast fail机制，这导致了java是静态类型与强类型语言。静态类型要求编译时确定类型。强类型意味着类型限制了变量可以存储的值范围、可以进行的操作。
泛型的设计与之是一脉相承的，尽可能的在强类型、静态语言中提供某种折中。其实没有泛型一样可以实现功能，但若不进行类型转换，则编译时确定的类型是上层类型，强类型又会限制操作，因此会报错。泛型是一种语法糖。

泛型与参数化类型之间存在instance关系吗

我在文件A中用T定义一个泛型，然后在B中用T定义另一个泛型，两个泛型之间有关系吗