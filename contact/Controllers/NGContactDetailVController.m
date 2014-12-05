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

@interface NGContactDetailVController ()<UITableViewDelegate, UITableViewDataSource>
@property(nonatomic, strong) UITableView *infoTableView;

@end

@implementation NGContactDetailVController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

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

    switch (indexPath.row) {
        case 0:
            cell.tipLabel.text = @"姓名";
            cell.contentLabel.text = self.fullContact.fullName;
            break;
        case 1:
            cell.tipLabel.text = @"职位";
            cell.contentLabel.text = self.fullContact.jobTitle;
            break;
        case 2:
            cell.tipLabel.text = @"电话";
            cell.contentLabel.text = self.fullContact.fullName;
            break;
        case 3:
            cell.tipLabel.text = @"邮箱";
            cell.contentLabel.text = self.fullContact.fullName;
            break;
        case 4:
            cell.tipLabel.text = @"地址";
            cell.contentLabel.text = self.fullContact.fullName;
            break;
        case 5:
            cell.tipLabel.text = @"微信";
            cell.contentLabel.text = self.fullContact.fullName;
            break;
        default:
            break;
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [ContactDetailCell heigh];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 6;
}
@end
