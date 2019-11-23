---
layout: post
title: 字符集编码格式介绍
description: ""
category: 其他
tags: [encoding]
---
{% include JB/setup %}

* toc
{:toc}

<hr />
关于编码格式、编码名称中文网页上有很多错误，本文试图纠正这些错误，对常见的编码术语给出一个正确的介绍，大部分资料来自wiki。

本文基本遵循[现代编码模型的术语][100]，但不严格区分，当说`字符集`一般指的是第一二层，当说`编码方式`一般指的是的是第三四层。

另外还找到一个有趣的资料：https://encoding.spec.whatwg.org/#index-gb18030-ranges-pointer，但没细看。

# 各种编码

## ANSI
ANSI指的是美国国家标准协会，不是编码标准，之所以放在这里是因为这个术语的误用最多。一般资料中根据上下文可以推测他说的ANSI可能是：
* ASCII
* 扩展ASCII
* ANSI CodePage（ANSI CodePage本身也是个误用，下面会讲）

## [ASCII][0]
全称是American Standard Code for Information Interchange，也就是美国标准信息交换码。
ASCII表的前32的字符是不可见的控制字符，这是因为ASCII本身为电报以及电传打印机开发的，控制字符用来控制信息传输的同步以及文本格式的字符，可以理解为这是一种简单的传输协议，这时候还没有微处理器，协议需要简单，所有的协议指令只有一个字符且放在文本流中。当然在现在的协议分层的思想下，将文本内容与控制文本内容的东西放在一起的设计很奇怪，我不清楚现在的电报是否还是用这种古老的方式。

ASCII的编码只用了7个bit。所有的128个码位都用了。

## 扩展ASCII
ASCII是为了英语下的电报信息交换适用的，但是计算机时代人们很快发现这个东西不够用，其他字母体系下的语言(比如欧洲的一些语言)无法表示。于是就出现了各种扩展ASCII编码。所以`扩展ASCII`编码不是指某一种确定的编码，指的是很多编码，这些编码很多甚至不是国际标准，仅仅是厂商标准，更重要的，所有的这些扩展ASCII跟美国国家标准协会与都没有关系。

[wiki][1]上介绍了一些扩展ASCII。中文网页有一种常见的说法说是ASCII扩展是IBM制定的，比如[这个][2]。IBM确实有扩展ASCII编码，但扩展ASCII并不是仅仅IBM制定，扩展ASCII有很多种，其中IBM自己就制定了很多种，其中有一个叫EBCDID，这个玩意儿很挫，[wiki上有关于其的几个笑话][3]。这篇文里放的那张图确实是源于IBM PC，后来被windows系统继承成为[windows codepage437][4]。

大部分扩展ASCII都是厂商标准且是老古董了，除了ISO-8859系列，其中ISO-8859-1也就是Latin-1，接触过MySql的对这个名词一定不陌生。

[ISO-8859系列][5]很奇怪，ISO是国际组织，制定的8859系列却是地方化的标准。每一个8859-n都是ASCII的8位扩展码，因此码位是重叠的，wiki上有一张[表][6]详细列出了不同的标准下同一个码位对应的字符。

## window平台下术语
windows平台--万恶的罪魁祸首，其对编码名称的误用可谓是流毒至今，祸乱天下。windows平台还有糟糕的API、糟糕的桌面系统，一言难尽。总之，一个初学、有追求的程序员一定要尽快远离windows，否则它会告诉你什么叫**艰难**，btw，还要抛弃baidu，不要试图用baidu搜索查找问题的答案，国内的技术论坛，也要细心甄别，因为大部分帖子里充满了错误，如此恶劣的软件技术环境，不知道给初学者造成了多少挫折，一个不会翻墙的程序员大概不是一个好程序员。不再细表，且说编码。

### ANSI CodePage
codepage也叫内码表，起源于IBM内码表，在没有unicode的时代用来做国际化的一种手段。windows继承了这一概念，但给它起名叫ANSI Codepage，甚至简称为ANSI，现在你打开记事本另存为的时候编码格式里还能看到ANSI，其实指的是本地化的windows codepage，比如中文win7下一般ANSI就是CP936。所以其实跟ANSI一毛钱关系都没有，最多就是像ASCII的一种扩展码，只不过这种扩展码不再是限于8bit。错了这么多年，MSDN上终于开始采用[windows codepage][7]这一术语。

