//
//  MLAccountCell.m
//  Monal
//
//  Created by Anurodh Pokharel on 2/8/15.
//  Copyright (c) 2015 Monal.im. All rights reserved.
//

#import "MLSwitchCell.h"
#import "HelperTools.h"
#import "MBProgressHUD.h"
@import MobileCoreServices;
#import "MLNotificationQueue.h"
#import <LocalAuthentication/LocalAuthentication.h>
@interface MLSwitchCell ()

@property (nonatomic, strong) NSString* defaultsKey;
@property (nonatomic, strong) sliderUpdate sliderFilter;

@end

@implementation MLSwitchCell

-(void) clear
{
    self.defaultsKey = nil;
    self.sliderFilter = nil;

    self.cellLabel.text = nil;

    self.labelRight.text = nil;
    self.labelRight.hidden = YES;
    
    self.textInputField.text = nil;
    self.textInputField.hidden = YES;

    self.toggleSwitch.hidden = YES;
    
    self.slider.hidden = YES;
    self.switchTouch.hidden = YES;

    self.imageView.image = nil;
    self.textLabel.text = nil;
    self.detailTextLabel.text = nil;
    self.accessoryView = nil;
    
    self.accessoryType = UITableViewCellAccessoryNone;
}

-(void) initTapCell:(NSString*) leftLabel
{
    [self clear];
    
    self.cellLabel.text = leftLabel;
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

-(void) initCell:(NSString*) leftLabel withLabel:(NSString*) rightLabel
{
    [self clear];

    self.cellLabel.text = leftLabel;
    self.labelRight.text = rightLabel;
    self.labelRight.hidden = NO;
}

-(void) initCell:(NSString*) leftLabel withTextField:(NSString*) rightText    andPlaceholder:(NSString*) placeholder andTag:(uint16_t) tag
{
    [self initCell:leftLabel withTextField:rightText secureEntry:NO andPlaceholder:placeholder andTag:tag];
}

-(void) initCell:(NSString*) leftLabel withTextField:(NSString*) rightText secureEntry:(BOOL) secureEntry andPlaceholder:(NSString*) placeholder andTag:(uint16_t) tag
{
    [self clear];

    self.cellLabel.text = leftLabel;
    self.textInputField.text = rightText;
    self.textInputField.placeholder = placeholder;
    self.textInputField.tag = tag;
    self.textInputField.secureTextEntry = secureEntry;
    self.textInputField.hidden = NO;
}

-(void) initCell:(NSString*) leftLabel withTextFieldDefaultsKey:(NSString*) key andPlaceholder:(NSString*) placeholder;
{
    [self initCell:leftLabel withTextField:[[HelperTools defaultsDB] stringForKey:key] andPlaceholder:placeholder andTag:0];
    self.defaultsKey = key;
}

-(void) initCell:(NSString*) leftLabel withToggle:(BOOL) toggleValue andTag:(uint16_t) tag
{
    [self clear];
    
    self.cellLabel.text = leftLabel;
    self.toggleSwitch.on = toggleValue;
    self.toggleSwitch.tag = tag;
    self.toggleSwitch.hidden = NO;
}

-(void) initCell:(NSString*) leftLabel withToggleDefaultsKey:(NSString*) key
{
    [self initCell:leftLabel withToggle:[[HelperTools defaultsDB] boolForKey:key] andTag:0];
    [self.toggleSwitch addTarget:self action:@selector(switchChange) forControlEvents:UIControlEventValueChanged];
    self.defaultsKey = key;
}

-(void) initCell:(NSString*) leftLabel withSliderDefaultsKey:(NSString*) key minValue:(float) minValue maxValue:(float) maxValue
{
    [self initCell:leftLabel withSliderDefaultsKey:key minValue:minValue maxValue:maxValue withLoadFunc:nil withUpdateFunc:nil];
}

- (IBAction)actionSlider:(id)sender {
    
    if([sender isOn]){
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"loginWithTouchId"];
        [[NSUserDefaults standardUserDefaults] setObject:@"true" forKey:@"loginWithTouchId"];
        [[NSUserDefaults standardUserDefaults] synchronize];
       }else{
           [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"loginWithTouchId"];
           [[NSUserDefaults standardUserDefaults] setObject:@"false" forKey:@"loginWithTouchId"];
           [[NSUserDefaults standardUserDefaults] synchronize];
       }
}

-(void) initCell:(NSString*) leftLabel withSliderDefaultsKey:(NSString*) key minValue:(float) minValue maxValue:(float) maxValue withLoadFunc:(sliderUpdate) sliderLoad withUpdateFunc:(sliderUpdate) sliderUpdate
{
    [self clear];

    self.cellLabel.text = leftLabel;

    self.slider.minimumValue = minValue;
    self.slider.maximumValue = maxValue;

    if(sliderLoad)
        self.slider.value = sliderLoad(self.cellLabel, [[HelperTools defaultsDB] floatForKey:key]);
    else
        self.slider.value = [[HelperTools defaultsDB] floatForKey:key];

    [self.slider addTarget:self action:@selector(sliderChange) forControlEvents:UIControlEventValueChanged];
    _defaultsKey = key;
    self.sliderFilter = sliderUpdate;
    self.slider.hidden = NO;
}

