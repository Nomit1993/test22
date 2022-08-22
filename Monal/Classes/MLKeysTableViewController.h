//
//  MLKeysTableViewController.h
//  Monal
//
//  Created by Anurodh Pokharel on 12/30/18.
//  Copyright © 2018 Monal.im. All rights reserved.
//
#import "xmpp.h"
#import "MLContact.h"
#import <Monal-Swift.h>

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MLKeysTableViewController : UITableViewController<MLLQRCodeScannerContactDeleagte>
@property (nonatomic, assign) BOOL ownKeys;
@property (nonatomic, strong) MLContact *contact;

@end

NS_ASSUME_NONNULL_END
