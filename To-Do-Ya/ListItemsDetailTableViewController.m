//
//  ListItemsDetailTableViewController.m
//  To-Do-Ya
//
//  Created by joyann on 14-11-2.
//  Copyright (c) 2014年 Joyann. All rights reserved.
//

#import "ListItemsDetailTableViewController.h"
#import "ListItem.h"

@interface ListItemsDetailTableViewController () <UITextViewDelegate, UITextFieldDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UIImageView *pictureIconView;
@property (weak, nonatomic) IBOutlet UILabel *pictureLabel;
@property (weak, nonatomic) IBOutlet UIImageView *dateIconView;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@property (nonatomic, copy) NSString *itemName;
@property (nonatomic, copy) NSString *itemDescription;

@property (nonatomic, strong) UIActionSheet *actionSheet;
@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (nonatomic, strong) UIImage *image;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, assign) BOOL datePickerVisible;

@property (weak, nonatomic) IBOutlet UISwitch *remindSwitch;


@end

@implementation ListItemsDetailTableViewController

- (NSDateFormatter *)dateFormatter
{
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.timeStyle = NSDateFormatterMediumStyle;
        _dateFormatter.dateStyle = NSDateFormatterShortStyle;
    }
    return _dateFormatter;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard:)];
    tapRecognizer.cancelsTouchesInView = NO;
    [self.tableView addGestureRecognizer:tapRecognizer];
    
    if (self.editedListItem != nil) {
        self.doneButton.enabled = YES;
        self.itemName = self.editedListItem.itemName;
        self.nameTextField.text = self.editedListItem.itemName;
        self.itemDescription = self.editedListItem.itemDescription;
        self.descriptionTextView.text = self.editedListItem.itemDescription;
        self.date = self.editedListItem.itemDate;
        self.dateLabel.text = [self.dateFormatter stringFromDate:self.editedListItem.itemDate];
        if (!self.editedListItem.itemDate) {
            self.dateLabel.text = @"Select your date";
        }
        self.remindSwitch.on = [self.editedListItem.itemIsRemind boolValue];
        
        if ([self.editedListItem hasPhoto]) {
            self.image = [self.editedListItem getPhoto];
            [self showImage:self.image];
            [self.tableView reloadData];
        }
    }
    
}

#pragma mark - HideKeyboard

- (void)hideKeyboard:(UIGestureRecognizer *)recognizer
{
    CGPoint point = [recognizer locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:point];
    if (indexPath != nil && ((indexPath.section == 0 && indexPath.row == 0) || (indexPath.section ==1 && indexPath.row == 0))) {
        return;
    }
    [self.nameTextField resignFirstResponder];
    [self.descriptionTextView resignFirstResponder];
    
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    self.itemDescription = [textView.text stringByReplacingCharactersInRange:range withString:text];
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    self.itemDescription = textView.text;
    return YES;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    self.itemName = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if ([self.itemName length] > 0) {
        self.doneButton.enabled = YES;
    } else {
        self.doneButton.enabled = NO;
    }
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    self.itemName = textField.text;
    return YES;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 3 && self.datePickerVisible) {
        return 3;
    }
    return [super tableView:tableView numberOfRowsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 3 && indexPath.row == 2) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DatePickerCell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DatePickerCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 0, 320, 216)];
            [self.datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
            
            [cell.contentView addSubview:self.datePicker];
        }
        return cell;
    } else {
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    }
}

#pragma mark - DateChanged

- (void)dateChanged:(UIDatePicker *)datePicker
{
    self.date = datePicker.date;
    
    self.dateLabel.text = [self.dateFormatter stringFromDate:self.date];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 2 && indexPath.row == 0) {
        [self showImageActionSheet];
    } else if (indexPath.section == 3 && indexPath.row == 1) {
        if (!self.datePickerVisible) {
            [self showDatePicker];
        } else {
            [self hideDatePicker];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && indexPath.row == 0) {
        return 88.0f;
    } else if (indexPath.section == 2 && indexPath.row == 0) {
        if (self.imageView.hidden) {
            return 44.0f;
        } else {
            return 180.0f;
        }
    } else if (indexPath.section == 3 && indexPath.row == 2) {
        return 320.0f;
    }
    
    return 44.0f;
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 3 && indexPath.row == 2) {
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:0 inSection:indexPath.section];
        return [super tableView:tableView indentationLevelForRowAtIndexPath:newIndexPath];
    } else {
        return [super tableView:tableView indentationLevelForRowAtIndexPath:indexPath];
    }
}

#pragma mark - ShowDatePicker

- (void)showDatePicker
{
    self.datePickerVisible = YES;
    
    [self.tableView reloadData];
}

