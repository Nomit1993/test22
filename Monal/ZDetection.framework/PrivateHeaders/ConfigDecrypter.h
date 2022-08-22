//
//  ConfigDecrypter.h
//  ZDetection
//
//  Created by Ryan Chazen on 12/1/15.
//  Copyright © 2015 Zimperium Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MDM_ID      @"com.zimperium.uid"
#define DEVICE_ID   @"com.zimperium.uid-device"

@interface ConfigDecrypter : NSObject

+ (NSData *) readConfigFileFromPath:(NSString *) path;
+ (void) setLicenseKey:(NSData*)licenseKey force:(BOOL)force error:(NSError**)error;
+ (NSData *) getConfigData;
+ (BOOL) isForceSet;
+ (void) setMDMId:(NSString*)mdmId;
+ (NSString*) getMDMId;
+ (NSString*) getDeviceId;
+ (void) setDeviceId:(NSString*)deviceId;
+ (NSData*) getLicenseKey;
+ (void) setLicenseKey:(NSData*)license;
+ (NSString*)getJWTString;
+ (void) clearLicenseKeyHolder;
+ (NSData*)readConfigData;
+ (NSString*) getAcceptor;
+ (void) removeMDMId;
@end
