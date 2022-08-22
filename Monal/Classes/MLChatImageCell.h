//
//  MLChatImageCell.h
//  Monal
//
//  Created by Anurodh Pokharel on 12/24/17.
//  Copyright © 2017 Monal.im. All rights reserved.
//

#import "MLBaseCell.h"

@class MLMessage;

@interface MLChatImageCell : MLBaseCell

@property (strong, nonatomic) IBOutlet UILabel *lblbaundry;

@property (strong, nonatomic) IBOutlet UIView *viewOfStarMessage;
@property (strong, nonatomic) IBOutlet UILabel *lblMessageSenderName;
@property (strong, nonatomic) IBOutlet UILabel *lblTimestamp;
@property (strong, nonatomic) IBOutlet UIView *viewOfImage;

-(void) initCellWithMLMessage:(MLMessage*) message;

-(UIImage*) getDisplayedImage;

@end

