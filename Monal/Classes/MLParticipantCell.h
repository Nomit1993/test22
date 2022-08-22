//
//  MLParticipantCell.h
//  Monal
//
//  Created by mohanchandaluri on 16/12/21.
//  Copyright © 2021 Monal.im. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MLContact.h"
NS_ASSUME_NONNULL_BEGIN

@interface MLParticipantCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *statusOrb;
@property (weak, nonatomic) IBOutlet UIImageView *userIcon;
@property (weak, nonatomic) IBOutlet UILabel *displayName;
@property (weak, nonatomic) IBOutlet UILabel *participantType;
@property (weak, nonatomic) IBOutlet UILabel *userStatus;
@property (nonatomic, strong) NSString* _Nullable Status;
@property (nonatomic, strong) NSString* _Nullable affilliation;
-(void) initCell:(MLContact*) contact;
@end

NS_ASSUME_NONNULL_END
