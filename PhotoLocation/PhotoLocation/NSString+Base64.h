//
//  NSString+Base64.h
//  TourWay
//
//  Created by luomeng on 16/3/11.
//  Copyright © 2016年 OneThousandandOneNights. All rights reserved.
//

#import <Foundation/NSString.h>

@interface NSString (Base64Additions)

+ (NSString *)base64StringFromData:(NSData *)data length:(int)length;

@end
