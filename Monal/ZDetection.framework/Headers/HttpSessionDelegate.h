//
//  HttpSessionDelegate.h
//  zIPSUtils
//
//  Created by Jae Han on 3/15/17.
//  Copyright © 2017 zimperium. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZCertStore : NSObject

+(ZCertStore*)instance;
+ (BOOL) shouldGetCertificate:(NSString*)commandName;

- (NSData*) findCertFromHost:(NSString*)host;
- (BOOL) setCert:(const char*)data forHost:(NSString*)host;
- (void) setPublicKeyHash:(const char*)data forCN:(const char*)cn;
- (void) removeAllPublicKeyHash;
- (NSMutableSet*) getWhitelistedKeys;
- (NSMutableSet*) getCerts:(NSString*)hostname forCN:(NSString**)cn;
@end

@interface HttpSessionDelegate : NSObject <NSURLSessionDelegate, NSURLSessionTaskDelegate>

- (id)initWithEnforceChecking:(bool)shouldCheck withCertificate:(NSMutableArray*)certificate withHostName:(NSString*)hostname;
- (NSDictionary *)getCertChain;
- (NSString*) getAcceptedCN;
- (NSString*) getLeafCert;
- (BOOL)isContainWhitelistCert;
- (BOOL)canRefreshPinnedCert:(int)retry;
@end
