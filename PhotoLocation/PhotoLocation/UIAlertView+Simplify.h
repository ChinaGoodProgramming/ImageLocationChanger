//
//  UIAlertView+Simplify.h
//  WuTong
//
//  Created by 罗义德 on 15/6/23.
//  Copyright (c) 2015年 MacbookAir_liubo. All rights reserved.
//

#import <UIKit/UIKit.h>

//点击其他按钮回调
typedef void (^ConfirmBlock)(NSInteger index);
//点击取消按钮回调
typedef void (^CancelBlock)(void);

@interface UIAlertView (Simplify)<UIAlertViewDelegate>

/**
 展示alertView
 */
+ (UIAlertView *)showAlertView:(NSString *)message andConfirmTitle:(NSString *)confirm confirmHandle:(ConfirmBlock)confirmHandle andCancelTitle:(NSString *)cancel cancelHandle:(CancelBlock)cancelHandle;

@end
