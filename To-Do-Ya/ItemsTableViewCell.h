//
//  ItemsTableViewCell.h
//  To-Do-Ya
//
//  Created by joyann on 14/11/8.
//  Copyright (c) 2014年 Joyann. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ItemsTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *itemImageView;
@property (weak, nonatomic) IBOutlet UILabel *itemNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *itemTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *starLabel;

@end
