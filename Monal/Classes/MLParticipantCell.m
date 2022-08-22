//
//  MLParticipantCell.m
//  Monal
//
//  Created by mohanchandaluri on 16/12/21.
//  Copyright © 2021 Monal.im. All rights reserved.
//

#import "MLParticipantCell.h"
#import "MLContact.h"
#import "MLXMPPManager.h"
#import "MLImageManager.h"
#import "DataLayer.h"
#import "xmpp.h"
#import "MLInitialAvatar.h"

@interface MLParticipantCell()

@end
@implementation MLParticipantCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

-(void) initCell:(MLContact*) contact{
   self.backgroundColor = [UIColor clearColor];
    NSArray* accountList = [[DataLayer sharedInstance] accountList];
    NSString *myjid = [NSString stringWithFormat:@"%@@%@",[[accountList objectAtIndex:0] objectForKey:@"username"],[[accountList objectAtIndex:0] objectForKey:@"domain"]];
    if ([myjid isEqualToString:contact.contactJid]){
        NSString *nickname = [NSString stringWithFormat:@"%@ - (YOU)",contact.contactDisplayName];
        [self showDisplayName:nickname];
        
    }else{
        [self showDisplayName:contact.contactDisplayName];
    }
   
    if(@available(iOS 13.0, *))
    {
        if(contact.isGroup)
        {
            if([@"channel" isEqualToString:contact.mucType])
                self.userIcon.image = [MLImageManager circularImage:[UIImage imageNamed:@"noicon_channel"]];
            else
                self.userIcon.image = [MLImageManager circularImage:[UIImage imageNamed:@"noicon_muc"]];
        }
        else
            [[MLImageManager sharedInstance] getIconForContact:contact.contactJid andAccount:contact.accountId withCompletion:^(UIImage *image) {
                if (!image){
                    MLInitialAvatar *avatar = [[MLInitialAvatar alloc] initWithRect:self.userIcon.bounds fullName:contact.contactDisplayName];
                    self.userIcon.image = [MLImageManager circularImage:avatar.imageRepresentation];
                    NSData *avatarData = UIImagePNGRepresentation(avatar.imageRepresentation);
                    [[MLImageManager sharedInstance] setIconForContact:contact.contactJid andAccount:contact.accountId WithData:avatarData];
                }else{
                    self.userIcon.image = image;
                }
                
            }];
    }
    else
        [[MLImageManager sharedInstance] getIconForContact:contact.contactJid andAccount:contact.accountId withCompletion:^(UIImage *image) {
            self.userIcon.image = image;
        }];
}

-(void) showDisplayName:(NSString *) name
{

    
    if(![self.displayName.text isEqualToString:name])
    {
        self.displayName.text = name;
    }
    self.userStatus.text = self.Status;
    self.participantType.text = self.affilliation;
}


@end
