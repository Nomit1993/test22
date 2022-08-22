//
//  MLLogInViewController.m
//  Monal
//
//  Created by Anurodh Pokharel on 11/9/18.
//  Copyright © 2018 Monal.im. All rights reserved.
//

#import "MLLogInViewController.h"
#import "MBProgressHUD.h"
#import "DataLayer.h"
#import "MLXMPPManager.h"
#import "xmpp.h"
#import "UIColor+Theme.h"
#import <monalxmpp/monalxmpp-Swift.h>
#import "MLNotificationQueue.h"
#import "MLNotificationManager.h"
@import SAMKeychain;
@import QuartzCore;
@import SafariServices;
@class UserServices;
@class MLQRCodeScanner;
@class KeyChainServices;
@interface MLLogInViewController ()

@property (nonatomic, strong) MBProgressHUD* loginHUD;
@property (nonatomic, weak) UITextField* activeField;
@property (nonatomic, strong) NSString* accountNo;

@end

@implementation MLLogInViewController

-(void) viewDidLoad
{
    [super viewDidLoad];
    self.topImage.layer.cornerRadius = 5.0;
    self.topImage.clipsToBounds = YES;
}

-(void) viewWillAppear:(BOOL) animated
{
    [super viewWillAppear:animated];
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(connected:) name:kMLHasConnectedNotice object:nil];
    [nc addObserver:self selector:@selector(catchedup:) name:kMonalFinishedCatchup object:nil];
#ifndef DISABLE_OMEMO
    [nc addObserver:self selector:@selector(omemoBundleFetchFinished:) name:kMonalFinishedOmemoBundleFetch object:nil];
#endif
//    if(@available(iOS 13.0, *))
//    {
//        // nothing to do here
//    }
//    else
//    {
//        [self.qrScanButton setTitle:NSLocalizedString(@"QR", "MLLoginView: QR-Code Button iOS12 only") forState:UIControlStateNormal];
//    }
    self.FirstTF.delegate = self;
    self.secondTF.delegate = self;
    self.ThirdTF.delegate = self;
    self.FourthTF.delegate = self;
    self.FifthTF.delegate = self;
    self.SixthTF.delegate = self;
    self.SeventhTF.delegate = self;
    self.EighthTF.delegate = self;
    self.NinthTF.delegate = self;
    [self registerForKeyboardNotifications];
}


-(void) openLink:(NSString *) link
{
    NSURL* url = [NSURL URLWithString:link];
    
    if([url.scheme isEqualToString:@"http"] || [url.scheme isEqualToString:@"https"])
    {
        SFSafariViewController *safariView = [[ SFSafariViewController alloc] initWithURL:url];
        [self presentViewController:safariView animated:YES completion:nil];
    }
}

-(IBAction) registerAccount:(id)sender;
{
    [self openLink:@"https://monal.im/welcome-to-xmpp/"];
}


-(void) ErrorAlertWithmsg: (NSString * ) msg {

  UIAlertController * alertvc = [UIAlertController alertControllerWithTitle:@"Warning" message: msg preferredStyle: UIAlertControllerStyleAlert];

  UIAlertAction * action = [UIAlertAction actionWithTitle: @"Ok" style: UIAlertActionStyleDefault handler: ^ (UIAlertAction * _Nonnull action) {
            NSLog(@"Dismiss Tapped");
                }
                ];
    [alertvc addAction: action];

    [self presentViewController: alertvc animated: true completion: nil];

}

