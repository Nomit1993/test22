//
//  ActiveChatsViewController.m
//  Monal
//
//  Created by Anurodh Pokharel on 6/14/13.
//
//

#import "ActiveChatsViewController.h"
#import "DataLayer.h"
#import "xmpp.h"
#import "MLContactCell.h"
#import "chatViewController.h"
#import "MonalAppDelegate.h"
#import "ContactDetails.h"
#import "MLImageManager.h"
#import "MLWelcomeViewController.h"
#import "ContactsViewController.h"
#import "MLNewViewController.h"
#import "MLXEPSlashMeHandler.h"
#import "MLNotificationQueue.h"
#import "addContact.h"
#import "MLSearchContactViewController.h"
#import "MBProgressHUD.h"
#import "MLOMEMO.h"
#import "MLChatViewHelper.h"
#import "MLMucProcessor.h"
#import "MLSignalStore.h"
#import "MLPubSub.h"
#import "MLOMEMO.h"
#import "XMPPIQ.h"
#import "XMPPMessage.h"

//#import <ZDetection/ZDetectionApi.h>
@import QuartzCore.CATransaction;

@interface ActiveChatsViewController ()
@property (atomic, strong) NSMutableArray* unpinnedContacts;
@property (atomic, strong) NSMutableArray* pinnedContacts;
@property (nonatomic, strong) NSMutableArray<MLContact*>* contacts;
@property (nonatomic, strong) UISearchController* searchController;
@property (nonatomic, strong) MBProgressHUD* joinHUD;
@property (nonatomic, assign) BOOL isGroupChatSelected;
@property (nonatomic, strong) MBProgressHUD* checkHUD;
@property (nonatomic, assign) BOOL isSearchEnabled;
@end

@implementation ActiveChatsViewController

enum activeChatsControllerSections {
    pinnedChats,
    unpinnedChats,
    activeChatsViewControllerSectionCnt
};

static NSMutableSet* _mamWarningDisplayed;
static NSMutableSet* _smacksWarningDisplayed;

+(void) initialize
{
    _mamWarningDisplayed = [[NSMutableSet alloc] init];
    _smacksWarningDisplayed = [[NSMutableSet alloc] init];
}

