//
//  Utilities.h
//  TourWay
//
//  Created by luomeng on 16/8/15.
//  Copyright © 2016年 XRY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>


@class CLLocationManager;
@interface Utilities : NSObject {
}

typedef enum {
    
    NETWORK_TYPE_NONE = 0,
    NETWORK_TYPE_2G = 1,
    NETWORK_TYPE_3G = 2,
    NETWORK_TYPE_4G = 3,
    NETWORK_TYPE_LTE = 4,//
    NETWORK_TYPE_WIFI = 5,
} NETWORK_TYPE;


//+(NSData *)getJSONDataFromDict:(NSDictionary *)dict;
//zxhadd
//+(NSDictionary*)getJSONDictFromData:(NSData*)data;
+(UIColor*)colorFromHexString:(NSString*)colorStr;
//zxhend
+(id)loadNibClass:(NSString *)name;
+(id)loadNib:(NSString *)nibName forClass:(NSString *)name;

+(BOOL)chopTheHeadToAss:(NSString *)filename offset:(NSNumber *)offset rename:(NSString *)newName offsetKey:(NSString *)offKey;
//+(BOOL)assToHead:(NSString *)filname rename:(NSString *)newName offsetKey:(NSString *)offKey;
+(BOOL)cutTheAssToHead:(NSString *)filename offset:(NSNumber *)offset rename:(NSString *)newName offsetKey:(NSString *)offKey;

//+(BOOL)headToAss:(NSString *)filname rename:(NSString *)newName offsetKey:(NSString *)offKey;

+(NSString *)getAppUserDocumentPath;
+(NSString *)getAppTempPath;
+(void)copyFileFromBoundleToAppDocDirIfNeeded:(NSString *)filename;
+(BOOL)existFileInAppUserSubPath:(NSString *)subPath;
+(BOOL)writeData:(NSData *)data toFile:(NSString *)filename;
+(NSString *)locateFilePath:(NSString *)filename;

+(NSArray *)randomlyGroupFrom:(NSArray *)sourceSet withMaxGroupSize:(NSInteger)groupSize;
+(NSArray *)groupFrom:(NSArray *)sourceSet withGroupSize:(NSInteger)groupSize;

+(NSData *) :(NSData *)sourceData;
+(NSData *)simpleDecryption__XOR_And_Indexed__From:(NSData *)sourceData;

+(NSString *)simpleDigitTransToLetter:(NSString *)sourceStr;
+(NSString *)simpleLetterToDigit:(NSString *)sourceStr;

+(BOOL)simpleEncryptFile:(NSString *)sourceFile toFile:(NSString *)targetFile keepSource:(BOOL)keepSource;
+(BOOL)simpleDecryptFile:(NSString *)sourceFile toFile:(NSString *)targetFile keepSource:(BOOL)keepSource;

+(NSString *)uniqueID;
+(NSString *)uniqueIDFromISA;
+(NSString *)uniqueIDFromMACAddr;
+(NSString *)MACAddr;

+(void)dessembleIPAddr:(NSString *)socketAddress toIp:(NSString **)ipStr port:(int *)outPort defaultPort:(int)dfPort;

+(UIImage *)scaleImage:(UIImage *)img toSize:(CGSize)size;
+(UIImage *)scaleImage:(UIImage *)img toRatio:(float)ratio;
+(UIImage *)aspectScaleImage:(UIImage *)img toWidth:(float)width;
+(UIImage *)aspectScaleImage:(UIImage *)img toHeight:(float)height;

+(NSString *)md5:(NSString *)str;

+(void)lineStyledButton:(UIButton *)btn lineWidth:(CGFloat)width;
+(void)lineStyledOffForButton:(UIButton *)btn;
+(void)horizontalLineFromView:(UIView *)view lineWidth:(CGFloat)width;
+(void)verticalLineFromView:(UIView *)view lineWidth:(CGFloat)width;

+(int)daysBetweenFirstDate:(NSDate *)date1 secondDate:(NSDate *)date2;

