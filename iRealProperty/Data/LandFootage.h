//
//  LandFootage.h
//  iRealProperty
//
//  Created by carlos venero on 4/2/14.
//  Copyright (c) 2014 to be changed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Land;

@interface LandFootage : NSManagedObject
@property (nonatomic, retain) NSString * guid;
@property (nonatomic, retain) NSString * rowStatus;
@property (nonatomic) NSTimeInterval serverUpdateDate;
@property (nonatomic, retain) NSNumber * sqFtLot;
@property (nonatomic, retain) NSNumber * sqFtLotDry;
@property (nonatomic, retain) NSNumber * sqFtLotSubmerged;
@property (nonatomic, retain) NSString * stagingGUID;
@property (nonatomic) NSTimeInterval updateDate;
@property (nonatomic, retain) NSString * updatedBy;
@property (nonatomic, retain) Land *land;

@end
