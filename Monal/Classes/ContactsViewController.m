//
//  ContactsViewController.m
//  Monal
//
//  Created by Anurodh Pokharel on 6/14/13.
//
//

#import "ContactsViewController.h"
#import "MLContactCell.h"
#import "MLInfoCell.h"
#import "DataLayer.h"
#import "chatViewController.h"
#import "ContactDetails.h"
#import "addContact.h"
#import "MLNewViewController.h"
#import "CallViewController.h"
#import "MonalAppDelegate.h"
#import "UIColor+Theme.h"
#import "xmpp.h"
#import "MLNotificationQueue.h"
#import "MLMucProcessor.h"
#import "MLOMEMO.h"
#import "MLSignalStore.h"
#import "MBProgressHUD.h"

@interface ContactsViewController ()
@property (nonatomic ,strong) UIBarButtonItem * CreateGroup;
@property (nonatomic ,strong) UIBarButtonItem *BackButtonItem;
@property (nonatomic ,strong) UIBarButtonItem * adduser;
@property (nonatomic, strong) UISearchController* searchController;
@property (nonatomic ,strong) NSMutableArray<MLContact*>* selectedContacts;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (nonatomic, strong) NSMutableArray<MLContact*>* groupContacts;
@property (nonatomic, strong) NSMutableArray<MLContact*>* roasterContacts;

@property (weak, nonatomic) IBOutlet UIButton *groupComposebtn;
@property (nonatomic, strong) NSMutableArray<MLContact*>* contacts;
@property (nonatomic, strong) NSMutableArray<MLContact*>* usercontacts;
@property (nonatomic, strong) MLContact* lastSelectedContact;
@property (nonatomic ,strong) UIButton *SendButton;
@property (nonatomic, strong) MBProgressHUD* checkHUD;
@property (strong, nonatomic) IBOutlet UIView *viewOfSegment;

@end

@implementation ContactsViewController

#pragma mark view life cycle

-(void) viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
        self.navigationItem.title=NSLocalizedString(@"Contacts", @"");

   // self.contactsTable = self.contactsTable;
    self.contactsTable.delegate = self;
    self.contactsTable.dataSource = self;

    self.contacts = [[NSMutableArray alloc] init];
    self.selectedContacts = [[NSMutableArray alloc] init];
    self.roasterContacts = [[NSMutableArray alloc] init];
    self.groupContacts = [[NSMutableArray alloc] init];
    
    
     CGPoint offset = CGPointMake(0, -60);
    [self.contactsTable setContentOffset:offset animated:NO];
    
    if(@available(iOS 15.0, *)) {
        self.contactsTable.sectionHeaderTopPadding = 0.0;
    }
    [self segmentAction:self];

    [self.contactsTable reloadData];
    
    [self.contactsTable registerNib:[UINib nibWithNibName:@"MLContactCell"
                                    bundle:[NSBundle mainBundle]]
                                    forCellReuseIdentifier:@"ContactCell"];
    
    self.splitViewController.preferredDisplayMode=UISplitViewControllerDisplayModeAllVisible;
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    
    self.searchController.searchResultsUpdater = self;
    self.searchController.delegate = self;
    self.searchController.obscuresBackgroundDuringPresentation = NO;
    self.definesPresentationContext = YES;
    
    self.navigationItem.searchController = self.searchController;
    
    self.contactsTable.emptyDataSetSource = self;
    self.contactsTable.emptyDataSetDelegate = self;
    self.CreateGroup.enabled = NO;
    self.segmentedControl.selectedSegmentIndex = 0;
    
    [self.btnAddUser setTitle:@"" forState:UIControlStateNormal];
    [self.groupComposebtn setHidden:YES];
    UIImage *btnImage = [MLImageManager circularImage:[UIImage imageNamed:@"add-user"]];
    [self.btnAddUser setImage:btnImage forState:UIControlStateNormal];
    self.btnAddUser.imageView.contentMode = UIViewContentModeScaleAspectFill;
    UIImage *grpbtnImage = [MLImageManager circularImage:[UIImage imageNamed:@"group"]];
    [self.groupComposebtn setImage:grpbtnImage forState:UIControlStateNormal];
    self.btnAddUser.imageView.contentMode = UIViewContentModeScaleAspectFill;
 self.BackButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(dismiss)];
    if (self.forwardMessage == YES){
        self.SendButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50) ];
        [self.SendButton addTarget:self action:@selector(didSelectforwardButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.SendButton setExclusiveTouch:YES];
        UIImage *btnImage = [UIImage imageNamed:@"ForwardButton"];
        [self.SendButton setImage:btnImage forState:UIControlStateNormal];
        self.SendButton.highlighted = YES;
        [self.view addSubview:self.SendButton];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.SendButton];
    }else if (self.isGroupChat == YES){
        self.CreateGroup = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"974-users"] style:UIBarButtonItemStylePlain target:self action:@selector(GroupComposeButtonPressed:)];
            self.navigationItem.rightBarButtonItems = nil;
            self.navigationItem.rightBarButtonItem = self.CreateGroup;
        [self.segmentedControl setHidden:YES];
       
        [self.btnAddUser setHidden:YES];
        self.navigationItem.leftBarButtonItem = self.BackButtonItem;

        
    }else if(self.addparticipants == YES){
        self.adduser = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"checkmark"] style:UIBarButtonItemStylePlain target:self action:@selector(addUserButtonPressed:)];
        [self.btnAddUser setHidden:YES];
       
        [self.segmentedControl setHidden:YES];
        self.navigationItem.rightBarButtonItem = self.adduser;
    }else{
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone )
        {
            self.navigationItem.leftBarButtonItem = nil;
        }

        self.navigationItem.rightBarButtonItem = nil;
    }
   
