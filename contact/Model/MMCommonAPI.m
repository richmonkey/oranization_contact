//
//  MMCommonAPI.m
//  momo
//
//  Created by mfm on 7/24/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MMCommonAPI.h"
#import "MMPhoneticAbbr.h"

@implementation MMCommonAPI



+ (NSDate*) getDateBySting:(NSString*)stringDate {		
	
	if (0 == stringDate.length){
		return nil;
	}
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	dateFormatter.dateStyle = NSDateFormatterMediumStyle;
	[dateFormatter setLocale:[NSLocale currentLocale]];	
	[dateFormatter setDateFormat:@"yyyy-MM-dd"];
	
	NSDate *date = [dateFormatter dateFromString:stringDate];
	[dateFormatter release];
	return date;
}

+ (NSString*) getStingByDate:(NSDate*)date {	
	if (nil == date) {
		return nil;
	}
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	dateFormatter.dateStyle = NSDateFormatterMediumStyle;
	[dateFormatter setLocale:[NSLocale currentLocale]];	 
	[dateFormatter setDateFormat:@"yyyy-MM-dd"];	
	
	NSString *stringDate = [dateFormatter stringFromDate:date];
	[dateFormatter release];
	return stringDate;
}

+ (NSString*)getDateString:(NSDate*)date {
	if (nil == date) {
		return nil;
	}
	
	NSString* retString = nil;
	unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit;
	
	
	NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:unitFlags fromDate:date];
	NSDateComponents *todayComponents = [[NSCalendar currentCalendar] components:unitFlags fromDate:[NSDate date]];
	
	if ([dateComponents day] == [todayComponents day] &&
		[dateComponents month] == [todayComponents month] &&
		[dateComponents year] == [todayComponents year]) {
		retString = [NSString stringWithFormat:@"%02d:%02d", [dateComponents hour], [dateComponents minute]];
	} else {
		if ([dateComponents year] != [todayComponents year]) {
			retString = [NSString stringWithFormat:@"%d年%d月%d日", [dateComponents year], [dateComponents month], [dateComponents day]];
		} else {
			retString = [NSString stringWithFormat:@"%d月%d日 %02d:%02d", [dateComponents month], [dateComponents day], [dateComponents hour], [dateComponents minute]];
		}
	}
	
	return retString;
}



+ (NSString *) getStringByDate:(NSDate*)date byFormatter:(NSString *)stringFormatter {	
	if (nil == date) {
		return nil;
	}
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	dateFormatter.dateStyle = NSDateFormatterMediumStyle;
	[dateFormatter setLocale:[NSLocale currentLocale]];	 
	[dateFormatter setDateFormat:stringFormatter];
	
	NSString *stringDate = [dateFormatter stringFromDate:date];
	[dateFormatter release];
	return stringDate;
}

+ (void)alert:(NSString *)message {
    UIAlertView *alert = [[UIAlertView alloc] init];
    [alert setTitle:@""];
    [alert setMessage:message];
    [alert addButtonWithTitle:@"确定"];
    [alert show];
    [alert release];
}

//判断该字符串的首字母是否 不为特殊字符
+ (BOOL) isNoSpecialChar:(NSString *)str {
	if ([str characterAtIndex:0] >= 'A' && [str characterAtIndex:0] <= 'Z') {
		return YES;
	} else {
		return NO;
	}
}

+ (NSString*)getStringFirstLetter:(NSString *)str {
    NSString *firstLetter = @"#";
	
	if (nil != str && [str length] > 0) {
		firstLetter = [[str substringToIndex:1] uppercaseString];
		firstLetter = [self isNoSpecialChar:firstLetter] ? firstLetter : @"#"; 
	}
	
	return firstLetter;
}





@end
