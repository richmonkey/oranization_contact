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
#import "MMUapRequest.h"
#import "MMCommonAPI.h"


@implementation MMContactSync
@synthesize addedCount, updatedCount, deletedCout;

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



-(BOOL)downloadContactToMomo:(NSArray*)simpleList contacts:(NSMutableArray*)contacts {
	NSMutableArray *idsToDown = [NSMutableArray array];
	NSMutableArray *contactsToUpdate = [NSMutableArray array];
	
    //需要下载的联系人列表
	for (MMMomoContactSimple *c in simpleList) {
		int index = [contacts indexOfObjectPassingTest:^(id obj, NSUInteger idx, BOOL *stop){
			DbContactSyncInfo *info = (DbContactSyncInfo*)obj;
			if(info.contactId == c.contactId)
				return YES;
			return NO;
		}];
		
		if (NSNotFound == index) {
			[idsToDown addObject:[NSNumber numberWithLongLong:c.contactId]];
		} else {
			DbContactSyncInfo *info = [contacts objectAtIndex:index];
			if (c.modifyDate > info.modifyDate ) {
				[idsToDown addObject:[NSNumber numberWithLongLong:c.contactId]];
				[contactsToUpdate addObject:info];
			}
			[contacts removeObjectAtIndex:index];
		}
	}
	
    //需要删除本地的列表
    if (contacts.count > 0) {
        [[self db] beginTransaction];
        for (MMMomoContactSimple *c in contacts) {
            [[MMContactManager instance] deleteContact:c.contactId];
            self.deletedCout = self.deletedCout + 1;
        }
        [[self db] commitTransaction];
    }
    
    
    NSMutableArray* downloadedContacts = [NSMutableArray array];
    for (unsigned int i = 0; i < [idsToDown count]; i+= 50) {
		int len = MIN(50, [idsToDown count] - i);
		NSArray *array = [MMServerContactManager getContactList:[idsToDown subarrayWithRange:NSMakeRange(i, len)]];
        if (nil == array) {
            break;
        }
        [downloadedContacts addObjectsFromArray:array];
        
        [[self db] beginTransaction];
        for (MMMomoContact *contact in array ){
            int index = [contactsToUpdate indexOfObjectPassingTest:^(id obj, NSUInteger idx, BOOL *stop){
                DbContactSimple *info = (DbContactSimple*)obj;
                if(info.contactId == contact.contactId)
                    return YES;
                return NO;
            }];
            if (self.isCancelled) {
                break;
            }
            if (NSNotFound == index) {
                self.addedCount = self.addedCount + 1;
                if ([[MMContactManager instance] insertContact:contact withDataList:contact.properties] != MM_DB_OK) {
                    MLOG(@"insert contact fail, contact id:%lld", contact.contactId);
                }
                
                
            } else {
                self.updatedCount = self.updatedCount + 1;
                if ([[MMContactManager instance] updateContact:contact withDataList:contact.properties] != MM_DB_OK) {
                    MLOG(@"update contact fail contact id:%lld", contact.contactId);
                }
            }
            
        }
        [[self db] commitTransaction];
        
        if (self.isCancelled) {
            return NO;
        }
	}
    
    if (idsToDown.count > downloadedContacts.count) {
        return NO;
    }
    
    if (self.isCancelled) {
        return NO;
    }
    
	return YES;
}

-(BOOL) downloadContactToMomo {
    self.addedCount = 0;
    self.updatedCount = 0;
    self.deletedCout = 0;
    
    
	NSArray *tmp = [[MMContactManager instance] getContactSyncInfoList:nil];
	NSMutableArray *syncInfos = [NSMutableArray arrayWithArray:tmp];
	NSArray *simpleList = [MMServerContactManager getSimpleContactList];
	if (nil == simpleList) {
		return NO;
	}
    
    //从服务器返回的数据为空,
    if (simpleList.count == 0) {
        NSLog(@"server db is empty");
    }
    
	return [self downloadContactToMomo:simpleList contacts:syncInfos];
}



@end
