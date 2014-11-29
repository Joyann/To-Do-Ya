//
//  List.h
//  To-Do-Ya
//
//  Created by joyann on 14/11/6.
//  Copyright (c) 2014年 Joyann. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ListItem;

@interface List : NSManagedObject

@property (nonatomic, retain) NSString * listDescription;
@property (nonatomic, retain) NSString * listImageName;
@property (nonatomic, retain) NSString * listName;
@property (nonatomic, retain) NSSet *items;
@end

@interface List (CoreDataGeneratedAccessors)

- (void)addItemsObject:(ListItem *)value;
- (void)removeItemsObject:(ListItem *)value;
- (void)addItems:(NSSet *)values;
- (void)removeItems:(NSSet *)values;

@end