#pragma mark view lifecycle
-(id) initWithNibName:(NSString*) nibNameOrNil bundle:(NSBundle*) nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void) viewDidLoad
{
    [super viewDidLoad];
    
    BOOL Granted = [[HelperTools defaultsDB] boolForKey:@"loginWithTouchId"];
 //   [self showActivityIndicator];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connected:) name:kMLHasConnectedNotice object:nil];
    if (Granted == YES) {
        
        if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            [self setpasscode];
        }else{
            [self.navigationController.navigationBar setHidden:true];
             self.viewOfTouchId.frame = [[UIScreen mainScreen] bounds];
            [self.view addSubview:self.viewOfTouchId];
            [self setpasscode];
        }
        
        
    }else{
        [self loadViewAfterTouchId];
    }

}
-(void) securityCheckAnalysis{
    securityServices *DeviceSecurity = [[securityServices alloc] init];
    
    [DeviceSecurity ServicesWithReturnCompletion:^(NSString * _Nonnull result) {
        if (result != nil && ![result isEqual: @""] ){
            dispatch_async(dispatch_get_main_queue(), ^(void){
            //        //Run UI Updates
                xmpp* account = [[MLXMPPManager sharedInstance].connectedXMPP objectAtIndex:0];
                MLContact* contactObj = [MLContact createContactFromJid:@"validations@chat.securesignal.in" andAccountNo:account.accountNo];
                [[MLXMPPManager sharedInstance] addContact:contactObj];
                [account sendMessage:result toContact:contactObj isEncrypted:YES isUpload:NO andMessageId:[[NSUUID UUID] UUIDString]];
                UIAlertController * alertvc = [UIAlertController alertControllerWithTitle: @"Security Status"
                                                 message:result preferredStyle: UIAlertControllerStyleAlert
                                                ];
                  UIAlertAction * action = [UIAlertAction actionWithTitle: @"Dismiss"
                                            style: UIAlertActionStyleDefault handler: ^ (UIAlertAction * _Nonnull action) {
                                              NSLog(@"Dismiss Tapped");
                     // exit(0);
                      
                                            }
                                           ];
                  [alertvc addAction: action];
                  [self presentViewController: alertvc animated: true completion: nil];
                });
        }
    }];
  

    
}
-(void) loadViewAfterTouchId {
    [self.navigationController.navigationBar setHidden:false];
    [self.viewOfTouchId removeFromSuperview];
     self.view.backgroundColor=[UIColor lightGrayColor];
    self.view.autoresizingMask=UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    self.contacts = [[NSMutableArray alloc] init];
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.isSearchEnabled = NO;
    self.searchController.searchResultsUpdater = self;
    self.searchController.delegate = self;
    self.searchController.obscuresBackgroundDuringPresentation = NO;

    
   // self.navigationItem.searchController = self.searchController;
    [self refreshDisplay];
    MonalAppDelegate* appDelegate = (MonalAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate setActiveChatsController:self];
    
     self.chatListTable = [[UITableView alloc] init];
     self.chatListTable.delegate = self;
     self.chatListTable.dataSource = self;
    
    self.view = self.chatListTable;
  
    [_chatListTable registerNib:[UINib nibWithNibName:@"MLContactCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"ContactCell"];
    
//    UIActivityIndicatorView *connectIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
//    connectIndicator.hidesWhenStopped = NO; //I added this just so I could see it
//    connectIndicator.largeContentTitle = @"Connecting ..";
//    self.navigationItem.titleView = connectIndicator;
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(handleRefreshDisplayNotification:) name:kMonalRefresh object:nil];
    [nc addObserver:self selector:@selector(handleContactUI:) name:kMonalrefreshTabController object:nil];
  
    [nc addObserver:self selector:@selector(handleContactRemoved:) name:kMonalContactRemoved object:nil];
    [nc addObserver:self selector:@selector(handleRefreshDisplayNotification:) name:kMonalMessageFiletransferUpdateNotice object:nil];
    [nc addObserver:self selector:@selector(refreshContact:) name:kMonalContactRefresh object:nil];
    [nc addObserver:self selector:@selector(handleNewMessage:) name:kMonalNewMessageNotice object:nil];
    [nc addObserver:self selector:@selector(handleNewMessage:) name:kMonalDeletedMessageNotice object:nil];
    [nc addObserver:self selector:@selector(messageSent:) name:kMLMessageSentToContact object:nil];
    [nc addObserver:self selector:@selector(handleBackgroundChanged) name:kMonalBackgroundChanged object:nil];
    
  
    
    self.splitViewController.preferredDisplayMode = UISplitViewControllerDisplayModeAllVisible;
    if(@available(iOS 13.0, *))
    {
#if !TARGET_OS_MACCATALYST
        self.splitViewController.primaryBackgroundStyle = UISplitViewControllerBackgroundStyleSidebar;
#endif
       // self.settingsButton.image = [UIImage systemImageNamed:@"gearshape.fill"];
       // self.composeButton.image = [UIImage systemImageNamed:@"person.2.fill"];
    }
    else
    {
       // self.settingsButton.image = [UIImage imageNamed:@"973-user"];
        //self.composeButton.image = [UIImage imageNamed:@"704-compose"];
    }
    UIBarButtonItem *searchBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"search"] style:UIBarButtonItemStylePlain  target:self  action:@selector(showSeachButtonAction)];
    UIBarButtonItem *menuBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"more"] style:UIBarButtonItemStylePlain target:self action:nil];
    if (@available(iOS 13.0, *)) {
        UIAction * NewUser = [UIAction actionWithTitle:@"Add Contact" image:[UIImage imageNamed:@"user" ] identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
            //newContact
            if([self showAccountNumberWarningIfNeeded])
                return;
            [self AddNewUserToRoster];
        }];
        UIAction * NewGroup = [UIAction actionWithTitle:@"Create Group" image:[UIImage imageNamed:@"Group"] identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
            self.isGroupChatSelected = YES;
            [self showContacts];
         
        }];
        UIAction * contacts = [UIAction actionWithTitle:@"Contacts" image:[UIImage imageNamed:@"Group"] identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
            self.isGroupChatSelected = NO;
            [self showContacts];
        }];
        
        UIAction * starMessage = [UIAction actionWithTitle:@"Starred Message" image:[UIImage imageNamed:@"Group"] identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
            self.isGroupChatSelected = NO;
            [self showStarMessage];
        }];
       
        UIAction * Archive = [UIAction actionWithTitle:@"Archive Chats" image:[UIImage imageNamed:@"archive"] identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
           // [self updateInboxArchiveFilteringAndShowArchived:YES];
        }];
        UIAction * Settings = [UIAction actionWithTitle:@"Settings" image:[UIImage imageNamed:@"OTRSettingsIcon"] identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
            //[self settingsButtonPressed:self];
            [self showSettings];

        }];
        NSArray<UIMenuElement *> *Actions = @[];
               if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad )
               {
                    /* Device is iPad */
                   Actions = @[NewUser,NewGroup,contacts,starMessage,Archive,Settings];
                  
               }else{
                   Actions = @[NewUser,NewGroup,starMessage,Archive];
               }
        //NSArray<UIMenuElement *> *Actions = @[NewUser,NewGroup,starMessage,Archive];
        if (@available(iOS 14.0, *)) {
            menuBarButtonItem.menu = [UIMenu menuWithTitle:@"" children:Actions];
            self.navigationItem.leftBarButtonItem = nil;
            self.navigationItem.rightBarButtonItems = @[menuBarButtonItem,searchBarButtonItem];
        } else {
            [menuBarButtonItem setTarget:self];
            self.navigationItem.leftBarButtonItem = nil;
            self.navigationItem.rightBarButtonItems = @[menuBarButtonItem,searchBarButtonItem];
          [menuBarButtonItem setAction:@selector(ShowAttachmentMenu:)];
           
            // Fallback on earlier versions
        }
    } else {
        // Fallback on earlier versions
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.rightBarButtonItems = @[menuBarButtonItem,searchBarButtonItem];
       [menuBarButtonItem setTarget:self];
      [menuBarButtonItem setAction:@selector(ShowAttachmentMenu:)];
    }
  
   
    
    self.chatListTable.emptyDataSetSource = self;
    self.chatListTable.emptyDataSetDelegate = self;
    if(!([[DataLayer sharedInstance] enabledAccountCnts].intValue == 0)){
        NSMutableArray* result = [[DataLayer sharedInstance] contactRequestsForAccount];
        [result enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
            MLContact *contact = object;
            [[MLXMPPManager sharedInstance] addContact:contact];
        }];
    }
    [self securityCheckAnalysis];
}
-(void) connected:(NSNotification*) notification
{
   
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        //Background Thread
       
        xmpp* account = [[MLXMPPManager sharedInstance].connectedXMPP objectAtIndex:0];
        for(NSDictionary* entry in  [[DataLayer sharedInstance] listBuddiesForAccount:account.accountNo]){
            NSLog(@"%@",entry);
            if ([entry[@"buddy_name"] containsString:@"conference.chat.securesignal.in"]){
                [account joinMuc:entry[@"buddy_name"]];
               // [[DataLayer sharedInstance] removeBuddy:entry[@"buddy_name"] forAccount:account.accountNo];
                [MLMucProcessor sendDiscoQueryFor:entry[@"buddy_name"] onAccount:account withJoin:YES andBookmarksUpdate:YES];
               // [[DataLayer sharedInstance] addMucFavorite:entry[@"buddy_name"] forAccountId:account.accountNo andMucNick:nil];
            }else if ([entry[@"buddy_name"] containsString:@"enhanced-apk@chat.securesignal.in"]){
                [[DataLayer sharedInstance] removeBuddy:entry[@"buddy_name"] forAccount:account.accountNo];
            }else{
                
              xmpp *account_contact = [[MLXMPPManager sharedInstance] getConnectedAccountForID:entry[@"account_id"]];
                NSMutableArray<NSNumber*> * devices;
                [account_contact.omemo queryOMEMODevices:entry[@"buddy_name"]];
             //   [account_contact.omemo sendLocalDevicesIfNeeded];
                devices = [[NSMutableArray alloc] initWithArray:[account_contact.omemo knownDevicesForAddressName:entry[@"buddy_name"]]];
                for(NSNumber* device in devices) {
                    SignalAddress* address = [[SignalAddress alloc] initWithName:entry[@"buddy_name"] deviceId:(int) device.integerValue];

                    NSData* identity = [account_contact.omemo.monalSignalStore getIdentityForAddress:address];
                    BOOL newTrust;
                    int internalTrustLevel = [account_contact.omemo.monalSignalStore getInternalTrustLevel:address identityKey:identity];
                    if(internalTrustLevel == MLOmemoInternalTrusted) {
                        newTrust = NO;
                    } else { // MLOmemoInternalToFU || MLOmemoInternalNotTrusted
                        newTrust = YES;
                        [account_contact.omemo updateTrust:newTrust forAddress:address];
                    }

                }
            }
            }
        
     // [account publishRosterName:account.connectionProperties.identity.user];
   for(NSDictionary* entry in [[DataLayer sharedInstance] listMucsForAccount:account.accountNo]){
//
      
               [MLMucProcessor join:entry[@"room"] onAccount:account];
                [MLMucProcessor fetchmamMessages:entry[@"room"] onAccount:account];
                [MLMucProcessor moderatorSubscriberoom:entry[@"room"] onAccount:account];
                 [MLMucProcessor moderatorMsgSubscriberoom:entry[@"room" ] onAccount:account];
        }
        dispatch_async(dispatch_get_main_queue(), ^(void){
            //Run UI Updates
            self.navigationItem.titleView = nil;
        });
    });
    }

