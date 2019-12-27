## windows平台下的中文乱码bug排查经过

起因很简单，一个页面读取系统文件夹下的所有的文件名字，以列表的形式展现在一个页面中。
因为中文windows系统上的默认编码是GBK，因此加载来的编码需要转码，简化后的情形如同下面：

<pre class="brush:python;">
@route('/list/')
def index():
	filename = filename.decode("gbk")
    return filename

@route('/static/<filename>')
def send_static(filename):
    return static_file(filename, root='../')

</pre>

结果是中文能够正常的在页面上显示，但是访问该文件确报异常：文件找不到

可以确定网页上能正常显示UTF-8编码。通过debug可以发现，send_static中接受到filename也是utf-8编码的str。

问题出在windows系统上需要用gbk编码来读取文件。因此修改为：


<pre class="brush:python;">
@route('/static/<filename>')
def send_static(filename):
	filename = filename.encode("gbk")
    return static_file(filename, root='../')

</pre>

然后报错编码无法转化。

但是仍然报找不到文件的异常，通过`print repr(filename)`对比` filename.decode("gbk")`转化后的utf8编码与send_static接受到的utf-8编码后发现
二者编码不一致，更进一步尝试后才意识到send_static接受到的filename是str类型。而python2
中编码转换需要借助unicode编码作为中介。filename要转为gbk需要解码为unicode，也就是`filename.decode('utf-8')`,然后编码为gbk，`filename.encode("gbk")`。

问题是index()方法中return的是一个unicode对象，而同为utf-8编码的一段字符串其unicode类型与str类型其二进制并不一样。那么为什么网页还能正常显示呢？
那是因为bottle中做了这个转化，有一个`def _cast(self, out, peek=None):`方法，将unicode以指定的输出编码转为了str。可以查看源码，不再细表。

所以值得思考的问题是：为什么同样编码的同一个字符串其unicode类型与str类型的二进制存储竟然会不一样，这个可以借助5层编码模型来理解。
其unicode类型中存的是编码空间中的码位，而str类型存储的是编码方案下的存储方案，比如utf-8多字节编码每个字节都有若干个1。

还一个问题若是有多个请求都需要编码处理，bottle有没有提供一种类似拦截器的东西？


## python os.path.join的特殊行为
打开cmd，进入F盘web目录下，在python执行

os.path.join("F:\\web", os.sep)
会发现得到的结果为"F:\\"。
根据https://docs.python.org/2.7/library/os.path.html#os.path.join 的解释，join函数把os.sep当成了绝对路径从而将之前的内容丢弃。
但是windows上的绝对路径肯定是以盘符开头的，所以可以认为这是个bug。正确的用法保证os.path.join参数的后面的部分不要以斜线开头。

