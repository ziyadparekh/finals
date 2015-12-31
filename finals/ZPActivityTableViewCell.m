//
//  ZPActivityTableViewCell.m
//  finals
//
//  Created by Ziyad Parekh on 12/28/15.
//  Copyright (c) 2015 Ziyad Parekh. All rights reserved.
//

#import "ZPActivityTableViewCell.h"
#import <FormatterKit/TTTTimeIntervalFormatter.h>
#import "ZPActivityFeedViewController.h"
#import "ZPProfileImageView.h"
#import "ZPConstants.h"
#import "ZPUtility.h"
#import "UIColor+ZPColors.h"

static TTTTimeIntervalFormatter *timeFormatter;

@interface ZPActivityTableViewCell ()

/*! Private view components */
@property (nonatomic, strong) UILabel *amountLabel;
@property (nonatomic, strong) UILabel *noteLabel;
@property (nonatomic, strong) UIButton *toNameButton;

/*! Flag to remove the right-hand side image if not necessary */
- (BOOL)hasAmount;

/*! Button touch handler for activity image button overlay */
- (void)didTapActivityButton:(id)sender;
/*! Button touch handler for recipient user */
- (void)didTapToUserButtonAction:(id)sender;

/*! Static helper method to calculate the space available for text given images and insets */
+ (CGFloat)horizontalTextSpaceForInsetWidth:(CGFloat)insetWidth;

@end


@implementation ZPActivityTableViewCell
@synthesize amountLabel;
@synthesize noteLabel;
@synthesize toNameButton;

#pragma mark - NSObject

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        horizontalTextSpace = [ZPActivityTableViewCell horizontalTextSpaceForInsetWidth:0];
        
        if (!timeFormatter) {
            timeFormatter = [[TTTTimeIntervalFormatter alloc] init];
        }
        
        // Create subviews and set cell properties
        self.opaque = YES;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryNone;
        
        self.toNameButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.toNameButton setBackgroundColor:[UIColor clearColor]];
        [self.toNameButton setTitleColor:[UIColor zp_darkGreyColor] forState:UIControlStateNormal];
        [self.toNameButton setTitleColor:[UIColor zp_darkGreyColor] forState:UIControlStateHighlighted];
        [self.toNameButton.titleLabel setFont:[UIFont boldSystemFontOfSize:13]];
        [self.toNameButton.titleLabel setLineBreakMode:NSLineBreakByTruncatingTail];
        [self.toNameButton addTarget:self action:@selector(didTapToUserButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.mainView addSubview:self.toNameButton];
        
        self.amountLabel = [[UILabel alloc] init];
        [self.amountLabel setFont:[UIFont boldSystemFontOfSize:10.0f]];
        [self.amountLabel setNumberOfLines:1];
        [self.amountLabel setBackgroundColor:[UIColor clearColor]];
        self.amountLabel.textAlignment = NSTextAlignmentRight;
        [self.mainView addSubview:self.amountLabel];
        
        self.noteLabel = [[UILabel alloc] init];
        [self.noteLabel setFont:[UIFont systemFontOfSize:11.0f]];
        [self.noteLabel setTextColor:[UIColor zp_darkGreyColor]];
        [self.noteLabel setNumberOfLines:0];
        [self.noteLabel setBackgroundColor:[UIColor clearColor]];
        [self.mainView addSubview:self.noteLabel];
        
        [self.mainView bringSubviewToFront:self.nameButton];
        [self.mainView bringSubviewToFront:self.contentLabel];
        
    }
    return self;
}

- (BOOL)hasAmount {
    if ([[[self.activity objectForKey:kZPTransactionFromUserKey] objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
        return YES;
    } else if ([[[self.activity objectForKey:kZPTransactionToUserKey] objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - UIView

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // Layout the activity image and show it if it is not nil (no image for the follow activity).
    // Note that the image view is still allocated and ready to be dispalyed since these cells
    // will be reused for all types of activity.
    CGSize amountSize = [self.amountLabel.text boundingRectWithSize:CGSizeMake(nameMaxWidth, CGFLOAT_MAX)
                                                              options:NSStringDrawingUsesLineFragmentOrigin // wordwrap?
                                                           attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:10.0f]}
                                                              context:nil].size;
    [self.amountLabel setFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - amountSize.width - 10.0f, nameY + 10.0f, amountSize.width, amountSize.height)];
    
    // Add amount label if user is part of transaction
    if ([self hasAmount]) {
        [self.amountLabel setHidden:NO];
    } else {
        [self.amountLabel setHidden:YES];
    }
    
    // Change frame of the content text so it doesn't go through the right-hand side picture
    CGSize contentSize = [self.contentLabel.text boundingRectWithSize:CGSizeMake(nameMaxWidth, CGFLOAT_MAX)
                                                              options:NSStringDrawingUsesLineFragmentOrigin // wordwrap?
                                                           attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13.0f]}
                                                              context:nil].size;
    [self.contentLabel setFrame:CGRectMake(self.nameButton.frame.origin.x, nameY + 6.0f, contentSize.width, contentSize.height)];
    
    CGSize toNameSize = [self.toNameButton.titleLabel.text boundingRectWithSize:CGSizeMake(nameMaxWidth, CGFLOAT_MAX)
                                                                        options:NSStringDrawingTruncatesLastVisibleLine
                                                                     attributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:13.0f]} context:nil].size;
    [self.toNameButton setFrame:CGRectMake(self.contentLabel.frame.origin.x, nameY + 6.0f, toNameSize.width, toNameSize.height)];
    
    CGSize noteSize = [self.noteLabel.text boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - avatarDim - 16.0f, CGFLOAT_MAX)
                                                        options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin
                                                     attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:11.0f]}
                                                        context:nil].size;
    [self.noteLabel setFrame:CGRectMake(self.nameButton.frame.origin.x, self.contentLabel.frame.origin.y + self.contentLabel.frame.size.height + 3.0f, noteSize.width, noteSize.height)];
    
    // Layout the timestamp label given new vertical
    CGSize timeSize = [self.timeLabel.text boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 72.0f - 46.0f, CGFLOAT_MAX)
                                                        options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin
                                                     attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:10.0f]}
                                                        context:nil].size;
    [self.timeLabel setFrame:CGRectMake( self.nameButton.frame.origin.x, self.mainView.bounds.size.height - timeSize.height - 5.0f, timeSize.width, timeSize.height)];
}

