//
//  SelectGeoViewController.h
//  PhotoLocation
//
//  Created by luomeng on 16/8/23.
//  Copyright © 2016年 XRY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonPage.h"

@protocol SelectGeoViewControllerDelegate <NSObject>

- (void)SelectGeoViewControllerDidSelcetLocation:(CLLocationCoordinate2D )coordinate;

@end

@interface SelectGeoViewController : CommonPage


@property(nonatomic, assign)CLLocationCoordinate2D center;

@property(nonatomic, assign)id<SelectGeoViewControllerDelegate>delegate;

@end
