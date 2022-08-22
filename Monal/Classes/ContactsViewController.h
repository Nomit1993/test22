//
//  ContactsViewController.h
//  Monal
//
//  Created by Anurodh Pokharel on 6/14/13.
//
//

#import <UIKit/UIKit.h>
#import "MLConstants.h"
#import "MLImageManager.h"
#import "MLContact.h"
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>
@protocol contactsViewDelegate;
@interface ContactsViewController : UIViewController  <UISearchResultsUpdating, UISearchControllerDelegate
,DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *contactsTable;
@property (strong, nonatomic) IBOutlet UIButton *btnAddUser;
@property (nonatomic, weak) id<contactsViewDelegate> delegate;
@property (nonatomic, strong) NSString* groupName;
@property (nonatomic, strong) contactCompletion selectContact;
@property (nonatomic,strong) contactTabCompletion selectTabContact;
@property (nonatomic, assign) BOOL forwardMessage;
@property (nonatomic, assign) BOOL isGroupChat;
@property (nonatomic, assign) BOOL addparticipants;
@property (nonatomic, strong) NSString* groupJid;
@property (nonatomic ,strong) MLMessage *message;
@property (nonatomic, strong) xmpp* xmppAccount;
@property (nonatomic, strong) NSString* jid;
-(IBAction) close:(id) sender;
- (IBAction)btnActnAddUser:(id)sender;
- (IBAction)segmentAction:(id)sender;
-(void) SessionKeyGenerate:(NSString *)groupJid;
@end


@protocol contactsViewDelegate <NSObject>

- (void)didFinishInviteUsers:(NSMutableArray< MLContact* >*)inviteUser GroupJid:(NSString *)jid GroupName:(NSString *)name;

@end
