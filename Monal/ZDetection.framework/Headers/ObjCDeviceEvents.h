//
//  ObjCDeviceEvents.h
//  dd_sdk_plugin
//
//  Created by Ryan Chazen on 2020/01/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^ObjCEventCallback)(NSString* eventName, NSString* detailsJson);

@interface ObjCDeviceEvents : NSObject

+ (NSValue*) listenForEvent:(NSString *)eventName block:(void (^)(void))block;
+ (NSValue*) listenForEvent:(NSString *)eventName blockWithDetails:(ObjCEventCallback)block;
+ (NSValue*) listenAll:(ObjCEventCallback)block;
+ (void) unlisten:(NSValue*) registration;
+ (void) submit:(NSString *)eventName;
+ (void) submit:(NSString *)eventName detail:(NSDictionary *)dict;
+ (NSDictionary *) submitForResponse:(NSString *)eventName detail:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
