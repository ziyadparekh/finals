//
//  ZPComposeViewController.h
//  finals
//
//  Created by Ziyad Parekh on 12/25/15.
//  Copyright (c) 2015 Ziyad Parekh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface ZPComposeViewController : UIViewController
- (id)initWithUser:(PFUser *)aUser;
@end
