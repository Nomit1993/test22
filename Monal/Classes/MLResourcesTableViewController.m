//
//  MLResourcesTableViewController.m
//  Monal
//
//  Created by Anurodh Pokharel on 12/30/18.
//  Copyright © 2018 Monal.im. All rights reserved.
//

#import "MLResourcesTableViewController.h"
#import "DataLayer.h"
#import "xmpp.h"
#import "MLXMPPManager.h"
#import "MLContactCell.h"
#import "MLParticipantCell.h"
#import "ContactsViewController.h"
#import "MLMucProcessor.h"
#import "MLNotificationQueue.h"
#import "MLNotificationManager.h"
#import <monalxmpp/monalxmpp-Swift.h>
@interface MLResourcesTableViewController ()
@property (nonatomic, strong) NSArray *resources;
@property (nonatomic, strong) NSArray *members;
@property (nonatomic ,strong) UIBarButtonItem * addParticipants;
@property (nonatomic, strong) NSMutableDictionary *versionInfoDic;
@property (nonatomic, assign) BOOL isAdmin;
@end

@implementation MLResourcesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(self.contact.isGroup) {
        [self.tableView registerNib:[UINib nibWithNibName:@"MLParticipantCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"ParticipantCell"];
        self.navigationItem.title=NSLocalizedString(@"Participants",@ "");
      
    } else {
        self.navigationItem.title=NSLocalizedString(@"Resources",@ "");
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshSoftwareVersion:) name: kMonalXmppUserSoftWareVersionRefresh object:nil];
        if (!self.versionInfoDic)
        {
            self.versionInfoDic = [[NSMutableDictionary alloc] init];
        }
    }    
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.resources = [[DataLayer sharedInstance] resourcesForContact:self.contact.contactJid];
    
    if (!self.contact.isGroup) {
        [self querySoftwareVersion];
        [self refreshSoftwareVersion:nil];
    }else{
        self.isAdmin = NO;
        self.addParticipants = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"907-plus-rounded-square"] style:UIBarButtonItemStylePlain target:self action:@selector(addParticipants:)];
        self.members = [[DataLayer sharedInstance] getMembersAndParticipantsOfMuc:self.contact.contactJid forAccountId:self.contact.accountId];
        NSArray* accountList = [[DataLayer sharedInstance] accountList];
        NSString *myjid = [NSString stringWithFormat:@"%@@%@",[[accountList objectAtIndex:0] objectForKey:@"username"],[[accountList objectAtIndex:0] objectForKey:@"domain"]];
        [self.members enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
            NSDictionary *member = object;
            NSString *jid = member[@"participant_jid"];
            NSString *affiliation = member[@"affiliation"];
          if ([jid isEqualToString:myjid] && ([affiliation isEqualToString:@"owner"] || [affiliation isEqualToString:@"admin"])){
                self.isAdmin = YES;
              self.navigationItem.rightBarButtonItem = self.addParticipants;
            }
        }];
        
      

    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if(!self.contact.isGroup)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:kMonalXmppUserSoftWareVersionRefresh];
    }
}

