//
//  buddyDetails.m
//  SworIM
//
//  Created by Anurodh Pokharel on 6/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ContactDetails.h"
#import "MBProgressHUD.h"
#import "MLImageManager.h"
#import "MLConstants.h"
#import "CallViewController.h"
#import "MLXMPPManager.h"
#import "MLDetailsTableViewCell.h"
#import "MLContactDetailHeader.h"
#import "MLKeysTableViewController.h"
#import "MLResourcesTableViewController.h"
#import "MLTextInputCell.h"
#import "HelperTools.h"
#import "MLChatViewHelper.h"
#import "MLOMEMO.h"
#import "MLMucProcessor.h"
#import "MLNotificationQueue.h"
@import MobileCoreServices;
@import AVFoundation;


@interface ContactDetails()
@property (nonatomic, strong) NSString* accountNo;
@property (nonatomic, strong) xmpp* xmppAccount;
@property (nonatomic, weak) UITextField* currentTextField;
@property (nonatomic, strong) NSMutableArray * photos;
@property (nonatomic, assign) NSInteger groupMemberCount;
@property (nonatomic, strong) UIImage* leftImage;
@property (nonatomic, strong) UIImage* rightImage;
@property (nonatomic, strong) MBProgressHUD* saveHUD;
@property (nonatomic, strong) NSArray *members;
@property (nonatomic, assign) BOOL isAdmin;
@property (nonatomic, strong) UIImage *selectedAvatarImage;
@property (nonatomic, strong) UIDocumentPickerViewController *imagePicker;

@end

@class HelperTools;

enum ContactDetailsSections {
    ContactDetailsHeaderSection,
    ContactDetailsAboutSection,
    ContactDetailsConnDetailsSection,
    ContactDetailsSectionsCnt
};

enum ContactDetailsConnDetailsRows {
   // KeysRow,
    ResourcesRow,
    SubscribedStateRow,
    BlockStateRow,
    PinStateRow,
   // OMEMOClearSessionRow,
    ContactDetailsConnDetailsRowsCnt
};

enum ContactDetailsAboutRows {
    NicknameRow,
    GroupSubjectRow,
    ChatSearch,
    ReceivedImagesRow,
    ContactDetailsAboutRowsCnt
    
};

@implementation ContactDetails

#pragma mark view lifecycle
-(void) viewDidLoad
{
    [super viewDidLoad];

    [self.tableView registerNib:[UINib nibWithNibName:@"MLTextInputCell"
                                               bundle:[NSBundle mainBundle]]
         forCellReuseIdentifier:@"TextCell"];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshContact:) name:kMonalContactRefresh object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshBlockState:) name:kMonalBlockListRefresh object:nil];

    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = UITableViewAutomaticDimension;
    self.isAdmin = NO;
    self.members = [[DataLayer sharedInstance] getMembersAndParticipantsOfMuc:self.contact.contactJid forAccountId:self.contact.accountId];
    
    NSArray* accountList = [[DataLayer sharedInstance] accountList];
    NSString *myjid = [NSString stringWithFormat:@"%@@%@",[[accountList objectAtIndex:0] objectForKey:@"username"],[[accountList objectAtIndex:0] objectForKey:@"domain"]];
#if TARGET_OS_MACCATALYST
    //UTI @"public.data" for everything
    NSString *images = (NSString *)kUTTypeImage;
    self.imagePicker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[images] inMode:UIDocumentPickerModeImport];
    self.imagePicker.allowsMultipleSelection = NO;
    self.imagePicker.delegate = self;
