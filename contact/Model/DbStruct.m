//
//  DbStruch.m
//  Momo
//
//  Created by zdh on 5/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DbStruct.h"
#import "SBJSON.h"
#import "RegexKitLite.h"
#import "MMGlobalData.h"
//#import "MMUapRequest.h"
#import "MMPhoneticAbbr.h"

@implementation DbContactId 
@synthesize contactId;

- (BOOL)isEqual:(id)object {
    return self.contactId == [object contactId];
}

- (NSUInteger)hash {
    return contactId;
}

@end

@implementation DbContactSyncInfo
@synthesize modifyDate;

-(id)init {
	self = [super init];
	if (self) {
	}
	return self;
}
-(void)dealloc {
	[super dealloc];
}
@end

//简单联系人
@implementation DbContactSimple
@synthesize firstName,middleName,lastName,avatarUrl,namePhonetic, cellPhoneNums;

- (BOOL)isEnglishName {
    NSString* tmpString = [NSString stringWithFormat:@"%@%@%@", PARSE_NULL_STR(lastName), PARSE_NULL_STR(middleName), PARSE_NULL_STR(firstName)];
    NSInteger length = tmpString.length;
    for (int i = 0; i < length; i++) {
        if ([tmpString characterAtIndex:i] > 256) {
            return NO;
        }
    }
    return YES;
}

-(NSString*)fullName {
    if ([self isEnglishName]) {
        NSMutableString* name = [NSMutableString stringWithString:PARSE_NULL_STR(lastName)];
        if (middleName.length > 0) {
            [name appendFormat:@"%@%@", name.length ? @" " : @"", PARSE_NULL_STR(middleName)];
        }
        if (firstName.length > 0) {
            [name appendFormat:@"%@%@", name.length ? @" " : @"", PARSE_NULL_STR(firstName)];
        }
        
        return name;
    } else {
        return [NSString stringWithFormat:@"%@%@%@", PARSE_NULL_STR(lastName), PARSE_NULL_STR(middleName), PARSE_NULL_STR(firstName)];
    }
}
-(NSString*) avatarPlatformUrl {
	return avatarUrl;
}

-(NSString*)avatarBigUrl {
    if (!avatarUrl) {
        return nil;
    }
    NSString* desireSizeStr = [NSString stringWithFormat:@"_%d.", BIG_AVATAR_SIZE];
    return [avatarUrl stringByReplacingOccurrencesOfString:@"_130." withString:desireSizeStr];
}

-(void)setPhoneCid:(NSInteger)pid {
	contactId = pid;
}
-(NSInteger)phoneCid {
	return contactId;
}

-(id)init{
	self = [super init];
	if (self) {
		firstName = @"";
		middleName = @"";
		lastName = @"";
		avatarUrl = @"";
		namePhonetic = @"";
        self.cellPhoneNums = [NSMutableSet set];
    }
    return self;
}

- (void)dealloc {
	self.avatarUrl = nil;
	self.firstName = nil;
	self.middleName = nil;
	self.lastName = nil;
	self.namePhonetic = nil;
    self.cellPhoneNums = nil;
	[super dealloc];
}
@end
@implementation MMLunarDate
@synthesize year, month, day, nyear, nmonth, nday;

-(NSString*)year {
    return [array_ objectAtIndex:3];
}
-(NSString*)month {
    return [array_ objectAtIndex:1];
}
-(NSString*)day {
    return [array_ objectAtIndex:2];
}
-(NSInteger)nyear {
    return [[array_ objectAtIndex:0] intValue];
}
-(NSInteger)nmonth {
    return [[array_ objectAtIndex:4] intValue];
}
-(NSInteger)nday {
    return [[array_ objectAtIndex:5] intValue];
}

- (NSString *)description {
    return [array_ componentsJoinedByString:@","];
}

-(id)initWithString:(NSString*)str {
    self = [super init];
    if (self) {
        if ([str length] > 0) {
            array_ = [str componentsSeparatedByString:@","];
            assert([array_ count] == 8);
            [array_ retain];
        }
    }
    return self;
}

-(void)dealloc {
    [array_ release];
    [super dealloc];
}

@end
//联系人
@implementation DbContact
@synthesize organization,department;
@synthesize  note,birthday,modifyDate,jobTitle,nickName;

