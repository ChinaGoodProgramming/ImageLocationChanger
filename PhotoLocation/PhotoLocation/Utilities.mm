//
//  Utilities.m
//  TourWay
//
//  Created by luomeng on 16/8/15.
//  Copyright © 2016年 XRY. All rights reserved.
//

#import "Utilities.h"
//#import "JSON.h"
#include <sys/sysctl.h>
#import "sys/utsname.h"

// About Custom UDID for IOS5
#include <stdio.h>
#include <arpa/inet.h>
#include <net/if.h>
#include <net/if_dl.h>
#include <arpa/inet.h>
#include <ifaddrs.h>
#import <CommonCrypto/CommonDigest.h>
//#import <AdSupport/ASIdentifierManager.h>
//#import "UIImage+FixOrientation.h"
//#import "Define.h"
#import <CommonCrypto/CommonCrypto.h>
#import "NSData+Base64.h"
#import "NSString+Base64.h"
#import "NSData+CommonCrypto.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>

#define kDevKey @"12345" //Custom KEY
#define MAXDATECOUNT 99999999
#define UTIL_UIDKEY @"MTF_UID_KEY"

//#ifndef DEBUG_RUN
//#define DEBUG_RUN
//#endif
//#define DEBUG_ENCRYPT

@implementation Utilities

/*
+(NSData *)getJSONDataFromDict:(NSDictionary *)dict{
	NSData *result = nil;
	NSString *JSONString = nil;
	JSONString = [dict JSONRepresentation];
	//If json string is nil, append "{}" as empty parameter
	if (!JSONString) {
		JSONString = @"";
	} else {
		JSONString=[NSString stringWithFormat:@"%@",JSONString];
	}
    NSLog(@"Send JSONString:%@",JSONString);
	result = [JSONString dataUsingEncoding:NSUTF8StringEncoding];
	return result;
}
+(NSDictionary*)getJSONDictFromData:(NSData*)data{
    NSDictionary* result;
    NSString* JSONString;
    JSONString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"Receive JSONString:%@",JSONString);
    if (!JSONString) {
        result = nil;
    }else{
        result = [JSONString JSONValue];
    }
    [JSONString release];
    return result;
}
*/
+(UIColor*)colorFromHexString:(NSString*)colorStr{
    UIColor* result;
    if ([colorStr length] != 6) {//rrggbb
        return nil;
    }
    unsigned int r,g,b;
    [[NSScanner scannerWithString:[colorStr substringWithRange:NSMakeRange(0, 2)]] scanHexInt:&r];
    [[NSScanner scannerWithString:[colorStr substringWithRange:NSMakeRange(2, 2)]] scanHexInt:&g];
    [[NSScanner scannerWithString:[colorStr substringWithRange:NSMakeRange(4, 2)]] scanHexInt:&b];
    result = [UIColor colorWithRed:r/255. green:g/255. blue:b/255. alpha:1.];
    return result;
}

+(id)loadNibClass:(NSString *)name{
	NSArray *objSet = [[NSBundle mainBundle] loadNibNamed:name owner:self options:nil];
    
	id targetClass = NSClassFromString(name);
	id result = nil;
	for (id object in objSet) {
		if ([object isKindOfClass:targetClass]){
			result = object;
			break;
		}
	}
	return result;
}
+(id)loadNib:(NSString *)nibName forClass:(NSString *)name{
	NSArray *objSet = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil];
    
	id targetClass = NSClassFromString(name);
	id result = nil;
	for (id object in objSet) {
		if ([object isKindOfClass:targetClass]){
			result = object;
			break;
		}
	}
	return result;
}

+(BOOL)chopTheHeadToAss:(NSString *)filename offset:(NSNumber *)offset rename:(NSString *)newName offsetKey:(NSString *)offKey{
    
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if (![fileManager fileExistsAtPath:filename]) {
		return NO;
	}
	NSError *error;
	if ([fileManager fileExistsAtPath:newName]) {
		if (![fileManager removeItemAtPath:newName error:&error]){
#ifdef DEBUG_RUN
			NSLog(@"+++++ failed to remove existing target file %@ with error message%@", newName, [error localizedDescription]);
#endif
		}
		return NO;
	}
	if (![fileManager moveItemAtPath:filename toPath:newName error:&error]) {
#ifdef DEBUG_RUN
		NSLog(@"+++++ failed to move %@ to %@ with error message%@", filename, newName, [error localizedDescription]);
#endif
		return NO;
	}
	
	NSFileHandle *f_hdle = [NSFileHandle fileHandleForUpdatingAtPath:newName];
	[f_hdle seekToFileOffset:0];
	NSData *headData = [f_hdle readDataOfLength:[offset intValue]];
	NSData *bodyData = [f_hdle readDataToEndOfFile];
	[f_hdle seekToFileOffset:0];
	[f_hdle writeData:bodyData];
	[f_hdle writeData:headData];
	[f_hdle closeFile];
	
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	
	NSString *offsetStr = [Utilities simpleDigitTransToLetter:[offset stringValue]];
	NSData *offsetData = [Utilities simpleEncryption__Indexed_And_XOR__From:[offsetStr dataUsingEncoding:NSUTF8StringEncoding]];
	
	[prefs setObject:offsetData forKey:offKey];
	[prefs synchronize];
	
	return YES;
}
/*
+(BOOL)assToHead:(NSString *)filname rename:(NSString *)newName offsetKey:(NSString *)offKey{
	
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	NSData *offData = [prefs objectForKey:offKey];
	
	if (!offData) {
#ifdef DEBUG_RUN
		NSLog(@"+++++ no offset key found");
#endif
		return NO;
	}
    
	NSString *offsetStr = [[[NSString alloc] initWithData:[Utilities simpleDecryption__XOR_And_Indexed__From:offData] encoding:NSUTF8StringEncoding] autorelease];
	long long int offset = [[Utilities simpleLetterToDigit:offsetStr] intValue];
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if (![fileManager fileExistsAtPath:filname]) {
		return NO;
	}
	NSError *error;
	if ([fileManager fileExistsAtPath:newName]) {
		if (![fileManager removeItemAtPath:newName error:&error]){
#ifdef DEBUG_RUN
			NSLog(@"+++++ failed to remove existing target file %@ with error message %@", newName, [error localizedDescription]);
#endif
		}
		return NO;
	}
	if (![fileManager moveItemAtPath:filname toPath:newName error:&error]) {
#ifdef DEBUG_RUN
		NSLog(@"+++++ failed to move %@ to %@ with error message %@", filname, newName, [error localizedDescription]);
#endif
		return NO;
	}
	
	NSFileHandle *f_hdle = [NSFileHandle fileHandleForUpdatingAtPath:newName];
	[f_hdle seekToEndOfFile];
	unsigned int assPoint = [f_hdle offsetInFile] - offset;
	[f_hdle seekToFileOffset:0];
	NSData *bodyData = [f_hdle readDataOfLength:assPoint];
	NSData *tailData = [f_hdle readDataToEndOfFile];
	
	[f_hdle seekToFileOffset:0];
	[f_hdle writeData:tailData];
	[f_hdle writeData:bodyData];
	[f_hdle closeFile];
	
	return YES;
}
 */
