//
//  MLSettingsTableViewController.m
//  Monal
//
//  Created by Anurodh Pokharel on 12/26/17.
//  Copyright © 2017 Monal.im. All rights reserved.
//

#import "MLSettingsTableViewController.h"
#import "MLWebViewController.h"
#import "MLSwitchCell.h"
#import "HelperTools.h"
#import "DataLayer.h"
#import "MLXMPPManager.h"
#import "XMPPEdit.h"
#import "MLImageManager.h"
#import "MLInitialAvatar.h"
#import "MBProgressHUD.h"

@import SafariServices;

enum kSettingSection {
    kSettingSectionAccounts,
    kSettingSectionApp,
    SecuritySection,
   // kSettingSectionSupport,
    kSettingSectionAbout,
    kSettingSectionCount,
    
};

enum SettingsAccountRows {
    QuickSettingsRow,
    AdvancedSettingsRow,
    SettingsAccountRowsCnt
};

enum SettingsAppRows {
    PrivacySettingsRow,
    NotificationsRow,
    BackgroundsRow,
    SoundsRow,
    EnableTouchId,
    UIThemeMode,
    SettingsAppRowsCnt
};

enum SecuritySection{
    zSecurity,
};

enum SettingsSupportRow {
    EmailRow,
    SubmitABugRow,
    SettingsSupportRowCnt
};

enum SettingsAboutRows {
//    RateMonalRow,
//    OpenSourceRow,
//    PrivacyRow,
//    AboutRow,
#ifdef DEBUG
    LogRow,
#endif
    VersionRow,
    SettingsAboutRowsCntORLogRow,
    SettingsAboutRowsWithLogCnt
};

//this will hold all disabled rows of all enums (this is needed because the code below still references these rows)
enum DummySettingsRows {
    DummySettingsRowsBegin = 100,
};

@interface MLSettingsTableViewController () {
    int _tappedVersionInfo;
}
@property (nonatomic, strong) MBProgressHUD* checkHUD;
@property (nonatomic, strong) NSArray* sections;
@property (nonatomic, strong) NSArray* accountRows;
@property (nonatomic, strong) NSArray* appRows;
@property (nonatomic, strong) NSArray* supportRows;
@property (nonatomic, strong) NSDateFormatter* uptimeFormatter;
@property (nonatomic, strong) UIImageView *userAvatarImageView;
@property (nonatomic, strong) NSIndexPath* selected;

@end

@implementation MLSettingsTableViewController

DDLogFileInfo* _logInfo;

-(IBAction) close:(id) sender
{
    _tappedVersionInfo = 0;
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSArray* sortedLogFileInfos = [HelperTools.fileLogger.logFileManager sortedLogFileInfos];
    _logInfo = [sortedLogFileInfos objectAtIndex: 0];

   

 
}
-(void) viewDidLoad
{
    [super viewDidLoad];
    [self setupAccountsView];
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone )
    {
        self.navigationItem.leftBarButtonItem = nil;
    }
    
    [self.tableView registerNib:[UINib nibWithNibName:@"MLSwitchCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"AccountCell"];
    self.tableView.backgroundColor = [UIColor systemBackgroundColor];
    self.splitViewController.preferredDisplayMode=UISplitViewControllerDisplayModeAllVisible;
#if !TARGET_OS_MACCATALYST
    if (@available(iOS 13.0, *)) {
        self.splitViewController.primaryBackgroundStyle=UISplitViewControllerBackgroundStyleSidebar;
    } else {
        // Fallback on earlier versions
    }
#endif
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refreshAccountList];

    _tappedVersionInfo = 0;
    self.selected = nil;
}

#pragma mark - key commands

-(BOOL) canBecomeFirstResponder
{
    return YES;
}

-(NSArray<UIKeyCommand*>*) keyCommands
{
    return @[[UIKeyCommand keyCommandWithInput:UIKeyInputEscape modifierFlags:0 action:@selector(close:)]];
}

#pragma mark - Table view data source