#endif

    UIBarButtonItem *menuBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"more"] style:UIBarButtonItemStylePlain target:self action:nil];
   
    if (@available(iOS 13.0, *)) {
        UIAction * GroupSubject = [UIAction actionWithTitle:@"Change Subject" image:[UIImage imageNamed:@"edit" ] identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
            [self changetoNewSubject];
        }];
        UIAction * ChangeIcon = [UIAction actionWithTitle:@"Change Icon" image:[UIImage imageNamed:@"edit" ] identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
                   [self getPhotoAction];
               }];

        NSArray<UIMenuElement *> *Actions = @[GroupSubject,ChangeIcon];
        if (@available(iOS 14.0, *)) {
            menuBarButtonItem.menu = [UIMenu menuWithTitle:@"" children:Actions];
           // self.navigationItem.leftBarButtonItem = nil;
            [self.members enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
            if (self.contact.isGroup){
                
                    NSDictionary *member = object;
                    NSString *jid = member[@"participant_jid"];
                    NSString *affiliation = member[@"affiliation"];
                    if ([jid isEqualToString:myjid] && ([affiliation isEqualToString:@"owner"] || [affiliation isEqualToString:@"admin"])){
                        self.isAdmin = YES;
                        self.navigationItem.rightBarButtonItem = menuBarButtonItem;
                    }
            }
                }];
              
        } else {
                        self.navigationItem.rightBarButtonItem = menuBarButtonItem;
                        [menuBarButtonItem setTarget:self];
                        [menuBarButtonItem setAction:@selector(ShowAttachmentMenu:)];

            
        }
    }
}
- (void)ShowAttachmentMenu:(id)sender
{
     UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@"Settings"
                                 message:Nil
                                 preferredStyle:UIAlertControllerStyleActionSheet];

    //Add Buttons

    UIAlertAction* subject = [UIAlertAction
                                actionWithTitle:@"Change Subject"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
                               
        [self changetoNewSubject];
                                }];

    UIAlertAction* Avatar = [UIAlertAction
                               actionWithTitle:@"Change Icon"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
                                
         [self getPhotoAction];
        
                               }];
//    self.isGroupChatSelected = NO;
//
    UIAlertAction* cancel = [UIAlertAction
                               actionWithTitle:@"Cancel"
                               style:UIAlertActionStyleDestructive
                               handler:^(UIAlertAction * action) {
                                   //Handle no, thanks button
                               }];
    //Add your buttons to alert controller

    [alert addAction:subject];
    [alert addAction:Avatar];
    
    [alert addAction:cancel];

    [self presentViewController:alert animated:YES completion:nil];
}

-(void) changetoNewSubject
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"New Subject"
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
           
            xmpp* account = [[MLXMPPManager sharedInstance].connectedXMPP objectAtIndex:0];
            self.contact.groupSubject = textField.text;
            self.contact.nickName = textField.text;
//            [account updateRosterItem:self.contact.contactJid withName:textField.text];
            [account changeMUCSubject:self.contact.contactJid roomSubject:textField.text];
         
            
        }else{
            UIAlertController * alertvc = [UIAlertController alertControllerWithTitle: @"Warning"
                                             message: @"Enter the subject Name" preferredStyle: UIAlertControllerStyleAlert
                                            ];
              UIAlertAction * action = [UIAlertAction actionWithTitle: @ "Dismiss"
                                        style: UIAlertActionStyleDefault handler: ^ (UIAlertAction * _Nonnull action) {
                                          NSLog(@ "Dismiss Tapped");
                  
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
-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if(!self.contact) return;

    self.tableView.rowHeight = UITableViewAutomaticDimension;

    self.navigationItem.title = self.contact.contactDisplayName;
    xmpp* account = [[MLXMPPManager sharedInstance].connectedXMPP objectAtIndex:0];
    if(self.contact.isGroup) {
       NSArray* members = [[DataLayer sharedInstance] resourcesForContact:self.contact.contactJid];
        self.groupMemberCount = members.count;
        [MLMucProcessor fetchMembersList:self.contact.contactJid onAccount:account];
        self.navigationItem.title = NSLocalizedString(@"Group Chat", @"");
    }
   
     [account fetchBuddiesAvatar:self.contact.contactJid];

    self.accountNo = self.contact.accountId;

    self.contact.isBlocked = ([[DataLayer sharedInstance] isBlockedJid:self.contact.contactJid withAccountNo:self.accountNo] == kBlockingMatchedNodeHost);

    NSDictionary* newSub = [[DataLayer sharedInstance] getSubscriptionForContact:self.contact.contactJid andAccount:self.contact.accountId];
    self.contact.ask = [newSub objectForKey:@"ask"];
    self.contact.subscription = [newSub objectForKey:@"subscription"];

    self.xmppAccount = [[MLXMPPManager sharedInstance] getConnectedAccountForID:self.accountNo];

    [self refreshLock];
    [self refreshMute];

    [self.xmppAccount fetchBlocklist];

    self.saveHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.saveHUD.label.text = NSLocalizedString(@"Saving changes to server", @"");
    self.saveHUD.mode = MBProgressHUDModeIndeterminate;
    self.saveHUD.removeFromSuperViewOnHide = YES;
    self.saveHUD.hidden = YES;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}


-(IBAction) callContact:(id)sender
{
    [self performSegueWithIdentifier:@"showCall" sender:self];
    [[MLXMPPManager sharedInstance] callContact:self.contact];
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"showCall"])
    {
        CallViewController* callScreen = segue.destinationViewController;
        callScreen.contact = self.contact;
    }
    else if([segue.identifier isEqualToString:@"showResources"])
    {
        MLResourcesTableViewController* resourcesVC = segue.destinationViewController;
        resourcesVC.contact = self.contact;
    }
    else if([segue.identifier isEqualToString:@"showKeys"])
    {
        MLKeysTableViewController* keysVC = segue.destinationViewController;
        keysVC.contact = self.contact;
    }
}

