/*
 *  MMUapRequest.cpp
 *  libSync
 *
 *  Created by aminby on 2010-6-24.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#import "MMRequest.h"
#import <CommonCrypto/CommonDigest.h>
#import "json.h"
#import "DbStruct.h"
#import "MMCommonAPI.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "Token.h"

@implementation MMRequest
+ (MMRequest*)shareInstance {
    static MMRequest* instance = nil;
    if(!instance) {
        @synchronized(self) {
            if(!instance) {
                instance = [[MMRequest alloc] init];
            }
        }
    }
    return instance;
}

+(NSInteger)postSync:(NSString *)source withObject:(NSObject *)object responseData:(NSData**)response {
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithPath:source withObject:object];
    [ASIHTTPRequest startSynchronous:request];
    *response = [request responseData];
    [[*response retain] autorelease];
    return [request responseStatusCode];
}

+(NSInteger)postSync:(NSString *)source withObject:(NSObject *)object responseString:(NSString**)response {
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithPath:source withObject:object];
    [ASIHTTPRequest startSynchronous:request];
    *response = [request responseString];
    [[*response retain] autorelease];
    return [request responseStatusCode];
}

+(NSInteger)postSync:(NSString *)source withObject:(NSObject *)object jsonValue:(id*)response {
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithPath:source withObject:object];
    [ASIHTTPRequest startSynchronous:request];
    *response = [request responseObject];
    [[*response retain] autorelease];
    return [request responseStatusCode];
}

// 发送POST请求
+(NSDictionary*)postSync:(NSString*)source withObject:(NSDictionary*)object{
    NSDictionary *ret = nil;
    int statusCode = [self postSync:source withObject:object jsonValue:&ret];
    if (!ret) {
        ret = [NSMutableDictionary dictionary];
    }

    if ([ret isKindOfClass:[NSDictionary class]]) {
        [ret setValue:[NSNumber numberWithInt:statusCode] forKey:STATUS];
    }

    return ret;
}

+(NSInteger)responseError:(NSDictionary*)response {
    NSString *error = [response objectForKey:@"error"];
    if ([error length] < 6) {
        return 0;
    }
    error = [error substringToIndex:6];
    return [error intValue];
}


+(NSInteger)getSync:(NSString*)source responseData:(NSData**)response compress:(BOOL)isCompress{
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithPath:source];
    if (isCompress) {
        [request setAllowCompressedResponse:YES];
    }
    [ASIHTTPRequest startSynchronous:request];
    *response = [request responseData];
    [[*response retain] autorelease];
    return [request responseStatusCode];
}

+(NSInteger)getSync:(NSString*)source responseData:(NSData**)response{
    return [self getSync:source responseData:response compress:NO];
}

+(NSInteger)getSync:(NSString*)source jsonValue:(id*)value compress:(BOOL)isCompress{
    NSString *response = nil;
    int statusCode = [self getSync:source responseString:&response compress:isCompress];
    id ret = nil;
    switch (statusCode) {
        case 200:
        case 400:
        {
            ret = [response JSONValue];
        }
            break;
        default:
            break;
    }
    *value = ret;
    return statusCode;
}

+(NSInteger)getSync:(NSString*)source responseString:(NSString**)response compress:(BOOL)isCompress{
    NSData *responseData = nil;
    int statusCode = [self getSync:source responseData:&responseData compress:isCompress];
    if (responseData) {
        *response = [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease];
    }
    return statusCode;
}
// 发送GET请求
+(NSDictionary*)getSync:(NSString*)source withSID:(NSString*)sid compress:(BOOL)isCompress{
    NSDictionary *ret = nil;
    NSInteger statusCode = [self getSync:source jsonValue:&ret compress:isCompress];
    if (!ret) {
        ret = [NSMutableDictionary dictionary];
    }

    if ([ret isKindOfClass:[NSDictionary class]]) {
        [ret setValue:[NSNumber numberWithInt:statusCode] forKey:STATUS];
    }

    return ret;
}

+(NSDictionary*)getSync:(NSString*)source compress:(BOOL)isCompress{
    return [self getSync:source withSID:nil compress:isCompress];
}

@end

@implementation MMHttpRequestThread
@synthesize request = request_;

-(void)dealloc {
    self.request = nil;
    [super dealloc];
}

- (void)start {
    //thread对象多次start
    self.request = nil;
    cancelled_ = NO;
    [super start];
}

-(void)main {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [super main];
    self.request = nil;
    [pool release];
}
-(void)cancel {
    [super cancel];
    [self.request cancel];
}

@end

@implementation ASIHTTPRequest(MMHttpRequest)

+ (id)requestWithPath:(NSString *)path usingSSL:(BOOL)usingSSL {
    NSString* fullUrl = nil;
    fullUrl = [API_URL stringByAppendingFormat:@"/%@",path];
    NSURL*url = [NSURL URLWithString:fullUrl];

    ASIHTTPRequest* request = [self requestWithURL:url];
    request.timeOutSeconds = HTTP_REQUEST_TIME_OUT_SECONDS;

    NSString *auth = [NSString stringWithFormat:@"Bearer %@", [Token instance].accessToken];
    [request addRequestHeader:@"Authorization" value:auth];

    [request setRequestMethod:@"GET"];

    return request;
}

+(id)requestWithPath:(NSString*)path {
    return [self requestWithPath:path usingSSL:NO];
}

+ (id)requestWithPath:(NSString*)path withObject:(NSObject*)object usingSSL:(BOOL)usingSSL {
    NSString* fullUrl = nil;
    fullUrl = [API_URL stringByAppendingFormat:@"/%@",path];
    NSURL* url = [NSURL URLWithString:fullUrl];

    ASIHTTPRequest* request = [self requestWithURL:url];
    request.timeOutSeconds = HTTP_REQUEST_TIME_OUT_SECONDS;
    [request setRequestMethod:@"POST"];
    [request addRequestHeader:@"Content-Type" value:@"application/json"];

    NSString *auth = [NSString stringWithFormat:@"Bearer %@", [Token instance].accessToken];
    [request addRequestHeader:@"Authorization" value:auth];

    // post body
    if (object != nil) {
        SBJSON* sbjson = [[SBJSON alloc] init];
        NSString* json = [sbjson stringWithObject:object];
        [request setPostBody:[NSMutableData dataWithData:[json dataUsingEncoding:NSUTF8StringEncoding]]];
        [sbjson release];
    }
    return request;
}

+(id)requestWithPath:(NSString*)path withObject:(NSObject*)object {
    return [self requestWithPath:path withObject:object usingSSL:NO];
}


+ (void)startSynchronous:(ASIHTTPRequest*)request {
    MMThread *thread = [MMThread currentThread];
    MMHttpRequestThread *requestThread = nil;

    NSThread *nsthread = [NSThread currentThread];
    NSDictionary *userinfo = [NSDictionary dictionaryWithObject:nsthread forKey:@"thread"];
    request.userInfo = userinfo;

    if ([thread isKindOfClass:[MMHttpRequestThread class]]) {
        requestThread = (MMHttpRequestThread*)thread;
    }
    
    requestThread.request = request;
    if (thread.isCancelled) {
        return;
    }
    [request startSynchronous];
}


-(id)responseObject {
    NSString *response = [self responseString];
    if ([self responseStatusCode] != 200) {
        NSLog(@"response:%@", response);
    }
    SBJSON* sbjson = [[[SBJSON alloc] init] autorelease];
    if (response.length == 0) {
        return nil;
    }
    return [sbjson objectWithString:response];
}

- (NSInteger)responseError {
    if ([self responseStatusCode] == 200) 
        return 0;
    return [MMRequest responseError:[self responseObject]];
}

@end


