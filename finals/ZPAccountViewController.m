//
//  ZPAccountViewController.m
//  finals
//
//  Created by Ziyad Parekh on 12/25/15.
//  Copyright (c) 2015 Ziyad Parekh. All rights reserved.
//

#import "ZPAccountViewController.h"
#import <FormatterKit/TTTTimeIntervalFormatter.h>
#import "ZPUtility.h"
#import "ZPConstants.h"
#import "UIImage+ImageEffects.h"
#import "UIColor+ZPColors.h"
#import "ZPBaseTableViewCell.h"
#import "AppDelegate.h"


@interface ZPAccountViewController ()
@property (strong, nonatomic) UIView *headerView;
@property (strong, nonatomic) UILabel *totalTransactionsLabel;
@property (strong, nonatomic) UIButton *composeTransactionButton;

- (void)didTapTransferToBankButton:(id)sender;

@end

@implementation ZPAccountViewController
@synthesize headerView;
@synthesize totalTransactionsLabel;
@synthesize composeTransactionButton;
@synthesize userInView;

#pragma mark - Initialization

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        self.parseClassName = kZPTransactionKey;
        self.loadingViewEnabled = NO;
        
        if (!self.userInView) {
            self.userInView = [PFUser currentUser];
            [[PFUser currentUser] fetchIfNeeded];
        }
    }
    return self;
}

- (id)initWithUser:(PFUser *)aUser andBackButton:(BOOL)backButton {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.userInView = aUser;
        self.showBackButton = backButton;
        self.parseClassName = kZPTransactionKey;
        if (!aUser) {
            [NSException raise:NSInvalidArgumentException format:@"PAPAccountViewController init exception: user cannot be nil"];
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (self.showBackButton) {
        UIBarButtonItem *dismissLeftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                     style:UIBarButtonItemStylePlain
                                                     target:self
                                                    action:@selector(dismissPresentingViewController:)];
        
        self.navigationItem.backBarButtonItem = dismissLeftBarButtonItem;
    }
    else {
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.backBarButtonItem = nil;
    }
    [self.tableView setBackgroundColor:[UIColor zp_lightGreyColor]];
    
    self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.bounds.size.width, 275.0f)];
    [self.headerView setBackgroundColor:[UIColor zp_lightGreyColor]];
    
    UILabel *userDisplayNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 20.0f, self.tableView.bounds.size.width, 22.0f)];
    [userDisplayNameLabel setTextAlignment:NSTextAlignmentCenter];
    [userDisplayNameLabel setBackgroundColor:[UIColor clearColor]];
    [userDisplayNameLabel setTextColor:[UIColor zp_darkGreyColor]];
    [userDisplayNameLabel setText:[[self.userInView objectForKey:kZPUserDisplayNameKey] uppercaseString]];
    [userDisplayNameLabel setFont:[UIFont boldSystemFontOfSize:16.0f]];
    [self.headerView addSubview:userDisplayNameLabel];
    
    UIView *profilePictureBackgroundView = [[UIView alloc] initWithFrame:CGRectMake( 101.0f, 55.0f, 118.0f, 118.0f)];
    [profilePictureBackgroundView setBackgroundColor:[UIColor darkGrayColor]];
    profilePictureBackgroundView.alpha = 1.0f;
    CALayer *layer = [profilePictureBackgroundView layer];
    layer.cornerRadius = 60.0f;
    layer.masksToBounds = YES;
    [self.headerView addSubview:profilePictureBackgroundView];
    
    PFImageView *profilePictureImageView = [[PFImageView alloc] initWithFrame:CGRectMake( 101.0f, 55.0f, 118.0f, 118.0f)];
    [self.headerView addSubview:profilePictureImageView];
    [profilePictureImageView setContentMode:UIViewContentModeScaleAspectFill];
    layer = [profilePictureImageView layer];
    layer.cornerRadius = 60.0f;
    layer.masksToBounds = YES;
    profilePictureImageView.alpha = 1.0f;
    
    if ([ZPUtility userHasProfilePictures:self.userInView]) {
        PFFile *imageFile = [self.userInView objectForKey:kZPUserProfilePicMediumKey];
        [profilePictureImageView setFile:imageFile];
        [profilePictureImageView loadInBackground:^(UIImage *image, NSError *error) {
            if (error) {
                NSLog(@"%@", error);
            }
        }];
    } else {
        profilePictureImageView.image = [ZPUtility defaultProfilePicture];
    }
    
    self.totalTransactionsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 180.0f, self.tableView.bounds.size.width, 30.0f)];
    [self.totalTransactionsLabel setTextAlignment:NSTextAlignmentCenter];
    [self.totalTransactionsLabel setBackgroundColor:[UIColor clearColor]];
    [self.totalTransactionsLabel setTextColor:[UIColor zp_horseGrey]];
    [self.totalTransactionsLabel setText:@"total transactions"];
    self.totalTransactionsLabel.font = [UIFont fontWithName:@"Helvetica" size:12];
    [self.headerView addSubview:self.totalTransactionsLabel];

    
    if (![[self.userInView objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
        self.composeTransactionButton = [[UIButton alloc] initWithFrame:CGRectMake(12.0f, 225.0f, self.tableView.bounds.size.width - 24.0f, 40.0f)];
        [self.composeTransactionButton setTitle:@"Pay" forState:UIControlStateNormal];
        [self.composeTransactionButton setBackgroundColor:[UIColor zp_venmoBlueColor]];
        [self.composeTransactionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.composeTransactionButton setTitleColor:[UIColor zp_lightGreyColor] forState:UIControlStateHighlighted];
        self.composeTransactionButton.layer.cornerRadius = 3.0f;
        self.composeTransactionButton.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:20];
        
        [self.headerView addSubview:self.composeTransactionButton];
    } else {
        float userBalance = [[self.userInView objectForKey:kZPUserBalanceKey] floatValue];
        NSString *formattedBalance = [NSString stringWithFormat:@"Transfer Rs%0.02f to Bank", userBalance];
        self.composeTransactionButton = [[UIButton alloc] initWithFrame:CGRectMake(30.0f, 225.0f, self.tableView.bounds.size.width - 60.0f, 30.0f)];
        [self.composeTransactionButton setTitle:formattedBalance forState:UIControlStateNormal];
        if (userBalance > 0) {
            [self.composeTransactionButton setBackgroundColor:[UIColor zp_buttonBlueColor]];
            [self.composeTransactionButton setTitleColor:[UIColor zp_superLightGreyColor] forState:UIControlStateNormal];
            [self.composeTransactionButton setTitleColor:[UIColor zp_superLightGreyColor] forState:UIControlStateHighlighted];
            [self.composeTransactionButton addTarget:self action:@selector(didTapTransferToBankButton:) forControlEvents:UIControlEventTouchUpInside];
        } else {
            [self.composeTransactionButton setBackgroundColor:[UIColor zp_superLightGreyColor]];
            [self.composeTransactionButton setTitleColor:[UIColor zp_veryLightGreyColor] forState:UIControlStateNormal];
            [self.composeTransactionButton setTitleColor:[UIColor zp_veryLightGreyColor] forState:UIControlStateHighlighted];
        }
        self.composeTransactionButton.layer.cornerRadius = 3.0f;
        self.composeTransactionButton.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:14];
        
        [self.headerView addSubview:self.composeTransactionButton];
    }
    
    PFQuery *transactionsFromUserQuery = [PFQuery queryWithClassName:kZPTransactionKey];
    [transactionsFromUserQuery whereKey:kZPTransactionFromUserKey equalTo:self.userInView];
    [transactionsFromUserQuery whereKey:kZPTransactionToUserKey notEqualTo:self.userInView];
    
    PFQuery *transactionsToUserQuery = [PFQuery queryWithClassName:kZPTransactionKey];
    [transactionsToUserQuery whereKey:kZPTransactionToUserKey equalTo:self.userInView];
    [transactionsToUserQuery whereKey:kZPTransactionFromUserKey notEqualTo:self.userInView];
    
    PFQuery *combinedQuery = [PFQuery orQueryWithSubqueries:@[transactionsToUserQuery, transactionsFromUserQuery]];
    [combinedQuery setCachePolicy:kPFCachePolicyCacheThenNetwork];
    [combinedQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (!error) {
            [self.totalTransactionsLabel setText:[NSString stringWithFormat:@"%d total transactions", number]];
        }
    }];
}

