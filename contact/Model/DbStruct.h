//
//  DbStruch.h
//  Momo
//
//  Created by zdh on 5/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIImage.h>
#import <MapKit/MapKit.h>
#import "DefineEnum.h"


@interface DbContactId : NSObject {
	int64_t contactId;
}
@property(nonatomic)int64_t contactId;
@end

@interface DbContactSyncInfo : DbContactId {
	int64_t modifyDate;//服务器联系人的时间戳
}
@property(nonatomic)int64_t modifyDate;
@end

//简单联系人
@interface DbContactSimple : DbContactId {
    
	NSString    *avatarUrl;
	NSString	*firstName;	//姓名
	NSString	*middleName;//(姓)名	
	NSString	*lastName;	//姓
	NSString	*namePhonetic;	//姓名
    
}

@property (copy, nonatomic) NSString *firstName;
@property (copy, nonatomic) NSString *middleName;
@property (copy, nonatomic) NSString *lastName;
@property (nonatomic, readonly)NSString *fullName;
@property (copy, nonatomic) NSString *avatarUrl;
@property (nonatomic, readonly) NSString *avatarPlatformUrl;
@property (nonatomic, readonly) NSString *avatarBigUrl;
@property (copy, nonatomic) NSString *namePhonetic;

-(id)init;

- (BOOL)isEnglishName;

@end



//联系人
@interface DbContact : DbContactSimple {
	NSString	*organization;//公司
	NSString	*department;//部门
	NSString	*note;//备注
	NSDate		*birthday;//生日
	int64_t     modifyDate;
	NSString	*jobTitle;//职称
	NSString	*nickName;//昵称
    NSString    *companyName;
    
}
@property (nonatomic) int32_t	phoneCid;
@property (nonatomic, copy) NSString *organization;
@property (nonatomic, copy) NSString *department;
@property (nonatomic, copy) NSString *note;
@property (nonatomic, copy) NSString *jobTitle;
@property (nonatomic, copy) NSString *nickName;
@property (nonatomic, copy) NSDate *birthday;
@property(nonatomic)int64_t modifyDate;
@property(nonatomic, copy) NSString *companyName;


-(id)initWithContact:(DbContact*)dbcontact;
@end

@class DbData;

@interface MMFullContact : DbContact <NSCopying>
{
	NSArray *properties;
}

@property(nonatomic, retain)NSArray *properties;
@property(nonatomic, readonly)DbData *mainTelephone;

@end

//联系人数据
@interface DbData : NSObject <NSCopying> {
	NSInteger	rowId;//表记录ID
	int64_t	contactId;//联系人ID
	ContactType	property;//
	NSString	*label;//联系方式的标签
	NSString	*value;//联系人的值
    
}
@property (nonatomic) NSInteger rowId;
@property (nonatomic) int64_t contactId;
@property ContactType property;
@property (copy, nonatomic) NSString  *label;
@property (copy, nonatomic) NSString *value;
@property (nonatomic) BOOL isMainTelephone;
- (id)init;

- (id)initWithDbData:(DbData *)data;
@end


@interface DbData(Address)
+(NSString*)AddressValue:(NSString*)country region:(NSString*)region city:(NSString*)city street:(NSString*)street postal:(NSString*)postal;
+(void)ParseAddressValue:(NSString*)value country:(NSString**)country region:(NSString**)region city:(NSString**)city street:(NSString**)street postal:(NSString**)postal;
@end

typedef MMFullContact MMMomoContact;

