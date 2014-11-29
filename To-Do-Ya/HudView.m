//
//  HudView.m
//  To-Do-Ya
//
//  Created by joyann on 14-11-2.
//  Copyright (c) 2014年 Joyann. All rights reserved.
//

#import "HudView.h"

@implementation HudView

+ (HudView *)hudViewInView:(UIView *)view isAnimation:(BOOL)animation
{
    HudView *hudView = [[HudView alloc] initWithFrame:view.bounds];
    hudView.userInteractionEnabled = NO;
    hudView.opaque = NO;
    
    [view addSubview:hudView];
    [hudView showAnimated:animation];
    
    return hudView;
}

- (void)showAnimated:(BOOL)animation
{
    if (animation) {
        self.alpha = 0.0f;
        self.transform = CGAffineTransformMakeScale(1.5f, 1.5f);
        [UIView animateWithDuration:0.3f animations:^{
            self.alpha = 1.0f;
            self.transform = CGAffineTransformIdentity;
        }];
    }
}

// draw a HudView .     ---------------> in HudView.m
- (void)drawRect:(CGRect)rect
{
    const CGFloat boxWidth = 96.0f;
    const CGFloat boxHeight = 96.0f;
    
    CGRect boxRect = CGRectMake(
                                roundf(self.bounds.size.width - boxWidth) / 2.0f,
                                roundf(self.bounds.size.height - boxHeight) / 2.0f,
                                boxWidth,
                                boxHeight);
    
    UIBezierPath *roundedRect = [UIBezierPath bezierPathWithRoundedRect:boxRect cornerRadius:10.0f];
    [[UIColor colorWithWhite:0.3f alpha:0.8f] setFill];
    [roundedRect fill];
    
    UIImage *image = [UIImage imageNamed:@"Checkmark"]; //The image you wanted draw.
    
    CGPoint imagePoint = CGPointMake(
                                     self.center.x - roundf(image.size.width / 2.0f),
                                     self.center.y - roundf(image.size.height / 2.0f) - boxHeight / 8.0f);
    
    [image drawAtPoint:imagePoint];
    
    NSDictionary *attributes = @{
                                 NSFontAttributeName : [UIFont systemFontOfSize:16.0f],
                                 NSForegroundColorAttributeName : [UIColor whiteColor]
                                 };
    
    CGSize textSize = [self.text sizeWithAttributes:attributes];
    
    CGPoint textPoint = CGPointMake(
                                    self.center.x - roundf(textSize.width / 2.0f),
                                    self.center.y - roundf(textSize.height / 2.0f) + boxHeight / 4.0f);
    
    [self.text drawAtPoint:textPoint withAttributes:attributes];
}


@end
