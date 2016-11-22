//
//  CommonPage.h
//  JDD
//
//  Created by luomeng on 16/3/26.
//  Copyright © 2016年 CJ. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FreshLoadingView;
@interface CommonPage : UIViewController
{

    FreshLoadingView *_loadingView;
}


- (UIBarButtonItem *)createCustomizedItemWithSEL:(SEL)sel image:(NSString *)imgName;
- (UIBarButtonItem *)createCustomizedItemWithSEL:(SEL)sel image:(NSString *)imgName titleStr:(NSString *)title titleColor:(UIColor *)titleColor;
- (UIBarButtonItem *)createCustomizedItemWithSEL:(SEL)sel image:(NSString *)imgName highlightedImg:(NSString *)imgName2;
- (UIBarButtonItem *)createCustomizedItemWithSEL:(SEL)sel titleStr:(NSString*)title titleColor:(UIColor *)titleColor;
- (UIBarButtonItem *)createTopLeftBack;
- (UIBarButtonItem *)createTopLeftBack:(SEL)sel;
- (void)back;


- (void)alertMessage:(NSString *)message completion:(void(^)(void))completion;
- (void)alertMessage:(NSString *)message delayForAutoComplete:(float)delay completion:(void(^)(void))completion;
- (void)alertMessage:(NSString *)message completeSelector:(SEL)sel;
- (void)alertMessage:(NSString *)message delayForAutoComplete:(float)delay completeSelector:(SEL)sel;
- (void)decisionMessage:(NSString *)message confirmCompletion:(void(^)(void))completion cancelCompletion:(void(^)(void))completion2;
- (void)callPromptMessage:(NSString *)message confirmCompletion:(void(^)(void))completion cancelCompletion:(void(^)(void))completion2;
- (void)decisionMessage:(NSString *)message confirmCompletion:(void(^)(void))completion cancelCompletion:(void(^)(void))completion2 continueCompletion:(void(^)(void))completion3;
- (void)decisionMessage:(NSString *)message confirmTitle:(NSString *)title1 confirmCompletion:(void(^)(void))completion1 cancelTitle:(NSString *)title2 cancelCompletion:(void(^)(void))completion2 continueTitle:(NSString *)title3 continueCompletion:(void(^)(void))completion3;
- (void)decisionMessage:(NSString *)message confirmCompleteSelector:(SEL)sel cancelCompleteSelector:(SEL)sel2;


- (void)startLoading;
- (void)stopLoading;

@end







