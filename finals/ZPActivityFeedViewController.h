//
//  ZPActivityFeedViewController.h
//  finals
//
//  Created by Ziyad Parekh on 12/28/15.
//  Copyright (c) 2015 Ziyad Parekh. All rights reserved.
//

#import "PFQueryTableViewController.h"
#import <ParseUI/ParseUI.h>
#import "ZPActivityTableViewCell.h"

@interface ZPActivityFeedViewController : PFQueryTableViewController <ZPActivityTableViewCellDelegate>

+ (NSString *)stringForActivityType:(NSString *)activityType;

@end
