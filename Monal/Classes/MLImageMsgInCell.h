//
//  MLImageMsgInCell.h
//  Monal
//
//  Created by mohanchandaluri on 29/04/22.
//  Copyright © 2022 Monal.im. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MLBaseCell.h"


@interface MLImageMsgCell : MLBaseCell

@property (weak, nonatomic) IBOutlet UILabel *Name;

@property (weak, nonatomic) IBOutlet UILabel *messageCaption;
@property (nonatomic, strong) MLMessage* message;
@property (weak, nonatomic) IBOutlet UIImageView *MessageBubble;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImage;
-(UIImage*) getDisplayedImage;
-(void) loadMessagePreviewWithCompletion:(void (^)(void))completion ;
@end


