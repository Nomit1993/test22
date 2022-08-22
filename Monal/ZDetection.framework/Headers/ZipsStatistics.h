//
//  ZipsStatistics.h
//  ZDetection
//
//  Created by Ryan Chazen on 2020/08/15.
//  Copyright © 2020 Zimperium Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/***
 ZipsStatistics class to store and load settings. ZipsStatistics name to match Android ZipsStatistics
 The key purpose of this class is to ensure all settings get mirrored into SharedDefaults for access by Extensions
 If no appgroup is set in info.plist (eg, zIAP 3rd party use case), then settings will only store in local NSUserDefaults
 */
@interface ZipsStatistics : NSObject

+ (void) setStat:(NSObject*)val forKey:(NSString*)key;
+ (void) setBoolStat:(bool)val forKey:(NSString*)key;
+ (void) setFloatStat:(float)val forKey:(NSString*)key;
+ (void) setDoubleStat:(double)val forKey:(NSString*)key;
+ (void) setIntStat:(NSInteger)val forKey:(NSString*)key;
+ (void) setSafeStringStat:(const char*)val forKey:(NSString*)key;

+ (nullable id) statForKey:(NSString*)key;
+ (bool) boolStatForKey:(NSString*)key;
+ (float) floatStatForKey:(NSString*)key;
+ (double) doubleStatForKey:(NSString*)key;
+ (NSInteger) intStatForKey:(NSString*)key;
+ (void) synchronize;

+ (void) setKeychainStat:(NSString*)val forKey:(NSString*)key;
+ (void) removeStatForKey:(NSString*)key;
+ (NSString*) keychainStatForKey:(NSString*)key;

+ (NSDictionary*) mdmSettings;


@end

NS_ASSUME_NONNULL_END
