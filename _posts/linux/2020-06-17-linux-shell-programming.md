---
layout: post
title: Linux Shell编程简明手册

tagline: "Supporting tagline"
category : linux
tags : [linux, shell]

---
{% include JB/setup %}

* toc
{:toc}

<hr/>

本文主要是linux下shell脚本编程简明手册，只涉及基本用法。
参考了很多资料，主要以[这篇][10]为大纲。

## 变量
### 变量分类

Shell中的变量分为用户自定义变量，环境变量，位置参数变量和预定义变量。可以通过set命令查看系统中存在的所有变量。

* 环境变量：保存和系统操作环境相关的数据。HOME、PWD、SHELL、USER等等

* 位置参数变量：主要用来向脚本中传递参数或数据，变量名不能自定义，变量作用固定。比如$@ $*

* 预定义变量：是Bash中已经定义好的变量，变量名不能自定义，变量作用也是固定的。比如$?

### 变量类型
shell是一门弱类型语言，变量内部都是以字符串来存储的，在某些上下文中，字符串会自动转换为数字，如果不能转换则出错。
这样的上下文有:
```
$[1 + 2*3]
$((1+2* 3))
```

鉴于shell的弱类型特征，我们只简单的将shell的变量类型分为单变量与数组两种。

shell中有个内建的type命令，这个命令可以用来查看shell中的符号是内建命令还是关键字。比如
```
type [ [[ test

[ is a shell builtin
[[ is a shell keyword
test is a shell builtin
```
这个type并非是用于我们这里讨论的类型。关于这个type的更多用法，参考[这里][11]。

### 创建用户自定义变量
#### 单变量
命名：变量名称可以由字母，数字和下划线组成，但是不能以数字开头，环境变量名建议大写，便于区分。

赋值：用等号，**等号左右两侧不能有空格** ， 变量的值如果有空格，需要使用单引号或者双引号包括。使用单反引号或者`$()`来把命令的输出结果赋值给变量。

通常情况下，赋值时右边的值不需要用引号来包括，但当内容还有空格时，为了保证赋值完整，必须使用双引号。有时候不希望其中
的$开头的变量做替换，需要用单引号包裹。简而言之，一劳永逸用双引号，特殊输出用单引号，直观无错不用引号。

```
a=hello world //wrong
a="hello world"
b='${a}='${a} // ${a}=hello world
```

类型：变量默认为字符串类型，但是在表达式计算中会自动转化为数字。比如
```
Bash add.sh:
echo $(($1 + $2))
Execute:
./add 111 111
Output:
222
```
#### 数组
数组中可以存放多个值。Bash Shell 只支持一维数组（不支持多维数组），初始化时不需要定义数组大小（与 PHP 类似）。

与大部分编程语言类似，数组元素的下标由0开始。

Shell 数组用括号来表示，元素用"空格"符号分割开，语法格式如下：
```
array_name=(value1 ... valuen)
```

```
array1=(1 2 3 "A")
```

也可以通过下标定义每个元素来定义数组

```
array1[0]=1
array1[1]=2
array1[2]=3
array1[3]="A"
```

### 创建环境变量
创建方法：export 变量名=变量值
作用范围：当前shell以及所有的子shell。

生效范围是在进程上下文中，因而进程关闭后变量不会留存下来。

### 使用位置参数变量
位置参数变量指的是命令行参数。比如，当执行命令

```
./some_command para1 para2 para3
```
shell会自动把`some_command para1 para2 para3`的相关信息赋值给以下变量

```
$*		命令行中所有的参数，当成一个整体来处理
$@		命令行中所有的参数，以空格分隔区分处理
$n 		以空格分隔命令行参数后，$0引用命令本身some_command $1引用para1 以此类推
$#		所有参数的个数
```

`$@`与`$*`的区别参考[这里][2]。简单来说就是当不用双引号包裹他们的时候，没有任何区别，当用了双引号，差别就显现出来了。
虽然echo看上去仍然一样，在for循环的处理完全不同。