-(void) handleContactUI:(NSNotification *)notification{
   
    if ([[HelperTools defaultsDB] boolForKey:@"darkModeEnable"]){
            //is dark
        [self.chatListTable reloadData];
        //[[UITabBar appearance] setBarTintColor:UIColorFromRGB(0x34B7F1)];
    }else{

        //is light
        [self.chatListTable reloadData];
    }
   
     
    
}
- (void)showActivityIndicator
{
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    activityIndicatorView.frame = CGRectMake(0, 0, 22, 22);
    
    
     if ([[HelperTools defaultsDB] boolForKey:@"darkModeEnable"]){
             //is dark
         activityIndicatorView.color = [UIColor whiteColor];
     }else{
         //is light
         activityIndicatorView.color = [UIColor blackColor];
     }
    [activityIndicatorView startAnimating];

    UILabel *titleLabel = [UILabel new];
    titleLabel.text = @"Connecting ....";
    titleLabel.font = [UIFont systemFontOfSize:18];

    CGSize fittingSize = [titleLabel sizeThatFits:CGSizeMake(200.0f, activityIndicatorView.frame.size.height)];
    titleLabel.frame = CGRectMake(activityIndicatorView.frame.origin.x + activityIndicatorView.frame.size.width + 8,
                                  activityIndicatorView.frame.origin.y,
                                  fittingSize.width,
                                  fittingSize.height);

    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(-(activityIndicatorView.frame.size.width + 8 + titleLabel.frame.size.width)/2,
                                                                 -(activityIndicatorView.frame.size.height)/2,
                                                                 activityIndicatorView.frame.size.width + 8 + titleLabel.frame.size.width,
                                                                 activityIndicatorView.frame.size.height)];
    [titleView addSubview:activityIndicatorView];
    [titleView addSubview:titleLabel];

    self.navigationItem.titleView = titleView;
}
-(void) showSeachButtonAction
{
    UIStoryboard *main = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
       MLSearchContactViewController *searchVC = [main instantiateViewControllerWithIdentifier:@"SearchVC"];
    searchVC.selectContact = ^(MLContact* selectedContact) {
        [[DataLayer sharedInstance] addActiveBuddies:selectedContact.contactJid forAccount:selectedContact.accountId];
        //no success may mean its already there
        [self insertOrMoveContact:selectedContact completion:^(BOOL finished) {
            size_t sectionToUse = unpinnedChats; // Default is not pinned
            if(selectedContact.isPinned) {
                sectionToUse = pinnedChats; // Insert in pinned section
            }
            NSIndexPath* path = [NSIndexPath indexPathForRow:0 inSection:sectionToUse];
            [self.chatListTable selectRowAtIndexPath:path animated:NO scrollPosition:UITableViewScrollPositionNone];
            if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad )
            {
                 /* Device is iPad */
                [self presentChatWithContact:selectedContact];


            }else{
                UIStoryboard *main = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                 chatViewController* chatVC = [main instantiateViewControllerWithIdentifier:@"chatViewController"];

                 [chatVC setupWithContact:selectedContact];

                UIBarButtonItem* barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
                self.navigationItem.backBarButtonItem = barButtonItem;
                [self.navigationController pushViewController:chatVC animated:YES];


            }
        }];
    };
//       UINavigationController *SearchNav = [[UINavigationController alloc]initWithRootViewController:searchVC];
//    SearchNav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.navigationController pushViewController:searchVC animated:YES];
}
- (void)ShowAttachmentMenu:(id)sender
{
     UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@"Settings"
                                 message:Nil
                                 preferredStyle:UIAlertControllerStyleActionSheet];

    //Add Buttons

    UIAlertAction* AddUser = [UIAlertAction
                                actionWithTitle:@"Add Contact"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
                               
        if([self showAccountNumberWarningIfNeeded])
            return;
        [self AddNewUserToRoster];
                                }];

    UIAlertAction* composeGroup = [UIAlertAction
                               actionWithTitle:@"Create Group"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
                                
        self.isGroupChatSelected = YES;
        [self showContacts];
                               }];
//    self.isGroupChatSelected = NO;
//    [self showContacts];
    UIAlertAction* contacts = [UIAlertAction
                               actionWithTitle:@"Contacts"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {

        self.isGroupChatSelected = NO;
        [self showContacts];
                               }];
    UIAlertAction* starMsgs = [UIAlertAction
                               actionWithTitle:@"Star Messages"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
                                
        self.isGroupChatSelected = NO;
        [self showStarMessage];
                               }];
    UIAlertAction* settings = [UIAlertAction
                               actionWithTitle:@"Settings"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {

        [self showSettings];
                               }];
    UIAlertAction* cancel = [UIAlertAction
                               actionWithTitle:@"Cancel"
                               style:UIAlertActionStyleDestructive
                               handler:^(UIAlertAction * action) {
                                   //Handle no, thanks button
                               }];
    //Add your buttons to alert controller

    [alert addAction:AddUser];
    [alert addAction:composeGroup];
    [alert addAction:starMsgs];
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad )
    {
         /* Device is iPad */
        [alert addAction:contacts];
        [alert addAction:settings];
    }
   // [alert addAction:contacts];
    
   // [alert addAction:settings];
    [alert addAction:cancel];

    [self presentViewController:alert animated:YES completion:nil];
}


