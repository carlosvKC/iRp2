//
//  ParcelAssignment.h
//  iRealProperty
//
//  Created by carlos venero on 4/21/14.
//  Copyright (c) 2014 to be changed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RealPropInfo;

@interface ParcelAssignment : NSManagedObject


@property (nonatomic, retain) NSString * assignedTo;
@property (nonatomic, retain) NSNumber * assmtYr;
@property (nonatomic, retain) NSString * guid;
@property (nonatomic, retain) NSString * rpguid;
@property (nonatomic, retain) NSString * rowStatus;
@property (nonatomic, retain) NSDate * serverUpdateDate;
@property (nonatomic, retain) NSString * stagingGUID;
@property (nonatomic, retain) NSDate * updateDate;
@property (nonatomic, retain) NSString * updatedBy;
@property (nonatomic, retain) RealPropInfo *realpropinfo;

@end