### 使用预定义变量
```
$?  执行上一个命令的返回值   执行成功，返回0，执行失败，返回非0（具体数字由命令决定）

$$  当前进程的进程号（PID），即当前脚本执行时生成的进程号

$!  后台运行的最后一个进程的进程号（PID），最近一个被放入后台执行的进程   &
```

### 变量引用
#### 单变量
使用$跟变量名引用变量。引用的变量在脚本运行时会自动替换成变量的值，但是如果变量引用处于单引号中，则变量替换则不会发生。
```
A=1
echo 'A = $A'
Output:
A = $A
```
引用多个字母命名的变量需要使用花括号
```
${varname}
```
#### 数组

数组元素以及数组引用的例子：
```
array1=(1 2 3 "A")
echo ${array1[0]}   // 1
echo ${array1[@]}	// 1 2 3 "A"
echo ${array1[*]}	// 1 2 3 "A"
echo ${#array1[*]}  // 4
echo $(#array1[@])  // 4
```
数组整体的引用语法`${array[*]}`与`${array[@]}`的区别与位置参数类型，在不使用双引号for循环的时候，没什么区别。
参考[这里][2]。

### 字符串操作
#### 字符串拼接
变量可以用类似宏替换的方式来叠加：
```
aa=123
cc="$aa"456 //123456
dd=${aa}789 //123789 
```
之所以要用引号或者`${}`包裹，是因为若不然则变成了对变量`aa456`的引用。

#### 字符串截取

参考[这里][1]就可以了，非常详尽。

### 删除变量
方法：unset 变量名。
作用：在当前shell进程内删除变量，可以是任意变量包括环境变量，但仅限该进程内，并不会真的删除环境变量。

## 输入输出
内置的输入为`read`：

```
read [选项] 值
　　read -p(提示语句) -n(字符个数) -t(等待时间，单位为秒) –s(隐藏输入)  
　　　　eg:
　　　　　　read –t 30 –p “please input your name: ” NAME
　　　　　　echo $NAME

　　　　　　read –s –p “please input your age : ” AGE
　　　　　　echo $AGE

　　　　　　read –n 1 –p “please input your sex  [M/F]: ” GENDER
　　　　　　echo $GENDER
```

内置的输出为`echo`，非常简单。
还有常用的外部命令`printf`，语法与C语言基本一样，不再细说。

使用select来与用户交互：
<pre class="brush:bash;">
#!/bin/bash
echo "What is your favourite color? "
select color in "red" "blue" "green" "white" "black"
do 
    break
done
echo "You have selected $color"
</pre>
从命令行参数中选择：
<pre class="brush:bash">
#!/bin/bash
echo "What is your favourite color? "
select color
do 
    break
done
echo "You have selected $color"
</pre>
### 屏幕控制
颜色、光标位置、闪烁等，暂略。

## 算术表达式
shell中算术运算不支持小数，若要进行小数四则运算需要借助外部工具bc或awk。做为一个简明教程，本文不涉及。

### 运算
1. 使用expr
expr是shell外部命令，功能很多，但这里我们只说如何用来做算术运算。
expr既然是命令，后面的参数就必须用空格区分开来，这不像前面几个格式那样自由。
```
expr 2+3
expr "2" + 3
expr "abc" + 3
expr 4.5 + 3
```
2. 使用`$[]`
```
echo $[2+3]
echo $[2 + 3]
echo $[abc + 3]
echo $[4.5 + 3]
```
3. 使用`(())`
```
echo $((2+3))
echo $((2 + 3))
echo $((abc + 3))
echo $((4.5+3))
```

<br />
问题：为什么第一种用法不需要加echo，而后两种用法需要加echo。

因为expr是外部命令, 后两种写法是一种变量替换，替换的结果写在shell脚本中，自然被shell当成命令执行。

<br />

### 运算并赋值

#### 使用expr赋值

