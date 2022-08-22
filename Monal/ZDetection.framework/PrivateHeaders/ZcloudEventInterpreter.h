//
//  ZcloudEventInterpreter.h
//  zIPS
//
//  Created by Ryan Chazen on 2/9/14.
//  Copyright (c) 2014 Zimperium LTD All rights reserved.
//

#import <Foundation/Foundation.h>
#import "zcloud.pb.h"

@class ZThreat;
@class NSManagedObjectContext;
@interface ZcloudEventInterpreter : NSObject

+(void)processSelfMitigatingThreat:(ZThreat *)threat;
+(void)mitigateSelfMitigatingThreat:(ZThreat *)threat;
@end