+(NSString *)standardTimeStringFrom:(NSInteger )newString;
+(NSString *)nowStringSSS;
+(NSString *)nowString;
+(NSString *)nowStringChs;
+(NSString *)timedUniqueName;
+(BOOL)writeImage:(UIImage *)image toPNGFile:(NSString *)filename;
+(void)writeImageToAlbumwithCGImage:(UIImage*)image metadata:(NSDictionary *)metadata;
+(UIImage *)getImageFromFile:(NSString *)filename;
+ (UIImage *)fixOrientation:(UIImage *)aImage;

+(NSAttributedString *)highlightString:(NSString *)str forKey:(NSArray *)keyStrs withColor:(UIColor *)color;
+(CGSize)sizeForString:(NSString *)text inFont:(UIFont *)font inWidth:(CGFloat)width;
+(NSString *)numericStringFrom:(NSString*)number;
+(NSString *)numberStringFrom:(NSString*)number;
+(NSString *)tenthousandsOfStringFromNumber:(NSNumber *)value;
+(NSString *)thousandsOfStringFromNumber:(NSNumber *)value;
+(NSString *)integerThousandsOfStringFromNumber:(NSNumber *)value;
+(NSString *)tailZeroTrunkedStringFrom:(NSString*)number;

+(unsigned long long)fileSizeForDir:(NSString*)path;
+(long long)fileSizeAtPath:(NSString *)filePath;
+(BOOL)enouthSpace:(float)fileSize;

+(BOOL)identifyDigitsOnlyString:(NSString *)str;
+(BOOL)identifyChinaMobilePhoneNumber:(NSString *)str;
+(BOOL)identifyChinaMobilePhoneNumberStrict:(NSString *)str;
+(BOOL)identifyFloatNumberString:(NSString *)str;
+(BOOL)identifyIntegerNumberString:(NSString *)str;
+(BOOL)identifyChinaLandLineNumber:(NSString *)str;
+(BOOL)identifyTencentQQNumber:(NSString *)str;
+(BOOL)identifyEmailString:(NSString *)str;
+(BOOL)identifyChinaZipCodeNumber:(NSString *)str;
+(BOOL)identifyChinaIdentifyCardNumber:(NSString *)str;

+(NSString *)platformString;
+(NSString *)internalDeviceInfo;

+(void)MakePhoneCallWithPhoneNumber:(NSString *)phone;

+(NETWORK_TYPE)networkTypeFromStatusBar;

+ (NSString *)disable_emoji:(NSString *)text;
+ (BOOL)isContainsEmoji:(NSString *)string;
/**
 生成二维码
 */
+ (UIImage *)filterQRImageWithInputText:(NSString *)text;
+ (NSString *)detectorTextFromQRImage:(UIImage *)image;

+ (NSString *)AES256EncryptWithContent:(NSString *)content withKey:(NSString *)key;
+ (NSString *)AES256DecryptWithContent:(NSString *)content withKey:(NSString *)key;

+ (NSString *)encrypt:(NSString *)message password:(NSString *)password;
+ (NSString *)decrypt:(NSString *)base64EncodedString password:(NSString *)password;


/*
 *
 获取当前APP版本和build号
 *
 */
+ (NSString *)getAppVersion;

+ (NSString *)JPGtimedVersionUniqueNameWithType:(NSString *)type;
+ (NSString *)saveJPGForData:(NSData *)data withType:(NSString *)type;

/*
 *
 弹起选择地图的actionsheet并跳转地图并导航
 *
 */
+ (UIAlertController *)actionSheetWithLocationFind:(CLLocationCoordinate2D)location;
/*
 *
 弹起选择地图的actionsheet并跳转地图做位置标记
 *
 */
+ (UIAlertController *)actionSheetWithLocation:(CLLocationCoordinate2D)location withAddress:(NSString *)address;

/*
 *
 将Base64加密后的json串转化为字典
 *
 */
+ (NSDictionary *)dictionoryFromBase64JsonString:(NSString *)string;
/*
 *
 将字典转化为Base64加密后的json串
 *
 */
+ (NSString *)bsae64JsonStringFromDictionory:(NSDictionary *)dictionory;

/*
 *
 将json串转化为字典
 *
 */
+ (NSDictionary *)dictionoryFromJsonString:(NSString *)string;
/*
 *
 将字典转化为json串
 *
 */
+ (NSString *)jsonStringFromDictionory:(NSDictionary *)dictionory;


+ (NSString *)getPriceStringWithprice:(float )price;


@end




























