//
//  ExtensionThreatReceiver.h
//  zIPS-ZDetection
//
//  Created by Ryan Chazen on 2019/05/19.
//  Copyright © 2019 Zimperium Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define kThreatReportsContainerNameKey @"com.zimperium.extension.detected_threats"
#define kThreatReportsEventKey "com.zimperium.extension.notification"

#define kTypeKey @"com.zimperium.extension.notification.type"
#define kDebugLogTag @"debug_log"
#define kThreatReportTag @"threat_report"
#define kThreatMitigatedTag @"threat_mitigated"

#define kURLKey @"url"
#define kSourceKey @"source"
#define kSessionKey @"session"
#define kAllowContinueKey @"allow_continue"
#define kMsgKey @"msg"
#define kThreatKey @"threat"
#define kPhishingNotificationTag @"phishing_notification_ui"

@interface ExtensionThreatReceiver : NSObject

+ (void)createThreatsInAppContext;
+ (NSArray*)getPendingThreats;
+ (void)clearPendingThreats;
+ (void)registerChangeListener;
+ (void)setPhishingAlertCallback:(void (^)(NSString *url, Boolean allowContinue))callback;

@end

NS_ASSUME_NONNULL_END

