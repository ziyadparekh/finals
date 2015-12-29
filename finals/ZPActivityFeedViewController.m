//
//  ZPActivityFeedViewController.m
//  finals
//
//  Created by Ziyad Parekh on 12/28/15.
//  Copyright (c) 2015 Ziyad Parekh. All rights reserved.
//

#import <Parse/Parse.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "ZPActivityFeedViewController.h"
#import "ZPConstants.h"
#import "ZPBaseTableViewCell.h"
#import "UIColor+ZPColors.h"
#import "AppDelegate.h"

@interface ZPActivityFeedViewController ()

@end

@implementation ZPActivityFeedViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        self.parseClassName = kZPTransactionKey;
        self.paginationEnabled = YES;
        self.pullToRefreshEnabled = YES;
        self.objectsPerPage = 15;
        self.loadingViewEnabled = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    
    [super viewDidLoad];
    
    UIView *texturedBackgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    [texturedBackgroundView setBackgroundColor:[UIColor zp_composeGreyBackgroundColor]];
    self.tableView.backgroundView = texturedBackgroundView;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tableView.separatorColor = [UIColor zp_dividerGreyColor];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.objects.count) {
        PFObject *object = [self.objects objectAtIndex:indexPath.row];
        NSString *activityString = [ZPActivityFeedViewController stringForActivityType:(NSString *)[object objectForKey:kZPTransactionTypeKey]];
        
        PFUser *user = (PFUser *)[object objectForKey:kZPTransactionFromUserKey];
        NSString *nameString = NSLocalizedString(@"Someone", nil);
        if (user && [user objectForKey:kZPUserDisplayNameKey] && [[user objectForKey:kZPUserDisplayNameKey] length] > 0) {
            nameString = [user objectForKey:kZPUserDisplayNameKey];
        }
        NSString *noteString = [object objectForKey:kZPTransactionNoteKey];
        
        return [ZPActivityTableViewCell heightForCellWithName:nameString contentString:activityString noteString:noteString];
    } else {
        return 44.0f;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - PFQueryTableViewController

- (PFQuery * __nonnull)queryForTable {
    if (![PFUser currentUser]) {
        PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
        [query setLimit:0];
        return query;
    }
    
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    [query whereKey:kZPTransactionToUserKey notEqualTo:[PFUser currentUser]];
    [query whereKey:kZPTransactionFromUserKey equalTo:[PFUser currentUser]];
    [query whereKeyExists:kZPTransactionFromUserKey];
    [query includeKey:kZPTransactionFromUserKey];
    [query includeKey:kZPTransactionToUserKey];
    [query orderByDescending:kZPTransactionCreatedAtKey];
    
    [query setCachePolicy:kPFCachePolicyNetworkOnly];
    
    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    //
    // If there is no network connection, we will hit the cache first.
    if (self.objects.count == 0 || ![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]) {
        [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
    }
    
    return query;
}

- (void)objectsDidLoad:(nullable NSError *)error {
    [super objectsDidLoad:error];
    
//    lastRefresh = [NSDate date];
//    [[NSUserDefaults standardUserDefaults] setObject:lastRefresh forKey:kPAPUserDefaultsActivityFeedViewControllerLastRefreshKey];
//    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    if (self.objects.count == 0 && ![[self queryForTable] hasCachedResult]) {
        self.tableView.scrollEnabled = NO;
        self.navigationController.tabBarItem.badgeValue = nil;
        NSLog(@"no objects were loaded");
//        if (!self.blankTimelineView.superview) {
//            self.blankTimelineView.alpha = 0.0f;
//            self.tableView.tableHeaderView = self.blankTimelineView;
//            
//            [UIView animateWithDuration:0.200f animations:^{
//                self.blankTimelineView.alpha = 1.0f;
//            }];
//        }
    } else {
        self.tableView.tableHeaderView = nil;
        self.tableView.scrollEnabled = YES;
        
//        NSUInteger unreadCount = 0;
//        for (PFObject *activity in self.objects) {
//            if ([lastRefresh compare:[activity createdAt]] == NSOrderedAscending && ![[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeJoined]) {
//                unreadCount++;
//            }
//        }
//        
//        if (unreadCount > 0) {
//            self.navigationController.tabBarItem.badgeValue = [NSString stringWithFormat:@"%lu",(unsigned long)unreadCount];
//        } else {
//            self.navigationController.tabBarItem.badgeValue = nil;
//        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    static NSString *CellIdentifier = @"ActivityCell";
    
    ZPActivityTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[ZPActivityTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell setDelegate:self];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    NSLog(@"%@", object);
    [cell setActivity:object];
    
//    if ([lastRefresh compare:[object createdAt]] == NSOrderedAscending) {
//        [cell setIsNew:YES];
//    } else {
//        [cell setIsNew:NO];
//    }
    
    [cell hideSeparator:(indexPath.row == self.objects.count - 1)];
    
    return cell;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - PAPActivityFeedViewController

+ (NSString *)stringForActivityType:(NSString *)activityType {
    if ([activityType isEqualToString:kZPTransactionCashOutKey]) {
        return NSLocalizedString(@"cashed out", nil);
    } else if ([activityType isEqualToString:kZPTransactionPaymentKey]) {
        return NSLocalizedString(@"paid", nil);
    } else {
        return nil;
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

-(void)viewDidLayoutSubviews {
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
