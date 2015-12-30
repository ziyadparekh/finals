//
//  ZPAccountViewController.h
//  finals
//
//  Created by Ziyad Parekh on 12/25/15.
//  Copyright (c) 2015 Ziyad Parekh. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>

#import "ZPHomeViewController.h"

@interface ZPAccountViewController : PFQueryTableViewController

@property (strong, nonatomic) PFUser *user;
@property (nonatomic, assign) BOOL showBackButton;

- (id)initWithUser:(PFUser *)aUser andBackButton:(BOOL)backButton;


@end
