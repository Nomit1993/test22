//
//  CallViewController.m
//  Monal
//
//  Created by Anurodh Pokharel on 12/22/13.
//
//

#import <AVFoundation/AVFoundation.h>
#import "CallViewController.h"
#import "MLConstants.h"
#import "MLImageManager.h"
#import "MLXMPPManager.h"
#import <AudioToolbox/AudioToolbox.h>
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#import <AVFoundation/AVFoundation.h>
#define maxWatingSeconds 30

@interface CallViewController (){
    NSTimer *callRingTimer;
    int currentSeconds;
    AVAudioPlayer *dialtonePlayer;
    AVAudioPlayer *ringtonePlayer;
    int Pingcounter ;
}
@end



@implementation CallViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}



-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    DDLogVerbose(@"call screen will appear");
    NSError *error;
    [UIDevice currentDevice].proximityMonitoringEnabled = YES;
    NSURL *soundFileURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/dialingTone.mp3", [[NSBundle mainBundle] resourcePath]]];
   
   NSURL *ringtonesoundFileURL =  [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/hangoutsdialingTone.mp3", [[NSBundle mainBundle] resourcePath]]];
    NSString *contactName ;
    if(self.contact) {
        contactName = self.contact.contactJid;
    }
    if(!contactName) {
        contactName = NSLocalizedString(@"No Contact Selected", @ "");
    }
    
    ringtonePlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:ringtonesoundFileURL
    error:&error];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive: YES error: nil];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    dialtonePlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL
                                                                  error:&error];
    dialtonePlayer.numberOfLoops = -1; //Infinite

    ringtonePlayer.numberOfLoops = -1;
    self.userName.text = contactName;

  
    [[MLImageManager sharedInstance] getIconForContact:contactName andAccount:self.contact.accountId withCompletion:^(UIImage *image) {
        self.userImage.image = image;
    }];
    
    [[MLXMPPManager sharedInstance] callContact:self.contact];
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
        if(!granted)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertController *messageAlert =[UIAlertController alertControllerWithTitle:NSLocalizedString(@"Please Allow Audio Access",@ "") message:NSLocalizedString(@"If you want to use VOIP you will need to allow access in Settings-> Privacy-> Microphone.",@ "") preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *closeAction =[UIAlertAction actionWithTitle:NSLocalizedString(@"Close",@ "") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                    
                }];
                
                [messageAlert addAction:closeAction];
                [self presentViewController:messageAlert animated:YES completion:nil];
            });
        }
    }];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
	DDLogVerbose(NSLocalizedString(@"call screen did disappear",@ ""));
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark tableview datasource delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}


-(IBAction)cancelCall:(id)sender
{
   // [UIDevice currentDevice].proximityMonitoringEnabled=NO;
   // [[MLXMPPManager sharedInstance] hangupContact:self.contact];
   // [self.navigationController popViewControllerAnimated:YES];
  [self dismissViewControllerAnimated:YES completion:nil];
  
}

@end