+(BOOL)cutTheAssToHead:(NSString *)filename offset:(NSNumber *)offset rename:(NSString *)newName offsetKey:(NSString *)offKey{
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if (![fileManager fileExistsAtPath:filename]) {
		return NO;
	}
	NSError *error;
	if ([fileManager fileExistsAtPath:newName]) {
		if (![fileManager removeItemAtPath:newName error:&error]){
#ifdef DEBUG_RUN
			NSLog(@"+++++ failed to remove existing target file %@ with error message %@", newName, [error localizedDescription]);
#endif
		}
		return NO;
	}
	if (![fileManager moveItemAtPath:filename toPath:newName error:&error]) {
#ifdef DEBUG_RUN
		NSLog(@"+++++ failed to move %@ to %@ with error message %@", filename, newName, [error localizedDescription]);
#endif
		return NO;
	}
	
	NSFileHandle *f_hdle = [NSFileHandle fileHandleForUpdatingAtPath:newName];
	[f_hdle seekToEndOfFile];
	unsigned long assPoint = [f_hdle offsetInFile] - [offset intValue];
	[f_hdle seekToFileOffset:0];
	NSData *bodyData = [f_hdle readDataOfLength:assPoint];
	NSData *tailData = [f_hdle readDataToEndOfFile];
	
	[f_hdle seekToFileOffset:0];
	[f_hdle writeData:tailData];
	[f_hdle writeData:bodyData];
	[f_hdle closeFile];
	
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
	NSString *offsetStr = [Utilities simpleDigitTransToLetter:[offset stringValue]];
	NSData *offsetData = [Utilities simpleEncryption__Indexed_And_XOR__From:[offsetStr dataUsingEncoding:NSUTF8StringEncoding]];
	
	[prefs setObject:offsetData forKey:offKey];
	[prefs synchronize];
	
	return YES;
}
/*
+(BOOL)headToAss:(NSString *)filname rename:(NSString *)newName offsetKey:(NSString *)offKey{
	
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	NSData *offData = [prefs objectForKey:offKey];
	
	if (!offData) {
#ifdef DEBUG_RUN
		NSLog(@"+++++ no offset key found");
#endif
		return NO;
	}
	
	NSString *offsetStr = [[[NSString alloc] initWithData:[Utilities simpleDecryption__XOR_And_Indexed__From:offData] encoding:NSUTF8StringEncoding] autorelease];
	long long int offset = [[Utilities simpleLetterToDigit:offsetStr] intValue];
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if (![fileManager fileExistsAtPath:filname]) {
		return NO;
	}
	NSError *error;
	if ([fileManager fileExistsAtPath:newName]) {
		if (![fileManager removeItemAtPath:newName error:&error]){
#ifdef DEBUG_RUN
			NSLog(@"+++++ failed to remove existing target file %@ with error message %@", newName, [error localizedDescription]);
#endif
		}
		return NO;
	}
	if (![fileManager moveItemAtPath:filname toPath:newName error:&error]) {
#ifdef DEBUG_RUN
		NSLog(@"+++++ failed to move %@ to %@ with error message %@", filname, newName, [error localizedDescription]);
#endif
		return NO;
	}
	
	NSFileHandle *f_hdle = [NSFileHandle fileHandleForUpdatingAtPath:newName];
	[f_hdle seekToFileOffset:0];
	NSData *headData = [f_hdle readDataOfLength:offset];
	NSData *bodyData = [f_hdle readDataToEndOfFile];
	[f_hdle seekToFileOffset:0];
	[f_hdle writeData:bodyData];
	[f_hdle writeData:headData];
	[f_hdle closeFile];
	
	return YES;
}
*/
+(NSString *)getAppUserDocumentPath{
    
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDir = [paths objectAtIndex:0];
    //    NSHomeDirectory();
	return documentsDir;
}
+(NSString *)getAppTempPath{
    
	//set appDir/tmp as the temporary target
	NSString *dPath = [self getAppUserDocumentPath];
	NSMutableArray *dPAr = [NSMutableArray arrayWithArray:[dPath pathComponents]];
	[dPAr removeLastObject];
	[dPAr addObject:@"tmp"];
	NSString *aPath = [NSString pathWithComponents:dPAr];
	return aPath;
}

+(void)copyFileFromBoundleToAppDocDirIfNeeded:(NSString *)filename{
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSError *error;
	NSString *localPath = [self locateFilePath:filename];
	BOOL success = [fileManager fileExistsAtPath:localPath];
	if(!success) {
		NSString *defaultPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:filename];
		success = [fileManager copyItemAtPath:defaultPath toPath:localPath error:&error];
		if (!success){
			NSAssert1(0, @"Failed to create file with message '%@'.", [error localizedDescription]);
		}
	}
}
+(BOOL)existFileInAppUserSubPath:(NSString *)subName{
    
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString *appDocPath = [self getAppUserDocumentPath];
	return [fileManager fileExistsAtPath:[NSString stringWithFormat:@"%@/%@", appDocPath, subName]];
}
+(BOOL)writeData:(NSData *)data toFile:(NSString *)filename{
    
	NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL result = NO;

    result = [fileManager createFileAtPath:filename contents:data attributes:nil];
	return result;
}
+(NSString *)locateFilePath:(NSString *)filename{
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDir = [paths objectAtIndex:0];
	return [documentsDir stringByAppendingPathComponent:filename];
}

+(NSArray *)randomlyGroupFrom:(NSArray *)sourceSet withMaxGroupSize:(NSInteger)groupSize{
	
	//{1, 2, 3, 4, 5, ...} ---> {1, 2}, {3}, {4, 5}, ...
	//protection
	if (!sourceSet) {
		return nil;
	}
	//sourceSet should be nsNumber array;
	if ([sourceSet count] && ![[sourceSet objectAtIndex:0] isKindOfClass:[NSNumber class]]){
		return nil;
	}
	//processing
	long count = [sourceSet count];
	int counted = 0;
	NSMutableArray *result = [NSMutableArray array];
	
	while (count - counted >= groupSize) {
		int group_s = rand()%groupSize + 1;
		NSMutableArray *gp_set = [NSMutableArray array];
		for (int i = 0; i < group_s; i ++) {
			[gp_set addObject:[sourceSet objectAtIndex:counted]];
			counted ++;
		}
		[result addObject:gp_set];
	}
	if (counted < count){
		NSMutableArray *last_gp_set = [NSMutableArray array];
		for (int i = 0; i < count - counted; i ++) {
			[last_gp_set addObject:[sourceSet objectAtIndex:counted]];
			counted ++;
		}
		[result addObject:last_gp_set];
	}
	return [[result retain] autorelease];
}
+(NSArray *)groupFrom:(NSArray *)sourceSet withGroupSize:(NSInteger)groupSize{
	
	//{1, 2, 3, 4, 5, ...} ---> {1, 2}, {3}, {4, 5}, ...
	//protection
	if (!sourceSet) {
		return nil;
	}
	//sourceSet should be nsNumber array;
	if ([sourceSet count] && ![[sourceSet objectAtIndex:0] isKindOfClass:[NSNumber class]]){
		return nil;
	}
	//processing
	long count = [sourceSet count];
	int counted = 0;
	NSMutableArray *result = [NSMutableArray array];
	
	while (count - counted >= groupSize) {
        
		NSMutableArray *gp_set = [NSMutableArray array];
		for (int i = 0; i < groupSize; i ++) {
			[gp_set addObject:[sourceSet objectAtIndex:counted]];
			counted ++;
		}
		[result addObject:gp_set];
	}
	if (counted < count){
		NSMutableArray *last_gp_set = [NSMutableArray array];
		for (int i = 0; i < count - counted; i ++) {
			[last_gp_set addObject:[sourceSet objectAtIndex:counted]];
			counted ++;
		}
		[result addObject:last_gp_set];
	}
	return [[result retain] autorelease];
}

