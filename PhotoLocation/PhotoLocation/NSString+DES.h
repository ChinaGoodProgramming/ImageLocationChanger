//
//  NSString+DES.h
//  TourWay
//
//  Created by luomeng on 16/3/11.
//  Copyright © 2016年 OneThousandandOneNights. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (DES)

+ (NSString *)encryptWithText:(NSString *)sText;
+ (NSString *)decryptWithText:(NSString *)sText;
@end