#pragma mark - key commands

-(BOOL)canBecomeFirstResponder {
    return YES;
}


// Close the current view
-(void) escapePressed:(UIKeyCommand*)keyCommand
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

// List of custom hardware key commands
- (NSArray<UIKeyCommand *> *)keyCommands {
    return @[
        // esc
        [UIKeyCommand keyCommandWithInput:UIKeyInputEscape modifierFlags:0 action:@selector(escapePressed:)],
    ];
}


#pragma mark - tableview

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 0) return 2; // table view does not like <=1

    return 30.0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* thecell;

    if(indexPath.section == ContactDetailsHeaderSection)
    {
        MLContactDetailHeader* detailCell = (MLContactDetailHeader *)[tableView dequeueReusableCellWithIdentifier:@"headerCell"];

        [detailCell loadContentForContact:self.contact];

        return detailCell;
    }
    else if(indexPath.section == ContactDetailsAboutSection)
    {
        if(indexPath.row == NicknameRow)
        {
            MLTextInputCell* cell = (MLTextInputCell *)[tableView dequeueReusableCellWithIdentifier:@"TextCell"];
            if(self.contact.isGroup)
            {
                [cell initTextCell:self.contact.accountNickInGroup andPlaceholder:nil andDelegate:self];
                [cell disableEditMode];
            }
            else
            {
                [cell initTextCell:[self.contact contactDisplayName] andPlaceholder:NSLocalizedString(@"Set a nickname for this contact", @"") andDelegate:self];
            }
            return cell;
        }
        else if(indexPath.row == GroupSubjectRow)
        {
            MLDetailsTableViewCell* cell = (MLDetailsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"MessageCell"];
            if(self.contact.isGroup) {
                cell.cellDetails.text = self.contact.groupSubject;
            } else {
                cell.cellDetails.text = self.contact.statusMessage;
                if([cell.cellDetails.text isEqualToString:@"(null)"]) {
                    cell.cellDetails.text = @"";
                }
            }
            return cell;
        }
        else if (indexPath.row == ChatSearch){
            UITableViewCell* cell=  (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"TableCell"];
            cell.textLabel.text = NSLocalizedString(@"Chat Search", @"");
            return cell;
        }
        else if(indexPath.row == ReceivedImagesRow)
        {
            UITableViewCell* cell=  (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"TableCell"];
            cell.textLabel.text = NSLocalizedString(@"View Images Received", @"");
            return cell;
        }
        else
            @throw @"Unimplemented RowId in section ContactDetailsAboutSection";
    }
    else
    {
        thecell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Sub"];
//        if(indexPath.row == KeysRow)
//            thecell.textLabel.text = NSLocalizedString(@"Encryption Keys", @"");
        if(indexPath.row == ResourcesRow)
        {
            if(self.contact.isGroup) {
                thecell.textLabel.text = NSLocalizedString(@"Participants", @"");
            } else {
                thecell.textLabel.text = NSLocalizedString(@"Resources", @"");
            }
        }
        else if(indexPath.row == SubscribedStateRow)
        {
            if(self.contact.isGroup == YES)
                thecell.textLabel.text = NSLocalizedString(@"Leave Conversation", @"");
            else
            {
                if([self.contact isSubscribed] == YES)
                    thecell.textLabel.text = NSLocalizedString(@"Remove Contact", @"");
                else
                    thecell.textLabel.text = NSLocalizedString(@"Add Contact", @"");
            }
        }
        else if(indexPath.row == BlockStateRow)
        {
            // hide block button if the server does not support it
            thecell.hidden = !self.xmppAccount.connectionProperties.supportsBlocking;

            if(!self.contact.isBlocked)
                thecell.textLabel.text = NSLocalizedString(@"Block Sender", @"");
            else
                thecell.textLabel.text = NSLocalizedString(@"Unblock Sender", @"");
        }
        else if(indexPath.row == PinStateRow)
        {
            if(self.contact.isPinned)
                thecell.textLabel.text = NSLocalizedString(@"Unpin Chat", @"");
            else
                thecell.textLabel.text = NSLocalizedString(@"Pin Chat", @"");
        }
//        else if(indexPath.row == OMEMOClearSessionRow)
//        {
//            thecell.textLabel.text = NSLocalizedString(@"Clear omemo session", @"DEBUG - ContactDetails");
//        }
        thecell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return thecell;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    if(section == ContactDetailsHeaderSection) return 1;
    if(section == ContactDetailsAboutSection) return ContactDetailsAboutRowsCnt;
    if(section == ContactDetailsConnDetailsSection) return ContactDetailsConnDetailsRowsCnt;

    return 0; //some default shouldnt reach this
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return ContactDetailsSectionsCnt;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString* toreturn = nil;
    if(section == ContactDetailsAboutSection)
        toreturn = NSLocalizedString(@"About", @"");

    if(section == ContactDetailsConnDetailsSection)
        toreturn = NSLocalizedString(@"Connection Details", @"");

    return toreturn;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];

    if(indexPath.section == ContactDetailsHeaderSection) return;

    if(indexPath.section == ContactDetailsAboutSection){
        if(indexPath.row < 2) return;
        if (indexPath.row == ChatSearch){
            [self dismissViewControllerAnimated:YES completion:^{
                [[MLNotificationQueue currentQueue] postNotificationName:kMonalchatSearch object:self.xmppAccount userInfo:nil];
            }];
        }else{
            [self showChatImages];
        }
       
    }
    else  {
        switch(indexPath.row)
        {
//            case KeysRow:  {
//                [self performSegueWithIdentifier:@"showKeys" sender:self];
//                break;
//            }
            case ResourcesRow:  {
                [self performSegueWithIdentifier:@"showResources" sender:self];
                break;
            }
            case SubscribedStateRow:  {
                if(self.contact.isGroup) {
                    [self removeContact]; // works for muc too
                } else  {
                    if([self.contact isSubscribed] == YES)
                    {
                        [self removeContact];
                    }  else  {
                        [self addContact];
                    }
                }
                break;
            }
            case BlockStateRow:  {
                if(![self checkBlockingSupport]) return;
                if(self.contact.isBlocked)
                {
                    [self unBlockContact];
                }
                else
                {
                    [self blockContact];
                }
                self.saveHUD.hidden = NO;
                // hide after 20 seconds
                [self.saveHUD hideAnimated:YES afterDelay:20];
                break;
            }
            case PinStateRow:  {
                if(self.contact.isPinned)
                {
                    [[DataLayer sharedInstance] unPinChat:self.accountNo andBuddyJid:self.contact.contactJid];
                }
                else
                {
                    [[DataLayer sharedInstance] pinChat:self.accountNo andBuddyJid:self.contact.contactJid];
                }
                self.contact.isPinned = !self.contact.isPinned;
                // Update button text
                [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
                // Update color in activeViewController
                [[MLNotificationQueue currentQueue] postNotificationName:kMonalContactRefresh object:self.xmppAccount userInfo:@{@"contact":self.contact, @"pinningChanged": @YES}];
                break;
            }
//            case OMEMOClearSessionRow:  {
//                [self.xmppAccount.omemo clearAllSessionsForJid:self.contact.contactJid];
//                break;
//            }
        }
    }
}

