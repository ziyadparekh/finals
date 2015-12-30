//
//  ZPHomeViewController.m
//  finals
//
//  Created by Ziyad Parekh on 12/29/15.
//  Copyright (c) 2015 Ziyad Parekh. All rights reserved.
//

#import "ZPHomeViewController.h"
#import "ZPConstants.h"
#import "AppDelegate.h"

@interface ZPHomeViewController ()

@end

@implementation ZPHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - PFQueryTableViewController

- (PFQuery * __nonnull)queryForTable {
    if (![PFUser currentUser]) {
        PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
        [query setLimit:0];
        return query;
    }
    
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    [query includeKey:kZPTransactionFromUserKey];
    [query includeKey:kZPTransactionToUserKey];
    [query orderByDescending:kZPTransactionCreatedAtKey];
    [query setCachePolicy:kPFCachePolicyNetworkOnly];
    
    
    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    //
    // If there is no network connection, we will hit the cache first.
    if (self.objects.count == 0 || ![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]) {
        [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
    }
    
    return query;
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
