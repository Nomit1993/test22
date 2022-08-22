//
//  ZcloudCommandInterpreter.h
//  zIPS
//
//  Created by Ryan Chazen on 2/9/14.
//  Copyright (c) 2014 Zimperium LTD All rights reserved.
//

#import <Foundation/Foundation.h>
#import "zcloud.pb.h"

@interface ZcloudCommandInterpreter : NSObject

@end

void handleGeneralCommand(com::zimperium::zcloud::common::generic_command_names request_type,
                          com::zimperium::zcloud::common::zCommand &request);

void handleZipsCommand(com::zimperium::zips::zcloud::zips_command_names request_type,
                       com::zimperium::zcloud::common::zCommand &request);
