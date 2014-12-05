#import "ContactListCell.h"
#import "UIView+NGAdditions.h"

@implementation ContactListCell

+ (ContactListCell *)cell {
    return [[[NSBundle mainBundle] loadNibNamed:@"ContactListCell" owner:self options:nil] lastObject];
}

+ (CGFloat)heigh {
    return 68;
}

- (void)awakeFromNib {
    _logoImage.layer.cornerRadius = 30;
    _logoImage.layer.masksToBounds = YES;
    
    UIView* selectBgView = [[UIView alloc] init];
    selectBgView.backgroundColor = [UIColor colorWithRed:0.949f green:0.953f blue:0.961f alpha:1.00f];
    self.selectedBackgroundView = selectBgView;
    
    UIView* bgView = [[UIView alloc] init];
    self.backgroundView = bgView;
}

//-(void)setCardDic:(NSDictionary *)cardDic {
//	_cardDic = cardDic;
//    
//    NSDictionary* brandDic = self.cardDic[@"brand"];
//    self.brandName.text = brandDic[@"name"];
//	
////	NSString* logoURL = brandDic[@"logo"];
////	if (logoURL.length > 0) {
////		[self.logoImage setImageWithURL:[BCCommon getFullURLByCode:logoURL] placeholderImage:[MMThemeMgr imageNamed:@"list_card_normal.png"]];
////    } else {
////        self.logoImage.image = [MMThemeMgr imageNamed:@"list_card_normal.png"];
////    }
//
//	self.memBerCardLabel.text = [NSString stringWithFormat:@"会员卡%d张", [self.cardDic[@"vip_summary"][@"total"] intValue]];
//	self.CouponLabel.text = [NSString stringWithFormat:@"优惠券%d张", [self.cardDic[@"coupon_summary"][@"total"] intValue]];
//    
//    _linkIcon.hidden = !([self.cardDic[@"vip_summary"][@"unbinded"] intValue] > 0);
//    _timeIcon.hidden = !([self.cardDic[@"coupon_summary"][@"warning_end_time"] intValue] > 0);
//    
//    _linkIcon.centerY = _memBerCardLabel.centerY;
//    _timeIcon.centerY = _CouponLabel.centerY;
//    
//    [self setNeedsLayout];
//}

- (void)setIndex:(NSInteger)index {
    _index = index;
    
    if (index % 2 == 0) {
        self.backgroundView.backgroundColor = [UIColor whiteColor];
    } else {
        self.backgroundView.backgroundColor = [UIColor colorWithRed:0.949f green:0.953f blue:0.961f alpha:1.00f];
    }
}

@end