//
//  MLSearchContactViewController.h
//  jrtplib-static
//
//  Created by mohanchandaluri on 29/03/22.
//  Copyright © 2022 Monal.im. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MLConstants.h"
#import "MLContact.h"
NS_ASSUME_NONNULL_BEGIN

@interface MLSearchContactViewController : UIViewController <UISearchResultsUpdating, UISearchControllerDelegate,UITableViewDelegate, UITableViewDataSource >
@property (nonatomic, strong) UISearchController* searchController;
@property (weak, nonatomic) IBOutlet UITableView *searchTableView;
@property (nonatomic, strong) contactCompletion selectContact;
@property (nonatomic, strong) NSMutableArray<MLContact*>* contacts;
@end

NS_ASSUME_NONNULL_END