-(void)addParticipants:(id)sender{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ContactsViewController* contacts = [storyboard instantiateViewControllerWithIdentifier:@"ContactsVC"];
    contacts.addparticipants = YES;
    contacts.delegate = self;
    contacts.groupJid = self.contact.contactJid;
    [self.navigationController pushViewController:contacts animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if(!self.contact.isGroup)
    {
        return self.resources.count;
    }
    else
    {
        return 1;
    }    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(!self.contact.isGroup)
    {
        return 3;
    }
    else
    {
        return self.members.count;
    }
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    
    if(section>=self.resources.count) {
        return @"";
    }
    NSString* resourceTitle = [[self.resources objectAtIndex:section] objectForKey:@"resource"];
    return  resourceTitle;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    if (self.contact.isGroup)
    {
        MLParticipantCell* cell = [tableView dequeueReusableCellWithIdentifier:@"ParticipantCell"];
        NSDictionary *member = [self.members objectAtIndex:indexPath.row];
        NSString *jid = member[@"participant_jid"];
        if (jid == nil){
            jid = member[@"member_jid"];
        }
        NSArray* accountList = [[DataLayer sharedInstance] accountList];
        NSString *myjid = [NSString stringWithFormat:@"%@@%@",[[accountList objectAtIndex:0] objectForKey:@"username"],[[accountList objectAtIndex:0] objectForKey:@"domain"]];
        if ([jid isEqualToString:myjid] && ([member[@"affiliation"] isEqualToString:@"owner"] || [member[@"affiliation"] isEqualToString:@"admin"])){
              self.isAdmin = YES;
            self.navigationItem.rightBarButtonItem = self.addParticipants;
          }
        xmpp* account = [[MLXMPPManager sharedInstance].connectedXMPP objectAtIndex:0];
        MLContact* contactObj = [MLContact createContactFromJid:jid andAccountNo:account.accountNo];
        
        cell.affilliation = member[@"affiliation"];
        [cell initCell:contactObj];
        return cell;
    }
    else
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"resource" forIndexPath:indexPath];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        NSString* resourceTitle = [[self.resources objectAtIndex:indexPath.section] objectForKey:@"resource"];
        if (resourceTitle)
        {
            NSDictionary* versionDataDictionary = [self.versionInfoDic objectForKey:resourceTitle];
            
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = [NSString stringWithFormat:@"%@%@",
                                              NSLocalizedString(@"Name: ", @""),
                                              (versionDataDictionary[@"platform_App_Name"] == nil) ? @"":versionDataDictionary[@"platform_App_Name"]];
                    break;
                case 1:
                    cell.textLabel.text = [NSString stringWithFormat:@"%@%@",
                                              NSLocalizedString(@"Os: ", @""),
                                              (versionDataDictionary[@"platform_OS"] == nil) ? @"":versionDataDictionary[@"platform_OS"]];
                    break;
                case 2:
                    cell.textLabel.text = [NSString stringWithFormat:@"%@%@",
                                              NSLocalizedString(@"Version: ", @""),
                                              (versionDataDictionary[@"platform_App_Version"] == nil) ? @"":versionDataDictionary[@"platform_App_Version"]];
                    break;
                default:
                    break;
            }
        }
        return cell;
    }
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 65;
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
    if(contact == nil)
        [self performSegueWithIdentifier:@"showConversationPlaceholder" sender:contact];
    else
        [self performSegueWithIdentifier:@"showConversation" sender:contact];
}
- (UIContextMenuConfiguration *)tableView:(UITableView *)tableView contextMenuConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath point:(CGPoint)point API_AVAILABLE(ios(13.0)){
    
    NSArray* accountList = [[DataLayer sharedInstance] accountList];
    NSString *myjid = [NSString stringWithFormat:@"%@@%@",[[accountList objectAtIndex:0] objectForKey:@"username"],[[accountList objectAtIndex:0] objectForKey:@"domain"]];
    [self.members enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
        NSDictionary *member = object;
        NSString *jid = member[@"participant_jid"];
        NSString *affiliation = member[@"affiliation"];
        
      if ([jid isEqualToString:myjid] && [affiliation isEqualToString:@"owner"]){
            self.isAdmin = YES;
           
      }else if([jid isEqualToString:myjid] && [affiliation isEqualToString:@"admin"]){
          self.isAdmin = YES;
      }
        
    }];
        return [UIContextMenuConfiguration configurationWithIdentifier:nil previewProvider:nil actionProvider:^UIMenu * _Nullable(NSArray<UIMenuElement *> * _Nonnull suggestedActions) {
            UIAction *admin = [UIAction actionWithTitle:@"Grant admin privileges" image:nil identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
                xmpp* account = [[MLXMPPManager sharedInstance].connectedXMPP objectAtIndex:0];
                NSDictionary *member = [self.members objectAtIndex:indexPath.row];
                NSString *jid = member[@"participant_jid"];
                 if (jid == nil){
                     jid = member[@"member_jid"];
                 }
                [MLMucProcessor setAffiliation:jid room:self.contact.contactJid type:@"admin" onAccount:account];
                [self dismissViewControllerAnimated:YES completion:nil];
            }];
            UIAction *message = [UIAction actionWithTitle:@"send message" image:nil identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
                xmpp* account = [[MLXMPPManager sharedInstance].connectedXMPP objectAtIndex:0];
                NSDictionary *member = [self.members objectAtIndex:indexPath.row];
                NSString *jid = member[@"participant_jid"];
                 if (jid == nil){
                     jid = member[@"member_jid"];
                 }
                
                if(self.selectContact)
                    self.selectContact([MLContact createContactFromJid:jid andAccountNo:account.accountNo]);
                
                    [self dismissViewControllerAnimated:YES completion:nil];
            }];
            UIAction *kickout = [UIAction actionWithTitle:@"kickout" image:nil identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
                xmpp* account = [[MLXMPPManager sharedInstance].connectedXMPP objectAtIndex:0];
                NSDictionary *member = [self.members objectAtIndex:indexPath.row];
                NSString *jid = member[@"participant_jid"];
                 if (jid == nil){
                     jid = member[@"member_jid"];
                 }
                NSMutableDictionary* item = [[NSMutableDictionary alloc ] init];
                item[@"jid"] = jid;
               // item[@"nick"] = presenceNode.fromResource;
                [MLMucProcessor setAffiliation:jid room:self.contact.contactJid type:@"none" onAccount:account];
               // [[DataLayer sharedInstance] removeParticipant:item fromMuc:self.contact.contactJid forAccountId:account.accountNo];
                [self dismissViewControllerAnimated:YES completion:nil];
            }];
            UIAction *revoke_Admin = [UIAction actionWithTitle:@"Remove admin privileges" image:nil identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
                xmpp* account = [[MLXMPPManager sharedInstance].connectedXMPP objectAtIndex:0];
                NSDictionary *member = [self.members objectAtIndex:indexPath.row];
                NSString *jid = member[@"participant_jid"];
                 if (jid == nil){
                     jid = member[@"member_jid"];
                 }
                [MLMucProcessor setAffiliation:jid room:self.contact.contactJid type:@"member" onAccount:account];
                [self dismissViewControllerAnimated:YES completion:nil];
            }];
             if(self.contact.isGroup) {
                 NSArray* accountList = [[DataLayer sharedInstance] accountList];
                 NSString *myjid = [NSString stringWithFormat:@"%@@%@",[[accountList objectAtIndex:0] objectForKey:@"username"],[[accountList objectAtIndex:0] objectForKey:@"domain"]];
                 
                 NSDictionary *member = [self.members objectAtIndex:indexPath.row];
                 NSString *jid = member[@"participant_jid"];
                  if (jid == nil){
                      jid = member[@"member_jid"];
                  }
                 
                 NSString *affiliation = member[@"affiliation"];
                 if (_isAdmin == YES){
                     if ([myjid isEqualToString:jid]) {
                         return nil;
                     }
                     if ([affiliation isEqualToString:@"owner"]){
                         UIMenu *menu = [UIMenu menuWithTitle:@"" children:@[message,revoke_Admin]];
                         return menu;
                     }
                     if ([affiliation isEqualToString:@"admin"]){
                         UIMenu *menu = [UIMenu menuWithTitle:@"" children:@[message,revoke_Admin,kickout]];
                         return menu;
                     }
                     if ([affiliation isEqualToString:@"member"]){
                         UIMenu *menu = [UIMenu menuWithTitle:@"" children:@[message,admin,kickout]];
                         return menu;
                     }
                 }
                 else{
                     
                     if ([myjid isEqualToString:jid]) {
                         return nil;
                     }
                     UIMenu *menu = [UIMenu menuWithTitle:@"" children:@[message]];
                     return menu;
                 }
             }
            return nil;
        }];
   
    
