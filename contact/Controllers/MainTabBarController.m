//
//  MainTabBarController.m
//  contact
//
//  Created by houxh on 15/12/29.
//  Copyright © 2015年 momo. All rights reserved.
//

#import "MainTabBarController.h"

#import <gobelieve/IMService.h>
#import <gobelieve/PeerMessageViewController.h>
#import <gobelieve/MessageDB.h>
#import <gobelieve/IMHttpAPI.h>
#import <gobelieve/PeerMessageDB.h>
#import <gobelieve/GroupMessageDB.h>
#import <gobelieve/PeerMessageHandler.h>
#import <gobelieve/GroupMessageHandler.h>
#import <gobelieve/SyncKeyHandler.h>
#import "MessageListViewController.h"
#import "ContactListVController.h"
#import "MMContact.h"
#import "Token.h"
#import "ContactCache.h"
//RGB颜色
#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]
//RGB颜色和不透明度
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f \
alpha:(a)]

@interface MainTabBarController ()<MessageViewControllerUserDelegate, MessageListViewControllerGroupDelegate>

@end

@implementation MainTabBarController

-(NSString*)getDocumentPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

-(BOOL)mkdir:(NSString*)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:path]) {
        NSError *err;
        BOOL r = [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&err];
        
        if (!r) {
            NSLog(@"mkdir err:%@", err);
        }
        return r;
    }
    
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    //启动im
    Token *token = [Token instance];
    NSString *path = [self getDocumentPath];
    NSString *dbPath = [NSString stringWithFormat:@"%@/%lld", path, token.uid];
    [self mkdir:dbPath];
    
    [PeerMessageDB instance].dbPath = [NSString stringWithFormat:@"%@/peer", dbPath];
    [GroupMessageDB instance].dbPath = [NSString stringWithFormat:@"%@/group", dbPath];
    
    [IMHttpAPI instance].accessToken = token.gobelieveToken;
    [IMService instance].token = token.gobelieveToken;
    
    [PeerMessageHandler instance].uid = token.uid;
    [GroupMessageHandler instance].uid = token.uid;
    
    NSString *fileName = [NSString stringWithFormat:@"%@/synckey", dbPath];
    SyncKeyHandler *handler = [[SyncKeyHandler alloc] initWithFileName:fileName];
    [IMService instance].syncKeyHandler = handler;
    
    [IMService instance].syncKey = [handler syncKey];
    NSLog(@"sync key:%lld", [handler syncKey]);
    
    [[IMService instance] clearSuperGroupSyncKey];
    NSDictionary *groups = [handler superGroupSyncKeys];
    for (NSNumber *k in groups) {
        NSNumber *v = [groups objectForKey:k];
        NSLog(@"group id:%@ sync key:%@", k, v);
        [[IMService instance] addSuperGroupSyncKey:[v longLongValue] gid:[k longLongValue]];
    }
    [[IMService instance] start];
    
    //加载联系人到cache中
    ContactCache *cache = [ContactCache instance];
    MMErrorType error = 0;
    cache.contacts = [[MMContactManager instance] getSimpleContactList:&error];

    
    //创建界面
    ContactListVController *contactViewController = [[ContactListVController alloc] init];
    contactViewController.tabBarItem.title = @"联系人";
    contactViewController.tabBarItem.selectedImage = [UIImage imageNamed:@"tabbar_contacts"];
    contactViewController.tabBarItem.image = [UIImage imageNamed:@"tabbar_contacts"];
    
    UINavigationController *nav0 = [[UINavigationController alloc] initWithRootViewController:contactViewController];
    
    
    MessageListViewController *msgController = [[MessageListViewController alloc] init];
    msgController.currentUID = token.uid;
    msgController.userDelegate = self;
    msgController.groupDelegate = self;
    
    msgController.tabBarItem.title = @"对话";
    msgController.tabBarItem.selectedImage = [UIImage imageNamed:@"TabBarIconChatsOn"];
    msgController.tabBarItem.image = [UIImage imageNamed:@"TabBarIconChatsOff"];

    UINavigationController *nav1 = [[UINavigationController alloc] initWithRootViewController:msgController];
    
    self.viewControllers = [NSArray arrayWithObjects:nav0, nav1, nil];
    self.selectedIndex = 1;

    //加载view
    (void)contactViewController.view;
    (void)msgController.view;
    
    [[self tabBar] setTintColor:RGBACOLOR(48,176,87, 1)];
    [[self tabBar] setBarTintColor:RGBACOLOR(245, 245, 246, 1)];
    
    UIApplication *application = [UIApplication sharedApplication];
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeAlert
                                                                                             | UIUserNotificationTypeBadge
                                                                                             | UIUserNotificationTypeSound) categories:nil];
        [application registerUserNotificationSettings:settings];
        
    } else {
        UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound;
        [application registerForRemoteNotificationTypes:myTypes];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRegisterForRemoteNotificationsWithDeviceToken:) name:@"didRegisterForRemoteNotificationsWithDeviceToken" object:nil];
}

-(void)dealloc {
    NSLog(@"main tab bar dealloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)didRegisterForRemoteNotificationsWithDeviceToken:(NSNotification*)notification {
    NSData *deviceToken = (NSData*)notification.object;
    
    NSString* newToken = [deviceToken description];
    newToken = [newToken stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    newToken = [newToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    [IMHttpAPI bindDeviceToken:newToken
                       success:^{
                           NSLog(@"bind device token success");
                           [Token instance].deviceToken = newToken;
                           [[Token instance] save];
                       }
                          fail:^{
                              NSLog(@"bind device token fail");
                          }];
    NSLog(@"device token is: %@:%@", deviceToken, newToken);
    
}


- (void)onEndSync:(NSNotification*)notification {
    NSLog(@"onEndSync");
    BOOL r = [[notification.object objectForKey:@"result"] boolValue];
    if (!r) {
        return;
    }else {
        BOOL changed = [[notification.object objectForKey:@"changed"] boolValue];
        if (!changed) {
            return;
        }else {
        
        }
    }
}

//从本地获取用户信息, IUser的name字段为空时，显示identifier字段
- (IUser*)getUser:(int64_t)uid {
    IUser *u = [[IUser alloc] init];
    u.uid = uid;
    u.identifier = [NSString stringWithFormat:@"%lld", uid];
    ContactCache *cache = [ContactCache instance];
    for (DbContactSimple *c in cache.contacts) {
        if (c.contactId == uid) {
            u.name = c.fullName;
            break;
        }
    }
    NSLog(@"user name:%@", u.name);
    return u;
}
//从服务器获取用户信息
- (void)asyncGetUser:(int64_t)uid cb:(void(^)(IUser*))cb {
    NSLog(@"async get user...");
}

//从本地获取群组信息
- (IGroup*)getGroup:(int64_t)gid {
    return nil;
}
//从服务器获取用户信息
- (void)asyncGetGroup:(int64_t)gid cb:(void(^)(IGroup*))cb {
    
}
@end
