//
//  StarMessageTableViewController.h
//  Monal
//
//  Created by Nandini Barve on 13/01/22.
//  Copyright © 2022 Monal.im. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface StarMessageTableViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UITableView *tblViewStarMessage;
- (IBAction)btnCloseBarButtonAction:(id)sender;

@end

NS_ASSUME_NONNULL_END
