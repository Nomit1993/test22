//
//  buddylist.h
//  SworIM
//
//  Created by Anurodh Pokharel on 11/21/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataLayer.h"
@import SAMKeychain;
#import "MLXMPPManager.h"
#import "TOCropViewController.h"

@interface XMPPEdit: UITableViewController <UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIDocumentPickerDelegate, TOCropViewControllerDelegate> {
	IBOutlet UILabel *JIDLabel;
}

@property (nonatomic, strong) DataLayer *db;
@property (nonatomic, strong ) 	NSArray *sectionArray;

@property (nonatomic, assign) BOOL editMode;
@property (nonatomic, strong) NSString* accountno;
// Used for QR-Code scanning
@property (nonatomic, strong) NSString* jid;
@property (nonatomic, strong) NSString* password;

@property (nonatomic, strong) NSIndexPath* originIndex;
@property (nonatomic, strong) NSString* accountType;

-(IBAction) save:(id) sender;


@end


