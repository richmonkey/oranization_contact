//
//  NGContactListVController.m
//  contact
//
//  Created by Coffee on 14/11/30.
//  Copyright (c) 2014年 momo. All rights reserved.
//

#import "NGContactListVController.h"
#import "UIView+NGAdditions.h"
#import "DbStruct.h"
#import "MMCommonAPI.h"
#import "ContactListCell.h"
#import "MMContact.h"
#import <AddressBook/AddressBook.h>
#import "MMAddressBook.h"
#import "MMSyncThread.h"
#import "NGContactDetailVController.h"
#import "APIRequest.h"
#import "Token.h"
#import "LoginViewController.h"
#import "MyCompanyViewController.h"

@interface NGContactListVController ()<UITableViewDelegate, UISearchBarDelegate,UISearchDisplayDelegate,
UITableViewDataSource>
@property(nonatomic)dispatch_source_t refreshTimer;
@property(nonatomic)int refreshFailCount;

@property(nonatomic, strong) UITableView *contactTable;
@property (strong, nonatomic) UISearchDisplayController* searchController;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) NSArray *contactArray;
@property (nonatomic, strong) NSMutableArray *searchArray;
@property (nonatomic, strong) NSMutableDictionary *contactsDictionary;
@property (nonatomic, strong) NSMutableArray *contactNameIndexArray;
@property (nonatomic, strong) NSMutableDictionary *filterContactsDictionary;
@property (nonatomic, strong) NSMutableArray *filterContactNameIndexArray;

@end

@implementation NGContactListVController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSNotificationCenter * center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(onEndSync:) name:kMMEndSync object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onComponyChange:) name:KMMComponyChange object:nil];

    self.contactArray = [NSArray array];
    self.searchArray = [NSMutableArray array];
    self.contactsDictionary = [NSMutableDictionary dictionary];
    self.contactNameIndexArray = [NSMutableArray array];
    self.filterContactsDictionary = [NSMutableDictionary dictionary];
    self.filterContactNameIndexArray = [NSMutableArray array];

    
    UIBarButtonItem *refreshItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(actionRefresh)];
    self.navigationItem.rightBarButtonItem = refreshItem;
    
    UIBarButtonItem *moreItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(actionLeft)];
    self.navigationItem.leftBarButtonItem = moreItem;
    
    [self createCustomView];
    
    [[MMSyncThread shareInstance] start];
    [self initContactArray];
    
    __weak NGContactListVController *wself = self;
    dispatch_queue_t queue = dispatch_get_main_queue();
    self.refreshTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_event_handler(self.refreshTimer, ^{
        [wself refreshAccessToken];
    });
    [self startRefreshTimer];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)prepareTimer {
    Token *token = [Token instance];
    int now = (int)time(NULL);
    if (now >= token.expireTimestamp - 1) {
        dispatch_time_t w = dispatch_walltime(NULL, 0);
        dispatch_source_set_timer(self.refreshTimer, w, DISPATCH_TIME_FOREVER, 0);
    } else {
        dispatch_time_t w = dispatch_walltime(NULL, (token.expireTimestamp - now - 1)*NSEC_PER_SEC);
        dispatch_source_set_timer(self.refreshTimer, w, DISPATCH_TIME_FOREVER, 0);
    }
}

-(void)startRefreshTimer {
    [self prepareTimer];
    dispatch_resume(self.refreshTimer);
}

-(void)refreshAccessToken {
    Token *token = [Token instance];
    if (!token.accessToken) {
        return;
    }
    [APIRequest refreshAccessToken:token.refreshToken
                           success:^(NSString *accessToken, NSString *refreshToken, int expireTimestamp) {
                               token.accessToken = accessToken;
                               token.refreshToken = refreshToken;
                               token.expireTimestamp = expireTimestamp;
                               [token save];
                               [self prepareTimer];
                               
                           }
                              fail:^{
                                  self.refreshFailCount = self.refreshFailCount + 1;
                                  int64_t timeout;
                                  if (self.refreshFailCount > 60) {
                                      timeout = 60*NSEC_PER_SEC;
                                  } else {
                                      timeout = (int64_t)self.refreshFailCount*NSEC_PER_SEC;
                                  }
                                  
                                  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, timeout), dispatch_get_main_queue(), ^{
                                      [self prepareTimer];
                                  });
                                  
                              }];
}



- (void)createCustomView {
    [self createTableView];
    [self createHeaderView];
}

- (void)createTableView {
    _contactTable = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.width, self.view.height) style:UITableViewStylePlain] ;
    _contactTable.delegate = self;
    _contactTable.dataSource = self;
    _contactTable.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _contactTable.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    _contactTable.backgroundColor = [UIColor clearColor];
    _contactTable.tableFooterView = [[UIView alloc] init];
    _contactTable.canCancelContentTouches = NO;
    [self.view addSubview:_contactTable];
}