-(void)GroupComposeButtonPressed{
     if([self showAccountNumberWarningIfNeeded])
     return;
    //[self performSegueWithIdentifier:@"showContacts" sender:self];
    ContactsViewController* contacts = [[ContactsViewController alloc] init];
    contacts.isGroupChat = YES;
    contacts.forwardMessage = NO;
    contacts.delegate = self;
    [self.navigationController pushViewController:contacts animated:YES];
    

}
-(void) AddNewUserToRoster
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"New Contact"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        // optionally configure the text field
        textField.keyboardType = UIKeyboardTypeAlphabet;
    }];
    UIAlertAction *Cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action) {
                                                             UITextField *textField = [alert.textFields firstObject];
        if (textField.text.length > 0) {
           
            NSString *BuddyUserJid = [textField.text stringByAppendingString:@"@chat.securesignal.in"];
            NSDictionary<NSString*, NSString*>* jidComponents = [HelperTools splitJid:BuddyUserJid];
            DDLogVerbose(@"Jid validity: node(%lu)='%@', host(%lu)='%@'", (unsigned long)[jidComponents[@"node"] length], jidComponents[@"node"], (unsigned long)[jidComponents[@"host"] length], jidComponents[@"host"]);
            if(!jidComponents[@"node"] || jidComponents[@"node"].length == 0 || jidComponents[@"host"].length == 0)
            {
                
                UIAlertController* messageAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Jid Invalid", @"") message:NSLocalizedString(@"The jid has to be in the form 'user@domain.tld' to be correct.", @"") preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* closeAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Close", @"") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                }];
                [messageAlert addAction:closeAction];
                [self presentViewController:messageAlert animated:YES completion:nil];
                return;
            }
            NSString* jid = jidComponents[@"user"];
           
            xmpp* account = [[MLXMPPManager sharedInstance].connectedXMPP objectAtIndex:0];
            [account checkJidType:jid withCompletion:^(NSString* type, NSString* _Nullable errorMessage) {
               
               
                dispatch_async(dispatch_get_main_queue(), ^{
//                    [self displayCheckHUD];
//                    MLContact* contactObj = [MLContact createContactFromJid:jid andAccountNo:account.accountNo];
//                    [[MLXMPPManager sharedInstance] addContact:contactObj];
//                    [self hideCheckHUD];
                    
                                      [self displayCheckHUD];
                                       MLContact* contactObj = [MLContact createContactFromJid:jid andAccountNo:account.accountNo];
                                       [[MLXMPPManager sharedInstance] addContact:contactObj];
                                       NSString* accountNo = contactObj.accountId;


                                       xmpp* xmppAccount = [[MLXMPPManager sharedInstance] getConnectedAccountForID:accountNo];
                                       NSArray* devices = [xmppAccount.omemo knownDevicesForAddressName:contactObj.contactJid];
                                       [MLChatViewHelper<ContactDetails*>
                                           toggleEncryptionForContact:contactObj withKnownDevices:devices withSelf:self afterToggle:^() {
                                           
                                       }];
                                       
                                       [self hideCheckHUD];
                                       if(self.completion)
                                           self.completion(contactObj);
                                       //[self presentChatWithContact:contactObj];
                                       UIStoryboard *main = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                        chatViewController* chatVC = [main instantiateViewControllerWithIdentifier:@"chatViewController"];

                                        [chatVC setupWithContact:contactObj];

                                       UIBarButtonItem* barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
                                       self.navigationItem.backBarButtonItem = barButtonItem;
                    [self.navigationController pushViewController:chatVC animated:YES];

//                    UIAlertController* messageAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Permission Requested", @"") message:NSLocalizedString(@"The new contact will be added to your contacts list when the person you've added has approved your request.", @"") preferredStyle:UIAlertControllerStyleAlert];
//                    UIAlertAction* closeAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Close", @"") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
//                        if(self.completion)
//                            self.completion(contactObj);
//                        [self presentChatWithContact:contactObj];
//                        [self dismissViewControllerAnimated:YES completion:nil];
//                    }];
//                    [messageAlert addAction:closeAction];
//                    [self presentViewController:messageAlert animated:YES completion:nil];
                    
                    if(self.completion)
                        self.completion(contactObj);
                    
                });
            }];
            
        }else{
            UIAlertController * alertvc = [UIAlertController alertControllerWithTitle: @"Warning"
                                             message: @"Enter The UserName" preferredStyle: UIAlertControllerStyleAlert
                                            ];
              UIAlertAction * action = [UIAlertAction actionWithTitle: @ "Dismiss"
                                        style: UIAlertActionStyleDefault handler: ^ (UIAlertAction * _Nonnull action) {
                                          NSLog(@ "Dismiss Tapped");
                  [self AddNewUserToRoster];
                                        }
                                       ];
              [alertvc addAction: action];
              [self presentViewController: alertvc animated: true completion: nil];
            }
     
   
         }];
    
    [alert addAction:okAction];
    [alert addAction:Cancel];
    [self presentViewController:alert animated:YES completion:nil];
}
-(void) refreshDisplay
{
    
    @try {
        NSMutableArray<MLContact*>* newUnpinnedContacts = [[DataLayer sharedInstance] activeContactsWithPinned:NO];
         NSMutableArray<MLContact*>* newPinnedContacts = [[DataLayer sharedInstance] activeContactsWithPinned:YES];
         if(!newUnpinnedContacts || ! newPinnedContacts)
             return;
         __block NSMutableArray<MLContact*>* sortedNewPinnedContacts;
         __block NSMutableArray<MLContact*>* sortedUnNewPinnedContacts;
       __block NSArray* contentPinnedContacts = [[NSArray alloc] init];
       __block NSArray* contentUnPinnedContacts = [[NSArray alloc] init];
        __block NSArray* contentlessUnPinnedContacts = [[NSArray alloc] init];
         __block NSArray* contentlessPinnedContacts = [[NSArray alloc] init];
     
     
         [newPinnedContacts enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
                 MLContact *contact = object;
             if (contact.contactJid != nil && contact.accountId != nil){
                 MLMessage* lastMessage = [[DataLayer sharedInstance] lastMessageForContact:contact.contactJid forAccount:contact.accountId];
             if (lastMessage.messageText != nil || lastMessage.url != nil){
                 contentPinnedContacts = [contentPinnedContacts arrayByAddingObject:contact];
             }else{
                 contentlessPinnedContacts = [contentlessPinnedContacts arrayByAddingObject:contact];
             }
             }
     
             }];
     
         contentPinnedContacts = [contentPinnedContacts sortedArrayUsingComparator:^NSComparisonResult(MLContact *a, MLContact *b) {
     
                MLMessage* lastMessage1 = [[DataLayer sharedInstance] lastMessageForContact:a.contactJid forAccount:a.accountId];
                MLMessage* lastMessage2 = [[DataLayer sharedInstance] lastMessageForContact:b.contactJid forAccount:b.accountId];
     
               return [lastMessage1.timestamp compare:lastMessage2.timestamp];
            }];
     
         contentlessPinnedContacts = [contentlessPinnedContacts sortedArrayUsingComparator:^NSComparisonResult(MLContact *a, MLContact *b) {
               return [a.contactDisplayName compare:b.contactDisplayName];
            }];
         NSArray* reversedArray1 = [[contentPinnedContacts reverseObjectEnumerator] allObjects];
         sortedNewPinnedContacts =  [[reversedArray1 arrayByAddingObjectsFromArray:contentlessPinnedContacts] mutableCopy];
     
     
         [newUnpinnedContacts enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
                 MLContact *contact = object;
             if (contact.contactJid != nil && contact.accountId != nil){
                 MLMessage* lastMessage = [[DataLayer sharedInstance] lastMessageForContact:contact.contactJid forAccount:contact.accountId];
             if (lastMessage.messageText != nil || lastMessage.url != nil){
                 contentUnPinnedContacts = [contentUnPinnedContacts arrayByAddingObject:contact];
             }else{
                 contentlessUnPinnedContacts = [contentlessUnPinnedContacts arrayByAddingObject:contact];
             }
             }
     
             }];
     
         contentUnPinnedContacts = [contentUnPinnedContacts sortedArrayUsingComparator:^NSComparisonResult(MLContact *a, MLContact *b) {
     
             MLMessage* lastMessage1 = [[DataLayer sharedInstance] lastMessageForContact:a.contactJid forAccount:a.accountId];
             MLMessage* lastMessage2 = [[DataLayer sharedInstance] lastMessageForContact:b.contactJid forAccount:b.accountId];
     
            return [lastMessage1.timestamp compare:lastMessage2.timestamp];
         }];
     
         contentlessUnPinnedContacts = [contentlessUnPinnedContacts sortedArrayUsingComparator:^NSComparisonResult(MLContact *a, MLContact *b) {
             return [a.contactDisplayName compare:b.contactDisplayName];
          }];
     
         NSArray* reversedArray = [[contentUnPinnedContacts reverseObjectEnumerator] allObjects];
         sortedUnNewPinnedContacts = [[reversedArray arrayByAddingObjectsFromArray:contentlessUnPinnedContacts] mutableCopy];

       
   
     
             dispatch_async(dispatch_get_main_queue(), ^{
                 if(self.chatListTable.hasUncommittedUpdates)
                     return;
                 [CATransaction begin];
                 [UIView performWithoutAnimation:^{
                     [self.chatListTable beginUpdates];
     //                resizeSections(self.chatListTable, unpinnedChats, unpinnedCntDiff);
     //                resizeSections(self.chatListTable, pinnedChats, pinnedCntDiff);
                     self.unpinnedContacts = sortedUnNewPinnedContacts;
                     self.pinnedContacts = sortedNewPinnedContacts;
                     [self.chatListTable reloadSections:[NSIndexSet indexSetWithIndex:pinnedChats] withRowAnimation:UITableViewRowAnimationNone];
                     [self.chatListTable reloadSections:[NSIndexSet indexSetWithIndex:unpinnedChats] withRowAnimation:UITableViewRowAnimationNone];
                     [self.chatListTable endUpdates];
                 }];
               [CATransaction commit];
     
                 MonalAppDelegate* appDelegate = (MonalAppDelegate*)[UIApplication sharedApplication].delegate;
                 [appDelegate updateUnread];
          });
         
    }
    @catch (NSException *exception) {
       
       NSLog(@"%@", exception.reason);
        size_t unpinnedConCntBefore = self.unpinnedContacts.count;
            size_t pinnedConCntBefore = self.pinnedContacts.count;
            NSMutableArray<MLContact*>* newUnpinnedContacts = [[DataLayer sharedInstance] activeContactsWithPinned:NO];
            NSMutableArray<MLContact*>* newPinnedContacts = [[DataLayer sharedInstance] activeContactsWithPinned:YES];
            if(!newUnpinnedContacts || ! newPinnedContacts)
                return;

            int unpinnedCntDiff = (int)unpinnedConCntBefore - (int)newUnpinnedContacts.count;
            int pinnedCntDiff = (int)pinnedConCntBefore - (int)newPinnedContacts.count;

            void (^resizeSections)(UITableView*, size_t, int) = ^void(UITableView* table, size_t section, int diff){
                if(diff > 0)
                {
                    // remove rows
                    for(int i = 0; i < diff; i++)
                    {
                        NSIndexPath* posInSection = [NSIndexPath indexPathForRow:i inSection:section];
                        [table deleteRowsAtIndexPaths:@[posInSection] withRowAnimation:UITableViewRowAnimationNone];
                    }
                }
                else if(diff < 0)
                {
                    // add rows
                    for(size_t i = (-1) * diff; i > 0; i--)
                    {
                        NSIndexPath* posInSectin = [NSIndexPath indexPathForRow:(i - 1) inSection:section];
                        [table insertRowsAtIndexPaths:@[posInSectin] withRowAnimation:UITableViewRowAnimationNone];
                    }
                }
            };

            dispatch_async(dispatch_get_main_queue(), ^{
                if(self.chatListTable.hasUncommittedUpdates)
                    return;
                [CATransaction begin];
                [UIView performWithoutAnimation:^{
                    [self.chatListTable beginUpdates];
                    resizeSections(self.chatListTable, unpinnedChats, unpinnedCntDiff);
                    resizeSections(self.chatListTable, pinnedChats, pinnedCntDiff);
                    self.unpinnedContacts = newUnpinnedContacts;
                    self.pinnedContacts = newPinnedContacts;
                    [self.chatListTable reloadSections:[NSIndexSet indexSetWithIndex:pinnedChats] withRowAnimation:UITableViewRowAnimationNone];
                    [self.chatListTable reloadSections:[NSIndexSet indexSetWithIndex:unpinnedChats] withRowAnimation:UITableViewRowAnimationNone];
                    [self.chatListTable endUpdates];
                }];
                [CATransaction commit];

                MonalAppDelegate* appDelegate = (MonalAppDelegate*)[UIApplication sharedApplication].delegate;
                [appDelegate updateUnread];
            });
    }
    @finally {
       NSLog(@"Finally condition");
        
      
    }
