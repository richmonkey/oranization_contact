//
//  MMSyncContact.m
//  momo
//
//  Created by houxh on 11-7-6.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import "MMContactSync.h"
#import "MMUapRequest.h"
#import "DbStruct.h"
#import <AddressBook/AddressBook.h>
#import "SBJSON.h"
#import "MMServerContactManager.h"
#import "MMContact.h"
#import "MMLogger.h"
#import "MMCommonAPI.h"
#import "MMSyncThread.h"

@interface MMContactSyncInfo : DbContactId
{
	NSInteger phoneContactId;
	int64_t modifyDate;
	int64_t phoneModifyDate;
	NSString *avatarUrl;
	NSData *avatarPart;
	NSString *avatarMd5;

}
@property(nonatomic)NSInteger phoneContactId;
@property(nonatomic)int64_t modifyDate;
@property(nonatomic)int64_t phoneModifyDate;
@property(nonatomic, copy)NSString *avatarUrl;
@property(nonatomic, retain)NSData *avatarPart;
@property(nonatomic, copy)NSString *avatarMd5;


-(id)initWithResultSet:(id<PLResultSet>)results;

@end

@implementation MMContactSyncInfo
@synthesize phoneContactId, modifyDate, phoneModifyDate, avatarUrl, avatarPart, avatarMd5;

-(id)initWithResultSet:(id<PLResultSet>)results {
	self = [super init];
	if (self) {
		self.contactId = [results intForColumn:@"contact_id"];
		self.phoneContactId = [results intForColumn:@"phone_contact_id"];
		self.modifyDate = [results bigIntForColumn:@"modify_date"];
		self.phoneModifyDate = [results bigIntForColumn:@"phone_modify_date"];
		if (![results isNullForColumn:@"avatar_url"]) {
			self.avatarUrl = [results stringForColumn:@"avatar_url"];
		} else {
			self.avatarUrl = @"";
		}

		if (![results isNullForColumn:@"avatar_part"]) {
			self.avatarPart = [results dataForColumn:@"avatar_part"];
		}
		if (![results isNullForColumn:@"avatar_md5"]) {
			self.avatarMd5 = [results stringForColumn:@"avatar_md5"];
		}


	}
	return self;
}

-(void)dealloc {

	[avatarUrl release];
	[avatarPart release];
	[avatarMd5 release];
	[super dealloc];
}

@end


@implementation MMContactSync(Contact)

-(NSMutableArray*)getContactSyncInfoList:(NSArray*)ids {
	NSString* strContactIds = [ids componentsJoinedByString:@", "];
	
	NSMutableArray *array = [NSMutableArray array];
	NSError *outError = nil;
	NSString* sql = [NSString stringWithFormat:@"select * from contact_sync where contact_id in (%@)", strContactIds];
	id<PLResultSet> results = [[self db]  executeQueryAndReturnError:&outError statement:sql];
	
	if(SQLITE_OK != [outError code]) {
		return nil;
	}
	PLResultSetStatus status = [results nextAndReturnError:nil];
	while (status) {
		MMContactSyncInfo *info = [[[MMContactSyncInfo alloc] initWithResultSet:results] autorelease];
		[array addObject:info];
		status = [results nextAndReturnError:nil];
	}
	[results close];
	return array;
}
-(MMContactSyncInfo*)getContactSyncInfo:(NSInteger)contactId {
	NSMutableArray *array = [self getContactSyncInfoList:[NSArray arrayWithObject:[NSNumber numberWithInt:contactId]]];
	if ([array count] == 0) {
		return nil;
	}
	return [array objectAtIndex:0];
}
-(NSMutableArray*)getContactSyncInfoList {
	NSMutableArray *array = [NSMutableArray array];
	NSError *outError = nil;
	NSString* sql = @"select * from contact_sync ";
	id<PLResultSet> results = [[self db]  executeQueryAndReturnError:&outError statement:sql];
	
	if(SQLITE_OK != [outError code]) {
		return nil;
	}
	PLResultSetStatus status = [results nextAndReturnError:nil];
	while (status) {
		MMContactSyncInfo *info = [[[MMContactSyncInfo alloc] initWithResultSet:results] autorelease];
		[array addObject:info];
		status = [results nextAndReturnError:nil];
	}
	[results close];
	return array;
}

