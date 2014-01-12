//
//  DZSingletonFactory.h
//  TimeUI
//
//  Created by Stone Dong on 13-12-12.
//  Copyright (c) 2013年 Stone Dong. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 * 一句话实现单例 ，嘿嘿
 *
 */
#define DZShareSingleFactory [DZSingletonFactory shareFactory]

#ifdef __cplusplus
extern "C" {
#endif
    id  DZSingleForClass(Class a);
#ifdef __cplusplus
}
#endif
/**
 *  单例工厂
 */
@interface DZSingletonFactory : NSObject

+ (DZSingletonFactory*) shareFactory;

- (id) shareInstanceFor:(Class)aclass;
- (id) shareInstanceFor:(Class)aclass category:(NSString*)key;
@end