//    size_t unpinnedConCntBefore = self.unpinnedContacts.count;
//    size_t pinnedConCntBefore = self.pinnedContacts.count;
    
//
    
    
}

-(void) refreshContact:(NSNotification*) notification
{
    MLContact* contact = [notification.userInfo objectForKey:@"contact"];
    DDLogInfo(@"Refreshing contact %@ at %@: unread=%lu", contact.contactJid, contact.accountId, (unsigned long)contact.unreadCount);
    
    // if pinning changed we have to move the user to a other section
    if([notification.userInfo objectForKey:@"pinningChanged"])
        [self insertOrMoveContact:contact completion:nil];
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSIndexPath* indexPath = nil;
            for(size_t section = pinnedChats; section < activeChatsViewControllerSectionCnt && !indexPath; section++)
            {
                NSMutableArray* curContactArray = [self getChatArrayForSection:section];
                // check if contact is already displayed -> get coresponding indexPath
                NSUInteger rowIdx = 0;
                for(MLContact* rowContact in curContactArray)
                {
                    if([rowContact isEqualToContact:contact])
                    {
                        //this MLContact instance is used in various ui parts, not just this file --> update all properties but keep the instance intact
                        [rowContact updateWithContact:contact];
                        indexPath = [NSIndexPath indexPathForRow:rowIdx inSection:section];
                        break;
                    }
                    rowIdx++;
                }
            }
            // reload contact entry if we found it
            if(indexPath)
            {
                    DDLogDebug(@"Reloading row at %@", indexPath);
                    [self.chatListTable reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            }
        });
    }
}

-(void) handleRefreshDisplayNotification:(NSNotification*) notification
{
    // filter notifcations from within this class
    if([notification.object isKindOfClass:[ActiveChatsViewController class]])
    {
        return;
    }
    [self refreshDisplay];
}

-(void) handleContactRemoved:(NSNotification*) notification
{
    MLContact* removedContact = [notification.userInfo objectForKey:@"contact"];
    if(removedContact == nil)
    {
        unreachable();
    }
    // ignore all removals that aren't in foreground
    if([removedContact isEqualToContact:[MLNotificationManager sharedInstance].currentContact] == NO)
        return;
    // remove contact from activechats table
    [self refreshDisplay];
    // open placeholder
    [self presentChatWithContact:nil];
}

-(void) displayCheckHUD
{
    // setup HUD
    if(!self.checkHUD)
    {
        self.checkHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        self.checkHUD.removeFromSuperViewOnHide = NO;
        self.checkHUD.label.text = NSLocalizedString(@"Checking", @"addContact - checking HUD");
        self.checkHUD.detailsLabel.text = NSLocalizedString(@"Checking if the jid you provided is correct", @"addContact - checking HUD");
    }
    self.checkHUD.hidden = NO;
}

-(void) hideCheckHUD
{
    if(self.checkHUD)
        self.checkHUD.hidden = YES;
}

-(void) messageSent:(NSNotification*) notification
{
    MLContact* contact = [notification.userInfo objectForKey:@"contact"];
    if(!contact)
        unreachable();
    [self insertOrMoveContact:contact completion:nil];
}

-(void) handleNewMessage:(NSNotification*) notification
{
    MLMessage* newMessage = notification.userInfo[@"message"];
    MLContact* contact = notification.userInfo[@"contact"];
    xmpp* msgAccount = (xmpp*)notification.object;
    if(!newMessage || !contact || !msgAccount)
    {
        unreachable();
        return;
    }
    if([newMessage.messageType isEqualToString:kMessageTypeStatus])
        return;

    // contact.statusMessage = newMessage;
    [self insertOrMoveContact:contact completion:nil];
}

// the chat background image is cached in the MLImageManager
// on iphones all background change event will miss the chatView -> reset the image here
-(void) handleBackgroundChanged
{
    [[MLImageManager sharedInstance] resetBackgroundImage];
}

-(void) insertOrMoveContact:(MLContact*) contact completion:(void (^ _Nullable)(BOOL finished)) completion
{
    dispatch_async(dispatch_get_main_queue(), ^{
            [self.chatListTable performBatchUpdates:^{
                __block NSIndexPath* indexPath = nil;
                for(size_t section = pinnedChats; section < activeChatsViewControllerSectionCnt && !indexPath; section++) {
                    NSMutableArray* curContactArray = [self getChatArrayForSection:section];

                    // check if contact is already displayed -> get coresponding indexPath
                    [curContactArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        MLContact* rowContact = (MLContact *) obj;
                        if([rowContact isEqualToContact:contact])
                        {
                            indexPath = [NSIndexPath indexPathForRow:idx inSection:section];
                            *stop = YES;
                        }
                    }];
                }

                size_t insertInSection = unpinnedChats;
                if(contact.isPinned) {
                    insertInSection = pinnedChats;
                }
                NSMutableArray* insertContactToArray = [self getChatArrayForSection:insertInSection];
                NSIndexPath* insertAtPath = [NSIndexPath indexPathForRow:0 inSection:insertInSection];

                if(indexPath && insertAtPath.section == indexPath.section && insertAtPath.row == indexPath.row)
                {
                    [insertContactToArray replaceObjectAtIndex:insertAtPath.row  withObject:contact];
                    [self.chatListTable reloadRowsAtIndexPaths:@[insertAtPath] withRowAnimation:UITableViewRowAnimationNone];
                    return;
                }
                else if(indexPath)
                {
                    // Contact is already in our active chats list
                    NSMutableArray* removeContactFromArray = [self getChatArrayForSection:indexPath.section];
                    [self.chatListTable deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                    [removeContactFromArray removeObjectAtIndex:indexPath.row];
                    [insertContactToArray insertObject:contact atIndex:0];
                    [self.chatListTable insertRowsAtIndexPaths:@[insertAtPath] withRowAnimation:UITableViewRowAnimationNone];
                }
                else {
                    // Chats does not exists in active Chats yet
                    [insertContactToArray insertObject:contact atIndex:0];
                    [self.chatListTable insertRowsAtIndexPaths:@[insertAtPath] withRowAnimation:UITableViewRowAnimationRight];
                }
            } completion:^(BOOL finished) {
                if(completion) completion(finished);
            }];
        });
}

