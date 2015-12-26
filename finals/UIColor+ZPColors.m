//
//  UIColor+ZPColors.m
//  finals
//
//  Created by Ziyad Parekh on 12/25/15.
//  Copyright (c) 2015 Ziyad Parekh. All rights reserved.
//

#import "UIColor+ZPColors.h"
#import <EDColor/UIColor+Hex.h>

@implementation UIColor (ZPColors)

#pragma mark - Grey colors

+ (UIColor *)zp_superLightGreyColor
{
    return [UIColor colorWithHexString:@"FAFBFC"];
}

+ (UIColor *)zp_veryLightGreyColor
{
    return [UIColor colorWithHexString:@"E7EBEE"];
}

+ (UIColor *)zp_lightGreyColor
{
    return [UIColor colorWithHexString:@"DEE2E5"];
}

+ (UIColor *)zp_greyColor
{
    return [UIColor colorWithHexString:@"707C7C"];
}

+ (UIColor *)zp_mediumGreyColor
{
    return [UIColor colorWithHexString:@"CACCCE"];
}

+ (UIColor *)zp_darkGreyColor
{
    return [UIColor colorWithHexString:@"262729"];
}

+ (UIColor *)zp_dividerGreyColor
{
    return [UIColor colorWithHexString:@"B7BDBD"];
}

+ (UIColor *)zp_composeGreyBackgroundColor
{
    return [UIColor colorWithHexString:@"F8F9FA"];
}

+ (UIColor *)zp_placeholderTextGreyColor
{
    return [UIColor colorWithHexString:@"C7CBCD"];
}

+ (UIColor *)zp_valleyGrey
{
    return [UIColor colorWithHexString:@"F2F2F2"];
}

+ (UIColor *)zp_horseGrey
{
    return [UIColor colorWithHexString:@"8C8C8C"];
}

+ (UIColor *)zp_extraLightGrey
{
    return [UIColor colorWithHexString:@"F9F9F9"];
}


#pragma mark - Blue colors

+ (UIColor *)zp_venmoBlueColor
{
    return [UIColor colorWithHexString:@"3D95CE"];
}

+ (UIColor *)zp_mediumBlueGreyColor
{
    return [UIColor colorWithHexString:@"C0C9CF"];
}

+ (UIColor *)zp_lightBlueColor
{
    return [UIColor colorWithHexString:@"E9F4F9"];
}

+ (UIColor *)zp_buttonBlueColor
{
    return [UIColor colorWithHexString:@"509FD3"];
}

+ (UIColor *)zp_heartBlueColor
{
    return [UIColor colorWithHexString:@"3D94CE"];
}

+ (UIColor *)zp_linkSelectedBlueColor
{
    return [UIColor colorWithHexString:@"355CC2"];
}


#pragma mark - Drawer colors

+ (UIColor *)zp_drawerBackgroundColor
{
    return [UIColor colorWithHexString:@"333B42"];
}

+ (UIColor *)zp_drawerSelectedTextColor
{
    return [UIColor colorWithHexString:@"6EBDF7"];
}

+ (UIColor *)zp_drawerSelectedCellBackgroundColor
{
    return [UIColor colorWithHexString:@"485159"];
}

+ (UIColor *)zp_drawerTextColor
{
    return [UIColor colorWithHexString:@"C0C9CF"];
}

+ (UIColor *)zp_drawerLineColor
{
    return [UIColor colorWithHexString:@"485259"];
}


#pragma mark - Other colors

+ (UIColor *)zp_greenColor
{
    return [UIColor colorWithHexString:@"59BF39"];
}

+ (UIColor *)zp_redColor
{
    return [UIColor colorWithHexString:@"E91A1A"];
}

+ (UIColor *)zp_orangeColor
{
    return [UIColor colorWithHexString:@"FF8000"];
}

@end