#pragma mark - HideDatePicker

- (void)hideDatePicker
{
    if (self.datePickerVisible) {
        self.datePickerVisible = NO;
        NSIndexPath *datePickerIndexPath = [NSIndexPath indexPathForRow:2 inSection:3];
        [self.tableView deleteRowsAtIndexPaths:@[datePickerIndexPath] withRowAnimation:UITableViewRowAnimationBottom];
    }
}

#pragma mark - ShowImageActionSheet

- (void)showImageActionSheet
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        self.actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:@"Take Photo", @"Choose From Library", nil];
        [self.actionSheet showInView:self.view];
    } else {
        [self choosePhotoFromLibrary];
    }
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self takePhotoByCamera];
    } else if(buttonIndex == 1) {
        [self choosePhotoFromLibrary];
    }
}

#pragma mark - GetPhoto

- (void)takePhotoByCamera
{
    self.imagePicker = [[UIImagePickerController alloc] init];
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    self.imagePicker.delegate = self;
    self.imagePicker.allowsEditing = YES;
    
    [self presentViewController:self.imagePicker animated:YES completion:nil];
}

- (void)choosePhotoFromLibrary
{
    self.imagePicker = [[UIImagePickerController alloc] init];
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    self.imagePicker.delegate = self;
    self.imagePicker.allowsEditing = YES;
    
    [self presentViewController:self.imagePicker animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    self.image = info[UIImagePickerControllerEditedImage];
    [self showImage:self.image];
    [self.tableView reloadData];
    [self dismissViewControllerAnimated:YES completion:nil];
    self.imagePicker.delegate = nil;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];

    self.imagePicker.delegate = nil;
}

#pragma mark - ShowImage

- (void)showImage:(UIImage *)image
{
    self.imageView.image = image;
    self.imageView.hidden = NO;
    CGRect newFrame = CGRectMake(10, 10, 160, 160);
    self.imageView.frame = newFrame;
    self.pictureIconView.hidden = YES;
    self.pictureLabel.hidden = YES;
}

#pragma mark - NotificationForThisItem

- (UILocalNotification *)notificationForThisItem:(ListItem *)item
{
    NSArray *notifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    for (UILocalNotification *notification in notifications) {
        NSNumber *notificationID = [notification.userInfo objectForKey:@"NotificationID"];
        if (notificationID != nil && [notificationID integerValue] == [item.itemNotificationID integerValue]) {
            return notification;
        }
    }
    return nil;
}

#pragma mark - Action

- (IBAction)done:(UIBarButtonItem *)sender
{
    ListItem *item = nil;
    if (self.editedListItem == nil) {
        item = [NSEntityDescription insertNewObjectForEntityForName:@"ListItem"
                                             inManagedObjectContext:self.managedObjectContext];
        item.itemNotificationID = @-1;
        item.itemPhotoID = @-1;
        item.whoTake = self.list;
    } else {
        item = self.editedListItem;
    }

    item.itemName = self.itemName;
    item.itemDescription = self.itemDescription;
    item.itemDate = self.date;
    item.itemIsRemind = @(self.remindSwitch.on);
    
    if (self.remindSwitch.isOn && [item.itemDate compare:[NSDate date]] != NSOrderedAscending) {
        
        item.itemNotificationID = @([ListItem nextNotificationID]);
        
        UILocalNotification *existingNotification = [self notificationForThisItem:item];
        if (existingNotification != nil) {
            [[UIApplication sharedApplication] cancelLocalNotification:existingNotification];
        }
        
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.fireDate = item.itemDate;
        notification.timeZone = [NSTimeZone defaultTimeZone];
        notification.alertBody = [NSString stringWithFormat:@"%@",item.itemDescription];
        notification.soundName = UILocalNotificationDefaultSoundName;
        notification.userInfo = @{ @"NotificationID" : item.itemNotificationID };
        notification.applicationIconBadgeNumber =1;
        
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
        
    } else if (!self.remindSwitch.isOn) {
        UILocalNotification *existingNotification = [self notificationForThisItem:item];
        if (existingNotification != nil) {
            [[UIApplication sharedApplication] cancelLocalNotification:existingNotification];
        }

    }
    
    
    if (self.image) {
        if (![item hasPhoto]) {
            item.itemPhotoID = @([ListItem nextPhotoID]);
        }
        NSData *data = UIImageJPEGRepresentation(self.image, 0.5);
        NSError *error;
        if (![data writeToFile:[item photoPath] atomically:YES]) {
            NSLog(@"%@",error);
        }
    }
    
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"%@",error);
    };
    
    [self closen];
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