就是把expr的执行结果赋值给变量，比如
```
b=`expr 1 + 2`
c=`expr $b + 1`
```
这种写法约束比较多：
* 等号两边要有括号
* 必须要有反引号表示命令执行
* expr的参数之间必须yo空格
* expr表达式中的变量引用要有$符号
* 最不足的地方是，expr后面只能是整数，`expr 4.5 + 1`就会出错。

用expr运算有诸多不足，因此基本没有实用的必要，这其实是一种“拼凑”的用法，shell中算术运算并赋值有专用的语法，就是`$[]` 与`(())`与`let`。

#### 使用`$[]`

```
b=$[1 + 2]
c=$[b + 1]

//下面这种写法也可以赋值，但是会把结果当成命令执行。 
$[b=1+2]
$[c=b+1]

```

#### 使用`(())`

```
b=$((1+2))
c=$((b+1))
//或者更简洁一些
((b=1+2))
((c=b +1))

```

写法格式较为自由，运算符前后的空格是任意的，引用变量无歧义的情况下不需要使用`${}`。

<hr />

`(())`与`$(())`的区别：`(())`可以看做一个特殊写法的命令，而`$(())`只是变量替换。
前者在shell中直接执行，后者在shell中做替换后再执行。
<hr />

#### 使用`let`

```
let "b= 1 + 2"
let "c=b+1"
```
写法格式较为自由，运算符前后的空格是任意的，引用变量无歧义的情况下不需要使用`${}`。let表达式也可以省去引号，但是要求后面不能再有空格，也就是

```
let b=1+2 //let b =1+2就会报错
```

`let`也是上面4种写法中唯一只能用来运算并赋值的写法，其他三种写法都可以只做运算即时输出，参考上一小节。

<hr />

`let`与`$[]`与`$(())`两种写法在引用变量无歧义的情况下不需要加$符号，有歧义的情况下就要用`${}`限界了。比如做一个变量叠加再运算
```
aa=1
bb=2
((cc=${aa}${bb}+1)) //cc=13
let cc=${aa}${bb}+1 //cc=13
```

## 测试表达式
### 单中括号 test 双中括号
测试表达式`[ ]`等价于`test`，但是与`[[]]`略有不同。

单括号是内建命令，双中括号是关键字。这点可以用`type [ [[`来验证。既然单中括号是命令，用于管道重定向的`< >`符号以及用于命令连接的`&& ||`符号就不能正确的处理。因此单中括号下的大于、小于以及逻辑与或都要用其他字符来代替。也因为是命令，后面的参数自然要用空格分隔。
```
[ 2 -gt 1 ]   // great than
[ 2 -lt 1 ]   // less than
[ $x == 1 -a $y == 1 ] // -a 表示逻辑与
[ $x == 1 -o $y == 1 ] // -o 表示逻辑或
```

而在双中括号中，以上的4条语句可以写成

```
[[ 2 > 1 ]]
[[ 2 < 1 ]]
[[ $x == 1 && $y == 1]]
[[ $x == 1 || $y == 1]]
```
注意，双中括号内也要用空格分隔各部分。


双中括号支持字符串的模式匹配，当使用`=~`时甚至支持正则表达式。

双中括号中的表达式是当成一个整体来处理的。
```
$[ !(pip list | grep pip) ] && echo True || echo False
-bash: [: too many arguments
False

$[[ !(pip list | grep pip) ]] && echo True || echo False
True
```
上例中`(pip list | grep pip)`执行后返回一个状态码(单独执行可以通过`$?`来查看)。


关于此小节更详细的解释，参考[这里][3]。

### 字符串测试
```
　　test  str1 == str2    　  测试字符串是否相等 
　　test  str1 != str2    　　测试字符串是否不相等
　　test  str1            　　   测试字符串是否不为空,不为空，true，false
　　test  -n str1     　　　  测试字符串是否不为空
　　test  -z  str1    　　　  测试字符串是否为空
```