从[wiki][8]上看，windows codepage本身是个有点复杂的东西，但我们大可不必关心，毕竟只是个windows平台一家的标准。我们只需要理解它是一种类似ASCII的扩展码就好了。下面重点讲下CP936

### CP936
前面说到代码页是Windows继承IBM，因此CP936也各有[IBM与Windows的版本][9]。我们只关心[windows cp936][10]，wiki词条介绍的比较详细了，CP936期初覆盖GB2312，windows95之后涵盖了大部分GBK。但注意GBK不是GB18030，支持GB18030的codepage为CP54936。
我们只需要理解CP936不等于GBK，更不等于GB18030就可以了。

推荐先阅读后面GB2312、GBK&GB18030小节，不然理解CP936的编码可能会有困难。

Unicode官方有一个CP936到Unicode的[映射表][11]。

观察映射表可知，cp936是采用单字节和双字节编码，单字节编码从0x00到0x80。0x81到0xFE为双字节第一字节的取值范围因而不进行编码。0xFF未定义。双字节编码采用GBK的EUC-CN表示法，合法的双字节编码可以从映射表中查取，需要注意的是双字节编码空间并不连续。因为双字节有6万多编码空间，而CP936作为GBK的子集，GBK才编码了2万多字符。

需要注意GB2312对英文字母、标点符号进行了区位分配。而GBK扩展了GB2312，自然也对英文字母、标点符号进行了区位分配。小写字母a的区位码是0365（十进制表示，16进制0x0341，区位码可以通过国家标准局在线标准文档查取），转为EUC-CN格式的机内码为0xA3E1(高低字节各加0xA0)。查映射表可知，该字母名字为FULLWIDTH LATIN SMALL LETTER A，也就是所谓的全角字符，而CP936单字节的字母a为LATIN SMALL LETTER A，也就是所谓的半角字符。对于标点符号来说，全角字符要比半角字符渲染的宽一些。

同时GB2312与GBK还对日文假名、俄文、希腊字母进行了编码（莫名其妙），作为对GB2312兼容的CP936以及GBK与GB18030自然也包括这些编码。这也是为什么在中文windows平台下用记事本以ANSI编码可以保存日文`にほんご`，但是不能保存印度文`नमस्ते`。


### Unicode

win7下的windows记事本的还有一种编码格式叫unicode，但unicode显然不是一种编码，最多是一种字符集。windows下的unicode编码是ucs-2。注意ucs-2只有两个字节。编码空间要比utf16小，所以utf16代理对的编码，在ucs-2中无法表示。

关于windows控制台编程方面，需要调用ReadConsoleW来代替C标准库里面的scanf、wscanf等一众函数才能正确的处理4字节的utf-16。
ReadConsoleW返回的永远都是UTF-16编码。跟SetConsoleCP与SetConsoleOutputCP的设置没关系，不清楚这些函数之间的联系。
实际上SetConsoleCP与SetConsoleOutputCP的功能远不像MSDN的文档上说的那样简单。关于这方面一个好的参考是Python3.7中的控制台读取函数，
python2.7版本中使用的fgets，不能正确处理中文,Python3.7中改为ReadConsoleW了。


## 中文国标

GB2312以及以下的GBK与GB18030严格来讲既是字符集也是编码方式，但根据上下文很容易区分指的是哪一个。
但是标准文档里描述的编码方式其实对应五层编码模型里的第三层字符编码表，但是标准详细规定了第一、二、三、四个字节的内容，因此
不存在大小端的问题。

utf编码之所以有大小端问题，是因为定义utf16与utf32的时候不是逐字节定义的，而是逐code unit定义且只定义了code unit的值，没有给出逐字节内容，所以code unit作为字节流传输的时候就有大小端的问题，就像任何int\long类型进行网络传输的时候会遇到大小端问题一样。

