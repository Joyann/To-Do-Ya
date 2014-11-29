//
//  HudView.h
//  To-Do-Ya
//
//  Created by joyann on 14-11-2.
//  Copyright (c) 2014年 Joyann. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HudView : UIView

@property (nonatomic, copy) NSString *text;

+ (HudView *)hudViewInView:(UIView *)view isAnimation:(BOOL)animation;

@end