-(NSInteger) numberOfSectionsInTableView:(UITableView*) tableView
{
    return kSettingSectionCount;
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        UIView* avatarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 100)];
        avatarView.backgroundColor = [UIColor clearColor];
        avatarView.userInteractionEnabled = YES;
        
        self.userAvatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.tableView.frame.size.width - 90)/2 , 25, 90, 90)];
        self.userAvatarImageView.layer.cornerRadius =  self.userAvatarImageView.frame.size.height / 2;
        self.userAvatarImageView.layer.borderWidth = 2.0f;
        self.userAvatarImageView.layer.borderColor = ([UIColor clearColor]).CGColor;
        self.userAvatarImageView.clipsToBounds = YES;
        self.userAvatarImageView.userInteractionEnabled = YES;
        NSArray* accountList = [[DataLayer sharedInstance] accountList];
        NSDictionary* account = [accountList objectAtIndex:0];
        
        NSString *jid = [NSString stringWithFormat:@"%@@%@",[account objectForKey:@"username"], [account objectForKey:@"domain"]];
        NSString* accountNo = [NSString stringWithFormat:@"%@", account[kAccountID]];
        [[MLImageManager sharedInstance] getIconForContact:jid andAccount:accountNo withCompletion:^(UIImage *image) {

            if (image){
                [self.userAvatarImageView setImage:image];
            }else{
                MLInitialAvatar *avatar = [[MLInitialAvatar alloc] initWithRect:CGRectMake( 0 , 0, 150, 150) fullName:[account objectForKey:@"username"]];
                [self.userAvatarImageView setImage:[MLImageManager circularImage:avatar.imageRepresentation]];
                NSData *avatarData = UIImagePNGRepresentation(avatar.imageRepresentation);
                [[MLImageManager sharedInstance] setIconForContact:jid andAccount:accountNo WithData:avatarData];
            }
            
        }];
        
        [avatarView addSubview:self.userAvatarImageView];
        
        return avatarView;
    }
    else
    {
        NSString* sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
        return [HelperTools MLCustomViewHeaderWithTitle:sectionTitle];
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0){
        return 100;
    }
    return UITableViewAutomaticDimension;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch(section)
    {
        case kSettingSectionAccounts:
            if ([self getAccountNum] > 0){
                return 1;
            }else{
               return 1;
            }
        case kSettingSectionApp: return SettingsAppRowsCnt;
        case SecuritySection: return 1;
     //   case kSettingSectionSupport: return SettingsSupportRowCnt;
//#ifndef DEBUG
//        case kSettingSectionAbout:
//            [[HelperTools defaultsDB] boolForKey:@"showLogInSettings"] ? SettingsAboutRowsWithLogCnt : //SettingsAboutRowsCntORLogRow;
//#else
        case kSettingSectionAbout: return 2;
            //SettingsAboutRowsCntORLogRow;
//#endif
        default:
            unreachable();
    }
    return 0;
}

-(void) prepareForSegue:(UIStoryboardSegue*) segue sender:(id) sender
{
    if([segue.identifier isEqualToString:@"showOpenSource"])
    {
        UINavigationController* nav = (UINavigationController*) segue.destinationViewController;
        MLWebViewController* web = (MLWebViewController*) nav.topViewController;

        NSBundle* mainBundle = [NSBundle mainBundle];
        NSString* myFile = [mainBundle pathForResource: @"opensource" ofType: @"html"];

        [web initViewWithUrl:[NSURL fileURLWithPath:myFile]];
    }
    else if([segue.identifier isEqualToString:@"editXMPP"])
    {
        XMPPEdit* editor = (XMPPEdit*) segue.destinationViewController.childViewControllers.firstObject; // segue.destinationViewController;

        if(self.selected && self.selected.row >= [self getAccountNum])
        {
            editor.accountno = @"-1";
        }
        else
        {
            assert(self.selected);
            editor.originIndex = self.selected;
            editor.accountno = [self getAccountNoByIndex:self.selected.row];
        }
    }
}

