//
//  ZPUtility.h
//  finals
//
//  Created by Ziyad Parekh on 12/25/15.
//  Copyright (c) 2015 Ziyad Parekh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface ZPUtility : NSObject

+ (void)submitTransaction:(PFObject *)transaction toUserInBackground:(PFUser *)user block:(void (^)(BOOL succeeded, NSError *error))completionBlock;
+ (void)submitTransaction:(PFObject *)transaction toUsers:(NSArray *)users block:(void (^)(BOOL succeeded, NSError *error))completionBlock;

+ (void)processFacebookProfilePictureData:(NSData *)data;

+ (BOOL)userHasValidFacebookData:(PFUser *)user;
+ (BOOL)userHasProfilePictures:(PFUser *)user;
+ (UIImage *)defaultProfilePicture;

+ (NSString *)firstNameForDisplayName:(NSString *)displayName;

@end
