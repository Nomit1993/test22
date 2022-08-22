//
//  SworIMAppDelegate.h
//  SworIM
//
//  Created by Anurodh Pokharel on 11/16/08.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

@import UIKit;
@import PushKit;

#import "DataLayer.h"
#import "MLProcessLock.h"

@import UserNotifications;


#if !TARGET_OS_MACCATALYST
@interface MonalAppDelegate : UIResponder <UIApplicationDelegate, PKPushRegistryDelegate, UNUserNotificationCenterDelegate,UITabBarControllerDelegate,UITabBarDelegate >
#else
@interface MonalAppDelegate : UIResponder <UIApplicationDelegate, UNUserNotificationCenterDelegate >
#endif

@property (nonatomic, strong) UIWindow* window;
@property (strong, nonatomic) UITabBarController *tabBarController;
-(void) updateUnread;

-(void) handleXMPPURL:(NSURL*) url;
-(void) setActiveChatsController: (UIViewController*) activeChats;

@end

