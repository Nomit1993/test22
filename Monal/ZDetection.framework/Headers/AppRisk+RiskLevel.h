//
//  AppRisk+RiskLevel.h
//  ZDetection
//
//  Created by Pawel Kijowski on 1/22/20.
//  Copyright © 2020 Zimperium Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


#import "AppRisk.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, AppRiskLevel) {
    unknown,
    trusted,
    low,
    medium,
    high
};

@interface AppRisk (RiskLevel)
@property (readonly) AppRiskLevel privacyRiskLevel;
@property (readonly) AppRiskLevel securityRiskLevel;
@property (readonly) AppRiskLevel riskLevel;
@end

NS_ASSUME_NONNULL_END
