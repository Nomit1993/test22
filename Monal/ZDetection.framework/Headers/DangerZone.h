//
//  DangerZone.h
//  zIPS-ZDetection
//
//  Created by Timothy Tripp on 8/19/16.
//  Copyright © 2016 Zimperium Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kKeyDZAttackCount       @"count"
#define kKeyDZLastAttack        @"last_attack"
#define kKeyDZNotificationType  @"type"

#define kDangerZoneCurrent      @"current_dangerzone"
#define kDangerZoneNearby       @"nearby_dangerzone"

#define kSettingsNeverShowAlertForNetworks @"never_show_alerts_for_networks"

typedef void(^getNetworksGridCompletion)(NSArray*, NSError*);

@protocol DangerZoneDelegate
- (void)showDangerZoneMap;
@end

@interface DangerZone : NSObject
@property (nonatomic, weak) id<DangerZoneDelegate> delegate;
+ (void) setAllowDangerZone: (Boolean) newValue;
+ (Boolean) allowDangerZone;
+ (NSString*)modeName:(int)nMode;
- (NSNumber*)countCriticalThreatsForNetwork:(NSDictionary*)ni;
- (NSNumber*)countElevatedThreatsForNetwork:(NSDictionary*)ni;
- (NSDictionary*)getCriticalThreatsForNetwork:(NSDictionary*)ni;
- (NSDictionary*)getElevatedThreatsForNetwork:(NSDictionary*)ni;
- (void) getNetworksInLat1:(NSNumber*)lat1
                      lon1:(NSNumber*)lon1
                      lat2:(NSNumber*)lat2
                      lon2:(NSNumber*)lon2
                completion:(getNetworksGridCompletion)completion;
@end


