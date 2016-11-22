//
//  FreshLoadingView.m
//  TourWay
//
//  Created by luomeng on 16/8/15.
//  Copyright © 2016年 XRY. All rights reserved.
//

#import "FreshLoadingView.h"

@implementation FreshLoadingView

- (instancetype)initWithFrame:(CGRect)frame{

    if (self = [super initWithFrame:frame]) {
       
        self.frame = frame;
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        view.backgroundColor = [UIColor blackColor];
        view.alpha = 0.3;
        _backView=view;
        [self addSubview:view];
        
        UIView *bg = [[UIView alloc] initWithFrame:CGRectMake((self.frame.size.width - 80) / 2.0, (self.frame.size.height - 80) / 2.0, 80, 80)];
        bg.clipsToBounds = YES;
        bg.layer.cornerRadius = 10;
        bg.backgroundColor = [UIColor whiteColor];
        _bgview=bg;
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake((bg.frame.size.width - 79) / 2.0, (bg.frame.size.height - 79) / 2.0, 79, 79)];
        _imageView.image = [UIImage imageNamed:@"1.png"];
        _currentIndex = 1;
        [bg addSubview:_imageView];
        
        [self addSubview:bg];
    }
    return self;
}

-(void)startAnimating{
    
    if (!_timer) {
        _timer = [NSTimer timerWithTimeInterval:2.0 / 53.0 target:self selector:@selector(change) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
    if ([self superview]) {
        
        self.center = self.superview.center;
    }
    
}
-(void)stopAnimating{
    
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    if ([self superview]) {
        [self removeFromSuperview];
    }
}

- (void)change{
    
    _imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%d", _currentIndex]];
    _currentIndex = _currentIndex + 1;
    if (_currentIndex > 52) {
        _currentIndex = 1;
    }
}


@end










