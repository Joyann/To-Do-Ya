//
//  ListsTableViewController.m
//  To-Do-Ya
//
//  Created by joyann on 14-11-2.
//  Copyright (c) 2014年 Joyann. All rights reserved.
//

#import "ListsTableViewController.h"
#import "List.h"
#import "ListItem.h"
#import "ListsTableViewCell.h"
#import "ListItemsTableViewController.h"
#import "ListDetailTableViewController.h"

@interface ListsTableViewController () <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end

@implementation ListsTableViewController

- (NSFetchedResultsController *)fetchedResultsController
{
    if(!_fetchedResultsController) {
        
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"List"];
        
        NSSortDescriptor *sortDescriptors1 = [[NSSortDescriptor alloc] initWithKey:@"listName" ascending:YES];
        request.sortDescriptors = @[sortDescriptors1];
        
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
    [self performFetch];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    UILongPressGestureRecognizer *longPressGR = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                              action:@selector(performSegue:)];
    longPressGR.minimumPressDuration = 1.0;
    [self.tableView addGestureRecognizer:longPressGR];
}

#pragma mark - PerformSegue

- (void)performSegue:(UIGestureRecognizer *)recognizer
{
    CGPoint point = [recognizer locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:point];
    List *list = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self performSegueWithIdentifier:@"EditList" sender:list];
}

#pragma mark - PerformFetch

- (void)performFetch
{
    NSError *error;
    if(![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"%@",error);
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id<NSFetchedResultsSectionInfo> resultsInfo = [self.fetchedResultsController sections][section];
    return [resultsInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"ListCellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark - ConfigureCell

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    ListsTableViewCell *listsCell = (ListsTableViewCell *)cell;
    List *list = [self.fetchedResultsController objectAtIndexPath:indexPath];
    listsCell.nameLabel.text = list.listName;
    listsCell.photoView.image = [UIImage imageNamed:list.listImageName];
    listsCell.itemsCount.text = [NSString stringWithFormat:@"Things:%ld",(long)[list.items count]];
    
    // Add separator
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, self.tableView.rowHeight - 1, self.tableView.frame.size.width, 1)];
    separator.backgroundColor = [UIColor blackColor];
    [cell.contentView addSubview:separator];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        List *list = [self.fetchedResultsController objectAtIndexPath:indexPath];
        for (ListItem *item in list.items) {
            [item removePhotoFile];
        }
        [self.managedObjectContext deleteObject:list];
        NSError *error;
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"%@",error);
        }
    }
}

#pragma mark - PrepareForSegue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowListItems"]) {
        if([segue.destinationViewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController *navigationController = (UINavigationController *)segue.destinationViewController;
            ListItemsTableViewController *listItemsTableViewController = (ListItemsTableViewController *)navigationController.topViewController;
            UITableViewCell *cell = (UITableViewCell *)sender;
            NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
            List *list = [self.fetchedResultsController objectAtIndexPath:indexPath];
            listItemsTableViewController.list = list;
            listItemsTableViewController.managedObjectContext = self.managedObjectContext;
        }
    } else if ([segue.identifier isEqualToString:@"EditList"]) {
        if ([segue.destinationViewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController *navigationController = (UINavigationController *)segue.destinationViewController;
            ListDetailTableViewController *listDetailTVC = (ListDetailTableViewController *)navigationController.topViewController;
            listDetailTVC.editList = (List *)sender;
            listDetailTVC.managedObjectContext = self.managedObjectContext;
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
            ListsTableViewCell *cell = (ListsTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
            List *list = [self.fetchedResultsController objectAtIndexPath:indexPath];
            cell.nameLabel.text = list.listName;
            cell.photoView.image = [UIImage imageNamed:list.listImageName];
            cell.itemsCount.text = [NSString stringWithFormat:@"Things:%ld",(long)[list.items count]];
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
