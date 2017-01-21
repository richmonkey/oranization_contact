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
	
	if ((nil == stringDate) 
		|| (0 == stringDate.length)){
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

+ (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (UIImage*)scaleAndRotateImage:(UIImage *)image scaleSize:(NSInteger)scaleSize{
	int kMaxResolution = scaleSize; // Or whatever
	
    CGImageRef imgRef = image.CGImage;
	
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
	
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    if (width > kMaxResolution || height > kMaxResolution) {
        CGFloat ratio = width/height;
        if (ratio > 1) {
            bounds.size.width = kMaxResolution;
            bounds.size.height = roundf(bounds.size.width / ratio);
        }
        else {
            bounds.size.height = kMaxResolution;
            bounds.size.width = roundf(bounds.size.height * ratio);
        }
    }
	
    CGFloat scaleRatio = bounds.size.width / width;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    UIImageOrientation orient = image.imageOrientation;
    switch(orient) {
			
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
			
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
			
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
			
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
			
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
			
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
			
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
			
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
			
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
			
    }
	
    UIGraphicsBeginImageContext(bounds.size);
	
    CGContextRef context = UIGraphicsGetCurrentContext();
	
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
	
    CGContextConcatCTM(context, transform);
	
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
	
    return imageCopy;
}

+ (UIImage*)rotateImage:(UIImage*)image {
    NSInteger scaleSize = MAX(image.size.width, image.size.height);
    return [self scaleAndRotateImage:image scaleSize:scaleSize];
}

+ (BOOL)isNetworkReachable {
	Reachability * curReach = [Reachability reachabilityForInternetConnection];
	return [curReach currentReachabilityStatus] != NotReachable;
}

+ (NetworkStatus)getNetworkStatus {
	Reachability * curReach = [Reachability reachabilityForInternetConnection];
	return [curReach currentReachabilityStatus];
}

+ (NSString*)createGUIDStr
{
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
	CFStringRef stringGUID = CFUUIDCreateString(NULL,theUUID);
	CFRelease(theUUID);
	return [(NSString *) stringGUID autorelease];
}

+ (NSString*)temporaryURLHost {
    return  @"http://temporary.momo.im/";
}

+ (NSString*)originalImageURL:(NSString*)smallImageURL {
    NSString* originImageUrl = [smallImageURL stringByReplacingOccurrencesOfString:@"_130." withString:@"_780."];
    return originImageUrl;
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
    [alert setTitle:nil];
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

+ (CGRect)properRectForButton:(UIButton*)button maxSize:(CGSize)maxSize {
	CGRect frame = button.frame;
	CGSize size = [button sizeThatFits:button.frame.size];
	if (size.width + 20 > maxSize.width) {
		size.width = maxSize.width;
	} else {
		size.width += 20;
	}
	
	frame.size = size;
	return frame;
}




@end
