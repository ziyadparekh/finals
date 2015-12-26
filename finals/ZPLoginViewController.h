//
//  ZPLoginViewController.h
//  finals
//
//  Created by Ziyad Parekh on 12/24/15.
//  Copyright (c) 2015 Ziyad Parekh. All rights reserved.
//

#import <FBSDKLoginKit/FBSDKLoginButton.h>
#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@protocol ZPLoginViewControllerDelegate;

@interface ZPLoginViewController : UIViewController <FBSDKLoginButtonDelegate>

@property (nonatomic, assign) id<ZPLoginViewControllerDelegate> delegate;

@end

@protocol ZPLoginViewControllerDelegate <NSObject>

- (void)logInViewControllerDidLogUserIn:(ZPLoginViewController *)logInViewController;

@end