- (void)didTapTransferToBankButton:(id)sender {
    NSLog(@"Transfer to bank initiated");
}

- (void)dismissPresentingViewController:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.objects.count) {
        PFObject *object = [self.objects objectAtIndex:indexPath.row];
        NSString *activityString = [ZPActivityFeedViewController stringForActivityType:(NSString *)[object objectForKey:kZPTransactionTypeKey]];
        
        PFUser *fromUser = (PFUser *)[object objectForKey:kZPTransactionFromUserKey];
        NSString *nameString = NSLocalizedString(@"Someone", nil);
        if (fromUser && [fromUser objectForKey:kZPUserDisplayNameKey] && [[fromUser objectForKey:kZPUserDisplayNameKey] length] > 0) {
            nameString = [fromUser objectForKey:kZPUserDisplayNameKey];
        }
        NSString *noteString = [object objectForKey:kZPTransactionNoteKey];
        
        return [ZPActivityTableViewCell heightForCellWithName:nameString contentString:activityString noteString:noteString];
    } else {
        return 44.0f;
    }
}

#pragma mark - PFQueryTableViewController

- (PFQuery * __nonnull)queryForTable {
    if (!self.userInView) {
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
    self.tableView.tableHeaderView = headerView;
    
    if (self.objects.count == 0 && ![[self queryForTable] hasCachedResult]) {
        self.tableView.scrollEnabled = NO;
        self.navigationController.tabBarItem.badgeValue = nil;
    } else {
        self.tableView.scrollEnabled = YES;
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
    [cell hideSeparator:(indexPath.row == self.objects.count - 1)];
    
    return cell;
}

#pragma mark - ZPActivityCellDelegate Methods

- (void)cell:(ZPBaseTableViewCell *)cellView didTapUserButton:(PFUser *)user {
    [self showUserAccountControllerIfNeeded:user];
}

- (void)cell:(ZPActivityTableViewCell *)cellView didTapToUserButton:(PFUser *)user {
    [self showUserAccountControllerIfNeeded:user];
}

- (void)showUserAccountControllerIfNeeded:(PFUser *)user {
    if ([[self.userInView objectId] isEqualToString:[user objectId]]) {
        CAKeyframeAnimation * anim = [ CAKeyframeAnimation animationWithKeyPath:@"transform" ] ;
        anim.values = @[ [ NSValue valueWithCATransform3D:CATransform3DMakeTranslation(-5.0f, 0.0f, 0.0f) ], [ NSValue valueWithCATransform3D:CATransform3DMakeTranslation(5.0f, 0.0f, 0.0f) ] ] ;
        anim.autoreverses = YES ;
        anim.repeatCount = 2.0f ;
        anim.duration = 0.07f ;
        [self.view.layer addAnimation:anim forKey:nil];
    } else {
        // Push account view controller
        ZPAccountViewController *accountViewController = [[ZPAccountViewController alloc] initWithUser:user andBackButton:YES];
        NSLog(@"Presenting account view controller with user: %@", user);
        [self.navigationController pushViewController:accountViewController animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
