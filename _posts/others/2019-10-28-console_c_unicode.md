---
layout: post
title: windows下控制台程序输入编码问题
description: ""
category: 其他
tags: [console, windows, unicode]
---
{% include JB/setup %}

这是一篇关于控制台下用c语言读取unicode字符的杂记。

起因是这样的，最初我想用C语言实现后缀自动机算法处理长篇小说《百年孤独》，遇到了编码的问题，先探究了一番编码之后，
对于windows下控制台程序中文的输出输出感到好奇，因为了解编码的时候很多资料都说windows内部编码其实是UCS-2，也就是说不能
处理汉字中超过0xFFFF的生僻字。但是显然windows7系统能正确的渲染这些生僻字，从而又对字体渲染的过程产生了兴趣，了解了字体渲染的大致过程
之后(有一篇文章将字体渲染的大致过程)。开始探究windows下c语言的控制台程序到底能否支持生僻汉字。

## 控制台程序的结构
一个常见的误用是把控制台当成是cmd.exe，其实真正的控制台是conhost.exe。cmd.exe只是命令行程序(command的缩写)，是运行在控制台下的一个程序而已，因为现在的操作系统都是GUI界面，其实不再有控制台，于是就用conhost.exe模拟了一个控制台，然后原来的控制台程序本来也是不需要界面的，在GUI界面下不得不需要一个界面也就是conhost.exe。从任务管理器中很容易看到，每当你启动一个控制台程序的时候，总是至少多出来两个进程conhost.exe与你的目标程序，比如cmd.exe。这部分可以参考cmder的[文档][0]。

于是呢，挡在控制台下输入的时候，控制台程序负责监听键盘事件与鼠标事件等，调用中文输入法，输入法将按键信息转换为中文的编码放入控制台的输入缓冲区里。似乎很简单，然而这个缓冲区似乎并不是stdin，直接从stdin里读取字节是由问题的，后面有程序可以验证。

控制台下中文的输入还有一种方式就是粘贴，那么就涉及到剪切板。表面上看剪切板似乎不应该对放入的东西进行编解码的操作，然后实际上会的。

查阅windows下编程的相关API可知，放入剪切板的时候需要自己指定格式`CF_TEXT,CT_UNICODETEXT`等。然而不论放入哪种格式，剪切板中都会出现其可以转换的其他格式。

第三个输入方式是文件，这里需要注意的是文件的存储编码，与编辑器打开后文件的内存中编码与编辑器拷贝操作拷贝出来的编码其实是不相关。
一个UTF-8编码的方式，打开的时候编辑器内存中完全可以是等宽的UTF-32编码方便处理。而当拷贝操作发生时，往剪切板放入的内容平台编辑器本身控制的，完全可以自己决定放入的东西的内容。关于剪切板会转换编码格式可以参加这篇[文章以及其提供的一个工具clipspy][1]


## C语言处理中文输入的一些总结

我们使用如下程序（codeblocks或VS中都可以打开）探究这个问题。

```
#include <stdio.h>
#include <stdlib.h>
#include <windows.h>
#include <fcntl.h>
#include <time.h>
#include <tchar.h>

#define buffer_size 10

void hexw(wchar_t * buf){
    unsigned char * p =(unsigned char * )buf;
    int i;
    for(i = 0; i<buffer_size*sizeof(wchar_t);i++){
        printf("%d-%X ",i,p[i]);
    }
    printf("\n");
}

void hex(unsigned char * buf){
    int i;
    for(i = 0; i<buffer_size;i++){
        printf("%d-%X ",i,buf[i]);
    }
    printf("\n");
}

void read_stdin_a(char * buf){
    int i;
    for(i=0; i<buffer_size;i++){
        read(0,buf+i,1);
    }
}
void read_stdin_w(){
}

int main()
{
    long cp=936;
    char mbuf[buffer_size];
    wchar_t wbuf[buffer_size];
    HANDLE h;
    long n;

    SetConsoleOutputCP(cp);
    SetConsoleCP(cp);
    h = GetStdHandle(STD_INPUT_HANDLE);
    //FILE * f = fopen(0, _O_RDONLY | _O_BINARY);
    //_setmode(0,_O_RDONLY | _O_BINARY);
    memset(mbuf,0,buffer_size);
    memset(wbuf,0,buffer_size*2);
    
    //while(1){
    //    fread(mbuf,1,1,f);
    //    Sleep(1);
    //}
    //read(0,mbuf,1);
    //read(0,mbuf+1,1);
    //wscanf(L"%ls",wbuf);
    //ReadConsoleW(h,wbuf,2,&n,NULL);
    //scanf("%s",mbuf);

    read_stdin_a(mbuf);

    //printf("\n%d\n",wcslen(wbuf));
    hex(mbuf);
    //hexw(wbuf);
    return 0;
}
```

