//
//  ImageViewController.m
//  PhotoLocation
//
//  Created by luomeng on 16/8/23.
//  Copyright © 2016年 XRY. All rights reserved.
//

#import "ImageViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "CLLocation+GPSDictionary.h"
#import "NSDictionary+CLLocation.h"
#import "SelectGeoViewController.h"
#import "CCLocationManager.h"

@interface ImageViewController ()
<
SelectGeoViewControllerDelegate
>
{

    __weak IBOutlet UIImageView *_imageView;
    __weak IBOutlet UILabel *_geoLabel;
    
    CLLocationCoordinate2D _coordinate;
    
    NSMutableDictionary *_imageMediaMetadata;
}


@end


@implementation ImageViewController (private)


- (IBAction)_selectGeo:(id)sender {
    
}
- (void)_save{
    [self startLoading];
    NSMutableDictionary *metadata = [NSMutableDictionary dictionaryWithDictionary:_imageMediaMetadata];
    
    NSDictionary * gpsDict = [[[CLLocation alloc] initWithLatitude:_coordinate.latitude longitude:_coordinate.longitude] GPSDictionary];
    
    if (metadata&& gpsDict) {
        [metadata setValue:gpsDict forKey:(NSString*)kCGImagePropertyGPSDictionary];
    }
    
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    ALAssetsLibraryWriteImageCompletionBlock imageWriteCompletionBlock =
    ^(NSURL *newURL, NSError *error) {
        [self stopLoading];
        if (error) {
            
            [self alertMessage:@"保存失败" delayForAutoComplete:1 completion:nil];
        } else {
            
            
            [self alertMessage:@"保存成功" delayForAutoComplete:1 completion:^{
                
                [super back];
            }];
        }
    };
    [library writeImageToSavedPhotosAlbum:[[self.sourceImage objectForKey:UIImagePickerControllerOriginalImage] CGImage]
                                 metadata:metadata
                          completionBlock:imageWriteCompletionBlock];
}
- (void)reverseGeoCode{
    
    CLGeocoder *clGeoCoder = [[CLGeocoder alloc] init];
    CLGeocodeCompletionHandler handle = ^(NSArray *placemarks,NSError *error){
        
        CLPlacemark *placeMark = placemarks.firstObject;
        NSDictionary *addressDic = placeMark.addressDictionary;
        NSString *name = [addressDic objectForKey:@"Name"];
        _geoLabel.text = [NSString stringWithFormat:@"%@(%f,%f)", name.length > 0 ? name : @"", _coordinate.latitude, _coordinate.longitude];
    };
    CLLocation *location = [[CLLocation alloc] initWithCoordinate:_coordinate altitude:CLLocationDistanceMax horizontalAccuracy:kCLLocationAccuracyNearestTenMeters verticalAccuracy:kCLLocationAccuracyNearestTenMeters timestamp:[NSDate date]];
    
    [clGeoCoder reverseGeocodeLocation:location completionHandler:handle];
}
- (void)createAlbum{

    ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
    NSMutableArray *groups = [NSMutableArray array];
    ALAssetsLibraryGroupsEnumerationResultsBlock listBlock = ^(ALAssetsGroup *group, BOOL *stop){
        
        
        
    };
}

@end

@implementation ImageViewController


#pragma mark -
#pragma mark - lifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _imageView.image = [Utilities fixOrientation:[self.sourceImage objectForKey:UIImagePickerControllerOriginalImage]];
    self.navigationItem.rightBarButtonItem = [self createCustomizedItemWithSEL:@selector(_save) titleStr:@"保存" titleColor:[UIColor whiteColor]];
    
    __block NSMutableDictionary *imageMetadata = nil;
    NSURL *assetURL = [self.sourceImage objectForKey:UIImagePickerControllerReferenceURL];
   
    
    if (assetURL) {
        //from album
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library assetForURL:assetURL
                 resultBlock:^(ALAsset *asset)  {
                     imageMetadata = [[NSMutableDictionary alloc] initWithDictionary:asset.defaultRepresentation.metadata];
                     _imageMediaMetadata = [NSMutableDictionary dictionaryWithDictionary:imageMetadata];
                     
                     //GPS数据
                     NSDictionary *GPSDict=[imageMetadata objectForKey:(NSString*)kCGImagePropertyGPSDictionary];
                     if (GPSDict!=nil) {
                        CLLocation *loc = [GPSDict locationFromGPSDictionary];
                         _geoLabel.text = [NSString stringWithFormat:@"%f,%f", loc.coordinate.latitude, loc.coordinate.longitude];
                         _coordinate = loc.coordinate;
                         [self reverseGeoCode];
                     }
                     else{
                         NSLog(@"此照片没有GPS信息");
                     }
                     
                     //EXIF数据
                     NSMutableDictionary *EXIFDictionary =[[imageMetadata objectForKey:(NSString *)kCGImagePropertyExifDictionary]mutableCopy];
                     NSString * dateTimeOriginal=[[EXIFDictionary objectForKey:(NSString*)kCGImagePropertyExifDateTimeOriginal] mutableCopy];
                     NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                     [dateFormatter setDateFormat:@"yyyy:MM:dd HH:mm:ss"];//yyyy-MM-dd HH:mm:ss
                 }
                failureBlock:^(NSError *error) {
                    
                    
                }];
    }
    else{
        //from camera
        _imageMediaMetadata = [NSMutableDictionary dictionaryWithDictionary:[self.sourceImage objectForKey:UIImagePickerControllerMediaMetadata]];
        [[CCLocationManager shareLocation] getLocationCoordinate:^(CLLocationCoordinate2D locationCorrrdinate) {
            
            _coordinate = locationCorrrdinate;
            _geoLabel.text = [NSString stringWithFormat:@"%f,%f", locationCorrrdinate.latitude, locationCorrrdinate.longitude];
            
            [self reverseGeoCode];
        }];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -
#pragma mark - SelectGeoViewControllerDelegate
- (void)SelectGeoViewControllerDidSelcetLocation:(CLLocationCoordinate2D)coordinate{

    _coordinate = coordinate;
    _geoLabel.text = [NSString stringWithFormat:@"%f,%f", _coordinate.latitude, _coordinate.longitude];
    [self reverseGeoCode];

}


#pragma mark -
#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"SelectGeoIdentify"]) {
        SelectGeoViewController *receive = segue.destinationViewController;
        receive.center = _coordinate;
        receive.navigationItem.title = @"位置详情";
        receive.delegate = self;
    }
}


@end







