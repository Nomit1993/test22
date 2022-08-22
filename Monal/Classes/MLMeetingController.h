//
//  MLMeetingController.h
//  jrtplib-static
//
//  Created by mohanchandaluri on 07/02/22.
//  Copyright © 2022 Monal.im. All rights reserved.
//

#import <UIKit/UIKit.h>
@import WebKit;
NS_ASSUME_NONNULL_BEGIN

@interface MLMeetingController : UIViewController
@property (weak, nonatomic) IBOutlet WKWebView *meetView;
@property (strong ,nonatomic) NSURL *meetingURL;
@end

NS_ASSUME_NONNULL_END
