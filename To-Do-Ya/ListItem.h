//
//  ListItem.h
//  To-Do-Ya
//
//  Created by joyann on 14/11/6.
//  Copyright (c) 2014年 Joyann. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>

@class List;

@interface ListItem : NSManagedObject

@property (nonatomic, retain) NSDate * itemDate;
@property (nonatomic, retain) NSString * itemDescription;
@property (nonatomic, retain) NSString * itemName;
@property (nonatomic, retain) NSNumber * itemPhotoID;
@property (nonatomic, retain) NSNumber * itemNotificationID;
@property (nonatomic, retain) NSNumber * itemIsRemind;
@property (nonatomic, retain) List *whoTake;

+ (NSInteger)nextPhotoID;
- (BOOL)hasPhoto;
- (NSString *)photoPath;
- (UIImage *)getPhoto;
- (void)removePhotoFile;

+ (NSInteger)nextNotificationID;

@end
