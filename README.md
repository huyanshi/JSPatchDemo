# JSPatchDemo
iOS开发swift热修复实践<br>

<TOC>

# 一、热修复的背景和选取方案
##1.1背景
  工作中容易犯错、bug难以避免；开发和测试人力有限；苹果Appstore审核周期太长，一旦出现严重bug难以快速上线新版本；作为生产力工具，用户有对稳定性和可靠性的需求。
##1.2选取方案分析

* (1) 申请“加急审核” <br>
方法：提交应用时，选择”加急审核”。<br>
优点：操作简单，只需要重新上传应用即可;<br>
缺点：“加急审核”，肯定是不能经常使用的。<br>
简评：我想，这可能是大多数公司遇到紧急问题时，最常使用的方案。一个应用每年是有若干次机会申请“加急审核”，来缩短应用新版本的审核周期。通常审核周期是7天左右；”加急审核”，通常只需要3天左右。
* (2) 使用 WebVView + Html5 页面 <br>
方法：特定的可能需要经常换的页面使用WebView来显示，内部使用Html5的内容来填充.当需要改变页面时，只需要改变下服务器接口返回的内容即可。<br>
优点：对于内容的更新，足够灵活和迅速。 <br>
缺点：无法修复非HTML5页面的Bug，Html5 交互和UI通常逊色于原生页面。<br>
简评：混合应用常用的方式，如PhoneGap等；对于大多数原生应用来说，此方案基本无适用性。
* (3) 编写基于ReactNative的应用 <br>
方法：使用 ReactNative 来编写应用或应用的部分页面，更多介绍参见：React Native 官方文档中文版。<br>
优点：原生UI，原生交互，支持服务器方式在线更新应用。<br>
缺点：对于非ReactNative编写的页面无能为力。<br>
简评：个人主观是很看好 ReactNative的，也在慢慢踩坑；但现实是大部分公司的已有项目是基于Objetive-C的，所以基于ReactNative的在线更新策略，目前对于大多说公司来说也并不具有可行性。
* (4) 基于WaxPatch实现在线补丁式更新 <br>
方法：在自己的项目中引入WaxPatch库，然后参见下文继续讨论的方案细节实施即可。<br>
优点：支持iOS6 ，支持操作所有工程中引入的CocoaTouch库与各种第三方库。<br>
缺点：Wax框架已经停止维护四五年，有可能审核不通过，Lua扩展脚本语言应用不广泛，不支持Objective-C里block跟Lua程序的互传。<br>
简评： Wax使用lua语言，3年没有更新，而且苹果对于Wax使用的态度也处于模糊状态，这也是一个潜在的使用风险。
* (5) 基于JSPatch实现在线补丁式更新 <br>
方法：在自己的项目中引入JSPatch库，然后参见下文继续讨论的方案细节实施即可参照JSPatch的入门使用。<br>
优点：支持操作所有工程中引入的CocoaTouch库与各种第三方库。可完全自由定义与重写已有代码的逻辑，符合Apple规则，小巧，支持block。<br>
缺点：JS语法操作API，语法转换有一定成本，最低版本兼容iOS7。<br>
简评：大多数时候我们需要的只是重写下某个方法，甚至某个判断某个默认值，就可以很好地修复某个线上的Bug。所以JSPatch已经够用了。当然，如果是对于复杂的新功能的添加的话，建议还是提交审核吧。另外不得不说JSPatch + ReactNatvie 将来或许会成为一个很强力的组合，前者侧重于Bug的修复，后者侧重于复杂新需求的添加。

# 二、JSPatch介绍和应用项目
JSPatch诞生于2015年5月，最初是腾讯广研高级iOS开发@bang的个人项目。它能够使用JavaScript调用Objective-C的原生接口，从而动态植入代码来替换旧代码，以实现修复线上bug。JSPatch在Github.com上开源后获得了3000多个star和500多fork，广受关注，目前已被应用在大量腾讯/阿里/百度的App中。

