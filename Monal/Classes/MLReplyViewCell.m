//
//  MLReplyViewCell.m
//  Monal
//
//  Created by mohanchandaluri on 02/12/21.
//  Copyright © 2021 Monal.im. All rights reserved.
//

#import "MLReplyViewCell.h"
#import "UIColor+Theme.h"
#import "MLImageManager.h"
#import "MLConstants.h"
#import "DataLayer.h"
#import "HelperTools.h"
#import "MLFiletransfer.h"
@import SafariServices;
@implementation MLReplyViewCell

//- (void)awakeFromNib {
//    [super awakeFromNib];
//
//    // Initialization code
//}
//
//- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
//    [super setSelected:selected animated:animated];
//
//    // Configure the view for the selected state
//}
-(void) updateCellWithNewSender:(BOOL)newSender
{
    [super updateCellWithNewSender:newSender];

    if(self.outBound)
    {
        self.ReplySidebar.backgroundColor = [UIColor monalrandomColor];
        self.MessageText.textColor=[UIColor blackColor];
       self.MessageBubble.image= [[MLImageManager sharedInstance] outboundImage];
    }
    else
    {
        self.ReplySidebar.backgroundColor = [UIColor monalrandomColor];
        self.MessageText.textColor=[UIColor whiteColor];
        self.MessageBubble.image=[[MLImageManager sharedInstance] inboundImage];
    }
  
    
}


-(BOOL) canPerformAction:(SEL)action withSender:(id)sender
{
    if(action == @selector(openlink:))
    {
        if(self.link)
            return  YES;
    }
    return (action == @selector(copy:)) ;
}


-(void) openlink: (id) sender {
    
    if(self.link)
    {
        NSURL *url= [NSURL URLWithString:self.link];
        
        if ([url.scheme isEqualToString:@"http"] || [url.scheme isEqualToString:@"https"]) {
            SFSafariViewController *safariView = [[ SFSafariViewController alloc] initWithURL:url];
            [self.parent presentViewController:safariView animated:YES completion:nil];
        }
        
    }
}

-(void) copy:(id)sender {
    UIPasteboard *pboard = [UIPasteboard generalPasteboard];
    pboard.string =self.messageBody.text;
}