+(NSData *)simpleEncryption__Indexed_And_XOR__From:(NSData *)sourceData{
    
	const uint8_t *     dataBuffer;
	NSUInteger          dataLength;
	NSData *            result = nil;
	
	//expand all bytes
	dataLength = [sourceData length];
	
	if (dataLength) {
		
		dataBuffer = (const uint8_t *)[sourceData bytes];
		uint8_t *resultBuffer = new uint8_t[dataLength];
		
#ifdef DEBUG_ENCRYPT
		NSLog(@"+++++ encoding source data %@", [sourceData description]);
#endif
		//across all bytes, excute add and xor
		uint8_t lastByte = *dataBuffer; //beginning one
		resultBuffer[0] = lastByte;
		for (int i = 1; i < dataLength; i ++) {
			
			uint8_t byte = *(dataBuffer+i);
			uint8_t a_byte = byte + i;
			uint8_t b_byte = a_byte ^ lastByte;
			resultBuffer[i] = b_byte;
			lastByte = byte;
		}
		result = [NSData dataWithBytes:resultBuffer length:dataLength];
		delete[] resultBuffer;
	}
	
	//return copy of autorelease
#ifdef DEBUG_ENCRYPT
	NSLog(@"+++++ target data %@", [result description]);
#endif
    
	return result;
}
+(NSData *)simpleDecryption__XOR_And_Indexed__From:(NSData *)sourceData{
	
	const uint8_t *     dataBuffer;
	NSUInteger          dataLength;
	NSData *            result = nil;
	
	//expand all bytes
	dataLength = [sourceData length];
	
	if (dataLength) {
		
		dataBuffer = (const uint8_t *)[sourceData bytes];
		uint8_t *resultBuffer = new uint8_t[dataLength];
		
#ifdef DEBUG_ENCRYPT
		NSLog(@"+++++ decoding source data %@", [sourceData description]);
#endif
		//across all bytes, excute add and xor
		uint8_t lastByte = *dataBuffer; //beginning one
		resultBuffer[0] = lastByte;
		for (int i = 1; i < dataLength; i ++) {
            
			uint8_t byte = *(dataBuffer+i);
			uint8_t b_byte = byte ^ lastByte;
			uint8_t a_byte = b_byte - i;
            
			resultBuffer[i] = a_byte;
			lastByte = a_byte;
		}
		result = [NSData dataWithBytes:resultBuffer length:dataLength];
		delete[] resultBuffer;
	}
	
	//return copy of autorelease
#ifdef DEBUG_ENCRYPT
	NSLog(@"+++++ target data %@", [result description]);
#endif
    
	return result;
}
+(NSString *)simpleDigitTransToLetter:(NSString *)sourceStr{
    
	NSString * result = nil;
	
	if ([sourceStr length]) {
		result = [sourceStr stringByReplacingOccurrencesOfString:@"0" withString:@"o"];
		result = [result stringByReplacingOccurrencesOfString:@"1" withString:@"i"];
		result = [result stringByReplacingOccurrencesOfString:@"2" withString:@"z"];
		result = [result stringByReplacingOccurrencesOfString:@"3" withString:@"E"];
		result = [result stringByReplacingOccurrencesOfString:@"4" withString:@"h"];
		result = [result stringByReplacingOccurrencesOfString:@"5" withString:@"s"];
		result = [result stringByReplacingOccurrencesOfString:@"6" withString:@"g"];
		result = [result stringByReplacingOccurrencesOfString:@"7" withString:@"L"];
		result = [result stringByReplacingOccurrencesOfString:@"8" withString:@"B"];
		result = [result stringByReplacingOccurrencesOfString:@"9" withString:@"b"];
	}
	
	return result;
}
+(NSString *)simpleLetterToDigit:(NSString *)sourceStr{
	
	NSString * result = nil;
	
	if ([sourceStr length]) {
		result = [sourceStr stringByReplacingOccurrencesOfString:@"o" withString:@"0"];
		result = [result stringByReplacingOccurrencesOfString:@"i" withString:@"1"];
		result = [result stringByReplacingOccurrencesOfString:@"z" withString:@"2"];
		result = [result stringByReplacingOccurrencesOfString:@"E" withString:@"3"];
		result = [result stringByReplacingOccurrencesOfString:@"h" withString:@"4"];
		result = [result stringByReplacingOccurrencesOfString:@"s" withString:@"5"];
		result = [result stringByReplacingOccurrencesOfString:@"g" withString:@"6"];
		result = [result stringByReplacingOccurrencesOfString:@"L" withString:@"7"];
		result = [result stringByReplacingOccurrencesOfString:@"B" withString:@"8"];
		result = [result stringByReplacingOccurrencesOfString:@"b" withString:@"9"];
	}
	
	return result;
}

+(BOOL)simpleEncryptFile:(NSString *)sourceFile toFile:(NSString *)targetFile keepSource:(BOOL)keepSource{
    
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if (![fileManager fileExistsAtPath:sourceFile]) {
		return NO;
	}
    NSError *error;
    if ([fileManager fileExistsAtPath:targetFile]) {
        [fileManager removeItemAtPath:targetFile error:&error];
#ifdef DEBUG_RUN
		NSLog(@"+++++ target file to move existed %@, removed with error message %@", targetFile, [error localizedDescription]);
#endif
        //		return NO;
	}
    //	NSError *error;
    
//    if (keepSource) {
//
//        if (![fileManager copyItemAtPath:sourceFile toPath:targetFile error:&error]) {
//#ifdef DEBUG_RUN
//            NSLog(@"+++++ failed to copy %@ to %@ in simpleEncryptFile with error message %@", sourceFile, targetFile, [error localizedDescription]);
//#endif
//            return NO;
//        }
//    }
//    else {
//
//        if (![fileManager moveItemAtPath:sourceFile toPath:targetFile error:&error]) {
//#ifdef DEBUG_RUN
//            NSLog(@"+++++ failed to move %@ to %@ in simpleEncryptFile with error message %@", sourceFile, targetFile, [error localizedDescription]);
//#endif
//            return NO;
//        }
//    }
    
    if (![fileManager copyItemAtPath:sourceFile toPath:targetFile error:&error]) {
#ifdef DEBUG_RUN
        NSLog(@"+++++ failed to copy %@ to %@ in simpleEncryptFile with error message %@", sourceFile, targetFile, [error localizedDescription]);
#endif
        return NO;
    }
    if (!keepSource) {
        [fileManager removeItemAtPath:sourceFile error:&error];
#ifdef DEBUG_RUN
        NSLog(@"+++++ source file %@, removed with error message %@", targetFile, [error localizedDescription]);
#endif
    }
    
    BOOL result = NO;
	NSFileHandle *f_hdle = [NSFileHandle fileHandleForUpdatingAtPath:targetFile];
	[f_hdle seekToFileOffset:0];
	NSData *sourceData = [f_hdle readDataToEndOfFile];
    NSData *targetData = [Utilities simpleEncryption__Indexed_And_XOR__From:sourceData];
    if (targetData.length == sourceData.length) {

        [f_hdle seekToFileOffset:0];
        [f_hdle writeData:targetData];
        result = YES;
    }
	[f_hdle closeFile];
	
	return result;
}
+(BOOL)simpleDecryptFile:(NSString *)sourceFile toFile:(NSString *)targetFile keepSource:(BOOL)keepSource{
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if (![fileManager fileExistsAtPath:sourceFile]) {
		return NO;
	}
    NSError *error;
	if ([fileManager fileExistsAtPath:targetFile]) {
        [fileManager removeItemAtPath:targetFile error:&error];
#ifdef DEBUG_RUN
		NSLog(@"+++++ target file to move existed %@, removed with error message %@", targetFile, [error localizedDescription]);
#endif
        //		return NO;
	}
    //	NSError *error;
//    if (keepSource) {
//
//        if (![fileManager copyItemAtPath:sourceFile toPath:targetFile error:&error]) {
//#ifdef DEBUG_RUN
//            NSLog(@"+++++ failed to copy %@ to %@ with error message %@", sourceFile, targetFile, [error localizedDescription]);
//#endif
//            return NO;
//        }
//    }
//    else {
//
//        if (![fileManager moveItemAtPath:sourceFile toPath:targetFile error:&error]) {
//#ifdef DEBUG_RUN
//            NSLog(@"+++++ failed to move %@ to %@ with error message %@", sourceFile, targetFile, [error localizedDescription]);
//#endif
//            return NO;
//        }
//    }
    
    if (![fileManager copyItemAtPath:sourceFile toPath:targetFile error:&error]) {
#ifdef DEBUG_RUN
        NSLog(@"+++++ failed to copy %@ to %@ in simpleEncryptFile with error message %@", sourceFile, targetFile, [error localizedDescription]);
#endif
        return NO;
    }
    if (!keepSource) {
        [fileManager removeItemAtPath:sourceFile error:&error];
#ifdef DEBUG_RUN
        NSLog(@"+++++ source file %@, removed with error message %@", targetFile, [error localizedDescription]);
#endif
    }
	
    BOOL result = NO;
	NSFileHandle *f_hdle = [NSFileHandle fileHandleForUpdatingAtPath:targetFile];
	[f_hdle seekToFileOffset:0];
	NSData *sourceData = [f_hdle readDataToEndOfFile];
    NSData *targetData = [Utilities simpleDecryption__XOR_And_Indexed__From:sourceData];
    if (targetData.length == sourceData.length) {
        
        [f_hdle seekToFileOffset:0];
        [f_hdle writeData:targetData];
        result = YES;
    }
	[f_hdle closeFile];
	
	return result;
}

