//
//  ActiveChatsViewController.h
//  Monal
//
//  Created by Anurodh Pokharel on 6/14/13.
//
//

#import <UIKit/UIKit.h>
#import "MLContact.h"
#import "MLConstants.h"
#import <Monal-Swift.h>
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>
#import <LocalAuthentication/LocalAuthentication.h>
#import "ContactsViewController.h"
@interface ActiveChatsViewController : UITableViewController  <DZNEmptyDataSetSource, DZNEmptyDataSetDelegate,UISearchResultsUpdating, UISearchControllerDelegate,contactsViewDelegate>

@property (nonatomic, strong) UITableView* chatListTable;
@property (nonatomic, weak) IBOutlet UIBarButtonItem* settingsButton;
@property (nonatomic, weak) IBOutlet UIBarButtonItem* composeButton;
@property (nonatomic, strong) contactCompletion completion;
@property (strong, nonatomic) IBOutlet UIView *viewOfTouchId;
@property (strong, nonatomic) IBOutlet UILabel *lblVaniLocked;
@property (strong, nonatomic) IBOutlet UIButton *btnTouchId;

- (IBAction)btnActnTouchId:(id)sender;

-(void) presentChatWithContact:(MLContact*) contact;
-(void) refreshDisplay;
 
-(void) showContacts;
-(void) deleteConversation;
-(void) showSettings;
-(void) showDetails;

@end