-(IBAction) login:(id)sender
{
    if (self.FirstTF.text.length == 0 || self.secondTF.text.length == 0 || self.ThirdTF.text.length == 0 || self.FourthTF.text.length == 0 || self.FifthTF.text.length == 0 || self.SixthTF.text.length == 0 || self.SeventhTF.text.length == 0 || self.EighthTF.text.length == 0 || self.NinthTF.text.length == 0){
            [self ErrorAlertWithmsg:@"Please Enter The OTP Properly."];
        }
        self.loginHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        self.loginHUD.label.text = NSLocalizedString(@"Validating OTP", @"");
        self.loginHUD.mode=MBProgressHUDModeIndeterminate;
        self.loginHUD.removeFromSuperViewOnHide=YES;
        
        NSString *OTPString = [self.FirstTF.text stringByAppendingString:self.secondTF.text];
        OTPString = [OTPString stringByAppendingString:self.ThirdTF.text];
        OTPString = [OTPString stringByAppendingString:self.FourthTF.text];
        OTPString = [OTPString stringByAppendingString:self.FifthTF.text];
        OTPString = [OTPString stringByAppendingString:self.SixthTF.text];
        OTPString = [OTPString stringByAppendingString:self.SeventhTF.text];
        OTPString = [OTPString stringByAppendingString:self.EighthTF.text];
        OTPString = [OTPString stringByAppendingString:self.NinthTF.text];
        
        UserServices *Services = [[UserServices alloc] init];
        NSString* pushToken = [MLXMPPManager sharedInstance].pushToken;
        //KeyChainServices *keyServices = [[KeyChainServices alloc] init];
    [Services OTPAuthenticationWithOTP:OTPString username:self.username pushToken:pushToken completion:^(BOOL Status, NSString * _Nullable Password, NSString * _Nullable NonceSalt, NSString * _Nullable ErrorMsg) {
        
            if (Status == YES && ErrorMsg == Nil){
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.loginHUD.label.text = NSLocalizedString(@"sending the presence services ...", @"");
                    NSString *nonceKeyName = @"PresenceNonceSalt";
                    [[NSUserDefaults standardUserDefaults] setObject:NonceSalt forKey:nonceKeyName];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    self.loginHUD.hidden = YES;
                    [self login:self.username password:Password];
                }
                               );
               // NSData* nonceData = [NonceSalt dataUsingEncoding:NSUTF8StringEncoding];
                
    //            OSStatus status = [keyServices saveWithKey:nonceKeyName data:nonceData];
    //            NSLog(@"status of nonceSalt: %d",(int)status);
    //            [Services SendUserPresenceWithUserName:self.userName salt:NonceSalt completion:^(BOOL Status, NSString * _Nullable errorMsg) {
    //                if (Status == TRUE){
    //                    dispatch_async(dispatch_get_main_queue(), ^{
    //                        self.loginHUD.hidden = YES;
    //                        [self login:self.userName password:Password];
    //                        //[self login:self.userName Password:Password];
    //                    });
    //                }else{
    //                    dispatch_async(dispatch_get_main_queue(), ^{
    //                        self.loginHUD.hidden = YES;
    //                    [self ErrorAlertWithmsg:@"Unable to login ..."];
    //                    });
    //
    //                }
    //            }];
                
            }else{
                if (ErrorMsg != Nil){
                    if ([ErrorMsg containsString:@"0x2001"]){
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.loginHUD.hidden = YES;
                            [self ErrorAlertWithmsg:@"OTP Not Sent"];
                        });
                       
                    }else if([ErrorMsg containsString:@"0x3112"]){
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.loginHUD.hidden = YES;
                            [self ErrorAlertWithmsg:@"Unauthorized"];
                        });
                        
                    }
                    else if([ErrorMsg containsString:@"0x3113"]){
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.loginHUD.hidden = YES;
                            [self ErrorAlertWithmsg:@"Already Logged in"];
                        });
        
                    }
                    else if([ErrorMsg containsString:@"0x3114"]){
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.loginHUD.hidden = YES;
                            [self ErrorAlertWithmsg:@"Wrong OTP"];
                        });
                        
                    }else if([ErrorMsg containsString:@"0x3115"]){
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.loginHUD.hidden = YES;
                            [self ErrorAlertWithmsg:@"Account Banned"];
                        });
                        
                    }else if([ErrorMsg containsString:@"0x3116"]){
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.loginHUD.hidden = YES;
                            [self ErrorAlertWithmsg:@"IP address blocked"];
                        });
                       
                    }
                    else if([ErrorMsg containsString:@"0x3117"]){
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.loginHUD.hidden = YES;
                            [self ErrorAlertWithmsg:@"Account Not Found"];
                        });
                        
                    }
                }
            }
        }];
    }