### 文件测试
```
　　test  -d  file      指定文件是否目录
　　test  –e  file     文件是否存在 exists
　　test  -f  file     指定文件是否常规文件
　　test –L File     文件存在并且是一个符号链接 
　　test  -r  file    指定文件是否可读
　　test  -w  file    指定文件是否可写
　　test  -x  file    指定文件是否可执行
```
### 整数测试
```
　　test   int1 -eq  int2    测试整数是否不相等		单双中括号中可以用 ==
　　test   int1 -ge  int2    测试int1是否>=int2		双中括号中可以用 >=
　　test   int1 -gt  int2    测试int1是否>int2		双中括号中可以用 >
　　test   int1 -le  int2    测试int1是否<=int2		双中括号中可以用 <=
　　test   int1 -lt  int2    测试int1是否<int2		双中括号中可以用 <
　　test   int1 -ne  int2    测试整数是否不相等		单双中括号中可以用 !=
```
注意，shell内建只支持整数测试，浮点数需要依靠外部工具，不再细说。部分测试双中括号支持符号形式。

### 逻辑符号
```
与: 单中括号中-a 双中括号中&&
或：单中括号中-o 双中括号中||
非：单双中括号中都是!
```
双中括号内可以加小括号让逻辑表达更清晰，比如表达取反：
```
[ ! 1 == 2 ] // 不能写成 [ ! ( 1 == 2 ) ]

//但双中括号可以写成
[[ !(1 == 2) ]]
```

## 注释

shell中#开头的行为单行注释，通常单行注释足够使用，多行注释语法较多，自行查找。

## 流程控制
### if...else
<pre class="brush:bash">
# example 1

	# ] ; then之间有无空格无所谓
	if [ test_expression ] ; then
		#your code
	fi

# example 2

	if [ test_expression ]
		then
		#your code
	fi

# example 3

	if [ test_expression ] ; then
		#your code
	elif [ test_expression ] ; then
		#your code
	else
		#不再需要then 
		#your code
	fi
</pre>
### case
<pre class="brush:bash">
CMD=$1

case $CMD in
　　start)
		echo "starting"
       　　;;
　　Stop)
		echo "stoping"
       　　;;
　　*)
    	echo "Usage: {start|stop} “
esac
</pre>

与c语言类似，双分号代表break, `*)`代表default。

### for
#### c语言风格
<pre class="brush:bash">
# 双小括号
for((i=0; i<5; i++)) ; do
	//your code
done
</pre>

#### for..in

<pre class="brush:bash">
# 常量数组 注意这个数组没有小括号
for i in  1 2 3 ; do
	# your code
done

# 引用数组
array1=(1 2 3)
for i in ${array1[@]} ; do
	#your code
done

# 整数序列 注意1..10中间只有两个点。
for i in {1..10} ; do
	#your code
done

# 带步长的整数序列
sum=0
for i in {1..100..2}
do
    let "sum+=i"
done
echo "sum=$sum"

# 命令行参数
for p in "$@" ; do
	#your code
done

#命令行参数简洁版
# argument的名字可以是任意的
# 可以看做for..in省去了in
for argument
do
    echo "$argument"
done

