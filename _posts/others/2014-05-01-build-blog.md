---
layout: post
category : 其他
tagline: "Supporting tagline"
tags : [jekyll, 语法高亮, github, blog]
title: 搭博小记
---
{% include JB/setup %}

使用github搭建博客一般有两种方法，其一是在任意一个仓库下用pages自动生成项目的gh-pages分支，作为博客，其二是建立名为
username.github.io的仓库，github将把此仓库关联到域名http://username.github.io上。下面简单介绍两种方法。
***************
###方法一
1.github上注册账号。  
2.新建仓库。  
3.仓库Setting页面使用auto pages generator。每一个仓库都可以有一个pages。然后查看pages的setting页面就可以看到pages网址。  
4.为了使用gitshell clone自己的blog，需要生成ssh以免密码登陆。  
5.使用ssh-keygen生成密码，三次回车，第二次回车会要求输入key的访问密码，可以省略。  
6.将github-rsa.pub的内容拷贝到github的账户密码中。  
7.使用git clone git@github.com:colddrizzle/blog.git便可以在生成本地库。（git@github使用git协议，还可以使用https协议，一般后者较快，
https协议的地址可以在github仓库的页面找到,使用https协议可以不设置前述ssh-key）  
8.在本地使用任意工具编辑页面。  
9.使用git add -A添加到下一次提交列表。   
10.使用git commit –m”messages”提交到本地。  
11.使用git push推送到github.com。(push一般需要关联远程仓库，但是clone得到的仓库里的.git的config里的remote已经设置好了)   

###方法二
1.新建仓库，命名为username.github.io，但是不生成pages。为行文方便，假设其git的https地址为url。  
2. 从git clone [这儿][1]克隆jekyll-bootstrap模板到本地仓库。  
3.修改.git里confing的remote设置为上文的url。  
4.执行git push推送到自己的博客。  
5.开始在本地修改样式，创建自己的博客吧。

******************
###方法二的一些小技巧
1. __快速更改主题__：[浏览选择主题][2],按照页面指示在本地仓库下执行rake命令。
2. __添加评论__:在disqus上注册，上面最后会给出一段代码（universal code），将这段代码添加到_includes\JB\comments-providers\disqus中，并且做如下修改：
    <input type="hidden" class="brush" value="brush:xml;highlight:[7,11]" />
    
        <div id="disqus_thread"></div>
        <script type="text/javascript">
            {% if site.safe == false %}var disqus_developer = 1;{% endif %}
            var disqus_shortname = '{{ site.JB.comments.disqus.short_name }}'; // required: replace example with your forum shortname
            {% if page.wordpress_id %}var disqus_identifier = '{{page.wordpress_id}} {{site.production_url}}/?p={{page.wordpress_id}}';{% endif %}
            /* * * DON'T EDIT BELOW THIS LINE * * */
            function add_comment() { /*添加函数名*/
                var dsq = document.createElement('script'); dsq.type = 'text/javascript'; dsq.async = true;
                dsq.src = 'http://' + disqus_shortname + '.disqus.com/embed.js';
                (document.getElementsByTagName('head')[0] || document.getElementsByTagName('body')[0]).appendChild(dsq);
            }/*去掉()以免立即执行函数*/
        </script>
        <noscript>Please enable JavaScript to view the <a href="http://disqus.com/?ref_noscript">comments powered by Disqus.</a></noscript>
        <a href="http://disqus.com" class="dsq-brlink">blog comments powered by <span class="logo-disqus">Disqus</span></a>
这样修改的目的将在下文说明。
然后修改_config.yml的comment provider为disqus，short_name设置为在disqus上添加站点时设置的shortname，以后可以从disqus上集中看自己的评论，删除评论。
可以在Disqus的站点下设置允许接收匿名评论（即作为guest访问），在Disqus账户中设置不接收Disqus摘要以去掉广告:)
3. __中文支持__：包括两个部分jekyll的中文直接和Markdown的中文支持。前者在_config.yml中配置encoding:utf-8，以后凡是出现中文的文件都要在无BOM的UTF-8格式下编辑;
修改permalink: /:categories/:year/:month/:day/:title，将/:categories去掉以免分类出现在链接中。
Markdown则在_config.yml中配置markdown:rdiscount。rdiscount是一个支持中文的markdown引擎。
4. __代码高亮__：使用google code prettify或者syntaxhighlighter。
我使用的是syntaxhighlighter,因为它的功能较强大一些。但这种方法插入代码时候需要使用pre标签，pre标签会让内部的<,&符号得不到转义，从而影响html的解析。但若是使用其他的块标签将导致
代码的原有格式被打乱,code标签会导致markdown添加的pre标签成为代码的一部分而被显示出来。我的解决办法是在markdown中需要插入代码的地方之前加上一行:  
`<input type="hidden" class="brush" value="brush:cpp;first-line:10;highlight=[12,13]" />`   
其中value值就是syntaxhighlighter的pre标签的class属性。
然后空一行，按照markdown的语法格式正常的插入代码即可。这样markdown就会先将代码中的<，&自动转换为html实体，然后加上pre标签。我们需要做的就是用jquery为这个pre标签添加上
class属性。定位这个pre标签自然是根据上面的input标签，我的js代码如下：  
<input type="hidden" class="brush" value="brush:jscript" />

        $(document).ready(function(){
            $("input.brush").each(function(i,cur){
                var t=$(cur).parent();//get P
                var node=$(t).next();//get PRE
                var code=$(node).children("code")[0];//get CODE
                $(code).attr("class",$(cur).attr("value"));//set class
            });
            SyntaxHighlighter.config.tagName="code";
            SyntaxHighlighter.defaults['toolbar']=false;
            SyntaxHighlighter.all();
            add_comment();
        });
可以看到add_comment()在页面完加载并且代码高亮渲染完之后调用，这样是避免访问disqus.com时网速过慢从而导致整个页面卡在这儿（顺便吐槽学校的破网速:<），从而导致jquery的ready方法无法执行，从而无法渲染代码。
5. __添加站点统计__：我使用的是cnzz，首先是去cnzz注册并添加自己的站点，然后cnzz会给你一段js代码，将这段代码保存为cnzz文件并拷贝到_includes\JB\analytics-providers\目录下，修改
_includes\JB\analytics文件，仿照其格式添加：
<input type="hidden" class="brush" value="brush:plain" />

        \{\% when "cnzz" \%\}
        \{\% include JB/analytics-providers/cnzz \%\}
在_config.yml添加站点配置site:&nbsp;true（注意冒号之后的空格），修改analytics provider为cnzz。

[1]:https://github.com/plusjade/jekyll-bootstrap.git
[2]:http://www.jekyllbootstrap.com/usage/jekyll-theming.html