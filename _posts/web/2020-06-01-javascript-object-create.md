---
layout: post
title: javascript对象创建过程
description: ""
category: web
tags: [javascript,language]
---
{% include JB/setup %}

* toc
{:toc}

<hr />

## 基本认识
javascript作为一种应用级解释型的语言，其解释器必是由其他语言构建的，构建它的语言称之为源语言。javascript作为一种基于对象的
语言，不论其源语言是何种，必然有一种结构用来对javascript对象建模。这一点如同cpython之于python，cpython的源码我们了解过。有了这一点认识，就很好理解
javascript中对象的[[prototype]]之类的双方括号属性是个什么东西了：
* [[prototype]]、[[construct]]、[[call]]都是源语言对对象建模时为了实现javascript层面功能而设立的字段。
* [[protottype]]是所有对象都有的。用来构建原型链，以达到代码复用也就是继承的效果。
* [[construct]]是所有函数对象都有的。当用new关键字调用函数对象的时候，触发[[construct]]里的逻辑。
* [[call]]是所有函数对象都有的。当对函数对象执行`()`操作符的时候，触发[[call]]里的逻辑。

## 对象创建过程
### 普通对象创建内部过程
关于函数创建过程，我没有去找javascript实现规范等权威参考资料，直接参考的[这里][0]和[这里][100]，仅做理解之用。

现在我们来看一下`new Person()`的实现过程

1. new触发[[construct]]逻辑
	1. 使用Object的内部逻辑创建一个obj对象
	2. 如果Person.prototype是Object类型，则将obj的[[prototype]]设置为Person.prototype。否则设置为Object.prototype.
2. `()`触发[[call]]逻辑
	1. 解释器创建当前执行上下文，确定this指向。这里以obj作为this。
	2. 以obj、`()`操作符中参数为参数执行Person函数体
	3. 以Person函数的返回值作为[[call]]的返回值
3. 如果[[call]]的返回值是Object的实例，则返回这个值，否则返回obj

注意1.2步是设置为`Object.prototype`，而不是`Object.__proto__`，前者是Object函数的原型，或者说”Object类“创建的实例默认继承的属性，而后者指向Object函数对象继承来的属性。

显然当执行`Person()`的时候，仅仅执行了上面步骤中的第二步，当在Chrome的console中执行这条代码是，this就指向window，因而会发生
将Person函数体中的属性创建在window对象上的事情。

### 函数对象创建内部过程

待补充。

## 判断对象之间实例关系
表面上javascript没有类的概念，但是对象确实有其创建者。Python、Java中存在判断对象是否是某类实例的方法。Javascript也存在判断对象是否是
某函数创建的方法。

### 选择性地使用instanceof
instanceof的原理[mozilla文档][2]解释的非常简洁：用于检测构造函数的 prototype 属性是否出现在某个实例对象的原型链上。通常我们也可以这样认为，
但其实instanceof有更复杂的逻辑，ECMAScript-262中instanceof操作符规范如下。关于这个操作符规范的详细解释可以参考[这里][3]。
```
11.8.6 The instanceof operator 
 The production RelationalExpression: 
     RelationalExpression instanceof ShiftExpression is evaluated as follows: 
 
 1. Evaluate RelationalExpression. 
 2. Call GetValue(Result(1)).// 调用 GetValue 方法得到 Result(1) 的值，设为 Result(2) 
 3. Evaluate ShiftExpression. 
 4. Call GetValue(Result(3)).// 同理，这里设为 Result(4) 
 5. If Result(4) is not an object, throw a TypeError exception.// 如果 Result(4) 不是 object，
                                                                //抛出异常
 /* 如果 Result(4) 没有 [[HasInstance]] 方法，抛出异常。规范中的所有 [[...]] 方法或者属性都是内部的，
在 JavaScript 中不能直接使用。并且规范中说明，只有 Function 对象实现了 [[HasInstance]] 方法。
所以这里可以简单的理解为：如果 Result(4) 不是 Function 对象，抛出异常 */ 
 6. If Result(4) does not have a [[HasInstance]] method, 
   throw a TypeError exception. 
 // 相当于这样调用：Result(4).[[HasInstance]](Result(2)) 
 7. Call the [[HasInstance]] method of Result(4) with parameter Result(2). 
 8. Return Result(7). 
 
 // 相关的 HasInstance 方法定义
 15.3.5.3 [[HasInstance]] (V) 
 Assume F is a Function object.// 这里 F 就是上面的 Result(4)，V 是 Result(2) 
 When the [[HasInstance]] method of F is called with value V, 
     the following steps are taken: 
 1. If V is not an object, return false.// 如果 V 不是 object，直接返回 false 
 2. Call the [[Get]] method of F with property name "prototype".// 用 [[Get]] 方法取 
                                                                // F 的 prototype 属性
 3. Let O be Result(2).//O = F.[[Get]]("prototype") 
 4. If O is not an object, throw a TypeError exception. 
 5. Let V be the value of the [[Prototype]] property of V.//V = V.[[Prototype]] 
 6. If V is null, return false. 
 // 这里是关键，如果 O 和 V 引用的是同一个对象，则返回 true；否则，到 Step 8 返回 Step 5 继续循环
 7. If O and V refer to the same object or if they refer to objects 
   joined to each other (section 13.1.2), return true. 
 8. Go to step 5.

```
上面一大段的大意是说：
<pre class="brush:javascript;">
function instance_of(L, R) {//L 表示左表达式，R 表示右表达式
 var O = R.prototype;// 取 R 的显示原型
 L = L.__proto__;// 取 L 的隐式原型
 while (true) { 
   if (L === null) 
     return false; 
   if (O === L)// 这里重点：当 O 严格等于 L 时，返回 true 
     return true; 
   L = L.__proto__; 
 } 
}
</pre>
结合规范以及规范的伪代码可以看到，instanceof操作符就是调用R的原型的[[HasInstance]]方法。这使得判断函数是否拥有某实例拥有了一个
统一的入口，从而拦截这种判断称为可能。确实，JS中提供了修改这个方法的手段，从而改变instanceof操作符的结果。
<pre class="brush:javascript;">
function Person(name, age) {
  this.name = name;
  this.age = age;
}
 
