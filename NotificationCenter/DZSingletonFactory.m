//
//  DZSingletonFactory.m
//  TimeUI
//
//  Created by Stone Dong on 13-12-12.
//  Copyright (c) 2013年 Stone Dong. All rights reserved.
//

#import "DZSingletonFactory.h"
@interface DZSingletonFactory()
{
    NSMutableDictionary* data;
}
@end

@implementation DZSingletonFactory
- (id) init
{
    self = [super init];
    if (self) {
        data = [[NSMutableDictionary alloc] init];
    }
    return self;
}

+ (DZSingletonFactory*) shareFactory
{
    static DZSingletonFactory* share = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        share = [[DZSingletonFactory alloc] init];
    });
    return share;
}

- (id) copyWithZone:(NSZone*)zone
{
    return self;
}
//over singlong

- (void) setShareData:(id)shareData  forKey:(NSString*)key
{
        if (shareData == nil) {
            return;
        }
        [data setObject:shareData forKey:key];
}

- (id) shareDataForKey:(NSString*)key
{
        return [data objectForKey:key];
}

- (id) shareInstanceFor:(Class)aclass
{
    NSString* className = [NSString stringWithFormat:@"%@",aclass];
     @synchronized(className)
    {
        id shareData = [self shareDataForKey:className];
        if (shareData == nil) {
            shareData = [[NSClassFromString(className) alloc] init];
            [self setShareData:shareData forKey:className];
        }
        return shareData;
    }
    
}

- (id) shareInstanceFor:(Class)aclass category:(NSString *)key
{
    NSString* className = [NSString stringWithFormat:@"%@",aclass];
    NSString* classKey = [NSString stringWithFormat:@"%@-%@",aclass,key];
    @synchronized(classKey)
    {
        id shareData = [self shareDataForKey:classKey];
        if (shareData == nil) {
            shareData = [[NSClassFromString(className) alloc] init];
            [self setShareData:shareData forKey:classKey];
        }
        return shareData;
    }
}

@end

id  DZSingleForClass(Class a)
{
    return [DZShareSingleFactory shareInstanceFor:a];
}