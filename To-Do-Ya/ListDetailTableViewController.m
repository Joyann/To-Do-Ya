//
//  ListDetailTableViewController.m
//  To-Do-Ya
//
//  Created by joyann on 14-11-2.
//  Copyright (c) 2014年 Joyann. All rights reserved.
//

#import "ListDetailTableViewController.h"
#import "HudView.h"
#import "List.h"
#import "PhotosTableViewController.h"

@interface ListDetailTableViewController () <UITextFieldDelegate, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *listNameTextField;
@property (weak, nonatomic) IBOutlet UITextView *listDescriptionTextView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;

@property (nonatomic, copy) NSString *listName;
@property (nonatomic, copy) NSString *listDescription;

@property (weak, nonatomic) IBOutlet UIImageView *photoView;
@property (weak, nonatomic) IBOutlet UILabel *photoLabel;

@property (nonatomic, copy) NSString *photoName;

@end

@implementation ListDetailTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.listNameTextField becomeFirstResponder];
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyBoard:)];
    [self.tableView addGestureRecognizer:gestureRecognizer];
    
    if (self.editList != nil) {
        self.doneButton.enabled = YES;
        
        self.listNameTextField.text = self.editList.listName;
        self.listDescriptionTextView.text = self.editList.listDescription;
        self.photoLabel.text = self.editList.listImageName;
        self.photoView.image = [UIImage imageNamed:self.editList.listImageName];
        self.photoName = self.editList.listImageName;
    }
    
}

#pragma mark - PrepareForSegue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowPhotos"]) {
        if ([segue.destinationViewController isKindOfClass:[PhotosTableViewController class]]) {
            PhotosTableViewController *photosTVC = (PhotosTableViewController *)segue.destinationViewController;
            photosTVC.selectedName = self.photoName;
        }
    }
}

#pragma mark - UnwindSegue

- (IBAction)getPhotoNameWithUnwindSegue:(UIStoryboardSegue *)segue
{
    PhotosTableViewController *photosTVC = (PhotosTableViewController *)segue.sourceViewController;
    self.photoName = photosTVC.selectedName;
    self.photoView.image = [UIImage imageNamed:self.photoName];
    self.photoLabel.text = self.photoName;
}

#pragma mark - Hide KeyBoard

- (void)hideKeyBoard:(UIGestureRecognizer *)recognizer
{
    CGPoint point = [recognizer locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:point];
    NSLog(@"%ld-%ld",(long)indexPath.section, (long)indexPath.row);
    if(indexPath != nil && indexPath.section == 0 && indexPath.row == 0) {
        return;
    } else if (indexPath != nil && indexPath.section == 1 && indexPath.row == 0) {
        return;
    }
    else if (indexPath != nil && (indexPath.section == 2 && indexPath.row == 0)) {
        [self performSegueWithIdentifier:@"ShowPhotos" sender:nil];
    }

    [self.listNameTextField resignFirstResponder];
    [self.listDescriptionTextView resignFirstResponder];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 1 && indexPath.row == 0) {
        return 88.0f;
    } else {
        return 44.0f;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
//    if (indexPath.section == 2 && indexPath.row == 0) {
//        return;
//    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    self.listName = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if([self.listName length] > 0) {
        self.doneButton.enabled = YES;
    } else {
        self.doneButton.enabled = NO;
    }
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    self.listName = textField.text;
    return YES;
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    self.listDescription = [textView.text stringByReplacingCharactersInRange:range withString:text];
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    self.listDescription = textView.text;
    return YES;
}

#pragma mark - Action

- (IBAction)done:(UIBarButtonItem *)sender
{
    // HudView
    HudView *hudView = [HudView hudViewInView:self.navigationController.view isAnimation:YES];
    
    List *list = nil;
    if (self.editList == nil) {
        hudView.text = @"Tagged";
        list = [NSEntityDescription insertNewObjectForEntityForName:@"List"
                                             inManagedObjectContext:self.managedObjectContext];
    } else {
        hudView.text = @"Updated";
        list = self.editList;
    }

    list.listName = self.listNameTextField.text;
    list.listDescription = self.listDescriptionTextView.text;
    list.listImageName = self.photoName;
    
    NSError *error;
    if(![self.managedObjectContext save:&error]) {
        NSLog(@"%@",error);
    }
 
    [self performSelector:@selector(closen) withObject:nil afterDelay:0.8f];
}

- (IBAction)cancel:(UIBarButtonItem *)sender
{
    [self closen];
}

#pragma mark - Closen

- (void)closen
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end




