- (void)createHeaderView {
    //搜索区域
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    _searchBar.backgroundColor=[UIColor clearColor];
    _searchBar.delegate = self;
    _searchBar.placeholder = @"搜索联系人";
    self.searchController = [[UISearchDisplayController alloc] initWithSearchBar:_searchBar contentsController:self];
    self.searchController.delegate = self;
    self.searchController.searchResultsDelegate = self;
    self.searchController.searchResultsDataSource = self;

    self.contactTable.tableHeaderView = _searchBar;
}

- (void)initContactArray {
    //获取本地联系人
    [self updateContactArray];

    //初次加载,本地联系人空时候进行同步
    NSArray *companyNames = [[MMContactManager instance] getCompanyList:nil];
    if (!companyNames.count) {
        [self synContanct];
    }
}

//用于切换公司,同步完成时候刷新数据
- (void)updateContactArray {
    self.navigationItem.title = [Token instance].organizationName;
    MMErrorType error = 0;
    self.contactArray = [[MMContactManager instance] getSimpleContactList:&error];
    [self sortByIndex:self.contactArray];
    [self.contactTable reloadData];
}

- (void)synContanct {
    //wait sync thread started
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[MMSyncThread shareInstance] beginSync];
    });
}

- (void)onEndSync:(NSNotification*)notification {
    NSLog(@"onEndSync");
    BOOL r = [[notification.object objectForKey:@"result"] boolValue];
    if (!r) {
        [MMCommonAPI alert:@"更新失败"];
        return;
    }else {
        BOOL changed = [[notification.object objectForKey:@"changed"] boolValue];
        if (!changed) {
            [MMCommonAPI alert:@"已经是最新"];
            NSLog(@"unchanged");
            return;
        }else {
            //不是最新则刷新界面
            [self updateContactArray];
        }
    }
}



- (NSString*)getStringFirstLetter:(DbContactSimple *)record {
    NSString *firstLetter = @"#";
    if ([record isEnglishName]) {
        firstLetter = [MMCommonAPI getStringFirstLetter:record.fullName];
    } else {
        firstLetter = [MMCommonAPI getStringFirstLetter:record.namePhonetic];
    }
    return firstLetter;
}

- (NSInteger)getContactCount {
    NSInteger count = 0;

    for (NSInteger i = 0; i < [[_contactsDictionary allKeys] count]; i++) {
        NSString *strkey = [_contactNameIndexArray objectAtIndex:i];
        NSArray *array = [_contactsDictionary objectForKey:strkey];
        count += [array count];
    }

    return count;
}

#pragma mark -
#pragma mark UITableViewDataSource Methods
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *strkey = nil;
    NSArray *array = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        strkey = [_filterContactNameIndexArray objectAtIndex:indexPath.section];
        // get the array of elements that begin with that letter
        array = [_filterContactsDictionary objectForKey:strkey];
    } else {
        strkey = [_contactNameIndexArray objectAtIndex:indexPath.section];
        // get the array of elements that begin with that letter
        array = [_contactsDictionary objectForKey:strkey];
    }

    DbContact *contact = [array objectAtIndex:indexPath.row];

    ContactListCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [ContactListCell cell];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.nameLabel.text = contact.fullName;
    cell.jobLabel.hidden = YES;

    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *strkey = nil;
    NSArray *array = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        strkey = [_filterContactNameIndexArray objectAtIndex:section];
        // get the array of elements that begin with that letter
        array = [_filterContactsDictionary objectForKey:strkey];
    } else {
        if (![_contactNameIndexArray count]) {
            return 0;
        }
        strkey = [_contactNameIndexArray objectAtIndex:section];
        // get the array of elements that begin with that letter
        array = [_contactsDictionary objectForKey:strkey];
    }
    return [array count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // this table has multiple sections. One for each unique character that an element begins with
    // [A,B,C,D,E,F,G,H,I,K,L,M,N,O,P,R,S,T,U,V,X,Y,Z]
    // return the count of that array
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [_filterContactNameIndexArray count];
    } else {
        return [_contactNameIndexArray count];
    }
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    if (title == UITableViewIndexSearch) {
        [_contactTable scrollRectToVisible:self.searchBar.frame animated:NO];
        return -1;
    }
    return index;
}


- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    NSMutableArray *indices = [NSMutableArray arrayWithObject:UITableViewIndexSearch];
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [indices arrayByAddingObjectsFromArray:_filterContactNameIndexArray];
    } else {
        return [indices arrayByAddingObjectsFromArray:_contactNameIndexArray];
    }
}

