//
//  MLBaseCell.h
//  Monal
//
//  Created by Anurodh Pokharel on 12/24/17.
//  Copyright © 2017 Monal.im. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MLConstants.h"
#import "MLMessage.h"

#define kDefaultTextHeight 20
#define kDefaultTextOffset 5

#define kSending NSLocalizedString(@"Sending...", @"")
#define kSent LocalizationNotNeeded(@"✓")
#define kReceived LocalizationNotNeeded(@"✓✓")
#define kDisplayed LocalizationNotNeeded(@"✓✓")


@interface MLBaseCell : UITableViewCell

-(id) init;

@property (nonatomic, assign) BOOL outBound;
@property (nonatomic, assign) BOOL MUC;

@property (nonatomic, strong) IBOutlet UILabel* name;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *nameHeight;

@property (nonatomic, strong) IBOutlet UILabel* date;
@property (nonatomic, strong) IBOutlet UILabel* messageBody;
@property (nonatomic, strong) IBOutlet UILabel* messageStatus;
@property (nonatomic, strong) IBOutlet UILabel* dividerDate;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *dividerHeight;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *bubbleTop;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *dayTop;

@property (nonatomic, strong) NSString* link;
@property (nonatomic, strong) IBOutlet UIView* bubbleView;

@property (nonatomic, weak) IBOutlet UIImageView *bubbleImage;
@property (nonatomic, weak) IBOutlet UIImageView *lockImage;

@property (nonatomic, assign) BOOL deliveryFailed;
@property (nonatomic, strong) IBOutlet UIButton* retry;
@property (nonatomic, strong) NSNumber* messageHistoryId;
@property (nonatomic, weak) UIViewController *parent;

@property (strong, nonatomic) IBOutlet UIView *viewOfStarMessage1;
@property (strong, nonatomic) IBOutlet UILabel *lblMessageSenderName1;
@property (strong, nonatomic) IBOutlet UILabel *lblTimestamp1;
@property (strong, nonatomic) IBOutlet UILabel *lblBaundry1;

@property (strong, nonatomic) IBOutlet UIImageView *imageOfMessageSendeer;
@property (nonatomic, assign) MLMessage* msg;

/**
 Updates ths cells spacing and display
 @param newSender determines if the sender of this cell
 is the same as the prior cell's sender
 **/
-(void) updateCellWithNewSender:(BOOL) newSender;
-(void) setGroupMessageImage:(MLContact*)contact;
-(void) initCell:(MLMessage*) message;

@end
