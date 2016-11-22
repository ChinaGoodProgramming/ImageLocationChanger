//
//  CommonPage.m
//  JDD
//
//  Created by luomeng on 16/3/26.
//  Copyright © 2016年 CJ. All rights reserved.
//

#import "CommonPage.h"
#import "AlertMessage.h"
#import "FreshLoadingView.h"


#define STATUSBAR_HEIGHT                    20
#define NAVIGATIONBAR_HEIGHT                44
#define NAVIGATIONBAR_LABEL_WIDTH           160
#define NAVIGATIONBAR_BUTTON_HEIGHT         44
#define NAVIGATIONBAR_BUTTON_TEXT_WIDTH     24
#define NAVIGATIONBAR_BUTTON_FONT_SIZE      15
#define NAVIGATIONBAR_LEFT_BUTTON_TO_LEFT   1
#define NAVIGATIONBAR_RIGHT_BUTTON_TO_RIGHT 1
#define OTHERBUTTONTITTLES                  @"繼續",@"确定"

@interface CommonPage ()
<
UIAlertViewDelegate,
AlertMessageDelegate
>{
UIAlertView *_messageAlterView;
}

@end

@implementation CommonPage


#pragma mark -
#pragma mark - lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = NO;

    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.06 green:0.45 blue:0.50 alpha:1.00];
        self.navigationController.navigationBar.tintColor = [UIColor colorWithWhite:1 alpha:0.8];
    [UIColor colorWithRed:0.97 green:0.13 blue:0.33 alpha:1.00];
    [UIColor colorWithRed:0.23 green:0.54 blue:0.50 alpha:1.00];
    [UIColor colorWithWhite:1 alpha:0.8];
    self.view.backgroundColor = [UIColor colorWithRed:0.94 green:0.94 blue:0.94 alpha:1.00];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,nil]];
}
- (void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:YES];
    self.navigationController.navigationBarHidden = NO;

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -
#pragma mark - public
-(UIBarButtonItem *)createCustomizedItemWithSEL:(SEL)sel image:(NSString *)imgName{
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *img = [UIImage imageNamed:imgName];
    if (!img) {
        return nil;
    }
    float imgWidthHeightRatio = img.size.width / img.size.height;
    btn.frame = CGRectMake(0, 0, imgWidthHeightRatio * NAVIGATIONBAR_BUTTON_HEIGHT, NAVIGATIONBAR_BUTTON_HEIGHT);
    [btn setContentMode:UIViewContentModeScaleAspectFit];
    [btn addTarget:self action:sel forControlEvents:UIControlEventTouchUpInside];
    
    [btn setImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
    return [[UIBarButtonItem alloc] initWithCustomView:btn];
}
-(UIBarButtonItem *)createCustomizedItemWithSEL:(SEL)sel image:(NSString *)imgName titleStr:(NSString *)title titleColor:(UIColor *)titleColor{
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *img = [UIImage imageNamed:imgName];
    float imgWidthHeightRatio = img.size.width / img.size.height;
    btn.frame = CGRectMake(0, 0, imgWidthHeightRatio * NAVIGATIONBAR_BUTTON_HEIGHT, NAVIGATIONBAR_BUTTON_HEIGHT);
    [btn setContentMode:UIViewContentModeScaleAspectFit];
    [btn addTarget:self action:sel forControlEvents:UIControlEventTouchUpInside];
    
    [btn setTitle:title forState:UIControlStateNormal];
    //[btn.titleLabel setFont:[UIFont systemFontOfSize:NAVIGATIONBAR_BUTTON_FONT_SIZE]];
    [btn.titleLabel setFont:[UIFont boldSystemFontOfSize:NAVIGATIONBAR_BUTTON_FONT_SIZE]];
    [btn setTitleColor:titleColor forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
    return [[UIBarButtonItem alloc] initWithCustomView:btn];
}
-(UIBarButtonItem *)createCustomizedItemWithSEL:(SEL)sel image:(NSString *)imgName highlightedImg:(NSString *)imgName2{
    
    //iOS 7 style
    //    UIBarButtonItem *drawerHndl = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:imgName]
    //                                                                    style:UIBarButtonItemStyleDone
    //                                                                   target:self
    //                                                                   action:sel] autorelease];
    //    [drawerHndl setBackgroundImage:[UIImage imageNamed:imgName2]
    //                          forState:UIControlStateHighlighted
    //                        barMetrics:UIBarMetricsDefault];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *img = [UIImage imageNamed:imgName];
    float imgWidthHeightRatio = img.size.width / img.size.height;
    btn.frame = CGRectMake(0, 0, imgWidthHeightRatio * NAVIGATIONBAR_BUTTON_HEIGHT, NAVIGATIONBAR_BUTTON_HEIGHT);
    [btn setContentMode:UIViewContentModeScaleAspectFit];
    [btn addTarget:self action:sel forControlEvents:UIControlEventTouchUpInside];
    
    [btn setImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:imgName2] forState:UIControlStateHighlighted];
    
    return [[UIBarButtonItem alloc] initWithCustomView:btn];
}
-(UIBarButtonItem *)createCustomizedItemWithSEL:(SEL)sel titleStr:(NSString*)title titleColor:(UIColor *)titleColor{
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    float btnWidth = NAVIGATIONBAR_BUTTON_TEXT_WIDTH * title.length;
    btn.frame = CGRectMake(0, 0, btnWidth, NAVIGATIONBAR_BUTTON_HEIGHT);
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [btn setTitleColor:titleColor forState:UIControlStateNormal];
    [btn.titleLabel setFont:[UIFont systemFontOfSize:NAVIGATIONBAR_BUTTON_FONT_SIZE]];
    
    [btn addTarget:self action:sel forControlEvents:UIControlEventTouchUpInside];
    return [[UIBarButtonItem alloc] initWithCustomView:btn];
}
-(UIBarButtonItem *)createTopLeftBack{
    return [self createCustomizedItemWithSEL:@selector(back) image:@"common_return.png"];
}
-(UIBarButtonItem *)createTopLeftBack:(SEL)sel{
    return [self createCustomizedItemWithSEL:sel image:@"common_return.png"];
}

-(void)back{
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)alertMessage:(NSString *)message completion:(void (^)(void))completion{
    
    AlertMessage *_alertMessage = [[AlertMessage alloc]initWithTitle:@"温馨提示"
                                                                mode:AlertMessageTypeAlert
                                                             message:message
                                                            delegate:self
                                                   confirmCompletion:completion
                                                    cancelCompletion:nil
                                                   cancelButtonTitle:@"确定"
                                                   otherButtonTitles:nil];
    [_alertMessage show];
}
-(void)alertMessage:(NSString *)message delayForAutoComplete:(float)delay completion:(void(^)(void))completion{
    
    AlertMessage *_alertMessage = [[AlertMessage alloc]initWithTitle:@"温馨提示"
                                                                mode:AlertMessageTypeAlert
                                                             message:message
                                                            delegate:self
                                                   confirmCompletion:completion
                                                    cancelCompletion:nil
                                                   cancelButtonTitle:nil
                                                   otherButtonTitles:nil];
    [_alertMessage showForSeconds:delay];
}
-(void)alertMessage:(NSString *)message completeSelector:(SEL)sel{
    
    AlertMessage *_alertMessage = [[AlertMessage alloc]initWithTitle:@"温馨提示"
                                                                mode:AlertMessageTypeAlert
                                                             message:message
                                                            delegate:self
                                             confirmCompleteSelector:sel
                                              cancelCompleteSelector:NULL
                                                   cancelButtonTitle:@"确定"
                                                   otherButtonTitles:nil];
    [_alertMessage show];
}
-(void)alertMessage:(NSString *)message delayForAutoComplete:(float)delay completeSelector:(SEL)sel{
    
    AlertMessage *_alertMessage = [[AlertMessage alloc]initWithTitle:@"温馨提示"
                                                                mode:AlertMessageTypeAlert
                                                             message:message
                                                            delegate:self
                                             confirmCompleteSelector:sel
                                              cancelCompleteSelector:NULL
                                                   cancelButtonTitle:nil
                                                   otherButtonTitles:nil];
    [_alertMessage showForSeconds:delay];
}
-(void)decisionMessage:(NSString *)message confirmCompletion:(void(^)(void))completion cancelCompletion:(void(^)(void))completion2{
    
    AlertMessage *_alertMessage = [[AlertMessage alloc]initWithTitle:@"温馨提示"
                                                                mode:AlertMessageTypeDecision
                                                             message:message
                                                            delegate:self
                                                   confirmCompletion:completion
                                                    cancelCompletion:completion2
                                                   cancelButtonTitle:@"取消"
                                                   otherButtonTitles:@"确定", nil];
    [_alertMessage show];
}
-(void)callPromptMessage:(NSString *)message confirmCompletion:(void(^)(void))completion cancelCompletion:(void(^)(void))completion2{
    
    AlertMessage *_alertMessage = [[AlertMessage alloc]initWithTitle:message
                                                                mode:AlertMessageTypeDecision
                                                             message:@""
                                                            delegate:self
                                                   confirmCompletion:completion
                                                    cancelCompletion:completion2
                                                   cancelButtonTitle:@"取消"
                                                   otherButtonTitles:@"呼叫", nil];
    [_alertMessage show];
}

-(void)decisionMessage:(NSString *)message confirmCompletion:(void(^)(void))completion cancelCompletion:(void(^)(void))completion2 continueCompletion:(void(^)(void))completion3{
    AlertMessage *_alertMessage = [[AlertMessage alloc]initWithTitle:@"温馨提示"
                                                                mode:AlertMessageTypeDecision
                                                             message:message
                                                            delegate:self
                                                   confirmCompletion:completion
                                                    cancelCompletion:completion2
                                                  continueCompletion:completion3
                                                   cancelButtonTitle:@"取消"
                                                   otherButtonTitle1:@"继续"
                                                   otherButtonTitle2:@"保存", nil];
    [_alertMessage show];
}
-(void)decisionMessage:(NSString *)message confirmTitle:(NSString *)title1 confirmCompletion:(void(^)(void))completion1 cancelTitle:(NSString *)title2 cancelCompletion:(void(^)(void))completion2 continueTitle:(NSString *)title3 continueCompletion:(void(^)(void))completion3;{
    
    AlertMessage *_alertMessage = [[AlertMessage alloc] initWithTitle:@"温馨提示"
                                                                 mode:AlertMessageTypeDecision
                                                              message:message
                                                             delegate:self
                                                    confirmCompletion:completion1
                                                     cancelCompletion:completion2
                                                   continueCompletion:completion3
                                                    cancelButtonTitle:title2
                                                    otherButtonTitle1:title3
                                                    otherButtonTitle2:title1, nil];
    [_alertMessage show];
}
-(void)decisionMessage:(NSString *)message confirmCompleteSelector:(SEL)sel cancelCompleteSelector:(SEL)sel2{
    
    AlertMessage *_alertMessage = [[AlertMessage alloc]initWithTitle:@"温馨提示"
                                                                mode:AlertMessageTypeDecision
                                                             message:message
                                                            delegate:self
                                             confirmCompleteSelector:sel
                                              cancelCompleteSelector:sel2
                                                   cancelButtonTitle:@"取消"
                                                   otherButtonTitles:@"确定", nil];
    [_alertMessage show];
}


#pragma mark
#pragma mark - alertView
-(void)alertMessage:(AlertMessage *)alertMessage clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    //keep this here to response alertMessage block or selector action
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView==_messageAlterView) {
        _messageAlterView=nil;
        [alertView resignFirstResponder];
        [self.view becomeFirstResponder];
    }
}


-(void)startLoading{
    
    if (!_loadingView) {
        _loadingView = [[FreshLoadingView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    }
    _loadingView.userInteractionEnabled = NO;
//    _loadingView.center = self.view.center;
    [_loadingView startAnimating];
//    [[[[UIApplication sharedApplication] windows] lastObject] addSubview:_loadingView];
    [self.view addSubview:_loadingView];
    [self.view bringSubviewToFront:_loadingView];
//    self.view.userInteractionEnabled = NO;
}
-(void)stopLoading{
    
    [_loadingView stopAnimating];
    [_loadingView removeFromSuperview];
    _loadingView = nil;
//    self.view.userInteractionEnabled = YES;
}

@end






