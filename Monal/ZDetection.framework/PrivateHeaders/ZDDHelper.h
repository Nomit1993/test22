//
//  ZDDHelper.h
//  ZDynamicDetection
//
//  Created by Ryan Chazen on 2020/07/13.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZDDRuleResult : NSObject

@property Boolean triggered;
@property NSString *triggerValue;
@property int timeTaken;
@property NSString  * _Nullable error;
@property NSString *forensicJson;

-(void) setFromJson:(NSString *)responseJson;

@end

@interface ZDDHelper : NSObject

+ (ZDDRuleResult*) runRuleBlocking:(NSString *)internalName;
+ (ZDDRuleResult*) runRuleBlocking:(NSString *)internalName Details:(NSDictionary*)eventDetails;
+ (void) runRuleAsync:(NSString *)internalName Details:(NSDictionary*)eventDetails callback:(void(^)(ZDDRuleResult*))callback;

@end

NS_ASSUME_NONNULL_END
