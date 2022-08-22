//
//  ZThreatDeposition.h
//  ZDetection
//
//  Created by Jae Han on 2/20/18.
//  Copyright © 2018 Zimperium Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZThreatDisposition : NSObject

/**
 Returns true if the server has noted this devices as running a vulnerable OS version
 */
- (BOOL)isOsVulnerable;
/**
 Returns true if the server has noted this devices as running a vulnerable and non upgradable OS version
 */
- (BOOL)isOsVulnerableAndNonUpgradable;
/**
 Returns true if there is an event logged on the device that is deemed as compromising
 */
- (BOOL)isCompromised;
/**
 Returns true if this device is BlueBorne vulnerable
 */
- (BOOL)isBlueBorneVulnerable;
/**
 Returns true if this device is rooted
 */
- (BOOL)isRooted;


/**
 Check to see if a threat is active or not.

 @param uuid UUID of a threat
 @return return true if the threat is active.
 */
- (BOOL)isThreatActive:(NSString*)uuid;


/**
 Return active threats in the device.
 Notice: do not call this in main UI thread. It may block UI thread. 

 @return list of active threat.
 */
- (NSArray*)getActiveThreats;
@end
