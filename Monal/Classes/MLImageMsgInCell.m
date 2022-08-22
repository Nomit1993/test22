//
//  MLImageMsgInCell.m
//  Monal
//
//  Created by mohanchandaluri on 29/04/22.
//  Copyright © 2022 Monal.im. All rights reserved.
//

#import "MLImageMsgInCell.h"
#import "UIColor+Theme.h"
#import "MLImageManager.h"
#import "MLConstants.h"
#import "DataLayer.h"
#import "HelperTools.h"
#import "MLFiletransfer.h"
@import SafariServices;
@implementation MLImageMsgCell

-(void) updateCellWithNewSender:(BOOL)newSender
{
    [super updateCellWithNewSender:newSender];

    if(self.outBound)
    {
        
        self.messageCaption.textColor=[UIColor blackColor];
       self.MessageBubble.image= [[MLImageManager sharedInstance] outboundImage];
    }
    else
    {
        
        self.messageCaption.textColor=[UIColor whiteColor];
        self.MessageBubble.image=[[MLImageManager sharedInstance] inboundImage];
    }
  
    
}

-(UIImage*) getDisplayedImage
{
    return self.thumbnailImage.image;
}

-(void) loadMessagePreviewWithCompletion:(void (^)(void))completion {
    // Remove old annotations
        //   self.messageCaption.text
    if ([self.message.messageText containsString:kMessageTypeImageCaption]){
        NSArray *messageComponents = [self.message.messageText componentsSeparatedByString:kMessageTypeImageCaption];
        self.messageCaption.text = messageComponents[1];

        if ([self.message.participantJid containsString:@"@conference.chat.securesignal.in"]){
            NSArray *components = [self.message.participantJid componentsSeparatedByString:@"@conference.chat.securesignal.in"];
            self.Name.text = components[0];
        }
        NSDictionary *imageInfo = [MLFiletransfer getFileInfoForMessage:self.message];
        UIImage* image = [UIImage imageWithContentsOfFile:imageInfo[@"cacheFile"]];
        [self.thumbnailImage setContentMode:UIViewContentModeScaleAspectFill];
        [self.thumbnailImage setImage:image];
        //self.thumbnailImage.image = image;
    }
    }

-(void)prepareForReuse
{
    [super prepareForReuse];
    self.messageBody.text=@"";
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
@end
