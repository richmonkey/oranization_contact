//
//  APIRequest.m
//  Message
//
//  Created by houxh on 14-7-26.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import "APIRequest.h"
#import "MMGlobalDefine.h"
#import "Token.h"
#import "Organization.h"

@implementation APIRequest
//企业通讯录
+(TAHttpOperation*)requestVerifyCode:(NSString*)zone number:(NSString*)number
                              success:(void (^)(NSString* code))success fail:(void (^)())fail{
    TAHttpOperation *request = [TAHttpOperation httpOperationWithTimeoutInterval:60];
    request.targetURL = [API_URL stringByAppendingFormat:@"/auth/verify_code?zone=%@&number=%@", zone, number];
    request.method = @"POST";
    request.successCB = ^(TAHttpOperation*commObj, NSURLResponse *response, NSData *data) {
        NSInteger statusCode = [(NSHTTPURLResponse*)response statusCode];
        if (statusCode != 200) {
            fail();
            return;
        }
        NSDictionary *resp = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        NSString *code = [resp objectForKey:@"code"];
        success(code);
    };
    request.failCB = ^(TAHttpOperation*commObj, TAHttpOperationError error) {
        fail();
    };
    [[NSOperationQueue mainQueue] addOperation:request];
    return request;
}


+(TAHttpOperation*)requestAuthToken:(NSString*)code zone:(NSString*)zone number:(NSString*)number deviceToken:(NSString*)deviceToken
                            success:(void (^)(NSString* accessToken, NSString *refreshToken, int expireTimestamp, NSArray *orgs))success
                               fail:(void (^)())fail {
    TAHttpOperation *request = [TAHttpOperation httpOperationWithTimeoutInterval:60];
    request.targetURL = [API_URL stringByAppendingString:@"/auth/token"];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:code forKey:@"code"];
    [dict setObject:zone forKey:@"zone"];
    [dict setObject:number forKey:@"number"];
    if (deviceToken) {
        [dict setObject:deviceToken forKey:@"apns_device_token"];
    }

    NSDictionary *headers = [NSDictionary dictionaryWithObject:@"application/json" forKey:@"Content-Type"];
    request.headers = headers;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    request.postBody = data;
    request.method = @"POST";
    request.successCB = ^(TAHttpOperation*commObj, NSURLResponse *response, NSData *data) {
        NSInteger statusCode = [(NSHTTPURLResponse*)response statusCode];
        if (statusCode != 200) {
            fail();
            return;
        }
        NSDictionary *resp = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
     
        NSString *accessToken = [resp objectForKey:@"access_token"];
        NSString *refreshToken = [resp objectForKey:@"refresh_token"];
        int expireTimestamp = (int)time(NULL) + [[resp objectForKey:@"expires_in"] intValue];
        NSArray *orgs = [resp objectForKey:@"organizations"];
        success(accessToken, refreshToken, expireTimestamp, orgs);
    };
    request.failCB = ^(TAHttpOperation*commObj, TAHttpOperationError error) {
        fail();
    };
    [[NSOperationQueue mainQueue] addOperation:request];
    return request;
}

+(TAHttpOperation*)refreshAccessToken:(NSString*)refreshToken
                              success:(void (^)(NSString *accessToken, NSString *refreshToken, int expireTimestamp))success
                                 fail:(void (^)())fail{
    TAHttpOperation *request = [TAHttpOperation httpOperationWithTimeoutInterval:60];
    request.targetURL = [API_URL stringByAppendingString:@"/auth/refresh_token"];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:refreshToken forKey:@"refresh_token"];
    NSDictionary *headers = [NSDictionary dictionaryWithObject:@"application/json" forKey:@"Content-Type"];
    request.headers = headers;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    request.postBody = data;
    request.method = @"POST";
    request.successCB = ^(TAHttpOperation*commObj, NSURLResponse *response, NSData *data) {
        int statusCode = (int)[(NSHTTPURLResponse*)response statusCode];
        if (statusCode != 200) {
            NSDictionary *e = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            NSLog(@"refresh token fail:%@", e);
            fail();
            return;
        }
        NSDictionary *resp = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        NSString *accessToken = [resp objectForKey:@"access_token"];
        NSString *refreshToken = [resp objectForKey:@"refresh_token"];
        int expireTimestamp = (int)time(NULL) + [[resp objectForKey:@"expires_in"] intValue];
        success(accessToken, refreshToken, expireTimestamp);
    };
    request.failCB = ^(TAHttpOperation*commObj, TAHttpOperationError error) {
        fail();
    };
    [[NSOperationQueue mainQueue] addOperation:request];
    return request;
}

