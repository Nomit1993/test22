//
//  ZDetectionApi.h
//  ZDetection
//
//  Created by Ryan Chazen on 11/2/15.
//  Copyright © 2015 Zimperium Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZDetectionState.h"
#import "ZThreat.h"
#import "ZDetectionTester.h"
#import "ZThreatDisposition.h"
#import "ZDetectionInfo.h"
#import "AppRisks.h"

#ifndef ZDetectionEngineStatisticsLogLevel
#define ZDetectionEngineStatisticsLogLevel
typedef NS_ENUM(NSInteger, ZLogLevel) {
    debug,
    warning,
    off
};
#endif

typedef NS_ENUM(NSInteger, RuleRunLevel) {
    PRODUCTION = 1,
    BETA = 2,
    QA = 3
};


/**
A callback definition to use for passing code blocks to execute when threats are detected.
*/
typedef void (^ ZThreatCallback)(ZThreat * _Nonnull newThreat);
typedef void (^ ZDetectionStateCallback)(ZDetectionState * _Nonnull oldState, ZDetectionState * _Nonnull newState);
typedef void (^ ZUrlScanResultCallback)(NSArray * _Nullable safeUrls, NSArray * _Nullable flaggedUrls);

/**
ZDetection is the main interface point for controlling threat monitoring. For most use cases, simply calling detectCriticalThreatsWithCallback: will be sufficient, along with shutdownZIAPEngine if it is desirable to stop monitoring at some point.
 
 The callback should include code to remove any sensitive data or take other actions to protect the user. These actions would be specific to your own application and use cases.
 
 Objective C:
 <pre>
 #import \<ZDetection/ZDetection.h\>
 [ZDetection detectCriticalThreatsWithCallback:^(ZThreat *newThreat) {
     NSLog(@"Got critical threat: %@", newThreat);
     // Do some action to protect the user here, such as:
        [session logout];
 }];
 </pre>
 
 Swift:
 <pre>
 import ZDetection
 ZDetection.detectCriticalThreats { (ZThreat) in
     print(ZThreat!)
     // Do some action to protect the user here, such as:
        session.logout
 }
 </pre>
*/
@interface ZDetection : NSObject

/**
Run active checks against the current network connection to determine if there are any attacks in progress
against network security.
 Notice that the callback will be running in background thread and won't be safe running in UI thread.
 @callback: completion routine will be called upon completion of device integrity check.

*/
+ (void) checkDeviceIntegrity:(void(^_Nullable)(void))callback;

+ (BOOL) isZDetectionAvailable;

/**
Runs a thorough check to determine if the device is rooted or jailbroken.
 Notice: Do not call this in main UI thread. It may block UI thread.
@return true if the device has been rooted or jailbroken
*/
+ (BOOL) isRootedOrJailbroken;

/**
Runs a check to determine if the device is likely to be an emulator or if a debugger has been connected.

@return true if the device could be debugged
*/
+ (BOOL) isDebugged;

/**
 Deprecatd. Use [setLicenseKey:(NSData*) error:(NSError*)] instead. Set the license key for ZDetection framework.
    Run this before any other API to use ZDetection framework properly.
 @licenseKey: license key to set
 @force: whether we regard the previous token or not. If it is set, it will disregard the previous auth token.
 @error: User will need to check to see if there's any error.
 Notice that force bit 'true' will clear the current login token, which will make zIPA to login to Console,
    regardless of the previous login status. Making the force bit 'false' will be sufficient for most of use case
    since user want to keep the login token. However when user has a new license, user want to set the force bit 'true'
    to clear the current login token to login with the new license information.
    Once user is logged in, user want to change the force bit 'false' to continue to use the login token.
 */
+ (void) setLicenseKey:(NSData* _Nonnull)licenseKey force:(BOOL)force error:(NSError*_Nullable*_Nullable)error __deprecated;

/**
 Setting license key.

 @param licenseKey license key (or activation token) to be used.
 @error: User will need to check to see if there's any error.
 */
+ (void) setLicenseKey:(NSData* _Nonnull)licenseKey error:(NSError*_Nullable*_Nullable)error;

/**
 Deprecated. Please use MDM ID instead.
 Set Device ID for the device using ZDetection framework.

 @param deviceId: user will set the string ID that can identify device uniquely.
 */
+ (void) setDeviceId:(NSString* _Nonnull)deviceId __deprecated;

/**
 Set MDM ID for the device using ZDetection framework.
 MDM provider uses this API to set MDM id for the device.

 @param mdmId MDM id for the device.
 */
+ (void) setMDMId:(NSString* _Nonnull)mdmId;

