//
//  NSData+Base64.h
//  TourWay
//
//  Created by luomeng on 16/3/11.
//  Copyright © 2016年 OneThousandandOneNights. All rights reserved.
//

#import <Foundation/NSString.h>
#import <UIKit/UIKit.h>

@class NSString;


@interface NSData (Base64Additions)

+ (NSData *)base64DataFromString:(NSString *)string;

@end
