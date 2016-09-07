//
//  ValEst.h
//  iRealProperty
//
//  Created by Regis Bridon on 6/21/12.
//  Copyright (c) 2012 to be changed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RealPropInfo;

@interface ValEst : NSManagedObject

@property (nonatomic) int16_t area;
@property (nonatomic) int16_t bldgNbr;
@property (nonatomic) NSTimeInterval estDate;
@property (nonatomic) int16_t estType;
@property (nonatomic, retain) NSString * guid;
@property (nonatomic) int32_t impsVal;
@property (nonatomic) int32_t landVal;
@property (nonatomic) int16_t rollYr;
@property (nonatomic, retain) NSString * rowStatus;
@property (nonatomic) NSTimeInterval serverUpdateDate;
@property (nonatomic, retain) NSString * stagingGUID;
@property (nonatomic) int32_t totalVal;
@property (nonatomic) NSTimeInterval updateDate;
@property (nonatomic, retain) NSString * updatedBy;
@property (nonatomic, retain) NSString * versionNbr;
@property (nonatomic, retain) RealPropInfo *realPropInfo;

@end
