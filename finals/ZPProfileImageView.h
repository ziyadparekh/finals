//
//  ZPProfileImageView.h
//  finals
//
//  Created by Ziyad Parekh on 12/26/15.
//  Copyright (c) 2015 Ziyad Parekh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@class PFImageView;
@interface ZPProfileImageView : UIView

@property (nonatomic, strong) UIButton *profileButton;
@property (nonatomic, strong) PFImageView *profileImageView;

- (void)setFile:(PFFile *)file;
- (void)setImage:(UIImage *)image;

@end
