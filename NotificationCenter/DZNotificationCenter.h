//
//  DZNotificationCenter.h
//  TimeUI
//
//  Created by Stone Dong on 13-12-15.
//  Copyright (c) 2013年 Stone Dong. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 *  解析更改内容的Block，传入需要解析内容，传出函数和参数。
 *
 *  @param userInfo 需要解析的更改内容
 *  @param params   传出参数列表的数组的指针
 *
 *  @return 函数
 */
typedef SEL (^DZDecodeNotificationBlock)(NSDictionary* userInfo, NSMutableArray* __autoreleasing* params);

@class DZNotificationCenter;

/**
 *  通知中心初始化委托，实现该委托为了为通知中心提供解析block，当通知中心找不到特定消息累心的解析block的时候，会调用改委托的初始化函数，来查找相应block。
 */
@protocol DZNotificationInitDelegaete <NSObject>
/**
 *  当通知中心找不到特定消息累心的解析block的时候，会调用该函数，来查找相应block。

 *
 *  @param message 需要解析的消息类型
 *  @param center  调用该函数的消息中心
 *
 *  @return 解析更改内容的block
 */
- (DZDecodeNotificationBlock) decodeNotification:(NSString*)message forCenter:(DZNotificationCenter*)center;
@end


/**
 *  方便调用通知中心的一个宏定义
 */
#define DZDefaultNotificationCenter [DZNotificationCenter defaultCenter]

/**
 *  通知中心，观察者模式的实现
 */

@interface DZNotificationCenter : NSObject
/**
 *  初始化委托
 */
@property (nonatomic, weak) id<DZNotificationInitDelegaete> delegate;
/**
 *  通知中心的一个全局单例
 *
 *  @return 通知中心的一个全局单例
 */
+ (DZNotificationCenter*) defaultCenter;
/**
 *  手动初始化特定消息类型
 *
 *  @param block    解析更改内容的block
 *  @param message 制定的消息类型
 */
- (void) addDecodeNotificationBlock:(DZDecodeNotificationBlock)block forMessage:(NSString*)message;
/**
 *  通过消息类型添加观察泽
 *
 *  @param observer 观察者
 *  @param key      特定的消息类型
 */
- (void) addObserver:(id)observer forKey:(NSString*)key;
/**
 *  注销观察者
 *
 *  @param observer 需要注销的观察者
 */
- (void) removeObserver:(id)observer;
/**
 *  通过消息类型注销观察者
 *
 *  @param observer 需要注销的观察者
 *  @param key      制定的消息类型
 */
- (void) removeObserver:(NSObject *)observer forMessage:(NSString*)key;
/**
 *  发送特定类型的消息通知，以通知client的变化
 *
 *  @param message  特定的消息类型
 *  @param userInfo 更改的内容
 */
- (void) postMessage:(NSString*)message userInfo:(NSDictionary*)userInfo;
@end
