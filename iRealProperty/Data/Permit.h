//
//  Permit.h
//  iRealProperty
//
//  Created by Regis Bridon on 6/21/12.
//  Copyright (c) 2012 to be changed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PermitDtl, RealPropInfo;

@interface Permit : NSManagedObject
    @property (nonatomic) int16_t area;
    @property (nonatomic, retain) NSString * guid;
    @property (nonatomic) NSTimeInterval issueDate;
    @property (nonatomic, retain) NSString * issuingJurisdiction;
    @property (nonatomic) NSTimeInterval jurisInspectDate;
    @property (nonatomic, retain) NSString * jurisInspectStat;
    @property (nonatomic) int16_t pcntComplete;
    @property (nonatomic, retain) NSString * permitDescr;
    @property (nonatomic, retain) NSString * permitNbr;
    @property (nonatomic) int32_t permitStatus;
    @property (nonatomic) int32_t permitType;
    @property (nonatomic) int32_t permitVal;
    @property (nonatomic, retain) NSString * rpGuid;
    @property (nonatomic, retain) NSString * reviewedBy;
    @property (nonatomic) NSTimeInterval reviewedDate;
    @property (nonatomic, retain) NSString * rowStatus;
    @property (nonatomic) NSTimeInterval serverUpdateDate;
    @property (nonatomic, retain) NSString * stagingGUID;
    @property (nonatomic, retain) NSString * unit;
    @property (nonatomic) NSTimeInterval updateDate;
    @property (nonatomic, retain) NSString * updatedBy;
    @property (nonatomic, retain) NSSet *permitDtl;
    @property (nonatomic, retain) RealPropInfo *realPropInfo;
@end

@interface Permit (CoreDataGeneratedAccessors)

    - (void)addPermitDtlObject:(PermitDtl *)value;
    - (void)removePermitDtlObject:(PermitDtl *)value;
    - (void)addPermitDtl:(NSSet *)values;
    - (void)removePermitDtl:(NSSet *)values;

@end
