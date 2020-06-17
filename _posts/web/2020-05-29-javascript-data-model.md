---
layout: post
title: javascript原型模型的理解
description: ""
category: web
tags: [javascript,language]
---
{% include JB/setup %}

* toc
{:toc}

<hr />

## 术语统一
因为JS中函数对象即是函数又是对象，
作为函数，其必有原型。函数，强调其可执行。
作为对象，其必有创建者。对象，可看做是个带类型的字典，这点可通过打印任意一个对象来验证。
双重身份容易混淆，以JS内置的Function为例，所以我们规定下面用语约束：
	当我们说Function函数，指的是函数方面。
	当我们说Function对象，指的是对象方面。

	我们不会说Function对象的原型，而是说Function函数的原型。
	同样，我们也不会说Function函数的创建者，而是说Functin对象的创建者。

	当我们说Function函数对象的时候，则强调其两种身份。

	关于创建者，我们认为对象创建者既不是函数也不是字典，而是两者的结合。
	因此我们会说，对象由“函数依据其原型”创建。或者把创建者中的原型单独拿出来看做是创建模板，
	因此我们可以说，对象是由构造函数依据某个创建模板创建出来的。

## 基础认识与推论

* JS中一切都是对象，但JS中不存在类的概念，JS是弱类型语言，弱类型导致JS有对象但没有类，有继承链但是没有类型链，这一点不同于python。

* JS中所有对象都是由函数依据其原型创建，函数也是对象，函数也由其他函数依据原型创建。因此必然存在一个“根函数”以及一个“根原型”。

* 原型是一个对象，可以看做是字典。那“根原型”其实就是一个字典。

* 原型与构造函数合起来可看做我们熟悉的类，实际上JS中二者永远是通过prototype与constructor俩字段构成双向链接紧密相连的。只有函数对象拥有且必有prototype字段，只有原型对象拥有且必有constructor属性。但是原型对象本身在对象的查找路径上，会出现看起来好像非原型对象拥有constructor字段一样，从而使constructor的语义混淆，关于constructor的语义，下面会再细讲。

* 所有的对象都包含`__proto__`字段，指向其创建函数的原型，对象之间通过`__proto__`构成原型链。这个`__proto__`字段是非标字段，其实对应的是JS语言内部本来不可见不可操作的`[[prototype]]`属性。注意原型链指的是`__proto__`而不是`prototype`，后者无法构成链，因为原型必不是函数。

* 对象创建大致就是Object先创建一个新对象，然后将新对象的[[prototype]]指向构造函数的原型。然后以之为this调用构造函数。

* 函数对象拥有双重身份。所有函数都拥有一个原型用来创建对象，因此可以说任意一个函数都可以是构造函数。因为函数的双唇身份，函数有`new --> ()`与`直接()`两种执行方式。

## 万物相连-万物有根
有了上节的基础认识，我们再来看网上的那个著名的图，便会恍然大悟：
![img](/assets/resources/js-prototype-model.jpg)

这个图本质上就讲了一件事：函数与函数、函数与原型、原型与原型之间的关系。根据上面的图可以推想，Javascript的设计者认为

* 只有Function能够创建函数，连Function自己也不例外，因此所有的函数对象都是由Function创建。
* 所有的对象的原型链都包含Object的原型Object.prototype，除了它自己之外，它没有原型，也就说，它是原型链的根。
* 函数必有一个原型跟随，二者通过constructor与prototype字段互连。

牢记上面三点，我们自己就能默画出上图了。

上图里还需要注意的是两个逻辑上的循环：

* `Function.__proto__`指向`Function.prototype`，意味着Function是以自己的原型为原型创建。也就是”自己创建自己“？
* Object作为函数由Function创建，但是Function的原型作为对象由Object创建。现有鸡还是先后蛋呢？

当然上面的循环在解释器实现中是不可能的这样按顺序创建的，而是分别创建，然后建立联系。只是在javascript模型层面逻辑上确实如此。

其实除了原型链，逻辑上还存在创建链，因为只有函数能创建对象，而函数本身也是对象必有其创建者，构成了创建链。
创建链上除了末尾肯定都是函数，但JS并没有用一个字段来维护创建链，需要注意的是constructor不是维护创建链的，constructor属性很脆弱容易被修改，
下面会讲。

与python对比，原型链与python继承链相仿，但是**原型链强调的是实例与实例之间的原型关系，而继承链强调的是类与类之间的继承关系**。
JS没有维护创建链，而python有维护创建链。

此外，python与js在对象模型的根的处理上相似，python中的继承链与js中的原型链都有根，根之外为NULL。python的创建链认为type与object互相创建，
而js中的创建链上也存在循环关系。

关于这一小节，还可以参考[这里][0]。

