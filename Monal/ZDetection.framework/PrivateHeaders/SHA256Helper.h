//
//  SHA256Helper.h
//  zIPS
//
//  Created by Ryan Chazen on 6/4/15.
//  Copyright (c) 2015 Mobile Dev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SHA256Helper : NSObject

+ (NSString *) sha256HashFor: (NSString *) filePath useCache:(BOOL)useCache;
+ (NSString *) sha256HashFor: (NSString *) filePath;

@end
