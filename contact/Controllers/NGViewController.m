//
//  NGViewController.m
//  newgame
//
//  Created by shichangone on 6/5/14.
//  Copyright (c) 2014 ngds. All rights reserved.
//

#import "NGViewController.h"
#import "UIButton+NGAdditions.h"

#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Either turn on ARC for the project or use -fobjc-arc flag
#endif

@interface NGViewController ()<UIGestureRecognizerDelegate>

@end

@implementation NGViewController

- (void)viewDidLoad {
    [super viewDidLoad];


    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _leftButton = [UIButton buttonWithImageName:@"nav_back"];
    [_leftButton addTarget:self action:@selector(actionLeft) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_leftButton];

    _rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_rightButton setTitleColor:[UIColor colorWithRed:0.529f green:0.808f blue:0.749f alpha:1.00f] forState:UIControlStateDisabled];
    [_rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
    _rightButton.titleLabel.font = [UIFont systemFontOfSize:13];
    [_rightButton setFrame:CGRectMake(0, 5, 50, 44)];
    [_rightButton addTarget:self action:@selector(actionRight) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_rightButton];

    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }

    //设置导航栏的颜色,不透明,且无底部的2个像素
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    [navigationBar setTranslucent:NO];
    [navigationBar setBackgroundImage:[UIImage new] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [navigationBar setShadowImage:[UIImage new]];
    [self.navigationController.navigationBar setTranslucent:NO];
    [self.view setBackgroundColor:[UIColor colorWithRed:0.894f green:0.910f blue:0.918f alpha:1.00f]];

    CGSize viewSize = [[UIScreen mainScreen] bounds].size;
    self.view.frame = CGRectMake(0, 0, viewSize.width, viewSize.height);
}


- (BOOL)shouldAutorotate {
    return NO;
}

#pragma mark - Public

-(void)actionLeft {
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)actionRight {

}

//处理自定义返回键后系统滑动返回失效的问题
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    self.navigationController.interactivePopGestureRecognizer.delegate = self;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([self isRootViewController]) {
        return NO;
    } else {
        return YES;
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return [gestureRecognizer isKindOfClass:UIScreenEdgePanGestureRecognizer.class];
}

#pragma mark - Private
- (BOOL)isRootViewController {
    return (self == self.navigationController.viewControllers.firstObject);
}
@end
