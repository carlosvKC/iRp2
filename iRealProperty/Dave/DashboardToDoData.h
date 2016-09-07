//
//  DashboardToDoData.h
//  MyDashboardCode
//
//  Created by David Baun on 4/8/14.
//  Copyright (c) 2014 None Yo Bizness. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DashboardToDoData : NSObject //<DashboardToDoTableViewDelegate>


    // NOTE: An int is not an NSObject, so 'retain' does not apply.  Retain is only for NSObjects. 

    // AssmtYr can be found in these spots...
    //   inspection.assmtYr
    //   [RealPropertyApp taxYear]-1;

    @property (nonatomic, retain) NSArray* toDoItems;
    @property (nonatomic, retain) NSManagedObjectContext* managedObjectContext;


    -(NSArray *)theToDoItemsforAssmtYr:(int32_t)theYear
                         andRealPropId:(int32_t)theRealPropId
                         andRpGuid:(NSString*)theRpGuid
                        andLndGuid:(NSString*)theLndGuid
                           andPropType:(NSString*)thePropType
                    withManagedContext:(NSManagedObjectContext*)theContext;

   // -(void)toDoListSelectedItem:(NSString *)item;


@end
