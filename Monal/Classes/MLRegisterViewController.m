//
//  MLLogInViewController.m
//  Monal
//
//  Created by Anurodh Pokharel on 11/9/18.
//  Copyright © 2018 Monal.im. All rights reserved.
//

#import "MLRegisterViewController.h"
#import "MBProgressHUD.h"
#import "DataLayer.h"
#import "MLXMPPManager.h"
#import "xmpp.h"
#import <monalxmpp/monalxmpp-Swift.h>
#import "MLRegSuccessViewController.h"

#import "MLNotificationManager.h"
#import "MLNotificationQueue.h"
@import QuartzCore;
@import SafariServices;
@import SAMKeychain;
@class UserServices;
@interface MLRegisterViewController ()
@property (nonatomic, strong) MBProgressHUD *loginHUD;
@property (nonatomic, weak) UITextField *activeField;
@property (nonatomic, strong) xmpp* xmppAccount;
@property (nonatomic, strong) NSDictionary *hiddenFields;
@property (nonatomic) NSInteger Count;

@end

@implementation MLRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(handlelogin:) name:kMonalrefreshLogin object:nil];
}

-(void) handlelogin:(NSNotification *)notification{
        [self dismissViewControllerAnimated:YES completion:nil];
}
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self registerForKeyboardNotifications];
    _Count = 0;
   // [self createXMPPInstance];
    
//    __weak MLRegisterViewController *weakself = self;
//    [self.xmppAccount requestRegFormWithCompletion:^(NSData *captchaImage, NSDictionary *hiddenFields) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if(captchaImage) {
//                weakself.captchaImage.image= [UIImage imageWithData:captchaImage];
//                weakself.hiddenFields = hiddenFields;
//            } else {
//                //show error image
//                //self.captchaImage.image=
//            }
//            [weakself.xmppAccount disconnect:YES];  //we dont want to see any time out errors
//        });
//    } andErrorCompletion:^(BOOL success, NSString* error) {
//        NSString *displayMessage = error;
//        if(displayMessage.length==0) displayMessage = NSLocalizedString(@"Could not request registration form. Please check your internet connection and try again.", @ "");
//        UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error", @ "") message:displayMessage preferredStyle:UIAlertControllerStyleAlert];
//        [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Close", @ "") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//            [alert dismissViewControllerAnimated:YES completion:nil];
//        }]];
//        [self presentViewController:alert animated:YES completion:nil];
//    }];
}

-(void) createXMPPInstance
{
    MLXMPPIdentity* identity = [[MLXMPPIdentity alloc] initWithJid:@"nothing@yax.im" password:@"nothing" andResource:@"MonalReg"];
    MLXMPPServer* server = [[MLXMPPServer alloc] initWithHost:@"" andPort:[NSNumber numberWithInt:52202] andDirectTLS:NO];
    self.xmppAccount = [[xmpp alloc] initWithServer:server andIdentity:identity andAccountNo:@"-1"];
}

-(void) ErrorAlertWithmsg: (NSString * ) msg {

  UIAlertController *alertvc = [UIAlertController alertControllerWithTitle:@"Warning" message: msg preferredStyle: UIAlertControllerStyleAlert];

  UIAlertAction *action = [UIAlertAction actionWithTitle:@"Ok" style: UIAlertActionStyleDefault handler: ^ (UIAlertAction * _Nonnull action) {
      dispatch_async(dispatch_get_main_queue(), ^{
          self.loginHUD.hidden = YES;
          [self.loginHUD hideAnimated:YES];
          [self.loginHUD removeFromSuperview];
      });
     
                }
                ];
    [alertvc addAction: action];

    [self presentViewController: alertvc animated: true completion: nil];

}

