//
//  MLContactCell.m
//  Monal
//
//  Created by Anurodh Pokharel on 7/7/13.
//
//

#import "MLContactCell.h"
#import "MLConstants.h"
#import "MLContact.h"
#import "MLMessage.h"
#import "DataLayer.h"
#import "MLXEPSlashMeHandler.h"
#import "HelperTools.h"
#import "MLXMPPManager.h"
#import "xmpp.h"
#import "MLMucProcessor.h"
#import "MLImageManager.h"
#import <QuartzCore/QuartzCore.h>
#import "MLInitialAvatar.h"
#import <Monal-Swift.h>
#import <monalxmpp/monalxmpp-Swift.h>
#import "HJCombinationAvatar.h"
@class GroupUser;

@interface MLContactCell()

@end

@implementation MLContactCell

-(void) awakeFromNib
{
    [super awakeFromNib];
}

-(void) initCell:(MLContact*) contact withLastMessage:(MLMessage* _Nullable) lastMessage
{
    NSMutableArray * Avatars = [[NSMutableArray alloc] init];
    __block NSMutableArray *groupAvatars = [[NSMutableArray alloc] init];
    self.accountNo = contact.accountId.integerValue;
    self.username = contact.contactJid;

    [self showDisplayName:contact.contactDisplayName];
    [self setPinned:contact.isPinned];
    [self setCount:(long)contact.unreadCount];
    if (lastMessage != nil){
        [self displayLastMessage:lastMessage forContact:contact];
    }
   
   
    if(@available(iOS 13.0, *))
     {
         if(contact.isGroup)
         {
             [[MLImageManager sharedInstance] getIconForContact:contact.contactJid andAccount:contact.accountId withCompletion:^(UIImage *image) {
                 if (!image){
            
//                     dispatch_async(dispatch_get_main_queue(), ^{
               
                         NSArray* members = [[DataLayer sharedInstance] getMembersAndParticipantsOfMuc:contact.contactJid forAccountId:contact.accountId];
                       
//                         NSArray* accountList = [[DataLayer sharedInstance] accountList];
//                         NSString *myjid = [NSString stringWithFormat:@"%@@%@",[[accountList objectAtIndex:0] objectForKey:@"username"],[[accountList objectAtIndex:0] objectForKey:@"domain"]];
                     if (members.count > 0){
                         [members enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
                             NSDictionary *member = object;
                             NSString *jid = member[@"participant_jid"];
                             if (jid == nil){
                                 jid = member[@"member_jid"];
                             }
//                           if (![jid isEqualToString:myjid]){
                               [[MLImageManager sharedInstance] getIconForContact:jid andAccount:contact.accountId withCompletion:^(UIImage *userimage) {
                                   if (!userimage){
                                       NSArray *username = [jid componentsSeparatedByString:@"@"];
                                       MLInitialAvatar *avatar = [[MLInitialAvatar alloc] initWithRect:self.userImage.bounds fullName:username[0]];
                                     
                                NSData *pngData = UIImagePNGRepresentation(avatar.imageRepresentation);
                               UIImage *initialimage = [UIImage imageWithData:pngData];
                                      
                                      if(Avatars.count == members.count){
                                          // groupAvatars = [NSMutableArray arrayWithArray:Avatars];
                                           HJCombinationAvatar *combinationAvatar = [HJCombinationAvatar combinationAvatarWithFrame:self.userImage.layer.frame images:Avatars];
                                           self.userImage.image = [combinationAvatar imageHeadCardView];
                                          NSData *avatarData = UIImagePNGRepresentation([combinationAvatar imageHeadCardView]);
                                         // NSData * vcardData = [HelperTools dataWithBase64EncodedString:binvalData];
                                          
                                          [[MLImageManager sharedInstance] setIconForContact:contact.contactJid andAccount:contact.accountId WithData:avatarData];
                                       } else if (Avatars.count >= 0 && Avatars.count < 5){
                                           [Avatars addObject:initialimage];
                                           HJCombinationAvatar *combinationAvatar = [HJCombinationAvatar combinationAvatarWithFrame:self.userImage.layer.frame images:Avatars];
                                           NSData *avatarData = UIImagePNGRepresentation([combinationAvatar imageHeadCardView]);
                                           [[MLImageManager sharedInstance] setIconForContact:contact.contactJid andAccount:contact.accountId WithData:avatarData];
                                           self.userImage.image = [combinationAvatar imageHeadCardView];
                                       } else{
                                          // groupAvatars = [NSMutableArray arrayWithArray:Avatars];
                                           HJCombinationAvatar *combinationAvatar = [HJCombinationAvatar combinationAvatarWithFrame:self.userImage.layer.frame images:Avatars];
                                           NSData *avatarData = UIImagePNGRepresentation([combinationAvatar imageHeadCardView]);
                                           [[MLImageManager sharedInstance] setIconForContact:contact.contactJid andAccount:contact.accountId WithData:avatarData];
                                           self.userImage.image = [combinationAvatar imageHeadCardView];
                                           *stop = YES;
                                           
                                       }
                                      
                                   }else{
//                                       NSData *pngData = UIImagePNGRepresentation(userimage);
//                                      UIImage *pngimage = [UIImage imageWithData:pngData];
                                       if(Avatars.count == members.count){
                                           groupAvatars = [NSMutableArray arrayWithArray:Avatars];
                                           HJCombinationAvatar *combinationAvatar = [HJCombinationAvatar combinationAvatarWithFrame:self.userImage.layer.frame images:Avatars];
                                           
                                           NSData *avatarData = UIImagePNGRepresentation([combinationAvatar imageHeadCardView]);
                                          
                                           [[MLImageManager sharedInstance] setIconForContact:contact.contactJid andAccount:contact.accountId WithData:avatarData];
                                           self.userImage.image =  [MLImageManager circularImage:[combinationAvatar imageHeadCardView]];
                                       } else if (Avatars.count >= 0 && Avatars.count < 5){
                                           [Avatars addObject:userimage];
                                           HJCombinationAvatar *combinationAvatar = [HJCombinationAvatar combinationAvatarWithFrame:self.userImage.layer.frame images:Avatars];
                                           NSData *avatarData = UIImagePNGRepresentation([combinationAvatar imageHeadCardView]);
                                           [[MLImageManager sharedInstance] setIconForContact:contact.contactJid andAccount:contact.accountId WithData:avatarData];
                                           self.userImage.image = [MLImageManager circularImage:[combinationAvatar imageHeadCardView]];
                                       }
                                       else{
                                          // groupAvatars = [NSMutableArray arrayWithArray:Avatars];
                                           HJCombinationAvatar *combinationAvatar = [HJCombinationAvatar combinationAvatarWithFrame:self.userImage.layer.frame images:Avatars];
                                           NSData *avatarData = UIImagePNGRepresentation([combinationAvatar imageHeadCardView]);
                                           [[MLImageManager sharedInstance] setIconForContact:contact.contactJid andAccount:contact.accountId WithData:avatarData];
                                           self.userImage.image = [MLImageManager circularImage:[combinationAvatar imageHeadCardView]];
                                           *stop = YES;
                                       }
                                       
                                   }
                                   
                                 }];
                             //}
                         }];
                     }else{
                         xmpp *account_contact = [[MLXMPPManager sharedInstance] getConnectedAccountForID:contact.accountId];
                         [MLMucProcessor fetchMembersList:contact.contactJid onAccount:account_contact];
                         self.userImage.image = [MLImageManager circularImage:[UIImage imageNamed:@"noicon_muc"]];
                     }
                       
                 }else{
                     self.userImage.image = image;
                 }
              
                 
                 
             }];
            
           
         }
         else
         {
             
              [[MLImageManager sharedInstance] getIconForContact:contact.contactJid andAccount:contact.accountId withCompletion:^(UIImage *image) {
                  if (!image){
                      if (![contact.contactJid containsString:@"conference.chat.securesignal.in"]){
                          MLInitialAvatar *avatar = [[MLInitialAvatar alloc] initWithRect:self.userImage.bounds fullName:contact.contactDisplayName];
                          self.userImage.image = [MLImageManager circularImage:avatar.imageRepresentation];
                          NSData *avatarData = UIImagePNGRepresentation(avatar.imageRepresentation);
                          [[MLImageManager sharedInstance] setIconForContact:contact.contactJid andAccount:contact.accountId WithData:avatarData];
                      }else{
                          self.userImage.image = [MLImageManager circularImage:[UIImage imageNamed:@"noicon_muc"]];
                      }
                     
                  }else{
                      self.userImage.image = image;
                  }
              }];
           
         }
            
     }

    else
        [[MLImageManager sharedInstance] getIconForContact:contact.contactJid andAccount:contact.accountId withCompletion:^(UIImage *image) {
            self.userImage.image = image;
        }];
    BOOL muted = [[DataLayer sharedInstance] isMutedJid:contact.contactJid onAccount:contact.accountId];
    self.muteBadge.hidden = !muted;
}