-(UITableViewCell*) tableView:(UITableView*) tableView cellForRowAtIndexPath:(NSIndexPath*) indexPath
{
    MLSwitchCell* cell = [tableView dequeueReusableCellWithIdentifier:@"AccountCell" forIndexPath:indexPath];
    switch((int)indexPath.section)
    {
        case kSettingSectionAccounts: {
            if(indexPath.row < [self getAccountNum])
            {
                // User selected an account
                [self initContactCell:cell forAccNo:indexPath.row];
            }
            else
            {
            
                NSAssert(indexPath.row - [self getAccountNum] < SettingsAccountRowsCnt, @"Tried to tap onto a row ment to be for a concrete account, not for quick or advanced settings");
                // User selected one of the 'add account' promts
                
                [cell initTapCell:NSLocalizedString(@"Add Account", @"")];
//                if ([self getAccountNum] > 0){
//                    switch(indexPath.row) {
//                        case QuickSettingsRow:
//                            [cell initTapCell:NSLocalizedString(@"Add Account", @"")];
//                            break;
//    //                    case AdvancedSettingsRow:
//    //                        [cell initTapCell:NSLocalizedString(@"Add Account (advanced)", @"")];
//    //                        break;
//                        default:
//                            unreachable();
//                    }
//                }
              
            }
            break;
        }
        case kSettingSectionApp: {
            switch(indexPath.row) {
                case PrivacySettingsRow:
                    [cell initTapCell:NSLocalizedString(@"Privacy Settings", @"")];
                    break;
                case NotificationsRow:
                    [cell initTapCell:NSLocalizedString(@"Register Notifications", @"")];
                    break;
                case BackgroundsRow:
                    [cell initTapCell:NSLocalizedString(@"Backgrounds", @"")];
                    break;
                case SoundsRow:
                    [cell initTapCell:NSLocalizedString(@"Sounds", @"")];
                    break;
                case EnableTouchId:
                    [cell initCell:NSLocalizedString(@"Enable Passcode ", @"") withToggleDefaultsKey:@"loginWithTouchId"];
//                    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"loginWithTouchId"] != nil) {
//                        NSString* indexMessage = [[NSUserDefaults standardUserDefaults] objectForKey:@"loginWithTouchId"];
//                        if ([indexMessage isEqualToString:@"true"]) {
//                            [cell.switchTouch setOn:true];
//                        } else if ([indexMessage isEqualToString:@"false"]) {
//                            [cell.switchTouch setOn:false];
//                        }
//                    }
                   // [cell.switchTouch setHidden:false];
                    break;
                case UIThemeMode:
                    [cell initCell:NSLocalizedString(@"Enable Dark Mode ", @"") withToggleDefaultsKey:@"darkModeEnable"];
                    break;
                default:
                    unreachable();
            }
            break;
        }
        case SecuritySection: {
            switch(indexPath.row){
                case zSecurity:
                    [cell initTapCell:NSLocalizedString(@"Security Stats of SAI", @"")];
                    break;
            }
            break;;
        }
//        case kSettingSectionSupport: {
//            switch(indexPath.row) {
//                case EmailRow:
//                    [cell initTapCell:NSLocalizedString(@"Email Support", @"")];
//                    break;
//                case SubmitABugRow:
//                    [cell initTapCell:NSLocalizedString(@"Submit A Bug", @"")];
//                    break;
//                default:
//                    unreachable();
//            }
//            break;
//        }
        case kSettingSectionAbout: {
            switch(indexPath.row) {
//                case RateMonalRow: {
//                    [cell initTapCell:NSLocalizedString(@"Rate Monal", @"")];
//                    break;
//                }
//                case OpenSourceRow: {
//                    [cell initTapCell:NSLocalizedString(@"Open Source", @"")];
//                    break;
//                }
//                case PrivacyRow: {
//                    [cell initTapCell:NSLocalizedString(@"Privacy", @"")];
//                    break;
//                }
//                case AboutRow: {
//                    [cell initTapCell:NSLocalizedString(@"About", @"")];
//                    break;
//                }
                case VersionRow: {
                    [cell initCell:NSLocalizedString(@"Version", @"") withLabel:[HelperTools appBuildVersionInfo]];
                    break;
                }
#ifdef DEBUG
                case LogRow:
#endif
                case SettingsAboutRowsCntORLogRow: {
                    [cell initTapCell:NSLocalizedString(@"Share Logs", @"")];
                    break;
                }
                default: {
                    unreachable();
                }
            }
            break;
        }
        default:
            unreachable();
    }
    return cell;
}

