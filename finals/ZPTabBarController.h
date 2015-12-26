//
//  ZPTabBarController.h
//  finals
//
//  Created by Ziyad Parekh on 12/24/15.
//  Copyright (c) 2015 Ziyad Parekh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZPComposeViewController.h"

@protocol ZPTabBarControllerDelegate;

@interface ZPTabBarController : UITabBarController <UINavigationControllerDelegate>

@end

@protocol ZPTabBarControllerDelegate <NSObject>

- (void)tabBarController:(UITabBarController *)tabBarController composeTransactionTouchUpInsideAction:(UIButton *)button;

@end
