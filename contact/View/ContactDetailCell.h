//
//  ContactListCell.h
//
//  Copyright (c) 2014年 nd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactDetailCell : UITableViewCell {
	
}

@property (retain, nonatomic) IBOutlet UILabel *tipLabel;
@property (retain, nonatomic) IBOutlet UILabel *contentLabel;
@property (retain, nonatomic) IBOutlet UIButton *actionBtn;

+ (CGFloat)heigh;

+ (ContactDetailCell *)cell;

@end