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

@interface MyCompanyVController ()<UITableViewDelegate, UITableViewDataSource>
@property(nonatomic, strong) UITableView *componyTableView;
@property(nonatomic, strong) NSArray *componyArray;

@end

@implementation MyCompanyVController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

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
    cell.actionRightBtn.hidden = YES;

    NSArray *componyArray = [MMCommonAPI myComponyArray];
    cell.tipLabel.text = componyArray[indexPath.row];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [ContactDetailCell heigh];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *componyArray = [MMCommonAPI myComponyArray];
    return componyArray.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *componyArray = [MMCommonAPI myComponyArray];
    NSString *curComponyName = componyArray[indexPath.row];

    [MMCommonAPI setCurComponyName:curComponyName];
}

-(void)actionLeft {
    [self dismissViewControllerAnimated:YES completion:^{
        nil;
    }];
}

@end