-(void) login:(NSString *)userName password:(NSString *)Password
{
    self.loginHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.loginHUD.label.text = NSLocalizedString(@"Logging in", @"");
    self.loginHUD.mode=MBProgressHUDModeIndeterminate;
    self.loginHUD.removeFromSuperViewOnHide=YES;

    NSString* jid = userName;
    NSString* password = Password;
    
   // NSArray* elements = [jid componentsSeparatedByString:@"@"];

    NSString* domain;
    NSString* user;
    
    user = jid;
    domain = @"chat.securesignal.in";
    //if it is a JID
//    if([elements count] > 1)
//    {
//        user = [elements objectAtIndex:0];
//        domain = [elements objectAtIndex:1];
//    }
   
    if(!user || !domain)
    {
        self.loginHUD.hidden = YES;
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Invalid Credentials", @"") message:NSLocalizedString(@"Your XMPP account should be in in the format user@domain. For special configurations, use manual setup.", @"") preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Close", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [alert dismissViewControllerAnimated:YES completion:nil];
        }]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    if(password.length == 0)
    {
        self.loginHUD.hidden = YES;
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Invalid Credentials", @"") message:NSLocalizedString(@"Please enter a password.", @"") preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Close", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [alert dismissViewControllerAnimated:YES completion:nil];
        }]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    if([[DataLayer sharedInstance] doesAccountExistUser:user.lowercaseString andDomain:domain.lowercaseString]) {
        self.loginHUD.hidden = YES;
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Duplicate Account", @"") message:NSLocalizedString(@"This account already exists on this instance", @"") preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Close", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [alert dismissViewControllerAnimated:YES completion:nil];
        }]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }

    NSMutableDictionary* dic  = [[NSMutableDictionary alloc] init];
    [dic setObject:domain.lowercaseString forKey:kDomain];
    [dic setObject:user.lowercaseString forKey:kUsername];
    [dic setObject:[HelperTools encodeRandomResource]  forKey:kResource];
    [dic setObject:@YES forKey:kEnabled];
    [dic setObject:@NO forKey:kDirectTLS];
    
    
    NSNumber* accountID = [[DataLayer sharedInstance] addAccountWithDictionary:dic];
    if(accountID)
    {
        //make sure we observer new connection errors (the observer will be removed in connected: to make sure we don't catch
        //non-fatal errors like muc join failures etc. (or any other errors after we successfully connected and logged in for that matter)
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(error:) name:kXMPPError object:nil];
        self.accountNo = [NSString stringWithFormat:@"%@", accountID];
        [SAMKeychain setAccessibilityType:kSecAttrAccessibleAfterFirstUnlock];
        [SAMKeychain setPassword:password forService:kMonalKeychainName account:self.accountNo];
        [[MLXMPPManager sharedInstance] connectAccount:self.accountNo];
    }

    // open privacy settings
//    if(![[HelperTools defaultsDB] boolForKey:@"HasSeenPrivacySettings"]) {
//        [self performSegueWithIdentifier:@"showPrivacySettings" sender:self];
//        return;
//    }
}

-(void) connected:(NSNotification*) notification
{
    xmpp* xmppAccount = notification.object;
    if(xmppAccount != nil && [xmppAccount.accountNo isEqualToString:self.accountNo])
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kXMPPError object:nil];
        [[HelperTools defaultsDB] setBool:YES forKey:@"HasSeenLogin"];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.loginHUD.label.text = NSLocalizedString(@"Loading contact list", @"");
        });
    }
}

-(void) catchedup:(NSNotification*) notification
{
    xmpp* xmppAccount = notification.object;
    if(xmppAccount != nil && [xmppAccount.accountNo isEqualToString:self.accountNo])
    {
#ifndef DISABLE_OMEMO
        dispatch_async(dispatch_get_main_queue(), ^{
            self.loginHUD.label.text = NSLocalizedString(@"Loading", @"");
        });
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateBundleFetchStatus:) name:kMonalUpdateBundleFetchStatus object:nil];
#else
        [self omemoBundleFetchFinished:nil];
#endif
    }
}

#ifndef DISABLE_OMEMO
-(void) updateBundleFetchStatus:(NSNotification*) notification
{
    if([notification.userInfo[@"accountNo"] isEqualToString:self.accountNo])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.loginHUD.label.text = [NSString stringWithFormat:NSLocalizedString(@"Loading files: %@ / %@", @""), notification.userInfo[@"completed"], notification.userInfo[@"all"]];
        });
    }
}
#endif

-(void) omemoBundleFetchFinished:(NSNotification*) notification
{
    if([notification.userInfo[@"accountNo"] isEqualToString:self.accountNo])
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kMonalUpdateBundleFetchStatus object:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.loginHUD.hidden = YES;
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Success!", @"") message:NSLocalizedString(@"You are set up and connected.", @"") preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Start Using SAI", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self dismissViewControllerAnimated:YES completion:^{
                    [[MLNotificationQueue currentQueue] postNotificationName:kMonalrefreshLogin object:nil userInfo:nil];
                }];
            }]];
            [self presentViewController:alert animated:YES completion:nil];
        });
    }
}



