//
//  ZPLockSplashViewController.m
//  finals
//
//  Created by Ziyad Parekh on 1/10/16.
//  Copyright (c) 2016 Ziyad Parekh. All rights reserved.
//

#import "ZPLockSplashViewController.h"
#import "AppDelegate.h"
#import "ZPUtility.h"

@interface ZPLockSplashViewController ()

@end

@implementation ZPLockSplashViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        //__weak typeof(self) weakSelf = self;
        self.didFinishWithSuccess = ^(BOOL success, VENTouchLockSplashViewControllerUnlockType unlockType) {
            if (success) {
                NSString *logString = @"Sample App unlocked";
                switch (unlockType) {
                    case VENTouchLockSplashViewControllerUnlockTypeTouchID: {
                        logString = [logString stringByAppendingString:@" with Touch ID"];
                        break;
                    }
                    case VENTouchLockSplashViewControllerUnlockTypePasscode: {
                        logString = [logString stringByAppendingString:@" with Passcode"];
                        break;
                    }
                    default:
                        break;
                }
                NSLog(@"%@", logString);
            } else {
                [(AppDelegate *)[[UIApplication sharedApplication] delegate] logOut];
            }
        };
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
