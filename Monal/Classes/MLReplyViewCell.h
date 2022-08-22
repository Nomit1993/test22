//
//  MLReplyViewCell.h
//  Monal
//
//  Created by mohanchandaluri on 02/12/21.
//  Copyright © 2021 Monal.im. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MLBaseCell.h"


@interface MLReplyViewCell : MLBaseCell
@property (weak, nonatomic) IBOutlet UIButton *RetryButton;
@property (weak, nonatomic) IBOutlet UIView *ReplyView;
@property (weak, nonatomic) IBOutlet UIImageView *ReplyMediaView;
@property (weak, nonatomic) IBOutlet UIView *ReplySidebar;
@property (weak, nonatomic) IBOutlet UILabel *ReplyUserStatus;
@property (weak, nonatomic) IBOutlet UIImageView *MessageBubble;
@property (weak, nonatomic) IBOutlet UILabel *MessageText;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthConstant;

@property (weak, nonatomic) IBOutlet UILabel *ReplyMessagetext;
@property (nonatomic, strong) MLMessage* message;
@property (nonatomic, strong) NSString *Jid;
@property (nonatomic, strong) MLContact* previewContact;
@property (nonatomic, strong) NSMutableArray<MLMessage*>* searchMessageList;
-(void) loadMessagePreviewWithCompletion:(void (^)(void))completion;
@end


