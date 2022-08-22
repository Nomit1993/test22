//
//  MLMeetingController.m
//  jrtplib-static
//
//  Created by mohanchandaluri on 07/02/22.
//  Copyright © 2022 Monal.im. All rights reserved.
//

#import "MLMeetingController.h"

@interface MLMeetingController ()

@end

@implementation MLMeetingController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
-(void) viewWillAppear:(BOOL)animated
{
    
    [self.meetView evaluateJavaScript:@"navigator.userAgent" completionHandler:^(NSString* _Nullable oldUA, NSError * _Nullable error) {

        // modify ua
        self.meetView.customUserAgent = @"Mozilla/5.0 (Macintosh; Intel Mac OS X 12_0_1) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Safari/605.1.15";

    }];
    
    self.meetingURL = [[NSURL alloc] initWithString:@"https://meeting2.chat.securesignal.in/avtesting?jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJjb250ZXh0Ijp7InVzZXIiOnsiaWQiOiIxIiwibmFtZSI6Ik1vaGFuIGlPUyIsImF2YXRhciI6Imh0dHBzOlwvXC9tZWV0aW5nMi5pbXZhbmkuY29tXC9pbWFnZXNcL3dhdGVybWFyay5wbmciLCJlbWFpbCI6ImZvb0Bmb28uYnVpbGQiLCJhZmZpbGlhdGlvbiI6Im93bmVyIn0sImZlYXR1cmVzIjp7ImxpdmVzdHJlYW1pbmciOnRydWUsIlZDX1JFX0YwIjp0cnVlLCJWQ19TUl9GMSI6WyJyb29tMSIsInJvb20yIiwicm9vbTMiXX0sImdyb3VwIjoiR1JPVVAifSwiYXVkIjoidmFuaSB2YyIsImlzcyI6Im1lZXRpbmcyLmltdmFuaSIsInN1YiI6Im1lZXRpbmcyLmltdmFuaS5jb20iLCJyb29tIjoiKiIsIm9yaWdpbiI6Imludml0ZS5pbXZhbmkuY29tIiwiZXhwIjoxLjY0Mzc4MTQ1NDUxODI4NTNlKzI2LCJuYmYiOjE2NDM3ODE0MTl9.O898Bt6Q1AYWXmqkjSUKpF8lUFfRfFWLN3JG2STv2M3u25VDd9tiP7VwVwFKeakfTP9lyAP27yClWJsUo_2uSw"];
    [super viewWillAppear:animated];

        NSURLRequest* nsrequest = [NSURLRequest requestWithURL: self.meetingURL];
        [self.meetView loadRequest:nsrequest];

    
    
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
}
@end