//    self.btnAddUser.clipsToBounds = YES;
//    self.btnAddUser.layer.cornerRadius = self.btnAddUser.window.frame.size.width / 2;
    

}

-(void) dealloc
{
}

-(void) dismiss{
//    self.isGroupChat = NO;
//    [self.segmentedControl setHidden:NO];
//    [self.btnAddUser setHidden:NO];
//    self.navigationItem.leftBarButtonItem = nil;
//    self.navigationItem.rightBarButtonItem = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.lastSelectedContact = nil;
    [self refreshDisplay];

    if(self.contacts.count == 0)
        [self reloadTable];
  
}

-(void) viewDidAppear:(BOOL) animated
{
    [super viewDidAppear:animated];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"is_Create_Group"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"is_Create_Group"];
    [[NSUserDefaults standardUserDefaults] synchronize];
   // [self.segmentedControl setHidden:NO];
}


-(void) viewWillDisappear:(BOOL) animated
{
    [super viewWillDisappear:animated];
}

-(void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL) canBecomeFirstResponder
{
    return YES;
}

-(NSArray<UIKeyCommand*>*) keyCommands {
    return @[
        [UIKeyCommand keyCommandWithInput:UIKeyInputEscape modifierFlags:0 action:@selector(close:)]
    ];
}

#pragma mark - jingle

-(void) showCallRequest:(NSNotification*) notification
{
    NSDictionary* dic = notification.object;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString* contactName = [dic objectForKey:@"user"];
        NSString* userName = [dic objectForKey:kUsername];

        UIAlertController* messageAlert =[UIAlertController alertControllerWithTitle:NSLocalizedString(@"Incoming Call", @"") message:[NSString stringWithFormat:NSLocalizedString(@"Incoming audio call to %@ from %@ ", @""),userName,  contactName] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *acceptAction =[UIAlertAction actionWithTitle:NSLocalizedString(@"Accept", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            [self performSegueWithIdentifier:@"showCall" sender:dic];
            
            [[MLXMPPManager sharedInstance] handleCall:dic withResponse:YES];
        }];
        UIAlertAction* closeAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Decline" , @"") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            [[MLXMPPManager sharedInstance] handleCall:dic withResponse:NO];
        }];
        [messageAlert addAction:closeAction];
        [messageAlert addAction:acceptAction];

        [self.tabBarController presentViewController:messageAlert animated:YES completion:nil];
    });
}

#pragma mark - message signals

-(void) reloadTable
{
    if(self.contactsTable.hasUncommittedUpdates) return;
    
    self.contactsTable.dataSource = nil;
    [self.contactsTable reloadData];
    self.contactsTable.dataSource = self;
    [self.contactsTable reloadData];
}

-(void) refreshDisplay
{
    [self loadContactsWithFilter:nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self reloadTable];
    });
}


#pragma mark - chat presentation

-(BOOL) shouldPerformSegueWithIdentifier:(NSString*) identifier sender:(id) sender
{
    if([identifier isEqualToString:@"showDetails"])
    {
        //don't show contact details for mucs (they will get their own muc details later on)
//        if(((MLContact*)sender).isGroup)
//            return NO;
    }
    return YES;
}

//this is needed to prevent segues invoked programmatically
-(void) performSegueWithIdentifier:(NSString*) identifier sender:(id) sender
{
    if([self shouldPerformSegueWithIdentifier:identifier sender:sender] == NO)
    {
//        if([identifier isEqualToString:@"showDetails"])
//        {
//            // Display warning
//            UIAlertController* groupDetailsWarning = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Groupchat/channel details", @"")
//                                                                                message:NSLocalizedString(@"Groupchat/channel details are currently not implemented in Monal.", @"") preferredStyle:UIAlertControllerStyleAlert];
//            [groupDetailsWarning addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Ok", @"") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//                [groupDetailsWarning dismissViewControllerAnimated:YES completion:nil];
//            }]];
//            [self presentViewController:groupDetailsWarning animated:YES completion:nil];
//        }
//        return;
    }
    [super performSegueWithIdentifier:identifier sender:sender];
}

-(void) prepareForSegue:(UIStoryboardSegue*) segue sender:(id) sender
{
    if([segue.identifier isEqualToString:@"showDetails"])
    {
        UINavigationController* nav = segue.destinationViewController;
        ContactDetails* details = (ContactDetails*)nav.topViewController;
        details.contact = sender;
    }
    else if([segue.identifier isEqualToString:@"showNewMenu"])
    {
        MLNewViewController* newView = segue.destinationViewController;
        newView.selectContact = self.selectContact;
    }
}