-(IBAction)registerAccount:(id) sender
{
    
    if(self.jid.text.length == 0)
        {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Warning", @"") message:NSLocalizedString(@"Please make sure you have entered a username.", @"") preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Close", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [alert dismissViewControllerAnimated:YES completion:nil];
            }]];
            [self presentViewController:alert animated:YES completion:nil];
            return;
        }

    if([self.jid.text rangeOfString:@"@"].location != NSNotFound)
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Invalid username", @"") message:NSLocalizedString(@"The username does not need to have an @ symbol. Please try again.", @"") preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Close", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [alert dismissViewControllerAnimated:YES completion:nil];
        }]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }

    self.loginHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.loginHUD.label.text = NSLocalizedString(@"Verifying the username", @"");
    self.loginHUD.mode = MBProgressHUDModeIndeterminate;
    self.loginHUD.removeFromSuperViewOnHide=YES;


    self.loginHUD.hidden = NO;
    UserServices *Services = [[UserServices alloc] init];
    NSString* pushToken = [MLXMPPManager sharedInstance].pushToken;
    if(
        [MLXMPPManager sharedInstance].hasAPNSToken &&
        pushToken != nil && [pushToken length] > 0
       ){
           
//               [Services registerAPNSWithUserName:self.jid.text pushToken:pushToken completion:^(BOOL Status, NSString * ErrorMessage) {
//                   if (Status == TRUE){
                     //  Services userName
    [self.registerButton removeTarget:self action: @selector(registerAccount:) forControlEvents:UIControlEventTouchUpInside];
    [Services registerAPNSWithUserName:self.jid.text pushToken:pushToken completion:^(BOOL Status, NSString * ErrorMessage) {
        if (Status == TRUE){
          //  Services userName
            dispatch_async(dispatch_get_main_queue(), ^{
                if (_Count == 0) {
                    [Services userNamePresenceWithUserName:self.jid.text  pushToken:pushToken completion:^(BOOL Status, NSString * _Nullable ErrorMessage, NSString *_Nullable OTP) {
                            
                                   if (Status == TRUE ){
                                       self.Count = self.Count + 1;
                                       if (OTP != nil){
        //                                   NSString *message = [NSString stringWithFormat:@"Authentication code for %@ is %@",self.jid.text,OTP];
        //                                   UNMutableNotificationContent* content = [[UNMutableNotificationContent alloc] init];
        //                                   content.title = self.jid.text;
        //                                   content.body = message;
        //                                   content.sound = [UNNotificationSound defaultSound];
        //                                   UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
        //                                   UNNotificationRequest* request = [UNNotificationRequest requestWithIdentifier: self.jid.text content:content trigger:nil];
        //                                   [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        //                                       if(error)
        //                                           DDLogError(@"Error posting xmppError notification: %@", error);
        //                                   }];
                                       }
                                       
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          self.loginHUD.label.text = NSLocalizedString(@"Verified.", @"");
                                          self.loginHUD.hidden = YES;
                                         // [self.loginHUD removeFromSuperview];
        //                                  NSString *message = [NSString stringWithFormat:@"Authentication code for %@ is %@",self.jid.text,OTP];
                                          UNMutableNotificationContent* content = [[UNMutableNotificationContent alloc] init];
                                          content.title = self.jid.text;
                                          content.body = @"Successfully verified, Please Enter the verification code.";
                                          content.sound = [UNNotificationSound defaultSound];
                                          UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
                                          UNNotificationRequest* request = [UNNotificationRequest requestWithIdentifier: self.jid.text content:content trigger:nil];
                                          [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
                                              if(error)
                                                  DDLogError(@"Error posting xmppError notification: %@", error);
                                          }];

                                          [self performSegueWithIdentifier:@"LoginSegue" sender:nil];
                                          
                                           
                                      });
                                       
                                       
                                   }else{

                                       if (ErrorMessage != Nil){
                                           if(ErrorMessage != nil){
                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                   self.loginHUD.hidden = YES;
                                                   [self.loginHUD hideAnimated:YES];
                                                   [self.loginHUD removeFromSuperview];
                                                   [self ErrorAlertWithmsg:@"Something went wrong. Please try again."];
                                               });
    //
                                           } else{
                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                   self.loginHUD.hidden = YES;
                                                   [self.loginHUD hideAnimated:YES];
                                                   [self.loginHUD removeFromSuperview];
                                                   if (ErrorMessage != nil){
                                                       [self ErrorAlertWithmsg:ErrorMessage];
                                                   }
                                               });
                                          }
                                           
                                           
                                       }
                                   }
                               }];
                }
                
            });
        
    
                   }
else{

                       dispatch_async(dispatch_get_main_queue(), ^{
                           self.loginHUD.hidden = YES;
                           [self.loginHUD hideAnimated:YES];
                           [self.loginHUD removeFromSuperview];
                           if (ErrorMessage != nil){
                               [self ErrorAlertWithmsg:@"Something went wrong. Please try again."];
                           }

                       });
                   }

               }];


           
       }else{

       }

    
}
  


-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"LoginSegue"])
    {
        //[[HelperTools defaultsDB] setBool:YES forKey:@"HasSeenLogin"];
//      MLLogInViewController* dest = (MLLogInViewController *) segue.destinationViewController;
//        dest.username = self.jid.text;
        UINavigationController *dest = (UINavigationController *) segue.destinationViewController;
        MLLogInViewController *loginVc = (MLLogInViewController *)dest.topViewController;
        loginVc.username = self.jid.text;
        //dest.registeredAccount = [NSString stringWithFormat:@"%@@%@",self.jid.text, kRegServer];
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

-(IBAction) openTos:(id)sender;
{
   // [self openLink:@"https://blabber.im/en/nutzungsbedingungen/"];
    [self openLink:@"https://yaxim.org/yax.im/"];
}

-(void) openLink:(NSString *) link
{
    NSURL *url= [NSURL URLWithString:link];
    
    if ([url.scheme isEqualToString:@"http"] || [url.scheme isEqualToString:@"https"] ) {
        SFSafariViewController *safariView = [[ SFSafariViewController alloc] initWithURL:url];
        [self presentViewController:safariView animated:YES completion:nil];
    }
}

#pragma mark -textfield delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.activeField= textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.activeField=nil;
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
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
}



@end
