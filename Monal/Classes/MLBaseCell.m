//
//  MLBaseCell.m
//  Monal
//
//  Created by Anurodh Pokharel on 12/24/17.
//  Copyright © 2017 Monal.im. All rights reserved.
//

#import "HelperTools.h"
#import "MLBaseCell.h"
#import "MLMessage.h"
#import "MLImageManager.h"
#import "MLContact.h"

@implementation MLBaseCell

-(id) init
{
    self = [super init];
    [self setRetryButtonImage];
    return self;
}

-(void) initCell:(MLMessage*) message
{
    [self setRetryButtonImage];

    self.messageHistoryId = message.messageDBId;
    self.messageBody.text = message.messageText;
    self.outBound = !message.inbound;
    self.imageOfMessageSendeer.image = [MLImageManager circularImage:[UIImage imageNamed:@"noicon"]]; 
}

-(void) setGroupMessageImage:(MLContact*)contact {
    dispatch_async(dispatch_get_main_queue(), ^{
            [[MLImageManager sharedInstance] getIconForContact:contact.contactJid andAccount:contact.accountId withCompletion:^(UIImage *image) {
                if (image != nil) {
                    self.imageOfMessageSendeer.image = [MLImageManager circularImage:image];
                } else {
                    self.imageOfMessageSendeer.image = [MLImageManager circularImage:[UIImage imageNamed:@"noicon"]];
                }
            }];
        });
}

-(void) setRetryButtonImage
{
    if(@available(iOS 13.0, *))
        [self.retry setImage:[UIImage systemImageNamed:@"info.circle"] forState:UIControlStateNormal];
    else
        [self.retry setImage:[UIImage imageNamed:@"724-info"] forState:UIControlStateNormal];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    BOOL backgrounds = [[HelperTools defaultsDB] boolForKey:@"ChatBackgrounds"];
    if(backgrounds) {
        self.name.textColor=[UIColor whiteColor];
        self.date.textColor=[UIColor whiteColor];
        self.messageStatus.textColor=[UIColor whiteColor];
        self.dividerDate.textColor=[UIColor whiteColor];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void) updateCellWithNewSender:(BOOL) newSender
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    if([self.parent respondsToSelector:@selector(retry:)]) {
        [self.retry addTarget:self.parent action:@selector(retry:) forControlEvents:UIControlEventTouchUpInside];
    }
#pragma clang diagnostic pop
    
    self.retry.tag= [self.messageHistoryId integerValue];
    
    if(self.deliveryFailed) {
        self.retry.hidden=NO;
    }
    else{
        self.retry.hidden=YES;
    }
    
/*    if(self.name) {
        if(self.name.text.length==0) {
            self.nameHeight.constant=0;
            self.bubbleTop.constant=0;
            self.dayTop.constant=0;
        } else  {
            self.nameHeight.constant= kDefaultTextHeight;
            self.bubbleTop.constant=kDefaultTextOffset;
            self.dayTop.constant=kDefaultTextOffset;
        }
    }
    
    if(self.dividerDate.text.length==0) {
        self.dividerHeight.constant=0;
        if(!self.name) {
            self.bubbleTop.constant=0;
            self.dayTop.constant=0;
        }
    } else  {
        if(!self.name) {
            self.bubbleTop.constant=kDefaultTextOffset;
            self.dayTop.constant=kDefaultTextOffset;
        }
        self.dividerHeight.constant=kDefaultTextHeight;
    }
    
    if(newSender &&  self.dividerHeight.constant==0) {
        self.dividerHeight.constant= kDefaultTextHeight/2;
    }*/
    
    
    if (self.dividerDate.text.length == 0 || self.dividerDate.text == NULL) {
        self.dividerHeight.constant=0;
    } else {
        self.dividerHeight.constant=20;
    }
    
}

-(void)prepareForReuse{
    [super prepareForReuse];
    self.deliveryFailed=NO;
    self.outBound=NO;
}

@end