-(void) loadContactsWithFilter:(NSString*) filter
{
    if(filter && [filter length] > 0){
            
     
            if (self.isGroupChat == YES || self.addparticipants == YES){
                self.usercontacts = [[NSMutableArray alloc] init];
                [self.roasterContacts removeAllObjects];
                    NSMutableArray* result = [[DataLayer sharedInstance] searchContactsWithString:filter];
                    [result enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
                        MLContact *contact = object;
                        
                       
                        if(contact.isGroup || [contact.contactJid containsString:@"@conference.chat.securesignal.in"])
                        {
                            if([@"channel" isEqualToString:contact.mucType] || [@"group" isEqualToString:contact.mucType] ){
                                if (![self.groupContacts containsObject:contact]){
                                    [self.groupContacts addObject:contact];
                                }
                            }else{
                                if (![self.roasterContacts containsObject:contact]){
                                    [self.roasterContacts addObject:contact];
                                   
                                    
                                }
                            }
                        }else{
                            
                            if (![self.roasterContacts containsObject:contact]){
                                [self.roasterContacts addObject:contact];
                            }
                            [self.usercontacts addObject:contact];
                        }
                    }];
            }else{
                self.contacts = [[DataLayer sharedInstance] searchContactsWithString:filter];
                
                switch (self.segmentedControl.selectedSegmentIndex)
                {
                case 0:
                        if (self.addparticipants == YES || self.isGroupChat == YES || self.forwardMessage == YES){
                            [self.roasterContacts removeAllObjects];
                            //[self.btnAddUser setHidden:YES];
                        }else{
                           // [self.btnAddUser setHidden:NO];
                        }
                        [self.roasterContacts removeAllObjects];
                case 1:
                        [self.btnAddUser setHidden:YES];
                   [self.groupContacts removeAllObjects];
                }
                [self.contacts enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
                    MLContact *contact = object;
                   
                    if(contact.isGroup || [contact.contactJid containsString:@"@conference.chat.securesignal.in"])
                    {
                        if([@"channel" isEqualToString:contact.mucType] || [@"group" isEqualToString:contact.mucType] ){
                            if (![self.groupContacts containsObject:contact]){
                                [self.groupContacts addObject:contact];
                            }
                        }else{
                            if (![self.roasterContacts containsObject:contact]){
                                [self.roasterContacts addObject:contact];
                               
                                
                            }
                        }
                    }else{
                        
                        if (![self.roasterContacts containsObject:contact]){
                            [self.roasterContacts addObject:contact];
                        }
                        [self.usercontacts addObject:contact];
                    }
                }];
            }
        }
        else
        {
            if (self.isGroupChat == YES || self.addparticipants == YES){
                self.usercontacts = [[NSMutableArray alloc] init];
                if(!([[DataLayer sharedInstance] enabledAccountCnts].intValue == 0)){
                    NSMutableArray* result = [[DataLayer sharedInstance] contactList];
                    [result enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
                        MLContact *contact = object;
                      
                        if(contact.isGroup || [contact.contactJid containsString:@"@conference.chat.securesignal.in"])
                        {
                            if([@"channel" isEqualToString:contact.mucType] || [@"group" isEqualToString:contact.mucType]  ){
                                if (![self.groupContacts containsObject:contact]){
                                    [self.groupContacts addObject:contact];
                                }
                            }else{
                                if (![self.roasterContacts containsObject:contact]){
                                    [self.roasterContacts addObject:contact];
                                }
                            }
                        }else{
                            if (![self.roasterContacts containsObject:contact] || ![contact.contactJid containsString:@"enhanced-apk@chat.securesignal.in"]){
                                [self.roasterContacts addObject:contact];
                            }
                            [self.usercontacts addObject:contact];
                        }
                    }];
                }
                self.contacts = self.usercontacts;
            }else{
               
                self.contacts = [[DataLayer sharedInstance] contactList];
                [self.contacts enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
                    MLContact *contact = object;
                    if(contact.isGroup || [contact.contactJid containsString:@"@conference.chat.securesignal.in"])
                    {
                        if([contact.mucType isEqualToString:@"channel"] || [contact.mucType isEqualToString:@"group"]){
                            if (![self.groupContacts containsObject:contact]){
                                [self.groupContacts addObject:contact];
                            }
                        }else{
                            if (![self.roasterContacts containsObject:contact]){
                                
                                [self.roasterContacts addObject:contact];
                            }
                        }
                    }else{
                        if (![self.roasterContacts containsObject:contact]){
                           
                            [self.roasterContacts addObject:contact];
                        }
                    }
                }];
            }
        }
}

#pragma mark - Search Controller

-(void) didDismissSearchController:(UISearchController*) searchController;
{
    // reset table to list of all contacts without a filter
    [self loadContactsWithFilter:nil];
    [self reloadTable];
}

