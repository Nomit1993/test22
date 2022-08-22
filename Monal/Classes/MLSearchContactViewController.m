//
//  MLSearchContactViewController.m
//  jrtplib-static
//
//  Created by mohanchandaluri on 29/03/22.
//  Copyright © 2022 Monal.im. All rights reserved.
//

#import "MLSearchContactViewController.h"
#import "DataLayer.h"
#import "MLContactCell.h"
@interface MLSearchContactViewController ()

@end

@implementation MLSearchContactViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc ] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:nil];
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.navigationItem.title = @"Search";
    self.searchController.searchResultsUpdater = self;
    self.searchController.delegate = self;
    self.searchTableView.delegate = self;
    self.searchTableView.dataSource = self;
    self.searchController.obscuresBackgroundDuringPresentation = NO;
    [self.searchTableView registerNib:[UINib nibWithNibName:@"MLContactCell"
                                    bundle:[NSBundle mainBundle]]
                                    forCellReuseIdentifier:@"ContactCell"];
    
    self.navigationItem.searchController = self.searchController;
    
   // self.navigationItem.leftBarButtonItem = backButton;
    // Do any additional setup after loading the view.
}
- (void)viewWillAppear:(BOOL)animated{
    [self refreshDisplay];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.searchController setActive:YES];
    [self.searchController.searchBar becomeFirstResponder];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
-(void) dismissView{
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void) refreshDisplay
{
    [self loadContactsWithFilter:nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self reloadTable];
    });
}
-(void) loadContactsWithFilter:(NSString*) filter
{
    if(filter && [filter length] > 0){
        self.contacts = [[DataLayer sharedInstance] searchContactsWithString:filter];
        [self.contacts enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
        MLContact *contact = object;
        if ([contact.contactJid isEqualToString:@"enhanced-apk@chat.securesignal.in"]){
            [self.contacts removeObjectAtIndex:idx];
        }
        }];
    }else{
        self.contacts = self.contacts = [[DataLayer sharedInstance] contactList];
        [self.contacts enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
        MLContact *contact = object;
        if ([contact.contactJid isEqualToString:@"enhanced-apk@chat.securesignal.in"]){
            [self.contacts removeObjectAtIndex:idx];
        }
        }];
    }
       
}
-(void) reloadTable
{
    if(self.searchTableView.hasUncommittedUpdates) return;
    
    [self.searchTableView reloadData];
}
#pragma mark - Search Controller

-(void) didDismissSearchController:(UISearchController*) searchController;
{
    // reset table to list of all contacts without a filter
  //  self.isSearchEnabled = NO;
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) updateSearchResultsForSearchController:(UISearchController*) searchController;
{
    [self loadContactsWithFilter:searchController.searchBar.text];
    [self reloadTable];
}


- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
   MLContact* contact = [self.contacts objectAtIndex:indexPath.row];
    MLContactCell* cell = [tableView dequeueReusableCellWithIdentifier:@"ContactCell"];
    if(!cell)
        cell = [[MLContactCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"ContactCell"];
    [cell initCell:contact withLastMessage:nil];
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.contacts count];
}

-(void) tableView:(UITableView*) tableView didSelectRowAtIndexPath:(NSIndexPath*) indexPath{
    MLContact* contact = [self.contacts objectAtIndex:indexPath.row];
    [self dismissViewControllerAnimated:YES completion:^{
        if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
           {
              // self.window.rootViewController = rootViewController;
               if(self.selectContact)
                   self.selectContact(contact);
           }else
           {
               if (self.selectContact){
                   self.selectContact(contact);
               }
            }
        
    }];
   
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}




@end
