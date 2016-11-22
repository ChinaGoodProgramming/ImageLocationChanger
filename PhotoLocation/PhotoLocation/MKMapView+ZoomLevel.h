//
//  MKMapView+ZoomLevel.h
//  TourWay
//
//  Created by WuTongAlvin on 11/13/15.
//  Copyright © 2015 OneThousandandOneNights. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface MKMapView (ZoomLevel)

- (void)setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate
                  zoomLevel:(NSUInteger)zoomLevel
                   animated:(BOOL)animated
                andDuration:(NSTimeInterval)duration;
- (double)getZoomLevel;

@end
