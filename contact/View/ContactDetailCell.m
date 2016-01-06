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

- (void)dealloc {
    [_actionRightBtn release];
    [super dealloc];
}
@end