## 2.1 JSPatch作者简介
JSPatch的作者是bang，1988年生于广东陆丰，毕业于华南师范大学，职业程序员，个人的签名是做自己喜欢做的事。经常上新浪微博，有时用Instagram拍照，会去豆瓣找书和电影，偶尔上twitter。可以看出作者是一个比较自由思维开阔的程序猿。下图是bang的github地址。
![](https://github.com/huyanshi/JSPatchDemo/blob/master/bang_github.png) <br>
[微博地址](http://weibo.com/bang"点击跳转") <br>
[github地址](https://github.com/bang590"点击跳转") <br>
[个人主页](http://cnbang.net"点击跳转")

## 2.2 JSPatch应用在的项目
JSPatch诞生一年多以来已经在超过2500个APP中使用。如下图已经在使用的APP。
![](https://github.com/huyanshi/JSPatchDemo/blob/master/JSPatch_client.png)

## 2.3 JSPatch的原理
   JSPatch用iOS内置的JavaScriptCore.framework作为JS引擎，但没有用它JSExport的特性进行JS-OC函数互调，而是通过Objective-C Runtime，从JS传递要调用的类名函数名到Objective-C，再使用NSInvocation动态调用对应的OC方法。<br>
   JSPatch 能做到通过 JS 调用和改写 OC 方法最根本的原因是 Objective-C 是动态语言，OC 上所有方法的调用/类的生成都通过 Objective-C Runtime 在运行时进行，我们可以通过类名/方法名反射得到相应的类和方法：<br>
         Class class = NSClassFromString("UIViewController");<br>
         id viewController = [[class alloc] init];<br>
         SEL selector = NSSelectorFromString("viewDidLoad");<br>
         [viewController performSelector:selector];<br>
   也可以替换某个类的方法为新的实现：<br>
         static void newViewDidLoad(id slf, SEL sel) {}<br>
         class_replaceMethod(class, selector, newViewDidLoad, @"");<br>
   还可以新注册一个类，为类添加方法：<br>
         Class cls = objc_allocateClassPair(superCls, "JPObject", 0);<br>
         objc_registerClassPair(cls);<br>
         class_addMethod(cls, selector, implement, typedesc);<br>
   理论上你可以在运行时通过类名/方法名调用到任何 OC 方法，替换任何类的实现以及新增任意类。所以 JSPatch 的基本原理就是：JS 传递字符串给 OC，OC 通过 Runtime 接口调用和替换 OC 方法。<br>
# 三、Swift中Runtime的分析与可行性

## 3.1 Swift
2014年WWDC大会，苹果在毫无预兆的情况下，发布了Swift编程语言。这个语言刚发布就引起了广泛关注。Swift虽然是新语言，却融合了Objective-C的很多特性。Swift与Objective-C共用同一套运行时环境。Swift的语法给人第一感觉就是简洁干净，Swift写起来，有点像脚本语言。这里没有出现类型定义，有人觉得它就是脚本语言，是解释执行的。而实际上Swift是真正的编译语言，通过类型推导，变量的类型可以确定下来。既然省略掉类型也不引起歧义，也就可以省略了。不再兼容C语言，修正Objective-C中容易出错的地方。将Swift分拆开，可大致分成以下部分：基本类型、控制流、函数定义和调用、函数式编程、面向对象、泛型。Swift的内容包含很多，也可以说很复杂，并非表面上看起来那样简单。Swift从语法上直接支持现代流行的编程泛式，包括：结构化编程、函数式编程、面向对象、泛型。

## 3.2 Runtime原理
RunTime简称运行时。OC就是运行时机制，其中最主要的是消息机制。对于C语言，函数的调用在编译的时候会决定调用哪个函数。对于OC的函数，属于动态调用过程，在编译的时候并不能决定真正调用哪个函数，只有在真正运行的时候才会根据函数的名称找到对应的函数来调用。
Runtime基本是用C和汇编写的，可见苹果为了动态系统的高效而作出的努力。你可以在这里下到苹果维护的开源代码。苹果和GNU各自维护一个开源的runtime版本，这两个版本之间都在努力的保持一致。方法调用的本质，就是让对象发送消息。objc_msgSend,只有对象才能发送消息，因此以objc开头
使用消息机制前提，必须导入#import \<objc/message.h\>。

### 3.2.1方法交换
交换方法实现的需求场景：自己创建了一个功能性的方法，在项目中多次被引用，当项目的需求发生改变时，要使用另一种功能代替这个功能，要求是不改变旧的项目(也就是不改变原来方法的实现)。<br>
可以在类的分类中，再写一个新的方法(是符合新的需求的),然后交换两个方法的实现。这样，在不改变项目的代码，而只是增加了新的代码 的情况下，就完成了项目的改进。<br>
交换两个方法的实现一般写在类的load方法里面，因为load方法会在程序运行前加载一次，而initialize方法会在类或者子类在 第一次使用的时候调用，当有分类的时候会调用多次。<br>
### 3.2.2类\对象的关联对象
关联对象不是为类\对象添加属性或者成员变量(因为在设置关联后也无法通过ivarList或者propertyList取得) ，而是为类添加一个相关的对象，通常用于存储类信息，例如存储类的属性列表数组，为将来字典转模型的方便。 <br>
(1) 给分类添加属性<br>
(2) 给对象添加关联对象<br>
### 3.3 Swift中Runtime可行性<br>
纯Swift类的函数调用已经不再是OC的运行时发消息objc_msgsend，而是类似C++的vtable，在编译时就确定了调用什么函数，所以runtime获取不到。 继承于NSObject的类依然拥有动态性，所以可以拿的到。OC的runtime特性就是，所有的运行时方法都依赖TypeEncoding，他指定了方法的参数类型以及函数在调用时参数入栈所需要的内存空间，没有这个标识就无法动态的压入参数。返回类型Tuple，也就是元组，是Swift特有的，无法映射到OC的类型，也无法用OC的TypeEncoding表示，所以也无法通过runtime获取。<br>
### 3.3.1 @objc<br>
@objc是用来将Swift的API导出给OC与OC runtime使用的，如果你继承NSObject的类，将会被自动的加入这个标识。<br>
### 3.3.2 dynamic
同时，还有这个，文档中有一句说明，加了@objc标识的方法、属性都无法保证都会被运行时调用，因为Swift会做静态优化。要想完全被动态调用就要使用dynamic修饰词了。使用这个标识也会隐形的加入@objc。这也就解释了为什么上边VC中的方法无法被替换了，被Swift优化成静态调用了，而ViewDidAppear本身为OC的方法，拥有动态特性，所以我们加入dynamic关键字
### 3.3.3小结
* (1) 纯Swift类没有动态性，但在方法、属性前添加dynamic修饰可以获得动态性；
* (2)继承自NSObject的Swift类，其继承自父类的方法具有动态性，其他自定义方法、属性需要加dynamic修饰才可以获得动态性；
* (3) 若方法的参数、属性类型为Swift特有、无法映射到Objective-C的类型(如Character、Tuple)，则此方法、属性无法添加dynamic修饰（会编译错误）；
* (4) Swift类在Objective-C中会有模块前缀。

# 四、JSPatch 的补丁包管理

## 4.1版本更新策略
考虑到下一个提交的App版本已经修复了上一个版本的bug，所以不同的App版本对应的补丁版本肯定也不同。同一个App版本下，可以出现递增的补丁版本。补丁为全量更新，即新版本补丁包括旧版补丁的内容，更新后新版补丁覆盖旧版补丁。补丁分为可选补丁和必选补丁，必选补丁用于重大bug的修复，如果不更新必选补丁则App无法继续使用。如下图中，补丁版本v1234对应各自版本的用户，补丁v3为必须更新，补丁v1，v2，v4为可选补丁，则v1，v2的用户必须更新到v4才可使用；而v3的用户可先使用，同时后台静默更新到v4。
![](https://github.com/huyanshi/JSPatchDemo/blob/master/Patch_hotfix.png)
## 4.2安全策略
安全问题在于JS 脚本可能被中间人攻击替换代码。可采取以下三种方法，股单App目前采用的是第三种：
* 1.对称加密。如zip 的加密压缩、AES 等加密算法。优点是简单，缺点是安全性低，易破解。若客户端被反编译，密码字段泄露，则完成。
* 2.HTTPS。优点是安全性高，证书在服务端未泄露，就不会被破解。缺点是部署麻烦，如果服务器本来就支持 HTTPS，使用这种方案也是一种不错的选择。
* 3.RSA校验。安全性高，部署简单。
### (1)RSA校验
详细校验步骤如下图所示:
* 1.服务端计算出脚本文件的 MD5 值，作为这个文件的数字签名。
* 2.服务端通过私钥加密第 1 步算出的 MD5 值，得到一个加密后的 MD5 值。3.把脚本文件和加密后的 MD5 值一起下发给客户端。
* 4.客户端拿到加密后的 MD5 值，通过保存在客户端的公钥解密。
* 5.客户端计算脚本文件的 MD5 值。
* 6.对比第 4/5 步的两个 MD5 值（分别是客户端和服务端计算出来的 MD5 值），若相等则通过校验。
![](https://github.com/huyanshi/JSPatchDemo/blob/master/Pathch_encrypt.png)
## 4.3.客户端策略
客户端具体策略如下图所示:
* 1.用户打开App时，同步进行本地补丁的加载。
* 2.用户打开App时，后台进程发起异步网络请求，获取服务器中当前App版本所对应的最新补丁版本和必须的补丁版本。
* 3.获取补丁版本的请求回来后，跟本地的补丁版本进行对比。
* 4.如果本地补丁版本小于必须版本，则提示用户，展示下载补丁界面，进行进程同步的补丁下载。下载完成后重新加载App和最新补丁，再进入App。
* 5.如果本地补丁版本不小于必须版本，但小于最新版本，则进入App，不影响用户操作。同时进行后台进程异步静默下载，下载后补丁保存在本地。下次App启动时再加载最新补丁。
* 6.如果版本为最新，则进入App。<br>
![](https://github.com/huyanshi/JSPatchDemo/blob/master/Patch_client_encrypt.png)<br>

## 完整的流程图
![](https://github.com/huyanshi/JSPatchDemo/blob/master/Patch_server-client.png)

# 参考文献
* [1] bang.JSPatch[DB/OL].https://github.com/bang590/JSPatch/blob/master/README-CN.md ，2015-12-23/2016-10-17.
* [2] 上官soyo.JSPatch技术文档[DB/OL]. http://www.jianshu.com/p/0cb81bf23d7a ，2015-12-13/2016-10-17.
* [3] bang.JSPatch平台介绍[DB/OL]. http://blog.cnbang.net/works ，2016-3-10/2016-10-17.
* [4] 颜风.基于JSPatch的iOS应用线上Bug的即时修复方案[DB/OL]. http://www.ios122.com/2015/12/jspatconline ，2015-12-7/2016-10-18.
* [5] 七牛云存储.Who is using JSPatch[EB/OL]. http://using.jspatch.org ，2015/2016-10-17.
* [6] 中证网编辑部.《我要上头条》第七期[J/OL]，http://www.fjfqrd.cn/keji/jiadian/83219.html ，2015-6-11/2016-10-17.
* [7] 七七.iOS Runtime原理及使用[DB/OL]. http://www.cnblogs.com/jys509/p/5207159.html ，2016-2-22/2016-10-17.
* [8] 黄兢成. 从Objective-C到Swift[DB/OL]. http://www.csdn.net/article/2014-07-08/2820568 ，2014-07-08/2016-10-18.
* [9] bang.JSPatch-动态更新iOS APP[DB/OL]. http://blog.cnbang.net/works/2767 ，2015-5-25/2016-10-18.
* [10] 尹峥伟. Swift Runtime分析：还像OC Runtime一样吗？[DB/OL]. http://www.jianshu.com/p/99ecdb4622c5 ，2016-03-29/2016-10-18.
* [11] 祭遵. JSPatch在Swift中的应用（一）[DB/OL]. http://www.jianshu.com/p/e2eb7b4861c5 ，2016-4-15/2016-10-24.
