### GB2312-1980

#### 编码方式

GB2312-1980编码一般称GB2312，全称是`信息交换用汉字编码字符集 基本集`。这个标准制定的非常早，第一版发布于1981年。当时iso与unicode统一编码小组都没成立，实际上1991年unicode才发布第一版。
这个标准可以看做是对标ASCII编码的。主要也是用于电传打印机、电报等用途。

与unicode编码的线性连贯编码空间不同，GB2312的编码空间是2维平面上块状的（当然也可以看做线性，但是就失去了领略设计意图的直观感受）。

GB2312分成了94个区，每个区94个字符，这样每个字符一个区号一个位号就能确定，也就是所谓的区位码。区号与位号取值都是01到94。16进制为0x01到0x5E，总共8836个区位，但只编码了6千多字符。这个区位码就相当于unicode的codepoint，只是一种编码空间的一一映射。

完整的标准文档可以参考国家标准局在线查询，也可以参考[这里][13]。

上面说到GB2312是对标ASCII的信息交换用码，所谓信息交换，可以理解为两台电报机之间的一个字节流，同样需要控制字符，为了国际间交互使用需要使用同样的通信控制协议，也就是控制字符，因此GB2312编码的字节流不能出现ASCII定义的控制字符以及空格字符（前33个也就是0x00到0x20）。为此编码方案中将区号与位号各加上0x20保证GB2312编码的字节中不会出现那33个字符，于是区号与位号的取值范围变为0x21到0x7E,称为**国际码**。

依照[wiki][12]所讲，为了遵循EUC标准保证不与通用的ASCII编码冲突，区号与位号再各加0x80变为**机内码**，也就是EUC-CN表示法, 实际上机内码就是存储、交换用编码格式，机内码之于区位码类似于utf8之于codepoint。

但是ASCII编码本身就包括了控制字符，所以先加0x20再加0x80完全是不必要的，可以直接加0x80就能兼容ASCII且不包含控制字符，也就是区、位号取值空间为0x81到0xDE，不知道为什么当初没有这么编码。

#### 与unicode的映射
GB2312的编码无法与unicode编码通过算法转换，必须查表。unicode官方提供过两个表:gb2312.txt的转换表以及现在ICU通过脚本从UCD提取出的表。
提取方式描述在[这里][15]，但是我没有细看。unicode官方还提供在线的[映射图表][14]

下面的例子来自与[wiki][12]，讲的是某些字符通过上面讲的两个转换表映射到unicode的不同的字符上去了，且这些字符无法通过Unicode规范化后相等。

|区位码|机内码字节序|	GBK子集	|	GB2312.TXT|		字符名称|
|--|--|--|--|--|
|0104|A1A4|	U+00B7 · middle dot|U+30FB ・ katakana middle dot	|	间隔点|
|010A|A1AA|	U+2014 — em dash	|	U+2015 ― horizontal bar	|	破折号|

因此wiki上讲这两种映射必然有一种映射错误，以我看来GB2312.txt的映射方式是错的，因为参考gb2312标准文档来看这两个符号应该是对标ASCII中的符号的，但是GB2312.txt貌似广泛使用包括icov，java1.7,python3.4，icu已经抛弃了gb2312.txt转换表，因此这个问题应该已经改正了，有待验证。非官方渠道[这里][16]还可以下载到gb2312.txt。


### GBK
1993年，Unicode 1.1标准发布，包括在中国大陆，台湾，日本和韩国使用的20,902个字符。此后，中国发布了GB13000.1-93，这是与Unicode 1.1等效的国家标准。Microsoft在Windows 95和Windows NT 3.51中将GB130000实现到了CP936中。虽然这个扩展的CP936不是国家标准，但是Windows 95的广泛使用导致CP936成为事实上的标准。1995年，中国国家信息技术标准化技术委员会制定了《中文内部代码扩展规范》（中文：汉字内码扩展规范（GBK）；拼音：HànzìNèimǎKuòzhǎnGuīfàn（GBK））1.0版，即GBK 1.0，是Codepage 936的略微扩展。
所以，微软的CP 936通常被认为是GBK。 但是，在GBK 1.0中添加的95个PUA字符未包含在代码页936中。代码页936 在0x80处还具有一个单字节欧元符号，而GBK 1.0则没有。

