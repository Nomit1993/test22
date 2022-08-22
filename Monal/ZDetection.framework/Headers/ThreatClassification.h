//
//  ThreatClassification.h
//  zIPS-ZDetection
//
//  Created by Ryan Chazen on 2/11/16.
//  Copyright © 2016 Zimperium Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ThreatClassification : NSObject

@property (nonatomic, assign) Boolean hasSideloadedAppsCriticalThreat;
@property (nonatomic, assign) Boolean hasSideloadedAppsElevatedThreat;
@property (nonatomic, assign) Boolean hasSideloadedAppsThreat;
@property (nonatomic, assign) Boolean hasAppsCriticalThreat;
@property (nonatomic, assign) Boolean hasAppsElevatedThreat;
@property (nonatomic, assign) int numAppsCriticalThreat;
@property (nonatomic, assign) int numAppsElevatedThreat;
@property (nonatomic, assign) Boolean hasDeviceElevatedThreat;
@property (nonatomic, assign) Boolean hasDeviceCriticalThreat;
@property (nonatomic, assign) int numDeviceCriticalThreat;
@property (nonatomic, assign) int numDeviceElevatedThreat;
@property (nonatomic, assign) Boolean hasNetworkElevatedThreat;
@property (nonatomic, assign) Boolean hasNetworkCriticalThreat;
@property (nonatomic, assign) int numNetworkCriticalThreat;
@property (nonatomic, assign) int numNetworkElevatedThreat;
@property (nonatomic, assign) Boolean isJailbroken;
@property (nonatomic, assign) Boolean isCompromised;
@property (nonatomic, assign) Boolean isUntrustedProfile;
@property (nonatomic, strong) NSMutableSet<NSString*> *untrustedProfileNames;
@property (nonatomic, assign) Boolean hasNoPasscode;
@property (nonatomic, strong) NSArray *activeThreats;
@property (nonatomic, strong) NSArray *activeNetworkThreats;
@property (nonatomic, strong) NSArray *activeDeviceThreats;
@property (nonatomic, strong) NSArray *activeAppsThreats;
@end