+(TAHttpOperation*)loginOrganization:(int64_t)orgID
                             success:(void (^)(int64_t uid, NSString *name, NSString *gobelieveToken))success
                                fail:(void(^)())fail {
    
    
    NSMutableDictionary *headers = [NSMutableDictionary dictionaryWithObject:@"application/json" forKey:@"Content-Type"];
    NSString *auth = [NSString stringWithFormat:@"Bearer %@", [Token instance].accessToken];
    [headers setObject:auth forKey:@"Authorization"];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[NSNumber numberWithLongLong:orgID] forKey:@"org_id"];
    
    TAHttpOperation *request = [APIRequest requestWithPath:@"/member/login_organization" withObject:dict withHeaders:headers];
    
    request.successCB = ^(TAHttpOperation*commObj, NSURLResponse *response, NSData *data) {
        int statusCode = (int)[(NSHTTPURLResponse*)response statusCode];
        if (statusCode != 200) {
            NSDictionary *e = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            NSLog(@"refresh token fail:%@", e);
            fail();
            return;
        }
        NSDictionary *resp = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        NSString *gobelieveToken = [resp objectForKey:@"gobelieve_token"];
        NSString *name = [resp objectForKey:@"name"];
        int64_t uid = [[resp objectForKey:@"id"] longLongValue];
        success(uid, name, gobelieveToken);
    };
    request.failCB = ^(TAHttpOperation*commObj, TAHttpOperationError error) {
        fail();
    };
    [[NSOperationQueue mainQueue] addOperation:request];
    return request;
}

+(TAHttpOperation*)requestWithPath:(NSString*)path withObject:(NSDictionary*)dict withHeaders:(NSDictionary*)headers {
    
    TAHttpOperation *request = [TAHttpOperation httpOperationWithTimeoutInterval:60];
    request.targetURL = [API_URL stringByAppendingString:path];
    request.headers = headers;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    request.postBody = data;
    request.method = @"POST";
    
    return request;
    
}

+(TAHttpOperation*)requestWithPath:(NSString*)path withHeaders:(NSDictionary*)headers {
    
    TAHttpOperation *request = [TAHttpOperation httpOperationWithTimeoutInterval:60];
    request.targetURL = [API_URL stringByAppendingString:path];
    request.headers = headers;
    request.method = @"GET";
    
    return request;
    
}

+(TAHttpOperation*)getOrganizations:(void(^)(NSArray *orgs))success fail:(void(^)())fail {
    NSMutableDictionary *headers = [NSMutableDictionary dictionaryWithObject:@"application/json" forKey:@"Content-Type"];
    NSString *auth = [NSString stringWithFormat:@"Bearer %@", [Token instance].accessToken];
    [headers setObject:auth forKey:@"Authorization"];
    
    TAHttpOperation *request = [APIRequest requestWithPath:@"/member/organizations" withHeaders:headers];
    
    request.successCB = ^(TAHttpOperation*commObj, NSURLResponse *response, NSData *data) {
        int statusCode = (int)[(NSHTTPURLResponse*)response statusCode];
        if (statusCode != 200) {
            NSDictionary *e = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            NSLog(@"refresh token fail:%@", e);
            fail();
            return;
        }
        
        NSMutableArray *orgs = [NSMutableArray array];
        NSDictionary *resp = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        NSArray *array = [resp objectForKey:@"organizations"];
        for (NSDictionary *obj in array) {
            Organization *org = [[Organization alloc] init];
            org.ID = [[obj objectForKey:@"id"] longLongValue];
            org.name = [obj objectForKey:@"name"];
            [orgs addObject:org];
        }
        success(orgs);
    };
    
    request.failCB = ^(TAHttpOperation*commObj, TAHttpOperationError error) {
        fail();
    };
    
    [[NSOperationQueue mainQueue] addOperation:request];
    return request;

    

}
@end
