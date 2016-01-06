//
//  ContactCache.m
//  contact
//
//  Created by houxh on 16/1/6.
//  Copyright © 2016年 momo. All rights reserved.
//

#import "ContactCache.h"

@implementation ContactCache
+(ContactCache*)instance {
    static ContactCache *cache;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!cache) {
            cache = [[ContactCache alloc] init];
        }
    });
    return cache;
}
@end
