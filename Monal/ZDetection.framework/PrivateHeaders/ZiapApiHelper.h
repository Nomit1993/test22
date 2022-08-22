//
//  ZiapApiHelper.h
//  ZDetection
//
//  Created by Ryan Chazen on 2/2/16.
//  Copyright © 2016 Zimperium Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZiapApiHelper : NSObject

+ (NSArray<NSNumber*>*) rogueSSLCertList;

+ (NSArray<NSNumber*>*) rogueNetworkList;

+ (NSArray<NSNumber*>*) deviceCompromisedList;

+ (NSArray<NSNumber*>*) maliciousAppList;

+ (NSString *) deviceHash;

+ (void) sendAccessPointToZcloud;

+ (void) createContentBlockerJson;

@end
