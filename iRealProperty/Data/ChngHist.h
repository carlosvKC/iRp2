//
//  ChngHist.h
//  iRealProperty
//
//  Created by Regis Bridon on 6/21/12.
//  Copyright (c) 2012 to be changed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ChngHistDtl, RealPropInfo;

@interface ChngHist : NSManagedObject
    @property (nonatomic) int16_t area;
    @property (nonatomic, retain) NSString * docId;
    @property (nonatomic) NSTimeInterval eventDate;
    @property (nonatomic, retain) NSString * eventPerson;
    @property (nonatomic, retain) NSString * guid;
    @property (nonatomic) int32_t pageCount;
    @property (nonatomic) int32_t propStatus;
    @property (nonatomic, retain) NSString * rpGuid;
    @property (nonatomic, retain) NSString * rowStatus;
    @property (nonatomic) NSTimeInterval serverUpdateDate;
    @property (nonatomic, retain) NSString * stagingGUID;
    @property (nonatomic, retain) NSString * type;
    @property (nonatomic) int16_t typeItemId;
    @property (nonatomic, retain) NSString * unit;
    @property (nonatomic) NSTimeInterval updateDate;
    @property (nonatomic, retain) NSString * updatedBy;
    @property (nonatomic, retain) NSSet *chngHistDtl;
    @property (nonatomic, retain) RealPropInfo *realPropInfo;
@end

@interface ChngHist (CoreDataGeneratedAccessors)

    - (void)addChngHistDtlObject:(ChngHistDtl *)value;
    - (void)removeChngHistDtlObject:(ChngHistDtl *)value;
    - (void)addChngHistDtl:(NSSet *)values;
    - (void)removeChngHistDtl:(NSSet *)values;

@end