#pragma mark uiswitch delegate
-(void) setpasscode{
    
    LAContext *context = [[LAContext alloc] init];

    NSError *error = nil;
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthentication error:&error]) {
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthentication
                localizedReason:@"SAI Locked"
                          reply:^(BOOL success, NSError *error) {
                               dispatch_async(dispatch_get_main_queue(), ^{
                              if (error) {
                                  [_toggleSwitch setOn:NO animated:YES];
                                  [[HelperTools defaultsDB] setBool:NO forKey:self.defaultsKey];
                              }

      if (success) {
              
         } else {
             [_toggleSwitch setOn:NO animated:YES];
             [[HelperTools defaultsDB] setBool:NO forKey:self.defaultsKey];
         }
                                   
         });
        }];
       } else {

    }
    }
-(void) switchChange
{
    if(self.defaultsKey == nil)
        return;
    // save new switch state to defaultsDB
    [[HelperTools defaultsDB] setBool:_toggleSwitch.on forKey:self.defaultsKey];
    if ([self.defaultsKey isEqualToString:@"loginWithTouchId"]){
        BOOL Granted = [[HelperTools defaultsDB] boolForKey:@"loginWithTouchId"];
                              if (Granted == YES) {
                                  LAContext *context = [[LAContext alloc] init];
                                          NSError *error = nil;
                                  
                                          //LAPolicyDeviceOwnerAuthenticationWithBiometrics
                                          // LAPolicyDeviceOwnerAuthentication
                                          if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
                                            [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                                                localizedReason:@"Are you the device owner?"
                                                     reply:^(BOOL success, NSError *error) {
                                                       dispatch_async(dispatch_get_main_queue(), ^{
                                                         if (error) {
                                                             [_toggleSwitch setOn:NO animated:YES];
                                                             [[HelperTools defaultsDB] setBool:NO forKey:self.defaultsKey];
                                                           return;
                                                         }
                                                         if (success) {
                                                           
                                                         }else{
                                                             [_toggleSwitch setOn:NO animated:YES];
                                                             [[HelperTools defaultsDB] setBool:NO forKey:self.defaultsKey];
                                                             [self setpasscode];
                                                            // [[HelperTools defaultsDB] setBool:_toggleSwitch.on forKey:self.defaultsKey];
                                                         }
                                                        
                                                       });
                                                
                                                     }];
                              }
    }
    }
    else if ([self.defaultsKey isEqualToString:@"darkModeEnable"]) {
            if (self.toggleSwitch.isOn == TRUE) {
                [self.window setOverrideUserInterfaceStyle:UIUserInterfaceStyleDark];
            } else if (self.toggleSwitch.isOn == FALSE) {
                [self.window setOverrideUserInterfaceStyle:UIUserInterfaceStyleLight];
            }
        [[MLNotificationQueue currentQueue] postNotificationName:kMonalrefreshTabController object:nil userInfo:nil];
        }

}

//-(void) showSuccessHUD
//{
//    dispatch_async(dispatch_get_main_queue(), ^{
//        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo: animated:YES];
//        hud.mode = MBProgressHUDModeCustomView;
//        hud.removeFromSuperViewOnHide = YES;
//        hud.label.text = NSLocalizedString(@"Success", @"");
//        hud.detailsLabel.text = NSLocalizedString(@"The account has been saved", @"");
//        UIImage *image = [[UIImage imageNamed:@"success"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
//        hud.customView = [[UIImageView alloc] initWithImage:image];
//        [hud hideAnimated:YES afterDelay:1.0f];
//
//    });
//}
#pragma mark uilabel delegate

-(void) sliderChange
{
    if(self.defaultsKey == nil)
        return;
    float filteredValue;

    if(self.sliderFilter == nil)
        filteredValue = self.slider.value;
    else
        filteredValue = self.sliderFilter(self.cellLabel, self.slider.value);

    // save new slider state to defaultsDB
    [[HelperTools defaultsDB] setFloat:filteredValue forKey:self.defaultsKey];
}

#pragma mark uitextfield delegate
-(void) textFieldDidBeginEditing:(UITextField*) textField
{
}

-(BOOL) textFieldShouldReturn:(UITextField*) textField
{
    if(self.defaultsKey == nil)
        return YES;
    // save new value to defaultsDB
    [[HelperTools defaultsDB] setObject:_textInputField.text forKey: self.defaultsKey];
    [textField resignFirstResponder];
    return YES;
}


@end