-(void) updateSearchResultsForSearchController:(UISearchController*) searchController;
{
    [self loadContactsWithFilter:searchController.searchBar.text];
    [self reloadTable];
}

#pragma mark - tableview datasource

-(NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return nil;
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView*) tableView numberOfRowsInSection:(NSInteger) section
{
    
    switch (self.segmentedControl.selectedSegmentIndex)
    {
    case 0:
           
        return [self.roasterContacts count];
    case 1:
           
        return [self.groupContacts count];
    }

    return [self.contacts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MLContact* contact;
       //= [self.contacts objectAtIndex:indexPath.row];
       switch (self.segmentedControl.selectedSegmentIndex)
       {
       case 0:
           contact = [self.roasterContacts objectAtIndex:indexPath.row];
               break;
       case 1:
               
           contact = [self.groupContacts objectAtIndex:indexPath.row];
               break;
       }
    
    MLContactCell* cell = [tableView dequeueReusableCellWithIdentifier:@"ContactCell"];
    if(!cell)
        cell = [[MLContactCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"ContactCell"];
    [cell initCell:contact withLastMessage:nil];
    if (self.forwardMessage == YES || self.isGroupChat == YES || self.addparticipants == YES){
        if ([self.selectedContacts containsObject:contact])
         {
           cell.accessoryType = UITableViewCellAccessoryCheckmark;
         }
         else
         {
           cell.accessoryType = UITableViewCellAccessoryNone;
         }
        
    }else{
        //cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    }
    
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return _viewOfSegment;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 35;
}


-(NSString *) randomStringWithLength: (int) len {
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];

    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C",[letters characterAtIndex: arc4random() % [letters length]]];
    }

    return [randomString lowercaseString];
}

-(void)addUserButtonPressed:(id)sender{
    if ([self.selectedContacts count] == 0){
        UIAlertController* messageAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Warning", @"") message:NSLocalizedString(@"Please select contacts to invite into group.", @"") preferredStyle:UIAlertControllerStyleAlert];
                       UIAlertAction* closeAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Close", @"") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                        
                         [self dismissViewControllerAnimated:YES completion:nil];
                       }];
                       [messageAlert addAction:closeAction];
                       [self presentViewController:messageAlert animated:YES completion:nil];
        return;
}
    
    NSString *groupKey = [[HelperTools defaultsDB] stringForKey:self.groupJid];
    if (groupKey == nil){
        [self SessionKeyGenerate:self.groupJid];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
         xmpp* account = [[MLXMPPManager sharedInstance].connectedXMPP objectAtIndex:0];
        [self.selectedContacts enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
            MLContact *contact = object;
            
            [account grantMemberToMUC:contact.contactJid room:self.groupJid];
            [account grantRoleToMUC:contact.contactJid room:self.groupJid];
            [account invitetoMUC:contact.contactJid room:self.groupJid];
            [account subscribetoMUC:contact.contactJid room:self.groupJid];
            if (groupKey != nil){
                MLECDHKeyExchange * ecdh = [[MLECDHKeyExchange alloc] init];
                NSString *message = [ecdh sendkeyWithGroupJid:self.groupJid key:groupKey];
                [account sendMessage:message toContact:contact isEncrypted:YES isUpload:NO andMessageId: [[NSUUID UUID] UUIDString]];
            }
            id<contactsViewDelegate> strongDelegate = self.delegate;
            if ([strongDelegate respondsToSelector:@selector(didFinishInviteUsers:GroupJid:GroupName:)]) {
                [strongDelegate didFinishInviteUsers:self.selectedContacts GroupJid:self.groupJid GroupName:self.groupName];

                }
        }];
        
        [self.navigationController popToRootViewControllerAnimated:YES];

    });
    
}

- (void) SessionKeyGenerate:(NSString *)groupJid{
    xmpp* account = [[MLXMPPManager sharedInstance].connectedXMPP objectAtIndex:0];
   
    MLECDHKeyExchange *ecdh = [[MLECDHKeyExchange alloc]init];
    NSArray* accountList = [[DataLayer sharedInstance] accountList];
    NSString *myjid = [NSString stringWithFormat:@"%@@%@",[[accountList objectAtIndex:0] objectForKey:@"username"],[[accountList objectAtIndex:0] objectForKey:@"domain"]];
    NSArray* members = [[DataLayer sharedInstance] getMembersAndParticipantsOfMuc:groupJid forAccountId:account.accountNo];
    [members enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
        NSDictionary *member = object;
        NSString *jid = member[@"participant_jid"];
        if (jid == nil){
            jid = member[@"member_jid"];
        }
        if (![jid isEqualToString:myjid]){
            NSString *message = [ecdh requestKeyWithGroupJid:groupJid];

            MLContact *inviteContact = [MLContact createContactFromJid:jid andAccountNo:account.accountNo];
            [account sendMessage:message toContact:inviteContact isEncrypted:YES isUpload:NO andMessageId:[[NSUUID UUID] UUIDString] ];
          
        }
    }];
}

