//
//  SworIMAppDelegate.m
//  SworIM
//
//  Created by Anurodh Pokharel on 11/16/08.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

#import <BackgroundTasks/BackgroundTasks.h>
#import "MonalAppDelegate.h"
#import "CallViewController.h"
#import "MLConstants.h"
#import "HelperTools.h"
#import "MLNotificationManager.h"
#import "DataLayer.h"
#import "MLImageManager.h"
#import "ActiveChatsViewController.h"
#import "ContactsViewController.h"
#import "IPC.h"
#import "MLProcessLock.h"
#import "MLFiletransfer.h"
#import "chatViewController.h"
#import "xmpp.h"
#import "MLNotificationQueue.h"
#import "MLCalllogController.h"
#import "MLSettingsAboutViewController.h"
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#import "MLSettingsTableViewController.h"
@import NotificationBannerSwift;
#import "MLXMPPManager.h"
#import "UIColor+Theme.h"
@import FirebaseCore;
#import <AVKit/AVKit.h>

#define GRACEFUL_TIMEOUT            20.0
#define BGFETCH_GRACEFUL_TIMEOUT    60.0
typedef void (^pushCompletion)(UIBackgroundFetchResult result);
static NSString* kBackgroundFetchingTask = @"in.signals.SAI-Secure.fetch";

//@interface MonalAppDelegate()
//{
//    NSMutableDictionary* _wakeupCompletions;
//    UIBackgroundTaskIdentifier _bgTask;
//    API_AVAILABLE(ios(13.0)) BGTask* _bgFetch;
//    monal_void_block_t _backgroundTimer;
//    MLContact* _contactToOpen;
//}
@interface MonalAppDelegate()
{
    NSMutableDictionary* _wakeupCompletions;
    UIBackgroundTaskIdentifier _bgTask;
    BGTask* _bgFetch;
    monal_void_block_t _backgroundTimer;
    MLContact* _contactToOpen;
    monal_id_block_t _completionToCall;
    BOOL _shutdownPending;
    BOOL _wasFreezed;
}
@property (nonatomic, weak) ActiveChatsViewController* activeChats;
@end

@implementation MonalAppDelegate

-(id) init
{
    self = [super init];
    _bgTask = UIBackgroundTaskInvalid;
    _wakeupCompletions = [[NSMutableDictionary alloc] init];
    return self;
}

#pragma mark -  APNS notificaion

-(void) application:(UIApplication*) application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*) deviceToken
{
    NSString* token = [HelperTools stringFromToken:deviceToken];
    DDLogInfo(@"APNS token string: %@", token);
    [[MLXMPPManager sharedInstance] setPushToken:token];
}

-(void) application:(UIApplication*) application didFailToRegisterForRemoteNotificationsWithError:(NSError*) error
{
    DDLogError(@"push reg error %@", error);
}

#pragma mark - VOIP notification

#if !TARGET_OS_MACCATALYST

-(void) voipRegistration
{
    PKPushRegistry* voipRegistry = [[PKPushRegistry alloc] initWithQueue:dispatch_get_main_queue()];
    voipRegistry.delegate = self;
    voipRegistry.desiredPushTypes = [NSSet setWithObject:PKPushTypeVoIP];
}

// Handle updated APNS tokens
-(void) pushRegistry:(PKPushRegistry*) registry didUpdatePushCredentials:(PKPushCredentials*) credentials forType:(NSString*) type
{
    NSString* token = [HelperTools stringFromToken:credentials.token];
    DDLogInfo(@"APNS voip token string: %@", token);
    [[MLXMPPManager sharedInstance] setPushToken:token];
}

-(void) pushRegistry:(PKPushRegistry*) registry didInvalidatePushTokenForType:(NSString*) type
{
    DDLogInfo(@"didInvalidatePushTokenForType called (and ignored, TODO: disable push on server?)");
}

// Handle incoming pushes
-(void) pushRegistry:(PKPushRegistry*) registry didReceiveIncomingPushWithPayload:(PKPushPayload*) payload forType:(PKPushType) type withCompletionHandler:(void (^)(void)) completion
{
    DDLogInfo(@"incoming voip push notfication: %@", [payload dictionaryPayload]);
    if([UIApplication sharedApplication].applicationState == UIApplicationStateActive)
        return;
    if(@available(iOS 13.0, *))
        DDLogError(@"Voip push shouldnt arrive on ios13.");
    else
        [self incomingWakeupWithCompletionHandler:^(UIBackgroundFetchResult result) {
            completion();
        }];
}

#endif

#pragma mark - notification actions

-(void) showCallScreen:(NSNotification*) userInfo
{
//    dispatch_async(dispatch_get_main_queue(),
//                   ^{
//                       NSDictionary* contact=userInfo.object;
//                       CallViewController *callScreen= [[CallViewController alloc] initWithContact:contact];
//
//
//
//                       [self.tabBarController presentModalViewController:callNav animated:YES];
//                   });
}

-(void) updateUnread
{
    //make sure unread badge matches application badge
    NSNumber* unreadMsgCnt = [[DataLayer sharedInstance] countUnreadMessages];
    dispatch_async(dispatch_get_main_queue(), ^{
        NSInteger unread = 0;
        if(unreadMsgCnt)
            unread = [unreadMsgCnt integerValue];
        DDLogInfo(@"Updating unread badge to: %ld", (long)unread);
        [UIApplication sharedApplication].applicationIconBadgeNumber = unread;
    });
}
-(void) initiateConnectionAlive{
    NSArray* accountList = [[DataLayer sharedInstance] accountList];
    if ([accountList count] > 0){
        UserServices *Services = [[UserServices alloc] init];
        NSString *nonceKeyName = @"PresenceNonceSalt";
        NSString *userName = [NSString stringWithFormat:@"%@", [[accountList objectAtIndex:0] objectForKey:@"username"]];
        NSString *NonceSalt = [[NSUserDefaults standardUserDefaults]
                               stringForKey:nonceKeyName];
        if (NonceSalt != nil && userName != nil){
            DDLogWarn(@"Sending nonce salt present in keychains.");
            [Services SendUserPresenceWithUserName:userName salt:NonceSalt completion:^(BOOL Status, NSString * _Nullable errorMsg) {
               
            }];
        }
    }
}
#pragma mark - app life cycle

