//
//  ZPWelcomeViewController.m
//  finals
//
//  Created by Ziyad Parekh on 12/24/15.
//  Copyright (c) 2015 Ziyad Parekh. All rights reserved.
//

#import "ZPWelcomeViewController.h"
#import "AppDelegate.h"
#import <Parse/Parse.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "ZPConstants.h"
#import "ZPUtility.h"

@interface ZPWelcomeViewController () {
    BOOL _presentedLoginViewController;
    int _facebookResponseCount;
    int _expectedFacebookResponseCount;
    NSMutableData *_profilePicData;
}

@end

@implementation ZPWelcomeViewController

- (void)loadView {
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    [backgroundImageView setImage:[UIImage imageNamed:@"Default-fb231265150320768-568h@2x.png"]];
    self.view = backgroundImageView;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // Do any additional setup after loading the view.
    
    if (![PFUser currentUser]) {
        [self presentLoginViewController:NO];
        return;
    }
    
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] presentTabBarController];
    
    _facebookResponseCount = 0;
    [[PFUser currentUser] fetchInBackgroundWithTarget:self selector:@selector(refreshCurrentUserCallbackWithResult:error:)];
}

- (void)presentLoginViewController:(BOOL)animated {
    if (_presentedLoginViewController) {
        return;
    }
    
    _presentedLoginViewController = YES;
    ZPLoginViewController *loginViewController = [[ZPLoginViewController alloc] init];
    loginViewController.delegate = self;
    [self presentViewController:loginViewController animated:animated completion:nil];
}

- (void)logInViewControllerDidLogUserIn:(ZPLoginViewController *)logInViewController {
    if (_presentedLoginViewController) {
        _presentedLoginViewController = NO;
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)processedFacebookResponse {
    // Once we handled all necessary facebook batch responses, save everything necessary and continue
    @synchronized (self) {
        _facebookResponseCount++;
        if (_facebookResponseCount != _expectedFacebookResponseCount) {
            return;
        }
    }
    _facebookResponseCount = 0;
    NSLog(@"done processing all Facebook requests");
    
    if (![[PFUser currentUser] objectForKey:kZPUserBalanceKey]) {
        [[PFUser currentUser] setObject:[NSNumber numberWithFloat:0.00f] forKey:kZPUserBalanceKey];
    }
    
    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!succeeded) {
            NSLog(@"Failed save in background of user, %@", error);
        } else {
            NSLog(@"saved current parse user");
        }
    }];
}

