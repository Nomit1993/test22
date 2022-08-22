//
//  AppRisk.h
//  ZDetection
//
//  Created by Pawel Kijowski on 1/21/20.
//  Copyright © 2020 Zimperium Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AppRisk : NSObject<NSCopying>
-(instancetype)initWithPackageName:(NSString* _Nonnull)packageName
                          appLabel:(NSString* _Nonnull)appLabel
                         marketURL:(NSURL* _Nullable)marketURL
                         universalURL:(NSURL* _Nullable)universalURL
                           iconURL:(NSURL* _Nullable)iconURL
                   rawPrivacyScore:(NSInteger)rawPrivacyScore
                  rawSecurityScore:(NSInteger)rawSecurityScore
               privacyScoreReasons:(NSArray* _Nonnull)privacyScoreReasons
              securityScoreReasons:(NSArray* _Nonnull)securityScoreReasons;
@property (readonly, nonnull) NSString* packageName;
@property (readonly, nonnull) NSString* appLabel;
@property (readonly, nullable) NSURL* marketURL;
@property (readonly, nullable) NSURL* universalURL;
@property (readonly, nullable) NSURL* iconURL;
@property (readwrite) NSInteger rawPrivacyScore;
@property (readwrite) NSInteger rawSecurityScore;
@property (readonly, nonnull) NSArray* privacyScoreReasons;
@property (readonly, nonnull) NSArray* securityScoreReasons;
@end

NS_ASSUME_NONNULL_END
