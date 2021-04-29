
## servlet tomcat spring的关系
servlet是框架规范，web应用被构建为一个个servlet。
tomcat是servlet容器或者说servlet的运行环境，运行servlet这个小“程序”。
spring为web开发提供工具以及框架级规范。


## servlet教程：
https://www.runoob.com/servlet/servlet-intro.html

@WebServlet是由谁提供，又是谁来实现的？

## spring
spring不是一个单独的项目，包含很多项目，参考
https://spring.io/projects

spring支持Servlet-stack与reactive-stack web applications（https://spring.io/projects/spring-framework spring-webmvc与spring-webflux）,二者区别：

https://www.zhihu.com/question/356329198

### spring boot

spring boot似乎内置了tomcat：https://www.cnblogs.com/sword-successful/p/11383723.html
https://blog.csdn.net/qq_32101993/article/details/99700910

### spring framework

文档：https://docs.spring.io/spring-framework/docs/current/reference/html/index.html

文档中也提到web servlet，那么这提供了哪些东西呢？另外提供这些东西并不意味spring可以脱离tomcat运行。