-(void) displayLastMessage:(MLMessage* _Nullable) lastMessage forContact:(MLContact*) contact
{
    NSString * senderOfLastGroupMsg;
    NSString *fromJid;
    xmpp* account;
    MLContact* fromContact;
    if(contact.isGroup == YES){
        account = [[MLXMPPManager sharedInstance].connectedXMPP objectAtIndex:0];
        fromJid = lastMessage.participantJid;
    }
    if(fromJid != nil){
        fromContact = [MLContact createContactFromJid:fromJid andAccountNo:account.accountNo];
        senderOfLastGroupMsg = fromContact.contactDisplayName;
    }else{
        senderOfLastGroupMsg = lastMessage.participantJid;
    }
    
      

    if(lastMessage)
    {
        if([lastMessage.messageType isEqualToString:kMessageTypeUrl] && [[HelperTools defaultsDB] boolForKey:@"ShowURLPreview"])
            [self showStatusText:NSLocalizedString(@"🔗 A Link", @"") inboundDir:lastMessage.inbound fromUser:senderOfLastGroupMsg message:lastMessage];
        
        else if([lastMessage.messageText containsString:KMessageTypeReply]){
            NSTextAttachment *Replyattachment = [[NSTextAttachment alloc] init];
            Replyattachment.image = [UIImage imageNamed:@"reply-M"];
            NSAttributedString *ReplyattachmentString = [NSAttributedString attributedStringWithAttachment:Replyattachment];
             NSMutableAttributedString *Reply= [[NSMutableAttributedString alloc] initWithString:@""];
             [Reply appendAttributedString:ReplyattachmentString];
            NSString *Status = [[Reply string] stringByAppendingString:@"Reply Message"];
           // [Reply appendAttributedString:@" Reply Message"];
            [self showStatusText:Status inboundDir:lastMessage.inbound fromUser:senderOfLastGroupMsg message:lastMessage];
        }
   
        else if ([lastMessage.messageType isEqualToString:KMessageDecrypt]){
            NSString *Status = @"New Message";
            [self showStatusText:Status inboundDir:lastMessage.inbound fromUser:senderOfLastGroupMsg message:lastMessage];
        }
        else if([lastMessage.messageType isEqualToString:kMessageTypeFiletransfer])
        {
            if([lastMessage.filetransferMimeType hasPrefix:@"image/"])
                [self showStatusText:NSLocalizedString(@"📷 An Image", @"") inboundDir:lastMessage.inbound fromUser:senderOfLastGroupMsg message:lastMessage];
            else if([lastMessage.filetransferMimeType hasPrefix:@"audio/"])
                [self showStatusText:NSLocalizedString(@"🎵 A Audiomessage", @"") inboundDir:lastMessage.inbound fromUser:senderOfLastGroupMsg message:lastMessage];
            else if([lastMessage.filetransferMimeType hasPrefix:@"video/"])
                [self showStatusText:NSLocalizedString(@"🎥 A Video", @"") inboundDir:lastMessage.inbound fromUser:senderOfLastGroupMsg message:lastMessage];
            else if([lastMessage.filetransferMimeType isEqualToString:@"application/pdf"])
                [self showStatusText:NSLocalizedString(@"📄 A Document", @"") inboundDir:lastMessage.inbound fromUser:senderOfLastGroupMsg message:lastMessage];
            else
                [self showStatusText:NSLocalizedString(@"📁 A File", @"") inboundDir:lastMessage.inbound fromUser:senderOfLastGroupMsg message:lastMessage];
        }
        else if ([lastMessage.messageType isEqualToString:kMessageTypeMessageDraft])
        {
            NSString* draftPreview = [NSString stringWithFormat:NSLocalizedString(@"Draft: %@", @""), lastMessage.messageText];
            [self showStatusTextItalic:draftPreview withItalicRange:NSMakeRange(0, 6)];
        }
        else if([lastMessage.messageType isEqualToString:kMessageTypeGeo])
            [self showStatusText:NSLocalizedString(@"📍 A Location", @"") inboundDir:lastMessage.inbound fromUser:senderOfLastGroupMsg message:lastMessage];
        else
        {
            if([lastMessage.messageText hasPrefix:@"/me "])
            {
                NSString* displayName;
                xmpp* account = [[MLXMPPManager sharedInstance] getConnectedAccountForID:contact.accountId];
                if(lastMessage.inbound == NO)
                    displayName = [MLContact ownDisplayNameForAccount:account];
                else
                    displayName = [contact contactDisplayName];

                NSString* replacedMessageText = [[MLXEPSlashMeHandler sharedInstance] stringSlashMeWithAccountId:contact.accountId displayName:displayName actualFrom:lastMessage.actualFrom message:lastMessage.messageText isGroup:contact.isGroup];

                NSRange replacedMsgAttrRange = NSMakeRange(0, replacedMessageText.length);

                [self showStatusTextItalic:replacedMessageText withItalicRange:replacedMsgAttrRange];
            }
            else
            {
                if ([lastMessage.messageText containsString:@"message-action"]){
                    NSError* error = nil;
                    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:[lastMessage.messageText dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
                    if (json[@"message-action"]) {
                       
                        NSString* str = json[@"message-action"];
                        NSString* strMember = json[@"member-name"];
                        NSString* strActionBy = json[@"action-by"];
                        strActionBy = [strActionBy componentsSeparatedByString:@"@"][0].capitalizedString;
                        strMember = [strMember componentsSeparatedByString:@"@"][0].capitalizedString;
                        NSLog(@"%@", strActionBy);
                        NSLog(@"%@", strMember);
                        NSMutableString *mtblString = [NSMutableString stringWithString:@" "];
                        if ([str isEqualToString:@"admin"]) {
                            NSMutableString *mtblString1 = [NSMutableString stringWithString:strActionBy];
                            [mtblString appendString:mtblString1];
                            [mtblString appendString:@" gives admin membership to "];
                            [mtblString appendString:strMember];
                            [mtblString appendString:@" "];
                           // [strActionBy stringByAppendingString:@" made admin "];
                           // [strActionBy stringByAppendingString:strMember];
                            [self showStatusText:mtblString inboundDir:lastMessage.inbound fromUser:senderOfLastGroupMsg message:lastMessage];
                        } else if ([str isEqualToString:@"removed"]) {
                            NSMutableString *mtblString1 = [NSMutableString stringWithString:strActionBy];
                            [mtblString appendString:mtblString1];
                            [mtblString appendString:@" removed "];
                            [mtblString appendString:strMember];
                            [mtblString appendString:@" "];
                            
                          //  [strActionBy stringByAppendingString:@" removed "];
                          //  [strActionBy stringByAppendingString:strMember];
                            [self showStatusText:mtblString inboundDir:lastMessage.inbound fromUser:senderOfLastGroupMsg message:lastMessage];
                        } else if ([str isEqualToString:@"admin-removed"]) {
                            NSMutableString *mtblString1 = [NSMutableString stringWithString:strActionBy];
                            [mtblString appendString:mtblString1];
                            [mtblString appendString:@" revokes admin membership from "];
                            [mtblString appendString:strMember];
                            [mtblString appendString:@" "];
                            
                            //[strActionBy stringByAppendingString:@" removed admin "];
                           // [strActionBy stringByAppendingString:strMember];
                            
                            [self showStatusText:mtblString inboundDir:lastMessage.inbound fromUser:senderOfLastGroupMsg message:lastMessage];
                           
                        }
                        
                        
                    }
                }
            else if ([lastMessage.messageText containsString:kMessageTypeCreateGroup]) {
                NSString *Status = @"Created Group";
                [self showStatusText:Status inboundDir:lastMessage.inbound fromUser:senderOfLastGroupMsg message:lastMessage];
               
            } else if ([lastMessage.messageText containsString:kMessageTypeAddMember]) {
                NSString *Status = @"Added Member";
                [self showStatusText:Status inboundDir:lastMessage.inbound fromUser:senderOfLastGroupMsg message:lastMessage];
             //   reloadCell.reloadLabel.text = @"added";
            } else if ([lastMessage.messageText containsString:kMessageTypeChangedGroupSubjectName]) {
                NSString *Status = @"Changed Group Subject";
                [self showStatusText:Status inboundDir:lastMessage.inbound fromUser:senderOfLastGroupMsg message:lastMessage];
               // reloadCell.reloadLabel.text = @"changed group subject name";
            } else if ([lastMessage.messageText containsString:kMessageTypeChangedGroupInfo]) {
              NSString *Status = @"Changed Group Info";
                [self showStatusText:Status inboundDir:lastMessage.inbound fromUser:senderOfLastGroupMsg message:lastMessage];
            }else{
                [self showStatusText:lastMessage.messageText inboundDir:lastMessage.inbound fromUser:senderOfLastGroupMsg message:lastMessage];
            }
               
            }
        }
        if(lastMessage.timestamp)
        {
            self.time.text = [self formattedDateWithSource:lastMessage.timestamp];
            self.time.hidden = NO;
        }
        else
            self.time.hidden = YES;
    }
    else
    {
        [self showStatusText:nil inboundDir:lastMessage.inbound fromUser:nil message:lastMessage];
        DDLogWarn(@"Active chat but no messages found in history for %@.", contact.contactJid);
    }
}

-(void) showStatusText:(NSString *) text inboundDir:(BOOL) inboundDir fromUser:(NSString* _Nullable) fromUser message:(MLMessage* _Nullable) lastMessage
{
    NSString* statusMessage = @"";
    NSTextAttachment *clockattachment = [[NSTextAttachment alloc] init];
    if ([[HelperTools defaultsDB] boolForKey:@"darkModeEnable"]){
        clockattachment.image = [UIImage imageNamed:@"clock.png"];
    }else{
        clockattachment.image = [UIImage imageNamed:@"black_clock.png"];
    }
    
    NSAttributedString *clock_attachmentString = [NSAttributedString attributedStringWithAttachment:clockattachment];
     NSMutableAttributedString *clock= [[NSMutableAttributedString alloc] initWithString:@""];
     [clock appendAttributedString:clock_attachmentString];
    
    
    NSTextAttachment *tickattachment = [[NSTextAttachment alloc] init];
    if ([[HelperTools defaultsDB] boolForKey:@"darkModeEnable"]){
        tickattachment.image = [UIImage imageNamed:@"white_tick.png"];
    }else{
        tickattachment.image = [UIImage imageNamed:@"black_tick.png"];
    }
    
    NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:tickattachment];
     NSMutableAttributedString *tick= [[NSMutableAttributedString alloc] initWithString:@""];
     [tick appendAttributedString:attachmentString];
    
    //double_tick
    NSTextAttachment *double_tickattachment = [[NSTextAttachment alloc] init];
    if ([[HelperTools defaultsDB] boolForKey:@"darkModeEnable"]){
        double_tickattachment.image = [UIImage imageNamed:@"white_double.png"];
    }else{
        double_tickattachment.image = [UIImage imageNamed:@"black_double.png"];
    }
    
    NSAttributedString *double_tickattachmentString = [NSAttributedString attributedStringWithAttachment:double_tickattachment];
     NSMutableAttributedString *doubletick= [[NSMutableAttributedString alloc] initWithString:@""];
     [doubletick appendAttributedString:double_tickattachmentString];
    
    
    NSTextAttachment *green_tickattachment = [[NSTextAttachment alloc] init];
   
        green_tickattachment.image = [UIImage imageNamed:@"Green_tick.png"];
   
     
    NSAttributedString *Green_tickattachmentString = [NSAttributedString attributedStringWithAttachment:green_tickattachment];
     NSMutableAttributedString *greentick= [[NSMutableAttributedString alloc] initWithString:@""];
     [greentick appendAttributedString:Green_tickattachmentString];
    
    
    NSTextAttachment *errorattachment = [[NSTextAttachment alloc] init];
    errorattachment.image = [UIImage imageNamed:@"attention.png"];
    NSAttributedString *errorAttachmentString = [NSAttributedString attributedStringWithAttachment:errorattachment];
     NSMutableAttributedString *errorMark= [[NSMutableAttributedString alloc] initWithString:@""];
     [errorMark appendAttributedString:errorAttachmentString];
    
    if(inboundDir == NO)
        statusMessage = [NSString stringWithFormat:@"%@ ", NSLocalizedString(@"", @"")];
       
        
    else if(inboundDir == YES && fromUser != nil && fromUser.length > 0)
        statusMessage = [NSString stringWithFormat:@"%@: ", fromUser];

    // set range of "Me" prefix that should be gray
    NSRange meAttrRange = NSMakeRange(0, statusMessage.length);

    if(text != nil)
    {
        NSMutableAttributedString* attrStatusText;
        statusMessage = [statusMessage stringByAppendingString:text];
        // set attribute settings
//
        if(inboundDir == NO){
            if( ([lastMessage.errorType length] > 0 || [lastMessage.errorReason length] > 0) && !lastMessage.hasBeenReceived && lastMessage.hasBeenSent)
            {
                attrStatusText = errorMark;
                
            }else if(lastMessage.hasBeenDisplayed){
                attrStatusText = greentick;
                      
                  }
                  else if(lastMessage.hasBeenReceived){
                      attrStatusText = doubletick;
                  }
                  else if(lastMessage.hasBeenSent){
                      attrStatusText = tick;
                  }
                  else{
                      attrStatusText = clock;
                  }
            [attrStatusText appendAttributedString: [[NSAttributedString alloc] initWithString:statusMessage]];
        }else{
            attrStatusText = [[NSMutableAttributedString alloc] initWithString:statusMessage];
        }
        
        //[[NSMutableAttributedString alloc] initWithString:statusMessage];
        [attrStatusText addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:meAttrRange];

        if(![attrStatusText isEqualToAttributedString:self.statusText.originalAttributedText])
        {
            // only update UI if needed
            self.statusText.attributedText = attrStatusText;
            [self setStatusTextLayout:text];
        }
    }
    else
    {
        self.statusText.text = nil;
    }
}

