//
//  MLLinkCell.h
//  Monal
//
//  Created by Anurodh Pokharel on 10/29/18.
//  Copyright © 2018 Monal.im. All rights reserved.
//

#import "MLBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLLinkCell : MLBaseCell
@property (nonatomic, strong) IBOutlet UILabel* messageTitle;
@property (nonatomic, strong) IBOutlet UIImageView* previewImage;
@property (nonatomic, strong) NSURL* imageUrl;

@property (strong, nonatomic) IBOutlet UIView *viewOfStarMessage;
@property (strong, nonatomic) IBOutlet UILabel *lblMessageSenderName;
@property (strong, nonatomic) IBOutlet UILabel *lblTimestamp;
@property (strong, nonatomic) IBOutlet UILabel *lblBaundry;


-(void) loadImageWithCompletion:(void (^)(void))completion;

-(void) openlink: (id) sender;

@end

NS_ASSUME_NONNULL_END
