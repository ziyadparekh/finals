//
//  ZPActivityTableViewCell.h
//  finals
//
//  Created by Ziyad Parekh on 12/28/15.
//  Copyright (c) 2015 Ziyad Parekh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZPBaseTableViewCell.h"

@protocol ZPActivityTableViewCellDelegate;

@interface ZPActivityTableViewCell : ZPBaseTableViewCell

/*!Setter for the activity associated with this cell */
@property (nonatomic, strong) PFObject *activity;

/*!Set the new state. This changes the background of the cell. */
- (void)setIsNew:(BOOL)isNew;

@end

/*!
 The protocol defines methods a delegate of a PAPBaseTextCell should implement.
 */
@protocol ZPActivityTableViewCellDelegate <ZPBaseTableViewCellDelegate>
@optional

/*!
 Sent to the delegate when the activity button is tapped
 @param activity the PFObject of the activity that was tapped
 */
- (void)cell:(ZPActivityTableViewCell *)cellView didTapActivityButton:(PFObject *)activity;

@end
