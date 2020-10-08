这系列的主题：

有关语言 但有不关具体预言的东西

比如编译、语法

格式化、高亮技术

编程范式
	面向切面

或者语言直接横向比较等




RG_RL、CFG_CFL篇不能替代词法分析与语法分析篇



文法与各个编程语言的关系：

python is not context free:
https://www.cs.unc.edu/~plaisted/comp455/Python%20is%20not%20context%20free.htm
https://cs.stackexchange.com/questions/77989/is-python-a-context-free-language


	真实的语言解析过程：
	以python为例，下面资料举了一个往python添加新语法的例子，相关资料也很有用：
https://docs.python.org/2/reference/grammar.html
https://www.python.org/dev/peps/pep-0306/

	上面的python的例子里的疑问：
	pgen生成的语法解析器不就能生成语法树了吗？
	为什么还要定义asdl并用asdl_c.py生成Python_ast.c文件呢？

	pgen类似于yacc吗，pgen其实是语法解析器的生成器而不是语法解析器本身。

	面临的问题：理论知识都是以基本BNF表达式来的
	但实际用的是各种BNF的变体，包含重复、组、值范围等，不适合直接拿来套到教材算法上。