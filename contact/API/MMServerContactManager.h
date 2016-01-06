//
//  MMServerContactManager.h
//  momo
//
//  Created by houxh on 11-7-6.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DbStruct.h"
#import "MMModel.h"


typedef MMFullContact MMMomoContact;
typedef DbContactSyncInfo MMMomoContactSimple;

@interface MMServerContactManager : NSObject {

}

+(NSArray*)getSimpleContactList;
+(NSArray*)getContactList:(NSArray*)ids;


+(NSDictionary*)encodeContact:(MMFullContact *)contact;
+(MMMomoContact*)decodeContact:(NSDictionary*)dic;

@end