-(NSString*) tableView:(UITableView*) tableView titleForHeaderInSection:(NSInteger) section
{
    switch(section) {
        case kSettingSectionAccounts:
            return nil;             //the account section does not need a heading (its the first one)
        case kSettingSectionApp:
            return NSLocalizedString(@"App", @"");
            
        case SecuritySection:
          return NSLocalizedString(@"Security", @"");
       case kSettingSectionAbout:
           return NSLocalizedString(@"About", @"");
        default:
            unreachable();
    }
    return nil;     //needed to make the compiler happy
}

-(void)tableView:(UITableView*) tableView didSelectRowAtIndexPath:(NSIndexPath*) indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch(indexPath.section)
    {
        case kSettingSectionAccounts: {
            self.selected = indexPath;
            if(indexPath.row < [self getAccountNum])
                [self performSegueWithIdentifier:@"editXMPP" sender:self];
            else
            {
                switch(indexPath.row - [self getAccountNum]) {
                    case QuickSettingsRow:
                        [self performSegueWithIdentifier:@"showLogin" sender:self];
                        break;
                    case AdvancedSettingsRow:
                        [self performSegueWithIdentifier:@"editXMPP" sender:self];
                        break;
                    default:
                        unreachable();
                }
            }
            break;
        }
        case kSettingSectionApp: {
            switch(indexPath.row) {
                case PrivacySettingsRow:
                    [self performSegueWithIdentifier:@"showPrivacySettings" sender:self];
                    break;
                case NotificationsRow:
                    [self registerNotification];
                   // [self performSegueWithIdentifier:@"showNotification" sender:self];
                    break;
                case BackgroundsRow:
                    [self performSegueWithIdentifier:@"showBackgrounds" sender:self];
                    break;
                case SoundsRow:
                    [self performSegueWithIdentifier:@"showSounds" sender:self];
                    break;
                case EnableTouchId:
                    break;
                case UIThemeMode:
                    break;
                default:
                    unreachable();
            }
            break;
        }
        case SecuritySection: {
            switch(indexPath.row){
                case zSecurity:
                    [self performSegueWithIdentifier:@"showSecurity" sender:self];
                    break;
            }
            break;
        }
//        case kSettingSectionSupport: {
//            switch(indexPath.row) {
//                case EmailRow:
//                    [self composeMail];
//                    break;
//                case SubmitABugRow:
//                    [self openLink:@"https://github.com/monal-im/Monal/issues"];
//                    break;
//                default:
//                    unreachable();
//            }
//            break;
//        }
        case kSettingSectionAbout: {
            switch(indexPath.row) {
//                case RateMonalRow:
//                    [self openStoreProductViewControllerWithITunesItemIdentifier:317711500];
//                    break;
//                case OpenSourceRow:
//                    [self performSegueWithIdentifier:@"showOpenSource" sender:self];
//                    break;
//                case PrivacyRow:
//                    [self openLink:@"https://monal.im/monal-privacy-policy/"];
//                    break;
//                case AboutRow:
//                    [self openLink:@"https://monal.im/about/"];
//                    break;
#ifdef DEBUG
                case LogRow:
#endif
                case SettingsAboutRowsCntORLogRow:
                  //  [self showFetching];
                    [self shareLogs];
                    //[self performSegueWithIdentifier:@"showLogs" sender:self];
                    break;
                case VersionRow: {
//#ifndef DEBUG
//                    if(_tappedVersionInfo >= 16)
//                    {
//                        [[HelperTools defaultsDB] setBool:YES forKey:@"showLogInSettings"];
//                        [tableView reloadData];
//                    }
//                    else
//                        _tappedVersionInfo++;
//#endif
                    UIPasteboard* pastboard = UIPasteboard.generalPasteboard;
                    pastboard.string = [HelperTools appBuildVersionInfo];
                    break;
                }
                default:
                    unreachable();
            }
            break;
        }
        default:
            unreachable();
    }
}
-(void) showFetching
{
    dispatch_async(dispatch_get_main_queue(), ^{
       self.checkHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        self.checkHUD.mode = MBProgressHUDModeIndeterminate;
        self.checkHUD.removeFromSuperViewOnHide = YES;
        self.checkHUD.label.text = NSLocalizedString(@"Fetching....", @"");
//        hud.detailsLabel.text = NSLocalizedString(@"The account has been saved", @"");
//        UIImage *image = [[UIImage imageNamed:@"success"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
//        hud.customView = [[UIImageView alloc] initWithImage:image];
       
       // [self.checkHUD hideAnimated:YES afterDelay:1.0f];
      
    });
}

