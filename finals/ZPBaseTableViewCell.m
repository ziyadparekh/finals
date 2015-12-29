//
//  ZPBaseTableViewCell.m
//  finals
//
//  Created by Ziyad Parekh on 12/28/15.
//  Copyright (c) 2015 Ziyad Parekh. All rights reserved.
//

#import "ZPBaseTableViewCell.h"
#import <FormatterKit/TTTTimeIntervalFormatter.h>
#import "ZPProfileImageView.h"
#import "ZPUtility.h"
#import "ZPConstants.h"

static TTTTimeIntervalFormatter *timeFormatter;

@interface ZPBaseTableViewCell () {
    BOOL hideSeparator; // True if the separator shouldn't be shown
}

/* Private static helper to obtain the horizontal space left for name and content after taking the inset and image in consideration */
+ (CGFloat)horizontalTextSpaceForInsetWidth:(CGFloat)insetWidth;
@end


@implementation ZPBaseTableViewCell

@synthesize mainView;
@synthesize cellInsetWidth;
@synthesize avatarImageView;
@synthesize avatarImageButton;
@synthesize nameButton;
@synthesize contentLabel;
@synthesize timeLabel;
@synthesize separatorImage;
@synthesize delegate;
@synthesize user;

#pragma mark - NSObject

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        // Initialization code
        if (!timeFormatter) {
            timeFormatter = [[TTTTimeIntervalFormatter alloc] init];
        }
        
        cellInsetWidth = 0.0f;
        hideSeparator = NO;
        self.clipsToBounds = YES;
        horizontalTextSpace = [ZPBaseTableViewCell horizontalTextSpaceForInsetWidth:cellInsetWidth];
        
        self.opaque = YES;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryNone;
        self.backgroundColor = [UIColor clearColor];
        
        mainView = [[UIView alloc] initWithFrame:self.contentView.frame];
        [mainView setBackgroundColor:[UIColor whiteColor]];
        
        self.avatarImageView = [[ZPProfileImageView alloc] init];
        [self.avatarImageView setBackgroundColor:[UIColor clearColor]];
        [self.avatarImageView setOpaque:YES];
        self.avatarImageView.layer.masksToBounds = YES;
        [mainView addSubview:self.avatarImageView];
        
        self.nameButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.nameButton setBackgroundColor:[UIColor clearColor]];
        
        if ([reuseIdentifier isEqualToString:@"ActivityCell"]) {
            [self.nameButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            [self.nameButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
        } else {
            [self.nameButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            [self.nameButton setTitleColor:[UIColor greenColor] forState:UIControlStateHighlighted];
        }
        [self.nameButton.titleLabel setFont:[UIFont boldSystemFontOfSize:13]];
        [self.nameButton.titleLabel setLineBreakMode:NSLineBreakByTruncatingTail];
        [self.nameButton addTarget:self action:@selector(didTapUserButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [mainView addSubview:self.nameButton];
        
        self.timeLabel = [[UILabel alloc] init];
        [self.timeLabel setFont:[UIFont systemFontOfSize:11]];
        [self.timeLabel setTextColor:[UIColor lightGrayColor]];
        [self.timeLabel setBackgroundColor:[UIColor clearColor]];
        [mainView addSubview:self.timeLabel];
        
        self.avatarImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.avatarImageButton setBackgroundColor:[UIColor clearColor]];
        [self.avatarImageButton addTarget:self action:@selector(didTapUserButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [mainView addSubview:self.avatarImageButton];
        
        self.separatorImage = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"SeparatorComments.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 0, 1)]];
        
        [self.contentView addSubview:mainView];
    }
    
    return self;
}

#pragma mark - UIView

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [mainView setFrame:CGRectMake(cellInsetWidth, self.contentView.frame.origin.y, self.contentView.frame.size.width - (2 * cellInsetWidth), self.contentView.frame.size.height)];
    
    // Layout avatar image
    [self.avatarImageView setFrame:CGRectMake(avatarX, avatarY + 5.0f, avatarDim, avatarDim)];
    [self.avatarImageButton setFrame:CGRectMake(avatarX, avatarY + 5.0f, avatarDim, avatarDim)];
    
    // Layout the name button
    CGSize nameSize = [self.nameButton.titleLabel.text boundingRectWithSize:CGSizeMake(nameMaxWidth, CGFLOAT_MAX)
                                                                    options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin
                                                                 attributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:13.0f]} context:nil].size;
    [self.nameButton setFrame:CGRectMake(nameX, nameY + 6.0f, nameSize.width, nameSize.height)];
    
    // Layout the content
    CGSize contentSize = [self.contentLabel.text boundingRectWithSize:CGSizeMake(horizontalTextSpace, CGFLOAT_MAX)
                                                              options:NSStringDrawingUsesLineFragmentOrigin
                                                           attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:13.0f]} context:nil].size;
    [self.contentLabel setFrame:CGRectMake(nameX, vertBorderSpacing + 6.0f, contentSize.width, contentSize.height)];
    
    // Layout the timestamp label
    CGSize timeSize = [self.timeLabel.text boundingRectWithSize:CGSizeMake(horizontalTextSpace, CGFLOAT_MAX)
                                                        options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin
                                                     attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:11.0f]}
                                                        context:nil].size;
    [self.timeLabel setFrame:CGRectMake(timeX, contentLabel.frame.origin.y + contentLabel.frame.size.height + vertElemSpacing, timeSize.width, timeSize.height)];
    
    // Layout separator
    [self.separatorImage setFrame:CGRectMake(0, self.frame.size.height-1, self.frame.size.width-cellInsetWidth*2, 1)];
    [self.separatorImage setHidden:hideSeparator];
}

#pragma mark - Delegate methods

