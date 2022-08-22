//
//  ZThreatInternal.h
//  ZDetection
//
//  Created by Ryan Chazen on 2021/05/25.
//  Copyright © 2021 Zimperium Inc. All rights reserved.
//

#ifndef ZThreatInternal_h
#define ZThreatInternal_h

#import <Foundation/Foundation.h>
#import "ZThreat.h"

@interface ZThreat()

- (void) updateWithEvent:(void *) event;
- (BOOL) saveThreat:(NSDictionary *) threat;
/**
 * A json string that contains all of the response details found below. The type of forensics detected depends on the setting local_event_detail
 *
 * @return
 */
- (NSString *) threatForensicJSON;

/**
 * BSSID of the access point when the attack was detected. Only present when the device was connected to a wifi network (example : "06:19:70:39:82:b9").
 *
 * @return
 */
- (NSString *) BSSID;

/**
 * IP address of the device, when is available.
 *
 * @return
 */
- (NSString *) deviceIP;

/**
 * MAC address of the device, when is available (only on ethernet networks).
 *
 * @return
 */
- (NSString *) deviceMAC;

/**
 * Network interface, when available (example : “wlan0”, “rmnet0, etc).
 *
 * @return
 */
- (NSString *) interface;

/**
 * Attacker’s IP address, only present on network related attacks when Headless zIPS is able to get the attacker’s IP address on the current network.
 *
 * @return
 */
- (NSString *) attackerIP;

/**
 * Attacker’s MAC address, only present on network related attacks when Headless zIPS is able to get the attacker’s MAC address on the current network.
 *
 * @return
 */
- (NSString *) attackerMAC;

- (NSString *) attackerHost;

/**
 * System file path of a malicious APK detected by headless zIPS (Example : “/data/app/com.ledflashlight.panel-2.apk” or “/sdcard/Download/trojan-2.apk”)
 *
 * @return
 */
- (NSString *) malwarePath;

/**
 * SHA256 sum of the scanned file and classified as malicious by Headless zIPS, to uniquely identify a given sample.
 *
 * @return
 */
- (NSString *) malwareHash;

/**
 * Name of a running process that triggered a detection on Headless zIPS, including the full parent tree. Usually processes are responsible of Elevation of Privileges attacks. Example : “/init (1) -> com.malicious.app (1293) -> ./exploit (3392)”
 *
 * @return
 */
- (NSString *) processName;

/**
 * Package name correlated to a given host threat detected by Headless zIPS. A package name uniquely identify an application installed on the device. Example : “com.geohot.towelroot”
 *
 * @return
 */
- (NSString *) packageName;

/**
 Return the version of Out Of Compliance app threat.
 
 @return version number in string.
 */
- (NSString*) OOCAppVersion;

/**
 Return the file hash of Out Of Compliance app threat.
 
 @return file hash in string.
 */
- (NSString*) OOCAppFileHash;

/**
 Return the app name of Out Of Compliance app threat if available.
 
 @return app name.
 */
- (NSString*) OOCAppName;

/**
 * Full path of a file or directory associated to a threat detected by Headless zIPS. For example, zIPS will watch critical parts of the file system on the device and will notify all modification detected on it (usually performed by persistent malware).
 *
 * @return
 */
- (NSString *) filePath;

/**
 * When Headless zIPS detects a Traffic Tampering threat the intercepted URL will be reported on this field.
 *
 * @return
 */
- (NSString *) tamperedUrl;

- (NSString *) malwareSource;

/**
 * Gateway IP when available
 *
 * @return
 */
- (NSString *) gatewayIP;

/**
 * Gateway MAC when available
 *
 * @return
 */
- (NSString *) gatewayMAC;

/**
 * A list of strings that indicate the responses set up for this threat in the Threat Response Matrix
 *
 * @return
 */
- (NSArray *) threatResponses;

- (NSString *) profileName;

- (NSString *) blockedDomain;

- (void)setAlertVisible:(BOOL)visible;

- (BOOL)getAlertVisible;

- (void)setSubsequent:(BOOL)subsequent;

- (BOOL)getSubsequent;

- (NSString *) sideloadedAppDeveloper;
- (NSString *) sideloadedAppName;
- (NSString *) sideloadedAppPackage;

- (NSString *) dangerzoneNearbySsid;
- (BOOL) needToCheckAction;
- (void) updateValue:(NSString*)key value:(bool)value;
- (NSString *) zcategory;
/**
 * URL detected by site insight check.
 *
 * @return malicious url as string
 */
- (NSString *) maliciousUrl;

- (NSString *) confidentialForensicJson;
- (NSString *) dynamicTrigger;
- (NSString *) dynamicInternalName;

+ (NSAttributedString *) replaceVariablesInString:(NSAttributedString *)str forThreat:(ZThreat *)threat;

+ (NSString *) hardcodedRawDescriptionForThreat:(ZThreat *)threat;
+ (NSString *) hardcodedRawDescriptionForThreatInEnglish:(ZThreat *)threat;
+ (NSAttributedString *) attributedHardcodedDescriptionForRawDescription: (NSString *) rawLocalizedDescription
                                                               forThreat: (ZThreat *) threat;
+ (NSAttributedString *) hardcodedDescriptionForThreat:(ZThreat *)threat;

@end


#endif /* ZThreatInternal_h */
