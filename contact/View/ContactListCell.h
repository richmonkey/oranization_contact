//
//  ContactListCell.h
//
//  Copyright (c) 2014年 nd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactListCell : UITableViewCell {
	
}
@property (weak, nonatomic) IBOutlet UIImageView *logoImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *jobLabel;
@property (nonatomic, retain) NSDictionary *cardDic;
@property (nonatomic) NSInteger index;

+ (CGFloat)heigh;

+ (ContactListCell *)cell;

@end