-(void) loadMessagePreviewWithCompletion:(void (^)(void))completion {
    // Remove old annotations
           NSString *replytoken = @"^$$%^";
           NSString *REPLY_END_REGEX = @"%reply-end-regex";
           NSString *REPLY_MID_REGEX = @"%reply-mid-regex";
    if ([self.message.messageText containsString:replytoken] && [self.message.messageText containsString:REPLY_MID_REGEX] && [self.message.messageText containsString:REPLY_END_REGEX]){
                    NSArray *items = [self.message.messageText componentsSeparatedByString:@"%reply-end-regex"];
                    self.MessageText.text = items[1];
                    NSArray *Replyitems = [items[0] componentsSeparatedByString:@"%reply-mid-regex"];
                    NSArray *UserLabel = [Replyitems[0] componentsSeparatedByString:@"?"];
                    self.ReplyMessagetext.text = Replyitems[1];
             self.widthConstant.constant = 0;
            if ([self.Jid containsString:UserLabel[1]]){
                    self.ReplyUserStatus.text = @"You";
                }else{
                    self.ReplyUserStatus.text = UserLabel[1];
                }
    }else{
        NSArray *items = [self.message.messageText componentsSeparatedByString:replytoken];
        NSLog(@"Reply message is %@",self.message.messageText);
        if ([items count] > 1){
            NSString *Message = items[1];
            NSString *Messageurl;
            NSArray *urlitems;
            NSArray *MessageItems;
            NSArray *UserItems;
            NSString *UserName;
            if ([Message containsString:@"geo:"]){
                urlitems = [items[1] componentsSeparatedByString:@"?"];
                Messageurl = urlitems[0];
                UserItems = [urlitems[2] componentsSeparatedByString:@"\n"];
                UserName = urlitems[1];
                MessageItems = UserItems;
                
            }else{
                urlitems = [items[1] componentsSeparatedByString:@"|"];
                if (urlitems.count == 1){
                urlitems = [items[1] componentsSeparatedByString:@"?"];
                Messageurl = urlitems[0];
                UserItems = [urlitems[2] componentsSeparatedByString:@"\n"];
                UserName = urlitems[1];
                MessageItems = UserItems;
                }else{
                    Messageurl = urlitems[0];
                    if (urlitems.count == 4){
                        UserItems = [urlitems[3] componentsSeparatedByString:@"?"];
                        
                        UserName = UserItems[1];
                        MessageItems= [UserItems[2] componentsSeparatedByString:@"\n"];
                    }else if(urlitems.count == 3){
                        UserName = urlitems[1];
                        MessageItems= [urlitems[2] componentsSeparatedByString:@"\n"];
                    }
                    
                }
            }
            if (UserName != nil){
                if ([self.Jid containsString:UserName]){
                             self.ReplyUserStatus.text = @"You";
                    }else{
                             self.ReplyUserStatus.text = UserName;
                    }
            }
            NSString *prefixToRemove = @"\n";
            NSString *newString = [MessageItems[1] copy];
            if ([MessageItems[1] hasPrefix:prefixToRemove]){
                newString = [MessageItems[1] substringFromIndex:[prefixToRemove length]];
                self.MessageText.text = newString;
            }else{
                self.MessageText.text = MessageItems[1];
            }
                
            if (Messageurl != nil){
                NSArray* searchResultArray = [[DataLayer sharedInstance] searchResultOfHistoryMessageWithKeyWords:Messageurl
                                                                                                            accountNo:self.previewContact.accountId
                                                                                                                   betweenBuddy:self.previewContact.contactJid];
                [searchResultArray enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
                    MLMessage *searchMsg = object;
                    if ([searchMsg.messageText isEqualToString:Messageurl]){
                        for (int idx = 0; idx<self.searchMessageList.count; idx++){
                            MLMessage* msg = [self.searchMessageList objectAtIndex:idx];
                            if ([searchMsg.messageText isEqualToString:msg.messageText]){
                                if([searchMsg.messageType isEqualToString:kMessageTypeUrl] && [[HelperTools defaultsDB] boolForKey:@"ShowURLPreview"]){
                                    self.ReplyMessagetext.text = @"🔗 A Link";
                                    }else if([searchMsg.filetransferMimeType hasPrefix:@"image/"])
                                    {
                                        NSDictionary *imageInfo = [MLFiletransfer getFileInfoForMessage:msg];
                                        UIImage* image = [UIImage imageWithContentsOfFile:imageInfo[@"cacheFile"]];
                                        self.ReplyMediaView.image = image;
                                        self.ReplyMessagetext.text = @"📷 Image";
                                        self.widthConstant.constant = 50;
                                    }
                                    else if([searchMsg.filetransferMimeType hasPrefix:@"audio/"]){
                                    self.ReplyMessagetext.text = @"🎵 Audio Message";
                                }
                                else if([searchMsg.filetransferMimeType hasPrefix:@"video/"]){
                                    NSDictionary *imageInfo = [MLFiletransfer getFileInfoForMessage:msg];
                                    UIImage* image = [UIImage imageWithContentsOfFile:imageInfo[@"cacheFile"]];
                                    self.ReplyMediaView.image = image;
                                    self.ReplyMessagetext.text = @"🎥 Video ";
                                    self.widthConstant.constant = 50;
                                }
                                else if([searchMsg.filetransferMimeType isEqualToString:@"application/pdf"]){
                                    NSDictionary *imageInfo = [MLFiletransfer getFileInfoForMessage:msg];
                                    UIImage* image = [UIImage imageWithContentsOfFile:imageInfo[@"cacheFile"]];
                                    self.ReplyMediaView.image = image;
                                    self.ReplyMessagetext.text =@"📄 Document";
                                    self.widthConstant.constant = 50;
                                }
                                else if([searchMsg.messageType isEqualToString:kMessageTypeGeo]){
                                   
                                    self.ReplyMessagetext.text = @"📍Location ";
                                    self.widthConstant.constant = 0;
                                }
                            }
                            
                        }
                    }

                }];
            }
               
            }
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

