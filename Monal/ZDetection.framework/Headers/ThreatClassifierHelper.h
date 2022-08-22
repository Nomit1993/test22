//
//  ThreatClassifierHelper.h
//  zIPS-ZDetection
//
//  Created by Ryan Chazen on 2/11/16.
//  Copyright © 2016 Zimperium Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CFNetwork/CFNetwork.h>

#import "ZDetection.h"

@class ThreatClassification;

typedef enum {
    ConnectionTypeUnknown,
    ConnectionTypeNone,
    ConnectionType3G,
    ConnectionTypeWiFi
} ConnectionType;

@interface ThreatClassifierHelper : NSObject

@property (nonatomic, strong) NSManagedObjectContext * _Nonnull moc;

- (instancetype _Nonnull ) initWithMOC:(NSManagedObjectContext *_Nonnull) frommoc;

- (void) innerCalculateThreatStatusWithCallback:(void (^_Nonnull)(ThreatClassification * _Nonnull threatClassification)) callback wait:(BOOL)wait;

+ (void) calculateThreatStatusWithCallback:(void (^_Nonnull)(ThreatClassification * _Nonnull threatClassification)) callback;

- (Boolean) isRadarNetworkThreat:(ZThreat *_Nonnull) threat;

+ (void) createCriticalThreatListWithCallback:(void (^_Nonnull)(NSArray<ZThreat *>* _Nonnull))callback;

+ (ConnectionType)connectionType;

+(BOOL)isWiFiSecureWithSSID:(NSString * _Nullable)ssid;

@end

