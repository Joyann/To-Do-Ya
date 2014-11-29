//
//  MyTabBarController.m
//  To-Do-Ya
//
//  Created by joyann on 14/11/9.
//  Copyright (c) 2014年 Joyann. All rights reserved.
//

#import "MyTabBarController.h"

@interface MyTabBarController ()

@end

@implementation MyTabBarController

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
- (UIViewController *)childViewControllerForStatusBarStyle
{
    return nil;
}

@end