-(BOOL) application:(UIApplication*) application willFinishLaunchingWithOptions:(NSDictionary*) launchOptions
{
   // [HelperTools activityLog];
    [FIRApp configure];
    //migrate defaults db to shared app group
    if(![[HelperTools defaultsDB] boolForKey:@"DefaulsMigratedToAppGroup"])
    {
        DDLogInfo(@"Migrating [NSUserDefaults standardUserDefaults] to app group container...");
        [[HelperTools defaultsDB] setBool:[[NSUserDefaults standardUserDefaults] boolForKey:@"ChatBackgrounds"] forKey:@"ChatBackgrounds"];
        [[HelperTools defaultsDB] setBool:[[NSUserDefaults standardUserDefaults] boolForKey:@"ShowGeoLocation"] forKey:@"ShowGeoLocation"];
        [[HelperTools defaultsDB] setBool:[[NSUserDefaults standardUserDefaults] boolForKey:@"Sound"] forKey:@"Sound"];
        [[HelperTools defaultsDB] setBool:[[NSUserDefaults standardUserDefaults] boolForKey:@"SetDefaults"] forKey:@"SetDefaults"];
        [[HelperTools defaultsDB] setBool:[[NSUserDefaults standardUserDefaults] boolForKey:@"HasSeenIntro"] forKey:@"HasSeenIntro"];
        [[HelperTools defaultsDB] setBool:[[NSUserDefaults standardUserDefaults] boolForKey:@"HasSeenLogin"] forKey:@"HasSeenLogin"];
        [[HelperTools defaultsDB] setBool:[[NSUserDefaults standardUserDefaults] boolForKey:@"ShowImages"] forKey:@"ShowImages"];
        [[HelperTools defaultsDB] setBool:[[NSUserDefaults standardUserDefaults] boolForKey:@"HasUpgradedPushiOS13"] forKey:@"HasUpgradedPushiOS13"];
        [[HelperTools defaultsDB] setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"BackgroundImage"] forKey:@"BackgroundImage"];
        [[HelperTools defaultsDB] setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"AlertSoundFile"] forKey:@"AlertSoundFile"];
        
        [[HelperTools defaultsDB] setBool:YES forKey:@"DefaulsMigratedToAppGroup"];
        [[HelperTools defaultsDB] synchronize];
        DDLogInfo(@"Migration complete and written to disk");
    }
    DDLogInfo(@"App launching with options: %@", launchOptions);
    
    //init IPC and ProcessLock
    [IPC initializeForProcess:@"MainApp"];
    
    //lock process and disconnect an already running NotificationServiceExtension
    [MLProcessLock lock];
    [[IPC sharedInstance] sendMessage:@"Monal.disconnectAll" withData:nil to:@"NotificationServiceExtension"];
    
    //do MLFiletransfer cleanup tasks (do this in a new thread to parallelize it with our ping to the appex and don't slow down app startup)
    //this will also migrate our old image cache to new MLFiletransfer cache
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [MLFiletransfer doStartupCleanup];
    });
    
    //only proceed with launching if the NotificationServiceExtension is *not* running
    if([MLProcessLock checkRemoteRunning:@"NotificationServiceExtension"])
    {
        DDLogInfo(@"NotificationServiceExtension is running, waiting for its termination");
        [MLProcessLock waitForRemoteTermination:@"NotificationServiceExtension" withLoopHandler:^{
            [[IPC sharedInstance] sendMessage:@"Monal.disconnectAll" withData:nil to:@"NotificationServiceExtension"];
        }];
    }
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(handletabbatColorAppearance:) name:kMonalrefreshTabController object:nil];
    return YES;
}

- (BOOL)application:(UIApplication*) application didFinishLaunchingWithOptions:(NSDictionary*) launchOptions
{
    //this will use the cached values in defaultsDB, if possible
    
    [[MLXMPPManager sharedInstance] setPushToken:nil];
    [self setupTabBarViewController];
    
       if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
          {
             // self.window.rootViewController = rootViewController;
          }else
          {
              self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
              self.window.rootViewController = self.tabBarController;

           }

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scheduleBackgroundFetchingTask) name:kScheduleBackgroundFetchingTask object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nowIdle:) name:kMonalIdle object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(filetransfersNowIdle:) name:kMonalFiletransfersIdle object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showMessageStatus:) name:kgroupMessageWarning object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showConnectionStatus:) name:kXMPPError object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUnread) name:kMonalNewMessageNotice object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUnread) name:kMonalUpdateUnread object:nil];
    
    UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate = self;
    
    //create notification categories with actions
    UNNotificationAction* replyAction = [UNTextInputNotificationAction
        actionWithIdentifier:@"REPLY_ACTION"
        title:NSLocalizedString(@"Reply", @"")
        options:UNNotificationActionOptionNone
        textInputButtonTitle:NSLocalizedString(@"Send", @"")
        textInputPlaceholder:NSLocalizedString(@"Your answer", @"")
    ];
    UNNotificationAction* markAsReadAction = [UNNotificationAction
        actionWithIdentifier:@"MARK_AS_READ_ACTION"
        title:NSLocalizedString(@"Mark as read", @"")
        options:UNNotificationActionOptionNone
    ];
    UNNotificationCategory* messageCategory;
    UNAuthorizationOptions authOptions = UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionCriticalAlert;
    if(@available(iOS 13.0, *))
    {
        messageCategory = [UNNotificationCategory
            categoryWithIdentifier:@"message"
            actions:@[replyAction, markAsReadAction]
            intentIdentifiers:@[]
            options:UNNotificationCategoryOptionAllowAnnouncement
        ];
        
        //ios 13 has support for UNAuthorizationOptionAnnouncement
        authOptions = authOptions | UNAuthorizationOptionAnnouncement;
    }
    else
    {
        messageCategory = [UNNotificationCategory
            categoryWithIdentifier:@"message"
            actions:@[replyAction, markAsReadAction]
            intentIdentifiers:@[]
            options:UNNotificationCategoryOptionNone
        ];
    }
    [self initiateConnectionAlive];
    //request auth to show notifications and register our notification categories created above
    [center requestAuthorizationWithOptions:authOptions completionHandler:^(BOOL granted, NSError* error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            DDLogInfo(@"Got local notification authorization response: granted=%@, error=%@", granted ? @"YES" : @"NO", error);
            BOOL oldGranted = [[HelperTools defaultsDB] boolForKey:@"notificationsGranted"];
            [[HelperTools defaultsDB] setBool:granted forKey:@"notificationsGranted"];
            if(granted == YES)
            {
                if(!oldGranted)
                {
                    //this is only needed for better UI (settings --> noifications should reflect the proper state)
                    //both invalidations are needed because we don't know the timing of this notification granting handler
                    DDLogInfo(@"Invalidating all account states...");
                    [[DataLayer sharedInstance] invalidateAllAccountStates];        //invalidate states for account objects not yet created
                    [[MLXMPPManager sharedInstance] reconnectAll];                  //invalidate for account objects already created
                }
                
                //activate push
                if(@available(iOS 13.0, *))
                {
                    DDLogInfo(@"Registering for APNS...");
                    [[UIApplication sharedApplication] registerForRemoteNotifications];
                }
                else
                {
#if !TARGET_OS_MACCATALYST
                    DDLogInfo(@"Registering for VoIP APNS...");
                    [self voipRegistration];
#endif
                }
            }
            else
            {
                //delete apns push token --> push will not be registered on our xmpp server anymore
                DDLogWarn(@"Notifications disabled --> deleting APNS push token from user defaults!");
                NSString* oldToken = [[HelperTools defaultsDB] objectForKey:@"pushToken"];
                [[HelperTools defaultsDB] removeObjectForKey:@"pushToken"];
                [[MLXMPPManager sharedInstance] setPushToken:nil];
                
                //unregister from push appserver
                if((oldToken != nil && oldToken.length != 0) || oldGranted)
                {
                    DDLogWarn(@"Unregistering node from appserver!");
                    [self unregisterPush];
                    
                    //this is only needed for better UI (settings --> noifications should reflect the proper state)
                    //both invalidations are needed because we don't know the timing of this notification granting handler
                    DDLogInfo(@"Invalidating all account states...");
                    [[DataLayer sharedInstance] invalidateAllAccountStates];        //invalidate states for account objects not yet created
                    [[MLXMPPManager sharedInstance] reconnectAll];                  //invalidate for account objects already created
                }
            }
        });
    }];
    [center setNotificationCategories:[NSSet setWithObjects:messageCategory, nil]];

    if (@available(iOS 13.0, *))
    {
        UINavigationBarAppearance* appearance = [[UINavigationBarAppearance alloc] init];
        [appearance configureWithTransparentBackground];
        appearance.backgroundColor = [UIColor systemBackgroundColor];
        
        [[UINavigationBar appearance] setScrollEdgeAppearance:appearance];
        [[UINavigationBar appearance] setStandardAppearance:appearance];
#if TARGET_OS_MACCATALYST
        self.window.windowScene.titlebar.titleVisibility = UITitlebarTitleVisibilityHidden;
#else
        [[UITabBar appearance] setTintColor:[UIColor monaldarkGreen]];
        [[UINavigationBar appearance] setTintColor:[UIColor monalGreen]];
#endif
    }
    [[UINavigationBar appearance] setPrefersLargeTitles:YES];

    //handle message notifications by initializing the MLNotificationManager
    [MLNotificationManager sharedInstance];
    
    //register BGTask
    if(@available(iOS 13.0, *))
    {
        DDLogInfo(@"calling MonalAppDelegate configureBackgroundFetchingTask");
        [self configureBackgroundFetchingTask];
    }
    // Play audio even if phone is in silent mode
    NSError* audioSessionError;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&audioSessionError];
    if(audioSessionError != nil)
    {
        DDLogWarn(@"Couldn't set AVAudioSession to AVAudioSessionCategoryPlayback: %@", audioSessionError);
    }

    NSDictionary* infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString* version = [infoDict objectForKey:@"CFBundleShortVersionString"];
    NSString* buildDate = [NSString stringWithUTF8String:__DATE__];
    NSString* buildTime = [NSString stringWithUTF8String:__TIME__];
    DDLogInfo(@"App started: %@", [NSString stringWithFormat:NSLocalizedString(@"Version %@ (%@ %@ UTC)", @""), version, buildDate, buildTime]);
    
    //init background/foreground status
    //this has to be done here to make sure we have the correct state when he app got started through notification quick actions
    if([UIApplication sharedApplication].applicationState==UIApplicationStateBackground)
        [[MLXMPPManager sharedInstance] nowBackgrounded];
    else
        [[MLXMPPManager sharedInstance] nowForegrounded];
    
    //should any accounts connect?
    [self connectIfNecessary];
    
    //For Setting Theme Mode
    if ([[HelperTools defaultsDB] boolForKey:@"darkModeEnable"]) {
          [self.window setOverrideUserInterfaceStyle:UIUserInterfaceStyleDark];
      } else {
          [self.window setOverrideUserInterfaceStyle:UIUserInterfaceStyleLight];
      }

    //handle IPC messages (this should be done *after* calling connectIfNecessary to make sure any disconnectAll messages are handled properly
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(incomingIPC:) name:kMonalIncomingIPC object:nil];
    