+(NSString *)uniqueID{
    
	float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (version >= 7.0) {
        return [Utilities uniqueIDFromISA];
    }
    else {
        return [Utilities uniqueIDFromMACAddr];
    }
}
+(NSString *)uniqueIDFromISA{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *resultStr = [defaults objectForKey:UTIL_UIDKEY];
    if (!resultStr) {
        
        NSString *devKey = kDevKey;
        //    NSString *MACAddr = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
        NSString *MACAddr = [[NSUUID UUID] UUIDString];
        
        const char  *cstart = [[NSString stringWithFormat:@"%C%C%@%@%C%C",
                                [MACAddr characterAtIndex:6],
                                [MACAddr characterAtIndex:7],
                                devKey,
                                MACAddr,
                                [MACAddr characterAtIndex:3],
                                [MACAddr characterAtIndex:4]] UTF8String];
        
        unsigned char result[CC_SHA1_DIGEST_LENGTH];
        CC_SHA1(cstart,strlen(cstart),result);
        
        NSMutableString *hash = [NSMutableString string];
        
        int i;
        for (i=0; i < 20; i++) {
            [hash appendFormat:@"%02x",result[i]];
        }
        
        resultStr = [hash lowercaseString];
        [defaults setObject:resultStr forKey:UTIL_UIDKEY];
    }
    return resultStr;
}
+(NSString *)uniqueIDFromMACAddr{
    
    NSString *devKey = kDevKey;
    NSString *MACAddr = [Utilities MACAddr];
    
    const char  *cstart = [[NSString stringWithFormat:@"%C%C%@%@%C%C",
                            [MACAddr characterAtIndex:6],
                            [MACAddr characterAtIndex:7],
                            devKey,
                            MACAddr,
                            [MACAddr characterAtIndex:3],
                            [MACAddr characterAtIndex:4]] UTF8String];
    
    
    
    unsigned char result[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(cstart,strlen(cstart),result);
    
    NSMutableString *hash = [NSMutableString string];
    
    int i;
    for (i=0; i < 20; i++) {
        [hash appendFormat:@"%02x",result[i]];
    }
    
    return [hash lowercaseString];
}
+(NSString *)MACAddr{
    struct ifaddrs *interfaces;
    const struct ifaddrs *tmpaddr;
    
    if (getifaddrs(&interfaces)==0)
	{
        tmpaddr = interfaces;
        
        while (tmpaddr != NULL)
		{
            if (strcmp(tmpaddr->ifa_name,"en0")==0)
			{
                struct sockaddr_dl *dl_addr = ((struct sockaddr_dl *)tmpaddr->ifa_addr);
                uint8_t *base = (uint8_t *)&dl_addr->sdl_data[dl_addr->sdl_nlen];
                
                NSMutableString *s = [NSMutableString string];
                int l = dl_addr->sdl_alen;
                int i;
                
                for (i=0; i < l; i++)
				{
                    [s appendFormat:(i!=0)?@":%02x":@"%02x",base[i]];
				}
                
                return s;
			}
            
            tmpaddr = tmpaddr->ifa_next;
		}
        
        freeifaddrs(interfaces);
	}
    return @"00:00:00:00:00:00";
}

+(void)dessembleIPAddr:(NSString *)socketAddress toIp:(NSString **)ipStr port:(int *)outPort defaultPort:(int)dfPort{
    
    NSRange colon = [socketAddress rangeOfString:@":"];
    NSString* order;
    int port;
    if (colon.location == NSNotFound) {
        order = socketAddress;
        port = dfPort;
    }
    else{
        order = [socketAddress substringToIndex:colon.location];
        port = [[socketAddress substringFromIndex:colon.location+1] intValue];
    }
    *ipStr = order;
    *outPort = port;
}

+(UIImage *)scaleImage:(UIImage *)img toSize:(CGSize)size{
    UIGraphicsBeginImageContext(size);
    [img drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}
+(UIImage *)scaleImage:(UIImage *)img toRatio:(float)ratio{
    
    float w = img.size.width * ratio;
    float h = img.size.height * ratio;
    CGSize size = CGSizeMake(w, h);
    UIGraphicsBeginImageContext(size);
    [img drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}
+(UIImage *)aspectScaleImage:(UIImage *)img toWidth:(float)width{

    float ratio = width / img.size.width;
    float h = img.size.height * ratio;
    CGSize size = CGSizeMake(width, h);
    UIGraphicsBeginImageContext(size);
    [img drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}
+(UIImage *)aspectScaleImage:(UIImage *)img toHeight:(float)height{

    float ratio = height / img.size.height;
    float w = img.size.width * ratio;
    CGSize size = CGSizeMake(w, height);
    UIGraphicsBeginImageContext(size);
    [img drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}


+(NSString *)md5:(NSString *)str{
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, strlen(cStr), result); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

+(void)lineStyledButton:(UIButton *)btn lineWidth:(CGFloat)width{
    
    UIColor *tColor = btn.currentTitleColor;
    [btn.layer setBorderWidth:width];
    [btn.layer setBorderColor:[tColor CGColor]];
}
+(void)lineStyledOffForButton:(UIButton *)btn{
    
    [btn.layer setBorderColor:[[UIColor clearColor] CGColor]];
}
+(void)horizontalLineFromView:(UIView *)view lineWidth:(CGFloat)width{
    
    view.frame = CGRectMake(view.frame.origin.x,
                            view.frame.origin.y,
                            view.frame.size.width,
                            width);
}
+(void)verticalLineFromView:(UIView *)view lineWidth:(CGFloat)width{
    
    view.frame = CGRectMake(view.frame.origin.x,
                            view.frame.origin.y,
                            width,
                            view.frame.size.width);
}

+(int)daysBetweenFirstDate:(NSDate *)date1 secondDate:(NSDate *)date2{
    
    NSTimeInterval interval = [date2 timeIntervalSinceDate:date1];
    return (int)(interval / 86400);
}


+(NSString *)standardTimeStringFrom:(NSInteger )newString{
    NSString *str, *str1, *str2, *str3;
    long hours = newString / 3600;
    long minutes = (newString % 3600) / 60;
    long seconds = newString - 3600 * hours - 60 *minutes;
    if (seconds < 10) {
        str1 = [NSString stringWithFormat:@"0%ld",seconds];
    }
    else{
        str1 = [NSString stringWithFormat:@"%ld",seconds];
    }
    if (minutes < 10) {
        str2 = [NSString stringWithFormat:@"0%ld",minutes];
    }
    else{
        str2 = [NSString stringWithFormat:@"%ld",minutes];
    }
    
    if (hours < 10) {
        str3 = [NSString stringWithFormat:@"0%ld",hours];
    }
    else{
        str3 = [NSString stringWithFormat:@"%ld",hours];
    }
    str = [NSString stringWithFormat:@"%@:%@:%@",str3,str2,str1];
    return str;
}
+(NSString *)nowString{
    
    NSDateFormatter * formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *str = [formatter stringFromDate:[NSDate date]];
    [formatter release];
    return str;
}
+(NSString *)nowStringSSS{
    
    NSDateFormatter * formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyyMMddHHmmssSSS"];
    NSString *str = [formatter stringFromDate:[NSDate date]];
    [formatter release];
    return str;
}
+(NSString *)nowStringChs{
    
    NSDateFormatter * formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy年 MM月 dd日 HH:mm:ss"];
    NSString *str = [formatter stringFromDate:[NSDate date]];
    [formatter release];
    return str;
}
+(NSString *)timedUniqueName{
    
    NSString *result = nil;
    NSDateFormatter * formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd-HH-mm-ss"];
    NSString *nowStr = [formatter stringFromDate:[NSDate date]];
    [formatter setDateFormat:@"SSS"];
    NSString *milSecStr = [formatter stringFromDate:[NSDate date]];
    [formatter release];
    result = [NSString stringWithFormat:@"%@-%@", nowStr, [self md5:milSecStr]];
    
    return result;
}
+(BOOL)writeImage:(UIImage *)image toPNGFile:(NSString *)filename{
    
    NSData *data = UIImagePNGRepresentation([self fixOrientation:image]);
	NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([Utilities enouthSpace:[[fileManager attributesOfItemAtPath:filename error:nil] fileSize]]) {
        if ([fileManager fileExistsAtPath:filename]) {
            [fileManager removeItemAtPath:filename error:nil];
        }
        BOOL result = [fileManager createFileAtPath:filename contents:data attributes:nil];
        return result;
    }
    else{
        UIAlertView *alert = [[[UIAlertView alloc]initWithTitle:@"警告" message:@"设备内存不足，媒体储存失败！" delegate:nil cancelButtonTitle:@"返回" otherButtonTitles: nil]autorelease];
        [alert show];
        return NO;
    }
	
}
+(UIImage *)getImageFromFile:(NSString *)filename{
    
    UIImage *result = nil;
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if ([fileManager fileExistsAtPath:filename]) {
        result = [UIImage imageWithContentsOfFile:filename];
    }
    return result;
}
+ (void)writeImageToAlbumwithCGImage:(UIImage*)image metadata:(NSDictionary *)metadata{
    
//    if ([[[UIDevice currentDevice] systemVersion] floatValue] > 8.0) {
//        
//        PHPhotoLibrary *library = [[PHPhotoLibrary alloc] init];
//    
//        
//    }
//    else{
    
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        ALAssetsLibraryWriteImageCompletionBlock imageWriteCompletionBlock =
        ^(NSURL *newURL, NSError *error) {
            if (error) {
                NSLog( @"Error writing image with metadata to Photo Library: %@", error );
            } else {
                
                
                NSLog( @"Wrote image with metadata to Photo Library");
            }
        };
        
        //保存相片到相册 注意:必须使用[image CGImage]不能使用强制转换: (__bridge CGImageRef)image,否则保存照片将会报错
        [library writeImageToSavedPhotosAlbum:[image CGImage]
                                     metadata:metadata
                              completionBlock:imageWriteCompletionBlock];
//    }
}


+(NSAttributedString *)highlightString:(NSString *)str forKey:(NSArray *)keyStrs withColor:(UIColor *)color{
    
    NSMutableAttributedString *result = [[[NSMutableAttributedString alloc] initWithString:str] autorelease];
    for (NSString *s in keyStrs) {
        NSRange range = [str rangeOfString:s options:NSCaseInsensitiveSearch];
        [result setAttributes:[NSDictionary dictionaryWithObject:color forKey:NSForegroundColorAttributeName] range:range];
    }
    return result;
}
+(CGSize)sizeForString:(NSString *)text inFont:(UIFont *)font inWidth:(CGFloat)width{
    
    //    CGSize sizeToFit = [text sizeWithFont:font
    //                        constrainedToSize:CGSizeMake(width, CGFLOAT_MAX)
    //                            lineBreakMode:NSLineBreakByWordWrapping];
    CGRect rectToFit = [text boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                          options:NSStringDrawingUsesLineFragmentOrigin
                                       attributes:[NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil]
                                          context:nil];
    return rectToFit.size;
}
+(NSString *)numericStringFrom:(NSString*)number{
    
    NSString *num = @"";
    NSCharacterSet *sting = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    for (int i = 0; i < number.length; i ++) {
        
        NSString *string = [number substringWithRange:NSMakeRange(i, 1)];
        NSRange range = [string rangeOfCharacterFromSet:sting];
        if (range.length) {
            
            num = [num stringByAppendingString:string];
        }
    }
    return num;
}
+(NSString *)numberStringFrom:(NSString*)number{
    
    NSString *num = @"";
    NSCharacterSet *sting = [NSCharacterSet characterSetWithCharactersInString:@"0123456789."];
    for (int i = 0; i < number.length; i ++) {
        
        NSString *string = [number substringWithRange:NSMakeRange(i, 1)];
        NSRange range = [string rangeOfCharacterFromSet:sting];
        if (range.length) {
            
            num = [num stringByAppendingString:string];
        }
    }
    return num;
}
+(NSString *)tenthousandsOfStringFromNumber:(NSNumber *)value{
    
    
    if (value.longLongValue / 10000 == 0) {
        
        return @"小于1万";
    }
    else{
        NSString *tenthousandStr = [self thousandsOfStringFromNumber:[NSNumber numberWithDouble:value.doubleValue / 10000]];
        return [NSString stringWithFormat:@"%@ 万", [tenthousandStr substringToIndex:tenthousandStr.length - 3]];
    }
}
+(NSString *)integerThousandsOfStringFromNumber:(NSNumber *)value{
    
    NSString *integerStr = [self thousandsOfStringFromNumber:value];
    return [integerStr substringToIndex:integerStr.length - 3];
}
+(NSString *)thousandsOfStringFromNumber:(NSNumber *)value{
    
    double orignialVal = [value doubleValue];
    NSString *originalStr = [NSString stringWithFormat:@"%.2f", orignialVal];
    NSString *floatPartStr = [originalStr substringWithRange:NSMakeRange(originalStr.length - 3, 3)];
    
    NSString *result = floatPartStr;
    NSString *integerPartStr = [originalStr substringToIndex:originalStr.length - 3];
    
    int lastPiece = integerPartStr.length % 3;
    NSInteger slice = integerPartStr.length / 3 + (lastPiece == 0 ? 0 : 1);
    
    for (int i = 1; i <= slice; i ++) {
        
        NSInteger rangeLoc = integerPartStr.length - i * 3;
        NSString *sliceDigStr = nil;
        if (rangeLoc < 0) {
            
            if (integerPartStr.length >= 3) {
                
                sliceDigStr = [integerPartStr substringWithRange:NSMakeRange(0, 3)];
            }
            else{
                
                sliceDigStr = integerPartStr;
            }

        }
        else{
            
            sliceDigStr = [integerPartStr substringWithRange:NSMakeRange(integerPartStr.length - i * 3, 3)];
        }
        if (i == 1) {
            result = [NSString stringWithFormat:@"%@%@", sliceDigStr, result];
        }
        else if (i == slice && lastPiece != 0) {
            NSString *lastPieceDigStr = [integerPartStr substringWithRange:NSMakeRange(0, lastPiece)];
            result = [NSString stringWithFormat:@"%@,%@", lastPieceDigStr, result];
        }
        else {
            result = [NSString stringWithFormat:@"%@,%@", sliceDigStr, result];
        }
    }
    return result;
}
+(NSString *)tailZeroTrunkedStringFrom:(NSString*)number{
    
    NSRange rangOfDot = [number rangeOfString:@"."];
    if (rangOfDot.location != NSNotFound) {
        
        if (rangOfDot.location > 0 && rangOfDot.location < number.length) {
            
            for (long i = number.length - 1; i > rangOfDot.location; i --) {
                
                if (![[number substringWithRange:NSMakeRange(i, 1)] isEqualToString:@"0"]) {
                    
                    return [number substringToIndex:i + 1];
                }
            }
            return [number substringToIndex:rangOfDot.location];
        }
    }
    return number;
}
+(unsigned long long)fileSizeForDir:(NSString*)path{
    
    long long size = 0;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray* array = [fileManager contentsOfDirectoryAtPath:path error:nil];
    
    for (NSString *subPath in array) {
        
        NSString *fullPath = [path stringByAppendingPathComponent:subPath];
        BOOL isDir;
        if ([fileManager fileExistsAtPath:fullPath isDirectory:&isDir]) {
            if (isDir) {
                size += ([self fileSizeForDir:fullPath]);
            }
            else {
                NSDictionary *fileAttributeDic = [fileManager attributesOfItemAtPath:fullPath error:nil];
                size += (fileAttributeDic.fileSize);
            }
        }
    }
    return size;
}
+(long long)fileSizeAtPath:(NSString *)filePath{
    
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}
+(BOOL)enouthSpace:(float)fileSize{
    
    float totalSpace = 0.0;
    float totalFreeSpace = 0.0;
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
    
    if (dictionary) {
        NSNumber *fileSystemSizeInBytes = [dictionary objectForKey: NSFileSystemSize];
        NSNumber *freeFileSystemSizeInBytes = [dictionary objectForKey:NSFileSystemFreeSize];
        totalSpace = [fileSystemSizeInBytes floatValue];
        totalFreeSpace = [freeFileSystemSizeInBytes floatValue];
//        NSLog(@"Memory Capacity of %f GB with %f GB Free memory available.", ((totalSpace/1024.0f)/1024.0f/1024.0f), ((totalFreeSpace/1024.0f)/1024.0f)/1024.0f);
    }
    else {
        NSLog(@"Error Obtaining System Memory"); //Info: Domain = %@, Code = %@", [error domain], [error code]);
    }
    
    if (fileSize < totalFreeSpace * 0.9) {
        return YES;
    }
    return NO;
}


+(BOOL)identifyDigitsOnlyString:(NSString *)str{
    
    NSString * regex = @"^[0-9]{1,}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [pred evaluateWithObject:str];
}
+(BOOL)identifyChinaMobilePhoneNumber:(NSString *)str{
    
    NSString * regex = @"^[0-9]{7,15}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [pred evaluateWithObject:str];
}
+(BOOL)identifyChinaMobilePhoneNumberStrict:(NSString *)str{
    
    NSString * regex = @"^(\\+861|00861|861|1)[2,3,4,5,7,8,9]{1}[0-9]{9}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [pred evaluateWithObject:str];
}
+(BOOL)identifyFloatNumberString:(NSString *)str{
    
    NSString * rege = @"^[1-9]\\d*\\.\\d*|[1-9]\\d*|0\\.\\d*[1-9]\\d*$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", rege];
    return [pred evaluateWithObject:str];

}
+(BOOL)identifyIntegerNumberString:(NSString *)str{
    
    NSString * regex = @"^[1-9]{1}\\d*$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [pred evaluateWithObject:str];
}
+(BOOL)identifyChinaLandLineNumber:(NSString *)str{
    
    //    NSString * regex = @"^0[1-9]{1}[0-9]{9}$";
    NSString * regex = @"^(\\+860|00860|860|0)[1-9]{1}[0-9]{1,2}[1-9]{1}[0-9]{6,7}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [pred evaluateWithObject:str];
}
+(BOOL)identifyTencentQQNumber:(NSString *)str{
    
    NSString * regex = @"^[1-9]{1}[0-9]{4,9}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [pred evaluateWithObject:str];
}
+(BOOL)identifyEmailString:(NSString *)str{
    
    NSString * regex = @"^[A-Za-z0-9_.-]{1,}@{1}[A-Za-z0-9_.-]{1,}.{1}[A-Za-z.]{1,}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [pred evaluateWithObject:str];
}
+(BOOL)identifyChinaZipCodeNumber:(NSString *)str{
    
    NSString * regex = @"^[1-9]{1}[0-9]{5}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [pred evaluateWithObject:str];
}
+(BOOL)identifyChinaIdentifyCardNumber:(NSString *)str{
    
    NSString * regex = @"^[1-9]{1}[1-9*]{1}[0-9]{15}[0-9X]{1}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [pred evaluateWithObject:str];
}

+(NSString *)platformString{

    // Gets a string with the device model
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
//    char *machine = malloc(size);
    char *machine = new char[size];
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
//    free(machine);
    delete [] machine;
    if ([platform isEqualToString:@"iPhone1,1"])    return @"iPhone 2G";
    if ([platform isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,2"])    return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,3"])    return @"iPhone 4 (CDMA)";
    if ([platform isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([platform isEqualToString:@"iPhone5,1"])    return @"iPhone 5";
    if ([platform isEqualToString:@"iPhone5,2"])    return @"iPhone 5 (GSM+CDMA)";

    if ([platform isEqualToString:@"iPhone5,3"])    return @"iPhone 5C (CDMA)";
    if ([platform isEqualToString:@"iPhone5,4"])    return @"iPhone 5C";
    if ([platform isEqualToString:@"iPhone6,1"])    return @"iPhone 5S (CDMA)";
    if ([platform isEqualToString:@"iPhone6,2"])    return @"iPhone 5S";

    if ([platform isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([platform isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    
    
    if ([platform isEqualToString:@"iPod1,1"])      return @"iPod Touch (1 Gen)";
    if ([platform isEqualToString:@"iPod2,1"])      return @"iPod Touch (2 Gen)";
    if ([platform isEqualToString:@"iPod3,1"])      return @"iPod Touch (3 Gen)";
    if ([platform isEqualToString:@"iPod4,1"])      return @"iPod Touch (4 Gen)";
    if ([platform isEqualToString:@"iPod5,1"])      return @"iPod Touch (5 Gen)";
    
    if ([platform isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([platform isEqualToString:@"iPad1,2"])      return @"iPad 3G";
    if ([platform isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,2"])      return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([platform isEqualToString:@"iPad2,4"])      return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,5"])      return @"iPad Mini (WiFi)";
    if ([platform isEqualToString:@"iPad2,6"])      return @"iPad Mini";
    if ([platform isEqualToString:@"iPad2,7"])      return @"iPad Mini (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
    if ([platform isEqualToString:@"iPad3,2"])      return @"iPad 3 (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad3,3"])      return @"iPad 3";
    if ([platform isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    if ([platform isEqualToString:@"iPad3,5"])      return @"iPad 4";
    if ([platform isEqualToString:@"iPad3,6"])      return @"iPad 4 (GSM+CDMA)";
    
    if ([platform isEqualToString:@"i386"])         return @"Simulator";
    if ([platform isEqualToString:@"x86_64"])       return @"Simulator";
    return platform;
}
+(NSString *)internalDeviceInfo{

    //here use sys/utsname.h
    struct utsname systemInfo;
    uname(&systemInfo);
    //get the device model and the system version
    return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
}

+(void)MakePhoneCallWithPhoneNumber:(NSString *)phone{

  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",phone]]];
}
/*
+(void)MakePhoneCallWithPhoneNumber:(NSString *)phone withRecorderID:(NSString *)recorderId withRecorderType:(MF_RecorderType)type{
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",phone]]];
}
*/
//Make sure that the Status bar is not hidden in your application. if it's not visible it will always return No wifi or cellular because your code reads the text in the Status bar thats all.
+(NETWORK_TYPE)networkTypeFromStatusBar{
    
    UIApplication *app = [UIApplication sharedApplication];
    [app setStatusBarHidden:NO];
    NSArray *subviews = [[[app valueForKey:@"statusBar"] valueForKey:@"foregroundView"] subviews];
    NSNumber *dataNetworkItemView = nil;
    
    for (id subview in subviews) {
        
        if([subview isKindOfClass:[NSClassFromString(@"UIStatusBarDataNetworkItemView") class]])     {
            
            dataNetworkItemView = subview;
            
            break;
        }
    }
    
    NETWORK_TYPE nettype = NETWORK_TYPE_NONE;
    NSNumber * num = [dataNetworkItemView valueForKey:@"dataNetworkType"];
    nettype = (NETWORK_TYPE)[num integerValue];
    
    NSString *resultStr = nil;
    switch (nettype) {
        case NETWORK_TYPE_NONE:
            resultStr = @"None";
            break;
        case NETWORK_TYPE_2G:
            resultStr = @"2G";
            break;
        case NETWORK_TYPE_3G:
            resultStr = @"3G";
            break;
        case NETWORK_TYPE_4G:
            resultStr = @"4G";
            break;
        case NETWORK_TYPE_LTE:
            resultStr = @"LTE";
            break;
        case NETWORK_TYPE_WIFI:
            resultStr = @"WiFi";
            break;
    }

    return nettype;
}

+ (UIImage *)fixOrientation:(UIImage *)aImage {
    
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

+ (NSString *)disable_emoji:(NSString *)text{
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[^\\u0020-\\u007E\\u00A0-\\u00BE\\u2E80-\\uA4CF\\uF900-\\uFAFF\\uFE30-\\uFE4F\\uFF00-\\uFFEF\\u0080-\\u009F\\u2000-\\u201f\r\n]" options:NSRegularExpressionCaseInsensitive error:nil];
    NSString *modifiedString = [regex stringByReplacingMatchesInString:text
                                                               options:0
                                                                 range:NSMakeRange(0, [text length])
                                                          withTemplate:@""];
    return modifiedString;
}

+ (BOOL)isContainsEmoji:(NSString *)string {
    __block BOOL isEomji = NO;
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:
     ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
         const unichar hs = [substring characterAtIndex:0];
         if (0xd800 <= hs && hs <= 0xdbff) {
             if (substring.length > 1) {
                 const unichar ls = [substring characterAtIndex:1];
                 const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                 if (0x1d000 <= uc && uc <= 0x1f77f) {
                     isEomji = YES;
                 }
             }
         } else if (substring.length > 1) {
             const unichar ls = [substring characterAtIndex:1];
             if (ls == 0x20e3) {
                 isEomji = YES;
             }
         } else {
             if (0x2100 <= hs && hs <= 0x27ff && hs != 0x263b) {
                 isEomji = YES;
             } else if (0x2B05 <= hs && hs <= 0x2b07) {
                 isEomji = YES;
             } else if (0x2934 <= hs && hs <= 0x2935) {
                 isEomji = YES;
             } else if (0x3297 <= hs && hs <= 0x3299) {
                 isEomji = YES;
             } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50|| hs == 0x231a ) {
                 isEomji = YES;
             }
         }
     }];
    return isEomji;
}


+ (UIImage *)filterQRImageWithInputText:(NSString *)text{
    
    //二维码滤镜
    
    CIFilter *filter=[CIFilter filterWithName:@"CIQRCodeGenerator"];
    
    //恢复滤镜的默认属性
    
    [filter setDefaults];
    
    //将字符串转换成NSData
    
    NSData *data=[text dataUsingEncoding:NSUTF8StringEncoding];
    
    //通过KVO设置滤镜inputmessage数据
    
    [filter setValue:data forKey:@"inputMessage"];
    
    //获得滤镜输出的图像
    
    CIImage *outputImage=[filter outputImage];
    
    //将CIImage转换成UIImage,并放大显示
    
    UIImage  *image=[self createNonInterpolatedUIImageFormCIImage:outputImage withSize:400.0];
    return image;
}
//改变二维码大小
+ (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat) size{
    
    CGRect extent = CGRectIntegral(image.extent);
    
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    
    // 创建bitmap;
    
    size_t width = CGRectGetWidth(extent) * scale;
    
    size_t height = CGRectGetHeight(extent) * scale;
    
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    
    CIContext *context = [CIContext contextWithOptions:nil];
    
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    
    CGContextScaleCTM(bitmapRef, scale, scale);
    
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    
    // 保存bitmap到图片
    
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    
    CGContextRelease(bitmapRef);
    
    CGImageRelease(bitmapImage);
    
    return [UIImage imageWithCGImage:scaledImage];
    
}
+ (NSString *)detectorTextFromQRImage:(UIImage *)image{

    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeText context:nil options:@{ CIDetectorAccuracy:CIDetectorAccuracyHigh }];
    CIImage *ciimage = [[CIImage alloc] initWithImage:image];
    NSArray *features = [detector featuresInImage:ciimage];
//    NSArray *features = [detector featuresInImage:ciimage options:<#(nullable NSDictionary<NSString *,id> *)#>];

    for (CIQRCodeFeature *feature in features) {
        NSLog(@"%@", feature.messageString);
    }
    CIQRCodeFeature *feature = features.firstObject;
    return feature.messageString;
}

+ (NSString *)AES256EncryptWithContent:(NSString *)content withKey:(NSString *)key{

    char keyPtr[kCCKeySizeAES256+1];
    bzero(keyPtr, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    NSUInteger dataLength = [content length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          keyPtr, kCCBlockSizeAES128,
                                          NULL,
                                          [[content dataUsingEncoding:NSUTF8StringEncoding] bytes], dataLength,
                                          buffer, bufferSize,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        NSData *data = [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    free(buffer);
    return nil;
}
+ (NSString *)AES256DecryptWithContent:(NSString *)content withKey:(NSString *)key{

    char keyPtr[kCCKeySizeAES256+1];
    bzero(keyPtr, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    NSUInteger dataLength = [content length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          keyPtr, kCCBlockSizeAES128,
                                          NULL,
                                          [[content dataUsingEncoding:NSUTF8StringEncoding] bytes], dataLength,
                                          buffer, bufferSize,
                                          &numBytesDecrypted);
    if (cryptStatus == kCCSuccess) {
        NSData *data = [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    free(buffer);
    return nil;
}


+ (NSString *)encrypt:(NSString *)message password:(NSString *)password {
    NSData *encryptedData = [[message dataUsingEncoding:NSUTF8StringEncoding] AES256EncryptedDataUsingKey:[[password dataUsingEncoding:NSUTF8StringEncoding] SHA256Hash] error:nil];
    NSString *base64EncodedString = [NSString base64StringFromData:encryptedData length:[encryptedData length]];
    return base64EncodedString;
}

+ (NSString *)decrypt:(NSString *)base64EncodedString password:(NSString *)password {
    NSData *encryptedData = [NSData base64DataFromString:base64EncodedString];
    NSData *decryptedData = [encryptedData decryptedAES256DataUsingKey:[[password dataUsingEncoding:NSUTF8StringEncoding] SHA256Hash] error:nil];
    return [[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding];
}



+ (NSString *)getAppVersion{

    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSString *app_build = [infoDictionary objectForKey:@"CFBundleVersion"];
    return [NSString stringWithFormat:@"%@.%@", app_Version, app_build];
}

+ (NSString *)JPGtimedVersionUniqueNameWithType:(NSString *)type{

    NSString *app_Version = [Utilities getAppVersion];
    
    NSString *photoName = [NSString stringWithFormat:@"iOS%@-%@-%@.jpg", app_Version, type, [Utilities timedUniqueName]];
    NSString *docPath = [Utilities getAppUserDocumentPath];
    
    NSString *dir =  [NSString stringWithFormat:@"%@/%@%@", docPath, MEDIA_BASE, IMAGE_DIR];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager isExecutableFileAtPath:dir]) {
        [fileManager createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
        
    }
    
    return [NSString stringWithFormat:@"%@/%@%@%@", docPath, MEDIA_BASE, IMAGE_DIR, photoName];
}
+ (NSString *)saveJPGForData:(NSData *)data withType:(NSString *)type{
    
    NSString *imgPath = [Utilities JPGtimedVersionUniqueNameWithType:type];
    if([Utilities writeData:data toFile:imgPath]){
        
        NSURL *url = [NSURL fileURLWithPath:imgPath isDirectory:NO];
        if ([url setResourceValue:[NSNumber numberWithBool:YES]
                           forKey:NSURLIsExcludedFromBackupKey error: nil]){
            
            return imgPath;
        }
    }
    return nil;
}


+ (UIAlertController *)actionSheetWithLocationFind:(CLLocationCoordinate2D)location{
    
    //    self.urlScheme = @"tourway://";
    //    self.appName = @"TourWay";
    __block NSString *urlScheme = @"tourway://";
    __block NSString *appName = @"TourWay";
    __block CLLocationCoordinate2D coordinate = location;
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"选择地图" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    if ( [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"http://maps.apple.com/"]])
    {
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"苹果地图" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            MKMapItem *currentLocation = [MKMapItem mapItemForCurrentLocation];
            MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:coordinate addressDictionary:nil]];
            
            [MKMapItem openMapsWithItems:@[currentLocation, toLocation]
                           launchOptions:@{MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving,MKLaunchOptionsShowsTrafficKey: [NSNumber numberWithBool:YES]}];
        }];
        
        [alert addAction:action];
    }
    
    if ( [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"baidumap://"]])
    {
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"百度地图" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            NSString *urlString = [[NSString stringWithFormat:@"baidumap://map/direction?origin={{我的位置}}&destination=latlng:%f,%f|name=目的地&mode=driving&coord_type=gcj02",coordinate.latitude, coordinate.longitude] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            NSLog(@"%@",urlString);
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
            
        }];
        
        [alert addAction:action];
    }
    
    
    if ( [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"iosamap://"]])
    {
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"高德地图" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            NSString *urlString = [[NSString stringWithFormat:@"iosamap://navi?sourceApplication=%@&backScheme=%@&lat=%f&lon=%f&dev=0&style=2",appName,urlScheme,coordinate.latitude, coordinate.longitude] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            NSLog(@"%@",urlString);
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
            
        }];
        
        [alert addAction:action];
    }
    
    if ( [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"comgooglemaps://"]])
    {
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"谷歌地图" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            NSString *urlString = [[NSString stringWithFormat:@"comgooglemaps://?x-source=%@&x-success=%@&saddr=&daddr=%f,%f&directionsmode=driving",appName,urlScheme,coordinate.latitude, coordinate.longitude] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            NSLog(@"%@",urlString);
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
            
        }];
        
        [alert addAction:action];
    }
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:action];
    
    return alert;
}

+ (UIAlertController *)actionSheetWithLocation:(CLLocationCoordinate2D)location withAddress:(NSString *)address{

    __block NSString *urlScheme = @"tourway://";
    __block NSString *appName = @"途遇";
    __block CLLocationCoordinate2D coordinate = location;
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"选择地图" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    
    if ( [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"http://maps.apple.com/"]])
    {
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"苹果地图" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
          CLGeocoder  *geocoder=[[CLGeocoder alloc] init];
            [geocoder reverseGeocodeLocation:[[CLLocation alloc] initWithLatitude:location.latitude longitude:location.longitude]completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
                
                CLPlacemark *clPlacemark = [placemarks firstObject];//获取第一个地标
                MKPlacemark *mkplacemark=[[MKPlacemark alloc]initWithPlacemark:clPlacemark];//定位地标转化为地图的地标
                NSDictionary *options=@{MKLaunchOptionsMapTypeKey:@(MKMapTypeStandard)};
                MKMapItem *mapItem=[[MKMapItem alloc]initWithPlacemark:mkplacemark];
                [mapItem openInMapsWithLaunchOptions:options];
                
            }];
            
        }];
        
        [alert addAction:action];
    }
    
    if ( [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"baidumap://"]])
    {
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"百度地图" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
             NSString *urlString = [[NSString stringWithFormat:@"baidumap://map/marker?location=%f,%f&title=位置&content=%@&src=途遇|%@",coordinate.latitude, coordinate.longitude, address, appName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
        }];
        [alert addAction:action];
    }
    
    
    if ( [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"iosamap://"]])
    {
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"高德地图" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            NSString *urlString = [[NSString stringWithFormat:@"iosamap://viewMap?sourceApplication=%@&backScheme=%@&poiname=A&lat=&lat=%f&lon=%f&dev=1",appName,urlScheme,coordinate.latitude, coordinate.longitude] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
        }];
        [alert addAction:action];
    }
    
    if ( [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"qqmap://"]])
    {
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"腾讯地图" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            qqmap://map/routeplan?type=drive&fromcoord=CurrentLocation&tocoord=%f,%f&coord_type=1&policy=0",coordinate.latitude, coordinate.longitude
            NSString *urlString = [[NSString stringWithFormat:@"http://apis.map.qq.com/uri/v1/marker?marker=coord:%f,%f;title:位置;addr:%@&coord_type=1&referer=%@",coordinate.latitude, coordinate.longitude, address, appName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            NSLog(@"%@",urlString);
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"apis.map.qq.com/uri/v1/marker?marker=coord:39.892326,116.342763;title:超好吃冰激凌;addr:手帕口桥北铁路道口&referer=myapp"]];
            
        }];
        
