//
//  UIColor+ColorTransfer.m
//  TourWay
//
//  Created by WuTongAlvin on 11/4/15.
//  Copyright © 2015 OneThousandandOneNights. All rights reserved.
//

#import "UIColor+ColorTransfer.h"

@implementation UIColor (ColorTransfer)

/**
 *可以将16进制色值转换成为RGB色值,直接返回给UIColer,例如[UIColor colorTransferToRGB:@"#ffffff"];
 */
+ (UIColor *)colorTransferToRGB:(NSString *)color{
    NSMutableString *colorString=[[NSMutableString alloc]initWithString:color];
    // 转换成标准16进制数
    [colorString replaceCharactersInRange:[colorString rangeOfString:@"#" ] withString:@"0x"];
    // 十六进制字符串转成整形。
    long colorLong = strtoul([colorString cStringUsingEncoding:NSUTF8StringEncoding], 0, 16);
    // 通过位与方法获取三色值
    int R = (colorLong & 0xFF0000 )>>16;
    int G = (colorLong & 0x00FF00 )>>8;
    int B = colorLong & 0x0000FF;

    //string转color
    UIColor *myColor = [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:1.0];
    return myColor;
}


@end
