//
//  ZWifiConnection+CoreDataProperties.h
//  ZDetection
//
//  Created by Ryan Chazen on 3/18/16.
//  Copyright © 2016 Zimperium Inc. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "ZWifiConnection.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZWifiConnection (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *ssid;
@property (nullable, nonatomic, retain) NSString *bssid;
@property (nullable, nonatomic, retain) NSString *gw;
@property (nullable, nonatomic, retain) NSString *dns;
@property (nullable, nonatomic, retain) NSDate *connectTime;
@property (nullable, nonatomic, retain) NSDate *disconnectTime;
@property (nullable, nonatomic, retain) NSNumber *wasAttacked;

@end

NS_ASSUME_NONNULL_END
