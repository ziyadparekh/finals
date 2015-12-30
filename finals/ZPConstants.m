//
//  ZPConstants.m
//  finals
//
//  Created by Ziyad Parekh on 12/24/15.
//  Copyright (c) 2015 Ziyad Parekh. All rights reserved.
//

#import "ZPConstants.h"

@implementation ZPConstants

#pragma mark - NSUserDefaults
NSString *const kZPUserDefaultsActivityFeedViewControllerLastRefreshKey = @"com.parse.Finals.userDefaults.activityFeedViewController.lastRefresh";

#pragma mark - User Class

NSString *const kZPUserClass                                   = @"_User";

// Field keys
NSString *const kZPUserIdKey                                   = @"objectId";
NSString *const kZPUserDisplayNameKey                          = @"displayName";
NSString *const kZPUserLowercaseNameKey                        = @"lowercaseName";
NSString *const kZPUserFacebookIDKey                           = @"facebookId";
NSString *const kZPUserPhotoIDKey                              = @"photoId";
NSString *const kZPUserProfilePicSmallKey                      = @"profilePictureSmall";
NSString *const kZPUserProfilePicMediumKey                     = @"profilePictureMedium";
NSString *const kZPUserFacebookFriendsKey                      = @"facebookFriends";
NSString *const kZPUserAlreadyAutoFollowedFacebookFriendsKey   = @"userAlreadyAutoFollowedFacebookFriends";
NSString *const kZPUserEmailKey                                = @"email";
NSString *const kZPUserAutoFollowKey                           = @"autoFollow";
NSString *const kZPUserBalanceKey                              = @"balance";

#pragma mark - Transaction Class

NSString *const kZPTransactionKey                              = @"Transactions";

// Field keys
NSString *const kZPTransactionAmountKey                        = @"amount";
NSString *const kZPTransactionNoteKey                          = @"note";
NSString *const kZPTransactionFromUserKey                      = @"fromUser";
NSString *const kZPTransactionToUserKey                        = @"toUser";
NSString *const kZPTransactionCreatedAtKey                     = @"createdAt";
NSString *const kZPTransactionTypeKey                          = @"type";
NSString *const kZPTransactionPaymentKey                       = @"payment";
NSString *const kZPTransactionCashOutKey                       = @"cashOut";


#pragma mark - TransactionObject Class
NSString *const kZPTransactionObjectKey                        = @"TransactionObject";


#pragma mark - Photo Class
// Class key
NSString *const kZPPhotoClassKey = @"Photo";

@end
