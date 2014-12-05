#import "ContactDetailCell.h"
#import "UIView+NGAdditions.h"

@implementation ContactDetailCell

+ (ContactDetailCell *)cell {
    return [[[NSBundle mainBundle] loadNibNamed:@"ContactDetailCell" owner:self options:nil] lastObject];
}

+ (CGFloat)heigh {
    return 68;
}

- (void)awakeFromNib {

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

@end