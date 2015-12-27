//
//  ZPProfileImageView.m
//  finals
//
//  Created by Ziyad Parekh on 12/26/15.
//  Copyright (c) 2015 Ziyad Parekh. All rights reserved.
//

#import "ZPProfileImageView.h"
#import <ParseUI/ParseUI.h>

@interface ZPProfileImageView ()
@property (strong, nonatomic) UIImageView *borderImageView;
@end

@implementation ZPProfileImageView

@synthesize borderImageView;
@synthesize profileImageView;
@synthesize profileButton;

#pragma mark - NSObject

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        self.profileImageView = [[PFImageView alloc] initWithFrame:frame];
        [self addSubview:self.profileImageView];
        
        self.profileButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:self.profileButton];
        
        [self addSubview:self.borderImageView];
    }
    return self;
}

#pragma mark - UIView

- (void)layoutSubviews {
    [super layoutSubviews];
    [self bringSubviewToFront:self.borderImageView];
    
    self.profileImageView.frame = CGRectMake( 0.0f, 0.0f, self.frame.size.width, self.frame.size.height);
    self.borderImageView.frame = CGRectMake( 0.0f, 0.0f, self.frame.size.width, self.frame.size.height);
    self.profileButton.frame = CGRectMake( 0.0f, 0.0f, self.frame.size.width, self.frame.size.height);
}


#pragma mark - PAPProfileImageView

- (void)setFile:(PFFile *)file {
    if (!file) {
        return;
    }
    
    self.profileImageView.image = [UIImage imageNamed:@"AvatarPlaceholder.png"];
    self.profileImageView.file = file;
    [self.profileImageView loadInBackground];
}

- (void)setImage:(UIImage *)image {
    self.profileImageView.image = image;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
