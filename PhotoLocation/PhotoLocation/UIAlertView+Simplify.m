//
//  UIAlertView+Simplify.m
//  WuTong
//
//  Created by 罗义德 on 15/6/23.
//  Copyright (c) 2015年 MacbookAir_liubo. All rights reserved.
//

#import "UIAlertView+Simplify.h"

static ConfirmBlock _confirmHandle = nil;
static CancelBlock _cancelHandle = nil;

@implementation UIAlertView (Simplify)

#pragma mark private method
#pragma 协议方法
+ (void)alertView:(UIAlertView*) alertView didDismissWithButtonIndex:(NSInteger) buttonIndex {
    
    if(buttonIndex == [alertView cancelButtonIndex]) {
        if (_cancelHandle) {
            _cancelHandle();
            _cancelHandle = nil;
        }
        
    } else {
        if (_confirmHandle) {
            _confirmHandle(buttonIndex - 1); // cancel button is button 0
            _confirmHandle = nil;
        }
        
    }
}

#pragma mark public method
/**
 展示alertView
 */
+ (UIAlertView *)showAlertView:(NSString *)message andConfirmTitle:(NSString *)confirm confirmHandle:(ConfirmBlock)confirmHandle andCancelTitle:(NSString *)cancel cancelHandle:(CancelBlock)cancelHandle {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:self cancelButtonTitle:cancel otherButtonTitles:confirm, nil];
    _confirmHandle = confirmHandle;
    _cancelHandle = cancelHandle;
    [alert show];
    return alert;
}

@end
