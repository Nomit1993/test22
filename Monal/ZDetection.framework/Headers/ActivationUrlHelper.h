//
//  ActivationUrlHelper.h
//  zIPS-ZDetection
//
//  Created by Ryan Chazen on 3/16/16.
//  Copyright © 2016 Zimperium Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ActivationUrlHelper : NSObject

+ (Boolean) handleActivationUrl:(NSString *)url;

+ (Boolean) handleActivationToken:(NSString *)url;

+ (NSString *) commChannelDev;
+ (NSString *) commChannelStaging;
+ (NSString *) commChannelLive;

+ (void) setCommChannelDev:(NSString *)str;
+ (void) setCommChannelStaging:(NSString *)str;
+ (void) setCommChannelLive:(NSString *)str;

@end
