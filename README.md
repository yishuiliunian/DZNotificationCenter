DZNotificationCenter
====================

一个优化版的由中心枢纽的通知中心

#####apple版实现的NotificationCenter让我用起来不太爽的几个小问题
在使用NSNotificationCenter的时候，从编程的角度来讲我们往往不止是希望能够做到功能实现，还能希望编码效率和整个工程的可维护性良好。而Apple提供的以NSNotificationCenter为中心的观察者模式实现，在可维护性和效率上存在以下缺点：

1. 每个注册的地方需要同时注册一个函数，这将会带来大量的编码工作。仔细分析能够发现，其实我们每个观察者每次注册的函数几乎都是雷同的。这就是种变相的CtrlCV，是典型的丑陋和难维护的代码。
2. 每个观察者的回调函数，都需要对主题对象发送来的消息进行解包的操作。从UserInfo中通过KeyValue的方式，将消息解析出来，而后进行操作。试想一下，工程中有100个地方，同时对前面中在响应变化的函数中进行了解包的操作。而后期需求变化需要多传一个内容的时候，将会是一场维护上的灾难。
3. 当大规模使用观察者模式的时候，我们往往在dealloc处加上一句:  
	`[[NSNotificationCenter defaultCenter] removeObserver:self]`  
	而在实际使用过程中，会发现该函数的性能是比较低下的。在整个启动过程中，进行了10000次RemoveObserver操作，
		
	```
	@implementation DZMessage
	- (void) dealloc
	{
 	   [[NSNotificationCenter defaultCenter] removeObserver:self];
	}
	....
```
	
	```
   for (int i = 0 ; i < 10000; i++) {
        DZMessage* message = [DZMessage new];
    }
```
	通过下图可以看出这一过程消耗了23.4%的CPU，说明这一函数的效率还是很低的。	![image](http://image226-c.poco.cn/mypoco/myphoto/20140111/21/17448668720140111213040027.jpg)
这还是只有一种消息类型的存在下有这样的结果，如果整个NotificationCenter中混杂着多种消息类型，那么恐怕对于性能来说将会是灾难性的。  

	```
   for (int i = 0 ; i < 10000; i++) {
        DZMessage* message = [DZMessage new];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handle) name:[@(i) stringValue] object:nil];
    }
```
	增加了多种消息类型之后，RemoveObserver占用了启动过程中63.9%的CPU消耗。
![image](http://image226-c.poco.cn/mypoco/myphoto/20140111/21/17448668720140111215636037.jpg)
	而由于Apple没有提供Center的源码，所以修改这个Center几乎不可能了。

######改进版的有中心观察者模式（DZNotificationCenter）
[GitHub地址](https://github.com/yishuiliunian/DZNotificationCenter.git)
在设计的时候考虑到以上用起来不爽的地方，进行了优化：

1. 将解包到执行函数的操作进行了封装，只需要提供某消息类型的解包block和消息类型对应的protocol，当有消息到达的时候，消息中心会进行统一解包，并直接调用观察者相应的函数。
2. 对观察者的维护机制进行优化（还未做完），提升查找和删除观察者的效率。

DZNotificationCenter的用法和NSNotificationCenter在注册和注销观察者的地方是一样的，不一样的地方在于，你在使用的时候需要提供解析消息的block。你可以通过两种方式来提供。

* 直接注册的方式

	```
[DZDefaultNotificationCenter addDecodeNotificationBlock:^SEL(NSDictionary *userInfo, NSMutableArray *__autoreleasing *params) {
        NSString* key = userInfo[@"key"];
        if (params != NULL) {
            *params = [NSMutableArray new];
        }
        [*params  addObject:key];
        return @selector(handleTestMessageWithKey:);
    } forMessage:kDZMessageTest];
```

* 实现DZNotificationInitDelegaete协议，当整个工程中大规模使用观察者的时候，建议使用该方式。这样有利于统一管理所有的解析方式。

```
- (DZDecodeNotificationBlock) decodeNotification:(NSString *)message forCenter:(DZNotificationCenter *)center
{
    if (message == kDZMessageTest) {
        return ^(NSDictionary* userInfo, NSMutableArray* __autoreleasing* params){
            NSString* key = userInfo[@"key"];
            if (params != NULL) {
                *params = [NSMutableArray new];
            }
            [*params  addObject:key];
            return @selector(handlePortMessage:);
        };
    }
    return nil;
}
```

在使用的过程中为了，能够保证在观察者处能够回调相同的函数，可以实现针对某一消息类型的protocol

```
@protocol DZTestMessageInterface <NSObject>
- (void) handleTestMessageWithKey:(NSString*)key;
@end
```

这样就能够保证，在使用观察者的地方不用反复的拼函数名和解析消息内容了。

```
@interface DZViewController () <DZTestMessageInterface>
@end
@implementation DZViewController
....
- (void) handleTestMessageWithKey:(NSString *)key
{
    self.showLabel.text = [NSString stringWithFormat:@"get message with %@", key];
}
....
```
