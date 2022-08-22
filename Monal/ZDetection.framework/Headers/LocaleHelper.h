//
//  LocaleHelper.h
//  zIPS
//
//  Created by Ryan Chazen on 5/5/15.
//  Copyright (c) 2015 Mobile Dev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocaleHelper : NSObject

+ (NSDictionary *)ISO639_2Dictionary;
+ (NSString *)ISO639_2LanguageCode;

+ (NSString *) appName;
+ (void) setAppName:(NSString *)appname;

@end
