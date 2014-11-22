//
//  MMContactSync.h
//  momo
//
//  Created by houxh on 11-7-5.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>
#import "MMModel.h"


//同步联系人（包含头像）及其分组
@interface MMContactSync : MMModel {

}

-(BOOL) isCancelled;
-(BOOL) clearSyncDb;
@end


@interface MMContactSync(Contact)
-(BOOL) downloadContactToMomo;


-(NSMutableArray*)getContactSyncInfoList;

@end