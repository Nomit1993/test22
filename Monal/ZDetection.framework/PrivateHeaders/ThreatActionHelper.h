//
//  TheatActionHelper.h
//  zIPS
//
//  Created by Ryan Chazen on 2/26/15.
//  Copyright (c) 2015 Mobile Dev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ThreatActionHelper : NSObject

#ifndef PRIVACY_VERSION
+ (BOOL)createRemoteVPN:(void *) vpnsettings;
#endif

#ifdef MDM_VERSION
+ (void)disableBluetooth;
#endif

@end