## 扑朔迷离的constructor语义
首先我们必须明确一点，constructor字段只存于原型对象中。但是constructor正因为存在于原型对象中，可以通过原型链访问到，当通过任意一个对象访问到constructor字段的时候，
该怎么解读这个字段的含义呢？

### 若对象是原型 
constructor属性属于该对象，此时constructor指向该原型对应的函数。意义是：原型使用constructor指向的函数创建对象。

### 若对象是实例而constructor属性通过原型链找到

此时意味着 该对象由constructor指向的函数创建。比如
<pre class="brush:javascript">
function Person(name, age){
	this.name = name;
	this.age =  age;
}
var p = new Person("Tom", "12");

(p.constructor === Person) == true;
</pre>

但是以上俩种情景都可以被认为破坏，破坏后语义不明朗。参见下面的破坏状态。

### 破坏状态

第一种破坏方式：执行new之前更改函数的prototype。

<pre class="brush:javascript">
function Person(name, age){
	this.name = name;
	this.age =  age;
}
Person.prototype = {};

var p = new Person("Tom", "12");

(p.constructor === Object) == true;
</pre>
这是因为`{}`没有没有constructor属性，通过`{}.__proto__`原型链继续查找，查找到`Object.prototype`，而`Object.prototype`的constructor属性指向Object函数。

这时候就破坏了实例对象中constructor属性的语义，显然p不由Object创建。

修补的方式很简单，更改原型时加上constructor属性：`Person.prototype = {constructor:Person}`。

第二种破坏方式：执行new之后更改原型的constructor
<pre class="brush:javascript">
function Person(name, age){
	this.name = name;
	this.age =  age;
}

var p = new Person("Tom", "12");

Person.prototype.constructor = function(){};

(p.constructor === Person) == true;
</pre>

因为以上的破坏情形，js中实际上是没有维护创建链的。不像`__proto__`属性，无法从外部修改。

## 对象的创建过程
参考[这里][1]。

## 继承的实现方式
本节内容可参考Nicholas《Javascript高级程序设计》第3版第6章内容，书中说明了6种实现继承的方式，
区别主要在于基类与子类的值类型与引用类型属性的私有还是共享的问题。
网上也有各种继承实现方式的介绍，但是继承方式命名混乱甚至互相冲突，以那本书为准。

### 仿照python那样的metaclass？
我们知道，函数附带有一个原型对象。一般而言，这个原型对象是Object.prototype。当然我们可以在执行new之前更改函数的prototype的指向。但能否找到类似python中
metaclass的那种方式，其创建的函数附带的原型对象是我们定制的。推而广之，就是能否找到一种自由创建函数的方法？

咋看上去，似乎只要令prototype指向Function.prototype就可以了。
<pre class="brush:javascript;">
function MyFunction(){
	this.uuid = Math.random();
}

MyFunction.prototype = Function.prototype;
// 或者
// MyFunction.prototype = Function

var myFunc = new MyFunction();
</pre>

遗憾的是，这两种方式都不行，`myFunc`只是普通对象，不支持`()`操作。

我暂时找到一种方法如下：
<pre class="brush:javascript;">
function MyFunction(){  
	//var func = new Function(arguments);//变长参数不可以二次传递
	var proto = Object.create(Function.prototype);
	var func  = Function.apply(proto, [...arguments]);//只有apply接受数组形式的多参数
	func.uuid = Math.random();

	return func;// 务必要返回func，否则new创建的只是普通对象
}

var myFunc = new MyFunction("a","this.a = a;");
console.log(myFunc.uuid);
console.log(new myFunc(1));
</pre>

## this、super、bind、call、apply

关于this与super可以参考[这里][10]。这篇文章里讲this指向当前对象，但是当前对象是个什么东西呢?
其实要理解这个，就需要理解执行上下文。参考[这里][11]。

关于call、bind、apply的意义与区别参考[这里][12]，讲的非常明白。
简而言之：三者都是改变方法体中this的指向的。与call的区别在于bind仅仅绑定不执行函数。apply接受多个参数以数组形式传递。

## 参数相关：caller、callee、arguments
根据[这里][13]，caller与callee都是些陈芝麻烂谷子，正在被废弃掉的东西，不了解也罢。

倒是arguments涉及到变长参数传递，可以了解一下。但是注意，arguments不能做二次传递。
目前我也没有找到变长参数二次传递的通用方法。



[0]:https://www.zhihu.com/question/34183746
[1]:/2020/06/01/javascript-object-create
[10]:https://www.runoob.com/w3cnote/the-different-this-super.html
[11]:/2020/06/01/javascript-execute-context-scope-chain.md
[12]:https://www.runoob.com/w3cnote/js-call-apply-bind.html
[13]:https://www.jianshu.com/p/e1542e09869a





