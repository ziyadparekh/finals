//
//  ZPTabBarController.m
//  finals
//
//  Created by Ziyad Parekh on 12/24/15.
//  Copyright (c) 2015 Ziyad Parekh. All rights reserved.
//

#import "ZPTabBarController.h"
#import "UIColor+ZPColors.h"

@interface ZPTabBarController ()
@property (strong, nonatomic) UINavigationController *navController;
@end

@implementation ZPTabBarController
@synthesize navController;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // color for active tab
    self.tabBar.tintColor = [UIColor zp_buttonBlueColor];
    // color for tab bar background
    self.tabBar.barTintColor = [UIColor zp_darkGreyColor];
    
    self.navController = [[UINavigationController alloc] init];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - UITabBarController

- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated {
    [super setViewControllers:viewControllers animated:animated];
    
    UIButton *composeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    composeButton.frame = CGRectMake(2 * (self.tabBar.bounds.size.width/5), 0.0f, (self.tabBar.bounds.size.width/5), self.tabBar.bounds.size.height);
    [composeButton setImage:[UIImage imageNamed:@"ComposeDefault"] forState:UIControlStateNormal];
    [composeButton setImage:[UIImage imageNamed:@"ComposeSelected"] forState:UIControlStateHighlighted];
    [composeButton addTarget:self action:@selector(didPressComposeTransactionButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.tabBar addSubview:composeButton];
}

- (void)didPressComposeTransactionButton:(id)sender {
    ZPComposeViewController *viewController = [[ZPComposeViewController alloc] init];
    
    [self.navController pushViewController:viewController animated:NO];
    [self presentViewController:self.navController animated:YES completion:nil];
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
