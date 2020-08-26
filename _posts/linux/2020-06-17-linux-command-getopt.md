---
layout: post
title: Linux命令getopt

tagline: "Supporting tagline"
category : linux
tags : [linux, getopt]

---
{% include JB/setup %}

* toc
{:toc}

<hr/>

## 术语
通常当我们执行命令时可以传入参数，比如一个foo程序
接受4个参数`-c file, -d , --with-libs, config_file`可以如下执行：
<pre class="brush: bash">
./foo -c file -d --with-libs config_file
</pre>
注意在我们的例子里，`config_file`不是`--with-libs`的值。

按照[linux man getopt(1)][0]的说法：
The parameters are parsed from left to right. Each parameter is classified as a short option, a long option, an argument to an option, or a non-option parameter.

命令行参数被称为`parameters`（注意不是形参的意思，跟形参实参没有关系）。每个parameter可以被分为短选项、长选项、选项参数或者非选项参数。
比如`-c file -d --with-libs config_file`分别对应
```
-c 短选项
file 选项参数
-d 短选项
--with-libs 长选项
config_file 非选项参数
```

选项后面可以跟一个值，称之为**选项参数**（an argument to an option），比如`file`。


## parameters类型
parameters虽然可以被分类成4种成分，但是可以区分为两类：option parameters与non-option parameters

### option parameters
option顾名思义，指的是parameter是可选的，调用程序时可以传入也可以不传入。

option parameters可以跟一个argument，并且可以规定这个argument是否是必须要给出的。
#### short option
以`-`开头，名字只有一个字符的选项，比如`-a`。通常格式如下：
```
//argument是必须的
-a   //wrong 必须带参数
-avalue
-a value

//argument是可选的
-a
-avalue
-a value //wrong value会被当成一个non-option parameter
```
#### long option
以`--`开头，名字是多个非空格字符的选项，比如`--with-libs`。通常格式如下：
```
//argument是必须的
--with-libs value
--with-libs=value

//argument是可选的
--with-libs
--with-libs=value
--with-libs value //wrong value会被当成一个non-option parameter
```
#### 区别
长选项与段选项的区别就是长选项有更多更清晰的命名方式。
长选项可以使用`=`连接值。

但段选项的有个优点是可以合并，比如`-a -b`合并为`-ab`。

### non-option parameters
相当于一种匿名参数。所有不能当成option parameters识别的部分都被当成non-option parameters。

## getopt能做什么
getopt根据跟定的选项格式，第一解析传入的命令行参数以规范的格式输出方便处理，第二检查参数是否有误，
比如必须的参数值没有提供等。

## 用法
依据[linux man getopt(1)][0]，getopt有三种语法：
```
getopt optstring parameters
getopt [options] [--] optstring parameters
getopt [options] -o|--options optstring [options] [--] parameters
```

第二种用法中`--`用来分隔getopt自己的option与getopt要处理的内容。第三种用法中的的`-o, --`起到类似的作用。

第三种用法中若是用了`-o`则parameters之前必须用`--`，否则getopt行为异常。

后两种用法是会给argument of option加引号的，适用于处理中间有空格的情况。
比如带参数值的选项a，我们想给它传参数"hello world"，如果使用第一种用法，getopt的输出是
```
getopt a: -a "hello world"

-a hello world --
```

第二三种用法的输出是：
```
getopt -- a: -a "hello world"

-a 'hello world' --
```

### optstring格式

选项后面跟一个冒号表示argument of option是必须的，两个冒号表示argument of option是可选的。比如:
<pre class="brush: bash">
getopt a:b:: -a b //wrong -a需要一个值
</pre>

多个长选项中间用逗号分隔(注意只能用逗号分隔，多加一个空格就会出错)，比如：
<pre class="brush: bash">
getopt -l apple:, banana:: -- --apple=1
</pre>
不幸的是，当我们只想要长选项的时候，比如上面的语句，那种写法是不能work的，原因是getopt有bug，参见[linux man getopt(1)][0]的Bugs小节。其说：
The syntax if you do not want any short option variables at all is not very intuitive (you have to set them explicitly to the empty string).

