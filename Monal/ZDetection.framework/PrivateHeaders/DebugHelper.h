//
//  DebugHelper.h
//  ZDetection
//
//  Created by Ryan Chazen on 2/2/16.
//  Copyright © 2016 Zimperium Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DebugHelper : NSObject

+ (BOOL) sysctlDebugCheck;

+ (BOOL) consoleDebugCheck;

+ (BOOL) ppidCheck;

@end