GB2312有区位码的概念，但是GBK与GB18030中非GB2312的那部分字符貌似没有区位码的概念了。

以下表格和图来自[wiki][17]，这个表其实关于GB18030其实不全的，因为GB18030还有4字节编码的字符大约15万。这个表里仅列出了2字节编码的GB18030。其余编码的范围没问题。

<table class="wikitable">
<caption>GBK Encoding Ranges
</caption>
<tbody><tr>
<th rowspan="2">range</th>
<th rowspan="2">byte 1</th>
<th rowspan="2">byte 2</th>
<th rowspan="2">code points</th>
<th colspan="4">characters
</th></tr>
<tr>
<th>GB 18030</th>
<th>GBK 1.0</th>
<th>Codepage 936</th>
<th>GB 2312
</th></tr>
<tr>
<td>Level GBK/1</td>
<td><code>A1</code>–<code>A9</code></td>
<td><code>A1</code>–<code>FE</code>
</td>
<td align="right">846</td>
<td style="text-align:right;">718</td>
<td style="text-align:right;">717</td>
<td style="text-align:right;">715</td>
<td style="text-align:right;">682
</td></tr>
<tr>
<td>Level GBK/2</td>
<td><code>B0</code>–<code>F7</code></td>
<td><code>A1</code>–<code>FE</code></td>
<td style="text-align:right;">6,768</td>
<td colspan="2" style="text-align:right;">6,763</td>
<td style="text-align:right;">6,763</td>
<td style="text-align:right;">6,763
</td></tr>
<tr>
<td>Level GBK/3</td>
<td><code>81</code>–<code>A0</code></td>
<td><code>40</code>–<code>FE</code> except <code>7F</code></td>
<td style="text-align:right;">6,080</td>
<td colspan="2" style="text-align:right;">6,080</td>
<td style="text-align:right;">6,080</td>
<td rowspan="6">
</td></tr>
<tr>
<td>Level GBK/4</td>
<td><code>AA</code>–<code>FE</code></td>
<td><code>40</code>–<code>A0</code> except <code>7F</code></td>
<td style="text-align:right;">8,160</td>
<td colspan="2" style="text-align:right;">8,160</td>
<td style="text-align:right;">8,080
</td></tr>
<tr>
<td>Level GBK/5</td>
<td><code>A8</code>–<code>A9</code></td>
<td><code>40</code>–<code>A0</code> except <code>7F</code></td>
<td style="text-align:right;">192</td>
<td colspan="2" style="text-align:right;">166</td>
<td style="text-align:right;">153
</td></tr>
<tr>
<td>user-defined 1</td>
<td><code>AA</code>–<code>AF</code></td>
<td><code>A1</code>–<code>FE</code></td>
<td style="text-align:right;">564</td>
<td colspan="4" rowspan="3">
</td></tr>
<tr>
<td>user-defined 2</td>
<td><code>F8</code>–<code>FE</code></td>
<td><code>A1</code>–<code>FE</code></td>
<td style="text-align:right;">658
</td></tr>
<tr>
<td>user-defined 3</td>
<td><code>A1</code>–<code>A7</code></td>
<td><code>40</code>–<code>A0</code> except <code>7F</code></td>
<td style="text-align:right;">672
</td></tr>
<tr>
<th>total:</th>
<th></th>
<th></th>
<th style="text-align:right;">23,940</th>
<th style="text-align:right;">21,887</th>
<th style="text-align:right;">21,886</th>
<th style="text-align:right;">21,791</th>
<th style="text-align:right;">7,445
</th></tr></tbody></table>


![img](/assets/resources/GBK_encoding.png)

由上图与表，可以清醒的观察到GBK与其他国标的关系，以及GBK的编码范围。GBK/1与GBK/2合起来就是GB2312，其实也包括右下两条红色区域，不过是用户定义区，gb2312没有分配字符。

