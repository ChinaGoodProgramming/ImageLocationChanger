//
//  MapLongpressAnnotation.h
//  TourWay
//
//  Created by WuTongAlvin on 1/11/16.
//  Copyright © 2016 OneThousandandOneNights. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MapLongpressAnnotation : NSObject<MKAnnotation>

/**
 大标题
 */
@property(nonatomic, strong)NSString *mainTitle;

/**
 城市的详细地址
 */
@property(nonatomic, strong)NSString *addressDetail;

/**
 经纬度
 */
@property(nonatomic, assign)CLLocationCoordinate2D addressCoordinate;


@end