-(void)GroupComposeButtonPressed:(id)sender{
    if ([self.selectedContacts count] == 0 || self.isGroupChat != YES){
        UIAlertController* messageAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Unable to create group chat", @"") message:NSLocalizedString(@"Please select contacts for  creating room.", @"") preferredStyle:UIAlertControllerStyleAlert];
                       UIAlertAction* closeAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Close", @"") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                        
                         [self dismissViewControllerAnimated:YES completion:nil];
                       }];
                       [messageAlert addAction:closeAction];
                       [self presentViewController:messageAlert animated:YES completion:nil];
        return;
    }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Group Name" message:@"Enter the group name" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *name = alertController.textFields.firstObject.text;
//
        if ([name length] > 0){
            NSString *NewRoomName = name;
                     
           dispatch_async(dispatch_get_main_queue(), ^{
                xmpp* account = [[MLXMPPManager sharedInstance].connectedXMPP objectAtIndex:0];
                NSString *jid = [NSString stringWithFormat:@"%@@conference.chat.securesignal.in",[self randomStringWithLength:16]];
              // NSString *roomJidaccount = [NSString stringWithFormat:@"%@/%@",jid,[account objectForKey:@"username"]];
               [account createMuc:jid subject:NewRoomName completion:^(BOOL status) {
                   if (status == YES){
//
                       MLContact* groupContact = [MLContact createContactFromJid:jid andAccountNo:account.accountNo];
                       if(self.selectContact)
                            self.selectContact(groupContact);
                      
                       
                       [account joinMuc:jid];
                       [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"is_Group_created"];
                       [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"is_Create_Group"];
                       [[NSUserDefaults standardUserDefaults] synchronize];
                       [account moderatorSubscriptiontoRoom:jid];
                       [account moderatorMsgSubscriberoom:jid];
                       [self.selectedContacts enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
                           MLContact *contact = object;
                       
                           [account grantMemberToMUC:contact.contactJid room:jid];
                           [account grantRoleToMUC:contact.contactJid room:jid];
                           [account invitetoMUC:contact.contactJid room:jid];
                            [account subscribetoMUC:contact.contactJid room:jid];
                           [account changeMUCSubject:jid roomSubject:NewRoomName];

                       }];
                       MLECDHKeyExchange * ecdh = [[MLECDHKeyExchange alloc] init];
                      // KeychainInterface *keychain = [[KeychainInterface alloc] init];
                       
                       NSData *MUCKey = [ecdh generatePrivatekey];
                       NSString *base64muckey =  [MUCKey base64EncodedStringWithOptions:0];
                   
                      // [[DataLayer sharedInstance] setGroupkey:base64muckey forContact:jid andAccount:account.accountNo];
                
                       [[HelperTools defaultsDB] setObject:base64muckey forKey:jid];
                           NSString *message = [ecdh sendkeyWithGroupJid:jid key:base64muckey];
                         
                           __block BOOL trustedMemeber = NO;
                            [self.selectedContacts enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
                                MLContact *contact = object;
                                NSArray<NSNumber*>* devices = [account.omemo knownDevicesForAddressName:contact.contactJid];
                                                       for(NSNumber* device in devices) {
                                                           SignalAddress* address = [[SignalAddress alloc] initWithName:contact.contactJid deviceId:(int) device.integerValue];
                                                           NSData* identity = [account.omemo getIdentityForAddress:address];
                              
                                                           // Only add trusted keys to the list
                                                           if([account.omemo isTrustedIdentity:address identityKey:identity])
                                                           {
                                                               trustedMemeber = YES;
                                                               
                                                           }else{
                                                               trustedMemeber = NO;
                                                           }
                                                       }
                                if (trustedMemeber == YES){
                                                               [account sendMessage:message toContact:contact isEncrypted:YES isUpload:NO andMessageId: [[NSUUID UUID] UUIDString]];
                              }
                            }];
                       id<contactsViewDelegate> strongDelegate = self.delegate;
                       if ([strongDelegate respondsToSelector:@selector(didFinishInviteUsers:GroupJid:GroupName:)]) {
                           [strongDelegate didFinishInviteUsers:self.selectedContacts GroupJid:jid GroupName:NewRoomName];

                           }
                       
                     
                       
                       dispatch_async(dispatch_get_main_queue(), ^{
                           [self dismissViewControllerAnimated:YES completion:^{
                           }];
                       });
                      
                   }else{
                       dispatch_async(dispatch_get_main_queue(), ^{
                           UIAlertController* messageAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Unable to create group chat", @"") message:NSLocalizedString(@"Error while creating room ,Please try after sometime.", @"") preferredStyle:UIAlertControllerStyleAlert];
                                          UIAlertAction* closeAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Close", @"") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                                           
                                            [self dismissViewControllerAnimated:YES completion:nil];
                                          }];
                                          [messageAlert addAction:closeAction];
                                          [self presentViewController:messageAlert animated:YES completion:nil];
                       });
                    
                   }
               
               }];
           });
              //  [account joinMuc:jid];
                
