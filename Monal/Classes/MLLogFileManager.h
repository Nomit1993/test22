//
//  MLLogFileManager.h
//  monalxmpp
//
//  Created by tmolitor on 21.07.20.
//  Copyright © 2020 Monal.im. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MLConstants.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLLogFileManager : DDLogFileManagerDefault

-(NSString*) newLogFileName;
-(BOOL) isLogFile:(NSString*) fileName;

@end

NS_ASSUME_NONNULL_END