//        [alert addAction:action];
    }

    
    if ( [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"comgooglemaps://"]])
    {
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"谷歌地图" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {

             NSString *urlString = [[NSString stringWithFormat:@"comgooglemaps://?q=%f,%f(%@)&z=17&hl=ch",coordinate.latitude, coordinate.longitude, address] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
        }];
        
        [alert addAction:action];
    }
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:action];
    
    return alert;
}

+ (NSDictionary *)dictionoryFromBase64JsonString:(NSString *)string{

    NSDictionary *result = nil;
    
    NSData *nsdataFromBase64String = [[NSData alloc]
                                      initWithBase64EncodedString:string options:0];
    
    // Decoded NSString from the NSData
    NSString *base64Decoded = [[NSString alloc]
                               initWithData:nsdataFromBase64String encoding:NSUTF8StringEncoding];
    NSData *data = [base64Decoded dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSError *error;
    result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    
    return result;
}
+ (NSString *)bsae64JsonStringFromDictionory:(NSDictionary *)dictionory{
    
    NSString *result = @"";
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionory options:NSJSONWritingPrettyPrinted error:&error];
    NSString *text = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSData *data1 = [text dataUsingEncoding:NSUTF8StringEncoding];
    result = [data1 base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    
    return result;
}


+ (NSDictionary *)dictionoryFromJsonString:(NSString *)string{
    
    NSDictionary *result = nil;
    
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSError *error;
    result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    
    return result;
}
+ (NSString *)jsonStringFromDictionory:(NSDictionary *)dictionory{

    NSString *result = @"";
    
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dictionory options:NSJSONWritingPrettyPrinted error:&error];
    result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    return result;
}
+ (NSString *)getPriceStringWithprice:(float )price{
    
    NSString *result = @"";
    
    float n = price;
    
    float num1,num2;
    
    num1=(int)(n*100+0.5);
    
    int i,j;
    
    i=(int)num1%100;
    num2=num1/100;
    
    j=(int)num2%100;
    
    
    
    if(i==0 && j==0){
        
        result = [NSString stringWithFormat:@"¥%d", (int)num2];
        //        NSLog(@"/n四舍五入后为：%d",(int)num2);
    }
    
    else{
        result = [NSString stringWithFormat:@"¥%.2f", num2];
        
        //        NSLog(@"/n四舍五入后为：%.2f",num2);
    }
    
    result = [result stringByReplacingOccurrencesOfString:@".00" withString:@""];
    result = [result stringByReplacingOccurrencesOfString:@".0" withString:@""];
    
    if ([result containsString:@"."]) {
        
        if ([result hasSuffix:@"0"]) {
            result = [result substringToIndex:result.length - 1];
        }
    }
    else{
    }
    return result;
}



@end






















