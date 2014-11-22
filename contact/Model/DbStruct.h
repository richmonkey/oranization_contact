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


typedef enum {
    MMDataRecordExist,		//已有记录 界面上已经被创建出来的 但并不一定已经入库
	MMDataRecordNoExist,	//记录还未被创建
	MMDataRecordAddRow,		//虚拟记录 只为了绘制界面而造出来的记录 增加一条记录
	MMDataRecordMoreInfo,	//虚拟记录 只为了绘制界面而造出来的记录 转到更多字段的页面
	MMDataRecordDelContact,  //虚拟记录 只为了绘制界面而造出来的记录 删除联系人
} MMDataRecordStateEnum;



@interface DbContactId : NSObject {
	NSInteger contactId;
}
@property(nonatomic)NSInteger contactId;
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
    
    NSMutableSet    *cellPhoneNums; //用户手机号数组
}
@property (nonatomic) NSInteger	phoneCid;
@property (copy, nonatomic) NSString *firstName;
@property (copy, nonatomic) NSString *middleName;
@property (copy, nonatomic) NSString *lastName;
@property (nonatomic, readonly)NSString *fullName;
@property (copy, nonatomic) NSString *avatarUrl;
@property (nonatomic, readonly) NSString *avatarPlatformUrl;
@property (nonatomic, readonly) NSString *avatarBigUrl;
@property (copy, nonatomic) NSString *namePhonetic;
@property (nonatomic, retain) NSMutableSet    *cellPhoneNums;

-(id)init;

- (BOOL)isEnglishName;

@end

@interface MMLunarDate : NSObject {
    NSArray *array_;
}
@property(nonatomic, readonly) NSString *year;
@property(nonatomic, readonly) NSString *month;
@property(nonatomic, readonly) NSString *day;
@property(nonatomic, readonly) NSInteger nyear;
@property(nonatomic, readonly) NSInteger nmonth;
@property(nonatomic, readonly) NSInteger nday;
-(id)initWithString:(NSString*)str;
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
    
}
@property (nonatomic, copy) NSString *organization;
@property (nonatomic, copy) NSString *department;
@property (nonatomic, copy) NSString *note;
@property (nonatomic, copy) NSString *jobTitle;
@property (nonatomic, copy) NSString *nickName;
@property (nonatomic, copy) NSDate *birthday;
@property(nonatomic)int64_t modifyDate;


-(id)initWithContact:(DbContact*)dbcontact;
@end

@class DbData, MMCard;

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
	NSInteger	contactId;//联系人ID
	ContactType	property;//
	NSString	*label;//联系方式的标签
	NSString	*value;//联系人的值
    
}
@property (nonatomic) NSInteger rowId;
@property (nonatomic) NSInteger contactId;
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


@interface MMDataRecord : DbData <NSCopying>
{
    
}

@property (nonatomic)	NSInteger	dataRecordState;	
@property (nonatomic, copy) NSString *reserve;   //用于界面文字显示用

- (id)init;

//对号码与邮箱进行排序 主号码总在最前。号码在邮箱之前。
- (NSComparisonResult)compareWithOther:(MMDataRecord *)other;
//对微博排序 微博在前，开心网在后。
- (NSComparisonResult)compareUrlWithOther:(MMDataRecord *)other;

@end




//联系人头像
@interface DbContactImage : NSObject {
	//	NSInteger	imageId;//头像自增ID
	NSString	*url;	//头像URL
	UIImage		*image;	//头像
	
}
//@property (nonatomic) NSInteger imageId;
@property (copy, nonatomic) NSString *url;
@property (nonatomic, retain) UIImage *image;
@end

//分组成员,是否要加头像
@interface DbCategoryMember : NSObject {
	NSInteger	categoryId;		//联系人组ID
	NSInteger	contactId;		//联系人ID
	NSString	*categoryName;	//联系人组名称
	NSString	*contactName;	//联系人名称
}

@property (nonatomic) NSInteger categoryId;
@property (nonatomic) NSInteger contactId;
@property (copy, nonatomic) NSString *categoryName;
@property (copy, nonatomic) NSString *contactName;

@end

//分组信息
@interface DbCategory : NSObject {
	NSInteger	categoryId;	//分组ID
	NSInteger	phoneCategoryId;	//address book中的分组id
	NSString	*categoryName;	//分组名称
}

@property (nonatomic) NSInteger categoryId;
@property (nonatomic) NSInteger phoneCategoryId;
@property (copy, nonatomic) NSString  *categoryName;

@end


//根据联系人获取简单电话信息
@interface DbContactPhone : NSObject {
	NSString	*label;		//标签(home,work等)
	NSString	*value;		//联系方式(电话号码)
	NSString	*location;	//归属地
}

@property (copy, nonatomic) NSString  *label;
@property (copy, nonatomic) NSString  *value;
@property (copy, nonatomic) NSString  *location;

@end

/*
 * 如果label isa NSNumber 那么他是个内置标签,可以多国语言化
 * 如果label isa NSString 那么是自定义标签,直接显示
 */
@interface MMContactInfo : NSObject {
    id label;
    NSString *value;
}
@property (copy, nonatomic) NSString  *value;
@property (nonatomic,retain) id  label;
@end