Object.defineProperty(Person, Symbol.hasInstance, {
  value(v) {
    return false;
  }
})
 
var wu = new Person('jenemy', 18);
console.log(wu instanceof Person); // false
</pre>

### 不要用constructor
文章[javascript原型模型的理解][4]指出了constructor混乱的语义，因此不要用constructor来判断实例关系。

### js中判断实例关系并不靠谱
关于constructor的不靠谱之处上面已经说了，instanceof本身也不靠谱。原因有两点，一是构造函数的prototype可以在对象创建后被修改，
二是构造函数的hasInstance属性引入的逻辑（详细参考上面instanceof操作符规范）。

## 避免遗漏new操作符\使得函数更像是构造函数

在[对象创建过程]小节我们提到过，如果在chrome中忘记了使用new操作符，会把window当做this，从而将属性创建或覆盖在window对象上（当然未必是window，要看执行环境）。
有时候这是一种失误，但有时候我们可以利用这一点使得函数只能被当做构造函数来使用，更像是”类“的概念。[这里][4]提到了两个小技巧来强制是函数必须使用new来调用，有点意思：

方法一，在调用函数前先判断函数的接收者是否为当前函数的实例。
<pre class="brush:javascript">
function Person(name, age) {
  if (!(this instanceof Person)) {
    return new Person(name, age);
  }
  this.name = name;
  this.age = age;
}

function Person(name, age) {
  var self = this instanceof Person ? this : Object.create(Person.prototype);
  self.name = name;
  self.age = age;
 
  return self;
}
</pre>

对象创建过程小节讲过，this指向新创建的一个对象，且该对象的`__proto__`指向`Person.prototype`。因此，this必是Person的实例，原理很简单。

方法一有两种实现，前者的一个缺点是需要额外的函数调用，在性能上代价有点高。后者更为有效，使用ES5的Object.create()函数。
这个效率更好的说法暂时存疑，使用Object.create有什么区别留待以后再挖。

方法一的两种实现都使用了instanceof，我们提到过instanceof并不靠谱，ES6提供了元属性new.target，当调用函数的[[Construct]]方法时，new.target被赋值为new操作的目标，通常为新创建对象的实例。于是我们有了方法二。

方法二：使用new.target

<pre class="brush:javascript">
function Person(name, age) {
  if (!new.target) {
    throw 'Peron must called with new';
  }
  this.name = name;
  this.age = age;
}
 
var wu = Person('jenemy', 18);
</pre>

这个new.target很有意思，看上去像是关键字new的属性，因为JS的单线程环境，同一时间最多只有一个创建对象的行为，因此new.target只要一个唯一值。看了，多线程模型已经不可能
在ES中发展起来了，因为单线程模型已经渗透到ES语言中。

## 实现单例模式
我认为的单例模式，就是直接new，永远返回同一个对象，而不是像[这里][6]讲的另开一个口子叫`Singleton`，然后通过`Singleton`来创建对象。简直就是鬼扯。你在没有堵死
new创建对象的情况下，使用其他创建对象的口子实现单例就是掩耳盗铃。就算堵死了new，使用其他口子创建对象也会对代码维护造成很大的困难，鬼知道你开的这个口子叫什么名字。
因此最好的方法就是在new创建对象的过程上下文章。上面小节[避免遗漏new操作符]里的方法稍作修改就可以实现单例。

<pre class="brush:javascript;">
Person = (function(){    
	var p = null;
	return function(name, age){
	    if (!new.target) { //强制Person必须通过new调用
	      throw 'Peron must called with new';
	    }
	    if(!p){
	  		p =  this; //让p指向新创建的对象
	  		//p.uuid = Math.random();//验证是同一个对象
	    }

	  	p.name = name;
	  	p.age = age;
	  	return p; //务必返回p，否则自动返回this
	}
}());
</pre>

Javascript没有类概念，也就无处放单例模型中的那个实例，上面使用闭包来实现函数中静态变量的效果，使得单例的那个实例不至于污染全局空间。


[100]:https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Operators/new
[0]:https://www.cnblogs.com/fool/archive/2010/10/13/1850588.html
[1]:https://www.cnblogs.com/fool/archive/2010/10/16/1853326.html
[2]:https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Operators/instanceof
[3]:https://www.ibm.com/developerworks/cn/web/1306_jiangjj_jsinstanceof/index.html
[4]:/2020/05/29/javascript-data-model
[5]:https://blog.csdn.net/weixin_34174132/article/details/88990607
[6]:https://www.cnblogs.com/dengyao-blogs/p/11652566.html