-(BOOL)addContactSyncInfo:(MMContactSyncInfo*)info {
	NSString* sql = @"INSERT INTO contact_sync (contact_id, phone_contact_id, modify_date, phone_modify_date, "
					@"avatar_url, avatar_part, avatar_md5) VALUES(?, ?, ?, ?, ?, ?, ?) ";


	if(![[self db]  executeUpdate:sql, 
		 [NSNumber numberWithInteger:info.contactId],
		 [NSNumber numberWithInteger:info.phoneContactId],
		 [NSNumber numberWithLongLong:info.modifyDate],
		 [NSNumber numberWithLongLong:info.phoneModifyDate],
		 info.avatarUrl,
		 info.avatarPart, 
		 info.avatarMd5 ]){

		return NO;
	}

	return YES;
}
-(BOOL)deleteContactSyncInfo:(NSInteger)contactId {
	NSString* sql = @"DELETE FROM contact_sync where contact_id = ? ";
	
	if(![[self db]  executeUpdate:sql, 
		 [NSNumber numberWithInteger:contactId]]) {
		return NO;
	}
	
	return YES;
}

-(BOOL)updateContactSyncInfo:(MMContactSyncInfo*)info {
	NSString* sql = @"UPDATE contact_sync SET "
					@"modify_date = ?, phone_modify_date = ?, avatar_url = ?, "
					@"avatar_part = ?, avatar_md5 = ? where contact_id = ? ";
	

	if(![[self db]  executeUpdate:sql, 
		 [NSNumber numberWithLongLong:info.modifyDate],
		 [NSNumber numberWithLongLong:info.phoneModifyDate],
		 info.avatarUrl,
		 info.avatarPart,
		 info.avatarMd5,
         [NSNumber numberWithInteger:info.contactId]]) {
		return NO;
	}
	return YES;
}

-(BOOL)setContactSyncInfoModifyTime:(int64_t)modifyTime contactId:(NSInteger)contactId{
	NSString* sql = @"UPDATE contact_sync SET modify_date = ? where contact_id = ? ";
	
	if(![[self db]  executeUpdate:sql, 
		 [NSNumber numberWithLongLong:modifyTime],
		 [NSNumber numberWithInteger:contactId]]) {
		return NO;
	}
	
	return YES;
}

-(BOOL)setContactSyncInfoPhoneModifyTime:(int64_t)modifyTime contactId:(NSInteger)contactId {
	NSString* sql = @"UPDATE contact_sync SET phone_modify_date = ? where contact_id = ? ";
	
	if(![[self db]  executeUpdate:sql, 
		 [NSNumber numberWithLongLong:modifyTime],
		 [NSNumber numberWithInteger:contactId]]) {
		return NO;
	}
	
	return YES;
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
			[idsToDown addObject:[NSNumber numberWithInteger:c.contactId]];
		} else {
			DbContactSyncInfo *info = [contacts objectAtIndex:index];
			if (c.modifyDate > info.modifyDate ) {
				[idsToDown addObject:[NSNumber numberWithInteger:c.contactId]];
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
                if ([[MMContactManager instance] insertContact:contact withDataList:contact.properties] != MM_DB_OK) {
                    MLOG(@"insert contact fail, contact id:%d", contact.contactId);
                }
                

            } else {
                if ([[MMContactManager instance] updateContact:contact withDataList:contact.properties] != MM_DB_OK) {
                    MLOG(@"update contact fail contact id:%d", contact.contactId);
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

-(BOOL) downloadContactToMomo:(NSArray*)simpleList {
	if ([simpleList count] == 0)
		return YES;
	NSMutableArray *array = [NSMutableArray array];
	for (MMMomoContactSimple *c in simpleList) {
		[array addObject:[NSNumber numberWithInteger:c.contactId]];
	}
	NSArray *tmp = [[MMContactManager instance] getContactSyncInfoList:array withError:nil];
	NSMutableArray *syncInfos = [NSMutableArray arrayWithArray:tmp];
	return [self downloadContactToMomo:simpleList contacts:syncInfos];
}

@end
