//
//  ZDetectionApi.h
//  ZDetection
//
//  Created by Ryan Chazen on 11/2/15.
//  Copyright © 2015 Zimperium Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZDetectionApi.h"
#import "PushTokenType.h"
#import "ThreatClassification.h"
#import "ThreatClassifierHelper.h"
#import "ZProtect.h"
#import "DangerZone.h"
#import "Collectables.h"
#import "VPNPingHelper.h"
#import "PermissionManager.h"

typedef NSArray* _Nullable (^ ZDetectionInstalledAppBlock)(void);

typedef NS_ENUM(unsigned int, PrivacyContext) {
    ON_THREAT = 1
};

@interface ZDetection()


/*
 loginWithJWTLicense: Pass encoded(encrypted(JWT)) as it is.
 jwt: encoded(encrypted(JWT)) string
 return: if the JWT is valid then true, otherwise it will be false and should consult the value of error.
 */
+ (BOOL) loginWithJWTLicense:(NSString*_Nonnull)jwt error:(NSError*_Nonnull*_Nullable)error;

+ (void) loginWithUser:(NSString *_Nonnull)username Password:(NSString *_Nonnull)password;

+ (void) loginWithGoodToken:(NSString *_Nonnull)token Username:(NSString *_Nonnull)username ContinerId:(NSString *_Nonnull)continerid UemId:(NSString *_Nonnull)uemid;

+ (void) loginWithInTuneToken:(NSString *_Nonnull)intunetoken Email:(NSString *_Nonnull)email DeviceId:(NSString *_Nonnull)deviceid;

+ (void) loginWithIamToken:(NSString *_Nonnull)iamtoken IamAuthmethodId:(NSString *_Nonnull)iamauthmethod IamIdentityToken:(NSString *_Nonnull)iamidentity IamEmail:(NSString *_Nonnull)iamemail;

+ (void) loginWithSoftbankToken:(NSString *_Nonnull)idtoken AccessToken:(NSString *_Nonnull)accesstoken RefreshToken:(NSString *_Nonnull)refreshtoken Cuid:(NSString *_Nonnull)cuid TenantId:(NSString *_Nonnull)tenantid;

+ (void) softbankSubscriptionEnded;

+ (void) queueNormalLoginPath;

+ (void) sendAppPushToken:(NSString *_Nonnull) token VoipToken:(NSString *_Nonnull) voiptoken ForType:(PushTokenType) type;

+ (void) sendAdalTokenToZcloud:(NSString *_Nullable) adalToken deviceId:(NSString *_Nullable) deviceId mdmId:(NSString *_Nullable) mdmId;

+ (void) sendAckWithID:(NSString *_Nonnull)ack_id;

+ (void) alertZcloudCommandsWithURL:(NSString *_Nullable)url;

+ (void) resetPasswordForUser:(NSString *_Nonnull)username;

+ (void) notifyPhoneCallOn;

+ (void) notifyPhoneCallOff;

+ (void) notifyScreenOn;

+ (void) notifyScreenOff;

+ (void) notifyNetworkChange;

+ (void) notifyDeviceWakingUp;

+ (void) fakeData;

+ (void) setConnectionState:(int) state;

+ (void) acknowledgeThreat:(ZThreat *_Nonnull)threat;

+ (ZDetectionState*_Nonnull) detectionState;

+ (void) startDetectionWithThreatCallback:(ZThreatCallback _Nonnull)callback SeverityFilter:(ZThreatSeverity) severity;

+ (void) startDetectionWithThreatCallback:(ZThreatCallback _Nonnull)callback TypeFilter:(int) type;

+ (void) clearHistoricThreatLog;

+ (void) sendSync;

+ (void) setTenantId:(NSString *_Nonnull)tenant;

+ (void) checkDevicePasscodeSet:(void (^_Nonnull)(Boolean hasPasscodeSet))caller;

+ (long int) getAppsCounter:(int)days;

+ (long int) getDeviceCounter:(int)days;

+ (long int) getNetworkCounter:(int)days;

+ (long int) getPhishingCounter:(int)days;

+ (void) setNearbyWifiList:(NSArray *_Nonnull) wifilist;
+ (NSArray *_Nullable) nearbyWifiList;
+ (void) setConnectingWifi:(NSDictionary *_Nonnull) wifi;

+ (void) toggleAllDetection:(Boolean) toggle;

+ (NSString *_Nullable) commChannel;

+ (void)setCustomCerts:(NSData*_Nonnull)certs;

/**
 Get the ZDetection engine logs.
 
 Notice: Use [ZDetection setLogLevel: debug]; to set desired log level.
 */
+ (NSArray<NSDictionary*> *_Nullable) getLogs;

/**
 Get the ZDetection rule download logs.
 
 Notice: Use [ZDetection setLogLevel: debug]; to set desired log level.
 */
+ (NSArray<NSDictionary*> *_Nullable) getRuleDownloadLogs;

/**
 Get the ZDetection rule state logs.
 
 Notice: Use [ZDetection setLogLevel: debug]; to set desired log level.
 */
+ (NSArray<NSDictionary*> *_Nullable) getRuleStateLogs;

/**
 Get the ZDetection rule run logs.
 
 Notice: Use [ZDetection setLogLevel: debug]; to set desired log level.
 */
+ (NSArray<NSDictionary*> *_Nullable) getRuleRunLogs;

