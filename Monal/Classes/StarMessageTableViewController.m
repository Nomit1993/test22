//
//  StarMessageTableViewController.m
//  Monal
//
//  Created by Nandini Barve on 13/01/22.
//  Copyright © 2022 Monal.im. All rights reserved.
//

#import "StarMessageTableViewController.h"
#import "MLMessage.h"
#import "DataLayer.h"
#import "StarMessageTableViewCell.h"
#import "MLChatCell.h"
#import "MLLinkCell.h"
#import "MLChatImageCell.h"
#import "MLChatMapsCell.h"
#import "MLReloadCell.h"
#import "MLReplyViewCell.h"
#import "MLFiletransfer.h"
#import "MLFileTransferDataCell.h"
#import "MLFileTransferVideoCell.h"
#import "MLFileTransferTextCell.h"
#import "MLFileTransferFileViewController.h"
#import "HelperTools.h"
#import "MLMetaInfo.h"

@interface StarMessageTableViewController () <OpenFileDelegate>

@property (nonatomic, strong) NSMutableSet* previewedIds;
@property (nonatomic, assign) BOOL showGeoLocationsInline;

@end

@implementation StarMessageTableViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    NSMutableArray *starMessageArray1 = [[[NSUserDefaults standardUserDefaults] arrayForKey:@"starMessageArray"] mutableCopy];
    [self.tblViewStarMessage setDelegate:self];
    [self.tblViewStarMessage setDataSource:self];
    self.previewedIds = [[NSMutableSet alloc] init];
    self.showGeoLocationsInline = [[HelperTools defaultsDB] boolForKey: @"ShowGeoLocation"];
    
    if([starMessageArray1 count] > 0) {
        [self.tblViewStarMessage reloadData];
    } else {
        [self.tblViewStarMessage reloadData];
        UILabel *noDataLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tblViewStarMessage.bounds.size.width, self.tblViewStarMessage.bounds.size.height)];
                noDataLabel.text             = @"No star message is available.";
                noDataLabel.textColor        = [UIColor blackColor];
                noDataLabel.textAlignment    = NSTextAlignmentCenter;
                self.tblViewStarMessage.backgroundView = noDataLabel;
                self.tblViewStarMessage.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    /*
     
     for (int i = 0; i < starMessageArray1.count; i++) {
         NSNumber* indexMessage = [starMessageArray1 objectAtIndex:i];
         if ([indexMessage isEqualToNumber:message.messageDBId]) {
             [starMessageArray1 removeObjectAtIndex:i];
             break;
         }
     }
     */
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSMutableArray *starMessageArray1 = [[[NSUserDefaults standardUserDefaults] arrayForKey:@"starMessageArray"] mutableCopy];
    if([starMessageArray1 count] > 0) {
        return 1;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSMutableArray *starMessageArray1 = [[[NSUserDefaults standardUserDefaults] arrayForKey:@"starMessageArray"] mutableCopy];
    return [starMessageArray1 count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if([self messageFromMessageId:indexPath.row] == NULL) {
        StarMessageTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"StarMessageTableViewCell" forIndexPath:indexPath];
        [cell.textLabel setText:@"No Data"];
        return cell;
    } else {
        MLMessage* msg = [self messageFromMessageId:indexPath.row];
        MLMessage* row = msg;

        //cut text after kMonalChatMaxAllowedTextLen chars to make the message cell work properly (too big texts don't render the text in the cell at all)
        NSString* messageText = row.messageText;
        if([messageText length] > kMonalChatMaxAllowedTextLen)
            messageText = [NSString stringWithFormat:@"%@\n[...]", [messageText substringToIndex:kMonalChatMaxAllowedTextLen]];
        BOOL inboundDir = row.inbound;
        if([row.messageType isEqualToString:kMessageTypeStatus])
        {
            MLBaseCell* cell;
            cell = [tableView dequeueReusableCellWithIdentifier:@"StatusCell"];
            cell.messageBody.text = messageText;
            cell.link = nil;
            cell.parent = self;
            //NSMutableAttributedString *fullString;
            CGSize size = CGSizeMake(20, 20);
            NSTextAttachment *icon = [[NSTextAttachment alloc] init];
            UIImage *iconImage;
            if (msg.inbound == false) {
                iconImage = [UIImage imageNamed:@"IDMPhotoBrowser_arrowLeft"];
            } else {
                iconImage = [UIImage imageNamed:@"IDMPhotoBrowser_arrowRight"];
            }
            UIGraphicsBeginImageContext(size);
            [iconImage drawInRect:CGRectMake(0, 2, size.width, size.height)];
            UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            //
            icon.image = destImage;
            NSAttributedString *Green_tickattachmentString = [NSAttributedString attributedStringWithAttachment:icon];
            NSMutableAttributedString *greentick= [[NSMutableAttributedString alloc] initWithString:@"You "];
            [greentick appendAttributedString:Green_tickattachmentString];
            NSArray *UserComponents = [msg.buddyName componentsSeparatedByString:@"@"];
            [greentick appendAttributedString:[[NSAttributedString alloc] initWithString:[UserComponents[0] capitalizedString]]];
            cell.lblMessageSenderName1.text = greentick.string;
            cell.lblTimestamp1.text = [self dateFromTimeStamp:msg.timestamp];
            return cell;
        } else if([row.messageType isEqualToString:kMessageTypeFiletransfer])
        {
            MLBaseCell* cell;
            DDLogVerbose(@"got filetransfer chat cell: %@ (%@)", row.filetransferMimeType, row.filetransferSize);
            NSDictionary* info = [MLFiletransfer getFileInfoForMessage:row];
            
            //TODO JIM: here we need the download and check-file buttons
            
            if(info && ![info[@"needsDownloading"] boolValue])
            {
                cell = [self fileTransferCellCheckerWithInfo:info direction:inboundDir tableView:tableView andMsg:row];
            }
            else if (info && [info[@"needsDownloading"] boolValue])
            {
                //TODO JIM: explanation: this was already checked (mime ype and size are known) but not yet downloaded --> download it
                //TODO JIM: explanation: this should not be automatically but only triggered by a button press
                //TODO JIM: explanation: I'm doing this automatically here because we still lack those buttons
                //TODO JIM: explanation: this only handles images, because we don't want to autodownload everything
                MLFileTransferDataCell* fileTransferCell = (MLFileTransferDataCell *) [self messageTableCellWithIdentifier:@"fileTransferCheckingData" andInbound:inboundDir fromTable:tableView];
                NSString* fileSize = info[@"size"] ? info[@"size"] : @"0";
                [fileTransferCell initCellForMessageId:row.messageDBId andFilename:info[@"filename"] andMimeType:info[@"mimeType"] andFileSize:fileSize.longLongValue];
                //NSMutableAttributedString *fullString;
                CGSize size = CGSizeMake(20, 20);
                NSTextAttachment *icon = [[NSTextAttachment alloc] init];
                UIImage *iconImage;
                if (msg.inbound == false) {
                    iconImage = [UIImage imageNamed:@"IDMPhotoBrowser_arrowLeft"];
                } else {
                    iconImage = [UIImage imageNamed:@"IDMPhotoBrowser_arrowRight"];
                }
                UIGraphicsBeginImageContext(size);
                [iconImage drawInRect:CGRectMake(0, 2, size.width, size.height)];
                UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                //
                icon.image = destImage;
                NSAttributedString *Green_tickattachmentString = [NSAttributedString attributedStringWithAttachment:icon];
                NSMutableAttributedString *greentick= [[NSMutableAttributedString alloc] initWithString:@"You "];
                [greentick appendAttributedString:Green_tickattachmentString];
                NSArray *UserComponents = [msg.buddyName componentsSeparatedByString:@"@"];
                [greentick appendAttributedString:[[NSAttributedString alloc] initWithString:[UserComponents[0] capitalizedString]]];
                fileTransferCell.lblMessageSenderName.text = greentick.string;
                fileTransferCell.lblTimestamp.text = [self dateFromTimeStamp:msg.timestamp];
                cell = fileTransferCell;
            }
            
            
            
            return cell;
        }  else if([row.messageType isEqualToString:kMessageTypeUrl] && [[HelperTools defaultsDB] boolForKey:@"ShowURLPreview"])
        {
            MLBaseCell* cell;
            MLLinkCell* toreturn = (MLLinkCell *)[self messageTableCellWithIdentifier:@"link" andInbound:inboundDir fromTable: tableView];
            
            NSString* cleanLink = [messageText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSArray* parts = [cleanLink componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            toreturn.link = parts[0];
            row.url= [NSURL URLWithString:toreturn.link];
            toreturn.messageBody.text = toreturn.link;
            toreturn.messageHistoryId = row.messageDBId;
            
            if(row.previewText || row.previewImage)
            {
                toreturn.imageUrl = row.previewImage;
                toreturn.messageTitle.text = row.previewText;
                [toreturn loadImageWithCompletion:^{}];
            }
            else
            {
                [self loadPreviewWithUrlForRow:indexPath withCompletion:^{
                    
                }];
            }
            //NSMutableAttributedString *fullString;
            CGSize size = CGSizeMake(20, 20);
            NSTextAttachment *icon = [[NSTextAttachment alloc] init];
            UIImage *iconImage;
            if (msg.inbound == false) {
                iconImage = [UIImage imageNamed:@"IDMPhotoBrowser_arrowLeft"];
            } else {
                iconImage = [UIImage imageNamed:@"IDMPhotoBrowser_arrowRight"];
            }
            UIGraphicsBeginImageContext(size);
            [iconImage drawInRect:CGRectMake(0, 2, size.width, size.height)];
            UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            //
            icon.image = destImage;
            NSAttributedString *Green_tickattachmentString = [NSAttributedString attributedStringWithAttachment:icon];
            NSMutableAttributedString *greentick= [[NSMutableAttributedString alloc] initWithString:@"You "];
            [greentick appendAttributedString:Green_tickattachmentString];
            NSArray *UserComponents = [msg.buddyName componentsSeparatedByString:@"@"];
            [greentick appendAttributedString:[[NSAttributedString alloc] initWithString:[UserComponents[0] capitalizedString]]];
            toreturn.lblMessageSenderName1.text = greentick.string;
            toreturn.lblTimestamp1.text = [self dateFromTimeStamp:msg.timestamp];
            
            cell = toreturn;
            return  cell;
        }
//        } else if([row.messageType isEqualToString:KMessageTypeReply]){
//            MLReplyViewCell *toreturn = (MLReplyViewCell *)[self messageTableCellWithIdentifier:@"Reply" andInbound:inboundDir fromTable: tableView];
//            toreturn.message = row;
//            
//            
//            NSDictionary* accountDict = [[DataLayer sharedInstance] detailsForAccount:self.contact.accountId];
//            if(accountDict)
//                self.jid = [NSString stringWithFormat:@"%@@%@",[accountDict objectForKey:@"username"], [accountDict objectForKey:@"domain"]];
//            
//            
//            toreturn.Jid = self.jid;
//            toreturn.searchMessageList = [self.messageList copy];
//            toreturn.previewContact = self.contact;
//            [toreturn loadMessagePreviewWithCompletion:^{
//            }];
//            cell = toreturn;
     //   }
        else if ([row.messageType isEqualToString:kMessageTypeGeo]) {
        //     Parse latitude and longitude
            MLBaseCell* cell;
            NSError* error = NULL;
            NSRegularExpression* geoRegex = [NSRegularExpression regularExpressionWithPattern:geoPattern
            options:NSRegularExpressionCaseInsensitive
              error:&error];

            if(error != NULL) {
                DDLogError(@"Error while loading geoPattern");
            }

            NSTextCheckingResult* geoMatch = [geoRegex firstMatchInString:messageText options:0 range:NSMakeRange(0, [messageText length])];
            
            if(geoMatch.numberOfRanges > 0) {
                NSRange latitudeRange = [geoMatch rangeAtIndex:1];
                NSRange longitudeRange = [geoMatch rangeAtIndex:2];
                NSString* latitude = [messageText substringWithRange:latitudeRange];
                NSString* longitude = [messageText substringWithRange:longitudeRange];

                // Display inline map
                if(self.showGeoLocationsInline) {
                    MLChatMapsCell* mapsCell = (MLChatMapsCell *)[self messageTableCellWithIdentifier:@"maps" andInbound:inboundDir fromTable: tableView];

                    // Set lat / long used for map view and pin
                    mapsCell.latitude = [latitude doubleValue];
                    mapsCell.longitude = [longitude doubleValue];

                    [mapsCell loadCoordinatesWithCompletion:^{}];
                    //NSMutableAttributedString *fullString;
                    CGSize size = CGSizeMake(20, 20);
                    NSTextAttachment *icon = [[NSTextAttachment alloc] init];
                    UIImage *iconImage;
                    if (msg.inbound == false) {
                        iconImage = [UIImage imageNamed:@"IDMPhotoBrowser_arrowLeft"];
                    } else {
                        iconImage = [UIImage imageNamed:@"IDMPhotoBrowser_arrowRight"];
                    }
                    UIGraphicsBeginImageContext(size);
                    [iconImage drawInRect:CGRectMake(0, 2, size.width, size.height)];
                    UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                    //
                    icon.image = destImage;
                    NSAttributedString *Green_tickattachmentString = [NSAttributedString attributedStringWithAttachment:icon];
                    NSMutableAttributedString *greentick= [[NSMutableAttributedString alloc] initWithString:@"You "];
                    [greentick appendAttributedString:Green_tickattachmentString];
                    NSArray *UserComponents = [msg.buddyName componentsSeparatedByString:@"@"];
                    [greentick appendAttributedString:[[NSAttributedString alloc] initWithString:[UserComponents[0] capitalizedString]]];
                    mapsCell.lblMessageSenderName.text = greentick.string;
                    mapsCell.lblTimestamp.text = [self dateFromTimeStamp:msg.timestamp];
                    cell = mapsCell;
                } else {
                    // Default to text cell
                    cell = [self messageTableCellWithIdentifier:@"text" andInbound:inboundDir fromTable: tableView];
                    NSMutableAttributedString* geoString = [[NSMutableAttributedString alloc] initWithString:messageText];
                    [geoString addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:[geoMatch rangeAtIndex:0]];

                    cell.messageBody.attributedText = geoString;
                    NSInteger zoomLayer = 15;
                    cell.link = [NSString stringWithFormat:@"https://www.openstreetmap.org/?mlat=%@&mlon=%@&zoom=%ldd", latitude, longitude, zoomLayer];
                    //NSMutableAttributedString *fullString;
                    CGSize size = CGSizeMake(20, 20);
                    NSTextAttachment *icon = [[NSTextAttachment alloc] init];
                    UIImage *iconImage;
                    if (msg.inbound == false) {
                        iconImage = [UIImage imageNamed:@"IDMPhotoBrowser_arrowLeft"];
                    } else {
                        iconImage = [UIImage imageNamed:@"IDMPhotoBrowser_arrowRight"];
                    }
                    UIGraphicsBeginImageContext(size);
                    [iconImage drawInRect:CGRectMake(0, 2, size.width, size.height)];
                    UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                    //
                    icon.image = destImage;
                    NSAttributedString *Green_tickattachmentString = [NSAttributedString attributedStringWithAttachment:icon];
                    NSMutableAttributedString *greentick= [[NSMutableAttributedString alloc] initWithString:@"You "];
                    [greentick appendAttributedString:Green_tickattachmentString];
                    NSArray *UserComponents = [msg.buddyName componentsSeparatedByString:@"@"];
                    [greentick appendAttributedString:[[NSAttributedString alloc] initWithString:[UserComponents[0] capitalizedString]]];
                    cell.lblMessageSenderName1.text = greentick.string;
                    cell.lblTimestamp1.text = [self dateFromTimeStamp:msg.timestamp];
                }
            } else {
                DDLogWarn(@"msgs of type kMessageTypeGeo should contain a geo location");
            }
            
            return cell;
        } else {
            StarMessageTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"StarMessageTableViewCell" forIndexPath:indexPath];
            MLMessage* msg = [self messageFromMessageId:indexPath.row];
             
             //NSMutableAttributedString *fullString;
             CGSize size = CGSizeMake(20, 20);
             NSTextAttachment *icon = [[NSTextAttachment alloc] init];
             UIImage *iconImage;
             if (msg.inbound == false) {
                 iconImage = [UIImage imageNamed:@"IDMPhotoBrowser_arrowLeft"];
             } else {
                 iconImage = [UIImage imageNamed:@"IDMPhotoBrowser_arrowRight"];
             }
             UIGraphicsBeginImageContext(size);
             [iconImage drawInRect:CGRectMake(0, 2, size.width, size.height)];
             UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();
             UIGraphicsEndImageContext();
             //
             icon.image = destImage;
             NSAttributedString *Green_tickattachmentString = [NSAttributedString attributedStringWithAttachment:icon];
             NSMutableAttributedString *greentick= [[NSMutableAttributedString alloc] initWithString:@"You "];
             [greentick appendAttributedString:Green_tickattachmentString];
             NSArray *UserComponents = [msg.buddyName componentsSeparatedByString:@"@"];
             [greentick appendAttributedString:[[NSAttributedString alloc] initWithString:[UserComponents[0] capitalizedString]]];
             cell.lblMessageSenderName.text = greentick.string;
             cell.lblTimestamp.text = [self dateFromTimeStamp:msg.timestamp];
             cell.lblMessage.text = msg.messageText;
            return cell;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    MLMessage* msg = [self messageFromMessageId:indexPath.row];
    if([msg.messageType isEqualToString:kMessageTypeStatus])
    {
        MLBaseCell* cell;
        cell = [tableView dequeueReusableCellWithIdentifier:@"StatusCell"];
        [cell layoutIfNeeded];
        return  cell.lblBaundry1.frame.origin.y + cell.lblBaundry1.frame.size.height;
    } else if([msg.messageType isEqualToString:kMessageTypeFiletransfer]) {
        NSDictionary* info = [MLFiletransfer getFileInfoForMessage:msg];
        if(info && ![info[@"needsDownloading"] boolValue])
        {
            if([info[@"mimeType"] hasPrefix:@"image/"])
            {
                MLChatImageCell* imageCell = (MLChatImageCell *)[self messageTableCellWithIdentifier:@"image" andInbound:msg.inbound fromTable:tableView];
                [imageCell layoutIfNeeded];
                return  imageCell.lblbaundry.frame.origin.y + imageCell.lblbaundry.frame.size.height;
                //return 270;
            }
            else if([info[@"mimeType"] hasPrefix:@"video/"])
            {
                MLFileTransferVideoCell* videoCell = (MLFileTransferVideoCell *) [self messageTableCellWithIdentifier:@"fileTransferVideo" andInbound:msg.inbound fromTable:tableView];
                [videoCell layoutIfNeeded];
                return  videoCell.lblBaundry.frame.origin.y + videoCell.lblBaundry.frame.size.height;
               // return 200;
            }
            else if([info[@"mimeType"] hasPrefix:@"audio/"])
            {
                MLFileTransferVideoCell* audioCell = (MLFileTransferVideoCell *) [self messageTableCellWithIdentifier:@"fileTransferAudio" andInbound:msg.inbound fromTable:tableView];
                [audioCell layoutIfNeeded];
                return  audioCell.lblBaundry.frame.origin.y + audioCell.lblBaundry.frame.size.height;
                //return 180;
            }
            else
            {
                MLFileTransferTextCell* textCell = (MLFileTransferTextCell *) [self messageTableCellWithIdentifier:@"fileTransferText" andInbound:msg.inbound fromTable:tableView];
                [textCell layoutIfNeeded];
                return  textCell.lblBaundry.frame.origin.y + textCell.lblBaundry.frame.size.height;
               // return 180;
            }
        }
        else if (info && [info[@"needsDownloading"] boolValue])
        {
            MLFileTransferDataCell* fileTransferCell = (MLFileTransferDataCell *) [self messageTableCellWithIdentifier:@"fileTransferCheckingData" andInbound:msg.inbound fromTable:tableView];
            [fileTransferCell layoutIfNeeded];
            return  fileTransferCell.lblBaundry.frame.origin.y + fileTransferCell.lblBaundry.frame.size.height;
            //return 180;
        }
    } else if([msg.messageType isEqualToString:kMessageTypeUrl] && [[HelperTools defaultsDB] boolForKey:@"ShowURLPreview"]) {
        MLLinkCell* toreturn = (MLLinkCell *)[self messageTableCellWithIdentifier:@"link" andInbound:msg.inbound fromTable: tableView];
        [toreturn layoutIfNeeded];
        return  toreturn.lblBaundry.frame.origin.y + toreturn.lblBaundry.frame.size.height;
       // return 180;
    } else if ([msg.messageType isEqualToString:kMessageTypeGeo]) {
        if(self.showGeoLocationsInline) {
            MLChatMapsCell* mapsCell = (MLChatMapsCell *)[self messageTableCellWithIdentifier:@"maps" andInbound:msg.inbound fromTable: tableView];
            [mapsCell layoutIfNeeded];
            return  mapsCell.lblBaundry.frame.origin.y + mapsCell.lblBaundry.frame.size.height;
        } else {
            // Default to text cell
            MLBaseCell* cell = [self messageTableCellWithIdentifier:@"text" andInbound:msg.inbound fromTable: tableView];
            [cell layoutIfNeeded];
            return  cell.lblBaundry1.frame.origin.y + cell.lblBaundry1.frame.size.height;
        }
        //return 265;
    } else {
        return UITableViewAutomaticDimension;
    }
    return UITableViewAutomaticDimension;
}

-(MLBaseCell*) fileTransferCellCheckerWithInfo:(NSDictionary*)info direction:(BOOL)inDirection tableView:(UITableView*)tableView andMsg:(MLMessage*)row {
    MLBaseCell *cell = nil;
    //TODO JIM: explanation: this was already downloaded and it is an image --> show this image inline
    if([info[@"mimeType"] hasPrefix:@"image/"])
    {
        MLChatImageCell* imageCell = (MLChatImageCell *)[self messageTableCellWithIdentifier:@"image" andInbound:inDirection fromTable:tableView];
      //  imageCell.lblMessageSenderName.text = greentick.string;
       // imageCell.lblTimestamp.text = [self dateFromTimeStamp:msg.timestamp];
        [imageCell initCellWithMLMessage:row];
        //NSMutableAttributedString *fullString;
        CGSize size = CGSizeMake(20, 20);
        NSTextAttachment *icon = [[NSTextAttachment alloc] init];
        UIImage *iconImage;
        if (row.inbound == false) {
            iconImage = [UIImage imageNamed:@"IDMPhotoBrowser_arrowLeft"];
        } else {
            iconImage = [UIImage imageNamed:@"IDMPhotoBrowser_arrowRight"];
        }
        UIGraphicsBeginImageContext(size);
        [iconImage drawInRect:CGRectMake(0, 2, size.width, size.height)];
        UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        //
        icon.image = destImage;
        NSAttributedString *Green_tickattachmentString = [NSAttributedString attributedStringWithAttachment:icon];
        NSMutableAttributedString *greentick= [[NSMutableAttributedString alloc] initWithString:@"You "];
        [greentick appendAttributedString:Green_tickattachmentString];
        NSArray *UserComponents = [row.buddyName componentsSeparatedByString:@"@"];
        [greentick appendAttributedString:[[NSAttributedString alloc] initWithString:[UserComponents[0] capitalizedString]]];
        imageCell.lblMessageSenderName.text = greentick.string;
        imageCell.lblTimestamp.text = [self dateFromTimeStamp:row.timestamp];
        
        
        cell = imageCell;
    }
    else if([info[@"mimeType"] hasPrefix:@"video/"])
    {
        MLFileTransferVideoCell* videoCell = (MLFileTransferVideoCell *) [self messageTableCellWithIdentifier:@"fileTransferVideo" andInbound:inDirection fromTable:tableView];
        NSString* videoStr = info[@"cacheFile"];
        NSString* videoFileName = info[@"filename"];
        [videoCell avplayerConfigWithUrlStr:videoStr andMimeType:info[@"mimeType"] fileName:videoFileName andVC:self];
                
        //NSMutableAttributedString *fullString;
        CGSize size = CGSizeMake(20, 20);
        NSTextAttachment *icon = [[NSTextAttachment alloc] init];
        UIImage *iconImage;
        if (row.inbound == false) {
            iconImage = [UIImage imageNamed:@"IDMPhotoBrowser_arrowLeft"];
        } else {
            iconImage = [UIImage imageNamed:@"IDMPhotoBrowser_arrowRight"];
        }
        UIGraphicsBeginImageContext(size);
        [iconImage drawInRect:CGRectMake(0, 2, size.width, size.height)];
        UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        //
        icon.image = destImage;
        NSAttributedString *Green_tickattachmentString = [NSAttributedString attributedStringWithAttachment:icon];
        NSMutableAttributedString *greentick= [[NSMutableAttributedString alloc] initWithString:@"You "];
        [greentick appendAttributedString:Green_tickattachmentString];
        NSArray *UserComponents = [row.buddyName componentsSeparatedByString:@"@"];
        [greentick appendAttributedString:[[NSAttributedString alloc] initWithString:[UserComponents[0] capitalizedString]]];
        videoCell.lblMessageSenderName.text = greentick.string;
        videoCell.lblTimestamp.text = [self dateFromTimeStamp:row.timestamp];
        
        cell = videoCell;
    }
    else if([info[@"mimeType"] hasPrefix:@"audio/"])
    {
        //we may wan to make a new kind later but for now this is perfectly functional
        MLFileTransferVideoCell* audioCell = (MLFileTransferVideoCell *) [self messageTableCellWithIdentifier:@"fileTransferAudio" andInbound:inDirection fromTable:tableView];
        NSString *audioStr = info[@"cacheFile"];
        NSString *audioFileName = info[@"filename"];
        [audioCell avplayerConfigWithUrlStr:audioStr andMimeType:info[@"mimeType"] fileName:audioFileName andVC:self];

        //NSMutableAttributedString *fullString;
        CGSize size = CGSizeMake(20, 20);
        NSTextAttachment *icon = [[NSTextAttachment alloc] init];
        UIImage *iconImage;
        if (row.inbound == false) {
            iconImage = [UIImage imageNamed:@"IDMPhotoBrowser_arrowLeft"];
        } else {
            iconImage = [UIImage imageNamed:@"IDMPhotoBrowser_arrowRight"];
        }
        UIGraphicsBeginImageContext(size);
        [iconImage drawInRect:CGRectMake(0, 2, size.width, size.height)];
        UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        //
        icon.image = destImage;
        NSAttributedString *Green_tickattachmentString = [NSAttributedString attributedStringWithAttachment:icon];
        NSMutableAttributedString *greentick= [[NSMutableAttributedString alloc] initWithString:@"You "];
        [greentick appendAttributedString:Green_tickattachmentString];
        NSArray *UserComponents = [row.buddyName componentsSeparatedByString:@"@"];
        [greentick appendAttributedString:[[NSAttributedString alloc] initWithString:[UserComponents[0] capitalizedString]]];
        audioCell.lblMessageSenderName.text = greentick.string;
        audioCell.lblTimestamp.text = [self dateFromTimeStamp:row.timestamp];
        
        cell = audioCell;
    }
    else
    {
        MLFileTransferTextCell* textCell = (MLFileTransferTextCell *) [self messageTableCellWithIdentifier:@"fileTransferText" andInbound:inDirection fromTable:tableView];
        
        NSString *fileSizeStr = info[@"size"];
        long long fileSizeLongLongValue = fileSizeStr.longLongValue;
        NSString *readableFileSize = [NSByteCountFormatter stringFromByteCount:fileSizeLongLongValue
                                                                    countStyle:NSByteCountFormatterCountStyleFile];
        NSString *hintStr = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Open", @""), info[@"filename"]];
        NSString *fileCacheUrlStr = info[@"cacheFile"];
        textCell.fileCacheUrlStr = fileCacheUrlStr;
        
        NSUInteger countOfMimtTypeComponent = [info[@"mimeType"] componentsSeparatedByString:@";"].count;
        NSString* fileMimeType = @"";
        NSString* fileCharSet = @"";
        NSString* fileEncodeName = @"utf-8";
        if (countOfMimtTypeComponent > 1)
        {
            fileMimeType = [info[@"mimeType"] componentsSeparatedByString:@";"].firstObject;
            fileCharSet = [info[@"mimeType"] componentsSeparatedByString:@";"].lastObject;
        }
        else
        {
            fileMimeType = info[@"mimeType"];
        }
        
        if (fileCharSet != nil && fileCharSet.length > 0)
        {
            fileEncodeName = [fileCharSet componentsSeparatedByString:@"="].lastObject;
        }
        
        textCell.fileMimeType = fileMimeType;
        textCell.fileName = info[@"filename"];
        textCell.fileEncodeName = fileEncodeName;
        [textCell.fileTransferHint setText:hintStr];
        [textCell.sizeLabel setText:readableFileSize];
        textCell.openFileDelegate = self;
        
        //NSMutableAttributedString *fullString;
        CGSize size = CGSizeMake(20, 20);
        NSTextAttachment *icon = [[NSTextAttachment alloc] init];
        UIImage *iconImage;
        if (row.inbound == false) {
            iconImage = [UIImage imageNamed:@"IDMPhotoBrowser_arrowLeft"];
        } else {
            iconImage = [UIImage imageNamed:@"IDMPhotoBrowser_arrowRight"];
        }
        UIGraphicsBeginImageContext(size);
        [iconImage drawInRect:CGRectMake(0, 2, size.width, size.height)];
        UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        //
        icon.image = destImage;
        NSAttributedString *Green_tickattachmentString = [NSAttributedString attributedStringWithAttachment:icon];
        NSMutableAttributedString *greentick= [[NSMutableAttributedString alloc] initWithString:@"You "];
        [greentick appendAttributedString:Green_tickattachmentString];
        NSArray *UserComponents = [row.buddyName componentsSeparatedByString:@"@"];
        [greentick appendAttributedString:[[NSAttributedString alloc] initWithString:[UserComponents[0] capitalizedString]]];
        textCell.lblMessageSenderName.text = greentick.string;
        textCell.lblTimestamp.text = [self dateFromTimeStamp:row.timestamp];
        
        cell = textCell;
    }
    
    return cell;
}

-(nullable __kindof UITableViewCell*) messageTableCellWithIdentifier:(NSString*) identifier andInbound:(BOOL) inboundDirection fromTable:(UITableView*) tableView
{
    NSString* direction = @"In";
    if(!inboundDirection)
    {
        direction = @"Out";
    }
    NSString* fullIdentifier = [NSString stringWithFormat:@"%@%@Cell", identifier, direction];
    return [tableView dequeueReusableCellWithIdentifier:fullIdentifier];
}

#pragma mark - MLFileTransferTextCell delegate
-(void) showData:(NSString *)fileUrlStr withMimeType:(NSString *)mimeType andFileName:(NSString * _Nonnull)fileName andFileEncodeName:(NSString * _Nonnull)encodeName
{
    MLFileTransferFileViewController *fileViewController = [[MLFileTransferFileViewController alloc] init];
    fileViewController.fileUrlStr = fileUrlStr;
    fileViewController.mimeType = mimeType;
    fileViewController.fileName = fileName;
    fileViewController.fileEncodeName = encodeName;
    [self presentViewController:fileViewController animated:NO completion:nil];
//    [self.navigationController pushViewController:fileViewController animated:NO];
}

#pragma mark - link preview

-(void) loadPreviewWithUrlForRow:(NSIndexPath *) indexPath withCompletion:(void (^)(void))completion
{
    MLMessage* row = [self messageFromMessageId:indexPath.row];
//    if(indexPath.row < self.messageList.count)
//    {
//        row = [self.messageList objectAtIndex:indexPath.row];
//    }
//    else
//    {
//        DDLogError(@"Attempt to access beyond bounds");
//    }

    //prevent duplicated calls from cell animations
    if([self.previewedIds containsObject:row.messageDBId])
    {
        return;
    }

    if(row.url)
    {
        NSMutableURLRequest* headRequest = [[NSMutableURLRequest alloc] initWithURL: row.url];
        headRequest.HTTPMethod = @"HEAD";
        headRequest.cachePolicy = NSURLRequestReturnCacheDataElseLoad;
        
        NSURLSession* session = [NSURLSession sharedSession];
        [[session dataTaskWithRequest:headRequest completionHandler:^(NSData* _Nullable data, NSURLResponse* _Nullable response, NSError* _Nullable error) {
            NSDictionary* headers = ((NSHTTPURLResponse*)response).allHeaderFields;
            NSString* mimeType = [[headers objectForKey:@"Content-Type"] lowercaseString];
            NSNumber* contentLength = [headers objectForKey:@"Content-Length"] ? [NSNumber numberWithInt:([[headers objectForKey:@"Content-Length"] intValue])] : @(-1);

            if(mimeType.length==0) {return;}
            if(![mimeType hasPrefix:@"text"]) {return;}
            if(contentLength.intValue>500*1024) {return;} //limit to half a meg of HTML

            [self downloadPreviewWithRow:indexPath];

        }] resume];

    }
    else if(completion)
        completion();
}

-(void) downloadPreviewWithRow:(NSIndexPath*) indexPath
{
    MLMessage* row = [self messageFromMessageId:indexPath.row];
//    if(indexPath.row < self.messageList.count) {
//        row = [self.messageList objectAtIndex:indexPath.row];
//    } else {
//        DDLogError(@"Attempt to access beyond bounds");
//    }
    
    [self.previewedIds addObject:row.messageDBId];
    /**
     <meta property="og:title" content="Nintendo recommits to “keep the business going” for 3DS">
     <meta property="og:image" content="https://cdn.arstechnica.net/wp-content/uploads/2016/09/3DS_SuperMarioMakerforNintendo3DS_char_01-760x380.jpg">
     facebookexternalhit/1.1
     */
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:row.url];
    [request setValue:@"facebookexternalhit/1.1" forHTTPHeaderField:@"User-Agent"]; //required on some sites for og tags e.g. youtube
    request.timeoutInterval = 10;
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
    {
        
        NSString *body = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        // prevent repeated calls to this logic  by setting to non null
        row.previewText=[MLMetaInfo ogContentWithTag:@"og:title" inHTML:body];
        row.previewImage=[NSURL URLWithString:[[MLMetaInfo ogContentWithTag:@"og:image" inHTML:body] stringByRemovingPercentEncoding]];
        if(row.previewText.length == 0)
            row.previewText = @" ";
        [[DataLayer sharedInstance] setMessageId:row.messageId previewText:[row.previewText copy] andPreviewImage:[row.previewImage.absoluteString copy]];
        //reload cells
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tblViewStarMessage reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        });
    }] resume];
}