/* Inform delegate that a user image or name was tapped */
- (void)didTapUserButtonAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(cell:didTapUserButton:)]) {
        [self.delegate cell:self didTapUserButton:self.user];
    }
}

#pragma mark - ZPBaseTableViewCell

/* Static helper to get the height for a cell if it had the given name and content */
+ (CGFloat)heightForCellWithName:(NSString *)name contentString:(NSString *)content {
    return [ZPBaseTableViewCell heightForCellWithName:name contentString:content cellInsetWidth:0];
}

+ (CGFloat)heightForCellWithName:(NSString *)name contentString:(NSString *)content cellInsetWidth:(CGFloat)cellInset {
    CGSize nameSize = [name boundingRectWithSize:nameSize
                                         options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin
                                      attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:13.0f]}
                                         context:nil].size;
    
    NSString *paddedString = [ZPBaseTableViewCell padString:content withFont:[UIFont systemFontOfSize:13] toWidth:nameSize.width];
    CGFloat horizontalTextSpace = [ZPBaseTableViewCell horizontalTextSpaceForInsetWidth:cellInset];
    
    CGSize contentSize = [paddedString boundingRectWithSize:CGSizeMake(horizontalTextSpace, CGFLOAT_MAX)
                                                    options:NSStringDrawingUsesLineFragmentOrigin
                                                 attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:13.0f]}
                                                    context:nil].size;
    
    CGFloat singleLineHeight = [@"test" boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                                                     options:NSStringDrawingUsesLineFragmentOrigin
                                                  attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:13.0f]}
                                                     context:nil].size.height;
    
    // Calculate the added height necessary for multiline text. Ensure value is not below 0.
    CGFloat multilineHeightAddition = (contentSize.height - singleLineHeight) > 0 ? (contentSize.height - singleLineHeight) : 0;
    
    return horiBorderSpacing + avatarDim + horiBorderSpacingBottom + multilineHeightAddition;
}

/* Static helper to obtain the horizontal space left for name and content after taking the inset and image in consideration */
+ (CGFloat)horizontalTextSpaceForInsetWidth:(CGFloat)insetWidth {
    return (320 - (insetWidth * 2)) - (horiBorderSpacing + avatarDim + horiElemSpacing + horiBorderSpacing);
}

/* Static helper to pad a string with spaces to a given beginning offset */
+ (NSString *)padString:(NSString *)string withFont:(UIFont *)font toWidth:(CGFloat)width {
    // Find number of spaces to pad
    NSMutableString *paddedString = [[NSMutableString alloc] init];
    while (true) {
        [paddedString appendString:@" "];
        CGSize resultSize = [paddedString boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                                                       options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin
                                                    attributes:@{NSFontAttributeName:font}
                                                       context:nil].size;
        if (resultSize.width >= width) {
            break;
        }
    }
    
    // Add final spaces to be ready for first word
    [paddedString appendString:[NSString stringWithFormat:@" %@", string]];
    return paddedString;
}

- (void)setUser:(PFUser *)aUser {
    user = aUser;
    
    // Set name button properties and avatar image
    if ([ZPUtility userHasProfilePictures:self.user]) {
        [self.avatarImageView setFile:[self.user objectForKey:kZPUserProfilePicSmallKey]];
    } else {
        [self.avatarImageView setImage:[ZPUtility defaultProfilePicture]];
    }
    
    [self.nameButton setTitle:[self.user objectForKey:kZPUserDisplayNameKey] forState:UIControlStateNormal];
    [self.nameButton setTitle:[self.user objectForKey:kZPUserDisplayNameKey] forState:UIControlStateHighlighted];
    
    // If user is set after contentText, we reset the content to make room for the name
    if (self.contentLabel.text) {
        [self setContentText:self.contentLabel.text];
    }
    [self setNeedsDisplay];
}

- (void)setContentText:(NSString *)contentString {
    if (self.user) {
        CGSize nameSize = [self.nameButton.titleLabel.text boundingRectWithSize:CGSizeMake(nameMaxWidth, CGFLOAT_MAX)
                                                        options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin
                                                        attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:13.0f]}
                                                        context:nil].size;
        NSString *paddedString = [ZPBaseTableViewCell padString:contentString withFont:[UIFont systemFontOfSize:13] toWidth:nameSize.width];
        [self.contentLabel setText:paddedString];
    } else {
        [self.contentLabel setText:contentString];
    }
    [self setNeedsDisplay];
}

- (void)setDate:(NSDate *)date {
    // Set the label with a human readable time
    [self.timeLabel setText:[timeFormatter stringForTimeIntervalFromDate:[NSDate date] toDate:date]];
    [self setNeedsDisplay];
}

- (void)setCellInsetWidth:(CGFloat)insetWidth {
    // Change the mainViews frame to be insetted by insetWidth and update the content text space
    cellInsetWidth = insetWidth;
    [mainView setFrame:CGRectMake(insetWidth, mainView.frame.origin.y, mainView.frame.size.width - (2 * insetWidth), mainView.frame.size.height)];
    horizontalTextSpace = [ZPBaseTableViewCell horizontalTextSpaceForInsetWidth:insetWidth];
    [self setNeedsDisplay];
}

/* Since we remove the compile-time check for the delegate conforming to the protocol
 in order to allow inheritance, we add run-time checks. */
- (id<ZPBaseTableViewCellDelegate>)delegate {
    return (id<ZPBaseTableViewCellDelegate>)delegate;
}

- (void)setDelegate:(id<ZPBaseTableViewCellDelegate>)aDelegate {
    if (delegate != aDelegate) {
        delegate = aDelegate;
    }
}

- (void)hideSeparator:(BOOL)hide {
    hideSeparator = hide;
}


/* Extra boilerplate code */
- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
