//
//  AlertMessage.h
//  TourWay
//
//  Created by luomeng on 16/8/15.
//  Copyright © 2016年 XRY. All rights reserved.
//

// Abstract: An easy and clear way to "alert" a message
// highly improved the code structure and integrity
//
// Version: 0.9
// Made by X.Tan, Jul 2014.

//# Permission is hereby granted, free of charge, to any person obtaining a copy
//# of this software and associated documentation files (the "Software"), to
//# deal in the Software without restriction, including without limitation the
//# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//# sell copies of the Software, and to permit persons to whom the Software is
//# furnished to do so, subject to the following conditions:
//#
//# The above copyright notice and this permission notice shall be included in
//# all copies or substantial portions of the Software.
//#
//# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
//# ALERTMESSAGE BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN
//# AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNEC-
//# TION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import <UIKit/UIKit.h>


typedef void (^AlertMessageCompletionBlock)(void);
typedef enum {

    AlertMessageTypeAlert,
    AlertMessageTypeDecision,
    
} AlertMessageType;

@class AlertMessage;
@protocol AlertMessageDelegate <NSObject>

@optional
-(void)alertMessage:(AlertMessage *)alertMessage clickedButtonAtIndex:(NSInteger)buttonIndex;

@end

@interface AlertMessage : NSObject <UIAlertViewDelegate> {

    UIAlertView *_alertView;
    SEL _alertMessageConfirmCompleteSelector;
    AlertMessageCompletionBlock _alertMessageConfirmCompletionBlock;

    SEL _alertMessageCancelCompleteSelector;
    AlertMessageCompletionBlock _alertMessageCancelCompletionBlock;
    
    AlertMessageCompletionBlock _alertMessageContinueCompletionBlock;

    AlertMessageType _alertType;
    
    id<AlertMessageDelegate> _delegate;
    BOOL _autoCompletion;
}

@property (nonatomic, readonly)SEL alertMessageConfirmCompleteSelector;
@property (nonatomic, readonly)AlertMessageCompletionBlock alertMessageConfirmCompletionBlock;
@property (nonatomic, readonly)SEL alertMessageCancelCompleteSelector;
@property (nonatomic, readonly)AlertMessageCompletionBlock alertMessageCancelCompletionBlock;
@property (nonatomic, readonly)AlertMessageCompletionBlock alertMessageContinueCompletionBlock;
@property (nonatomic, readonly)AlertMessageType mode;
@property (nonatomic)int tag;

-(id)initWithTitle:(NSString *)title
              mode:(AlertMessageType)mode
           message:(NSString *)message
          delegate:(id)delegate
confirmCompleteSelector:(SEL)sel
cancelCompleteSelector:(SEL)sel2
 cancelButtonTitle:(NSString *)cancelButtonTitle
 otherButtonTitles:(NSString *)otherButtonTitles, ...;
-(id)initWithTitle:(NSString *)title
              mode:(AlertMessageType)mode
           message:(NSString *)message
          delegate:(id)delegate
 confirmCompletion:(void (^)(void))completion
  cancelCompletion:(void (^)(void))completion2
 cancelButtonTitle:(NSString *)cancelButtonTitle
 otherButtonTitles:(NSString *)otherButtonTitles, ...;
-(id)initWithTitle:(NSString *)title
              mode:(AlertMessageType)mode
           message:(NSString *)message
          delegate:(id)delegate
 confirmCompletion:(void (^)(void))completion
  cancelCompletion:(void (^)(void))completion2
continueCompletion:(void (^)(void))completion3
 cancelButtonTitle:(NSString *)cancelButtonTitle
 otherButtonTitle1:(NSString *)otherButtonTitle1
 otherButtonTitle2:(NSString *)otherButtonTitle2,...;
-(void)show;
-(void)showForSeconds:(float)sec;

@end












