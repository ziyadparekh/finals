//
//  ZPActivityFeedViewController.m
//  finals
//
//  Created by Ziyad Parekh on 12/28/15.
//  Copyright (c) 2015 Ziyad Parekh. All rights reserved.
//

#import "ZPActivityFeedViewController.h"
#import "ZPConstants.h"

@interface ZPActivityFeedViewController ()

@end

@implementation ZPActivityFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - PAPActivityFeedViewController

+ (NSString *)stringForActivityType:(NSString *)activityType {
    if ([activityType isEqualToString:kZPTransactionCashOutKey]) {
        return NSLocalizedString(@"cashed out", nil);
    } else if ([activityType isEqualToString:kZPTransactionPaymentKey]) {
        return NSLocalizedString(@"paid", nil);
    } else {
        return nil;
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