//                UIAlertController* messageAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Permission Requested", @"") message:NSLocalizedString(@"The new contact will be added to your contacts list when the person you've added has approved your request.", @"") preferredStyle:UIAlertControllerStyleAlert];
//                UIAlertAction* closeAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Close", @"") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
////                    [self presentChatWithContact:contactObj];
////                    [self dismissViewControllerAnimated:YES completion:nil];
//                }];
//                [messageAlert addAction:closeAction];
//                [self presentViewController:messageAlert animated:YES completion:nil];
            //});
                      // [self setupGroup:name];
        }else{
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Please Enter the valid GroupName" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *dismissAction =  [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                
               
            }];
            [alert addAction:dismissAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
       
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alertController addAction:okAction];
    [alertController addAction:cancelAction];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Enter the group name";
        if ([textField.text length] == 0){
                   UIColor *color = [UIColor redColor];
            textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:textField.placeholder attributes:@{NSForegroundColorAttributeName: color}];
        }
        [[NSNotificationCenter defaultCenter] addObserverForName:UITextFieldTextDidChangeNotification object:textField queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
           
                okAction.enabled = textField.text.length > 0;
           
            
        }];
    }];
    
    
    [self presentViewController:alertController animated:YES completion:nil];
   
}
//-(void)refreshBot:(NSString *)roomjid{
//    xmpp* account = [[MLXMPPManager sharedInstance].connectedXMPP objectAtIndex:0];
//    NSString *botJid = @"enhanced-apk@chat.securesignal.in";
//   NSArray* accountList = [[DataLayer sharedInstance] accountList];
//   NSString *FromJid = [NSString stringWithFormat:@"%@/%@", roomjid,[[accountList objectAtIndex:0] objectForKey:@"username"]];
//    MLContact* botContact = [MLContact createContactFromJid:botJid andAccountNo:account.accountNo];
//   NSDictionary *refresh =  @{@"type":@"TYPE_GROUP_REFRESH",@"roomid":FromJid};
//   NSError *error;
//   NSData *jsonData = [ NSJSONSerialization dataWithJSONObject:refresh options:NSJSONWritingPrettyPrinted error:&error];
//   NSString *refreshMessage = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//   NSData *RefreshData = [refreshMessage dataUsingEncoding:NSUTF8StringEncoding];
//   MLECDHKeyExchange *ecdh = [[MLECDHKeyExchange alloc]init];
//   NSString *pkMessage = [ecdh aesEncryptWithMessageData:RefreshData];
//   NSString* msgid = [[NSUUID UUID] UUIDString];
//   [account sendMessage:pkMessage toContact:botContact isEncrypted:NO isUpload:NO andMessageId:msgid];
//}
- (IBAction)btnActnAddUser:(id)sender {
    
   if (@available(iOS 13.0, *)) {
       if([self showAccountNumberWarningIfNeeded])
           return;
       [self AddNewUserToRoster];
   }
}

- (void)didSelectforwardButton:(id)sender {
    
    if( self.selectedContacts.count == 0){
        self.SendButton.highlighted = YES;
        return;
    }
    [self.selectedContacts enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
        NSString *replytoken = @"^$$%^";
        NSString *REPLY_END_REGEX = @"%reply-end-regex";
        NSString *REPLY_MID_REGEX = @"%reply-mid-regex";
        NSString *localString;
        NSString *messageType;
         if ([self.message.messageText containsString:replytoken]) {
             if ([self.message.messageText containsString:replytoken] && [self.message.messageText containsString:REPLY_MID_REGEX] && [self.message.messageText containsString:REPLY_END_REGEX]){
                             NSArray *items = [self.message.messageText componentsSeparatedByString:@"%reply-end-regex"];
                            // self.MessageText.text = items[1];
                 localString = items[1];
                 
             }else{
                 NSArray *items = [self.message.messageText componentsSeparatedByString:replytoken];
                 NSString *Message = items[1];
                 NSString *Messageurl;
                 NSArray *urlitems;
                 NSArray *MessageItems;
                 NSArray *UserItems;
                 NSString *UserName;
                 if ([Message containsString:@"geo:"]){
                     urlitems = [items[1] componentsSeparatedByString:@"?"];
                     Messageurl = urlitems[0];
                     UserItems = [urlitems[2] componentsSeparatedByString:@"\n"];
                     UserName = urlitems[1];
                     MessageItems = UserItems;
                     
                 }else{
                     urlitems = [items[1] componentsSeparatedByString:@"|"];
                     if (urlitems.count == 1){
                     urlitems = [items[1] componentsSeparatedByString:@"?"];
                     Messageurl = urlitems[0];
                     UserItems = [urlitems[2] componentsSeparatedByString:@"\n"];
                     UserName = urlitems[1];
                     MessageItems = UserItems;
                     }else{
                         Messageurl = urlitems[0];
                         UserItems = [urlitems[1] componentsSeparatedByString:@"?"];
                         UserName = UserItems[1];
                         MessageItems= [UserItems[2] componentsSeparatedByString:@"\n"];
                     }
                 }
                 localString = MessageItems[1];
             }
         }else{
             localString = self.message.messageText;
         }
        if( [self.message.messageType hasPrefix:KMessageTypeReply]){
            messageType = @"Text";
        }else{
            messageType = self.message.messageType;
        }
        MLContact *contact = object;
        NSString* messageID = [[NSUUID UUID] UUIDString];
        NSNumber* messageDBId = [[DataLayer sharedInstance] addMessageHistoryTo:contact.contactJid forAccount:contact.accountId withMessage:localString actuallyFrom:(contact.isGroup ? contact.accountNickInGroup : self.jid) withId:messageID encrypted:contact.isEncrypted messageType:messageType mimeType:nil size:nil];
        NSLog(@"Forwarded message %@", messageDBId);
        [[MLXMPPManager sharedInstance] sendMessage:self.message.messageText toContact:contact isEncrypted:contact.isEncrypted isUpload:NO messageId:messageID
                            withCompletionHandler:nil];
        //AddToActiveBuddyList
        NSLog(@"%@", contact.contactDisplayName);
        NSLog(@"%@", contact.contactJid);
        [[DataLayer sharedInstance] addActiveBuddies:contact.contactJid forAccount:contact.accountId];
        
        [[MLNotificationQueue currentQueue] postNotificationName:kMonalContactRefresh object:self.xmppAccount userInfo:@{@"contact": contact}];
       
    }];
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - tableview delegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}