-(void) addContact {
    NSString* messageString = [NSString  stringWithFormat:NSLocalizedString(@"Add %@ to your contacts?", @""), self.contact.contactJid];
    NSString* detailString = NSLocalizedString(@"They will see when you are online. They will be able to send you encrypted messages.", @"");

    UIAlertController* alert = [UIAlertController alertControllerWithTitle:messageString
                                                                   message:detailString preferredStyle:UIAlertControllerStyleActionSheet];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"No", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [alert dismissViewControllerAnimated:YES completion:nil];
    }]];

    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Yes", @"") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [[MLXMPPManager sharedInstance] addContact:self.contact];
    }]];

    alert.popoverPresentationController.sourceView = self.tableView;

    [self presentViewController:alert animated:YES completion:nil];
}

-(void) removeContact
{
    NSString* messageString = [NSString stringWithFormat:NSLocalizedString(@"Remove %@ from contacts?", @""), self.contact.contactJid];
    NSString* detailString = NSLocalizedString(@"They will no longer see when you are online. They may not be able to send you encrypted messages.", @"");

    BOOL isMUC = self.contact.isGroup;
    if(isMUC)
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
        [[MLXMPPManager sharedInstance] removeContact:self.contact];
        // announce that the contact was removed
        [[MLNotificationQueue currentQueue] postNotificationName:kMonalContactRemoved object:self userInfo:@{@"contact": self.contact}];
        [self dismissViewControllerAnimated:YES completion:nil];
    }]];

    alert.popoverPresentationController.sourceView = self.tableView;

    [self presentViewController:alert animated:YES completion:nil];
}