- (NSString *)dateFromTimeStamp:(NSDate*)timestamp {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM dd, YYYY hh:mm a"];
    return [formatter stringFromDate:timestamp];
}

- (MLMessage *)messageFromMessageId:(NSInteger)index {    
    NSMutableArray *starMessageArray1 = [[[NSUserDefaults standardUserDefaults] arrayForKey:@"starMessageArray"] mutableCopy];
    NSMutableDictionary *mutableDict = [starMessageArray1 objectAtIndex:index];
    NSNumber* historyId = [mutableDict objectForKey:@"messageDBId"];
    MLMessage* msg = [[DataLayer sharedInstance] messageForHistoryID:historyId];
    if(!msg)
    {
      //  DDLogError(@"historyId %@ does not yield an MLMessage object, aborting", historyId);
        msg = NULL;
    }
    return msg;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSMutableArray *starMessageArray1 = [[[NSUserDefaults standardUserDefaults] arrayForKey:@"starMessageArray"] mutableCopy];
    NSMutableDictionary *mutableDict = [starMessageArray1 objectAtIndex:indexPath.row];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"starMessageId"];
    [[NSUserDefaults standardUserDefaults] setObject:mutableDict forKey:@"starMessageId"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self performSegueWithIdentifier:@"ShowStarMessageID" sender:self];
}

- (IBAction)btnCloseBarButtonAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