- (void)setIsNew:(BOOL)isNew {
    if (isNew) {
        [self.mainView setBackgroundColor:[UIColor colorWithRed:29.0f/255.0f green:29.0f/255.0f blue:29.0f/255.0f alpha:1.0f]];
    } else {
        [self.mainView setBackgroundColor:[UIColor blackColor]];
    }
}

- (void)setActivity:(PFObject *)activity {
    // Set the activity property
    _activity = activity;
    
    float amountString = [[activity objectForKey:kZPTransactionAmountKey] floatValue];
    if ([[[activity objectForKey:kZPTransactionFromUserKey] objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
        [self.amountLabel setTextColor:[UIColor zp_redColor]];
        [self.amountLabel setText:[NSString stringWithFormat:@"- Rs%.02f", amountString]];
    } else {
        [self.amountLabel setTextColor:[UIColor zp_greenColor]];
        [self.amountLabel setText:[NSString stringWithFormat:@"+ Rs%.02f", amountString]];
    }
    
    NSString *activityString = [ZPActivityFeedViewController stringForActivityType:(NSString *)[activity objectForKey:kZPTransactionTypeKey]];
    self.user = [activity objectForKey:kZPTransactionFromUserKey];
    
    // Set the name button properties and avatar image
    if ([ZPUtility userHasProfilePictures:self.user]) {
        [self.avatarImageView setFile:[self.user objectForKey:kZPUserProfilePicSmallKey]];
    } else {
        [self.avatarImageView setImage:[ZPUtility defaultProfilePicture]];
    }
    
    NSString *nameString = NSLocalizedString(@"Someone", @"Text when the user's name is unknown");
    if (self.user && [self.user objectForKey:kZPUserDisplayNameKey] && [[self.user objectForKey:kZPUserDisplayNameKey] length] > 0) {
        nameString = [ZPUtility firstNameForDisplayName:[self.user objectForKey:kZPUserDisplayNameKey]];
    }
    [self.nameButton setTitle:nameString forState:UIControlStateNormal];
    [self.nameButton setTitle:nameString forState:UIControlStateHighlighted];
    
    // If user is set after the contentText, we reset the content to include the padding
    if (self.contentLabel.text) {
        [self setContentText:self.contentLabel.text];
    }
    
    if (self.user) {
        CGSize nameSize = [self.nameButton.titleLabel.text boundingRectWithSize:CGSizeMake(nameMaxWidth, CGFLOAT_MAX)
                                                        options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin
                                                        attributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:13.0f]}
                                                        context:nil].size;
        NSString *paddedString = [ZPBaseTableViewCell padString:activityString withFont:[UIFont systemFontOfSize:13.0f] toWidth:nameSize.width];
        [self.contentLabel setText:paddedString];
    } else {
        [self.contentLabel setText:activityString];
    }
    
    CGSize contentLabelSize = [self.contentLabel.text boundingRectWithSize:CGSizeMake(nameMaxWidth, CGFLOAT_MAX)
                                                    options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin
                                                    attributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:13.0f]}
                                                    context:nil].size;
    NSString *toUserString = [ZPUtility firstNameForDisplayName:[[activity objectForKey:kZPTransactionToUserKey] objectForKey:kZPUserDisplayNameKey]];
    NSString *toUserPaddedString = [ZPBaseTableViewCell padString:toUserString withFont:[UIFont boldSystemFontOfSize:13.0f] toWidth:contentLabelSize.width];

    [self.toNameButton setTitle:toUserPaddedString forState:UIControlStateNormal];
    [self.noteLabel setText:[activity objectForKey:kZPTransactionNoteKey]];
    [self.timeLabel setText:[timeFormatter stringForTimeIntervalFromDate:[NSDate date] toDate:[activity createdAt]]];
    
    [self setNeedsDisplay];
}

