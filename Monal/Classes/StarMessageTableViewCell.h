//
//  StarMessageTableViewCell.h
//  Monal
//
//  Created by Nandini Barve on 13/01/22.
//  Copyright © 2022 Monal.im. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface StarMessageTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIView *viewOfStarMessage;
@property (strong, nonatomic) IBOutlet UILabel *lblMessageSenderName;
@property (strong, nonatomic) IBOutlet UILabel *lblTimestamp;
@property (strong, nonatomic) IBOutlet UILabel *lblMessage;
@property (strong, nonatomic) IBOutlet UILabel *lblBaundry;
@end

NS_ASSUME_NONNULL_END