#pragma mark -
#pragma mark UITableViewDataSource Data

- (void)sortByIndex:(NSArray *)sortArray {

    [_contactsDictionary removeAllObjects];
    [_contactNameIndexArray removeAllObjects];


    for (DbContactSimple *record in sortArray) {
        NSString* firstLetter = [self getStringFirstLetter:record];

        NSMutableArray *existingArray;
        // if an array already exists in the name index dictionary
        // simply add the element to it, otherwise create an array
        // and add it to the name index dictionary with the letter as the key
        if ((existingArray = [_contactsDictionary valueForKey:firstLetter])) {
            [existingArray addObject:record];
        }
        else {
            NSMutableArray *tempArray = [[NSMutableArray alloc]init];
            [tempArray addObject:record];
            [_contactsDictionary setObject:tempArray forKey:firstLetter];
        }
    }

    [_contactNameIndexArray setArray:
     [[_contactsDictionary allKeys] sortedArrayUsingSelector:@selector(compareWithOther:)]];
}

- (void)sortByIndexForFilter:(NSArray *)sortArray {

    [_filterContactsDictionary removeAllObjects];
    [_filterContactNameIndexArray removeAllObjects];


    for (DbContactSimple *record in sortArray) {
        NSString* firstLetter = [self getStringFirstLetter:record];

        NSMutableArray *existingArray;
        // if an array already exists in the name index dictionary
        // simply add the element to it, otherwise create an array
        // and add it to the name index dictionary with the letter as the key
        if ((existingArray = [_filterContactsDictionary valueForKey:firstLetter])) {
            [existingArray addObject:record];
        }
        else {
            NSMutableArray *tempArray = [[NSMutableArray alloc]init];
            [tempArray addObject:record];
            [_filterContactsDictionary setObject:tempArray forKey:firstLetter];
        }
    }

    [_filterContactNameIndexArray setArray:
     [[_filterContactsDictionary allKeys] sortedArrayUsingSelector:@selector(compareWithOther:)]];
}

#pragma mark -
#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [ContactListCell heigh];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (tableView == _contactTable) {
        UIView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 20)];
        imageView.backgroundColor = [UIColor clearColor];

        UILabel *letter = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 200, 20)];
        letter.backgroundColor = [UIColor clearColor];
        letter.font = [UIFont fontWithName:@"Helvetica" size:16];
        letter.textColor = [UIColor colorWithRed:0.502f green:0.502f blue:0.502f alpha:1.00f];

        if (tableView == self.searchDisplayController.searchResultsTableView) {
            letter.text = [_filterContactNameIndexArray objectAtIndex:section];
        } else {
            letter.text = [_contactNameIndexArray objectAtIndex:section];
        }

        [imageView addSubview:letter];

        return imageView;
    }
    return nil;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _contactTable) {
        NSString *strkey = [_contactNameIndexArray objectAtIndex:indexPath.section];;
        NSArray *array = [_contactsDictionary objectForKey:strkey];;
        DbContactSimple *contact = [array objectAtIndex:indexPath.row];
        MMFullContact* fullContact = [[MMContactManager instance] getFullContact:contact.contactId withError:nil];
        
        NGContactDetailVController *viewController = [NGContactDetailVController new];
        viewController.fullContact = fullContact;
        [self.navigationController pushViewController:viewController animated:YES];
    }else {
        NSString *strkey = [_filterContactNameIndexArray objectAtIndex:indexPath.section];;
        NSArray *array = [_filterContactsDictionary objectForKey:strkey];;
        DbContactSimple *contact = [array objectAtIndex:indexPath.row];
        MMFullContact* fullContact = [[MMContactManager instance] getFullContact:contact.contactId withError:nil];

        NGContactDetailVController *viewController = [NGContactDetailVController new];
        viewController.fullContact = fullContact;
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

#pragma mark -
#pragma mark UISearchDisplayDelegate

- (void)filterContentForSearchText:(NSString *)searchString {
    NSArray *resultArray = [[MMContactManager instance] searchContact:self.contactArray pattern:searchString needName:NO];
    self.searchArray = [NSMutableArray arrayWithArray:resultArray];
    [self sortByIndexForFilter:self.searchArray];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self filterContentForSearchText:searchString];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    NSString *searchText = [self.searchDisplayController.searchBar text];
    [self filterContentForSearchText:searchText];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

- (void)actionLeft {
    MyCompanyViewController *viewController = [[MyCompanyViewController alloc] init];
    viewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)actionRefresh {
    [[MMSyncThread shareInstance] beginSync];
}


- (void)onComponyChange:(NSNotification*)notification {
    [self updateContactArray];
}

@end
