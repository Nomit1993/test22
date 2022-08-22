//
//  ZcloudWrapper.h
//  zIPS
//
//  Created by Ryan Chazen on 2/4/14.
//  Copyright (c) 2014 Zimperium LTD All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ZDetection/DangerZone.h>
#import "PushTokenType.h"
@class ZDetectionState;
typedef NS_ENUM(NSInteger, ZCloudState);
typedef NS_ENUM(NSInteger, ZEngineState);
typedef NS_ENUM(NSInteger, ZErrorState);
typedef NS_ENUM(NSInteger, ZRunMode);

typedef void (^ ZUrlScanResultCallback)(NSArray *safeUrls, NSArray *flaggedUrls);

@interface ZcloudWrapper : NSObject <DangerZoneDelegate>
@property (strong, nonatomic) DangerZone *dangerZone;
@property (strong, nonatomic) ZDetectionState *detectionState;

+ (Boolean) hasAuthToken;

+ (void)setTrackingIds:(NSString*)trackingId1 id2:(NSString*)trackingId2;

+ (void) removeAuthToken;

+ (NSString*)getZIAPDocFolder;

+ (NSURL*)getZIAPDocFolderURL;

- (NSString*)getPhishingDBFileDate;
- (NSString*) getPhishingDBRevisionNumber;
- (NSString*)getPhishingClassifierSignature;

- (NSString*) getAuthToken:(OSStatus*)status;
- (void) setAuthToken:(NSString *)authtoken;

- (NSString*) getCommandUrl;

- (void) updateCloudState:(ZCloudState)cloudState EngineState:(ZEngineState)engineState ErrorState:(ZErrorState)errorState;

- (void) doNormalLoginPath:(BOOL)retry;

- (void) doManualLoginPathWithUsername:(NSString *)username Password:(NSString *)password;

- (void) doLoginPathWithInTuneToken:(NSString *)intunetoken Email:(NSString *)email;

- (void) doLoginPathWithIamToken:(NSString *)iamtoken IamAuthmethodId:(NSString *)iamauthmethod IamIdentityToken:(NSString *)iamidentity IamEmail:(NSString *)iamemail;

- (void) doGoodLoginPathWithToken:(NSString *)token Username:(NSString *)username ContinerId:(NSString *)continerid UemId:(NSString *)uemid;

- (void) doLoginPathWithSoftbankToken:(NSString *)idtoken AccessToken:(NSString *)accesstoken RefreshToken:(NSString *)refreshtoken Cuid:(NSString *)cuid;

- (void) softbankSubscriptionEnded;

- (void) doForgotPasswordLoginPathWithUsername:(NSString *)username;

- (int) logout;

- (int) setCommunicationChannel:(NSString *) commchannel;

- (int) setSecureCommunicationChannel:(NSString *) commchannel WithKey:(NSString *)key;

- (int) setConnectionState:(int) state;

- (void) fakeData;

- (int) notifyNetworkChange;

- (int) notifyDeviceWakingUp:(void (^)(void))callback;

- (void) notifyZipsExternalCommand:(void *) command ForType:(int) type;

- (void) notifyZipsCommand:(void *) command ForType:(int) type;

- (void) notifyZipsEvent:(void *) event ForType:(int) type;

- (void) notifyGeneralEvent:(void *) event ForType:(int) type;

- (void) startDetection;

- (void) stopDetection;

- (int) isDetectionRunning;

- (NSString *) commChannelDefault;

- (void) notifyScreenOn;
- (void) notifyScreenOff;

- (void) notifyPhoneCallOn;
- (void) notifyPhoneCallOff;

- (void) sendSync;

- (void) setTenantId:(NSString *)tenant;

- (void) sendAdalTokenToZcloud:(NSString*) adalToken deviceId:(NSString*) deviceId mdmId:(NSString*) mdmId;

- (void) sendAppPushToken:(NSString *) token VoipToken:(NSString *) voiptoken ForType:(PushTokenType) type;

- (void) alertZcloudCommandsWithURL:(NSString *)url;

- (void) sendAckWithID:(NSString *)ack_id;

- (long int) getAppsCounter:(int)days;

- (long int) getDeviceCounter:(int)days;

- (long int) getNetworkCounter:(int)days;

- (void) toggleAllDetection:(Boolean) toggle;

- (NSString*) getMDMId:(BOOL*)isMDM;

- (int) waitForNetworkThreads;

- (void) setAllowDangerZone: (Boolean) newValue;

- (Boolean) allowDangerZone;

- (NSNumber*)countCriticalThreatsForNetwork:(NSDictionary*)ni;

- (NSNumber*)countElevatedThreatsForNetwork:(NSDictionary*)ni;

- (NSDictionary*)getCriticalThreatsForNetwork:(NSDictionary*)ni;

- (NSDictionary*)getElevatedThreatsForNetwork:(NSDictionary*)ni;

- (void) getNetworksInLat1:(NSNumber*)lat1
                      lon1:(NSNumber*)lon1
                      lat2:(NSNumber*)lat2
                      lon2:(NSNumber*)lon2
                completion:(getNetworksGridCompletion)completion;

- (void) saveLastValidDeviceID;
- (void) restoreLastValidDeviceID;
- (BOOL) shouldReportApp;
- (BOOL) isPrivacyPolicyAvailable;
- (void) checkDefaultTRM;
- (void) setTrackingIds:(NSString*)trackingId1 id2:(NSString*)trackingId2; 
- (void) getMDMConfiguration;
- (NSArray<NSString*>*)getPhishingDB;
- (void) updatePhishingDB;
- (BOOL)isNetworkWhitelisted:(NSString*)BSSID SSID:(NSString*)SSID threat_type:(int)threat_type;
- (void)clearUserData;
- (void) setupDangerZone;
- (void)searchRemoteDB:(NSString*)url triggerThreat:(bool)triggerThreat callback:(ZUrlScanResultCallback)callback;
- (void) siteInsightUrlScan:(NSString *)url triggerThreat:(bool)triggerThreat callback:(ZUrlScanResultCallback)callback;
- (void)maliciousUrlOpened:(NSString*)url;
- (void) setRunMode:(ZRunMode)runMode;
- (ZRunMode) getCurrentRunMode;
- (void) resetCloudState;
- (BOOL)isSideloadedDevWhitelisted:(NSString* _Nonnull)dev;
- (BOOL) hasEntitlement:(int) feature;
- (BOOL) shouldCollect:(int)context Collectible:(int)collectible;
- (unsigned int) getCollectables:(int)context;
- (BOOL)hasLocationAccuracy:(int)context;
- (BOOL)isAppWhiteListed:(NSString*)packageName;
- (void) resetCommandUrl;
@end
