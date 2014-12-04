//
//  NGAddition.m
//  contact
//
//  Created by Coffee on 14/11/30.
//  Copyright (c) 2014年 momo. All rights reserved.
//

#import "NGAddition.h"
#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Either turn on ARC for the project or use -fobjc-arc flag
#endif

@implementation NGAddition

@end

@implementation NSString (Check)

- (BOOL)isEmpty {
    NSString *temp = [self stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([temp length]) {
        return NO;
    }else {
        return YES;
    }
}

@end