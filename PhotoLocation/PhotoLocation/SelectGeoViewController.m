//
//  SelectGeoViewController.m
//  PhotoLocation
//
//  Created by luomeng on 16/8/23.
//  Copyright © 2016年 XRY. All rights reserved.
//

#import "SelectGeoViewController.h"
#import "MapLongpressAnnotation.h"

@interface SelectGeoViewController ()
<
MKMapViewDelegate
>
{
    __weak IBOutlet MKMapView *_mapView;
    MapLongpressAnnotation *_longPressAnnotation;

    CLLocationCoordinate2D _coordinate;
}

@end

@implementation SelectGeoViewController (private)


- (void)longPressAction:(UILongPressGestureRecognizer *)longGesture{
    
    if (longGesture.state == UIGestureRecognizerStateBegan) {//手势开始
        //获取长按坐标
        CGPoint center = [longGesture locationInView:_mapView];
        //添加大头针
        [self addAnnotationWithCenter:center];
    }else if (longGesture.state == UIGestureRecognizerStateEnded) {//手势结束
    }
}
- (void)addAnnotationWithCenter:(CGPoint)center{
    if (_longPressAnnotation) {
        //先删除其他大头针
        [_mapView removeAnnotation:_longPressAnnotation];
        //        _longPressAnnotation = nil;
    }else{
        //大头针模型:必须自定义
        _longPressAnnotation = [[MapLongpressAnnotation alloc] init];
    }
    
    //坐标转化
    CLLocationCoordinate2D coordinate = [_mapView convertPoint:center toCoordinateFromView:_mapView];
    
    //反地理编码
    _coordinate = coordinate;
    _longPressAnnotation.coordinate = coordinate;
    //添加大头针
    [_mapView addAnnotation:_longPressAnnotation];
}
- (void)_save{

    if ([self.delegate respondsToSelector:@selector(SelectGeoViewControllerDidSelcetLocation:)]) {
        [self.delegate SelectGeoViewControllerDidSelcetLocation:_coordinate];
    }
    [super back];
}

@end

@implementation SelectGeoViewController


#pragma mark -
#pragma mark - lifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
   self.navigationItem.rightBarButtonItem = [self createCustomizedItemWithSEL:@selector(_save) titleStr:@"保存" titleColor:[UIColor whiteColor]];
    MKCoordinateSpan theSpan;
    theSpan.latitudeDelta = 0.01;
    theSpan.longitudeDelta = 0.01;
    MKCoordinateRegion theRegion;
    if (self.center.latitude == 0 && self.center.longitude == 0) {
        
//        33.1459297345, 109.4333866253
        self.center = CLLocationCoordinate2DMake(40.038558333333334,116.31698666666666);
        _coordinate = self.center;
        
    }
    theRegion.center = self.center;
    theRegion.span = theSpan;
    [_mapView setRegion:theRegion];
    
    
    if (_longPressAnnotation) {
        [_mapView removeAnnotation:_longPressAnnotation];
        _longPressAnnotation = nil;
    }else{
        //大头针模型:必须自定义
        _longPressAnnotation = [[MapLongpressAnnotation alloc] init];
    }
    _longPressAnnotation.coordinate = _coordinate;
    //添加大头针
    [_mapView addAnnotation:_longPressAnnotation];
    
    UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
    [_mapView addGestureRecognizer:longGesture];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