-(id) init{
    self = [super init];
    if (self) {
		organization = @"";
		department = @"";
		note = @"";
		jobTitle = @"";
		nickName = @"";
		birthday = nil;
	}
    return self;
}

-(id)initWithContact:(DbContact*)dbcontact {
    self = [super init];
    if (self) {
        self.contactId = dbcontact.contactId;
        self.avatarUrl = dbcontact.avatarUrl;
        self.firstName = dbcontact.firstName;
        self.lastName = dbcontact.lastName;
        self.namePhonetic = dbcontact.namePhonetic;
        self.middleName = dbcontact.middleName;
        self.organization = dbcontact.organization;
        
        self.department = dbcontact.department;
        self.note = dbcontact.note;
        self.jobTitle = dbcontact.jobTitle;
        self.nickName = dbcontact.nickName;
        self.birthday = dbcontact.birthday;
        self.modifyDate = dbcontact.modifyDate;
        
    }
    return self;
}

- (void)dealloc {
	self.organization = nil;
	self.department = nil;
	self.note = nil;
	self.jobTitle = nil;
	self.nickName = nil;
	self.birthday = nil;
    
	[super dealloc];
}

@end

@implementation MMFullContact
@synthesize   properties;


-(void)dealloc {
	self.properties = nil;
	[super dealloc];
}

-(DbData*)mainTelephone {
    for (DbData *data in properties) {
        if ([data isMainTelephone]) {
            return data;
        }
    }
    return nil;
}

- (id)copyWithZone:(NSZone *)zone {
	
	MMFullContact *newFullcontact = [[MMFullContact allocWithZone:zone] initWithContact:self];
	
    
	NSMutableArray *newArray = [NSMutableArray array];
	for (DbData *data in self.properties) {
		DbData *newData = [[[DbData alloc] initWithDbData:data] autorelease];
		[newArray addObject:newData];
	}
	
	newFullcontact.properties = newArray;
    
	return newFullcontact;
}

@end

//联系人数据
@implementation DbData
@synthesize rowId,contactId,property,label,value;
@synthesize isMainTelephone;

- (id)init {
	
    self = [super init];
    if (self) {
        rowId = 0;
        contactId = 0;
        property = 0;
        label = @"";
        value = @"";
		isMainTelephone = NO;
    }
    return self;
}

- (id)initWithDbData:(DbData *)data {
	self = [self init];
    if (self) {
        self.isMainTelephone = data.isMainTelephone;   
        self.rowId = data.rowId;
        self.contactId = data.contactId;
        self.property = data.property;
        self.label = data.label;
        self.value = data.value;
    }
	
	return self;
}

- (id)copyWithZone:(NSZone *)zone {
	DbData *newData = [[DbData allocWithZone:zone] init];
	
    newData.isMainTelephone = self.isMainTelephone;   
	newData.rowId = self.rowId;
	newData.contactId = self.contactId;
	newData.property = self.property;
	newData.label = [[self.label copyWithZone:zone] autorelease];
	newData.value = [[self.value copyWithZone:zone] autorelease];
	
	return newData;
}

- (void)dealloc {
	self.label = nil;
	self.value = nil;
	[super dealloc];
}

+(NSString*)AddressValue:(NSString*)country region:(NSString*)region city:(NSString*)city 
				  street:(NSString*)street postal:(NSString*)postal{
	NSMutableArray *array = [[[NSMutableArray alloc] init] autorelease];
	[array addObject:@""];
	[array addObject:@""]; // 添加两个空值
	
	[array addObject:street];
	[array addObject:city];
	[array addObject:region];
	[array addObject:postal];
	[array addObject:country];		
	
	SBJSON* sbjson = [[SBJSON new] autorelease];
	return [sbjson stringWithObject:array];
}

+(void)ParseAddressValue:(NSString*)value country:(NSString**)country region:(NSString**)region 
					city:(NSString**)city street:(NSString**)street postal:(NSString**)postal {
	// patched for address order 0-6: 0:nil 1:nil 2:street 3:city 4:province 5:zip 6:country
	// the patched order is: state, province, city, street, zip -> 6 4 3 2 5
	SBJSON* sbjson = [[SBJSON new] autorelease];
	NSArray *array = [sbjson objectWithString:value];
    
	*country = [[[array objectAtIndex:6] copy] autorelease];
	*region = [[[array objectAtIndex:4] copy] autorelease];
	*city = [[[array objectAtIndex:3] copy] autorelease];
	*street = [[[array objectAtIndex:2] copy] autorelease];
	*postal = [[[array objectAtIndex:5] copy] autorelease];
	return;
}
@end

