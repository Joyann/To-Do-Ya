//
//  ListItemsTableViewController.m
//  To-Do-Ya
//
//  Created by joyann on 14-11-2.
//  Copyright (c) 2014年 Joyann. All rights reserved.
//

#import "ListItemsTableViewController.h"
#import "ListItem.h"
#import "ListItemsDetailTableViewController.h"
#import "UIImage+Resize.h"
#import "ItemsTableViewCell.h"

@interface ListItemsTableViewController () <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end

@implementation ListItemsTableViewController

- (NSDateFormatter *)dateFormatter
{
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.timeStyle = NSDateFormatterMediumStyle;
        _dateFormatter.dateStyle = NSDateFormatterShortStyle;
    }
    return _dateFormatter;
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (!_fetchedResultsController) {
        
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"ListItem"];
        
        request.predicate = [NSPredicate predicateWithFormat:@"whoTake = %@",self.list];
        
        NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"itemName" ascending:YES];
        request.sortDescriptors = @[sortDescriptor1];
        
        _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:self.managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
        _fetchedResultsController.delegate = self;
    }
    return _fetchedResultsController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSError *error;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"%@",error);
    }
}

#pragma mark - TableViewDelegate

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        ListItem *listItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [listItem removePhotoFile];
        [self.managedObjectContext deleteObject:listItem];
        NSError *error;
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"%@",error);
        }
    }
}

#pragma mark - TableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"ListItemsCellID";
    ItemsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    ListItem *listItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.itemNameLabel.text = listItem.itemName;
    cell.itemTimeLabel.text = [self.dateFormatter stringFromDate:listItem.itemDate];
    UIImage *image = [listItem getPhoto];
    UIImage *newImage = [image resizeImageWithBounds:CGSizeMake(36, 36)];
   
    cell.itemImageView.clipsToBounds = YES;
    cell.itemImageView.layer.cornerRadius = cell.itemImageView.bounds.size.width / 2.0f;
    cell.itemImageView.image = newImage;
    
    if ([listItem.itemIsRemind boolValue]) {
        cell.starLabel.text = @"✓";
    } else {
        cell.starLabel.text = @"";
    }
    
    return cell;
}

#pragma mark - PrepareForSegue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"AddListItem"]) {
        if ([segue.destinationViewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController *navigationController = (UINavigationController *)segue.destinationViewController;
            ListItemsDetailTableViewController *listItemDetailTVC = (ListItemsDetailTableViewController *)navigationController.topViewController;
            listItemDetailTVC.managedObjectContext = self.managedObjectContext;
            listItemDetailTVC.list = self.list;
        }
    } else if ([segue.identifier isEqualToString:@"EditListItem"]) {
        if ([segue.destinationViewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController *navigationController = (UINavigationController *)segue.destinationViewController;
            ListItemsDetailTableViewController *listItemDetailTVC = (ListItemsDetailTableViewController *)navigationController.topViewController;
            
            UITableViewCell *selectedCell = (UITableViewCell *)sender;
            NSIndexPath *indexPath = [self.tableView indexPathForCell:selectedCell];
            ListItem *listItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
            
            listItemDetailTVC.editedListItem = listItem;
            listItemDetailTVC.managedObjectContext = self.managedObjectContext;
        }
    }
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    NSLog(@"*** controllerWillChangeContent");
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    switch (type) {
        case NSFetchedResultsChangeInsert:
            NSLog(@"*** NSFetchedResultsChangeInsert (object)");
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            NSLog(@"*** NSFetchedResultsChangeDelete (object)");
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate: {
            NSLog(@"*** NSFetchedResultsChangeUpdate (object)");
            ListItem *listItem = (ListItem *)anObject;
            ItemsTableViewCell *cell = (ItemsTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
            cell.itemNameLabel.text = listItem.itemName;
            cell.itemTimeLabel.text = [self.dateFormatter stringFromDate:listItem.itemDate];
            cell.itemImageView.image = [listItem getPhoto];
            cell.itemImageView.clipsToBounds = YES;
            cell.itemImageView.layer.cornerRadius = cell.itemImageView.bounds.size.width / 2.0f;
            if ([listItem.itemIsRemind boolValue]) {
                cell.starLabel.text = @"✓";
            } else {
                cell.starLabel.text = @"";
            }
            break;
        }
 
        case NSFetchedResultsChangeMove:
            NSLog(@"*** NSFetchedResultsChangeMove (object)");
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch (type) {
        case NSFetchedResultsChangeInsert:
            NSLog(@"*** NSFetchedResultsChangeInsert (section)");
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            NSLog(@"*** NSFetchedResultsChangeDelete (section)");
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        default:
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    NSLog(@"*** controllerDidChangeContent");
    [self.tableView endUpdates];
}


@end
