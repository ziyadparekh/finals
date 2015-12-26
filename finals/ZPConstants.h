//
//  ZPConstants.h
//  finals
//
//  Created by Ziyad Parekh on 12/24/15.
//  Copyright (c) 2015 Ziyad Parekh. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    ZPHomeTabBarItemIndex = 0,
    ZPProfileTabBarItemIndex = 1,
    ZPEmptyTabBarItemIndex = 2,
    ZPActivityTabBarItemIndex = 3
} ZPTabBarControllerViewControllerIndex;

@interface ZPConstants : NSObject

#pragma mark - PFObject User Class
// Field keys
extern NSString *const kZPUserDisplayNameKey;
extern NSString *const kZPUserFacebookIDKey;
extern NSString *const kZPUserPhotoIDKey;
extern NSString *const kZPUserProfilePicSmallKey;
extern NSString *const kZPUserProfilePicMediumKey;
extern NSString *const kZPUserFacebookFriendsKey;
extern NSString *const kZPUserAlreadyAutoFollowedFacebookFriendsKey;
extern NSString *const kZPUserEmailKey;
extern NSString *const kZPUserAutoFollowKey;
extern NSString *const kZPUserBalanceKey;

#pragma mark - Transactions Class
extern NSString *const kZPUserTransactionsKey;

#pragma mark - PFObject Photo Class
// Class key
extern NSString *const kZPPhotoClassKey;

@end
