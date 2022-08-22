//
//  ZHotspotHelper.h
//  ZDetection
//
//  Created by Ryan Chazen on 2020/03/14.
//  Copyright © 2020 Zimperium Inc. All rights reserved.
//

#ifdef ZHOTSPOT

#import <Foundation/Foundation.h>
#import <NetworkExtension/NetworkExtension.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZHotspotHelper : NSObject

/**
Refer to documentation for NEHotspotHelper for details.
ZHotspotHelper must be used to register with HotspotHelper to allow ZDefend to monitor network traffic as only a single registration per app can be made.
ZHotspotHelper will pass through responses unchanged to provided handler(s). Only a single response per network must be provided.

If handleAllResponses has been called, you must not provided responses in your handler as well.
*/
+ (BOOL) registerWithOptions:(nullable NSDictionary<NSString *,NSObject *> *)options
                  queue:(dispatch_queue_t)queue
                handler:(NEHotspotHelperHandler)handler
API_AVAILABLE(ios(9.0)) API_UNAVAILABLE(macos, watchos, tvos);

/**
If using registerWithOptions and handling hotspot responses directly, this method can be used to check if a given NEHotspotNetwork is a Dangerzone.
 */
+ (BOOL) isDangerZone:(NEHotspotNetwork *)network;

/**
An alternative way to enable hotspothelper. In this case, ZDefend will take over handling all responses, and will flag DangerZones automatically
 */
+ (void) handleAllResponses;

+ (NSArray<NEHotspotNetwork*>*) supportedNetworkInterfaces;

@end

NS_ASSUME_NONNULL_END

#endif // ZHOTSPOT