unicode官方提供GBK与unicode的[映射查询表格][18]。此外，[这里][19]也提供了一个查询表格。


### GB18030
关于GB18030最好的说明是国际标准局网站上在线文档。以下图表取自该文档，GB18030编码有单字节、双字节、四字节三种。单字节编码兼容ASCII，双字节编码兼容GBK，4字节编码为扩展部分。

![img](/assets/resources/gb18030_encoding_bytes_range.png)

下图中单字节编码0x00到0x7F一个线性编码空间太简单没有截取。

![img](/assets/resources/gb18030_encoding_space.png)

以下图来自[wiki][20]。其中紫色部分的字节被用来进行4字节编码中的第二字节与第4字节，4字节编码空间这个图无法表示，机制
类似于BMP中UTF-16 surrogates pair。

![img](/assets/resources/GB18030_encoding.png)

unicode官网有一些关于GB18030的一些[FAQ][21]，可以参考下吧。

由GB18030编码查unicode codepoint可以通过国家官方GB18030标准文档，其每个字符的下方标出了对应的codepoint。
通过codepoint查GB18030编码暂时没找到途径（主要是4字节部分找不到转换表），貌似可以通过UCD转换。

## unicode字符集下的编码方式

关于utf的unicode官方的一些[FAQ][30]可以参考。

### UTF-16

关于UTF-16的编码[wiki][22]上有详细介绍。UTF-16编码一个codepoint需要2个字节或者4个字节。BMP中的字符都需要两个字节。
SMP中需要4个字节。因为一个code unit是两个字节，所以存储起来有大小端两种格式。以大端为例（符合人阅读习惯，高位在低地址）:

对于BMP中的字符，UTF-16BE编码与codepoint的16进制表示相同。
对于SMP中的字符，共16个平面，也就是一共`2^4 * 65536= 2^20`个需要编码的字符, `2^20=2^10*2^10`也就是说只需要1024个数就能表示，也就是
(1...1024个不同数字)乘以(1...1024个不同数字)就可以给2^20个字符编码。那为什么surrogates划出了0xD800到0xDFFF共2048个数呢，我考虑是没有什么特别的必要性，大概是为了让编解码算法能区分前导代理与后尾代理吧

### UTF-32

UTF-32比较简单，直接有codepoint来作为编码，但是限制了前11位必须为0，表示范围限制在了0x0到0x10FFFF之内。
同样存在大小端的问题，不过[wiki][23]没有提到这一点。

### UTF-8

UTF-8是一种非常nice的编码方式，设计与故事可以参考[这篇文章][24]，
为了防止链接失效，引用在此