#if TARGET_OS_MACCATALYST
    //handle catalyst foregrounding/backgrounding of window
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowHandling:) name:@"NSWindowDidResignKeyNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowHandling:) name:@"NSWindowDidBecomeKeyNotification" object:nil];
#endif

    return YES;
}

#if TARGET_OS_MACCATALYST
-(void) windowHandling:(NSNotification*) notification
{
    if([notification.name isEqualToString:@"NSWindowDidResignKeyNotification"])
    {
        DDLogInfo(@"Window lost focus (key window)...");
        [self updateUnread];
        if(NSProcessInfo.processInfo.isLowPowerModeEnabled)
        {
            DDLogInfo(@"LowPowerMode is active: nowReallyBackgrounded to reduce power consumption");
            [self nowReallyBackgrounded];
        }
        else
            [[MLXMPPManager sharedInstance] noLongerInFocus];
    }
    else if([notification.name isEqualToString:@"NSWindowDidBecomeKeyNotification"])
    {
        DDLogInfo(@"Window got focus (key window)...");
        @synchronized(self) {
            DDLogVerbose(@"Setting _shutdownPending to NO...");
            _shutdownPending = NO;
        }
        [self addBackgroundTask];
        [[MLXMPPManager sharedInstance] nowForegrounded];
    }
}
#endif

-(void) incomingIPC:(NSNotification*) notification
{
    NSDictionary* message = notification.userInfo;
    //another process tells us to disconnect all accounts
    //this could happen if we are connecting (or even connected) in the background and the NotificationServiceExtension got started
    //BUT: only do this if we are in background (we should never receive this if we are foregrounded)
    if([message[@"name"] isEqualToString:@"Monal.disconnectAll"])
    {
        DDLogInfo(@"Got disconnectAll IPC message");
        NSAssert([HelperTools isInBackground]==YES, @"Got 'Monal.disconnectAll' while in foreground. This should NEVER happen!");
        //disconnect all (currently connecting or already connected) accounts
        [[MLXMPPManager sharedInstance] disconnectAll];
    }
    else if([message[@"name"] isEqualToString:@"Monal.connectIfNecessary"])
    {
        DDLogInfo(@"Got connectIfNecessary IPC message");
        //(re)connect all accounts
        [self connectIfNecessary];
    }
}

-(void) applicationDidBecomeActive:(UIApplication*) application
{
    //[UIApplication sharedApplication].applicationIconBadgeNumber=0;
}

-(void) setActiveChatsController: (UIViewController*) activeChats
{
    self.activeChats = (ActiveChatsViewController*)activeChats;
    [self openChatOfContact:_contactToOpen];
}

-(void) unregisterPush
{
    NSString* node = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSString* api_url = [NSString stringWithFormat:@"%@/v1/unregister", [HelperTools pushServer][@"url"]];
    
    NSString* post = [NSString stringWithFormat:@"type=apns&node=%@", [node stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
    NSData* postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString* postLength = [NSString stringWithFormat:@"%luld",[postData length]];
    
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:api_url]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            NSHTTPURLResponse* httpresponse = (NSHTTPURLResponse*)response;
            if(!error && httpresponse.statusCode < 400)
            {
                DDLogInfo(@"connection to push api %@ successful(%ld)", api_url, httpresponse.statusCode);
                NSString* responseBody = [[NSString alloc] initWithData:data  encoding:NSUTF8StringEncoding];
                DDLogInfo(@"push api returned: %@", responseBody);
                NSArray* responseParts=[responseBody componentsSeparatedByString:@"\n"];
                if(responseParts.count>0)
                {
                    if([responseParts[0] isEqualToString:@"OK"] )
                        DDLogInfo(@"push api: unregistered ok");
                    else
                        DDLogError(@"push api returned invalid data: %@", [responseParts componentsJoinedByString: @" | "]);
                }
                else
                    DDLogError(@"push api response could not be broken into parts");
            }
            else
                DDLogError(@"connection to push api %@ NOT successful(%ld): %@", api_url, httpresponse.statusCode, error);
        }] resume];
    });
}

#pragma mark - handling urls

/**
 xmpp:romeo@montague.net?message;subject=Test%20Message;body=Here%27s%20a%20test%20message
          or
 xmpp:coven@chat.shakespeare.lit?join;password=cauldronburn
         
 @link https://xmpp.org/extensions/xep-0147.html
 */
-(void) handleXMPPURL:(NSURL*) url
{
    //TODO just uses fist account. maybe change in the future
    xmpp* account = [[MLXMPPManager sharedInstance].connectedXMPP firstObject];
    if(account)
    {
        NSURLComponents* components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
        NSString* jid = components.path;
        BOOL isGroup = NO;
        
        for(NSURLQueryItem* item in components.queryItems)
        {
            if([item.name isEqualToString:@"join"])
                isGroup = YES;
        }
        
        if(isGroup)
            [account joinMuc:jid];
        
        [[DataLayer sharedInstance] addActiveBuddies:jid forAccount:account.accountNo];
        MLContact* contact = [MLContact createContactFromJid:jid andAccountNo:account.accountNo];
        [self openChatOfContact:contact];
    }
}

-(BOOL) application:(UIApplication*) app openURL:(NSURL*) url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id>*) options
{
    if([url.scheme isEqualToString:@"xmpp"])                //for xmpp uris
    {
        [self handleXMPPURL:url];
        return YES;
    }
    else if([url.scheme isEqualToString:@"monalOpen"])      //app opened via sharesheet
    {
        //make sure our outbox content is sent (if the mainapp is still connected and also was in foreground while the sharesheet was used)
        //and open the chat the newest outbox entry was sent to
        MLContact* lastRecipientContact = [[MLXMPPManager sharedInstance] sendAllOutboxes];
        [[DataLayer sharedInstance] addActiveBuddies:lastRecipientContact.contactJid forAccount:lastRecipientContact.accountId];
        DDLogVerbose(@"Trying to open chat for %@", lastRecipientContact.contactJid);
        [self openChatOfContact:lastRecipientContact];
        return YES;
    }
    return NO;
}