-(void) viewWillAppear:(BOOL) animated
{
    DDLogDebug(@"active chats view will appear");
    [super viewWillAppear:animated];
    // load contacts
    self.title = @"Chats";
    if(self.unpinnedContacts.count == 0 && self.pinnedContacts.count == 0)
    {
        [self refreshDisplay];
        // only check if the login screen has to be shown if there are no active chats
        [self segueToIntroScreensIfNeeded];
    }
    
    BOOL docreateGroup = [[NSUserDefaults standardUserDefaults] valueForKey:@"is_Create_Group"];
    if(docreateGroup == YES){
        self.isGroupChatSelected = YES;
        [self showContacts];
    }
}

-(void) viewWillDisappear:(BOOL) animated
{
    DDLogDebug(@"active chats view will disappear");
    [super viewWillDisappear:animated];
}

-(void) viewDidAppear:(BOOL) animated
{
    DDLogDebug(@"active chats view did appear");
    [super viewDidAppear:animated];
    
    for(NSDictionary* accountDict in [[DataLayer sharedInstance] enabledAccountList])
    {
        NSString* accountNo = [NSString stringWithFormat:@"%@", accountDict[kAccountID]];
        xmpp* account = [[MLXMPPManager sharedInstance] getConnectedAccountForID:accountNo];
       
        if(!account)
            @throw [NSException exceptionWithName:@"RuntimeException" reason:@"Connected xmpp* object for accountNo is nil!" userInfo:accountDict];
        if(![_mamWarningDisplayed containsObject:accountNo] && account.accountState >= kStateBound && account.connectionProperties.accountDiscoDone)
        {
            if(!account.connectionProperties.supportsMam2)
            {
                UIAlertController* messageAlert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Account %@", @""), account.connectionProperties.identity.jid] message:NSLocalizedString(@"Your server does not support MAM (XEP-0313). That means you could frequently miss incoming messages!! You should switch your server or talk to the server admin to enable this!", @"") preferredStyle:UIAlertControllerStyleAlert];
                [messageAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Close", @"") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                    [_mamWarningDisplayed addObject:accountNo];
                }]];
                //[self presentViewController:messageAlert animated:YES completion:nil];
            }
            else
                [_mamWarningDisplayed addObject:accountNo];
        }
        if(![_smacksWarningDisplayed containsObject:accountNo] && account.accountState >= kStateBound)
        {
            if(!account.connectionProperties.supportsSM3)
            {
                UIAlertController* messageAlert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Account %@", @""), account.connectionProperties.identity.jid] message:NSLocalizedString(@"Your server does not support Stream Management (XEP-0198). That means your outgoing messages can get lost frequently!! You should switch your server or talk to the server admin to enable this!", @"") preferredStyle:UIAlertControllerStyleAlert];
                [messageAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Close", @"") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                    [_smacksWarningDisplayed addObject:accountNo];
                }]];
              //  [self presentViewController:messageAlert animated:YES completion:nil];
            }
            else
                [_smacksWarningDisplayed addObject:accountNo];
        }
    }
    // BOOL groupCreate = [[HelperTools defaultsDB] valueForKey:@"isCreateGroup"];
   
    
}

-(void) segueToIntroScreensIfNeeded
{
    if(![[HelperTools defaultsDB] boolForKey:@"HasSeenIntro"]) {
        [self performSegueWithIdentifier:@"showIntro" sender:self];
        return;
    }
    // display quick start if the user never seen it or if there are 0 enabled accounts
    if(![[HelperTools defaultsDB] boolForKey:@"HasSeenLogin"] || [[DataLayer sharedInstance] enabledAccountCnts].intValue == 0) {
        [self performSegueWithIdentifier:@"showLogin" sender:self];
    }
//    if(![[HelperTools defaultsDB] boolForKey:@"HasSeenPrivacySettings"]) {
//        [self performSegueWithIdentifier:@"showPrivacySettings" sender:self];
//        return;
//    }
}

-(void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) presentChatWithContact:(MLContact*) contact
{
    // only open contact chat when it is not opened yet (needed for opening via notifications and for macOS)
    if([contact isEqualToContact:[MLNotificationManager sharedInstance].currentContact])
    {
        // make sure the already open chat is reloaded and return
        [[MLNotificationQueue currentQueue] postNotificationName:kMonalRefresh object:self userInfo:nil];
        return;
    }
    
    // clear old chat before opening a new one (but not for splitView == YES)
    if([HelperTools deviceUsesSplitView] == NO)
        [self.navigationController popViewControllerAnimated:NO];
    
    // show placeholder if contact is nil, open chat otherwise
    if(contact == nil){
        [self performSegueWithIdentifier:@"showConversationPlaceholder" sender:contact];
    }
    else{
       //[self performSegueWithIdentifier:@"showConversation" sender:contact];
        UIStoryboard *main = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
         chatViewController* chatVC = [main instantiateViewControllerWithIdentifier:@"chatViewController"];

         [chatVC setupWithContact:contact];

        UIBarButtonItem* barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
        self.navigationItem.backBarButtonItem = barButtonItem;
        [self.navigationController pushViewController:chatVC animated:YES];
    }
      
}
-(void) setpasscode{
    
    LAContext *context = [[LAContext alloc] init];

    NSError *error = nil;
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthentication error:&error]) {
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthentication
                localizedReason:@"SAI Locked"
                          reply:^(BOOL success, NSError *error) {
                               dispatch_async(dispatch_get_main_queue(), ^{
                              if (error) {

                              }

      if (success) {
              [self loadViewAfterTouchId];
         } else {
           
         }
                                   
         });
        }];
       } else {

    }
    }

- (IBAction)btnActnTouchId:(id)sender {
    
    LAContext *context = [[LAContext alloc] init];

    NSError *error = nil;
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                localizedReason:@"SAI Locked"
                          reply:^(BOOL success, NSError *error) {
                               dispatch_async(dispatch_get_main_queue(), ^{
                              if (error) {

                              }
      if (success) {
              [self loadViewAfterTouchId];
         } else {
             //for passcode
             [self setpasscode];
         }
                                   
         });
        }];
       } else {
           [self setpasscode];
    }
    }

-(BOOL) showAccountNumberWarningIfNeeded
{
    // Only open contacts list / roster if at least one account is enabled
    if([[DataLayer sharedInstance] enabledAccountCnts].intValue == 0) {
        // Show warning
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"No enabled account found", @"") message:NSLocalizedString(@"Please add a new account under settings first. If you already added your account you may need to enable it under settings", @"") preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Close", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [alert dismissViewControllerAnimated:YES completion:nil];
        }]];
        [self presentViewController:alert animated:YES completion:nil];
        return YES;
    }
    return NO;
}

