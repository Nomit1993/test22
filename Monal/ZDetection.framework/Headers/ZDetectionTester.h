//
//  ZDetectionTester.h
//  ZDetection
//
//  Created by Ryan Chazen on 1/6/17.
//  Copyright © 2017 Zimperium Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZThreat.h"

@interface ZSimulatedAttack : NSObject

/**
 Attacker gateway IP address.

 @param ip gateway ip address to set.
 */
- (void)setAttackerGatewayIP:(NSString*)ip;

/**
 Attacker gateway MAC address.

 @param mac gateway MAC address to set.
 */
- (void)setAttackerGatewayMac:(NSString*)mac;

/**
 Attacker IP address.

 @param ip ip address to set.
 */
- (void)setAttackerIP:(NSString*)ip;

/**
 Attacker MAC address.

 @param mac mac address to set.
 */
- (void)setAttackerMAC:(NSString*)mac;
@end

/**
Create and send a test threat that will appear as a test rogue ssl threat on zconsole and will
be delivered locally to registered handlers if subscribed using detectRogueSSLCert or detectCriticalThreats
*/
@interface ZDetectionTester : NSObject

/**
Create and send a test threat that will appear as a test rogue ssl threat on zconsole and will
be delivered locally to registered handlers if subscribed using detectRogueSSLCert or detectCriticalThreats
*/
- (void) testRogueSSL;
/**
 Create and send a test threat that will appear as a test rogue network threat on zconsole and will
 be delivered locally to registered handlers if subscribed using detectRogueNetwork or detectCriticalThreats
*/
- (void) testRogueNetwork;

/**
Create and send a test threat that will appear as a test device compromised threat on zconsole and will
be delivered locally to registered handlers if subscribed using detectDeviceCompromised or detectCriticalThreats
*/
- (void) testDeviceCompromised;

/**
Create and send a test threat that will appear as a test malicious app threat on zconsole and will
be delivered locally to registered handlers if subscribed using detectMaliciousApp or detectCriticalThreats
*/
- (void) testMaliciousApp;


/**
 Simulate threats with ZThreatType. 
 It will be appeared as a real threat in zconsole without attacker information.

 @param threat ZThreatType to simulate.
 */
- (void) testThreatWithThreatType:(ZThreatType)threat;


/**
 Simulate ARP MITM threat.
 It will be appeared as a real threat in zconsole with the attacker information provided.

 @param attack simulated attack for ARP MITM.
 */
- (void) testARPMITMThreat:(ZSimulatedAttack*)attack;

/**
 Simulate ARP Scan threat.
 It will be appeared as a real threat in zconsole with the attacker information provided.

 @param attack simulated attack for ARP Scan.
 */
- (void) testARPScanThreat:(ZSimulatedAttack*)attack;

/**
 Simulate ICMP Redirect threat.
 It will be appeared as a real threat in zconsole with the attacker information provided.

 @param attack simulated attack for ICMP Redirect.
 */
- (void) testICMPRedirectThreat:(ZSimulatedAttack*)attack;

/**
 Simulate proxy change threat.
 It will be appeared as a real threat in zconsole with the attacker information provided.

 @param attack simulated attack for proxy change.
 */
- (void) testProxyChangeThreat:(ZSimulatedAttack*)attack;

/**
 Simulate rouge access point threat.
 It will be appeared as a real threat in zconsole with the attacker information provided.

 @param attack simulated attack for rogue access point
 */
- (void) testRogueAccessPointThreat:(ZSimulatedAttack*)attack;


/**
 Simulate SSL Strip threat.
 It will be appeared as a real threat in zconsole with the attacker information provided.

 @param attack simulated attack for ssl strip.
 */
- (void) testSSLStripThreat:(ZSimulatedAttack*)attack;

/**
 Simulate Suspicious App threat.
 It will be appeared as a real threat in zconsole with the attacker information provided.
 
 @param attack simulated attack for suspicious app.
 */
- (void) testSuspiciouAppThreat:(ZSimulatedAttack*)attack;

/**
 Simulate Sideloaded App threat.
 It will be appeared as a real threat in zconsole with the attacker information provided.
 
 @param attack simulated attack for sideloaded app.
 */
- (void) testSideloadedAppThreat: (ZSimulatedAttack *) attack;

/**
 Simulate Out of Compliance App threat.
 It will be appeared as a real threat in zconsole with the attacker information provided.
 
 @param attack simulated attack for ooc app.
 */
- (void) testOOCAppThreat: (ZSimulatedAttack *) attack;

/**
 Simulate Untrusted profile threat.
 It will be appeared as a real threat in zconsole with the attacker information provided.

 @param attack simulated attack for untrusted profile.
 */
- (void) testUntrustedProfileThreat:(ZSimulatedAttack*)attack;

/**
Remove all simulated threats in the device. Any real threats in the device won't be removed.
 @param error: represent an error while removing the simulated threats.
 
 return true when all simulated threats are removed.
*/
- (BOOL) removeAllSimulatedThreats:(NSError**)error;

#ifdef DEBUG
- (void)testVuluerableOSVersion:(ZSimulatedAttack*)attack;
- (void)testVuluerableOSVersionMitigation:(ZSimulatedAttack *)attack;
- (void)testVuluerableOSVersionMitigationVersion:(ZSimulatedAttack *)attack;
#endif
@end
