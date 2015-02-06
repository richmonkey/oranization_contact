//
//  NGContactDetailVController.m
//  contact
//
//  Created by Coffee on 14/12/5.
//  Copyright (c) 2014年 momo. All rights reserved.
//

#import "NGContactDetailVController.h"
#import "UIView+NGAdditions.h"
#import "ContactDetailCell.h"
#import <AddressBook/AddressBook.h>
#import "JSON.h"
#import "MMAddressBook.h"
#import "UIImage+NGAdditions.h"
#import "MMCommonAPI.h"

@interface NGContactDetailVController ()<UITableViewDelegate, UITableViewDataSource>
@property(nonatomic, strong) UITableView *infoTableView;
@property(nonatomic, strong) NSString *curPhone;

@end

@implementation NGContactDetailVController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.navigationItem.title = @"详细信息";
    self.leftButton.hidden = NO;
    [self createTableView];
}

- (void)createTableView {
    self.infoTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.width, self.view.height) style:UITableViewStylePlain] ;
    self.infoTableView.delegate = self;
    self.infoTableView.dataSource = self;
    self.infoTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.infoTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.infoTableView.backgroundColor = [UIColor clearColor];

    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(20, 0, self.view.width-40, 68)];
    footerView.backgroundColor = [UIColor clearColor];

    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 20, footerView.width, 48);
    [button setBackgroundImage: [UIImage imageWithStretchName:@"btn_green" top:20 left:5] forState:UIControlStateNormal];
    [button setBackgroundImage: [UIImage imageWithStretchName:@"btn_grey@" top:20 left:5] forState:UIControlStateDisabled];
    [button setBackgroundImage: [UIImage imageWithStretchName:@"btn_green_press" top:20 left:5] forState:UIControlStateHighlighted];
    [button setTitle:@"保存到本地" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(add) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:button];

    self.infoTableView.tableFooterView = footerView;
    self.infoTableView.canCancelContentTouches = NO;
    [self.view addSubview:self.infoTableView];
}

-(void)add {
    CFErrorRef err = nil;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &err);
    if (err) {
        NSString *s = (__bridge NSString*)CFErrorCopyDescription(err);
        NSLog(@"address book error:%@", s);
        return;
    }
    
    ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
    if (status == kABAuthorizationStatusNotDetermined) {
        NSLog(@"not determined");
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            NSLog(@"grant:%d", granted);
            if (granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    int32_t phoneID = 0;
                    MMABErrorType err = [MMAddressBook insertContact:self.fullContact withDataList:self.fullContact.properties returnCellId:&phoneID];
                    if (err != MM_AB_OK) {
                        NSLog(@"save error");
                        [MMCommonAPI alert:@"保存失败"];
                    } else {
                        [MMCommonAPI alert:@"保存成功"];
                        NSLog(@"save ok");
                    }
                });
            }
        });
    } else if (status == kABAuthorizationStatusAuthorized){
        int32_t phoneID = 0;
        MMABErrorType err = [MMAddressBook insertContact:self.fullContact withDataList:self.fullContact.properties returnCellId:&phoneID];
        if (err != MM_AB_OK) {
            NSLog(@"save error");
            [MMCommonAPI alert:@"保存失败"];
        } else {
            [MMCommonAPI alert:@"保存成功"];
            NSLog(@"save ok:%d", phoneID);
        }
    } else {
        [MMCommonAPI alert:@"无通讯录访问权限"];
        NSLog(@"no addressbook authorization");
    }
    CFRelease(addressBook);
}

