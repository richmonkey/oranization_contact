//
//  APIRequest.h
//  Message
//
//  Created by houxh on 14-7-26.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TAHttpOperation.h"

@interface APIRequest : NSObject

+(TAHttpOperation*)requestVerifyCode:(NSString*)zone number:(NSString*)number
                             success:(void (^)(NSString* code))success fail:(void (^)())fail;

+(TAHttpOperation*)requestAuthToken:(NSString*)code zone:(NSString*)zone number:(NSString*)number deviceToken:(NSString*)deviceToken
                            success:(void (^)(NSString* accessToken, NSString *refreshToken, int expireTimestamp, NSArray *orgs))success
                               fail:(void (^)())fail;

+(TAHttpOperation*)refreshAccessToken:(NSString*)refreshToken
                              success:(void (^)(NSString *accessToken, NSString *refreshToken, int expireTimestamp))success
                                 fail:(void (^)())fail;

+(TAHttpOperation*)loginOrganization:(int64_t)orgID
                            success:(void (^)(int64_t uid, NSString *name, NSString *gobelieveToken))success
                                fail:(void(^)())fail;

+(TAHttpOperation*)getOrganizations:(void(^)(NSArray *orgs))success fail:(void(^)())fail;

@end
