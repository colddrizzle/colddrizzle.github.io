---
layout: post
title: 在mac上按照jekyll以及rubygems理解
description: ""
category: 其他
tags: [jekyll, rubygems]
---
{% include JB/setup %}

基本上是遵循 官方文档 https://jekyllrb.com/docs/installation/macos/
的安装过程，但又不完全一致。

因为jekyll是一个Ruby Gem。Gem是Ruby应用的一种包装规格。

RubyGems是这个包装规格的包管理工具，类似于`apt-get,brew,pip`这类工具。
rubygems本身又是一个ruby应用。rubygems会根据当前的ruby版本（which命令返回的ruby）来确定安装包的位置，
具体配置可以通过`gem env`来查看。



OK，以上是背景。

我系统上的ruby版本是2.3.7。所要按照的jekyll要求版本2.4。

系统上默认的ruby是xcode commandline tools自带的，安装路径为`/usr/bin/ruby`貌似没有找到更新方法。
看起来势必要安装两个ruby。OK，使用homebrew:

```
brew install ruby
#重新打开控制台执行
which ruby
```
可以看到安装到了`/usr/local/bin/ruby`下了。那为什么which命令能找到新的ruby版本呢？

答案是PATH路径里`/usr/local/bin`排在`/usr/bin`之前。因此老的ruby还存在，依然可以通过绝对路径的方式引用。

然后我一直想怎么样让jekyll这个gem以新的ruby版本来运行。问题在于jekyll这个gem是直接通过ruby来运行的还是通过
gem来运行的。

其实官方文档里有这一句配置

```

export PATH=$HOME/.gem/ruby/X.X.0/bin:$PATH

```
ruby与rubygems是独立的，不同版本的ruby的gem被安装到了不同的目录(具体看是按照到全局还是用户级`gem env`里可以查看按照位置)，且都自动生成了一个gem的包装命令。
也就是上面的bin目录中。

比如jekyll。
当运行jekyll的时候，其实是运行的这个包装命令，该包装命令会去根据当前ruby版本查找合适的gem。