#pragma mark  - user notifications

-(void) application:(UIApplication*) application didReceiveRemoteNotification:(NSDictionary*) userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result)) completionHandler
{
    DDLogVerbose(@"got didReceiveRemoteNotification: %@", userInfo);
    [self incomingWakeupWithCompletionHandler:completionHandler];
}
 
- (void)userNotificationCenter:(UNUserNotificationCenter*) center willPresentNotification:(UNNotification*) notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options)) completionHandler;
{
    DDLogInfo(@"userNotificationCenter:willPresentNotification:withCompletionHandler called");
    //show local notifications while the app is open and ignore remote pushes
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        completionHandler(UNNotificationPresentationOptionNone);
    } else {
        completionHandler(UNNotificationPresentationOptionAlert);
    }
}

-(void) userNotificationCenter:(UNUserNotificationCenter*) center didReceiveNotificationResponse:(UNNotificationResponse*) response withCompletionHandler:(void (^)(void)) completionHandler
{
    if([response.notification.request.content.categoryIdentifier isEqualToString:@"message"])
    {
        DDLogVerbose(@"notification action '%@' triggered for %@", response.actionIdentifier, response.notification.request.content.userInfo);
        [[IPC sharedInstance] sendMessage:@"Monal.disconnectAll" withData:nil to:@"NotificationServiceExtension"];
        //add our completion handler to handler queue
        [self incomingWakeupWithCompletionHandler:^(UIBackgroundFetchResult result) {
            completionHandler();
        }];
        
        MLContact* fromContact = [MLContact createContactFromJid:response.notification.request.content.userInfo[@"fromContactJid"] andAccountNo:response.notification.request.content.userInfo[@"fromContactAccountId"]];
        NSString* messageId = response.notification.request.content.userInfo[@"messageId"];
        xmpp* account = [[MLXMPPManager sharedInstance] getConnectedAccountForID:fromContact.accountId];
        NSAssert(fromContact, @"fromContact should not be nil");
        NSAssert(messageId, @"messageId should not be nil");
        NSAssert(account, @"account should not be nil");
        
        //make sure we have an active buddy for this chat
        [[DataLayer sharedInstance] addActiveBuddies:fromContact.contactJid forAccount:fromContact.accountId];
        
        //handle message actions
        if([response.actionIdentifier isEqualToString:@"REPLY_ACTION"])
        {
            DDLogInfo(@"REPLY_ACTION triggered...");
            UNTextInputNotificationResponse* textResponse = (UNTextInputNotificationResponse*) response;
            if(!textResponse.userText.length)
            {
                DDLogWarn(@"User tried to send empty text response!");
                return;
            }
            
            //mark messages as read because we are replying
            NSArray* unread = [[DataLayer sharedInstance] markMessagesAsReadForBuddy:fromContact.contactJid andAccount:fromContact.accountId tillStanzaId:messageId wasOutgoing:NO];
            DDLogDebug(@"Marked as read: %@", unread);
            
            //remove notifications of all read messages (this will cause the MLNotificationManager to update the app badge, too)
            [[MLNotificationQueue currentQueue] postNotificationName:kMonalDisplayedMessagesNotice object:account userInfo:@{@"messagesArray":unread}];
            
            //update unread count in active chats list
            [fromContact refresh];      //this will make sure the unread count is correct
            [[MLNotificationQueue currentQueue] postNotificationName:kMonalContactRefresh object:account userInfo:@{
                @"contact": fromContact
            }];
            
            BOOL encrypted = [[DataLayer sharedInstance] shouldEncryptForJid:fromContact.contactJid andAccountNo:fromContact.accountId];
            [[MLXMPPManager sharedInstance] sendMessageAndAddToHistory:textResponse.userText toContact:fromContact isEncrypted:encrypted isUpload:NO withCompletionHandler:^(BOOL successSendObject, NSString* messageIdSentObject) {
                DDLogInfo(@"REPLY_ACTION success=%@, messageIdSentObject=%@", successSendObject ? @"YES" : @"NO", messageIdSentObject);
            }];
        }
        else if([response.actionIdentifier isEqualToString:@"MARK_AS_READ_ACTION"])
        {
            DDLogInfo(@"MARK_AS_READ_ACTION triggered...");
            NSArray* unread = [[DataLayer sharedInstance] markMessagesAsReadForBuddy:fromContact.contactJid andAccount:fromContact.accountId tillStanzaId:messageId wasOutgoing:NO];
            DDLogDebug(@"Marked as read: %@", unread);
            
            //send displayed marker for last unread message (XEP-0333)
            //but only for 1:1 or group-type mucs,not for channe-type mucs (privacy etc.)
            MLMessage* lastUnreadMessage = [unread lastObject];
            if(lastUnreadMessage && (!fromContact.isGroup || [@"group" isEqualToString:fromContact.mucType]))
            {
                DDLogDebug(@"Sending XEP-0333 displayed marker for message '%@'", lastUnreadMessage.messageId);
                [account sendDisplayMarkerForMessage:lastUnreadMessage];
            }
            
            //remove notifications of all read messages (this will cause the MLNotificationManager to update the app badge, too)
            [[MLNotificationQueue currentQueue] postNotificationName:kMonalDisplayedMessagesNotice object:account userInfo:@{@"messagesArray":unread}];
            
            //update unread count in active chats list
            [fromContact refresh];      //this will make sure the unread count is correct
            [[MLNotificationQueue currentQueue] postNotificationName:kMonalContactRefresh object:account userInfo:@{
                @"contact": fromContact
            }];
        }
        else if([response.actionIdentifier isEqualToString:@"com.apple.UNNotificationDefaultActionIdentifier"])     //open chat of this contact
            [self openChatOfContact:fromContact];
    }
    else
    {
        //call completion handler directly (we did not handle anything and no connectIfNecessary was called)
        if(completionHandler)
            completionHandler();
    }
}

-(void) openChatOfContact:(MLContact* _Nullable) contact
{
    if (contact == nil){
        return ;
    }
    if(contact != nil)
        _contactToOpen = contact;
    
    if(self.activeChats != nil && _contactToOpen != nil)
    {
        // the timer makes sure the view is properly initialized when opning the chat
        createTimer(0.5, (^{
            dispatch_async(dispatch_get_main_queue(), ^{
                if(_contactToOpen != nil)
                {
                    DDLogDebug(@"Opening chat for contact %@", [contact contactJid]);
                    // open new chat
                    [(ActiveChatsViewController*)self.activeChats presentChatWithContact:_contactToOpen];
                }
                else
                    DDLogDebug(@"_contactToOpen changed to nil, not opening chat for contact %@", [contact contactJid]);
                _contactToOpen = nil;
            });
        }));
    }
    else
        DDLogDebug(@"Not opening chat for contact %@", [contact contactJid]);
}

#pragma mark - memory
-(void) applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    [[MLImageManager sharedInstance] purgeCache];
}

#pragma mark - backgrounding
-(void) startBackgroundTimer:(double) timeout
{
    //cancel old background timer if still running and start a new one
    //this timer will fire after timeout seconds in background and disconnect gracefully (e.g. when fully idle the next time)
    if(_backgroundTimer)
        _backgroundTimer();
    _backgroundTimer = createTimer(timeout, ^{
        //mark timer as *not* running
        self->_backgroundTimer = nil;
        //retry background check (now handling idle state because no running background timer is blocking it)
        dispatch_async(dispatch_get_main_queue(), ^{
            [self checkIfBackgroundTaskIsStillNeeded];
        });
    });
}