-(void) showStatusTextItalic:(NSString *) text withItalicRange:(NSRange)italicRange
{
    UIFont* italicFont = [UIFont italicSystemFontOfSize:self.statusText.font.pointSize];
    NSMutableAttributedString* italicString = [[NSMutableAttributedString alloc] initWithString:text];
    [italicString addAttribute:NSFontAttributeName value:italicFont range:italicRange];

    if(![italicString isEqualToAttributedString:self.statusText.originalAttributedText])
    {
        self.statusText.attributedText = italicString;
        [self setStatusTextLayout:text];
    }
}

-(void) setStatusTextLayout:(NSString*) text
{
    if(text)
    {
        self.centeredDisplayName.hidden = YES;
        self.displayName.hidden = NO;
        self.statusText.hidden = NO;
    }
    else
    {
        self.centeredDisplayName.hidden = NO;
        self.displayName.hidden=YES;
        self.statusText.hidden=YES;
    }
}

-(void) showDisplayName:(NSString *) name
{
    if(![self.displayName.text isEqualToString:name])
    {
        self.centeredDisplayName.text = name;
        self.displayName.text = name;
    }
}

-(void) setCount:(long)count
{
    if(count > 0)
    {
        // show number of unread messages
        [self.badge setTitle:[NSString stringWithFormat:@"%ld", (long)count] forState:UIControlStateNormal];
        self.badge.hidden = NO;
    }
    else
    {
        // hide number of unread messages
        [self.badge setTitle:@"" forState:UIControlStateNormal];
        self.badge.hidden = YES;
    }
}

-(void) setPinned:(BOOL) pinned
{
    self.isPinned = pinned;

    if(pinned) {
        self.backgroundColor = [UIColor colorNamed:@"activeChatsPinnedColor"];
    } else {
        self.backgroundColor = nil;
    }
}

#pragma mark - date
-(NSString*) formattedDateWithSource:(NSDate*) sourceDate
{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    if([[NSCalendar currentCalendar] isDateInToday:sourceDate])
    {
        //today just show time
        [dateFormatter setDateStyle:NSDateFormatterNoStyle];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    }
    else
    {
        // note: if it isnt the same day we want to show the full day
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        //no more need for seconds
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    }
    NSString* dateString = [dateFormatter stringFromDate:sourceDate];
    return dateString ? dateString : @"";
}

@end