-(BOOL) checkBlockingSupport
{
    if(!self.xmppAccount.connectionProperties.supportsBlocking)
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Blocking not supported", @"") message:NSLocalizedString(@"The server does not support blocking", @"") preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction* closeAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Close", @"") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        }];

        [alert addAction:closeAction];
        [self presentViewController:alert animated:YES completion:nil];
        return NO;
    }
    return YES;
}

-(void) blockContact {
    if(!self.xmppAccount.connectionProperties.supportsBlocking) return;
    [[MLXMPPManager sharedInstance] blocked:YES Jid:self.contact];
}

-(void) unBlockContact
{
    if(!self.xmppAccount.connectionProperties.supportsBlocking) return;
    [[MLXMPPManager sharedInstance] blocked:NO Jid:self.contact];
}

-(void) showChatImages
{
    NSMutableArray* images = [[DataLayer sharedInstance] allAttachmentsFromContact:self.contact.contactJid forAccount:self.accountNo];

    if(!self.photos)
    {
        self.photos = [[NSMutableArray alloc] init];
        for(NSDictionary* imageInfo  in images)
            if(![imageInfo[@"needsDownloading"] boolValue] && [imageInfo[@"mimeType"] hasPrefix:@"image/"])
            {
                UIImage* image = [UIImage imageWithContentsOfFile:imageInfo[@"cacheFile"]];
                IDMPhoto* photo = [IDMPhoto photoWithImage:image];
                [self.photos addObject:photo];
            }
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        if(self.photos.count > 0) {
            IDMPhotoBrowser* browser = [[IDMPhotoBrowser alloc] initWithPhotos:self.photos];
            browser.delegate = self;
            browser.autoHideInterface = NO;
            browser.displayArrowButton = YES;
            browser.displayCounterLabel = YES;
            browser.displayActionButton = YES;
            browser.displayToolbar = YES;

            self.leftImage=[UIImage imageNamed:@"IDMPhotoBrowser_arrowLeft"];
            self.rightImage=[UIImage imageNamed:@"IDMPhotoBrowser_arrowRight"];
            browser.leftArrowImage = self.leftImage;
            browser.rightArrowImage = self.rightImage;
            UIBarButtonItem* close = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", @"") style:UIBarButtonItemStyleDone target:self action:@selector(closePhotos)];
                          browser.navigationItem.leftBarButtonItem = close;

            UINavigationController* nav =[[UINavigationController alloc] initWithRootViewController:browser];

            [self presentViewController:nav animated:YES completion:nil];
        } else  {
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Nothing to see", @"") message:NSLocalizedString(@"You have not received any images in this conversation.", @"") preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Close", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [alert dismissViewControllerAnimated:YES completion:nil];
            }]];
            [self presentViewController:alert animated:YES completion:nil];
        }
    });
}

