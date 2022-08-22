//
//  PermissionManager.h
//  ZDetection
//
//  Created by Akshay Ramesh on 10/26/21.
//  Copyright © 2021 Zimperium Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PermissionManager : NSObject

+ (NSString*) getCameraPermissionState;
#ifndef PRIVACY_VERSION
+ (NSString*) getLocationPermissionState;
+ (NSString*) getPreciseLocationPermissionState;
+ (NSString*) getDeviceLocationState;
#endif
+ (NSString*) getNotificationPermissionState;
#ifdef ZVPN
+ (NSString*) getVPNPermissionState;
+ (NSString*) isVPNEnabledState;
#endif
@end

NS_ASSUME_NONNULL_END