/**
 Get the ZDetection phishing logs.
 
 Notice: Use [ZDetection setLogLevel: debug]; to set desired log level.
 */
+ (NSArray<NSDictionary*> *_Nullable) getPhishingLogs;

+ (void) logEngineStatisticsEvent: (NSString *_Nonnull) event;
+ (void) logEngineStatisticsEvent: (NSString *_Nonnull) event withLevel: (ZLogLevel) level;
/**
 Set log capacity.
 
 @param newCapacity new desired log capacity.
 
 Notice: Capacity should be between 0 and 1000. If the value is out of this range the capacity is going to be reset to the default value of 100.
 */
+ (void) setLogCapacity: (NSInteger) newCapacity;
+ (void) scanAppsJson:(NSArray *_Nonnull)apps;

+ (NSString *_Nullable) hardcodedRawDescriptionForThreat:(ZThreat *_Nonnull)threat;
+ (NSString *_Nullable) hardcodedRawDescriptionForThreatInEnglish:(ZThreat *_Nonnull)threat;
+ (NSAttributedString *_Nullable) attributedHardcodedDescriptionForRawDescription: (NSString *_Nonnull) rawLocalizedDescription
                                                               forThreat: (ZThreat *_Nonnull) threat;
/**
 Get device id.

 @param error if there's an error to retrieve device id, the error will be set.
 @return device id.
 */
+ (NSString*_Nullable) getDeviceID:(NSError*_Nullable*_Nullable)error;

/**
 Get MDM id.

 @param error if there's an error to get mdm id.
 @return mdm id if it is available.
 */
+ (NSString*_Nullable) getMDMID:(NSError*_Nullable*_Nullable)error;
+ (void)logout;

+ (void) clearMitigatedThreats;
+ (NSString*_Nullable)getPhishingDBDate;
+ (NSString*_Nullable)getPhishingDBRevisionNumber;
+ (NSString*_Nullable)getPhishingSignature;
+ (void) updatePhishingDB;

/**
 Test whether the BSSID(SSID) is whitelisted or not.

 @param BSSID BSSID to test
 @param SSID SSID to test
 @param threat_type threat type to check against the BSSID or SSID
 @return true if it is whitelisted. 
 */
+ (BOOL)isNetworkWhitelisted:(NSString*_Nullable)BSSID SSID:(NSString*_Nullable)SSID threat_type:(ZThreatType)threat_type;

/**
 Clear user data such as proxy whitelist and AP whitelist.
 */
+ (void)clearUserData;

+ (NSNumber*_Nullable)countCriticalThreatsForNetwork:(NSDictionary*_Nonnull)ni;

+ (NSNumber*_Nullable)countElevatedThreatsForNetwork:(NSDictionary*_Nonnull)ni;

+ (NSDictionary*_Nullable)getCriticalThreatsForNetwork:(NSDictionary*_Nonnull)ni;

+ (NSDictionary*_Nullable)getElevatedThreatsForNetwork:(NSDictionary*_Nonnull)ni;

+ (void) getNetworksInLat1:(NSNumber*_Nonnull)lat1
                      lon1:(NSNumber*_Nonnull)lon1
                      lat2:(NSNumber*_Nonnull)lat2
                      lon2:(NSNumber*_Nonnull)lon2
                completion:(getNetworksGridCompletion _Nonnull )completion;

+ (Boolean) isPhishingUrl:(NSString *_Nonnull)url;

+ (void) reportMaliciousUrl:(NSString*_Nonnull)url;
+(BOOL)isSideloadedDevWhitelisted:(NSString* _Nonnull)dev;

+ (BOOL) hasEntitlement:(int) feature;

+ (BOOL) shouldCollect:(int)context Collectible:(int)collectible;

+ (BOOL)isAppWhiteListed:(NSString*_Nullable)packageName;

+ (void)initializeDetection;

+ (NSString*_Nullable)getVpnDeviceLog;

+ (void) mitigateThreatByInternalName:(NSString*_Nullable)name value:(NSNumber*_Nullable)value;

+ (ZThreatResultsController * _Nonnull) historicThreats;

+ (ZThreatResultsController * _Nonnull) historicThreatsGroupedByMitigated;

+ (ZThreatResultsController * _Nonnull) historicThreats_Device;

+ (ZThreatResultsController * _Nonnull) historicThreats_Network;

+ (ZThreatResultsController * _Nonnull) historicThreats_Apps;

+ (ZThreatResultsController * _Nonnull) historicThreatsOfType:(NSArray<NSNumber*>*_Nonnull)threatIds;

+ (ZThreatResultsController * _Nonnull) activeThreats;

+ (ZThreatResultsController * _Nonnull) activeThreats_Device;

+ (ZThreatResultsController * _Nonnull) activeThreats_Network;

+ (ZThreatResultsController * _Nonnull) activeThreats_Apps;

+ (ZThreatResultsController * _Nonnull) activeThreatsOfType:(NSArray<NSNumber*>*_Nonnull)threatIds;

+ (ZThreatResultsController * _Nonnull) activeCriticalThreats;

/**
 Fetch the current collectables in the privacy policy from the given context.
 */
+(Collectables *_Nullable) getCollectables:(PrivacyContext)context;

/**
 Check if location accuracy is set.
 */
+(BOOL) hasLocationAccuracy:(PrivacyContext)context;

@end
