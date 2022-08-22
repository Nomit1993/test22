//
//  ZDetectionInfo.h
//  ZDetection
//
//  Created by Jae Han on 11/9/18.
//  Copyright © 2018 Zimperium Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZThreat.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZDetectionInfo : NSObject

/**
 Server name that device is connecting to.

 @return the string name of the server endpoint.
 */
- (NSString*)serverName;

/**
 Customer name associated with the license.
 *

 @return customer name in string.
 */
- (NSString*)customerName;

/**
 TRM policy download date.

 @return TRM policy date in string.
 */
- (NSString*)threatPolicyDate;

/**
 Privacy download date.

 @return Privacy download date in string.
 */
- (NSString*)privacyPolicyDate;

/**
 Zee9 engine data download date.

 @return zee9 engine data download date in string.
 */
- (NSString*)z9DownloadDate __deprecated;

/**
 MDM config for the device. This may be json formatted string configured by plist.

 @return MDM config in string.
 */
- (NSString*)mdmConfig;

/**
 device ID of the device.

 @return device ID in string.
 */
- (NSString*)deviceID;

/**
 MDM ID of the device.

 @return mdm id for the device.
 */
- (NSString*)mdmID;

/**
 Return the current active license.

 @return license string for the device.
 */
- (NSString*)license;

/**
 Return the date of whitelisted certs download.

 @return whitelist certs download date in string.
 */
- (NSString*)whitelistCertsDate;

/**
  Get the phishing classifier download date.

  @return Date string of the last phishing classifier is downloaded.
 */
 - (NSString*)phishingClassifierDownloadDate;

 /**
  Get the signature of the phishing classifier

  @return signature of the phishing classifier
  */
 - (NSString*)phishingClassifierSignature __deprecated;

/**
 Return the date for recently downloaded phishing DB.

 @return phishing db download date in string.
 */
- (NSString*)phishingDBDate;


/**
 Get the revision number for the current phishing DB.

 @return revision number in string.
 */
- (NSString*)phishingDBRevisionNumber;

/**
 Return the last update date for the network whitelist.

 @return network whitelist download date.
 */
- (NSString*)accessPointDownloadDate;

/**
 Return the Treat Response Matrix.
 
 @return TRM in form ThreatType to ThreatSeverity map.
 */
- (NSDictionary *)getTRMSeverityMap;

/**
 Return the Treat Severity from Threat Type.
 
 @return ThreatSeverity.
 */
- (ZThreatSeverity)getTRMThreatSeverityFor:(ZThreatType)type;

/**
 Return the Treat Collection Map.
 
 @return Treat Collection Map.
 */
- (NSDictionary *)getThreatCollectionPolicyMap;

/**
 Return the Treat Collection Policy from Threat Type.
 
 @return Treat Collection Policy.
 */
- (BOOL)getThreatCollectionPolicyFor:(ZThreatType)type;

/**
 Return application setting for Danger Zone.
 
 @return boolean flag that indicates if Danger Zone has been enabled.
 */
- (BOOL)isDangerZoneEnabled;

/**
 Return application setting for Site Insight.
 
 @return boolean flag that indicates if Site Insight has been enabled.
 */
- (BOOL)isSiteInsightEnabled;

/**
 Return whether phishing classifier is enabled or not.

 @return true if phishing classifier is enabled.
 */
- (BOOL)phishingClassifierEnabled;

/**
 Get phishing threashold

 @return phishing threashold
 */
- (float)phishingThreshold;

/**
 Return the last update date for the sideloaded developers whitelist.

 @return sideloaded develpers whitelist download date.
 */
- (NSString*)sideloadedDevelopersWhitelistDownloadDate;

/**
 Return the Local VPN Custom DNS Settings from Console.
 
 @return Local VPN Custom DNS Settings which contains DNS1, DNS2, SSID, Type and date.
 */
- (NSDictionary *)getLocalVPNCustomDNSSettings;

/**
 Return the last updated downloaded date for the access control list.
 
 @return access control list download date.
 */
- (NSString*)accessControlListDownloadDate;

@end

NS_ASSUME_NONNULL_END
