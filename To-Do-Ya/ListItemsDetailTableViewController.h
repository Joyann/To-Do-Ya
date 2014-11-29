//
//  ListItemsDetailTableViewController.h
//  To-Do-Ya
//
//  Created by joyann on 14-11-2.
//  Copyright (c) 2014年 Joyann. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "List.h"

@interface ListItemsDetailTableViewController : UITableViewController

@property (nonatomic, strong) List *list;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) ListItem *editedListItem;

@end
