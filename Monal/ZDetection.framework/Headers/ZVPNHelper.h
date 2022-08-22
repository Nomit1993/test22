//
//  ZVPNHelper.h
//  zIPS-ZDetection
//
//  Created by Ryan Chazen on 6/19/17.
//  Copyright © 2017 Zimperium Inc. All rights reserved.
//
#ifdef ZVPN
#import <Foundation/Foundation.h>

extern NSString * _Nonnull const kIsVPNReadyForUnsecuredWiFiUserDefaultsKey;
extern NSString * _Nonnull const kVPNDisabledForNetworkSSIDUserDefaultsKey;
extern NSString * _Nonnull const kShouldAutoEnableVPN;
extern NSString * _Nonnull const kVPNTunnelEnabled;

typedef enum {
    VPNEnableType_UNKNOWN = 0,
    VPNEnableType_DISABLE = 1,
    VPNEnableType_ENABLE = 2
} VPNEnableType;

@class NETunnelProviderManager;
@interface ZVPNHelper : NSObject

+ (void) setup;
+ (void) enable;
+ (void) copyConfig;
+ (void) disable;
+ (void) updateSettings:(BOOL)htmlPageChanged url:(NSString*)url permanent:(BOOL)permanent;
+ (void) clearPhishingWhitelist;

+ (void) enableZFiltering;
+ (void) setupRemoteVPN;
+ (void) enableRemoteVPN;
+ (void) disableVPNThreatResponse;
+ (void) enableForThreat;
+ (void) checkVPNStatus;
+ (Boolean) isSiteInsightVpnEnabled;
+ (void) loadZVPNManager: (void(^)(NETunnelProviderManager *)) completionHandler;

+ (void) getStats:(nullable void (^)( NSData * __nullable responseData))responseHandler;

+(VPNEnableType)isVPNReadyForUnsecureWiFi;
+(void)setVPNReadyForUnsecuredWiFi;
+(void)setVPNNotReadyForUnsecuredWiFi;
+(BOOL)isVPNDisabledForNetwork:(NSString * _Nullable)ssid;
+(void)saveVPNDisabledForNetwork:(NSString* _Nullable)ssid;
+(void)clearVPNDisabledForNetwork;
+(void)clearVPNDisabledForNetworkIfNetworkChanged;
+(void)updateVPNSettingsWithAutoenableFor:(NETunnelProviderManager*)manager;
+(void)updateVPNSettingsWith:(NETunnelProviderManager*)manager;
+(void)turnVPNOnForUnsecuredWiFi;
+(void)turnVPNOff;
+(void)setupUnsecuredWifiNotification;
+(void)notifyUnsecuredWifiSession:(NSString*)ssid;
+(void)setVPNReadyForUnsecuredWiFiManual;
+(void)turnOffAllVPNs;
+(void)resetVPNSettings;
+(void)resetAndTurnOff;

+ (NSString *_Nonnull) appGroup;
+ (NSString *_Nonnull) groupPath;
+ (NSString *_Nonnull) providerBundleIdentifier;
+ (NSUserDefaults *_Nonnull) sharedDefaults;

+(void)addWhitelistedZimperiumUrl:(NSString *) url;

+(void)updateSettingsAfterPhishingPolicyUpdate:(void(^_Nonnull)(void))callback;
+ (void) updateiOS10Settings;
+(void)updateCustomDNSSetting:(NSDictionary*)dnsSettings;
+(void)resetVPNLogin;
+(BOOL)isAllowed:(NSString*)url;
@end
#endif
