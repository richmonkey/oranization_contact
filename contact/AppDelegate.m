//
//  AppDelegate.m
//  contact
//
//  Created by houxh on 14-11-4.
//  Copyright (c) 2014年 momo. All rights reserved.
//

#import "AppDelegate.h"
#import "Token.h"
#import "LoginViewController.h"
#import "MainTabBarController.h"

#import <gobelieve/IMService.h>
#import <gobelieve/PeerMessageHandler.h>
#import <gobelieve/GroupMessageHandler.h>
#import <gobelieve/PeerMessageDB.h>
#import <gobelieve/GroupMessageDB.h>
#import <gobelieve/IMHttpAPI.H>


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [IMService instance].deviceID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSLog(@"device id:%@", [[[UIDevice currentDevice] identifierForVendor] UUIDString]);
    [IMService instance].peerMessageHandler = [PeerMessageHandler instance];
    [IMService instance].groupMessageHandler = [GroupMessageHandler instance];
    [[IMService instance] startRechabilityNotifier];
    
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

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    [[IMService instance] enterBackground];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    [[IMService instance] enterForeground];
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    //register to receive notifications
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didRegisterForRemoteNotificationsWithDeviceToken"
                                                        object:deviceToken];


}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"didFailToRegisterForRemoteNotificationsWithError:%@", error);
}

- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo
fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))handler {
    handler(UIBackgroundFetchResultNoData);
}
@end
