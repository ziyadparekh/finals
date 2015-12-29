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

static TTTTimeIntervalFormatter *timeFormatter;

@interface ZPActivityTableViewCell ()

/*! Private view components */
@property (nonatomic, strong) ZPProfileImageView *activityImageView;
@property (nonatomic, strong) UIButton *activityImageButton;

/*! Flag to remove the right-hand side image if not necessary */
@property (nonatomic) BOOL hasActivityImage;

/*! Private setter for the right-hand side image */
- (void)setActivityImageFile:(PFFile *)image;

/*! Button touch handler for activity image button overlay */
- (void)didTapActivityButton:(id)sender;

/*! Static helper method to calculate the space available for text given images and insets */
+ (CGFloat)horizontalTextSpaceForInsetWidth:(CGFloat)insetWidth;

@end


@implementation ZPActivityTableViewCell

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
        self.hasActivityImage = NO; // No until one is set
        
        self.activityImageView = [[ZPProfileImageView alloc] init];
        [self.activityImageView setBackgroundColor:[UIColor clearColor]];
        [self.activityImageView setOpaque:YES];
        [self.mainView addSubview:self.activityImageView];
        
        self.activityImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.activityImageButton setBackgroundColor:[UIColor clearColor]];
        [self.activityImageButton addTarget:self action:@selector(didTapActivityButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.mainView addSubview:self.activityImageButton];
    }
    return self;
}

#pragma mark - UIView

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // Layout the activity image and show it if it is not nil (no image for the follow activity).
    // Note that the image view is still allocated and ready to be dispalyed since these cells
    // will be reused for all types of activity.
    [self.activityImageView setFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 46.0f, 13.0f, 33.0f, 33.0f)];
    [self.activityImageButton setFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 46.0f, 13.0f, 33.0f, 33.0f)];
    
    // Add activity image if one was set
    if (self.hasActivityImage) {
        [self.activityImageView setHidden:NO];
        [self.activityImageButton setHidden:NO];
    } else {
        [self.activityImageView setHidden:YES];
        [self.activityImageButton setHidden:YES];
    }
    
    // Change frame of the content text so it doesn't go through the right-hand side picture
    CGSize contentSize = [self.contentLabel.text boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 72.0f - 46.0f, CGFLOAT_MAX)
                                                              options:NSStringDrawingUsesLineFragmentOrigin // wordwrap?
                                                           attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13.0f]}
                                                              context:nil].size;
    [self.contentLabel setFrame:CGRectMake( 46.0f, 16.0f, contentSize.width, contentSize.height)];
    
    // Layout the timestamp label given new vertical
    CGSize timeSize = [self.timeLabel.text boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 72.0f - 46.0f, CGFLOAT_MAX)
                                                        options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin
                                                     attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:11.0f]}
                                                        context:nil].size;
    [self.timeLabel setFrame:CGRectMake( 46.0f, self.contentLabel.frame.origin.y + self.contentLabel.frame.size.height + 7.0f, timeSize.width, timeSize.height)];
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
    if ([[activity objectForKey:kZPTransactionTypeKey] isEqualToString:kZPTransactionPaymentKey] || [[activity objectForKey:kZPTransactionTypeKey] isEqualToString:kZPTransactionCashOutKey]) {
        [self setActivityImageFile:nil];
    } else {
        // Need to do something here for activity with an image file
        // Not supported yet
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
        nameString = [self.user objectForKey:kZPUserDisplayNameKey];
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

+ (CGFloat)heightForCellWithName:(NSString *)name contentString:(NSString *)content cellInsetWidth:(CGFloat)cellInset {
    CGSize nameSize = [name boundingRectWithSize:CGSizeMake(200.0f, CGFLOAT_MAX)
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

- (void)setActivityImageFile:(PFFile *)imageFile {
    if (imageFile) {
        [self.activityImageView setFile:imageFile];
        [self setHasActivityImage:YES];
    } else {
        [self setHasActivityImage:NO];
    }
}

- (void)didTapActivityButton:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(cell:didTapActivityButton:)]) {
        [self.delegate cell:self didTapActivityButton:self.activity];
    }
}


/* Extra boilerplate code  */
- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
