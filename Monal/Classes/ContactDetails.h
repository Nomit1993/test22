//
//  chat.h
//  SworIM
//
//  Created by Anurodh Pokharel on 1/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataLayer.h"
#import "IDMPhotoBrowser.h"
#import "TOCropViewController.h"
typedef void (^controllerCompletion)(void);

@interface ContactDetails : UITableViewController <UITextFieldDelegate, IDMPhotoBrowserDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIDocumentPickerDelegate, TOCropViewControllerDelegate>

@property (nonatomic, strong) MLContact *contact;
@property (nonatomic, strong) controllerCompletion completion;

-(IBAction) callContact:(id)sender;
-(IBAction) muteContact:(id)sender;
-(IBAction) toggleEncryption:(id)sender;


@end
