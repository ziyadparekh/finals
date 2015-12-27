//
//  ZPUserTableViewCell.h
//  finals
//
//  Created by Ziyad Parekh on 12/26/15.
//  Copyright (c) 2015 Ziyad Parekh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@class ZPProfileImageView;
@protocol ZPUserTableViewCellDelegate;

@interface ZPUserTableViewCell : UITableViewCell {
    id _delegate;
}

@property (strong, nonatomic) id <ZPUserTableViewCellDelegate> delegate;

/*! The user represented in the cell */
@property (nonatomic, strong) PFUser *user;
@property (nonatomic, strong) UILabel *photoLabel;

/*! Setters for the cell's content */
- (void)setUser:(PFUser *)user;

- (void)didTapUserButtonAction:(id)sender;

/*! Static Helper methods */
+ (CGFloat)heightForCell;

@end

/*!
 The protocol defines methods a delegate of a PAPFindFriendsCell should implement.
 */
@protocol ZPUserTableViewCellDelegate <NSObject>
@optional

/*!
 Sent to the delegate when a user button is tapped
 @param aUser the PFUser of the user that was tapped
 */
- (void)cell:(ZPUserTableViewCell *)cellView didTapUserButton:(PFUser *)aUser;

@end
