//
//  Define.h
//  JDD
//
//  Created by luomeng on 16/3/29.
//  Copyright © 2016年 CJ. All rights reserved.
//

#ifndef Define_h
#define Define_h

#import "WebDefine.h"
//#import "ThirdPartAccountDefine.h"


#ifndef NULL_REPLACE_BLOCK
#define NULL_REPLACE_BLOCK
#define NULL_REPLACE(_OBJ_) \
_OBJ_?_OBJ_:@""
#endif

#define COUNT_ONE_PAGE     20


#define NAVBAR_HEIGHT      44

#define DECLARE_SYNTHESIZE_SINGLETON_METHOD_FOR_CLASS(classname)\
+(classname*)shared##classname;\

#define IMPLEMENT_SYNTHESIZE_SINGLETON_METHOD_FOR_CLASS(classname) \
\
\
\
static classname* shared##classname=nil;                           \
+(classname*)shared##classname{                                    \
@synchronized(self)                                                \
{if(!shared##classname){                                           \
shared##classname=[[self alloc] init];}}                           \
return shared##classname;                                          \
}                                                                  \
+(id)allocWithZone:(NSZone*)zone{                                  \
@synchronized(self){                                               \
if(shared##classname==nil){                                        \
shared##classname = [super allocWithZone:zone];                    \
return shared##classname;}}                                        \
return nil;                                                        \
}                                                                  \
-(id)copyWithZone:(NSZone*)zone{                                   \
return self;                                                       \
}                                                                  \




#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)      //屏幕宽度
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)    //屏幕高度

#define SCREEN_4S ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) : NO)

#define SCREEN_5S ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)

#define SCREEN_6 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(750,1334), [[UIScreen mainScreen] currentMode].size) : NO)

#define SCREEN_6Plus ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242,2208), [[UIScreen mainScreen] currentMode].size) : NO)


//判断iphone6
#define iPhone6 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size) : NO)
//判断iphone6+
#define iPhone6Plus (IOS_8?([UIScreen mainScreen].nativeScale>2.60 ? YES : NO):NO)

#define SCALE_X ([UIScreen mainScreen].bounds.size.width)/320
#define SCALE_Y ([UIScreen mainScreen].bounds.size.height)/568

#define RBGCOLOR(r,g,b) [UIColor colorWithRed:0.400 green:0.523 blue:0.949 alpha:1.000]  //设置颜色

#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]

// rgb颜色转换（16进制-&gt;10进制）
#define HexColor(rgbValue) [UIColor colorWithRed:((float)((rgbValue &amp; 0xFF0000) &gt;&gt; 16))/255.0 green:((float)((rgbValue &amp; 0xFF00) &gt;&gt; 8))/255.0 blue:((float)(rgbValue &amp; 0xFF))/255.0 alpha:1.0]

#define DefaultBackGroundColor RGBACOLOR(240, 240, 240, 1)

#define IOS_8 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0f)

#define DocumentFolder [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]


#define USER_DEFAULT [NSUserDefaults standardUserDefaults]


#define COUNT_IN_PAGE

#define KEY_USER_ID              @"userID"
#define KEY_MOBILE               @"mobileNo"
#define TOKEN                    [[NSUserDefaults standardUserDefaults] objectForKey:KEY_USER_ID]



#define KEY_LATEST_MESSAGE_ID      @"latestMessageId"

#define CUSTOMER_PHONE             @"022-2329-6038"





#define MEDIA_BASE                      @"Media/"
#define IMAGE_DIR                       @"Images/"
#define AUDIO_DIR                       @"Audio/"
#define VIDEO_DIR                       @"Video/"
#define OTHER_DIR                       @"Other/"
#define DATA_DIR                        @"Data/"




#endif /* Define_h */







