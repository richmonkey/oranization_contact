//
//  NGContactDetailVController.m
//  contact
//
//  Created by Coffee on 14/12/5.
//  Copyright (c) 2014年 momo. All rights reserved.
//

#import "MyCompanyVController.h"
#import "UIView+NGAdditions.h"
#import "ContactDetailCell.h"
#import "MMCommonAPI.h"
#import "MMSyncThread.h"

@interface MyCompanyVController ()<UITableViewDelegate, UITableViewDataSource>
@property(nonatomic, strong) UITableView *componyTableView;
@property(nonatomic, strong) NSMutableArray *componyArray;

@end

@implementation MyCompanyVController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.componyArray = [NSMutableArray array];
    self.componyArray = [NSMutableArray arrayWithArray:[[MMContactManager instance] getCompanyList:nil]];

    self.navigationItem.title = @"切换公司";
    self.leftButton.hidden = NO;
    [self createTableView];

}

- (void)createTableView {
    self.componyTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.width, self.view.height) style:UITableViewStylePlain] ;
    self.componyTableView.delegate = self;
    self.componyTableView.dataSource = self;
    self.componyTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.componyTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.componyTableView.backgroundColor = [UIColor clearColor];

    [self.view addSubview:self.componyTableView];
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
    if ([[MMCommonAPI curComponyName] isEqualToString:self.componyArray[indexPath.row]]) {
        cell.actionRightBtn.hidden = NO;
        [cell.actionRightBtn setImage:[UIImage imageNamed:@"公司选中"] forState:UIControlStateNormal];
    }else {
        cell.actionRightBtn.hidden = YES;
    }

    cell.contentLabel.text = self.componyArray[indexPath.row];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [ContactDetailCell heigh];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.componyArray.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    NSString *curComponyName = self.componyArray[indexPath.row];

    if (![[MMCommonAPI curComponyName] isEqualToString:curComponyName]) {
        [MMCommonAPI setCurComponyName:curComponyName];
        [[NSNotificationCenter defaultCenter] postNotificationName:KMMComponyChange object: nil userInfo:nil];
    }

    [self dismissViewControllerAnimated:YES completion:^{
        nil;
    }];
}

-(void)actionLeft {
    [self dismissViewControllerAnimated:YES completion:^{
        nil;
    }];
}

@end
