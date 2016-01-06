/*
 *  MMUapRequest.h
 *  libSync
 *
 *  Created by aminby on 2010-6-24.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _MMUAPREQUEST_H_
#define _MMUAPREQUEST_H_

#import "ASIHTTPRequest.h"
#include "MMRequest.h"
#import "MMThread.h"
#import "MMGlobalDefine.h"

#define STATUS @"status"


@interface MMRequest : NSObject
{
}


+ (MMRequest*)shareInstance;


/**************************************** 可以提为公用函数 ****************************************/
/*
 * 同步发起HTTP POST请求
 * 
 * @param source: 请求资源
 * @param object: 请求参数
 * @param sid: Session ID
 *
 * @return: JSON转化成的结构
 */
+(NSDictionary*)postSync:(NSString*)source withObject:(NSObject*)object;
+(NSInteger)postSync:(NSString *)source withObject:(NSObject *)object responseData:(NSData**)response;
+(NSInteger)postSync:(NSString *)source withObject:(NSObject *)object responseString:(NSString**)response;
+(NSInteger)postSync:(NSString *)source withObject:(NSObject *)object jsonValue:(id*)value;
+(NSInteger)responseError:(NSDictionary*)response;


/*
 * 同步发起HTTP GET请求
 * 
 * @param source: 请求资源
 * @param sid: Session ID
 *
 * @return: JSON转化成的结构
 */
+(NSDictionary*)getSync:(NSString*)source compress:(BOOL)isCompress;
+(NSInteger)getSync:(NSString*)source jsonValue:(id*)value compress:(BOOL)isCompress;
+(NSInteger)getSync:(NSString*)source responseData:(NSData**)response compress:(BOOL)isCompress;
+(NSInteger)getSync:(NSString*)source responseString:(NSString**)response compress:(BOOL)isCompress;

@end

@interface ASIHTTPRequest(MMHttpRequest)

+ (id)requestWithPath:(NSString*)path;
+ (id)requestWithPath:(NSString *)path usingSSL:(BOOL)usingSSL;
+ (id)requestWithPath:(NSString*)path withObject:(NSObject*)object;
+ (id)requestWithPath:(NSString*)path withObject:(NSObject*)object usingSSL:(BOOL)usingSSL;
- (id)responseObject;
- (NSInteger)responseError;
+ (void)startSynchronous:(ASIHTTPRequest*)request;

@end

//http sync request
@interface MMHttpRequestThread : MMThread {
	ASIHTTPRequest *request_;
}
@property(retain) ASIHTTPRequest *request;

@end

#endif