/**
 Deprecated. Use setTrackingIds instead. Set custom tags for customer. The tags will be associated with the device that user sets the tags.
 will be deprecated. Use setTrackingIds instead.
 @tag1: custom tag1
 @tag2: custom tag2
 */
+ (void) setCustomTags:(NSString* _Nonnull)tag1 tag2:(NSString* _Nonnull)tag2 __deprecated;

/**
 Set tracking ids for customer. The tracking ids will be associated with the device that user sets the tags.
 
 @tag1: custom tag1
 @tag2: custom tag2
 */
+ (void) setTrackingIds:(NSString* _Nonnull)tag1 tag2:(NSString* _Nonnull)tag2 __deprecated;

/**
 Set tracking ids for customer. Once the tracking ids are set, they will be associated any threats or device information.

 @param tag1 any string for tag1. Maximum length is 128.
 @param tag2 any string for tag2, Maximum length is 128.
 @param error error won't be nil if there's any error in setting the tracking ids.
 @return void. If it is successful, error will be null. 
 */
+ (void) setSafeTrackingIds:(NSString* _Nonnull)tag1 tag2:(NSString* _Nonnull)tag2 error:(NSError*_Nullable*_Nullable)error;

/**
Have the zIAP engine notify you when any critical threat is found by zIAP.

@param callback A callback must be passed in that will be called when zIAP detects the threat.
*/
+ (void) detectCriticalThreatsWithCallback:(ZThreatCallback _Nonnull)callback;

/**
Have the zIAP engine notify you when the device encounters a rogue SSL certificate.

@param callback A callback must be passed in that will be called when zIAP detects the threat.
*/
+ (void) detectRogueSSLCertWithCallback:(ZThreatCallback _Nonnull)callback;

/**
Have the zIAP engine notify you when the device is on a rogue network.

@param callback A callback must be passed in that will be called when zIAP detects the threat.
*/
+ (void) detectRogueNetworkWithCallback:(ZThreatCallback _Nonnull)callback;

/**
Have the zIAP engine notify you when the device has been compromised by on on-device attack.

@param callback A callback must be passed in that will be called when zIAP detects the threat.
*/
+ (void) detectDeviceCompromisedWithCallback:(ZThreatCallback _Nonnull)callback;

/**
Have the zIAP engine notify you when a malicious app becomes present on the device.

@param callback A callback must be passed in that will be called when zIAP detects the threat.
*/
+ (void) detectMaliciousAppWithCallback:(ZThreatCallback _Nonnull)callback;

/**
Remove a specific callback that was previously registered with one of the detection functions.

This method will not affect other registered callbacks and will not shut down the detection service, even if all callbacks are removed.
shutdownZIAPEngine must be called if you wish to stop the engine from running entirely.

@param callback The same callback used when calling a detection function.
*/
+ (void) stopDetectingForCallback:(ZThreatCallback _Nonnull)callback;

/**
Shutdown monitoring of threats and end the zIAP process. This method will remove all registered threat handlers, and will close all resources in use by the engine.
*/
+ (void) shutdownZIAPEngine;

/**
 Shutdown with callback. When shutdown is completed, the callback will be called.
 */
+ (void) shutdownZIAPEngineWithCallback:(void(^_Nonnull)(NSError* _Nullable error))callback;

/**
 Will return an instance of ZDetectionTester that can be used to test the
 capabilities of zIAP, and can be used to unit test various detection flows for
 integration purposes, as well as test connectivity with the Zimperium Console.
*/
+ (ZDetectionTester *_Nonnull) createZDetectionTester;

/**
 Disable all location reporting.
*/
+ (void) disableLocation;

/**
 Re-enable all location reporting if it has been previously disabled.
*/
+ (void) enableLocation;

/**
 Add detection status callback. Can add multiple callback. 
 The order of callback won't be guaranteed. 
 */
+ (void) addDetectionStateCallback:(ZDetectionStateCallback _Nonnull )callback;

/**
 Remove detection callback. The callback block will be removed from the list and 
 won't received any callback after that.
 */
+ (void) removeDetectionStateCallback:(ZDetectionStateCallback _Nonnull)callback;

/**
 Set data folder for all ZIAP files including database.
 Once user sets it, it will be saved into UserDefault database and will be available subsequently.
 If user calls it with different folder in subsequent call, the previous one will be ignored and
 the new folder is used for ZIAP data files and database.

 @param folder to create.
 @param error will be returned if the folder creation is failed.
 @return true if folder creation succeeds. 
 Notice: cannot contain Documents or path in the folder string. Will not backup or move old ZIAP files
 to the new location when the location of folder is changed or when a new folder is created.
 */