<pre>
	FSS/UTF 编码全称是 File System Safe Universal Character Set Transformation Format。为什么要考虑这个文件系统安全呢？因为在 unicode 出现之前，计算机普遍使用 ASCII 编码。UNIX 的文件系统使用 /，也就是 0x2f，作为路径分隔标志。另一方面，c 语言使用 0x00 表示字符串的结尾。而 ISO/IEC 10646 (Unicode) 制定 UCS-2 编码使用双字节编码，最多支持表示 65535 个字符（code point）。UCS-2 编码一定会出现某个字符编码包含 0x2f 或 0x00 情况。例如，「⼀」的 UCS-2 编码是 0x2f00，同时包含了 0x2f 和 0x00。UNIX 系统和 c 语言基本没法处理使用 UCS-2 编码的数据。如果非要使用 UCS-2 编码，那就只有一个办法——将老数据使用 UCS-2 转码。这显然不现实。

	所以 Rob 和 Ken 给新编码制定了几条指导原则：

	兼容历史文件系统，文件名不能包含 0x2f 和 0x00
	兼容现有程序，非 ASCII 字符编码不能部分包含 ASCII 编码
	与 UCS 编码转换要简单
	首字节需要指明后续字节长度
	编码格式不要浪费空间
	自同步
	前两条讲得是一个事情。ASCII 编码范围是 0x00-0x7f，新编码方案中非 ASCII 字符的编码序列不能包含 0x00-0x7f 范围的内容，不然现有的系统和程序会把这部分内容当成 ASCII 处理而导致混乱。

	第六条说的是错误恢复。简单来说，程序从文件的任意部分开始读取，可能只读到一个字符的部分编码字节，从而无法实别这一字符。但没关系，编码方案需要支持程序快速跳过有问题的字节，然后正常解码。

	这六条原则一言一蔽之，多快好省。

	最终的编码方案使用变长字节编码，不同范围的字符使用不同长度的字节编码，最多使用 6 个字节，可表示范围为 [0,0x7fffffff]。

	其中，ASCII 字符 [0x00-0x7f] 的编码方式与现有 ASCII 编码保持一致，已有的 ASCII 编码无需做任何改动。其他字符使用多字节编码。

	为了实现第一条和第二条原则，多字节编码的每个字节的最高位永远是 1，而 ASCII 字符编码的最高位是 0，所以从根本上杜绝了编码冲突。

	为了实现第四条原则，多字节编码以 11{1,5}0 开头。1 和 0 之间 1 的数量表示后续字节的长度（这里借用了正则的表示方式）。

	为了实现第五条原则，编码规定，如果一个字符的编码可以有多种表示方式，则选用最短的表示。

	为了实现第六条原则，编码序列的后续字节都是以 10 开头的。如果程序读到了受损的文件，只能有三种情况：1、当前字节最高位是 0，则是合法 ASCII 字符；2、当前最高两位是 11，则是合法的多字节编码；3、当前字节最高两位是 10，则是其他字符编码的一部分，跳过，直到读到最高位为 0 或最高两位为 11 为止。

	举个例子，汉字「吕」的 Unicde 编码是 U+5415，对应二进制为 0b0101010000010101，需要 15 bit，所以使用三字节编码，对应二进制拆成（从低位到高位）三部分，分别是 0b0101, 0b010000, 0b010101，再拼上编码前缀得到 0b11100101, 0b10010000, 0b10010101，对应十六进制为 0xe5, 0x90, 0x95。所以汉字「吕」的 UTF-8 编码是 0xe59095。
</pre>

UTF-8有很多优秀的优点，在我看来最重要的优点就是
存储空间小与自同步特性。



### [SCSU][25]

unicode提供的一种8bit编码方式，貌似没看到应用场景，大致了解就好了。

## ISO 10646对标UTF的UCS

### UCS-2

参考utf16词条下的说明。需要注意的是UTF-16可以是4个字节编码整个unicode空间。
而UCS-2只有两个字节，所以UCS-2是UTF-16的子集。

windows7下的所谓unicode编码其实是ucs-2。windows提供的widechartomultibyte其实不能正确处理4字节的utf-16编码。

UCS-2同样有大小端。


### UCS-4

UCS-4等同于UTF-32。

# 关于中文字符集

根据GB18030标准计算，汉字字符大约7万。其中4字节扩展部分包括CJK扩展A的6530个字符与CJK扩展B的42711个字符，现在的中文字体文件几乎没有完全支持GB18030的4字节编码扩展部分的。但是4字节编码部分的汉字在unicode中并非都在SMP中。CJK扩展A区是4字节编码却在BMP中，再加上CJK统一统一表意文字最初版本的2万汉字，也就说BMP中大约有27000汉字，一般能见到的所谓支持GB18030的字体文件一般也就支持BMP中的这27000个字符。GoolgeNoto号称世界上所有语言的字体，对中文支持才[约8千个字符][31]。

扩展区B的字体一般是单独的字体包，wiki上有个[列表][2]列出了支持汉字扩展字符集的一些字体。win7下预装了几种支持扩展区b的字体，可以在font文件夹下搜extb看看你的系统装了哪些字体，但windows下的应用能否显示生僻字还要看应用自己选的字体是否正确。

# 编码空间重叠分析