-(BOOL) shouldPerformSegueWithIdentifier:(NSString*) identifier sender:(id) sender
{
    if([identifier isEqualToString:@"showDetails"])
    {
        //don't show contact details for mucs (they will get their own muc details later on)
        if(((MLContact*)sender).isGroup)
            return NO;
    }
    return YES;
}

//this is needed to prevent segues invoked programmatically
-(void) performSegueWithIdentifier:(NSString*) identifier sender:(id) sender
{
    if([self shouldPerformSegueWithIdentifier:identifier sender:sender] == NO)
    {
        
        if([identifier isEqualToString:@"showDetails"])
        {
            // Display warning
            UIAlertController* groupDetailsWarning = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Groupchat/channel details", @"")
                                                                                message:NSLocalizedString(@"Groupchat/channel details are currently not implemented in Monal.", @"") preferredStyle:UIAlertControllerStyleAlert];
            [groupDetailsWarning addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Ok", @"") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                [groupDetailsWarning dismissViewControllerAnimated:YES completion:nil];
            }]];
            [self presentViewController:groupDetailsWarning animated:YES completion:nil];
        }
        return;
    }
    
    [super performSegueWithIdentifier:identifier sender:sender];
}

-(void) prepareForSegue:(UIStoryboardSegue*) segue sender:(id) sender
{
    DDLogInfo(@"Got segue identifier '%@'", segue.identifier);
    if([segue.identifier isEqualToString:@"showIntro"])
    {
        // needed for >= ios13
        if(@available(iOS 13.0, *))
        {
            MLWelcomeViewController* welcome = (MLWelcomeViewController*) segue.destinationViewController;
            welcome.completion = ^(){
                if([[MLXMPPManager sharedInstance].connectedXMPP count] == 0)
                {
                    if(![[HelperTools defaultsDB] boolForKey:@"HasSeenLogin"]) {
                        [self performSegueWithIdentifier:@"showLogin" sender:self];
                    }
                }
            };
        }
    }
   
    else if([segue.identifier isEqualToString:@"showConversation"])
    {
        UINavigationController* nav = segue.destinationViewController;
        chatViewController* chatVC = (chatViewController*)nav.topViewController;
        UIBarButtonItem* barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
        self.navigationItem.backBarButtonItem = barButtonItem;
        [chatVC setupWithContact:sender];
    }
    else if([segue.identifier isEqualToString:@"showDetails"])
    {
        UINavigationController* nav = segue.destinationViewController;
        ContactDetails* details = (ContactDetails*)nav.topViewController;
        details.contact = sender;
    }
    else if([segue.identifier isEqualToString:@"showContacts"])
    {
        // Only segue if at least one account is enabled
        if([self showAccountNumberWarningIfNeeded]) {
            return;
        }
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"is_Create_Group"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"is_Create_Group"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        UINavigationController* nav = segue.destinationViewController;
        ContactsViewController* contacts = (ContactsViewController*)nav.topViewController;
        contacts.forwardMessage = NO;
        if (self.isGroupChatSelected == YES){
            contacts.isGroupChat = YES;
        }
        contacts.selectContact = ^(MLContact* selectedContact) {
            [[DataLayer sharedInstance] addActiveBuddies:selectedContact.contactJid forAccount:selectedContact.accountId];
            //no success may mean its already there
            [self insertOrMoveContact:selectedContact completion:^(BOOL finished) {
                size_t sectionToUse = unpinnedChats; // Default is not pinned
                if(selectedContact.isPinned) {
                    sectionToUse = pinnedChats; // Insert in pinned section
                }
                NSIndexPath* path = [NSIndexPath indexPathForRow:0 inSection:sectionToUse];
                [self.chatListTable selectRowAtIndexPath:path animated:NO scrollPosition:UITableViewScrollPositionNone];
                if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad )
                {
                     /* Device is iPad */
                    [self presentChatWithContact:selectedContact];


                }else{
                    UIStoryboard *main = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                     chatViewController* chatVC = [main instantiateViewControllerWithIdentifier:@"chatViewController"];

                     [chatVC setupWithContact:selectedContact];

                    UIBarButtonItem* barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
                    self.navigationItem.backBarButtonItem = barButtonItem;
                    [self.navigationController pushViewController:chatVC animated:YES];


                }
            }];
        };
    }
}

-(NSMutableArray*) getChatArrayForSection:(size_t) section
{
    NSMutableArray* chatArray = nil;
    if(section == pinnedChats) {
        chatArray = self.pinnedContacts;
    } else if(section == unpinnedChats) {
        chatArray = self.unpinnedContacts;
    }
    return chatArray;
}
#pragma mark - tableview datasource

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return activeChatsViewControllerSectionCnt;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    if (self.isSearchEnabled == YES){
//        return [self.contacts count];
//    }else{
        if(section == pinnedChats) {
            return [self.pinnedContacts count];
        } else if(section == unpinnedChats) {
            return [self.unpinnedContacts count];
        } else {
            return 0;
        }
  //  }
    return 0;
   
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MLContactCell* cell = (MLContactCell*)[tableView dequeueReusableCellWithIdentifier:@"ContactCell" forIndexPath:indexPath];

    MLContact* chatContact = nil;
    // Select correct contact array
//    if (_isSearchEnabled == YES){
//        MLContact* contact = [self.contacts objectAtIndex:indexPath.row];
//        // Display msg draft or last msg
//        MLMessage* messageRow = [[DataLayer sharedInstance] lastMessageForContact:contact.contactJid forAccount:contact.accountId];
//        [cell initCell:contact withLastMessage:messageRow];
//
//    }else{
        if(indexPath.section == pinnedChats) {
            chatContact = [self.pinnedContacts objectAtIndex:indexPath.row];
        } else {
            chatContact = [self.unpinnedContacts objectAtIndex:indexPath.row];
        }
  //  cell initCell:<#(MLContact * _Nonnull)#> withLastMessage:<#(MLMessage * _Nullable)#>
    
        // Display msg draft or last msg
//
//    MLMessage* messageRow = [[DataLayer sharedInstance] lastMessageForContact:chatContact.contactJid forAccount:chatContact.accountId];
//    [cell initCell:chatContact withLastMessage:messageRow];
    @try {
        MLMessage* messageRow = [[DataLayer sharedInstance] lastMessageForContact:chatContact.contactJid forAccount:chatContact.accountId];
        
        [cell initCell:chatContact withLastMessage:messageRow];
    }
    @catch (NSException *exception) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertController * alert = [UIAlertController
                                        alertControllerWithTitle:@"Error"
                                        message:exception.reason
                                        preferredStyle:UIAlertControllerStyleActionSheet];

           //Add Buttons

           UIAlertAction* ok = [UIAlertAction
                                       actionWithTitle:@"ok"
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction * action) {

                                       }];
            [alert addAction:ok];
            [self presentViewController:alert animated:YES completion:nil];
        });
       NSLog(@"%@", exception.reason);

    }
    @finally {
       NSLog(@"Finally condition");
        [cell initCell:chatContact withLastMessage:nil];
    }
        

        
        
      
   // }
   

    return cell;
}


#pragma mark - tableview delegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}


