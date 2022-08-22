//
//  VPNPingHelper.h
//
//  Created by Jae Han on 1/12/21.
//  Copyright © 2021 Zimperium Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VPNPingHelper : NSObject

// test whether zVPN is up and running.
// BOOL will tell the test was successful or not.
// NSError must be nil to secceed this test.
// Notice: if NSError is not nil, then the boolean result may not truly indicate the zVPN status.
+ (void)test_running:(void (^)(BOOL, NSError*))completion;

@end

NS_ASSUME_NONNULL_END