-(void) openLink:(NSString *) link
{
    NSURL* url = [NSURL URLWithString:link];
    
    if ([url.scheme isEqualToString:@"http"] || [url.scheme isEqualToString:@"https"]) {
        SFSafariViewController* safariView = [[ SFSafariViewController alloc] initWithURL:url];
        [self presentViewController:safariView animated:YES completion:nil];
    }
}

#pragma mark - Actions
-(void) shareLogs{
    self.checkHUD.hidden = YES;
    UIActivityViewController* shareController = [[UIActivityViewController alloc] initWithActivityItems:@[[NSURL fileURLWithPath:_logInfo.filePath]] applicationActivities:nil];
    [self presentViewController:shareController animated:YES completion:^{}];
}
-(void) registerNotification{
    UserServices *Services = [[UserServices alloc] init];
    NSString* pushToken = [MLXMPPManager sharedInstance].pushToken;
    NSArray* accountList = [[DataLayer sharedInstance] accountList];
    NSDictionary* account = [accountList objectAtIndex:0];
    
    NSString *jid = [NSString stringWithFormat:@"%@",[account objectForKey:@"username"]];
    [Services registerAPNSWithUserName:jid pushToken:pushToken completion:^(BOOL Status, NSString * ErrorMessage) {
        if (Status == TRUE){
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertController* messageAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Success", @"") message:NSLocalizedString(@"Registration is successful , you can keep your device in offline to receive notifications.", @"") preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* closeAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Close", @"") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                }];
                [messageAlert addAction:closeAction];
                
                [self presentViewController:messageAlert animated:YES completion:nil];

            });
    
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                if (ErrorMessage != nil){
                    NSString *message = NSLocalizedString(@"Registration is not successful , Please try after sometime to register notifications. ", Errormessage);
                    UIAlertController* messageAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Warning", @"") message:message preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction* closeAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Close", @"") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                    }];
                    [messageAlert addAction:closeAction];
                    
                    [self presentViewController:messageAlert animated:YES completion:nil];
                }
              
                

            });
        
        }
        
        }];
}
-(void) openStoreProductViewControllerWithITunesItemIdentifier:(NSInteger) iTunesItemIdentifier {
    SKStoreProductViewController *storeViewController = [[SKStoreProductViewController alloc] init];
    
    storeViewController.delegate = self;
    
    NSNumber* identifier = [NSNumber numberWithInteger:iTunesItemIdentifier];
    //, @"action":@"write-review"
    NSDictionary* parameters = @{ SKStoreProductParameterITunesItemIdentifier:identifier};
    
    [storeViewController loadProductWithParameters:parameters
                                   completionBlock:^(BOOL result, NSError *error) {
                                       if (result)
                                           [self presentViewController:storeViewController
                                                              animated:YES
                                                            completion:nil];
                                       else NSLog(@"SKStoreProductViewController: %@", error);
                                   }];
    
    
}

-(void) composeMail
{
    if([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController* composeVC = [[MFMailComposeViewController alloc] init];
        composeVC.mailComposeDelegate = self;
        [composeVC setToRecipients:@[@"info@monal.im"]];
        [self presentViewController:composeVC animated:YES completion:nil];
    }
    else
    {
        UIAlertController* messageAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error", @"") message:NSLocalizedString(@"There is no configured email account. Please email info@monal.im .", @"") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* closeAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Close", @"") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        }];
        [messageAlert addAction:closeAction];
        
        [self presentViewController:messageAlert animated:YES completion:nil];
    }
    
}

#pragma mark - Message ui delegate
- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - SKStoreProductViewControllerDelegate

-(void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
    [viewController dismissViewControllerAnimated:YES completion:nil];
}
@end
