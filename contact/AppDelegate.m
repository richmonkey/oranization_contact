//
//  AppDelegate.m
//  contact
//
//  Created by houxh on 14-11-4.
//  Copyright (c) 2014年 momo. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"
#import "NGContactListVController.h"
#import "Token.h"
#import "MainTabBarController.h"

#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Either turn on ARC for the project or use -fobjc-arc flag
#endif
@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    application.statusBarHidden = NO;

    Token *token = [Token instance];
    if (token.accessToken && token.uid > 0) {
        MainTabBarController *root = [[MainTabBarController alloc] init];
        self.window.rootViewController = root;
    } else {
        LoginViewController *loginVController = [[LoginViewController alloc] init];
        UINavigationController * navCtr = [[UINavigationController alloc] initWithRootViewController: loginVController];
        self.window.rootViewController = navCtr;
    }

    [self initAppAppearance];

    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];

    return YES;
}

- (void)initAppAppearance {
    //UINavigation Bar

    //标题白色
    [[UINavigationBar appearance] setTitleTextAttributes:
     @{ NSForegroundColorAttributeName: [UIColor whiteColor],
        NSFontAttributeName: [UIFont boldSystemFontOfSize:21],
        }];

    //状态栏设置为白色
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

    [[UINavigationBar appearance] setShadowImage:[UIImage new]];

    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:0.137f green:0.773f blue:0.694f alpha:1.00f]];
    [[UINavigationBar appearance] setBackgroundColor:[UIColor colorWithRed:0.137f green:0.773f blue:0.694f alpha:1.00f]];
}

@end
