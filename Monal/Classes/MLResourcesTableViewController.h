//
//  MLResourcesTableViewController.h
//  Monal
//
//  Created by Anurodh Pokharel on 12/30/18.
//  Copyright © 2018 Monal.im. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MLContact.h"
#import "MLConstants.h"
#import "ContactsViewController.h"
@class MLECDHKeyExchange;
NS_ASSUME_NONNULL_BEGIN

@interface MLResourcesTableViewController : UITableViewController<contactsViewDelegate>
@property (nonatomic, strong) MLContact *contact;
@property (nonatomic, strong) contactCompletion selectContact; 
@end

NS_ASSUME_NONNULL_END