# 编码转换
C语言下原生的编码转换系统是基于Locale的。C语言标准制定的时候还没有万国码的存在，wstomb与mbtows都是基于locale。其核心思想用一个比较宽的类型wchar_t来表示系统中所有的字符集，但是C语言标准并没有规定这个wchar_t的大小，只要足够宽，所谓multibyte也就是多字节编码。这样我在编写程序的时候只要考虑好widechar的情况，输出的时候与multibyte进行转换就好了。比如linux系统，其源码肯定只有一套，其内部的widechar就是32位int类型。这种方式在单一系统内不会有什么问题。但在多系统交换文件就会出现乱码。比如一个locale为中文的环境下产生的文件放入locale为英文的环境下就是乱码。C语言提供的mbtowc与wctomb具体如何有待测试。

gnu的iconv以及ICU。ICU与iconv的不同在于iconv只做转码。而ICU提供规范化、本地化支持等，所以要想实现国际化支持，只用iconv是远远不够的。
 这里有个iconv的小例子：https://ideone.com/QcQAyg


# 编码格式探测
ICU提供了编码格式探测工具http://userguide.icu-project.org/conversion/detection
另外python也有人提供了一个库叫做chardect

编码探测是下下策，上策是统一用unicode，中策是规定好编码格式。

# 乱码
既然是乱码也就是不可识别，首先应该考虑字体的问题，若所使用的字体不能支持该字符，一般字体处理程序会返回一个特殊的字模来代替。
常见的就是一个方框或黑方块或一个带问好的方框。

## 方框或带问好的方框

## 锟斤拷

## 烫烫烫


[100]:https://zh.wikipedia.org/wiki/%E5%AD%97%E7%AC%A6%E7%BC%96%E7%A0%81#%E7%8E%B0%E4%BB%A3%E7%BC%96%E7%A0%81%E6%A8%A1%E5%9E%8B
[0]:https://en.wikipedia.org/wiki/ASCII
[1]:https://en.wikipedia.org/wiki/Extended_ASCII#Proprietary_extensions
[2]:https://blog.csdn.net/na_tion/article/details/50148883
[3]:https://en.wikipedia.org/wiki/EBCDIC#Criticism_and_humor
[4]:https://en.wikipedia.org/wiki/Code_page_437
[5]:https://en.wikipedia.org/wiki/ISO/IEC_8859
[6]:https://en.wikipedia.org/wiki/ISO/IEC_8859#Table
[7]:https://docs.microsoft.com/en-us/windows/win32/intl/code-pages
[8]:https://en.wikipedia.org/wiki/Windows_code_page
[9]:https://en.wikipedia.org/wiki/Code_page_936
[10]:https://en.wikipedia.org/wiki/Code_page_936_(Microsoft_Windows)
[11]:https://www.unicode.org/Public/MAPPINGS/VENDORS/MICSFT/WINDOWS/CP936.TXT
[12]:https://zh.wikipedia.org/wiki/GB_2312
[13]:https://web.archive.org/web/20170723035528/https://www.china-language.gov.cn/wenziguifan/scanning/gfhbz/gfbz27.htm
[14]:http://demo.icu-project.org/icu-bin/convexp?conv=gb2312
[15]:http://site.icu-project.org/charts/charset
[16]:https://haible.de/bruno/charsets/conversion-tables/GB2312.html
[17]:https://en.wikipedia.org/wiki/GBK_(character_encoding)
[18]:http://demo.icu-project.org/icu-bin/convexp?conv=gbk
[19]:https://web.archive.org/web/20160303230643/http://cs.nyu.edu/~yusuke/tools/unicode_to_gb2312_or_gbk_table.html
[20]:https://en.wikipedia.org/wiki/GB_18030
[21]:http://unicode.org/L2/L2001/01314-FAQ-GB18030.htm
[22]:https://zh.wikipedia.org/wiki/UTF-16
[23]:https://zh.wikipedia.org/wiki/UTF-32
[24]:https://zhuanlan.zhihu.com/p/70264909
[25]:https://www.unicode.org/reports/tr6/tr6-4.html

[30]:http://www.unicode.org/faq/utf_bom.html
[31]:https://www.google.com/get/noto/help/cjk/
[32]:https://zh.wikipedia.org/wiki/Wikipedia:Unicode%E6%89%A9%E5%B1%95%E6%B1%89%E5%AD%97