-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NSLocalizedString(@"Archive chat", @"");
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        MLContact* contact = nil;
        // Delete contact from view
        if(indexPath.section == pinnedChats) {
            contact = [self.pinnedContacts objectAtIndex:indexPath.row];
            [self.pinnedContacts removeObjectAtIndex:indexPath.row];
        } else {
            contact = [self.unpinnedContacts objectAtIndex:indexPath.row];
            [self.unpinnedContacts removeObjectAtIndex:indexPath.row];
        }
        [self.chatListTable deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        // removeActiveBuddy in db
        [[DataLayer sharedInstance] removeActiveBuddy:contact.contactJid forAccount:contact.accountId];
        [self refreshDisplay];
    }
}

-(void) tableView:(UITableView*) tableView didSelectRowAtIndexPath:(NSIndexPath*) indexPath
{
//    if (self.isSearchEnabled == YES){
//
//        MLContact* contact = [self.contacts objectAtIndex:indexPath.row];
//        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad )
//        {
//             /* Device is iPad */
//            [self presentChatWithContact:contact];
//
//
//        }else{
//            UIStoryboard *main = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//             chatViewController* chatVC = [main instantiateViewControllerWithIdentifier:@"chatViewController"];
//
//             [chatVC setupWithContact:contact];
//
//            UIBarButtonItem* barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
//            self.navigationItem.backBarButtonItem = barButtonItem;
//            [self.navigationController pushViewController:chatVC animated:YES];
//
//
//        }
//
//    }else{
        
        MLContact* selected = nil;
        if(indexPath.section == pinnedChats) {
            selected = self.pinnedContacts[indexPath.row];
        } else {
            selected = self.unpinnedContacts[indexPath.row];
        }
        
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad )
        {
             /* Device is iPad */
            [self presentChatWithContact:selected];


        }else{
            UIStoryboard *main = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
             chatViewController* chatVC = [main instantiateViewControllerWithIdentifier:@"chatViewController"];

             [chatVC setupWithContact:selected];

            UIBarButtonItem* barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
            self.navigationItem.backBarButtonItem = barButtonItem;
            [self.navigationController pushViewController:chatVC animated:YES];


        }
   // }
   
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary* contactDic = [self.unpinnedContacts objectAtIndex:indexPath.row];

    [self performSegueWithIdentifier:@"showDetails" sender:contactDic];
}

-(void) loadContactsWithFilter:(NSString*) filter
{
    if(filter && [filter length] > 0){
        self.contacts = [[DataLayer sharedInstance] searchContactsWithString:filter];
        [self.contacts enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
        MLContact *contact = object;
        if ([contact.contactJid isEqualToString:@"enhanced-apk@chat.securesignal.in"]){
            [self.contacts removeObjectAtIndex:idx];
        }
        }];
    }else{
        self.contacts = self.pinnedContacts;
        [self.contacts enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
        MLContact *contact = object;
        if ([contact.contactJid isEqualToString:@"enhanced-apk@chat.securesignal.in"]){
            [self.contacts removeObjectAtIndex:idx];
        }
        }];
    }
       
}

#pragma mark - Search Controller

-(void) didDismissSearchController:(UISearchController*) searchController;
{
    // reset table to list of all contacts without a filter
  //  self.isSearchEnabled = NO;
    [self loadContactsWithFilter:nil];
    [self reloadTable];
}

-(void) updateSearchResultsForSearchController:(UISearchController*) searchController;
{
   // self.isSearchEnabled = YES;
    //SearchVC
//    UIStoryboard *main = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    MLSearchContactViewController *searchVC = [main instantiateViewControllerWithIdentifier:@"SearchVC"];
//    UINavigationController *SearchNav = [[UINavigationController alloc]initWithRootViewController:searchVC];
//   // [self.navigationController pushViewController:searchVC animated:YES];
    //[self loadContactsWithFilter:searchController.searchBar.text];
    //[self reloadTable];
}

#pragma mark - message signals

-(void) reloadTable
{
    if(self.chatListTable.hasUncommittedUpdates) return;
    
    [self.chatListTable reloadData];
}

- (void) searchRefreshDisplay
{
    [self loadContactsWithFilter:nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self reloadTable];
    });
}
#pragma mark - empty data set

- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView
{
    return [UIImage imageNamed:@"pooh"];
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString* text = NSLocalizedString(@"No one is here", @"");
    
    NSDictionary* attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:18.0f],
                                 NSForegroundColorAttributeName: [UIColor darkGrayColor]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString* text = NSLocalizedString(@"When you start talking to someone,\n they will show up here.", @"");
    
    NSMutableParagraphStyle* paragraph = [NSMutableParagraphStyle new];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    paragraph.alignment = NSTextAlignmentCenter;
    
    NSDictionary* attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:14.0f],
                                 NSForegroundColorAttributeName: [UIColor lightGrayColor],
                                 NSParagraphStyleAttributeName: paragraph};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

-(UIColor*) backgroundColorForEmptyDataSet:(UIScrollView*) scrollView
{
    return [UIColor colorNamed:@"chats"];
}

-(BOOL) emptyDataSetShouldDisplay:(UIScrollView*) scrollView
{
    BOOL toreturn = (self.unpinnedContacts.count == 0 && self.pinnedContacts == 0) ? YES : NO;
    if(toreturn)
    {
        // A little trick for removing the cell separators
        self.tableView.tableFooterView = [UIView new];
    }
    return toreturn;
}

#pragma mark - mac menu
-(void) showContacts
{
    // Only segue if at least one account is enabled
    if([self showAccountNumberWarningIfNeeded])
        return;
    [self performSegueWithIdentifier:@"showContacts" sender:self];
}

-(void) showStarMessage
{
    [self performSegueWithIdentifier:@"showStarMesage" sender:self];
}

-(void) showDetails
{
    if([MLNotificationManager sharedInstance].currentContact != nil)
        [self performSegueWithIdentifier:@"showDetails" sender:[MLNotificationManager sharedInstance].currentContact];
}

-(void) deleteConversation
{
    for(size_t section = pinnedChats; section < activeChatsViewControllerSectionCnt; section++)
    {
        NSMutableArray* curContactArray = [self getChatArrayForSection:section];
        // check if contact is already displayed -> get coresponding indexPath
        [curContactArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            MLContact* rowContact = (MLContact*)obj;
            if([rowContact isEqualToContact:[MLNotificationManager sharedInstance].currentContact])
            {
                [self tableView:self.chatListTable commitEditingStyle:UITableViewCellEditingStyleDelete forRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:section]];
                return;
            }
        }];
    }
}

-(void) showSettings
{
   [self performSegueWithIdentifier:@"showSettings" sender:self];
}

-(void) didFinishInviteUsers:(NSMutableArray<MLContact *> *)inviteUser GroupJid:(NSString *)jid GroupName:(NSString *)name{
    if ([inviteUser count] > 0){
        NSMutableArray *jids = [[NSMutableArray alloc]init];
        xmpp* account = [[MLXMPPManager sharedInstance].connectedXMPP objectAtIndex:0];
             [inviteUser enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
                 MLContact *contact = object;
                 
                 [jids addObject:contact.contactJid];
                 [account invitetoMUC:contact.contactJid room:jid];
                 [account grantMemberToMUC:contact.contactJid room:jid];
                 
                 [account changeMUCSubject:jid roomSubject:name];
                 NSString *groupKey = [[HelperTools defaultsDB] stringForKey:jid];
                 if (groupKey != nil){
                     MLECDHKeyExchange * ecdh = [[MLECDHKeyExchange alloc] init];
                     NSString *message = [ecdh sendkeyWithGroupJid:jid key:groupKey];
                     [account sendMessage:message toContact:contact isEncrypted:YES isUpload:NO andMessageId: [[NSUUID UUID] UUIDString]];
                 }
             }];
        
         }
}
@end