-(void) error:(NSNotification*) notification
{
    xmpp* xmppAccount = notification.object;
    if(xmppAccount != nil && [xmppAccount.accountNo isEqualToString:self.accountNo])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.loginHUD.hidden=YES;
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error", @"") message:NSLocalizedString(@"We were not able to connect your account. Please check your credentials and make sure you are connected to the internet.", @"") preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Close", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [alert dismissViewControllerAnimated:YES completion:nil];
            }]];
            [self presentViewController:alert animated:YES completion:nil];
            
            if(self.accountNo)
            {
                [[MLXMPPManager sharedInstance] disconnectAccount:self.accountNo];
                [[DataLayer sharedInstance] removeAccount:self.accountNo];
            }
        });
    }
}

-(IBAction) useWithoutAccount:(id)sender
{
    [[HelperTools defaultsDB] setBool:YES forKey:@"HasSeenLogin"];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction) tapAction:(id)sender
{
    [self.view endEditing:YES];
}



#pragma mark -textfield delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.activeField = textField;
}

-(BOOL)textFieldShouldReturn:(UITextField*)textField;
{
    if (textField == self.FirstTF)
    {
        [self.secondTF becomeFirstResponder];
    }
    else if (textField == self.secondTF)
    {
        [self.ThirdTF becomeFirstResponder];
    }
    else if (textField == self.ThirdTF)
    {
        [self.FourthTF becomeFirstResponder];
    }else if (textField == self.FifthTF)
    {
        [self.FifthTF becomeFirstResponder];
    }else if (textField == self.SixthTF)
    {
        [self.SixthTF becomeFirstResponder];
    }else if (textField == self.SixthTF)
    {
        [self.SeventhTF becomeFirstResponder];
    }else if (textField == self.SeventhTF)
    {
        [self.EighthTF becomeFirstResponder];
    }else if (textField == self.NinthTF)
    {
        [self.NinthTF resignFirstResponder];
    }

    return NO;
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    
    if (textField == self.NinthTF)
    {
        
        [self.view endEditing:YES];
    }
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    // This allows numeric text only, but also backspace for deletes
    if (string.length > 0 && ![[NSScanner scannerWithString:string] scanInt:NULL])
        return NO;

    NSUInteger oldLength = [textField.text length];
    NSUInteger replacementLength = [string length];
    NSUInteger rangeLength = range.length;

    NSUInteger newLength = oldLength - rangeLength + replacementLength;

    // This 'tabs' to next field when entering digits
    if (newLength == 1) {
        if (textField == self.FirstTF)
        {
            self.FirstTF.layer.borderColor = [[UIColor blackColor] CGColor];
            [self performSelector:@selector(setNextResponder:) withObject:self.secondTF afterDelay:0.2];
        }
        else if (textField == self.secondTF)
        {
            self.secondTF.layer.borderColor = [[UIColor blackColor] CGColor];
            [self performSelector:@selector(setNextResponder:) withObject:self.ThirdTF afterDelay:0.2];
        }
        else if (textField == self.ThirdTF)
        {
            self.ThirdTF.layer.borderColor = [[UIColor blackColor] CGColor];
            [self performSelector:@selector(setNextResponder:) withObject:self.FourthTF afterDelay:0.2];
        } else if (textField == self.FourthTF)
        {
            self.FourthTF.layer.borderColor = [[UIColor blackColor] CGColor];
            [self performSelector:@selector(setNextResponder:) withObject:self.FifthTF afterDelay:0.2];
        } else if (textField == self.FifthTF)
        {
            self.FifthTF.layer.borderColor = [[UIColor blackColor] CGColor];
            [self performSelector:@selector(setNextResponder:) withObject:self.SixthTF afterDelay:0.2];
        } else if (textField == self.SixthTF)
        {
            self.SixthTF.layer.borderColor = [[UIColor blackColor] CGColor];
            [self performSelector:@selector(setNextResponder:) withObject:self.SeventhTF afterDelay:0.2];
        } else if (textField == self.SeventhTF)
        {
            self.SeventhTF.layer.borderColor = [[UIColor blackColor] CGColor];
            [self performSelector:@selector(setNextResponder:) withObject:self.EighthTF afterDelay:0.2];
        } else if (textField == self.EighthTF)
        {
            self.EighthTF.layer.borderColor = [[UIColor blackColor] CGColor];
            [self performSelector:@selector(setNextResponder:) withObject:self.NinthTF afterDelay:0.2];
        }
    }
    //this goes to previous field as you backspace through them, so you don't have to tap into them individually
    else if (oldLength > 0 && newLength == 0) {
        if (textField == self.NinthTF)
        {
            self.NinthTF.layer.borderColor = [[UIColor monaldarkGreen] CGColor];
            [self performSelector:@selector(setNextResponder:) withObject:self.EighthTF afterDelay:0.1];
        }
        else if (textField == self.EighthTF)
        {
            self.EighthTF.layer.borderColor = [[UIColor monaldarkGreen] CGColor];
            [self performSelector:@selector(setNextResponder:) withObject:self.SeventhTF afterDelay:0.1];
        }
        else if (textField == self.SeventhTF)
        {
            self.SeventhTF.layer.borderColor = [[UIColor monaldarkGreen] CGColor];
            [self performSelector:@selector(setNextResponder:) withObject:self.SixthTF afterDelay:0.1];
        }if (textField == self.SixthTF)
        {
            self.SixthTF.layer.borderColor = [[UIColor monaldarkGreen] CGColor];
            [self performSelector:@selector(setNextResponder:) withObject:self.FifthTF afterDelay:0.1];
        }
        else if (textField == self.FifthTF)
        {
            self.FifthTF.layer.borderColor = [[UIColor monaldarkGreen] CGColor];
            [self performSelector:@selector(setNextResponder:) withObject:self.FourthTF afterDelay:0.1];
        }
        else if (textField == self.FourthTF)
        {
            self.FourthTF.layer.borderColor = [[UIColor monaldarkGreen] CGColor];
            [self performSelector:@selector(setNextResponder:) withObject:self.ThirdTF afterDelay:0.1];
        }if (textField == self.ThirdTF)
        {
            self.ThirdTF.layer.borderColor = [[UIColor monaldarkGreen] CGColor];
            [self performSelector:@selector(setNextResponder:) withObject:self.secondTF afterDelay:0.1];
        }
        else if (textField == self.secondTF)
        {
            self.secondTF.layer.borderColor = [[UIColor monaldarkGreen] CGColor];
            [self performSelector:@selector(setNextResponder:) withObject:self.FirstTF afterDelay:0.1];
        }
       
    }

    return newLength <= 1;
}