- (void)setCellInsetWidth:(CGFloat)insetWidth {
    [super setCellInsetWidth:insetWidth];
    horizontalTextSpace = [ZPActivityTableViewCell horizontalTextSpaceForInsetWidth:insetWidth];
}

// Since we remove the compile-time check for the delegate conforming to the protocol
// in order to allow inheritance, we add run-time checks.
- (id<ZPActivityTableViewCellDelegate>)delegate {
    return (id<ZPActivityTableViewCellDelegate>)_delegate;
}

- (void)setDelegate:(id<ZPActivityTableViewCellDelegate>)delegate {
    if(_delegate != delegate) {
        _delegate = delegate;
    }
}

#pragma mark - ()

+ (CGFloat)horizontalTextSpaceForInsetWidth:(CGFloat)insetWidth {
    return ([UIScreen mainScreen].bounds.size.width - (insetWidth * 2.0f)) - 72.0f - 46.0f;
}

+ (CGFloat)heightForCellWithName:(NSString *)name contentString:(NSString *)content {
    return [self heightForCellWithName:name contentString:content cellInsetWidth:0.0f];
}

+ (CGFloat)heightForCellWithName:(NSString *)name contentString:(NSString *)content noteString:(NSString *)note {
    return [self heightForCellWithName:name contentString:content noteString:note cellInsetWidth:0.0f];
}

+ (CGFloat)heightForCellWithName:(NSString *)name contentString:(NSString *)content cellInsetWidth:(CGFloat)cellInset {
    CGSize nameSize = [name boundingRectWithSize:CGSizeMake(nameMaxWidth, CGFLOAT_MAX)
                                         options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin
                                      attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:13.0f]}
                                         context:nil].size;
    NSString *paddedString = [ZPBaseTableViewCell padString:content withFont:[UIFont systemFontOfSize:13.0] toWidth:nameSize.width];
    CGFloat horizontalTextSpace = [ZPActivityTableViewCell horizontalTextSpaceForInsetWidth:cellInset];
    
    CGSize contentSize = [paddedString boundingRectWithSize:CGSizeMake(horizontalTextSpace, CGFLOAT_MAX)
                                                    options:NSStringDrawingUsesLineFragmentOrigin
                                                 attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13.0f]}
                                                    context:nil].size;
    
    
    CGFloat singleLineHeight = [@"Test" boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                                                     options:NSStringDrawingUsesLineFragmentOrigin
                                                  attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13.0f]}
                                                     context:nil].size.height;
    
    // Calculate the added height neccessary for multiline text. Ensure value is not below 0
    CGFloat multilineHeightAddition = contentSize.height - singleLineHeight;
    
    return 58.0f + fmax(0.0f, multilineHeightAddition);
}

+ (CGFloat)heightForCellWithName:(NSString *)name contentString:(NSString *)content noteString:(NSString *)note cellInsetWidth:(CGFloat)cellInset {
    CGSize nameSize = [name boundingRectWithSize:CGSizeMake(nameMaxWidth, CGFLOAT_MAX)
                                         options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin
                                      attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:13.0f]}
                                         context:nil].size;
    NSString *paddedString = [ZPBaseTableViewCell padString:content withFont:[UIFont systemFontOfSize:13.0] toWidth:nameSize.width];
    CGFloat horizontalTextSpace = [ZPActivityTableViewCell horizontalTextSpaceForInsetWidth:cellInset];
    
    CGSize contentSize = [paddedString boundingRectWithSize:CGSizeMake(horizontalTextSpace, CGFLOAT_MAX)
                                                    options:NSStringDrawingUsesLineFragmentOrigin
                                                 attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13.0f]}
                                                    context:nil].size;
    
    CGSize noteSize = [note boundingRectWithSize:CGSizeMake(horizontalTextSpace, CGFLOAT_MAX)
                                        options:NSStringDrawingUsesLineFragmentOrigin
                                      attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:11.0f]}
                                        context:nil].size;
    
    
    CGFloat singleLineHeight = [@"Test" boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                                                     options:NSStringDrawingUsesLineFragmentOrigin
                                                  attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13.0f]}
                                                     context:nil].size.height;
    
    // Calculate the added height neccessary for multiline text. Ensure value is not below 0
    CGFloat multilineHeightAddition = (contentSize.height + noteSize.height) - singleLineHeight;
    
    return 58.0f + fmax(0.0f, multilineHeightAddition);
}

- (void)didTapActivityButton:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(cell:didTapActivityButton:)]) {
        [self.delegate cell:self didTapActivityButton:self.activity];
    }
}

- (void)didTapToUserButtonAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(cell:didTapToUserButton:)]) {
        [self.delegate cell:self didTapToUserButton:[self.activity objectForKey:kZPTransactionToUserKey]];
    }
}

@end
