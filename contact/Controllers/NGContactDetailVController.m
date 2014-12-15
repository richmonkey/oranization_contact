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
    self.infoTableView.tableFooterView = [[UIView alloc] init];
    self.infoTableView.canCancelContentTouches = NO;
    [self.view addSubview:self.infoTableView];
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