-(void) closePhotos {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)close:(id)sender
{
    [self textFieldShouldEndEditing:self.currentTextField];
    if(self.completion) self.completion();
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}


-(IBAction) muteContact:(id)sender
{
    if(self.contact.isMuted == NO) {
        [[DataLayer sharedInstance] muteJid:self.contact.contactJid onAccount:self.accountNo];
    } else {
        [[DataLayer sharedInstance] unMuteJid:self.contact.contactJid onAccount:self.accountNo];
    }
    [self refreshMute];
}

-(void) refreshMute
{
    self.contact.isMuted = [[DataLayer sharedInstance] isMutedJid:self.contact.contactJid onAccount:self.accountNo];
    dispatch_async(dispatch_get_main_queue(), ^{
        NSIndexPath* path = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationNone];
    });
}

-(IBAction) toggleEncryption:(id)sender
{
#ifndef DISABLE_OMEMO
    NSArray* devices = [self.xmppAccount.omemo knownDevicesForAddressName:self.contact.contactJid];
    [MLChatViewHelper<ContactDetails*>
        toggleEncryptionForContact:self.contact withKnownDevices:devices withSelf:self afterToggle:^() {
        [self refreshLock];
    }];
#endif
}

-(void) refreshLock
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSIndexPath* path = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationNone];
    });
}

#pragma mark - textfield delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void) refreshContact:(NSNotification*) notification
{
    MLContact* contactUpdate = notification.userInfo[@"contact"];
    if(contactUpdate && [contactUpdate isEqualToContact:self.contact])
    {
        weakify(self);
        dispatch_async(dispatch_get_main_queue(), ^{
            strongify(self);
            self.navigationItem.title = [self.contact contactDisplayName];
            // Update nick name
            self.contact.nickName = contactUpdate.nickName;
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:NicknameRow inSection:ContactDetailsAboutSection]] withRowAnimation:UITableViewRowAnimationNone];
            self.saveHUD.hidden = YES;
        });
    }
}

-(void) refreshBlockState:(NSNotification*) notification
{
    if([notification.userInfo[@"accountNo"] isEqualToString:self.accountNo]) {
        weakify(self);
        dispatch_async(dispatch_get_main_queue(), ^{
            strongify(self);
            self.contact.isBlocked = ([[DataLayer sharedInstance] isBlockedJid:self.contact.contactJid withAccountNo:self.accountNo] == kBlockingMatchedNodeHost);
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:BlockStateRow inSection:ContactDetailsConnDetailsSection]] withRowAnimation:UITableViewRowAnimationNone];
            self.saveHUD.hidden = YES;
        });
    }
}

-(BOOL) textFieldShouldEndEditing:(UITextField *)textField {
    if(!textField)
        return NO;

    //update roster on our server if the nick changed
    if(!self.contact.nickName || ![self.contact.nickName isEqualToString:textField.text])
    {
        //no need to update our db here, this will be done automatically on incoming roster push that gets initiated by our roster set with the new name
        [self.xmppAccount updateRosterItem:self.contact.contactJid withName:textField.text];
        self.saveHUD.hidden = NO;
    }

    return YES;
}


- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    self.currentTextField = textField;
    return YES;
}

#pragma mark - photo browser delegate
- (NSUInteger)numberOfPhotosInPhotoBrowser:(IDMPhotoBrowser *)photoBrowser {
    return self.photos.count;
}

- (id <IDMPhoto>)photoBrowser:(IDMPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < self.photos.count) {
        return [self.photos objectAtIndex:index];
    }
    return nil;
}

