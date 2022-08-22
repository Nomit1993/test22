//
//  MLChatCell.h
//  Monal
//
//  Created by Anurodh Pokharel on 8/20/13.
//
//

#import <UIKit/UIKit.h>
#import "MLBaseCell.h"

@interface MLChatCell : MLBaseCell

@property (weak, nonatomic) IBOutlet UITextView *previewText;
@property (strong, nonatomic) IBOutlet UIView *viewOfStarMessage;
@property (strong, nonatomic) IBOutlet UILabel *lblMessageSenderName;
@property (strong, nonatomic) IBOutlet UILabel *lblTimestamp;
@property (strong, nonatomic) IBOutlet UILabel *lblBaundry;

-(void) openlink: (id) sender;

@end