- (void)setNextResponder:(UITextField *)nextResponder
{
    [nextResponder becomeFirstResponder];
}
#pragma mark - key commands

-(BOOL)canBecomeFirstResponder {
    return YES;
}


// login on enter
-(void) enterPressed:(UIKeyCommand*)keyCommand
{
    [self login:self];
}

// List of custom hardware key commands
- (NSArray<UIKeyCommand *> *)keyCommands {
    return @[
        // enter
        [UIKeyCommand keyCommandWithInput:@"\r" modifierFlags:0 action:@selector(enterPressed:)],
    ];
}


#pragma mark - keyboard management

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your app might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect, self.activeField.frame.origin) ) {
        [self.scrollView scrollRectToVisible:self.activeField.frame animated:YES];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}

-(void) dealloc
{
    [self removeObservers];
}


-(void) removeObservers {
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"scanQRCode"])
    {
        if(@available(iOS 12.0, macCatalyst 14.0, *))
        {
            MLQRCodeScanner* qrCodeScanner = (MLQRCodeScanner*)segue.destinationViewController;
            qrCodeScanner.loginDelegate = self;
        }
        else
        {
            [MLQRCodeScannerCatalina showCatalinaWarningWithView:self];
        }
    }
    else if([segue.identifier isEqualToString:@"showPrivacySettings"])
    {
        // nothing todo
    }
    else
    {
        [self removeObservers];
    }
}

-(void) MLQRCodeAccountLoginScannedWithJid:(NSString*) jid password:(NSString*) password
{
    // Insert jid and password into text fields
    self.jid.text = jid;
    self.password.text = password;
    // Close QR-Code scanner
    [self.navigationController popViewControllerAnimated:YES];
}


@end
