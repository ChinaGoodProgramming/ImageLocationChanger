//
//  MapLongpressAnnotation.m
//  TourWay
//
//  Created by WuTongAlvin on 1/11/16.
//  Copyright © 2016 OneThousandandOneNights. All rights reserved.
//

#import "MapLongpressAnnotation.h"

@implementation MapLongpressAnnotation

//主标题
- (NSString *)title {
    return _mainTitle;
}

//副标题
- (NSString *)subtitle {
    return _addressDetail;
}

//经纬度
- (CLLocationCoordinate2D)coordinate {
    return _addressCoordinate;
}


//拖拽必须实现的协议方法 ---- 坑呀！找了好久
- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate {
    _addressCoordinate = newCoordinate;
}

@end