#pragma mark -
#pragma mark UITableViewDataSource Methods
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ContactDetailCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [ContactDetailCell cell];
    }

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.actionLfetBtn.hidden = YES;
    cell.actionRightBtn.hidden = YES;

    if (indexPath.row == 0) {
        cell.tipLabel.text = @"姓名";
        cell.contentLabel.text = self.fullContact.fullName;
    }else if (indexPath.row == 1) {
        cell.tipLabel.text = @"职位";
        cell.contentLabel.text = self.fullContact.jobTitle;
    }else {
        DbData *contactData = self.fullContact.properties[indexPath.row-2];
        switch(contactData.property){
            case kMoTel: {
                cell.tipLabel.text = @"电话";
                cell.contentLabel.text = contactData.value;
                self.curPhone = contactData.value;
                cell.actionLfetBtn.hidden = YES;
                cell.actionRightBtn.hidden = NO;
                [cell.actionRightBtn addTarget:self action:@selector(actionSMS) forControlEvents:UIControlEventTouchUpInside];
                cell.actionLfetBtn.hidden = NO;
                [cell.actionLfetBtn addTarget:self action:@selector(actionPhone) forControlEvents:UIControlEventTouchUpInside];
            }
                break;
            case kMoMail: {
                cell.tipLabel.text = @"邮箱";
                cell.contentLabel.text = contactData.value;
                cell.actionLfetBtn.hidden = YES;
            }
                break;
            case kMoAdr: {
                SBJSON* sbjson = [SBJSON new];
                NSMutableArray *listItems = [sbjson objectWithString:contactData.value];
                [sbjson release];

                NSMutableDictionary* dictKey = [NSMutableDictionary dictionary];
                [dictKey setObject:(NSString*)kABPersonAddressStreetKey forKey:[NSString stringWithFormat:@"%d", 2]];
                [dictKey setObject:(NSString*)kABPersonAddressCityKey forKey:[NSString stringWithFormat:@"%d", 3]];
                [dictKey setObject:(NSString*)kABPersonAddressStateKey forKey:[NSString stringWithFormat:@"%d", 4]];
                [dictKey setObject:(NSString*)kABPersonAddressZIPKey forKey:[NSString stringWithFormat:@"%d", 5]];
                [dictKey setObject:(NSString*)kABPersonAddressCountryKey forKey:[NSString stringWithFormat:@"%d", 6]];

                NSMutableDictionary* addressDict = [NSMutableDictionary dictionary];
                for(int i = 2; i < 7; i++) {
                    NSString* str = [listItems objectAtIndex:i];
                    if(str && ![str isEqualToString:@""])
                        [addressDict setObject:str forKey:(NSString*)[dictKey valueForKey:[NSString stringWithFormat:@"%d", i]]];
                }


                cell.tipLabel.text = @"地址";
                cell.contentLabel.text = contactData.value;
                cell.actionLfetBtn.hidden = YES;
            }
                break;
            case kMoBday: {
                if(contactData.value && ![contactData.value isEqualToString:@""]) {
                    NSDateFormatter* formater = [NSDateFormatter new];
                    [formater setDateFormat:@"YYYY-MM-dd"];
                    NSDate* date = [formater dateFromString:contactData.value];
                    [formater release];
                    if (date)
                        cell.tipLabel.text = @"生日";
                       cell.contentLabel.text = contactData.value;
                    }
                }
                break;
            case kMoImQQ:{
                cell.tipLabel.text = @"QQ";
                cell.contentLabel.text = contactData.value;
                cell.actionLfetBtn.hidden = YES;
                break;
      
            }
            case kMoImWeChat:
                cell.tipLabel.text = @"微信";
                cell.contentLabel.text = contactData.value;
                cell.actionLfetBtn.hidden = YES;
                break;
        }
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [ContactDetailCell heigh];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2 + [self.fullContact.properties count];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0: {

        }
            break;
        case 1:
            break;
        case 2:
            break;
        case 3:
            break;
        case 4:
            break;
        case 5:
            break;
        default:
            break;
    }
}

- (void)actionSMS {
    NSURL *phoneUrl = [NSURL URLWithString:[NSString  stringWithFormat:@"sms://%@", self.curPhone]];
    [[UIApplication sharedApplication] openURL:phoneUrl];
}

- (void)actionPhone {
    NSURL *phoneUrl = [NSURL URLWithString:[NSString  stringWithFormat:@"tel://%@", self.curPhone]];
    if ([[UIApplication sharedApplication] canOpenURL:phoneUrl]) {
        [[UIApplication sharedApplication] openURL:phoneUrl];
    }
}

@end
