//
//  AppRisks.h
//  ZDetection
//
//  Created by Pawel Kijowski on 1/21/20.
//  Copyright © 2020 Zimperium Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppRisksCompletionHandler.h"
#import "AppRisk.h"
#import "AppRisk+RiskLevel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AppRisks : NSObject
-(void)query:(NSString * _Nonnull)q completionHandler:(AppRisksRequestCompletionHandler)handler;
-(void)trendingWith:(AppRisksRequestCompletionHandler)completionHandler;
@end

NS_ASSUME_NONNULL_END