//
}

#pragma mark - Query Software Version

-(void) querySoftwareVersion
{
    for (NSDictionary* resourceDic in self.resources)
    {
        NSString* resourceTitle = [resourceDic objectForKey:@"resource"];
        [[MLXMPPManager sharedInstance] getEntitySoftWareVersionForContact:self.contact andResource:resourceTitle];
    }
}

#pragma mark - refresh software version
-(void) refreshSoftwareVersion:(NSNotification*) verNotification
{
    if (verNotification) {
        NSMutableDictionary* inVerDictionary = [verNotification.userInfo mutableCopy];
        NSString* resourceKey = [inVerDictionary objectForKey:@"fromResource"];
        if (resourceKey)
        {
            [inVerDictionary removeObjectForKey:@"fromResource"];
            [self.versionInfoDic setObject:inVerDictionary forKey:resourceKey];
        }
    } else {
        for (NSDictionary* resourceDic in self.resources)
        {
            NSString* resourceTitle = [resourceDic objectForKey:@"resource"];
            NSArray* versionDBInfoArr = [[DataLayer sharedInstance] getSoftwareVersionInfoForContact:self.contact.contactJid resource:resourceTitle andAccount:self.contact.accountId];
            
            if(versionDBInfoArr && [versionDBInfoArr count] >= 1) {
                [self.versionInfoDic setObject:versionDBInfoArr[0] forKey:resourceTitle];
            }
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
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