- (void)refreshCurrentUserCallbackWithResult:(PFObject *)refreshedObject error:(NSError *)error {
    // This fetches the most recent data from FB, and syncs up all data with the server including
    // profile pic and friends list from FB
    
    // A kPFErrorObjectNotFound error on currentUser refresh signals a deleted user
    if (error && error.code == kPFErrorObjectNotFound) {
        NSLog(@"User does not exist");
        [(AppDelegate *)[[UIApplication sharedApplication] delegate] logOut];
        return;
    }
    
    if (![FBSDKAccessToken currentAccessToken]) {
        NSLog(@"FB Session does not exist, logout");
        [(AppDelegate *)[[UIApplication sharedApplication] delegate] logOut];
        return;
    }
    
    if (![FBSDKAccessToken currentAccessToken].userID) {
        NSLog(@"userID on FB Session does not exist, logout");
        [(AppDelegate *)[[UIApplication sharedApplication] delegate] logOut];
        return;
    }
    
    PFUser *currentParseUser = [PFUser currentUser];
    if (!currentParseUser) {
        NSLog(@"Current Parse user does not exist, logout");
        [(AppDelegate *)[[UIApplication sharedApplication] delegate] logOut];
        return;
    }
    
    NSString *facebookId = [currentParseUser objectForKey:kZPUserFacebookIDKey];
    if (!facebookId || ![facebookId length]) {
        // set the parse user's FBID
        [currentParseUser setObject:[FBSDKAccessToken currentAccessToken].userID forKey:kZPUserFacebookIDKey];
    }
    
    if (![ZPUtility userHasValidFacebookData:currentParseUser]) {
        NSLog(@"User does not have valid facebook ID. PFUser's FBID: %@, FBSessions FBID: %@. logout", [currentParseUser objectForKey:kZPUserFacebookIDKey], [FBSDKAccessToken currentAccessToken].userID);
        [(AppDelegate *)[[UIApplication sharedApplication] delegate] logOut];
        return;
    }
    
    // Finished checking for invalid stuff
    // Refresh FB Session (When we link up the FB access token with the parse user, information other than the access token string is dropped
    // By going through a refresh, we populate useful parameters on FBAccessTokenData such as permissions.
    
    [FBSDKAccessToken refreshCurrentAccessToken:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        if (error) {
            NSLog(@"Failed refresh of FB Session, logging out: %@", error);
            [(AppDelegate *)[[UIApplication sharedApplication] delegate] logOut];
            return;
        }
        // refreshed
        NSLog(@"refreshed permissions: %@", [FBSDKAccessToken currentAccessToken]);
        
        _expectedFacebookResponseCount = 0;
        FBSDKAccessToken *currentAccessToken = [FBSDKAccessToken currentAccessToken];
        if ([currentAccessToken hasGranted:@"public_profile"]) {
            // Logged in with FB
            // Create batch request for all the stuff
            FBSDKGraphRequestConnection *connection = [[FBSDKGraphRequestConnection alloc] init];
            _expectedFacebookResponseCount++;
            [connection addRequest:[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields" : @"name"}] completionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                if (error) {
                    // Failed to fetch me data.. logout to be safe
                    NSLog(@"couldn't fetch facebook /me data: %@, logout", error);
                    [(AppDelegate *)[[UIApplication sharedApplication] delegate] logOut];
                    return;
                }
                
                NSString *facebookName = result[@"name"];
                if (facebookName && [facebookName length] != 0) {
                    [currentParseUser setObject:facebookName forKey:kZPUserDisplayNameKey];
                }
                
                [self processedFacebookResponse];
            }];
            
            // profile pic request
            _expectedFacebookResponseCount++;
            [connection addRequest:[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters: @{@"fields":@"picture.width(500).height(500)"}] completionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                if (!error) {
                    // result is a dictionary with the user's Facebook data
                    NSDictionary *userData = (NSDictionary *)result;
                    
                    NSURL *profilePictureUrl = [NSURL URLWithString: userData[@"picture"][@"data"][@"url"]];
                    
                    // Now add the data to the UI elements
                    NSURLRequest *profilePictureURLRequest = [NSURLRequest requestWithURL:profilePictureUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0f]; // Facebook profile picture cache policy: Expires in 2 weeks
                    [NSURLConnection connectionWithRequest:profilePictureURLRequest delegate:self];
                } else {
                    NSLog(@"Error getting profile pic url, setting as default avatar: %@", error);
                    NSData *profilePictureData = UIImagePNGRepresentation([UIImage imageNamed:@"AvatarPlaceholder.png"]);
                    [ZPUtility processFacebookProfilePictureData:profilePictureData];
                }
                [self processedFacebookResponse];
            }];
            if ([currentAccessToken hasGranted:@"user_friends"]) {
                // Fetch FB Friends + me
                _expectedFacebookResponseCount++;
                [connection addRequest:[[FBSDKGraphRequest alloc] initWithGraphPath:@"/me/friends" parameters:@{ @"fields": @"id,name,first_name,last_name" }] completionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                    NSLog(@"processing Facebook friends");
                    if (error) {
                        // need to clear the cache
                    } else {
                        NSArray *data = [result objectForKey:@"data"];
                        NSMutableArray *facebookIds = [[NSMutableArray alloc] initWithCapacity:[data count]];
                        for (NSDictionary *friendData in data) {
                            if (friendData[@"id"]) {
                                [facebookIds addObject:friendData[@"id"]];
                            }
                        }
                        NSLog(@"%@", facebookIds);
                        // cache friend data
                        // need to add cache utility
                        
                        if ([currentParseUser objectForKey:kZPUserFacebookFriendsKey]) {
                            [currentParseUser removeObjectForKey:kZPUserFacebookFriendsKey];
                        }
                    }
                    [self processedFacebookResponse];
                }];
            }
            [connection start];
        } else {
            NSData *profilePictureData = UIImagePNGRepresentation([UIImage imageNamed:@"AvatarPlaceholder.png"]);
            [ZPUtility processFacebookProfilePictureData:profilePictureData];
            
            // need to clear the cache
            [currentParseUser setObject:@"Someone" forKey:kZPUserDisplayNameKey];
            _expectedFacebookResponseCount++;
            [self processedFacebookResponse];
        }
    }];
}

#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    _profilePicData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_profilePicData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [ZPUtility processFacebookProfilePictureData:_profilePicData];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Connection error downloading profile pic data: %@", error);
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