也就是能work的写法应该是
<pre class="brush: bash">
getopt -o "" -l apple:,banana:: --apple=1
</pre>

## 输出格式
下面讨论是第二三种用法的输出格式，前面提到过，这两种用法会给argument of option加上引号。
输出格式如下，先是选项参数，然后是`--`分隔的非选项参数。一般可以看做如下样式：

```
option1 argument1 option2 argument2 ... -- non-option-parameter1 non-option-parameter2...
```

对于选项的值如果是可选的，并且确实没有提供，其值就是空字符串`''`。

对于选项不需要值的情况下，输出格式中argument部分就被略去了。比如
```
getopt a -a
-a --
```

### 歧义
#### argument of option and non-option parameter

当option的argument是可选的时候，若是提供该argument，必须写成紧紧相连的形式，中间不能有空格。

比如我们想给a提供一个参数值c，写成下面这样是不行的
<pre class="brush:bash;">
getopt a::b -a c b
</pre>
解析结果是:
```
a '' b '' -- c
```
c被当成了非选项参数，必须是:
<pre class="brush:bash;">
getopt a::b -ac b
getopt a::b -a'c' b
</pre>

## 与shell脚本配合
getopt的应用场景当然是用shell脚本中进行参数解析了，虽然shell有内置的getopts，但是getopts只能处理短选项，因此getopt还是有用武之地的。

在bash中的使用要配合`set -- value`命令来使用，该命令的作用是将命令行参数替换为value，而value就可以是我们用getopt解析后的格式。
举个例子test.sh:

<pre class="brush:bash">
#!/bin/bash

echo $@
set -- `getopt -q -o a:b::c: -- "$@"`
echo $@
</pre>
使用下面的命令执行这个脚本，查看一下输出的区别
```
./test.sh -a1 -b -c2

-a1 -b -c2
-a '1' -b '' -c '2' --
```
可以看到$@已经被替换成了getopt解析之后的格式。剩下的就是配合while与shift来遍历这个解析后的结果就可以了。
shift每次左移一次命令行参数，使得原来的$2称为$1。如果一个选项带参数，则在该选项处理过程中额外shift一次就好了。下面的逻辑就很容易看懂了。

<pre class="brush:bash">
#!/bin/bash

set -- `getopt -q -o a:b::c -- "$@"`
while [ -n "$1" ]
do
    case "$1" in
    -a)
        echo "Found the -a option" ;;
    -b)
        param="$2"
        echo "Found the -b option, with parameter value $param"
        shift ;;
    -c)
        echo "Found the -c option" ;;
    --)
        shift
        break ;;
     *)
        echo "$1 is not an option" ;;
    esac
    shift
done
</pre>

### 遗留问题

1. 选项b的参数是可选的，那么在分支-b中，怎么判断$2是不是b的参数呢？

2. 空格问题

但是事情并没完，当argument of option或者non-option parameter中出现空格的时候，$1引用并不能正确的识别它们。
看如下的例子:

```
./bash -a"X Y" -b -c "file1 file2"

Output:



```
方法似乎是使用`eval set --`，原理是什么呢

## 与python模块argparse的区别
python的argparse模块要更加强大，可以指定参数的nargs,action,default,type以及help信息，并且自动生成usage信息。具体参考python argparse模块官方文档。

option parameters在python中被称为optional arguments，
non-option parameters被称为positional arguments。 getopt的optstring中并没有规定non-option parameters形式，你多传或少传
non-option parameters都不会报错，但是argparse模块认为positional arguments都是必须的，并且不能调换次序，必须按照ArgumentParser里规定的次序逐个传入，当然中间可以混入optional arguments。

[0]:https://linux.die.net/man/1/getopt