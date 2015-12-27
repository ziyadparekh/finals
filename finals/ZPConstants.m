//
//  ZPConstants.m
//  finals
//
//  Created by Ziyad Parekh on 12/24/15.
//  Copyright (c) 2015 Ziyad Parekh. All rights reserved.
//

#import "ZPConstants.h"

@implementation ZPConstants

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
NSString *const kZPUserTransactionsKey                         = @"transactions";


#pragma mark - Photo Class
// Class key
NSString *const kZPPhotoClassKey = @"Photo";

@end
