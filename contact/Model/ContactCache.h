//
//  ContactCache.h
//  contact
//
//  Created by houxh on 16/1/6.
//  Copyright © 2016年 momo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ContactCache : NSObject
+(ContactCache*)instance;

@property(nonatomic) NSArray *contacts;

@end