-(NSString*) tableView:(UITableView*) tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath*) indexPath
{
    NSAssert(indexPath.section == 0, @"Wrong section");
    MLContact* contact = self.contacts[indexPath.row];
    if(contact.isGroup == YES)
        return NSLocalizedString(@"Remove Conversation", @"");
    else
        return NSLocalizedString(@"Remove Contact", @"");
}

-(BOOL) tableView:(UITableView*) tableView canEditRowAtIndexPath:(NSIndexPath*) indexPath
{
    if(tableView == self.view)
        return YES;
    else
        return NO;
}

-(BOOL) tableView:(UITableView*) tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath*) indexPath
{
    if(tableView == self.view)
        return YES;
    else
        return NO;
}

-(void) deleteRowAtIndexPath:(NSIndexPath *) indexPath
{
    MLContact* contact = [self.contacts objectAtIndex:indexPath.row];
    NSString* messageString = [NSString stringWithFormat:NSLocalizedString(@"Remove %@ from contacts?", @""), contact.contactJid];
    NSString* detailString = NSLocalizedString(@"They will no longer see when you are online. They may not be able to access your encryption keys.", @"");
    
    if(contact.isGroup)
    {
        messageString = NSLocalizedString(@"Leave this converstion?", @"");
        detailString = nil;
    }
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:messageString
                                                                   message:detailString preferredStyle:UIAlertControllerStyleActionSheet];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"No", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [alert dismissViewControllerAnimated:YES completion:nil];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Yes", @"") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        // remove contact
        [[MLXMPPManager sharedInstance] removeContact:contact];
        // remove contact from table
        [self.contactsTable beginUpdates];
        switch (self.segmentedControl.selectedSegmentIndex)
        {
        case 0:
            [self.roasterContacts removeObjectAtIndex:indexPath.row];
                break;
        case 1:
             [self.groupContacts removeObjectAtIndex:indexPath.row];
                break;
        }
        //[self.contacts removeObjectAtIndex:indexPath.row];
        [self.contactsTable deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.contactsTable endUpdates];
    }]];
    alert.popoverPresentationController.sourceView = self.contactsTable;
    [self presentViewController:alert animated:YES completion:nil];
}

-(void) tableView:(UITableView*) tableView commitEditingStyle:(UITableViewCellEditingStyle) editingStyle forRowAtIndexPath:(NSIndexPath*) indexPath
{
    if(editingStyle == UITableViewCellEditingStyleDelete)
        [self deleteRowAtIndexPath:indexPath];
}

-(void) tableView:(UITableView*) tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath*) indexPath
{
    if (self.forwardMessage == NO ){
        MLContact* contactDic = [self.contacts objectAtIndex:indexPath.row];
        [self performSegueWithIdentifier:@"showDetails" sender:contactDic];
    }
   
}

-(void) tableView:(UITableView*) tableView didSelectRowAtIndexPath:(NSIndexPath*) indexPath
{
    
    if (self.forwardMessage == YES || self.isGroupChat == YES || self.addparticipants == YES){
        MLContact* contact;
        if (self.segmentedControl.selectedSegmentIndex == 0) {
            contact = [self.roasterContacts objectAtIndex:indexPath.row];
        } else {
            contact = [self.groupContacts objectAtIndex:indexPath.row];
        }
        NSLog(@"Selected %@", contact.contactDisplayName);
                if ([self.selectedContacts containsObject:contact])
                   {
                     [self.selectedContacts removeObject:contact];
                   }
                   else
                   {
                      [self.selectedContacts addObject:contact];
                   }
        
        
          
        if (self.isGroupChat == YES){
            if (self.selectedContacts.count > 0){
                self.CreateGroup.enabled  = YES;
            }else{
                self.CreateGroup.enabled  = NO;
            }
            [tableView reloadData];
        }else{
            if (self.selectedContacts.count > 0){
                self.SendButton.highlighted = NO;
            }else{
                self.SendButton.highlighted = YES;
            }
            [tableView reloadData];
        }
     
    }else{
       
        MLContact* row ;
               switch (self.segmentedControl.selectedSegmentIndex)
               {
               case 0:
                   row = [self.roasterContacts objectAtIndex:indexPath.row];
                       break;
               case 1:
                   row = [self.groupContacts objectAtIndex:indexPath.row];
                       break;
               }

        [self.searchController setActive:NO];
        [self dismissViewControllerAnimated:YES completion:^{
            if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
               {
                  // self.window.rootViewController = rootViewController;
                   if(self.selectContact)
                       self.selectContact(row);
               }else
               {
                   if (self.selectTabContact){
                       self.selectTabContact(row);
                   }
                }
            
        }];
        
    }
   
    
}

