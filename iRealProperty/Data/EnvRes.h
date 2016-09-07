//
//  EnvRes.h
//  iRealProperty
//
//  Created by carlos venero on 8/29/13.
//  Copyright (c) 2013 to be changed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Land;

@interface EnvRes : NSManagedObject

@property (nonatomic, retain) NSNumber * area;
@property (nonatomic, retain) NSNumber * attributeId;
@property (nonatomic, retain) NSNumber * delineationStudy;
@property (nonatomic, retain) NSString * guid;
@property (nonatomic, retain) NSString * lndGuid;
@property (nonatomic, retain) NSNumber * lUSourceItem;
@property (nonatomic, retain) NSNumber * pcntAffected;
@property (nonatomic, retain) NSString * rowStatus;
@property (nonatomic) NSTimeInterval serverUpdateDate;
@property (nonatomic, retain) NSString * stagingGUID;
@property (nonatomic) NSTimeInterval updateDate;
@property (nonatomic, retain) NSString * updatedBy;
@property (nonatomic, retain) NSNumber * valPct;
@property (nonatomic, retain) Land *land;

@end
