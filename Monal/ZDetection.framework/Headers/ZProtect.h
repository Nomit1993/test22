//
//  ZProtect.h
//  ZDetection
//
//  Created by Ryan Chazen on 2019/11/03.
//  Copyright © 2019 Zimperium Inc. All rights reserved.
//
#ifdef ZVPN
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * The status of the phishing zprotect api
 */
@interface ZProtectPhishingStatus : NSObject

/**
 * Whether or not phishing has been enabled by the ZProtect configuration.
 */
- (Boolean) isPhishingEnabled;
/**
 * Whether or not the phishing databases have downloaded.
 */
- (Boolean) hasPhishingDatabases;
/**
 * This call will return true if the ZProtect VPN is enabled and running, phishing has been enabled, and the phishing databases are downloaded and phishing will function.
 */
- (Boolean) isPhishingActive;

@end

@interface ZProtectSinkholeStatus : NSObject

/**
* Whether or not sinkhole has been enabled by the ZProtect configuration.
*/
- (Boolean) isSinkholeEnabled;

@end

/**
* The status of the ZProtect API
*/
@interface ZProtectStatus : NSObject

/**
 * Whether the VPN is currently active and running on the device or not.
 */
- (Boolean) isVPNRunning;
/**
 * Fetch an object that provides for the current phishing status on the vpn
 */
- (ZProtectPhishingStatus*) phishingStatus;
/**
 * Fetch an object that provides for the current sinkhole status on the vpn
 */
- (ZProtectSinkholeStatus*) sinkholeStatus;

@end

enum ZProtect_SinkholeMode {
    BLOCK_ALL_BY_DEFAULT,
    ALLOW_ALL_BY_DEFAULT
};

@interface ZProtectConfig : NSObject

/**Create a new ZProtectConfig with default (blank) values. Use this method if you want to set all of the values to new ones.*/
+ (ZProtectConfig *) createConfigWithDefaults;
/**Create a new ZProtectConfig with the values from the previous time ZProtect.updateConfiguration was called. Use this method if you only want to update some values in the stored config.*/
+ (ZProtectConfig *) createConfigWithCurrentValues;

/**Set the name shown to the user in iOS system dialogs for this VPN.*/
@property (nonatomic) NSString *displayName;
/**Set an HTML page that will be shown to the user in their browser when a page has been blocked. It is up to the caller to provide an HTML page for the current localization. The HTML will be delivered as-is to the end user.*/
@property (nonatomic) NSString *blockedHTMLPage;
/**Option to enable or disable phishing protection.*/
@property (nonatomic) Boolean phishingEnabled;
/**Set an HTML page that will be shown to the user in their browser when a page has been blocked. It is up to the caller to provide an HTML page for the current localization. The HTML will be delivered as-is to the end user.*/
@property (nonatomic) NSString *localNotificationPhishingMessage;
/**Set a list of URLs that will not be flagged as phishing.*/
@property (nonatomic) NSArray<NSString*>* phishingWhitelist;
/**Set a list of URLs that will always be flagged as phishing.*/
@property (nonatomic) NSArray<NSString*>* phishingBlacklist;
/**Option to enable or disable the sinkhole rule set.*/
@property (nonatomic) Boolean sinkholeEnabled;
/**Option to disable the ios notification popup when an ip or domain is blocked by sinkhole*/
@property (nonatomic) Boolean sinkholeNotificationDisabled;

@end

@interface ZProtect : NSObject

/**ZProtectConfig will allow for different ZProtect features to be enabled or disabled. This will store the relevant values to shared files on disk, as well as notify the VPN that the configuration has changed and should be reloaded from disk.*/
+ (void) updateConfiguration:(ZProtectConfig*) config;

/**Call this method to remove the stored ZProtect configuration and reset the VPN to use values obtained from the Zimperium server set by ZConsole.*/
//+ (void) disableConfiguration;

/**Starts the VPN.*/
+ (void) startVPN;

/**Stops the VPN.*/
+ (void) stopVPN;

/**Check if the user has granted VPN permissions. (If the VPN profile exists and can be enabled)*/
+ (void) hasVPNAuthorizationWithCallback:(void (^)(Boolean isAuthorized, NSError* _Nullable error))callback;

/**Pop up an iOS permission request dialog to add the VPN. The callback will be called once the VPN permission has been granted.*/
+ (void) requestVPNAuthorizationFromUserWithCallback:(void (^)(Boolean isAuthorized, NSError* _Nullable error))callback;

/**Check if the VPN is currently enabled and running. The phishing or sinkhole status of the VPN will be determined by what was last set in the updateConfiguration call. */
+ (void) isVPNRunningWithCallback:(void (^)(Boolean isRunning, NSError* _Nullable error))callback;

/**A phishing alert callback must be set. This callback will be called when a phishing alert needs to be displayed to the user.
 The URL that triggered the phishing alert will be set.
 The allowContinue flag relates to the phishing policy on zconsole and can be ignored.*/
+ (void) setPhishingAlertCallback:(void (^)(NSString *url, Boolean allowContinue))callback;

/**Set a callback that is invoked when the status of ZProtect changes, such as phishing databases becoming available or the VPN stopping. */
+ (void) addZProtectStatusChangeCallback:(void (^)(ZProtectStatus* status))callback;

/** Get phishing statistics. The codes are subject to change. Contact Zimperium for further information. */
+ (NSString*) getPhishingStat;

/** Get the current shinkhole settings.
 */
+ (NSString*) getSinkholeSettings;

+ (Boolean) copyPhishingFiles;

/** User need to run this to see if VPN is suported in this version iOS. */
+ (Boolean) isVPNSupported;

/**
    Clear the local whitelist.
 */
+ (void) clearLocalWhitelist;

@end

NS_ASSUME_NONNULL_END
#endif
