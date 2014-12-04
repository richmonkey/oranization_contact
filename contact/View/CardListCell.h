//
//  CardListCell.h
//  91BeautyClient
//
//  Created by jackie on 14-1-17.
//  Copyright (c) 2014年 nd. All rights reserved.
//

#import <UIKit/UIKit.h>

//卡包列表
@interface CardListCell : UITableViewCell {
	
}
@property (weak, nonatomic) IBOutlet UIImageView *logoImage;
@property (weak, nonatomic) IBOutlet UILabel *brandName;
@property (weak, nonatomic) IBOutlet UILabel *memBerCardLabel;
@property (weak, nonatomic) IBOutlet UIImageView* linkIcon;
@property (weak, nonatomic) IBOutlet UIImageView* timeIcon;
@property (weak, nonatomic) IBOutlet UILabel *CouponLabel;

@property (nonatomic, retain) NSDictionary *cardDic;
@property (nonatomic) NSInteger index;

+ (CGFloat)heigh;

+ (CardListCell *)cell;

@end