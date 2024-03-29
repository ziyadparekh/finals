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
#import "ZPAccountViewController.h"
#import "UIColor+ZPColors.h"
#import "AppDelegate.h"

@interface ZPActivityFeedViewController ()

@property (nonatomic, strong) UINavigationController *presentingAccountNavController;
@property (nonatomic, strong) NSDate *lastRefresh;
@property (nonatomic, strong) UIView *blankTimelineView;

@end

@implementation ZPActivityFeedViewController
@synthesize lastRefresh;

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        self.parseClassName = kZPTransactionKey;
        self.paginationEnabled = YES;
        self.objectsPerPage = 15;
        // The Loading text clashes
        self.loadingViewEnabled = NO;
    }
    return self;
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [UIColor zp_composeGreyBackgroundColor];
    self.navigationItem.title = @"Notifications";
    
    self.blankTimelineView = [[UIView alloc] initWithFrame:self.tableView.bounds];
    
    UILabel *blankLabel = [[UILabel alloc] init];
    [blankLabel setText:@"No transactions to display"];
    [blankLabel setTextAlignment:NSTextAlignmentCenter];
    [blankLabel setTextColor:[UIColor zp_horseGrey]];
    [blankLabel setFrame:CGRectMake(0.0f, 10.0f, self.tableView.bounds.size.width, 40.0f)];
    [self.blankTimelineView addSubview:blankLabel];
    
    lastRefresh = [[NSUserDefaults standardUserDefaults] objectForKey:kZPUserDefaultsActivityFeedViewControllerLastRefreshKey];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self loadObjects];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row < self.objects.count) {
        return;
    } else if (self.paginationEnabled) {
        // load more
        [self loadNextPage];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.objects.count;
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
    
    PFQuery *query2 = [PFQuery queryWithClassName:self.parseClassName];
    [query2 whereKey:kZPTransactionToUserKey equalTo:[PFUser currentUser]];
    [query2 whereKey:kZPTransactionFromUserKey notEqualTo:[PFUser currentUser]];
    
    PFQuery *combinedQuery = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:query, query2, nil]];
    [combinedQuery includeKey:kZPTransactionFromUserKey];
    [combinedQuery includeKey:kZPTransactionToUserKey];
    [combinedQuery orderByDescending:kZPTransactionCreatedAtKey];
    [combinedQuery setCachePolicy:kPFCachePolicyNetworkOnly];
                              

    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    //
    // If there is no network connection, we will hit the cache first.
    if (self.objects.count == 0 || ![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]) {
        [combinedQuery setCachePolicy:kPFCachePolicyCacheThenNetwork];
    }
    
    return combinedQuery;
}

- (void)objectsDidLoad:(nullable NSError *)error {
    [super objectsDidLoad:error];
    
    lastRefresh = [NSDate date];
    [[NSUserDefaults standardUserDefaults] setObject:lastRefresh forKey:kZPUserDefaultsActivityFeedViewControllerLastRefreshKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (self.objects.count == 0 && ![[self queryForTable] hasCachedResult]) {
        self.tableView.scrollEnabled = NO;
        self.navigationController.tabBarItem.badgeValue = nil;
        NSLog(@"no objects were loaded");
        self.tableView.tableHeaderView = self.blankTimelineView;
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
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        
        NSUInteger unreadCount = 0;
        for (PFObject *activity in self.objects) {
            if ([lastRefresh compare:[activity createdAt]] == NSOrderedAscending) {
                unreadCount++;
            }
        }
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
    [cell setActivity:object];
    
//    if ([lastRefresh compare:[object createdAt]] == NSOrderedAscending) {
//        [cell setIsNew:YES];
//    } else {
//        [cell setIsNew:NO];
//    }
    
    [cell hideSeparator:(indexPath.row == self.objects.count - 1)];
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *LoadMoreCellIdentifier = @"LoadMoreCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:LoadMoreCellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LoadMoreCellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = @"Load More";
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.font = [UIFont systemFontOfSize:14.0];
        cell.textLabel.textColor = [UIColor zp_greyColor];
        cell.backgroundColor = [UIColor whiteColor];
    }
    return cell;
}

#pragma mark - ZPActivityCellDelegate Methods

- (void)cell:(ZPBaseTableViewCell *)cellView didTapUserButton:(PFUser *)user {
    // Push account view controller
    ZPAccountViewController *accountViewController = [[ZPAccountViewController alloc] initWithUser:user andBackButton:YES];
    NSLog(@"Presenting account view controller with user: %@", user);
    [self.navigationController pushViewController:accountViewController animated:YES];
}

- (void)cell:(ZPActivityTableViewCell *)cellView didTapToUserButton:(PFUser *)user {
    // Push account view controller
    ZPAccountViewController *accountViewController = [[ZPAccountViewController alloc] initWithUser:user andBackButton:YES];
    NSLog(@"Presenting account view controller with user: %@", user);
    [self.navigationController pushViewController:accountViewController animated:YES];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ZPActivityFeedViewController

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
