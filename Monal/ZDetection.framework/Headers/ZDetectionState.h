//
//  ZDetectionState.h
//  ZDetection
//
//  Created by Ryan Chazen on 11/2/15.
//  Copyright © 2015 Zimperium Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, ZCloudState) {
    ZCLOUD_NOT_RUNNING,
    ZCLOUD_AUTHENTICATING,
    ZCLOUD_RUNNING
};

typedef NS_ENUM(NSInteger, ZEngineState) {
    ZENGINE_DETECTING,
    ZENGINE_NOT_DETECTING,
    ZENGINE_UPDATING
};

typedef NS_ENUM(NSInteger, ZErrorState) {
    ZERROR_NO_ERROR,
    ZERROR_AUTH_FAILED,
    ZERROR_SIMULATOR,
    ZERROR_CONNECTION_ERROR,
    ZERROR_LICENSE_EXPIRED,
    ZERROR_RESET_PASSWORD,
    ZERROR_LOGIN_CANCELLED,
    ZERROR_LICENSE_INVALID_OR_NOT_PRESENT,
    ZERROR_LICENSE_LIMIT_EXCEEDED,
    ZERROR_LOGGED_OUT
};

typedef NS_ENUM(NSInteger, ZRunMode) {
    ZRUNMODE_NORMAL,
    ZRUNMODE_FOREGROUND_BATTERY_SAVE
};

typedef NS_ENUM(NSInteger, ZTestStatus) {
    ZTEST_FALSE,
    ZTEST_TRUE,
    ZTEST_NEED_TO_REQUEST_PERMISSION,
    ZTEST_WIFI_REQUIRED,
    ZTEST_UNKNOWN
};

@interface ZDetectionState : NSObject

@property (nonatomic, assign) ZCloudState cloudStateEnum;
@property (nonatomic, assign) ZEngineState engineStateEnum;
@property (nonatomic, assign) ZErrorState errorStateEnum;

- (NSString *) cloudState;
- (NSString *) engineState;
- (NSString *) errorState;

- (NSString *) stringify;

@end
