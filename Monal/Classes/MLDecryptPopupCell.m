//
//  MLDecryptPopupCell.m
//  Monal
//
//  Created by mohanchandaluri on 07/05/22.
//  Copyright © 2022 Monal.im. All rights reserved.
//

#import "MLDecryptPopupCell.h"
#import "UIColor+Theme.h"
#import "MLImageManager.h"
#import "MLConstants.h"
#import "DataLayer.h"
#import "HelperTools.h"
#import "MLFiletransfer.h"
@implementation MLDecryptPopupCell

//- (void)awakeFromNib {
//    [super awakeFromNib];
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
       self.MessageBubble.image= [[MLImageManager sharedInstance] outboundImage];
    }
    else
    {
        self.MessageBubble.image=[[MLImageManager sharedInstance] inboundImage];
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
