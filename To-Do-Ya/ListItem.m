//
//  ListItem.m
//  To-Do-Ya
//
//  Created by joyann on 14/11/6.
//  Copyright (c) 2014年 Joyann. All rights reserved.
//

#import "ListItem.h"
#import "List.h"


@implementation ListItem

@dynamic itemIsRemind;
@dynamic itemDate;
@dynamic itemDescription;
@dynamic itemName;
@dynamic itemPhotoID;
@dynamic itemNotificationID;
@dynamic whoTake;

+ (NSInteger)nextPhotoID
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger photoID = [defaults integerForKey:@"PhotoID"];
    [defaults setInteger:photoID + 1 forKey:@"PhotoID"];
    [defaults synchronize];
    return photoID;
}

+ (NSInteger)nextNotificationID
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger notificationID = [defaults integerForKey:@"NotificationID"];
    [defaults setInteger:notificationID + 1 forKey:@"NotificationID"];
    [defaults synchronize];
    return notificationID;
}

- (BOOL)hasPhoto
{
    return (self.itemPhotoID != nil && [self.itemPhotoID integerValue] != -1);
}

- (NSString *)photoPath
{
    NSString *dericatoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    return [dericatoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"Photo-%ld", (long)[self.itemPhotoID integerValue]]];
}

- (UIImage *)getPhoto
{
//    NSAssert(self.itemPhotoID != nil, @"No photoID");
//    NSAssert([self.itemPhotoID integerValue] != -1, @"photoID == -1");
    return [UIImage imageWithContentsOfFile:[self photoPath]];
}

- (void)removePhotoFile
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:[self photoPath]]) {
        NSError *error;
        if (![fileManager removeItemAtPath:[self photoPath] error:&error]) {
            NSLog(@"%@",error);
        }
    }
}

@end
