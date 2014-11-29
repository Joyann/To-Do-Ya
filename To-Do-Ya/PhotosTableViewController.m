//
//  PhotosTableViewController.m
//  To-Do-Ya
//
//  Created by joyann on 14/11/4.
//  Copyright (c) 2014年 Joyann. All rights reserved.
//

#import "PhotosTableViewController.h"
#import "ListDetailTableViewController.h"

@interface PhotosTableViewController ()

@property (nonatomic, strong) NSArray *photos;
@property (nonatomic, copy) NSString *photoName;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;

@end

@implementation PhotosTableViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
 
    self.photos = @[
                        @"Appointments",
                        @"Birthdays",
                        @"Chores",
                        @"Drinks",
                        @"Folder",
                        @"Groceries",
                        @"Inbox",
                        @"Photos",
                        @"Trips"
                   ];
    
}

#pragma mark - TableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.photos count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"PhotoCellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    NSString *photoName = self.photos[indexPath.row];
    
    cell.textLabel.text = photoName;
    cell.imageView.image = [UIImage imageNamed:photoName];
    
    if ([self.selectedName isEqualToString:photoName]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        self.selectedIndexPath = indexPath;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    

    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath != self.selectedIndexPath) {
        UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
        newCell.accessoryType = UITableViewCellAccessoryCheckmark;
        
        UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:self.selectedIndexPath];
        oldCell.accessoryType = UITableViewCellAccessoryNone;
        
        self.selectedIndexPath = indexPath;
    }

}

#pragma mark - PrepareForSegue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"GetSelectedPhoto"]) {
        if ([segue.destinationViewController isKindOfClass:[ListDetailTableViewController class]]) {
            UITableViewCell *cell = (UITableViewCell *)sender;
            NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
            NSString *photoName = self.photos[indexPath.row];
            self.selectedName = photoName;
        }
    }
}

@end








