+ (BOOL) setDataFolder:(NSString* _Nonnull)folder error:(NSError*_Nullable*_Nullable)error;

/**
 Disable all Danger Zone reporting.
 */
+ (void) disableDangerZone;

/**
 Re-enable all Danger Zone reporting if it has been previously disabled.
 */
+ (void) enableDangerZone;

/**
 Get the sdk version installed in App. The format of the version number is major.minor.build_number-flavor"
 */
+ (NSString*_Nonnull) getSdkVersion;

+ (ZDetectionInfo*_Nonnull)getDetectionInfo;

/**
 Get the ZDetection engine logs.
 
 Notice: Use [ZDetection setLogLevel: debug]; to set desired log level.
 */
+ (NSArray<NSDictionary*> *_Nullable) getLogs;

/**
 Set log level for the logs returned by getLogs. getLogs return all log entries that have a log level >= then set log level.
 Available log levels can be found in ZLogEntry.h
 Example: Obj-C [ZDetection setLogLevel: debug];
          Swift ZDetection.setLogLevel(.debug)
 
 @param desiredLogLevel array of desired log levels.

 Notice 1: If no call is made to setLogLevel debug log level is set.
 Notice 2: You can disable loging by calling [ZDetection setLogLevel: off]
 */
+ (void) setLogLevel: (ZLogLevel) desiredLogLevel;

/**
 Get the current phishing DB.

 @return the array of phishing URL in string.
 */
+ (NSArray<NSString*>*_Nonnull)getPhishingDB;

/**
 Send ziap poll command to zcloud console to see if there is any zcloud command to run.
 */
+ (void) alertZcloudCommand;

/**
 Scans the url passed in to determine if it is a known risky URL.
 The callback will be called after the scan is completed.

 @param url URL to scan
 @param triggerThreat determine whether it triggers threat or not if it deems to be risky.
 @param callback the result callback.
 */
+ (void) scanUrl:(NSString *_Nonnull)url triggerThreat:(bool)triggerThreat callback:(ZUrlScanResultCallback _Nonnull )callback;

/**
 Report malicious url is opened. The malicious url was warned, but user chose to continue.
 
 @param url malicious url
 */
+ (void) maliciousUrlOpened:(NSString*_Nonnull)url;

/**
 Set run mode for foreground execution.
 Two run modes are available:
 ZRUNMODE_NORMAL: normal running. The normal running mode is set by default.
 ZRUNMODE_FOREGROUND_BATTERY_SAVE. This mode will start battery save mode. The detection will run less frequently to save the foreground battery usage.

 @param runMode either ZRUNMODE_NORMAL or ZRUNMODE_FOREGROUND_BATTERY_SAVE
 */
+ (void) setRunMode:(ZRunMode)runMode;

/**
 Get the current run mode.

 @return the current run mode. 
 */
+ (ZRunMode) getCurrentRunMode;

/**
Get AppRisks API.

@return object that allows access to AppRisks interface.
*/
+(AppRisks* _Nonnull)getAppRisks;

/**
  Run this will make iOS pop up the local network access permission dialog.
    Notice that this won't guarantee to show up the local network pop up.
    The pop up dialog will only show once.
   @return true when successfuly trigger the test.
        when it is false, the test trigger cannot be reliable. There may be no local interface.
 */
+(BOOL) requestLocalNetworkPermission;

/**
    Test whether user has the local network permission.
     @return
            ZTEST_TRUE when devcie has the local network permission.
            ZTEST_FALSE when device does not have the local network permission.
            ZTEST_NEED_TO_REQUEST_PERMISSION when device never run 'requestLocalNetworkPermission' before.
                                device needs to run this first to show the proper local network permisson status.
            ZTEST_WIFI_REQUIRED: App is in no-wifi. To run this test, App needs to be in wifi. 
            ZTEST_UNKNOWN when the status cannot be determined due to some unknown reason. Most likely memory or resource error.
 */
+ (ZTestStatus) hasLocalNetworkPermission;


/**
    Set the current rule run level. This defines which types of rules are downloaded and used by the engine.
    QA rules can only be selected for non-release builds.
 */
+ (void) setRuleRunLevel:(RuleRunLevel)ruleRunLevel;
/**
    Fetch current rule run level - production, beta or qa
 */
+ (RuleRunLevel) getRuleRunLevel;

/**
Have the zIAP engine notify you when any threat is found by zIAP.
@param callback A callback must be passed in that will be called when zIAP detects the threat.
*/
+ (void) startDetectionWithThreatCallback:(ZThreatCallback _Nonnull )callback;
@end
