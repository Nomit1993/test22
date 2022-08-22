//
//  MLFileTransferVideoCell.h
//  Monal
//
//  Created by Jim Tsai(poormusic2001@gmail.com) on 2020/12/23.
//  Copyright © 2020 Monal.im. All rights reserved.
//

#import "MLBaseCell.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MLFileTransferVideoCell : MLBaseCell


@property (weak, nonatomic) IBOutlet UIView *videoView;
@property (strong, nonatomic) IBOutlet UIView *viewOfStarMessage;
@property (strong, nonatomic) IBOutlet UILabel *lblMessageSenderName;
@property (strong, nonatomic) IBOutlet UILabel *lblTimestamp;
@property (strong, nonatomic) IBOutlet UILabel *lblBaundry;

-(void)avplayerConfigWithUrlStr:(NSString*)fileUrl andMimeType:(NSString*) mimeType fileName:(NSString*) fileName andVC:(UIViewController*) vc;
@end

NS_ASSUME_NONNULL_END
