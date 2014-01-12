//
//  DZNotificationCenter.m
//  TimeUI
//
//  Created by Stone Dong on 13-12-15.
//  Copyright (c) 2013年 Stone Dong. All rights reserved.
//

#import "DZNotificationCenter.h"
#import "DZSingletonFactory.h"
#import "DZSendSelector.h"
#import <set>
#import <map>
using namespace std;

typedef set<void*> DZPointerSet;
typedef map<NSString*, DZPointerSet> DZObserverMap;
@interface DZNotificationCenter ()
{
    DZObserverMap _notificationMaps;
    NSMutableDictionary* _decodeBlocksMap;
}
@end

@implementation DZNotificationCenter

+ (DZNotificationCenter*) defaultCenter
{
    return DZSingleForClass([DZNotificationCenter class]);
}

- (void) addDecodeNotificationBlock:(DZDecodeNotificationBlock)block forMessage:(NSString*)message
{
    _decodeBlocksMap[message] = block;
}

- (instancetype) init
{
    self = [super init];
    if (!self) {
        return self;
    }
    _decodeBlocksMap = [NSMutableDictionary new];
    return self;
}

- (DZPointerSet* ) observersArrayByKey:(NSString*)key
{
    DZObserverMap::iterator itor = _notificationMaps.find(key);
    if (itor == _notificationMaps.end()) {
        DZPointerSet set;
        _notificationMaps.insert(pair<NSString*, DZPointerSet>(key, set));
        DZObserverMap::iterator it = _notificationMaps.find(key);
        return &(it->second);
    }
    else
    {
        return &(itor->second);
    }
}

- (void) removeObserver:(NSObject *)observer forMessage:(NSString*)key
{
    DZPointerSet* set  = [self observersArrayByKey:key];
    DZPointerSet::iterator ereaseItor = set->end();
    for (DZPointerSet::iterator itor = set->begin(); itor != set->end(); itor++) {
        id ob = (__bridge id)*itor;
        if (ob == observer) {
            ereaseItor = itor;
            break;
        }
    }
    if (ereaseItor != set->end()) {
        set->erase(ereaseItor);
    }
}
- (void) removeObserver:(id)observer
{
    for (DZObserverMap::iterator itor = _notificationMaps.begin(); itor != _notificationMaps.end(); itor++) {
        DZPointerSet* set = &itor->second;
        DZPointerSet::iterator ereaseItor = set->end();
        for (DZPointerSet::iterator sitor = set->begin(); sitor != set->end(); sitor++) {
            id ob = (__bridge id)*sitor;
            if (ob == observer) {
                ereaseItor = sitor;
                break;
            }
        }
        if (ereaseItor != set->end()) {
            set->erase(ereaseItor);
        }
    }
}

- (void) addObserver:(id)observer forKey:(NSString*)key
{
    DZPointerSet* set  = [self observersArrayByKey:key];
    DZPointerSet::iterator itor = set->find((__bridge void*)observer);
    if (itor == set->end()) {
        set->insert((__bridge void*)observer);
    }
}

- (void) postMessage:(NSString*)message userInfo:(NSDictionary*)userInfo
{
    DZPointerSet* set = [self observersArrayByKey:message];
    DZDecodeNotificationBlock block = _decodeBlocksMap[message];
    if (!block) {
        if ([_delegate respondsToSelector:@selector(decodeNotification:forCenter:)]) {
            _decodeBlocksMap[message] = block;
        }
    }
    NSCAssert(block, @"decode blcok for %@ is nil", message);
    __block NSMutableArray* params = nil;
    SEL selector = block(userInfo, &params);
    if (!selector  || !params) {
        return;
    }
    for (DZPointerSet::iterator itor = set->begin(); itor != set->end(); itor++) {
        __strong id observer = (__bridge id)*itor;
        SendSelectorToObjectInMainThreadWithParams(selector, observer, params);
    }
}


@end
