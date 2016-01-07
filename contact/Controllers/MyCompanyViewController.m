//
//  NGContactDetailVController.m
//  contact
//
//  Created by Coffee on 14/12/5.
//  Copyright (c) 2014年 momo. All rights reserved.
//

#import "MyCompanyViewController.h"
#import "UIView+NGAdditions.h"
#import "ContactDetailCell.h"
#import "MMCommonAPI.h"
#import "MMSyncThread.h"
#import "MainTabBarController.h"
#import "Organization.h"
#import "APIRequest.h"
#import "MMCommonAPI.h"
#import "MBProgressHUD.h"
#import "Token.h"
#import "MMSyncThread.h"
#import "MMContact.h"
#import <imsdk/IMService.h>
#import <imkit/IMHttpAPI.h>

@interface MyCompanyViewController ()<UITableViewDelegate, UITableViewDataSource>
@property(nonatomic, strong) UITableView *componyTableView;
@property(nonatomic) Organization *organization;
@property(nonatomic, getter=isLogin) BOOL login;
@end

@implementation MyCompanyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消"
                                                                             style:UIBarButtonItemStyleBordered
                                                                            target:self
                                                                            action:@selector(actionLeft:)] ;
    
    

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完成"
                                                                              style:UIBarButtonItemStyleBordered
                                                                             target:self
                                                                             action:@selector(actionRight:)];
    self.navigationItem.rightBarButtonItem.enabled = NO;

    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    //设置导航栏的颜色,不透明,且无底部的2个像素
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    [navigationBar setTranslucent:NO];
    [navigationBar setBackgroundImage:[UIImage new] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [navigationBar setShadowImage:[UIImage new]];
    [self.navigationController.navigationBar setTranslucent:NO];
    [self.view setBackgroundColor:[UIColor colorWithRed:0.894f green:0.910f blue:0.918f alpha:1.00f]];
    
    CGSize viewSize = [[UIScreen mainScreen] bounds].size;
    self.view.frame = CGRectMake(0, 0, viewSize.width, viewSize.height);



    self.navigationItem.title = @"选择组织";

    [self createTableView];

    self.login = ([Token instance].uid > 0);

    if (self.organizations.count == 0) {
        MBProgressHUD *hub = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [APIRequest getOrganizations:^(NSArray *orgs) {
            [hub hide:NO];
            self.organizations = orgs;
            for (Organization *org in self.organizations) {
                if (org.ID == [Token instance].organizationID) {
                    self.organization = org;
                    self.navigationItem.rightBarButtonItem.enabled = YES;
                    break;
                }
            }
            [self.componyTableView reloadData];
        } fail:^{
            [hub hide:NO];
            [MMCommonAPI alert:@"获取组织列表失败"];
        }];
    }

}

- (void)createTableView {
    self.componyTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.width, self.view.height) style:UITableViewStylePlain] ;
    self.componyTableView.delegate = self;
    self.componyTableView.dataSource = self;
    self.componyTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.componyTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.componyTableView.backgroundColor = [UIColor clearColor];
    self.componyTableView.tableFooterView = [UIView new];

    [self.view addSubview:self.componyTableView];
}


- (BOOL)shouldAutorotate {
    return NO;
}

- (void)actionLeft:(id)sender {
    [[self navigationController] popViewControllerAnimated:YES];
}
- (void)actionRight:(id)sender {
    
    if (!self.organization) {
        [MMCommonAPI alert:@"请选择组织"];
        return;
    }
    Organization *org = self.organization;
    
    //组织未变
    if ([Token instance].organizationID == org.ID) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    MBProgressHUD *hub = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    

    [APIRequest loginOrganization:org.ID
                          success:^(int64_t uid, NSString *name, NSString *gobelieveToken) {
                              [hub hide:NO];
                              
                              [Token instance].uid = uid;
                              [Token instance].gobelieveToken = gobelieveToken;
                              [Token instance].name = name;
                              [Token instance].organizationID = org.ID;
                              [Token instance].organizationName = org.name;
                              [[Token instance] save];
                              
                              if (self.isLogin) {
                                  [[MMSyncThread shareInstance] cancel];
                                  [[MMSyncThread shareInstance] wait];
                                  
                                  [[MMContactManager instance] clearContactDB];
                                  
                                  [[IMService instance] stop];
                                  
                                  NSString *deviceToken = [Token instance].deviceToken;
                                  if (deviceToken.length > 0) {
                                      //解除上一个用户和devicetoken的绑定关系，以免接收到上一个用户的离线推送消息
                                      //不处理unbind失败的情况
                                      [Token instance].deviceToken = @"";
                                      [[Token instance] save];
                                      [IMHttpAPI unbindDeviceToken:deviceToken
                                                           success:^{
                                                               NSLog(@"unbind device token success");
                                                           }
                                                              fail:^{
                                                                  NSLog(@"bind device token fail");
                                                              }];
                                  }
                              }
                              
                              MainTabBarController *main = [[MainTabBarController alloc] init];
                              [UIApplication sharedApplication].keyWindow.rootViewController = main;
                          }
                             fail:^{
                                 [hub hide:NO];
                                 [MMCommonAPI alert:@"登陆组织失败，请检查网络"];
                             }];
}

#pragma mark -
#pragma mark UITableViewDataSource Methods
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UILabel* nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 14, 190, 40)];
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.font = [UIFont fontWithName:@"Helvetica" size:16];
        nameLabel.tag = 2;
        [cell.contentView addSubview:nameLabel];

        
        UIImage *image = [UIImage imageNamed:@"unchecked"];
        UIImageView* checkImageView = [[UIImageView alloc] initWithFrame:CGRectMake(260, 24, image.size.width, image.size.height)];
        checkImageView.image = image;
        checkImageView.tag = 3;
        [cell.contentView addSubview:checkImageView];

    }
    
    Organization *org = [self.organizations objectAtIndex:indexPath.row];
    UILabel* nameLabel = (UILabel*)[cell.contentView viewWithTag:2];

    nameLabel.text = org.name;
	UIImageView* checkImageView = (UIImageView*)[cell.contentView viewWithTag:3];
    
    
    if (self.organization == org) {
        checkImageView.image = [UIImage imageNamed:@"checked"];
    } else {
        checkImageView.image = [UIImage imageNamed:@"unchecked"];
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.organizations.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.navigationItem.rightBarButtonItem.enabled = YES;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Organization *oldOrg = self.organization;
    Organization *org = self.organizations[indexPath.row];
    self.organization = org;
    
    if (self.organization == oldOrg) {
        return;
    }
    
    if (oldOrg) {
        NSUInteger i = [self.organizations indexOfObject:oldOrg];
        NSIndexPath *index = [NSIndexPath indexPathForRow:i inSection:0];
        
        UITableViewCell* cell = [tableView cellForRowAtIndexPath:index];
        UIImageView* checkImageView = (UIImageView*)[cell.contentView viewWithTag:3];
        checkImageView.image = [UIImage imageNamed:@"unchecked"];
    }

    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    UIImageView* checkImageView = (UIImageView*)[cell.contentView viewWithTag:3];
    checkImageView.image = [UIImage imageNamed:@"checked"];
}


@end
