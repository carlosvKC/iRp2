//
//  Inspection.h
//  iRealProperty
//
//  Created by Regis Bridon on 6/21/12.
//  Copyright (c) 2012 to be changed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RealPropInfo;

@interface Inspection : NSManagedObject

    @property (nonatomic) int16_t area;
    @property (nonatomic) int32_t assmtYr;
    @property (nonatomic, retain) NSString * completedBy;
    @property (nonatomic) NSTimeInterval completedDate;
    @property (nonatomic, retain) NSString * guid;
    //@property (nonatomic) int32_t inspectionId;
    @property (nonatomic) int16_t inspectionTypeId;
    @property (nonatomic) int16_t inspectionTypeItemId;
    @property (nonatomic, retain) NSString * rpGuid;
    @property (nonatomic, retain) NSString * rowStatus;
    @property (nonatomic) NSTimeInterval serverUpdateDate;
    @property (nonatomic, retain) NSString * stagingGUID;
    @property (nonatomic) NSTimeInterval updateDate;
    @property (nonatomic, retain) NSString * updatedBy;
    @property (nonatomic, retain) RealPropInfo *realPropInfo;

@end
