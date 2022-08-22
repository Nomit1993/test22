//
//  ReachabilityHelper.h
//  ZDetection
//
//  Created by Ryan Chazen on 2018/05/11.
//  Copyright © 2018 Zimperium Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReachabilityHelper : NSObject

+ (ReachabilityHelper *) createReachability;
- (void) start;
- (void) stop;

+ (int) connectionState;

@property (nonatomic)   NSString* lastSSID;
@property (nonatomic)   NSString* activeSSID;

@end
