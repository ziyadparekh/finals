//
//  UIColor+ZPColors.h
//  finals
//
//  Created by Ziyad Parekh on 12/25/15.
//  Copyright (c) 2015 Ziyad Parekh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIColor (ZPColors)

#pragma mark - Grey colors

+ (UIColor *)zp_superLightGreyColor;
+ (UIColor *)zp_veryLightGreyColor;
+ (UIColor *)zp_lightGreyColor;
+ (UIColor *)zp_greyColor;
+ (UIColor *)zp_mediumGreyColor;
+ (UIColor *)zp_darkGreyColor;
+ (UIColor *)zp_dividerGreyColor;
+ (UIColor *)zp_composeGreyBackgroundColor;
+ (UIColor *)zp_placeholderTextGreyColor;
+ (UIColor *)zp_valleyGrey;
+ (UIColor *)zp_horseGrey;
+ (UIColor *)zp_extraLightGrey;


#pragma mark - Blue colors

+ (UIColor *)zp_venmoBlueColor;
+ (UIColor *)zp_mediumBlueGreyColor;
+ (UIColor *)zp_lightBlueColor;
+ (UIColor *)zp_buttonBlueColor;
+ (UIColor *)zp_heartBlueColor;
+ (UIColor *)zp_linkSelectedBlueColor;


#pragma mark - Drawer colors

+ (UIColor *)zp_drawerBackgroundColor;
+ (UIColor *)zp_drawerSelectedTextColor;
+ (UIColor *)zp_drawerSelectedCellBackgroundColor;
+ (UIColor *)zp_drawerTextColor;
+ (UIColor *)zp_drawerLineColor;


#pragma mark - Other colors

+ (UIColor *)zp_greenColor;
+ (UIColor *)zp_redColor;
+ (UIColor *)zp_orangeColor;

@end