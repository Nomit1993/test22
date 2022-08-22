//
//  MLLogInViewController.h
//  Monal
//
//  Created by Anurodh Pokharel on 11/9/18.
//  Copyright © 2018 Monal.im. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Monal-Swift.h>
NS_ASSUME_NONNULL_BEGIN

@interface MLLogInViewController : UIViewController <UITextFieldDelegate, MLLQRCodeScannerAccountLoginDeleagte>
@property (nonatomic, weak) IBOutlet UITextField* jid;
@property (nonatomic, weak) IBOutlet UITextField* password;
@property (nonatomic, weak) IBOutlet UIButton* loginButton;
@property (nonatomic, weak) IBOutlet UIScrollView* scrollView;
@property (nonatomic, weak) IBOutlet UIView* contentView;
@property (nonatomic, weak) IBOutlet UIImageView* topImage;
@property (weak, nonatomic) IBOutlet UIButton* qrScanButton;
@property (nonnull,nonatomic,strong) NSString *username;
@property (weak, nonatomic) IBOutlet UITextField *FirstTF;
@property (weak, nonatomic) IBOutlet UITextField *secondTF;
@property (weak, nonatomic) IBOutlet UITextField *ThirdTF;
@property (weak, nonatomic) IBOutlet UITextField *FifthTF;
@property (weak, nonatomic) IBOutlet UITextField *FourthTF;
@property (weak, nonatomic) IBOutlet UITextField *SixthTF;
@property (weak, nonatomic) IBOutlet UITextField *SeventhTF;
@property (weak, nonatomic) IBOutlet UITextField *EighthTF;
@property (weak, nonatomic) IBOutlet UITextField *NinthTF;


-(IBAction) login:(id)sender;
-(IBAction) registerAccount:(id)sender;
-(IBAction) useWithoutAccount:(id)sender;


-(IBAction) tapAction:(id)sender;


@end

NS_ASSUME_NONNULL_END
