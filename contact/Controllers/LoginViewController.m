//
//  LoginViewController.m
//  contact
//
//  Created by Coffee on 14/11/16.
//  Copyright (c) 2014年 momo. All rights reserved.
//

#import "LoginViewController.h"
#import "AppDelegate.h"
#import "MMCommonAPI.h"
#import "SVProgressHUD.h"
#import "UIImage+NGAdditions.h"
#import "UIButton+NGAdditions.h"
#import "SVProgressHUD.h"
#import "NGAddition.h"
#import "NGContactListVController.h"
#import "APIRequest.h"
#import "Token.h"

#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Either turn on ARC for the project or use -fobjc-arc flag
#endif

@interface LoginViewController () <UITextFieldDelegate>
@property (strong, nonatomic) UITextField *accountField;
@property (strong, nonatomic) UITextField *secretField;
@property (strong, nonatomic) UIButton *nextBtn;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = @"登录";
    self.leftButton.hidden = YES;

    //手机号码
	UIImageView* backImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 30, 320, 50)] ;
	backImage.userInteractionEnabled = YES;
    backImage.backgroundColor = [UIColor whiteColor];
	_accountField = [[UITextField alloc] initWithFrame: CGRectMake(20, 12, 280, 30)] ;
	_accountField.borderStyle = UITextBorderStyleNone;
	_accountField.textAlignment = NSTextAlignmentLeft;
    _accountField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@" 输入公司账号" attributes:@{NSForegroundColorAttributeName: [UIColor colorWithRed:0.702f green:0.702f blue:0.702f alpha:1.00f], NSFontAttributeName: [UIFont systemFontOfSize:17]}];
    _accountField.font = [UIFont systemFontOfSize:17];
    _accountField.keyboardType = UIKeyboardTypeASCIICapable;
    _accountField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _accountField.textColor = [UIColor blackColor];
    _accountField.returnKeyType = UIReturnKeyDone;
    [_accountField becomeFirstResponder];
    _accountField.delegate = self;
	[backImage addSubview:_accountField];
    [self.view addSubview:backImage];
    [_accountField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];

    //手机号码
    backImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 100, 320, 50)] ;
    backImage.userInteractionEnabled = YES;
    backImage.backgroundColor = [UIColor whiteColor];
    _secretField = [[UITextField alloc] initWithFrame: CGRectMake(20, 12, 280, 30)] ;
    _secretField.borderStyle = UITextBorderStyleNone;
    _secretField.textAlignment = NSTextAlignmentLeft;
    _secretField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@" 输入授权码" attributes:@{NSForegroundColorAttributeName: [UIColor colorWithRed:0.702f green:0.702f blue:0.702f alpha:1.00f], NSFontAttributeName: [UIFont systemFontOfSize:17]}];
    _secretField.font = [UIFont systemFontOfSize:17];
    _secretField.keyboardType = UIKeyboardTypePhonePad;
    _secretField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _secretField.textColor = [UIColor blackColor];
    _secretField.returnKeyType = UIReturnKeyDone;
    [_secretField becomeFirstResponder];
    _secretField.delegate = self;
    [backImage addSubview:_secretField];
    [self.view addSubview:backImage];
    [_secretField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];


	self.nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.nextBtn.frame = CGRectMake(15, 160, 290, 48);
	[self.nextBtn setBackgroundImage: [UIImage imageWithStretchName:@"btn_green" top:20 left:5] forState:UIControlStateNormal];
    [self.nextBtn setBackgroundImage: [UIImage imageWithStretchName:@"btn_grey@" top:20 left:5] forState:UIControlStateDisabled];
    [self.nextBtn setBackgroundImage: [UIImage imageWithStretchName:@"btn_green_press" top:20 left:5] forState:UIControlStateHighlighted];
	[self.nextBtn setTitle:@"下一步" forState:UIControlStateNormal];
    [self.nextBtn addTarget:self action:@selector(actionLogin) forControlEvents:UIControlEventTouchUpInside];
    [self.nextBtn setEnabled:NO];
    [self.view addSubview: self.nextBtn];
}


- (void) textFieldDidChange:(id) sender {
    if (![_accountField.text isEmpty] && ![_secretField.text isEmpty] ) {
        self.nextBtn.enabled = YES;
    }else {
        self.nextBtn.enabled = NO;
    }
}


- (BOOL)textFieldShouldClear:(UITextField *)textField {
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)actionLogin {
    NSString* account = _accountField.text;
    account = [account stringByReplacingOccurrencesOfString:@" " withString:@""];

    NSString* secret = _secretField.text;
    secret = [secret stringByReplacingOccurrencesOfString:@" " withString:@""];

    [SVProgressHUD showWithStatus:@"请求中" maskType:SVProgressHUDMaskTypeBlack];

    [APIRequest signInByEmail:account password:secret success:^(int64_t uid, NSString *accessToken, NSString *refreshToken, int expireTimestamp, NSString *state) {
        NSLog(@"auth token success");
        Token *token = [Token instance];
        token.accessToken = accessToken;
        token.refreshToken = refreshToken;
        token.expireTimestamp = expireTimestamp;
        token.uid = uid;
        [token save];
        [SVProgressHUD dismiss];

        NGContactListVController *viewController = [NGContactListVController new];
        [self.navigationController pushViewController:viewController animated:YES];
    } fail:^{
        NSLog(@"sign in error");

        [SVProgressHUD dismiss];
    }];
}

@end