#pragma mark - doc picker
-(void)pickImgFile:(id)sender
{
    [self presentViewController:self.imagePicker animated:YES completion:nil];

    return;
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls
{
    NSFileCoordinator *coordinator = [[NSFileCoordinator alloc] init];
    [coordinator coordinateReadingItemAtURL:urls.firstObject options:NSFileCoordinatorReadingForUploading error:nil byAccessor:^(NSURL * _Nonnull newURL) {
        NSData *data =[NSData dataWithContentsOfURL:newURL];
        UIImage *pickImg = [UIImage imageWithData:data];
        [self useAvatarImage:pickImg];
    }];
}

-(void)getPhotoAction
{
    xmpp* account = [[MLXMPPManager sharedInstance].connectedXMPP objectAtIndex:0];

    if (!account) return;
    
    UIAlertController *actionControll = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Select Action", @"")
                                                                            message:nil preferredStyle:UIAlertControllerStyleActionSheet];

#if TARGET_OS_MACCATALYST
    [self pickImgFile:nil];
#else
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;

    UIAlertAction* cameraAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Camera", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:imagePicker animated:YES completion:nil];
    }];

    UIAlertAction* photosAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Photos", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if(granted)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self presentViewController:imagePicker animated:YES completion:nil];
                });
            }
        }];
    }];

    // Set image
    if (@available(iOS 13.0, *)) {
        [cameraAction setValue:[[UIImage systemImageNamed:@"camera"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
        [photosAction setValue:[[UIImage systemImageNamed:@"photo"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    } else {
        [cameraAction setValue:[[UIImage imageNamed:@"714-camera"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    }
    [actionControll addAction:cameraAction];
    [actionControll addAction:photosAction];
#endif
    
    // Set image
    [actionControll addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [actionControll dismissViewControllerAnimated:YES completion:nil];
    }]];

//    actionControll.popoverPresentationController.sourceView = self.userAvatarImageView;
    [self presentViewController:actionControll animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *, id> *)info
{
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    if([mediaType isEqualToString:(NSString*) kUTTypeImage]) {
        UIImage *selectedImage = info[UIImagePickerControllerEditedImage];
        if(!selectedImage) selectedImage = info[UIImagePickerControllerOriginalImage];
        
        TOCropViewController *cropViewController = [[TOCropViewController alloc] initWithImage:selectedImage];
        cropViewController.delegate = self;
        cropViewController.transitioningDelegate = nil;
        //set square aspect ratio and don't let the user change that (this is a avatar which should be square for maximum compatibility with other clients)
        cropViewController.aspectRatioPreset = TOCropViewControllerAspectRatioPresetSquare;
        cropViewController.aspectRatioLockEnabled = YES;
        cropViewController.aspectRatioPickerButtonHidden = YES;
        
        UINavigationController* cropRootController = [[UINavigationController alloc] initWithRootViewController:cropViewController];
        [picker dismissViewControllerAnimated:YES completion:^{
            [self presentViewController:cropRootController animated:YES completion:nil];
        }];
    }
    else
        [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void) imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void) useAvatarImage:(UIImage*) selectedImg
{
    /*
    //small sample image
    UIGraphicsImageRenderer* renderer = [[UIGraphicsImageRenderer alloc] initWithSize:CGSizeMake(200, 200)];
    selectedImg = [renderer imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull context) {
        [[UIColor darkGrayColor] setStroke];
        [context strokeRect:renderer.format.bounds];
        [[UIColor colorWithRed:158/255.0 green:215/255.0 blue:245/255.0 alpha:1] setFill];
        [context fillRect:CGRectMake(1, 1, 140, 140)];
    }];
    */
    
    //check if conversion can be done and display error if not
    if(selectedImg && UIImageJPEGRepresentation(selectedImg, 1.0))
    {
       self.selectedAvatarImage = selectedImg;
        xmpp* account = [[MLXMPPManager sharedInstance].connectedXMPP objectAtIndex:0];
       // [account publishAvatar:selectedImg];
        [account publishGroupAvatar:selectedImg groupJid:self.contact.contactJid];
//        [self.userAvatarImageView setImage:self.selectedAvatarImage];
//        self.avatarChanged = YES;
    }
    else
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error", @"")
                                                                       message:NSLocalizedString(@"Can't convert the image to jpeg format.", @"") preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Close", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [alert dismissViewControllerAnimated:YES completion:nil];
        }]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}


#pragma mark -- TOCropViewController delagate

- (void)cropViewController:(nonnull TOCropViewController *)cropViewController
    didCropToImage:(nonnull UIImage *)image withRect:(CGRect)cropRect
                     angle:(NSInteger)angle
{
    [self useAvatarImage:image];
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
