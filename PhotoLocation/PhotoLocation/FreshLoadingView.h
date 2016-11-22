//
//  FreshLoadingView.h
//  TourWay
//
//  Created by luomeng on 16/8/15.
//  Copyright © 2016年 XRY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface FreshLoadingView : UIView
{

    NSTimer *_timer;
    int _currentIndex;
    UIImageView *_imageView;
}
@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UIView *bgview;

-(void)startAnimating;
-(void)stopAnimating;

@end
