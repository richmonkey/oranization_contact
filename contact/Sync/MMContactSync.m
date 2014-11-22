//
//  MMContactSync.m
//  momo
//
//  Created by houxh on 11-7-5.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MMContactSync.h"
#import "MMUapRequest.h"
#import "DbStruct.h"
#import <AddressBook/AddressBook.h>
#import "SBJSON.h"
#import "MMServerContactManager.h"
#import "MMLogger.h"
#import "MMContact.h"
#import "MMGlobalDefine.h"


@implementation MMContactSync


-(id)init {
	self = [super init];
	if (self) {

	}
	return self;
}
-(void)dealloc {
	[super dealloc];
}

-(BOOL) isCancelled {
	MMThread *thread = [MMThread currentThread];
	MMHttpRequestThread *requestThread = nil;
	
	if ([thread isKindOfClass:[MMHttpRequestThread class]]) {
		requestThread = (MMHttpRequestThread*)thread;
	}

	return requestThread.isCancelled;
}


@end
