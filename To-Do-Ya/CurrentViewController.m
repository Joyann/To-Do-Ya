//
//  CurrentViewController.m
//  To-Do-Ya
//
//  Created by joyann on 14-11-2.
//  Copyright (c) 2014年 Joyann. All rights reserved.
//

#import "CurrentViewController.h"
#import "FLSpringView.h"
#import "ListDetailTableViewController.h"

@interface CurrentViewController ()

@property (weak, nonatomic) IBOutlet UIView *myView;

@end

@implementation CurrentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    FLSpringView *springView = [[FLSpringView alloc] initWithFrame:self.myView.bounds];
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addList:)];
    [(UIImageView *)[springView viewWithTag:1000] addGestureRecognizer:tapRecognizer];
    
    [self.view addSubview:springView];
}

- (void)addList:(UIGestureRecognizer *)recognizer
{
    [self performSegueWithIdentifier:@"ShowListDetail" sender:nil];
}

#pragma mark - PrepareForSegue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"ShowListDetail"]) {
        if ([segue.destinationViewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController *navigationController = (UINavigationController *)segue.destinationViewController;
            ListDetailTableViewController *listDetailTVC = (ListDetailTableViewController *)navigationController.topViewController;
            listDetailTVC.managedObjectContext = self.managedObjectContext;
        }
    }
}

@end