@implementation MMDataRecord

@synthesize dataRecordState;
@synthesize reserve;

- (id)init{
    self = [super init];
    if (self) {
        self.dataRecordState = MMDataRecordExist;
		self.reserve = @"";
    }
    return self;
}
- (void)dealloc {
	self.reserve = nil;
	[super dealloc];
}

- (id)copyWithZone:(NSZone *)zone {
	MMDataRecord *newDataRcd = [[MMDataRecord allocWithZone:zone] init];
	
	newDataRcd.rowId = self.rowId;
	newDataRcd.contactId = self.contactId;
	newDataRcd.property = self.property;
	newDataRcd.label = [[self.label copyWithZone:zone] autorelease];
	newDataRcd.value = [[self.value copyWithZone:zone] autorelease];
	
	newDataRcd.dataRecordState = self.dataRecordState;
	newDataRcd.reserve = [[self.reserve copyWithZone:zone] autorelease];
	
	return newDataRcd;
}

//对号码与邮箱进行排序 主号码总在最前。号码在邮箱之前。
- (NSComparisonResult)compareWithOther:(MMDataRecord *)other {
	
	assert(other.property == kMoTel || other.property == kMoMail);
    
	if (self.isMainTelephone && !other.isMainTelephone) {
		return NSOrderedAscending;
	}
	
	if (!self.isMainTelephone && other.isMainTelephone) {
		return NSOrderedDescending;
	}
    
	if (self.property == kMoTel && other.property == kMoMail) {
		return NSOrderedAscending;
	}
	
	if (self.property == kMoMail && other.property == kMoTel) {
		return NSOrderedDescending;
	}
	
	return NSOrderedSame;	
}

//对微博排序 微博在前，开心网在后。
- (NSComparisonResult)compareUrlWithOther:(MMDataRecord *)other {
	
	assert(other.property == kMoUrl);
    
    if ([self.label isEqualToString:@"weibo.com"]) {
        return NSOrderedAscending; 
    }
    
    if ([self.label isEqualToString:@"kaixin001.com"]) {
        return NSOrderedDescending;
    }
    
    return NSOrderedSame;
}


@end

//图片
@implementation DbContactImage
@synthesize url,image;

- (void)dealloc {
	self.url = nil;
	self.image = nil;
	[super dealloc];
}
@end

//分组成员
@implementation DbCategoryMember
@synthesize contactId,categoryId,categoryName,contactName;

- (void)dealloc {
	self.categoryName = nil;
	self.contactName = nil;
	[super dealloc];
}

@end

//分组成员
@implementation DbCategory
@synthesize categoryId,categoryName,phoneCategoryId;

- (BOOL)isEqual:(id)object {
    return self.categoryId == [object categoryId];
}

- (NSUInteger)hash {
    return categoryId;
}

- (void)dealloc {
	self.categoryName = nil;
	[super dealloc];
}

@end

@interface MMImageInfo : NSObject {
    NSInteger	imageId;
	NSString	*url;
	NSString	*originalUrl;
	NSInteger	lastUpdateTime;
	NSData		*imageData;
	NSData		*originalImageData;
	NSInteger	createState;
	NSInteger	updateState;
	NSInteger	deleteState;
}
@property (nonatomic)			NSInteger	imageId;
@property (nonatomic,retain)	NSString	*url;
@property (nonatomic,retain)	NSString	*originalUrl;
@property (nonatomic)			NSInteger	lastUpdateTime;
@property (nonatomic,retain)	NSData		*imageData;
@property (nonatomic,retain)	NSData		*originalImageData;

@property (nonatomic)			NSInteger	createState;
@property (nonatomic)			NSInteger	updateState;
@property (nonatomic)			NSInteger	deleteState;

@end

@interface MMSimpleImageInfo : NSObject {
    NSInteger	imageId;
	NSString	*url;
	NSString	*originalUrl;	
}
@property (nonatomic)			NSInteger	imageId;
@property (nonatomic,retain)	NSString	*url;
@property (nonatomic,retain)	NSString	*originalUrl;


@end