//
//  ZPUserTableViewCell.m
//  finals
//
//  Created by Ziyad Parekh on 12/26/15.
//  Copyright (c) 2015 Ziyad Parekh. All rights reserved.
//

#import "ZPUserTableViewCell.h"
#import "ZPProfileImageView.h"
#import "ZPUtility.h"
#import "ZPConstants.h"
#import "UIColor+ZPColors.h"

@interface ZPUserTableViewCell ()
/*! The cell's views. These shouldn't be modified but need to be exposed for the subclass */
@property (nonatomic, strong) UIButton *nameButton;
@property (nonatomic, strong) UIButton *avatarImageButton;
@property (nonatomic, strong) ZPProfileImageView *avatarImageView;

@end

@implementation ZPUserTableViewCell
@synthesize delegate;
@synthesize user;
@synthesize avatarImageView;
@synthesize avatarImageButton;
@synthesize nameButton;

#pragma mark - NSObject

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.avatarImageView = [[ZPProfileImageView alloc] init];
        self.avatarImageView.frame = CGRectMake( 5.0f, 5.0f, 40.0f, 40.0f);
        self.avatarImageView.layer.masksToBounds = YES;
        self.avatarImageView.layer.cornerRadius = 20.0f;
        [self.contentView addSubview:self.avatarImageView];
        
        self.avatarImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.avatarImageButton.backgroundColor = [UIColor clearColor];
        self.avatarImageButton.frame = CGRectMake( 5.0f, 5.0f, 40.0f, 40.0f);
        self.avatarImageButton.layer.cornerRadius = 20.0f;
        [self.avatarImageButton addTarget:self action:@selector(didTapUserButtonAction:)
                         forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.avatarImageButton];
        
        self.nameButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.nameButton.backgroundColor = [UIColor clearColor];
        self.nameButton.titleLabel.font = [UIFont boldSystemFontOfSize:14.0f];
        self.nameButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.nameButton setTitleColor:[UIColor zp_darkGreyColor] forState:UIControlStateNormal];
        [self.nameButton setTitleColor:[UIColor zp_lightGreyColor] forState:UIControlStateHighlighted];
        [self.nameButton addTarget:self action:@selector(didTapUserButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.nameButton];
        
    }
    return self;
}

#pragma mark - ZPUserTableViewCell

- (void)setUser:(PFUser *)aUser {
    user = aUser;
    
    // Configure the cell
    if ([ZPUtility userHasProfilePictures:self.user]) {
        [self.avatarImageView setFile:[self.user objectForKey:kZPUserProfilePicSmallKey]];
    } else {
        [self.avatarImageView setImage:[ZPUtility defaultProfilePicture]];
    }
    
    // Set name
    NSString *nameString = [self.user objectForKey:kZPUserDisplayNameKey];
    CGSize nameSize = [nameString boundingRectWithSize:CGSizeMake(144.0f, CGFLOAT_MAX)
                                               options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin
                                            attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:14.0f]}
                                               context:nil].size;
    [self.nameButton setTitle:[self.user objectForKey:kZPUserDisplayNameKey] forState:UIControlStateNormal];
    [self.nameButton setTitle:[self.user objectForKey:kZPUserDisplayNameKey] forState:UIControlStateHighlighted];
    
    [self.nameButton setFrame:CGRectMake( 60.0f, 15.0f, nameSize.width, nameSize.height)];
    
}

#pragma mark - ()

+ (CGFloat)heightForCell {
    return 50.0f;
}

/* Inform delegate that a user image or name was tapped */
- (void)didTapUserButtonAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(cell:didTapUserButton:)]) {
        [self.delegate cell:self didTapUserButton:self.user];
    }
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
