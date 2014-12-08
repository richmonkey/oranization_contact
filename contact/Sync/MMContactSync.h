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

@property(nonatomic, assign)int addedCount;
@property(nonatomic, assign)int deletedCout;
@property(nonatomic, assign)int updatedCount;

-(BOOL) isCancelled;

-(BOOL) downloadContactToMomo;
@end