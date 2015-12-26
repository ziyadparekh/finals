//
//  ZPWelcomeViewController.h
//  finals
//
//  Created by Ziyad Parekh on 12/24/15.
//  Copyright (c) 2015 Ziyad Parekh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZPLoginViewController.h"

@interface ZPWelcomeViewController : UIViewController <ZPLoginViewControllerDelegate>

- (void)presentLoginViewController:(BOOL)animated;

@end
