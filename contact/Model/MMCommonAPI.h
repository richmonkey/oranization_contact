//
//  MMCommonAPI.h
//  momo
//
//  Created by mfm on 7/24/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DbStruct.h"
#import "ErrorType.h"
#import "Reachability.h"

@class MMWebViewController;
@interface MMCommonAPI : NSObject {

}

+ (NSDate*) getDateBySting:(NSString*)stringDate;
+ (NSString*) getStringByDate:(NSDate*)date byFormatter:(NSString *)stringFormatter;
+ (NSString*) getStingByDate:(NSDate*)date;

+ (void)alert:(NSString *)message;

//判断该字符串的首字母是否 不为特殊字符
+ (BOOL)isNoSpecialChar:(NSString *)str;
+ (NSString*)getStringFirstLetter:(NSString *)str;



@end