#pragma mark - empty data set

-(UIImage*) imageForEmptyDataSet:(UIScrollView*) scrollView
{
    return [UIImage imageNamed:@"river"];
}

-(NSAttributedString*) titleForEmptyDataSet:(UIScrollView*) scrollView
{
    NSString *text = NSLocalizedString(@"You need friends for this ride", @"");
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:18.0f],
                                 NSForegroundColorAttributeName: [UIColor darkGrayColor]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

-(NSAttributedString*) descriptionForEmptyDataSet:(UIScrollView*) scrollView
{
    NSString *text = NSLocalizedString(@"Add new contacts with the + button above. Your friends will pop up here when they can talk", @"");
    
    NSMutableParagraphStyle *paragraph = [NSMutableParagraphStyle new];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    paragraph.alignment = NSTextAlignmentCenter;
    
    NSDictionary* attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:14.0f],
                                 NSForegroundColorAttributeName: [UIColor lightGrayColor],
                                 NSParagraphStyleAttributeName: paragraph};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

-(UIColor*) backgroundColorForEmptyDataSet:(UIScrollView*) scrollView
{
    return [UIColor colorNamed:@"contacts"];
}

-(BOOL) emptyDataSetShouldDisplay:(UIScrollView*) scrollView
{
    if(self.contacts.count == 0)
    {
        // A little trick for removing the cell separators
        self.contactsTable.tableFooterView = [UIView new];
    }
    return self.contacts.count == 0;
}

- (IBAction)segmentAction:(id)sender {
    if  (self.segmentedControl.selectedSegmentIndex == 0 ){
        if (self.addparticipants == YES || self.isGroupChat == YES || self.forwardMessage == YES){
            [self.btnAddUser setHidden:YES];
            [self.groupComposebtn setHidden:YES];
        }else{
          
            [self.groupComposebtn setHidden:YES];
            [self.btnAddUser setHidden:NO];
        }
        } else if (self.segmentedControl.selectedSegmentIndex == 1 ){
            if (self.roasterContacts.count > 0){
                [self.btnAddUser setHidden:YES];
                [self.groupComposebtn setHidden:NO];
              
               
            }
        }
    [self.contactsTable reloadData];
    
}

- (IBAction)composseGRoup:(id)sender {
    MonalAppDelegate *appDelegate = (MonalAppDelegate *)[[UIApplication sharedApplication] delegate];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"is_Create_Group"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    appDelegate.tabBarController.selectedIndex = 0;
    
//    self.isGroupChat = YES;
//    self.CreateGroup = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"974-users"] style:UIBarButtonItemStylePlain target:self action:@selector(composegroup:)];
//    self.navigationItem.rightBarButtonItem = self.CreateGroup;
//    self.navigationItem.leftBarButtonItem = self.BackButtonItem;
//    [self.btnAddUser setHidden:YES];
//    [self.groupComposebtn setHidden:YES];
//    self.segmentedControl.selectedSegmentIndex = 0;
//    [self.segmentedControl setHidden:YES];
//    [self.contactsTable reloadData];
}


-(IBAction) close:(id) sender
{
  
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - AddUserAction

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
                    [self displayCheckHUD];
                    MLContact* contactObj = [MLContact createContactFromJid:jid andAccountNo:account.accountNo];
                    [[MLXMPPManager sharedInstance] addContact:contactObj];
                    [self hideCheckHUD];
//                    UIAlertController* messageAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Permission Requested", @"") message:NSLocalizedString(@"The new contact will be added to your contacts list when the person you've added has approved your request.", @"") preferredStyle:UIAlertControllerStyleAlert];
//                    UIAlertAction* closeAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Close", @"") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
//                     //   if(self.completion)
//                            //self.completion(contactObj);
//                      //  [self presentChatWithContact:contactObj];
//
//                        [self dismissViewControllerAnimated:YES completion:nil];
//                    }];
//                    [messageAlert addAction:closeAction];
                    [self refreshDisplay];
                    if (self.selectTabContact){
                        self.selectTabContact(contactObj);
                    }
                  //  [self presentViewController:messageAlert animated:YES completion:nil];
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


@end
