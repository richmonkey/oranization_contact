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

+ (void)dial:(NSString *)numberStr;

+ (void)sendMessage:(NSString *)numberStr;
+ (void)sendEmail:(NSString *)numberStr;

+ (void)showFailAlertViewTitle:(NSString*) title andMessage:(NSString*)message;

+ (NSDate*) getDateBySting:(NSString*)stringDate;
+ (NSString*) getStringByDate:(NSDate*)date byFormatter:(NSString *)stringFormatter;
+ (NSString*) getStingByDate:(NSDate*)date;

+ (NSString*)getDateString:(NSDate*)date;

+ (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize;

+ (UIImage*)scaleAndRotateImage:(UIImage *)image  scaleSize:(NSInteger)scaleSize;
+ (UIImage*)rotateImage:(UIImage*)image;
+ (BOOL)isNetworkReachable;

+ (NetworkStatus)getNetworkStatus;

+ (NSString*)createGUIDStr;

+ (NSString*)temporaryURLHost;

+ (NSString*)originalImageURL:(NSString*)smallImageURL;

+ (void)alert:(NSString *)message;

//判断该字符串的首字母是否 不为特殊字符
+ (BOOL) isNoSpecialChar:(NSString *)str;
+ (NSString*)getStringFirstLetter:(NSString *)str;

+ (void)checkDirectoryExist;	//程序启动时检测相关文件夹是否创建

+ (CGRect)properRectForButton:(UIButton*)button maxSize:(CGSize)maxSize;

+ (NSInteger)countWord:(NSString*)text;

+ (NSArray*)sortArrayByAbbr:(NSArray*)objectArray key:(NSString*)key;

+ (NSString*)getDetailURL:(NSUInteger)typeId applicationId:(uint64_t)appId;
+ (NSString*)getLongTextURL:(NSString*)statusId;
+ (NSString*)getIMLongTextURL:(NSString*)msdId;

+(NSString *)changeToValidNumber:(NSString*)mobile;
+ (BOOL)isValidTelNumber:(NSString*)mobile;

+ (BOOL)isJailBreakDevice;

+ (float)getAppFloatVersion;

+ (void)waitHTTPThreadsQuit:(NSMutableArray*)backgroundThreads;

+ (NSString*)avatarUrlBySmallAvatarUrl:(NSString*)smallAvatarUrl desireSize:(NSInteger)desireSize;

//代替UIDevice的unique identifier
+ (NSString*)deviceId;

+ (NSString*)computeKCode:(double)longitude latitude:(double)latitude;

+ (NSArray* )sortIntArray:(NSArray*)array;


@end