-(void) nowReallyBackgrounded
{
    [self addBackgroundTask];
    [[MLXMPPManager sharedInstance] nowBackgrounded];
    [self startBackgroundTimer:GRACEFUL_TIMEOUT];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self checkIfBackgroundTaskIsStillNeeded];
    });
}
//-(void) startBackgroundTimer
//{
//    //cancel old background timer if still running and start a new one
//    //this timer will fire after GRACEFUL_TIMEOUT seconds in background and disconnect gracefully (e.g. when fully idle the next time)
//    if(_backgroundTimer)
//        _backgroundTimer();
//    _backgroundTimer = createTimer(GRACEFUL_TIMEOUT, ^{
//        //mark timer as *not* running
//        _backgroundTimer = nil;
//        //retry background check (now handling idle state because no running background timer is blocking it)
//        [self checkIfBackgroundTaskIsStillNeeded];
//    });
//}

-(void) stopBackgroundTimer
{
    if(_backgroundTimer)
        _backgroundTimer();
    _backgroundTimer = nil;
}

-(void) applicationWillEnterForeground:(UIApplication *)application
{
    DDLogInfo(@"Entering FG");
    
    //TODO: show "loading..." animation/modal
    [self initiateConnectionAlive];
    //only proceed with foregrounding if the NotificationServiceExtension is not running
    [[IPC sharedInstance] sendMessage:@"Monal.disconnectAll" withData:nil to:@"NotificationServiceExtension"];
    if([MLProcessLock checkRemoteRunning:@"NotificationServiceExtension"])
    {
        DDLogInfo(@"NotificationServiceExtension is running, waiting for its termination");
        [MLProcessLock waitForRemoteTermination:@"NotificationServiceExtension" withLoopHandler:^{
            [[IPC sharedInstance] sendMessage:@"Monal.disconnectAll" withData:nil to:@"NotificationServiceExtension"];
        }];
    }
    
    //trigger view updates (this has to be done because the NotificationServiceExtension could have updated the database some time ago)
    [[MLNotificationQueue currentQueue] postNotificationName:kMonalRefresh object:self userInfo:nil];
    
    //cancel already running background timer, we are now foregrounded again
    [self stopBackgroundTimer];
    
    [self addBackgroundTask];
    [[MLXMPPManager sharedInstance] nowForegrounded];
}

-(void) applicationWillResignActive:(UIApplication *)application
{
}

-(void) applicationDidEnterBackground:(UIApplication*) application
{
    UIApplicationState state = [application applicationState];
    if(state == UIApplicationStateInactive)
        DDLogInfo(@"Screen lock / incoming call");
    else if(state == UIApplicationStateBackground)
        DDLogInfo(@"Entering BG");
    
    [self updateUnread];
#if TARGET_OS_MACCATALYST
    if(NSProcessInfo.processInfo.isLowPowerModeEnabled)
    {
        DDLogInfo(@"LowPowerMode is active: nowReallyBackgrounded to reduce power consumption");
        [self nowReallyBackgrounded];
    }
    else
        [[MLXMPPManager sharedInstance] noLongerInFocus];
#else
    [self nowReallyBackgrounded];
#endif
}

-(void) applicationWillTerminate:(UIApplication *)application
{
    @synchronized(self) {
        DDLogVerbose(@"Setting _shutdownPending to YES...");
        _shutdownPending = YES;
        DDLogWarn(@"|~~| T E R M I N A T I N G |~~|");
        [self scheduleBackgroundFetchingTask:YES];        //make sure delivery will be attempted, if needed (force as soon as possible)
        DDLogInfo(@"|~~| 20%% |~~|");
        [self updateUnread];
        DDLogInfo(@"|~~| 40%% |~~|");
        [[HelperTools defaultsDB] synchronize];
        DDLogInfo(@"|~~| 60%% |~~|");
        [[MLXMPPManager sharedInstance] nowBackgrounded];
        DDLogInfo(@"|~~| 80%% |~~|");
        [HelperTools updateSyncErrorsWithDeleteOnly:NO andWaitForCompletion:YES];
        DDLogInfo(@"|~~| 100%% |~~|");
        [[MLXMPPManager sharedInstance] disconnectAll];
        DDLogInfo(@"|~~| T E R M I N A T E D |~~|");
        [DDLog flushLog];
    }
}


-(void) setupTabBarViewController{
    //activeVC
    self.tabBarController = [[UITabBarController alloc] init];
     UIStoryboard *main = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
     ActiveChatsViewController* chatVC = [main instantiateViewControllerWithIdentifier:@"activeVC"];
    chatVC.tabBarItem.image = [UIImage imageNamed:@"chats"];
    chatVC.tabBarItem.selectedImage = [UIImage imageNamed:@"selectedChats"];
    chatVC.title = @"Chats";
    MLCalllogController *callsVC = [main instantiateViewControllerWithIdentifier:@"callsVC"];
    callsVC.tabBarItem.image = [UIImage imageNamed:@"call_unselected"];
    callsVC.tabBarItem.selectedImage = [UIImage imageNamed:@"call"];
    callsVC.title = @"Calls";
    UINavigationController *CallsNav = [[UINavigationController alloc]
                                             initWithRootViewController:callsVC];
    UINavigationController *ConversationNav = [[UINavigationController alloc]
                                             initWithRootViewController:chatVC];
    ContactsViewController *contacts = [main instantiateViewControllerWithIdentifier:@"ContactsVC"];
    contacts.tabBarItem.image = [UIImage imageNamed:@"contact-book"];
    contacts.tabBarItem.selectedImage = [UIImage imageNamed:@"contacts"];
    contacts.title = @"Contacts";
    contacts.selectTabContact = ^(MLContact* selectedContact) {
        //UIStoryboard *main = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.tabBarController.selectedIndex = 0;
             chatViewController* messageVC = [main instantiateViewControllerWithIdentifier:@"chatViewController"];

             [messageVC setupWithContact:selectedContact];

    //        UIBarButtonItem* barButtonItem = [[UIBarButtonItem alloc] initWithTitle:Nil style:UIBarButtonItemStylePlain target:nil action:nil];
    //        ConversationNav.navigationItem.backBarButtonItem = barButtonItem;
            messageVC.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc ]initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:nil];
            chatVC.title = @"";
            [ConversationNav pushViewController:messageVC animated:YES];
        });
     

    };
    
    UINavigationController *contactsNav = [[UINavigationController alloc] initWithRootViewController:contacts];
    
    UIStoryboard *settings = [UIStoryboard storyboardWithName:@"Settings" bundle:nil];
    MLSettingsTableViewController *settingsVC = [settings instantiateViewControllerWithIdentifier:@"settingsVC"];
    settingsVC.tabBarItem.image = [UIImage imageNamed:@"settings"];
    UINavigationController *settingNav = [[UINavigationController alloc]
                                             initWithRootViewController:settingsVC];
    NSArray* controllers = [NSArray arrayWithObjects:ConversationNav,CallsNav,contactsNav,settingNav, nil];
    self.tabBarController.viewControllers = controllers;
    self.tabBarController.delegate = self;

 //435A64
  
}

-(void) handletabbatColorAppearance:(NSNotification *)notification{
   
    if ([[HelperTools defaultsDB] boolForKey:@"darkModeEnable"]){
            //is dark
        [[UITabBar appearance] setBackgroundColor:UIColorFromRGB(0x161618)];
        [[UITabBar appearance] setUnselectedItemTintColor:[UIColor whiteColor]];
        //[[UITabBar appearance] setBarTintColor:UIColorFromRGB(0x34B7F1)];
    }else{

        //is light
        [[UITabBar appearance] setBackgroundColor:UIColorFromRGB(0xE4E6EB)];
        [[UITabBar appearance] setUnselectedItemTintColor:[UIColor blackColor]];
    }
   
     
    
}

