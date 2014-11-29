//
//  ListsTableViewCell.h
//  To-Do-Ya
//
//  Created by joyann on 14-11-2.
//  Copyright (c) 2014年 Joyann. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ListsTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *photoView;
@property (weak, nonatomic) IBOutlet UILabel *itemsCount;


@end
