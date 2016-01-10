//
//  ZPLoginViewController.m
//  finals
//
//  Created by Ziyad Parekh on 12/24/15.
//  Copyright (c) 2015 Ziyad Parekh. All rights reserved.
//

#import "ZPLoginViewController.h"
#import "MBProgressHUD.h"
#import <ParseFacebookUtilsV4.h>

#import "AppDelegate.h"

@interface ZPLoginViewController () {
    FBSDKLoginButton *_facebookLoginView;
}

@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation ZPLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    // Do any additional setup after loading the view.
    //Position of the Facebook button
    CGFloat yPosition = 360.0f;
    if ([UIScreen mainScreen].bounds.size.height > 480.0f) {
        yPosition = 450.0f;
    }
    
    _facebookLoginView = [[FBSDKLoginButton alloc] initWithFrame:CGRectMake(36.0f, yPosition, 244.0f, 44.0f)];
    _facebookLoginView.readPermissions = @[@"public_profile", @"user_friends", @"email"];
    _facebookLoginView.delegate = self;
    _facebookLoginView.tooltipBehavior = FBSDKLoginButtonTooltipBehaviorDisable;
    [self.view addSubview:_facebookLoginView];

}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

#pragma mark - FBSDKLoginButtonDelegate

- (void)  loginButton:(FBSDKLoginButton *)loginButton
didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result
                error:(NSError *)error {
    if (!error) {
        [self handleFacebookSession];
    } else {
        [self handleLogInError:error];
    }
}

- (void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton {
    // No op
}

- (void)handleFacebookSession {
    if ([PFUser currentUser]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(logInViewControllerDidLogUserIn:)]) {
            [self.delegate performSelector:@selector(logInViewControllerDidLogUserIn:) withObject:[PFUser currentUser]];
        }
        return;
    }
    
    if (![FBSDKAccessToken currentAccessToken]) {
        NSLog(@"Login failure. FB Access Token or user ID does not exist");
        return;
    }
    
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [PFFacebookUtils logInInBackgroundWithAccessToken:[FBSDKAccessToken currentAccessToken] block:^(PFUser *user, NSError *error) {
        if (!error) {
            [self.hud removeFromSuperview];
            if (self.delegate) {
                if ([self.delegate respondsToSelector:@selector(logInViewControllerDidLogUserIn:)]) {
                    [self.delegate performSelector:@selector(logInViewControllerDidLogUserIn:) withObject:user];
                }
            }
        } else {
            [self cancelLogIn:error];
        }
    }];
}

#pragma mark - ()

- (void)cancelLogIn:(NSError *)error {
    
    if (error) {
        [self handleLogInError:error];
    }
    
    [self.hud removeFromSuperview];
    [FBSDKAccessToken setCurrentAccessToken:nil];
    [PFUser logOut];
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] presentLoginViewController:NO];
}

- (void)handleLogInError:(NSError *)error {
    if (error) {
        NSLog(@"Error: %@", [[error userInfo] objectForKey:@"com.facebook.sdk:ErrorLoginFailedReason"]);
        NSString *title = NSLocalizedString(@"Login Error", @"Login error title in PAPLogInViewController");
        NSString *message = NSLocalizedString(@"Something went wrong. Please try again.", @"Login error message in PAPLogInViewController");
        
        if ([[[error userInfo] objectForKey:@"com.facebook.sdk:ErrorLoginFailedReason"] isEqualToString:@"com.facebook.sdk:UserLoginCancelled"]) {
            return;
        }
        
        if (error.code == kPFErrorFacebookInvalidSession) {
            NSLog(@"Invalid session, logging out.");
            [FBSDKAccessToken setCurrentAccessToken:nil];
            return;
        }
        
        if (error.code == kPFErrorConnectionFailed) {
            NSString *ok = NSLocalizedString(@"OK", @"OK");
            NSString *title = NSLocalizedString(@"Offline Error", @"Offline Error");
            NSString *message = NSLocalizedString(@"Something went wrong. Please try again.", @"Offline message");
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                            message:message
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:ok, nil];
            [alert show];
            
            return;
        }
        
        NSString *ok = NSLocalizedString(@"OK", @"OK");
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                            message:message
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:ok, nil];
        [alertView show];
    }
}


#pragma mark - PFLoginViewController delegate

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)handleDelegateCallForSignUpAndLogin {
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(logInViewControllerDidLogUserIn:)]) {
            [self.delegate logInViewControllerDidLogUserIn:self];
        }
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