#pragma mark - error feedback

-(void) showMessageStatus:(NSNotification*) notification
{
    //this will show an error banner but only if our app is foregrounded
//        dispatch_async(dispatch_get_main_queue(), ^{
//
//            NotificationBanner* banner = [[NotificationBanner alloc] initWithTitle:@"Waiting for the group messages" subtitle:@"Please don't close or terminate the application , otherwise msgs will be skipped ." leftView:nil rightView:nil style:BannerStyleWarning colors: nil];
//            banner.duration = 10.0;     //show for 10 seconds to make sure users can read it
//            NotificationBannerQueue* queue = [[NotificationBannerQueue alloc] initWithMaxBannersOnScreenSimultaneously:2];
//            [banner showWithQueuePosition:QueuePositionBack bannerPosition:BannerPositionTop queue:queue on:nil];
//        });

}
-(void) showConnectionStatus:(NSNotification*) notification
{
    //this will show an error banner but only if our app is foregrounded
    if(![HelperTools isNotInFocus])
    {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            xmpp* xmppAccount = notification.object;
//            if(![notification.userInfo[@"isSevere"] boolValue])
//                DDLogError(@"Minor XMPP Error(%@): %@", xmppAccount.connectionProperties.identity.user, notification.userInfo[@"message"]);
//            NSString *message_Info = notification.userInfo[@"message"];
//            if ([message_Info containsString:@"Invalid Username or password"]){
//                NotificationBanner* banner = [[NotificationBanner alloc] initWithTitle:xmppAccount.connectionProperties.identity.user subtitle:@"This may take a while, Connecting......." leftView:nil rightView:nil style:([notification.userInfo[@"isSevere"] boolValue] ? BannerStyleDanger : BannerStyleWarning) colors:nil];
//                banner.duration = 10.0;     //show for 10 seconds to make sure users can read it
//                NotificationBannerQueue* queue = [[NotificationBannerQueue alloc] initWithMaxBannersOnScreenSimultaneously:2];
//                [banner showWithQueuePosition:QueuePositionBack bannerPosition:BannerPositionTop queue:queue on:nil];
//            }else{
//                NotificationBanner* banner = [[NotificationBanner alloc] initWithTitle:xmppAccount.connectionProperties.identity.user subtitle:notification.userInfo[@"message"] leftView:nil rightView:nil style:([notification.userInfo[@"isSevere"] boolValue] ? BannerStyleDanger : BannerStyleWarning) colors:nil];
//                banner.duration = 10.0;     //show for 10 seconds to make sure users can read it
//                NotificationBannerQueue* queue = [[NotificationBannerQueue alloc] initWithMaxBannersOnScreenSimultaneously:2];
//                [banner showWithQueuePosition:QueuePositionBack bannerPosition:BannerPositionTop queue:queue on:nil];
//            }
//
//        });
    }
}

#pragma mark - mac menu
-(void) buildMenuWithBuilder:(id<UIMenuBuilder>) builder
{
    [super buildMenuWithBuilder:builder];
    if (@available(iOS 13.0, *)) {
        //monal
        UIKeyCommand* preferencesCommand = [UIKeyCommand commandWithTitle:@"Preferences..." image:nil action:@selector(showSettings) input:@"," modifierFlags:UIKeyModifierCommand propertyList:nil];

        UIMenu* preferencesMenu = [UIMenu menuWithTitle:@"" image:nil identifier:@"im.monal.preferences" options:UIMenuOptionsDisplayInline children:@[preferencesCommand]];
        [builder insertSiblingMenu:preferencesMenu afterMenuForIdentifier:UIMenuAbout];

        //file
        UIKeyCommand* newCommand = [UIKeyCommand commandWithTitle:@"New Message" image:nil action:@selector(showNew) input:@"N" modifierFlags:UIKeyModifierCommand propertyList:nil];

        UIMenu* newMenu = [UIMenu menuWithTitle:@"" image:nil identifier:@"im.monal.new" options:UIMenuOptionsDisplayInline children:@[newCommand]];
        [builder insertChildMenu:newMenu atStartOfMenuForIdentifier:UIMenuFile];

        UIKeyCommand* detailsCommand = [UIKeyCommand commandWithTitle:@"Details..." image:nil action:@selector(showDetails) input:@"I" modifierFlags:UIKeyModifierCommand propertyList:nil];

        UIMenu* detailsMenu = [UIMenu menuWithTitle:@"" image:nil identifier:@"im.monal.detail" options:UIMenuOptionsDisplayInline children:@[detailsCommand]];
        [builder insertSiblingMenu:detailsMenu afterMenuForIdentifier:@"im.monal.new"];

        UIKeyCommand* deleteCommand = [UIKeyCommand commandWithTitle:@"Delete Conversation" image:nil action:@selector(deleteConversation) input:@"\b" modifierFlags:UIKeyModifierCommand propertyList:nil];

        UIMenu* deleteMenu = [UIMenu menuWithTitle:@"" image:nil identifier:@"im.monal.delete" options:UIMenuOptionsDisplayInline children:@[deleteCommand]];
        [builder insertSiblingMenu:deleteMenu afterMenuForIdentifier:@"im.monal.detail"];

        [builder removeMenuForIdentifier:UIMenuHelp];

        [builder replaceChildrenOfMenuForIdentifier:UIMenuAbout fromChildrenBlock:^NSArray<UIMenuElement *> * _Nonnull(NSArray<UIMenuElement *> * _Nonnull items) {
            UICommand* itemCommand = (UICommand*)items.firstObject;
            UICommand* aboutCommand = [UICommand commandWithTitle:itemCommand.title image:nil action:@selector(aboutWindow) propertyList:nil];
            NSArray* menuItems = @[aboutCommand];
            return menuItems;
        }];
    }
}

-(void) aboutWindow
{
    UIStoryboard* settingStoryBoard = [UIStoryboard storyboardWithName:@"Settings" bundle:nil];
    MLSettingsAboutViewController* settingAboutViewController = [settingStoryBoard instantiateViewControllerWithIdentifier:@"SettingsAboutViewController"];
    UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController:settingAboutViewController];
    [self.window.rootViewController presentViewController:navigationController animated:NO completion:nil];
}

-(void) showNew
{
    [self.activeChats showContacts];
}

-(void) deleteConversation
{
    [self.activeChats deleteConversation];
}

-(void) showSettings
{
    [self.activeChats showSettings];
}

-(void) showDetails
{
    [self.activeChats showDetails];
}

#pragma mark - background tasks

-(void) nowIdle:(NSNotification*) notification
{
    DDLogInfo(@"### SOME ACCOUNT CHANGED TO IDLE STATE ###");
    [self checkIfBackgroundTaskIsStillNeeded];
}

-(void) filetransfersNowIdle:(NSNotification*) notification
{
    DDLogInfo(@"### FILETRANSFERS CHANGED TO IDLE STATE ###");
    [self checkIfBackgroundTaskIsStillNeeded];
}

