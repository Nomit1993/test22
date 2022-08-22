//
//  ZWifiConnection.h
//  ZDetection
//
//  Created by Ryan Chazen on 3/18/16.
//  Copyright © 2016 Zimperium Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZWifiConnection : NSManagedObject

+ (ZWifiConnection *) lastWifiConnectionWithBSSID:(NSString *)bssid andMOC:(NSManagedObjectContext *)moc;

+ (void) onWifiChange;
+ (NSString*)encryptBSSID:(NSString*)bssid;
+ (NSString*)encryptSSID:(NSString*)ssid;
+ (NSString*)decryptSSID:(NSString*)ssid;
+ (NSString*)decryptBSSID:(NSString*)bssid;

@end

NS_ASSUME_NONNULL_END

#import "ZWifiConnection+CoreDataProperties.h"
