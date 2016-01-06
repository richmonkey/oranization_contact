//
//  MainTabBarController.m
//  contact
//
//  Created by houxh on 15/12/29.
//  Copyright © 2015年 momo. All rights reserved.
//

#import "MainTabBarController.h"
#import "NGContactListVController.h"

//RGB颜色
#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]
//RGB颜色和不透明度
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f \
alpha:(a)]

@interface MainTabBarController ()

@end

@implementation MainTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NGContactListVController *ctl = [[NGContactListVController alloc] init];
    ctl.tabBarItem.title = @"通讯录";

    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:ctl];
    
    self.viewControllers = [NSArray arrayWithObjects:nav, nil];
    self.selectedIndex = 0;
    
    
    
    UITabBarItem *tabBarItem = [[UITabBarItem alloc] initWithTitle:@"联系人"
                                               image:[UIImage imageNamed:@"tabbar_contacts"]
                                                 tag:11];
    ctl.tabBarItem = tabBarItem;
    
    
    [[self tabBar] setTintColor:RGBACOLOR(48,176,87, 1)];
    [[self tabBar] setBarTintColor:RGBACOLOR(245, 245, 246, 1)];
}

-(void)dealloc {
    NSLog(@"main tab bar dealloc");
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