# 文件
for FILE in $HOME/* ; do
	echo $FILE
done

# 文件
for file in $( ls )
do
   echo "file: $file"
done

</pre>

### while
<pre class="brush:bash">
# sample 1
N=5
while [ $N -gt 0 ]
do
     echo $N
     ((N=N-1))
done

# example 2
N=5
while [ $N -gt 0 ]; do
     echo $N
     ((N=N-1))
done

# example 3
N=5
while ((N>0)) ; do
	echo $N
	((N=N-1))
done

# example 4
echo '请输入。。。'
echo 'ctrl + d 即可停止该程序'
while read FILM
do
    echo "Yeah! great film the $FILM"
done

# example 5 read与管道重定向结合
while read line; do
	#filter out the user who use bash
	Bashuser=`echo $line | awk -F: '{print $1,$NF}' | grep 'bash' | awk '{print $1}'`
	#jugement Bashuser is null or not and print the user who use bash shell
	if [ ! -z $Bashuser ];then
		echo "$Bashuser use bash shell."
	fi
done < "/etc/passwd"

#example 6 利用管道与命令组合
cat /etc/passwd | {
while read line; do
	#use if statement jugement bash shell user  and print it
	if [ "`echo $line | awk -F: '{print $NF}'`" == "/bin/bash" ];then
		Bashuser=`echo $line |     awk -F: '{print $1}'`
		echo "$Bashuser use bash shell."
	fi
done
}

</pre>

### do...until
与while类似，仅举一例。
<pre class="brush:bash">
#!/bin/bash
 
i=0
until [[ "$i" -gt 5 ]]    #大于5
do
    let "square=i*i"
    echo "$i * $i = $square"
    let "i++"
done
</pre>

### 跳出循环
<pre class="brush:bash">
break  #跳出所有循环
break n  #跳出第n层f循环
continue  #跳出当前循环
</pre>

### 三目表达式
可以使用命令连接符号`$$ ||`来模拟三目运算符，基本语法是
```
test_expression && branch1 || branch2
```
因为branch2会在前面的`test_expression && branch1`执行失败(返回码不为0)的时候
执行,由与逻辑的短路机制，当`test_expression`失败的时候，`test_expression && branch1`执行失败，
因此执行`branch2`。而`test_expression`为真的时候，继续执行`branch1`。或逻辑连接的命令前面的执行成功
后面的就不再执行。因此整个逻辑模拟了三目运算符。

<pre class="brush:bash">
$[[ !(pip list | grep pip) ]] && echo True || echo False
</pre>

## 函数
在shell中，函数必须先定义，再调用。函数在当前shell中执行，可以使用脚本中的变量。
函数返回值只能是整数。

### 声明函数
基本语法：
```
[ function ] funname [()] {
	action;
	[return int;]
}
```
当一个文件中声明的函数有同名的时候，后面的覆盖前面的。

一些函数声明的例子：
<pre class="brush:bash">
# example 1
function foo () {

}

# example 2
# 无()时函数名与{之间必须有空格
function foo {
	
}

# example 3
foo() {
	
}
</pre>
### 使用函数
调用函数并向函数传参数如同调用普通命令传参数，
函数体内取得参数列表如同shell脚本取得参数列表。

函数体内位置参数变量会“遮盖”掉脚本的位置参数。若如要在函数内引用脚本位置参数变量，先将这些变量
赋值给其他变量。

函数的返回值有return语句指定或者由函数体内最后一句的运行结果作为返回值。取得函数的返回值只能使用`$?`
<pre class="brush:bash">
# 返回值
foo() {
	((1==2))
}
foo
echo $? # 结果为1
</pre>

## 模块化

```
可以使用source和.关键字来引入外部脚本，如：
 
source ./function.sh
 
. ./function.sh
```
## 其他
### 脚本调试（未验证）
```
　　sh -x script　　
　　这将执行该脚本并显示所有变量的值。

　　在shell脚本里添加  
　　set -x  对部分脚本调试
　　sh -n script
　　不执行脚本只是检查语法的模式，将返回所有语法错误。

　　sh –v script
　　执行并显示脚本内容。
```

### 特殊转义上下文
#### 替换上下文
```
` ` $()
$[] $(()) 

${} //定界引用

```
#### 算术上下文
```
(()) //算术运算
```

### shell括号总结
https://www.jianshu.com/p/2bc5206e29b2
里面有三点值得注意：
* 子shell命令组合(command1; command2; [command3..])
* 双中括号测试
* 命令组合

### 管道与shell命令组合连接
https://blog.csdn.net/goodstuddayupyyeah/article/details/72792819

### 参数处理

内建getopts使用
https://www.cnblogs.com/klb561/p/8933992.html


[0]:https://www.cnblogs.com/zhangchao162/p/9614145.html
[1]:http://c.biancheng.net/view/1120.html
[2]:http://c.biancheng.net/view/807.html
[3]:https://www.cnblogs.com/zeweiwu/p/5485711.html

[10]:https://www.cnblogs.com/zhangchao162/p/9614145.html
[11]:https://www.cnblogs.com/jxhd1/p/6699177.html