-(void) checkIfBackgroundTaskIsStillNeeded
{
    if([[MLXMPPManager sharedInstance] allAccountsIdle] && [MLFiletransfer isIdle])
    {
        DDLogInfo(@"### ALL ACCOUNTS IDLE AND FILETRANSFERS COMPLETE NOW ###");
        [HelperTools updateSyncErrorsWithDeleteOnly:NO andWaitForCompletion:YES];
        
        //hide spinner
       // [self.activeChats.spinner stopAnimating];
        
        //use a synchronized block to disconnect only once
        @synchronized(self) {
            if(_backgroundTimer != nil || [_wakeupCompletions count] > 0)
            {
                DDLogInfo(@"### ignoring idle state because background timer or wakeup completion timers are still running ###");
                return;
            }
            if(_shutdownPending)
            {
                DDLogInfo(@"### ignoring idle state because a shutdown is already pending ###");
                return;
            }
            
            DDLogInfo(@"### checking if background is still needed ###");
            BOOL background = [HelperTools isInBackground];
            if(background)
            {
                DDLogInfo(@"### All accounts idle, disconnecting and stopping all background tasks ###");
                [DDLog flushLog];
                DDLogVerbose(@"Setting _shutdownPending to YES...");
                _shutdownPending = YES;
                [[MLXMPPManager sharedInstance] disconnectAll];     //disconnect all accounts to prevent TCP buffer leaking
                [self scheduleBackgroundFetchingTask:NO];           //request bg fetch execution in BGFETCH_DEFAULT_INTERVAL seconds
                [HelperTools dispatchSyncReentrant:^{
                    BOOL stopped = NO;
                    //make sure this will be done only once, even if we have an uikit bgtask and a bg fetch running simultaneously
                    if(self->_bgTask != UIBackgroundTaskInvalid || self->_bgFetch != nil)
                    {
                        //notify about pending app freeze (don't queue this notification because it should be handled IMMEDIATELY and INLINE)
                        DDLogVerbose(@"Posting kMonalWillBeFreezed notification now...");
                        [[NSNotificationCenter defaultCenter] postNotificationName:kMonalWillBeFreezed object:nil];
                    }
                    if(self->_bgTask != UIBackgroundTaskInvalid)
                    {
                        DDLogDebug(@"stopping UIKit _bgTask");
                        [DDLog flushLog];
                        UIBackgroundTaskIdentifier task = self->_bgTask;
                        self->_bgTask = UIBackgroundTaskInvalid;
                        [[UIApplication sharedApplication] endBackgroundTask:task];
                        stopped = YES;
                    }
                    if(self->_bgFetch != nil)
                    {
                        DDLogDebug(@"stopping backgroundFetchingTask");
                        [DDLog flushLog];
                        BGTask* task = self->_bgFetch;
                        self->_bgFetch = nil;
                        [task setTaskCompletedWithSuccess:YES];
                        stopped = YES;
                    }
                    if(!stopped)
                    {
                        DDLogDebug(@"no background tasks running, nothing to stop");
                        [DDLog flushLog];
                    }
                } onQueue:dispatch_get_main_queue()];
            }
        }
    }
}

-(void) scheduleBackgroundFetchingTask:(BOOL) force
{
    DDLogInfo(@"Scheduling new BackgroundFetchingTask with force=%s...", force ? "yes" : "no");
    [HelperTools dispatchSyncReentrant:^{
        NSError *error = NULL;
        // cancel existing task (if any)
        [BGTaskScheduler.sharedScheduler cancelTaskRequestWithIdentifier:kBackgroundFetchingTask];
        // new task
        //BGAppRefreshTaskRequest* request = [[BGAppRefreshTaskRequest alloc] initWithIdentifier:kBackgroundFetchingTask];
        BGProcessingTaskRequest* request = [[BGProcessingTaskRequest alloc] initWithIdentifier:kBackgroundFetchingTask];
        //do the same like the corona warn app from germany which leads to this hint: https://developer.apple.com/forums/thread/134031
        request.requiresNetworkConnectivity = YES;
        request.requiresExternalPower = NO;
        if(force)
            request.earliestBeginDate = nil;
        else
            request.earliestBeginDate = [NSDate dateWithTimeIntervalSinceNow:BGFETCH_DEFAULT_INTERVAL];
        BOOL success = [[BGTaskScheduler sharedScheduler] submitTaskRequest:request error:&error];
        if(!success) {
            // Errorcodes https://stackoverflow.com/a/58224050/872051
            DDLogError(@"Failed to submit BGTask request: %@", error);
        } else {
            DDLogVerbose(@"Success submitting BGTask request %@", request);
        }
    } onQueue:dispatch_get_main_queue()];
}

-(void) addBackgroundTask
{
    [HelperTools dispatchSyncReentrant:^{
            //log both cases if present
            if(self->_bgTask != UIBackgroundTaskInvalid)
                DDLogVerbose(@"Not starting UIKit background task, already running: %d", (int)self->_bgTask);
            if(self->_bgFetch != nil)
                DDLogVerbose(@"Not starting UIKit background task, bg fetch already running: %@", self->_bgFetch);
            //don't start uikit bg task if it's already running or a bg fetch is running already
            if(self->_bgTask == UIBackgroundTaskInvalid && self->_bgFetch == nil)
            {
                DDLogInfo(@"Starting UIKit background task...");
                //indicate we want to do work even if the app is put into background
                self->_bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^(void) {
                    DDLogWarn(@"BG WAKE EXPIRING");
                    [DDLog flushLog];
                    
                    @synchronized(self) {
                        //ui background tasks expire at the same time as background fetching tasks
                        //--> we have to check if a background fetching task is running and don't disconnect, if so
                        if(self->_bgFetch == nil)
                        {
                            DDLogVerbose(@"Setting _shutdownPending to YES...");
                            self->_shutdownPending = YES;
                            DDLogDebug(@"_bgFetch == nil --> disconnecting and ending background task");
                            
                            //this has to be before account disconnects, to detect which accounts are not idle (e.g. have a sync error)
                            [HelperTools updateSyncErrorsWithDeleteOnly:NO andWaitForCompletion:YES];
                          //  [HelperTools updateSyncErrorsWithDeleteOnly:NO andWaitForCompletion:YES];
                            
                            //disconnect all accounts to prevent TCP buffer leaking
                            [[MLXMPPManager sharedInstance] disconnectAll];
                            
                            //schedule a BGProcessingTaskRequest to process this further as soon as possible
                            //(if we end up here, the graceful shuttdown did not work out because we are not idle --> we need more cpu time)
                            [self scheduleBackgroundFetchingTask:YES];      //force as soon as possible
                            
                            //notify about pending app freeze (don't queue this notification because it should be handled IMMEDIATELY and INLINE)
                            DDLogVerbose(@"Posting kMonalWillBeFreezed notification now...");
                            [[NSNotificationCenter defaultCenter] postNotificationName:kMonalWillBeFreezed object:nil];
                        }
                        else
                            DDLogDebug(@"_bgFetch != nil --> not disconnecting");
                        
                        DDLogDebug(@"stopping UIKit _bgTask");
                        [DDLog flushLog];
                        UIBackgroundTaskIdentifier task = self->_bgTask;
                        self->_bgTask = UIBackgroundTaskInvalid;
                        [[UIApplication sharedApplication] endBackgroundTask:task];
                    }
                }];
            }
        } onQueue:dispatch_get_main_queue()];
}