探究结果如下：


测试数据：

𪚥 unicode:2a6a5  utf-8: f0aa9aa5  utf16be:d869dea5  gb18030:9835ee37

页 unicode:9875  utf-8:e9a1b5  utf16be: 9875  gb18030:d2b3


控制台是UTF8的情况下，scanf读到的都是0。拷贝后分别显示双问号 和正常显示。

控制台是936的情况下，scanf读到的分别是3f3f和d2b3。 拷贝后显示也是双问号和正常显示。

控制台是936 ，wscanf前者读成3f003f00.后者读成d200b300
控制台是utf8  wscanf都读成000

ReadConsoleW 前者读成69d8a5de。后者读成7598

想要在windows下正确的读取到四字节的中文，只能用ReadConsoleW。

至于前两者为什么读不到正确编码，问题出在哪一步，还不清楚。

为了探究这个问题，尝试把stdin当成普通文件，直接读取字节流，在控制台utf8下都到都是0. 在936下读到的一个是3f3f，另一个是d2似乎是d2b3的一半。所以控制台似乎并不是一个简单的缓存。

总结来说，在C控制台程序下，标准库函数最多能处理GBK编码，不能正确处理GB18030中的字符，哪怕这个字符是用UTF-8编码。
唯一能正确处理的是Window API ReadConsoleW函数，且与控制台的编码方式无关，所以python3中cpython实现中不再使用fgets从控制台都取数据
而是改用了ReadConsoleW。

至于从文件读取，当然按2进制读取肯定能读取到正确的字节流，接下来就是编码转换的问题。Window提供的MultiByteToWideChar与WideCharToMultiByte能正确处理辅助多文本平面里的汉字，Windows下的widechar在win7中其是两个wchar_t来表示一个汉字，其编码是GB18030的编码，GB18030编码是变长编码，其双字节汉字也是两个wchar_t编码，格式看起来有点奇怪，`D2B3编码成 D200B300`。

## 其他资料

### 关于输入法框架
https://blog.codingnow.com/2019/05/windows_utf16.html
https://blog.csdn.net/shuilan0066/article/details/6883629
https://blog.csdn.net/fishmai/article/details/60633558
https://blog.csdn.net/wishfly/article/details/1282973

### 未处理资料

https://stackoverflow.com/questions/39736901/chcp-65001-codepage-results-in-program-termination-without-any-error/39745938#39745938

https://docs.microsoft.com/en-us/windows/win32/api/stringapiset/nf-stringapiset-multibytetowidechar
https://docs.microsoft.com/en-us/windows/win32/intl/code-page-identifiers

https://stackoverflow.com/questions/30539882/whats-the-deal-with-python-3-4-unicode-different-languages-and-windows/30551552#30551552

https://stackoverflow.com/questions/31846091/python-unicode-console-support-under-windows#comment51688033_31846091

### 

[0]:https://conemu.github.io/en/RealConsole.html
[1]:https://www.codeproject.com/Articles/168/ClipSpy
