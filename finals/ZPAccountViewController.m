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

@interface ZPAccountViewController ()
@property (strong, nonatomic) UIView *headerView;
@end

@implementation ZPAccountViewController
@synthesize headerView;
@synthesize user;

#pragma mark - Initialization

- (id)initWithUser:(PFUser *)aUser andBackButton:(BOOL)backButton {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.user = aUser;
        self.showBackButton = backButton;
        
        if (!aUser) {
            [NSException raise:NSInvalidArgumentException format:@"PAPAccountViewController init exception: user cannot be nil"];
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (!self.user) {
        self.user = [PFUser currentUser];
        [[PFUser currentUser] fetchIfNeeded];
    }
    if (self.showBackButton) {
        UIBarButtonItem *dismissLeftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                     style:UIBarButtonItemStylePlain
                                                     target:self
                                                     action:@selector(dismissPresentingViewController)];
        
        self.navigationItem.leftBarButtonItem = dismissLeftBarButtonItem;
    }
    else {
        self.navigationItem.leftBarButtonItem = nil;
    }
    
    self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.bounds.size.width, 222.0f)];
    [self.headerView setBackgroundColor:[UIColor zp_lightGreyColor]];
    
    UIView *profilePictureBackgroundView = [[UIView alloc] initWithFrame:CGRectMake( 0.0f, 0.0f, 154.0f, 154.0f)];
    [profilePictureBackgroundView setBackgroundColor:[UIColor darkGrayColor]];
    profilePictureBackgroundView.alpha = 1.0f;
    CALayer *layer = [profilePictureBackgroundView layer];
    layer.masksToBounds = YES;
    [self.headerView addSubview:profilePictureBackgroundView];
    
    PFImageView *profilePictureImageView = [[PFImageView alloc] initWithFrame:CGRectMake( 0.0f, 0.0f, 154.0f, 154.0f)];
    [self.headerView addSubview:profilePictureImageView];
    [profilePictureImageView setContentMode:UIViewContentModeScaleAspectFill];
    layer = [profilePictureImageView layer];
    layer.masksToBounds = YES;
    profilePictureImageView.alpha = 1.0f;
    
    if ([ZPUtility userHasProfilePictures:self.user]) {
        PFFile *imageFile = [self.user objectForKey:kZPUserProfilePicMediumKey];
        [profilePictureImageView setFile:imageFile];
        [profilePictureImageView loadInBackground:^(UIImage *image, NSError *error) {
            if (error) {
                NSLog(@"%@", error);
            }
        }];
    } else {
        profilePictureImageView.image = [ZPUtility defaultProfilePicture];
    }
    
    UILabel *userDisplayNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0f, 10.0f, 149.0f, 22.0f)];
    [userDisplayNameLabel setTextAlignment:NSTextAlignmentLeft];
    [userDisplayNameLabel setBackgroundColor:[UIColor clearColor]];
    [userDisplayNameLabel setTextColor:[UIColor zp_drawerBackgroundColor]];
    [userDisplayNameLabel setText:[[self.user objectForKey:@"displayName"] uppercaseString]];
    [userDisplayNameLabel setFont:[UIFont boldSystemFontOfSize:14.0f]];
    
    UIImageView *friendsIconImageView = [[UIImageView alloc] initWithImage:nil];
    [friendsIconImageView setImage:[UIImage imageNamed:@"FriendsIcon.png"]];
    [friendsIconImageView setFrame:CGRectMake( 42.0f, 37.0f, 12.0f, 12.0f)];
    
    UILabel *friendsCountLabel = [[UILabel alloc] initWithFrame:CGRectMake( 5.0f, 37.0f, 50.0f, 12.0f)];
    [friendsCountLabel setTextAlignment:NSTextAlignmentLeft];
    [friendsCountLabel setBackgroundColor:[UIColor clearColor]];
    [friendsCountLabel setTextColor:[UIColor zp_darkGreyColor]];
    [friendsCountLabel setFont:[UIFont boldSystemFontOfSize:12.0f]];
    [friendsCountLabel setText:@"320"];
    
    UIView *userDetailsView = [[UIView alloc] initWithFrame:CGRectMake(154.0f, 0.0f, self.tableView.bounds.size.width - 154.0f, 154.0f)];
    [userDetailsView setBackgroundColor:[UIColor whiteColor]];
    userDetailsView.alpha = 1.0f;
    
    [userDetailsView addSubview:userDisplayNameLabel];
    [userDetailsView addSubview:friendsIconImageView];
    [userDetailsView addSubview:friendsCountLabel];

    UIButton *userDetailsActionButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 129.0f, self.tableView.bounds.size.width - 154.0f, 25.0f)];
    if (![[self.user objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
        [userDetailsActionButton setBackgroundColor:[UIColor zp_greenColor]];
        [userDetailsActionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [userDetailsActionButton setTitle:@"FRIENDS" forState:UIControlStateNormal];
        userDetailsActionButton.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:10];
    } else {
        [userDetailsActionButton setBackgroundColor:[UIColor zp_venmoBlueColor]];
        [userDetailsActionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [userDetailsActionButton setTitle:@"CASH OUT" forState:UIControlStateNormal];
        userDetailsActionButton.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:10];
        
    }
    
    [userDetailsView addSubview:userDetailsActionButton];
    [self.headerView addSubview:userDetailsView];
    
    if (![[self.user objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
    
        UIButton *composeTransactionButton = [[UIButton alloc] initWithFrame:CGRectMake(5.0f, 5.0f, self.tableView.bounds.size.width - 10.0f, self.headerView.bounds.size.height - 164.0f)];
        [composeTransactionButton setTitle:@"PAY" forState:UIControlStateNormal];
        [composeTransactionButton setBackgroundColor:[UIColor zp_venmoBlueColor]];
        [composeTransactionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [composeTransactionButton setTitleColor:[UIColor zp_lightGreyColor] forState:UIControlStateSelected];
        composeTransactionButton.layer.cornerRadius = 3.0f;
        composeTransactionButton.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:24];
    
        UIView *buttonContainerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 154.0f, self.tableView.bounds.size.width, self.headerView.bounds.size.height - 154.0f)];
        [buttonContainerView setBackgroundColor:[UIColor clearColor]];
        [buttonContainerView addSubview:composeTransactionButton];
    
        [self.headerView addSubview:buttonContainerView];
        
    } else {
        UILabel *totalTransactionsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 10.0f, self.tableView.bounds.size.width / 3, 30.0f)];
        [totalTransactionsLabel setTextAlignment:NSTextAlignmentCenter];
        [totalTransactionsLabel setBackgroundColor:[UIColor clearColor]];
        [totalTransactionsLabel setTextColor:[UIColor zp_lightBlueColor]];
        [totalTransactionsLabel setText:@"298"];
        totalTransactionsLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:24];
        
        UILabel *transactionsTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 40.0f, self.tableView.bounds.size.width / 3, 15.0f)];
        [transactionsTitleLabel setTextAlignment:NSTextAlignmentCenter];
        [transactionsTitleLabel setBackgroundColor:[UIColor clearColor]];
        [transactionsTitleLabel setTextColor:[UIColor zp_lightBlueColor]];
        [transactionsTitleLabel setText:@"TRANSACTIONS"];
        transactionsTitleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:8];
        
        UILabel *totalBalanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.tableView.bounds.size.width / 3, 10.0f, self.tableView.bounds.size.width / 3, 30.0f)];
        [totalBalanceLabel setTextAlignment:NSTextAlignmentCenter];
        [totalBalanceLabel setBackgroundColor:[UIColor clearColor]];
        [totalBalanceLabel setTextColor:[UIColor zp_lightBlueColor]];
        [totalBalanceLabel setText:@"$298.00"];
        totalBalanceLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:24];
        
        UILabel *balanceTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.tableView.bounds.size.width / 3, 40.0f, self.tableView.bounds.size.width / 3, 15.0f)];
        [balanceTitleLabel setTextAlignment:NSTextAlignmentCenter];
        [balanceTitleLabel setBackgroundColor:[UIColor clearColor]];
        [balanceTitleLabel setTextColor:[UIColor zp_lightBlueColor]];
        [balanceTitleLabel setText:@"BALANCE"];
        balanceTitleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:8];

        
        UIView *metaDataView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 154.0f, self.tableView.bounds.size.width, self.headerView.bounds.size.height - 154.0f)];
        [metaDataView setBackgroundColor:[UIColor zp_drawerBackgroundColor]];
        [metaDataView addSubview:totalTransactionsLabel];
        [metaDataView addSubview:transactionsTitleLabel];
        [metaDataView addSubview:totalBalanceLabel];
        [metaDataView addSubview:balanceTitleLabel];
        
        [self.headerView addSubview:metaDataView];
    }

}

- (void)objectsDidLoad:(nullable NSError *)error {
    [super objectsDidLoad:error];
    
    self.tableView.tableHeaderView = headerView;
}

- (void)dismissPresentingViewController {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