-(void) handleBackgroundFetchingTask:(BGTask*) task
{
    DDLogInfo(@"RUNNING BGTASK SETUP HANDLER");
    
    _bgFetch = task;
    weakify(task);
    task.expirationHandler = ^{
        strongify(task);
        DDLogWarn(@"*** BGTASK EXPIRED ***");
        [DDLog flushLog];
        
        BOOL background = [HelperTools isInBackground];
        
        DDLogVerbose(@"Waiting for @synchronized(self)...");
        @synchronized(self) {
            DDLogVerbose(@"Now entered @synchronized(self) block...");
            //ui background tasks expire at the same time as background fetching tasks
            //--> we have to check if an ui bg task is running and don't disconnect, if so
            if(background && self->_bgTask == UIBackgroundTaskInvalid)
            {
                DDLogVerbose(@"Setting _shutdownPending to YES...");
                self->_shutdownPending = YES;
                DDLogDebug(@"_bgTask == UIBackgroundTaskInvalid --> disconnecting and ending background task");
                
                //this has to be before account disconnects, to detect which accounts are not idle (e.g. have a sync error)
                [HelperTools updateSyncErrorsWithDeleteOnly:NO andWaitForCompletion:YES];
                
                //disconnect all accounts to prevent TCP buffer leaking
                [[MLXMPPManager sharedInstance] disconnectAll];
                
                //schedule a new BGProcessingTaskRequest to process this further as soon as possible
                //(if we end up here, the graceful shuttdown did not work out because we are not idle --> we need more cpu time)
                [self scheduleBackgroundFetchingTask:YES];      //force as soon as possible
                
                //notify about pending app freeze (don't queue this notification because it should be handled IMMEDIATELY and INLINE)
                DDLogVerbose(@"Posting kMonalWillBeFreezed notification now...");
                [[NSNotificationCenter defaultCenter] postNotificationName:kMonalWillBeFreezed object:nil];
            }
            else
                DDLogDebug(@"_bgTask != UIBackgroundTaskInvalid --> not disconnecting");
            
            DDLogDebug(@"stopping backgroundFetchingTask");
            [DDLog flushLog];
            self->_bgFetch = nil;
            //only signal success, if we are not in background anymore (otherwise we *really* expired without being idle)
            [task setTaskCompletedWithSuccess:!background];
        }
    };
    
    //only proceed with our BGTASK if the NotificationServiceExtension is not running
    [[IPC sharedInstance] sendMessage:@"Monal.disconnectAll" withData:nil to:@"NotificationServiceExtension"];
    if([MLProcessLock checkRemoteRunning:@"NotificationServiceExtension"])
    {
        DDLogInfo(@"NotificationServiceExtension is running, waiting for its termination");
        [MLProcessLock waitForRemoteTermination:@"NotificationServiceExtension" withLoopHandler:^{
            [[IPC sharedInstance] sendMessage:@"Monal.disconnectAll" withData:nil to:@"NotificationServiceExtension"];
        }];
    }
    
    if(self->_bgTask != UIBackgroundTaskInvalid)
    {
        DDLogDebug(@"stopping UIKit _bgTask, not needed when running a bg fetch");
        [DDLog flushLog];
        UIBackgroundTaskIdentifier task = self->_bgTask;
        self->_bgTask = UIBackgroundTaskInvalid;
        [[UIApplication sharedApplication] endBackgroundTask:task];
    }
    
    if([[MLXMPPManager sharedInstance] hasConnectivity])
    {
        [self startBackgroundTimer:BGFETCH_GRACEFUL_TIMEOUT];
        @synchronized(self) {
            DDLogVerbose(@"Setting _shutdownPending to NO...");
            _shutdownPending = NO;
        }
        //don't use *self* connectIfNecessary, because we don't need an additional UIKit bg task, this one is already a bg fetch
        [[MLXMPPManager sharedInstance] connectIfNecessary];
    }
    else
        DDLogWarn(@"BGTASK has *no* connectivity? That's strange!");
    
    //request another execution in BGFETCH_DEFAULT_INTERVAL seconds
    [self scheduleBackgroundFetchingTask:NO];
    
    DDLogInfo(@"BGTASK SETUP HANDLER COMPLETED SUCCESSFULLY...");
}

-(void) configureBackgroundFetchingTask
{
    if(@available(iOS 13.0, *))
    {
        [[BGTaskScheduler sharedScheduler] registerForTaskWithIdentifier:kBackgroundFetchingTask usingQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) launchHandler:^(BGTask *task) {
            DDLogDebug(@"RUNNING BGTASK LAUNCH HANDLER");
            if(![HelperTools isInBackground])
            {
                DDLogDebug(@"Already in foreground, stopping bgtask");
                [_bgFetch setTaskCompletedWithSuccess:YES];
            }
            else
                [self handleBackgroundFetchingTask:task];
        }];
    } else {
        // No fallback unfortunately
    }
}

-(void) scheduleBackgroundFetchingTask
{
    if(@available(iOS 13.0, *))
    {
        [HelperTools dispatchSyncReentrant:^{
            NSError *error = NULL;
            // cancel existing task (if any)
            [BGTaskScheduler.sharedScheduler cancelTaskRequestWithIdentifier:kBackgroundFetchingTask];
            // new task
            //BGAppRefreshTaskRequest* request = [[BGAppRefreshTaskRequest alloc] initWithIdentifier:kBackgroundFetchingTask];
            BGProcessingTaskRequest* request = [[BGProcessingTaskRequest alloc] initWithIdentifier:kBackgroundFetchingTask];
            //do the same like the corona warn app from germany which leads to this hint: https://developer.apple.com/forums/thread/134031
            request.requiresNetworkConnectivity = YES;
            request.requiresExternalPower = NO;
            request.earliestBeginDate = nil;
            //request.earliestBeginDate = [NSDate dateWithTimeIntervalSinceNow:40];        //begin nearly immediately (if we have network connectivity)
            BOOL success = [[BGTaskScheduler sharedScheduler] submitTaskRequest:request error:&error];
            if(!success) {
                // Errorcodes https://stackoverflow.com/a/58224050/872051
                DDLogError(@"Failed to submit BGTask request: %@", error);
            } else {
                DDLogVerbose(@"Success submitting BGTask request %@", request);
            }
        } onQueue:dispatch_get_main_queue()];
    }
    else
    {
        // No fallback unfortunately
        DDLogError(@"BGTask needed but NOT supported!");
    }
}

-(void) connectIfNecessary
{
    [self addBackgroundTask];
    [[MLXMPPManager sharedInstance] connectIfNecessary];
}

-(void) incomingWakeupWithCompletionHandler:(void (^)(UIBackgroundFetchResult result)) completionHandler
{
    if(![HelperTools isInBackground])
    {
        DDLogError(@"Ignoring incomingWakeupWithCompletionHandler: because app is in FG!");
        completionHandler(UIBackgroundFetchResultNoData);
        return;
    }
    
    NSString* completionId = [[NSUUID UUID] UUIDString];
    DDLogInfo(@"got incomingWakeupWithCompletionHandler with ID %@", completionId);
    
    //don't use *self* connectIfNecessary] because we already have a background task here
    //that gets stopped once we call the completionHandler
    [[MLXMPPManager sharedInstance] connectIfNecessary];
    
    //register push completion handler and associated timer (use the GRACEFUL_TIMEOUT here, too)
    @synchronized(self) {
        _wakeupCompletions[completionId] = @{
            @"handler": completionHandler,
            @"timer": createTimer(GRACEFUL_TIMEOUT, (^{
                DDLogWarn(@"### Wakeup timer triggered for ID %@ ###", completionId);
                dispatch_async(dispatch_get_main_queue(), ^{
                    @synchronized(self) {
                        if([_wakeupCompletions objectForKey:completionId] != nil)
                        {
                            DDLogInfo(@"Handling wakeup completion %@", completionId);
                            
                            //remove this handler from list
                            [_wakeupCompletions removeObjectForKey:completionId];
                            
                            //retry background check (now handling idle state because no running background timer is blocking it)
                            [self checkIfBackgroundTaskIsStillNeeded];
                            
                            //call completion (should be done *after* the idle state check because it could freeze the app)
                            DDLogInfo(@"Calling wakeup completion handler...");
                            completionHandler(UIBackgroundFetchResultFailed);
                        }
                        else
                            DDLogWarn(@"Wakeup completion %@ got already handled and was removed from list!", completionId);
                    }
                });
            }))
        };
        DDLogInfo(@"Added timer %@ to wakeup completion list...", completionId);
    }
}
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController{
    
}
- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item{
    if (item == 0){
        item.title = @"Chats";
    }
}




@end

