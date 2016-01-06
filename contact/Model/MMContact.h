//
//  MMContact.h
//  Db
//
//  Created by aminby on 2010-7-23.
//  Copyright 2010 NetDragon.Co. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMModel.h"

@interface MMContactManager : MMModel {
}

+(MMContactManager*) instance;

-(NSArray*) getContactSyncInfoList:(MMErrorType*)error;

-(NSArray*) getCompanyList:(MMErrorType*)error;

-(NSArray*) getSimpleContactListWithCompanyName:(NSString*)companyName error:(MMErrorType*)error;

/*
 * 获取联系人简单信息列表 返回DbContact元素的NSArray
 */

- (NSArray*)getSimpleContactList:(MMErrorType*)error;

/*
 * 获得联系人某种类型数据, 返回DbData元素的NSArray
 */
- (NSArray*)getDataList:(int64_t)contactId withType:(ContactType)type withError:(MMErrorType*)error;
/*
 * 获得联系人数据, 返回DbData元素的NSArray
 */
- (NSArray*)getDataList:(int64_t)contactId withError:(MMErrorType*)error;

/*
 * 获得联系人信息
 */
- (DbContact*) getContact:(int64_t)contactId withError:(MMErrorType*)error;

/*
* 获得详细联系人信息
*/
- (MMFullContact*) getFullContact:(int64_t)contactId withError:(MMErrorType*)error;

/*
 * 插入联系人, 使用DbContact和DdData List, 已设置contactId
 */
- (MMErrorType)insertContact:(DbContact *)contact withDataList:(NSArray*)listData;

/*
 * 插入联系人, 使用DbContact和DdData List
 */
- (MMErrorType)insertContact:(DbContact *)contact withDataList:(NSArray*)listData returnContactId:(NSInteger*)contactId;


/*
 * 更新联系人, 使用DbContact和DdData List
 */
- (MMErrorType) updateContact:(DbContact*)contact withDataList:(NSArray*)listData;
/*
 * 删除某个联系人
 */
- (MMErrorType) deleteContact:(int64_t)contactId;

- (MMErrorType) setModifyDate:(NSDate*)modifydate byContactId:(NSInteger)contactId;

- (MMErrorType)clearContactDB;


//匹配联系人
- (NSArray*)searchContact:(NSArray*)contacts
                   pattern:(NSString*)searchString
                 needName:(BOOL)needName;    //是否包含没有名字联系人


//@private

- (MMErrorType) _insertContact:(DbContact*)contact returnContactId:(NSInteger*)contactId;
- (MMErrorType) _updateContact:(DbContact*)contact;
- (MMErrorType) _deleteContact:(int64_t)contactId;
- (MMErrorType) _insertData:(DbData*)data;
- (MMErrorType) _updateData:(DbData*)data;
- (MMErrorType) _deleteData:(NSInteger)row_id;
- (MMErrorType) _deleteAllData:(int64_t)contactId;
- (MMErrorType) _updateContact:(DbContact*)contact withDataList:(NSArray*)listData;
- (MMErrorType) _updatePhoneticAbbr:(NSInteger)contactId;

-(NSString*) getDefaulMMLabelByProperty:(NSInteger) property;
@end

typedef MMContactManager MMContact ;
