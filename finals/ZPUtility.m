//
//  ZPUtility.m
//  finals
//
//  Created by Ziyad Parekh on 12/25/15.
//  Copyright (c) 2015 Ziyad Parekh. All rights reserved.
//

#import "ZPUtility.h"
#import "ZPConstants.h"
#import "UIImage+ResizeAdditions.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@implementation ZPUtility

#pragma mark - Transactions

+ (void)submitTransaction:(PFObject *)transaction toUserInBackground:(PFUser *)user block:(void (^)(BOOL, NSError *))completionBlock {
    if ([[user objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
        return;
    }
    
    NSError *error = nil;
    
    PFObject *transactionActivity = [PFObject objectWithClassName:kZPTransactionKey];
    [transactionActivity setObject:[PFUser currentUser] forKey:kZPTransactionFromUserKey];
    [transactionActivity setObject:user forKey:kZPTransactionToUserKey];
    [transactionActivity setObject:kZPTransactionPaymentKey forKey:kZPTransactionTypeKey];
    [transactionActivity setObject:[transaction objectForKey:kZPTransactionAmountKey] forKey:kZPTransactionAmountKey];
    [transactionActivity setObject:[transaction objectForKey:kZPTransactionTotalAmountKey] forKey:kZPTransactionTotalAmountKey];
    [transactionActivity setObject:[transaction objectForKey:kZPTransactionNoteKey] forKey:kZPTransactionNoteKey];
    
    PFACL *transactionAcl = [PFACL ACLWithUser:[PFUser currentUser]];
    [transactionAcl setPublicReadAccess:YES];
    [transactionAcl setWriteAccess:YES forUser:[PFUser currentUser]];
    transactionActivity.ACL = transactionAcl;
    [transactionActivity save:&error];
    
    if (error != nil) {
        completionBlock(NO, error);
    } else {
        completionBlock(YES, error);
    }
}

+ (void)submitTransaction:(PFObject *)transaction toUsers:(NSArray *)users block:(void (^)(BOOL, NSError *))completionBlock {
    for (PFUser *user in users) {
        [ZPUtility submitTransaction:transaction toUserInBackground:user block:completionBlock];
    }
}

#pragma mark - Facebook

+ (void)processFacebookProfilePictureData:(NSData *)newProfilePictureData {
    NSLog(@"Processing profile picture of size: %@", @(newProfilePictureData.length));
    if (newProfilePictureData.length == 0) {
        return;
    }
    
    UIImage *image = [UIImage imageWithData:newProfilePictureData];
    
    UIImage *mediumImage = [image thumbnailImage:280 transparentBorder:0 cornerRadius:0 interpolationQuality:kCGInterpolationHigh];
    UIImage *smallRoundedImage = [image thumbnailImage:64 transparentBorder:0 cornerRadius:0 interpolationQuality:kCGInterpolationLow];
    
    NSData *mediumImageData = UIImageJPEGRepresentation(mediumImage, 0.5); // using JPEG for larger pictures
    NSData *smallRoundedImageData = UIImagePNGRepresentation(smallRoundedImage);
    
    if (mediumImageData.length > 0) {
        PFFile *fileMediumImage = [PFFile fileWithData:mediumImageData];
        [fileMediumImage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                [[PFUser currentUser] setObject:fileMediumImage forKey:kZPUserProfilePicMediumKey];
                [[PFUser currentUser] saveInBackground];
            }
        }];
    }
    
    if (smallRoundedImageData.length > 0) {
        PFFile *fileSmallRoundedImage = [PFFile fileWithData:smallRoundedImageData];
        [fileSmallRoundedImage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                [[PFUser currentUser] setObject:fileSmallRoundedImage forKey:kZPUserProfilePicSmallKey];
                [[PFUser currentUser] saveInBackground];
            }
        }];
    }
    NSLog(@"Processed profile picture");
}

+ (BOOL)userHasValidFacebookData:(PFUser *)user {
    // Check that PFUser has valid fbid that matches current FBSessions userId
    NSString *facebookId = [user objectForKey:kZPUserFacebookIDKey];
    return (facebookId && facebookId.length > 0 && [facebookId isEqualToString:[FBSDKAccessToken currentAccessToken].userID]);
}

+ (BOOL)userHasProfilePictures:(PFUser *)user {
    PFFile *profilePictureMedium = [user objectForKey:kZPUserProfilePicMediumKey];
    PFFile *profilePictureSmall = [user objectForKey:kZPUserProfilePicSmallKey];
    
    return (profilePictureMedium && profilePictureSmall);
}

+ (UIImage *)defaultProfilePicture {
    return [UIImage imageNamed:@"profile_default.png"];
}


#pragma mark Display Name

+ (NSString *)formattedLowerCaseName:(NSString *)name {
    if (!name || name.length == 0) {
        return @"@someone";
    }
    NSArray *nameComponenets = [name componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *joinedComponents = [nameComponenets componentsJoinedByString:@"-"];
    
    if (joinedComponents.length > 50) {
        joinedComponents = [joinedComponents substringToIndex:50];
    }
    return [NSString stringWithFormat:@"@%@", joinedComponents];
    
}

+ (NSString *)firstNameForDisplayName:(NSString *)displayName {
    if (!displayName || displayName.length == 0) {
        return @"Someone";
    }
    
    NSArray *displayNameComponents = [displayName componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *firstName = [displayNameComponents objectAtIndex:0];
    
    if (firstName.length > 100) {
        // truncate to 100 so that it fits in a Push payload
        firstName = [firstName substringToIndex:100];
    }
    return firstName;
}

+ (UIAlertController *)presentAlertControllerWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [alertController dismissViewControllerAnimated:YES completion:nil];
    }]];
    
    return alertController;
}


@end
