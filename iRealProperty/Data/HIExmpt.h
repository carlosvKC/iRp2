//
//  HIExmpt.h
//  iRealProperty
//
//  Created by Regis Bridon on 6/21/12.
//  Copyright (c) 2012 to be changed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class NoteHIExmpt, RealPropInfo;

@interface HIExmpt : NSManagedObject

@property (nonatomic) BOOL appMobile;
@property (nonatomic) BOOL appOwnLand;
@property (nonatomic) BOOL approved;
@property (nonatomic, retain) NSString * approvedBy;
@property (nonatomic) NSTimeInterval approvedDate;
@property (nonatomic) BOOL appSigned;
@property (nonatomic) int16_t area;
@property (nonatomic, retain) NSString * bldgGuid;
@property (nonatomic) BOOL destroyedProperty;
@property (nonatomic) NSTimeInterval estCompletionDate;
@property (nonatomic) int32_t estCost;
@property (nonatomic) int16_t firstBillYr;
@property (nonatomic, retain) NSString * guid;
@property (nonatomic) int32_t homeImpVal;
@property (nonatomic) int16_t lastBillYr;
@property (nonatomic) BOOL lateApplication;
@property (nonatomic, retain) NSString * maintOrReplace;
@property (nonatomic) BOOL multipleDwellings;
@property (nonatomic) BOOL newConstr;
@property (nonatomic) BOOL newDwellingUnit;
@property (nonatomic) BOOL nonDwellingUnit;
@property (nonatomic, retain) NSString * rpGuid;
@property (nonatomic) int32_t pageCount;
@property (nonatomic) int16_t permitDistrictId;
@property (nonatomic) BOOL personalProperty;
@property (nonatomic) BOOL priorExemption;
@property (nonatomic) NSTimeInterval receivedDate;
@property (nonatomic, retain) NSString * rowStatus;
@property (nonatomic) NSTimeInterval serverUpdateDate;
@property (nonatomic, retain) NSString * stagingGUID;
@property (nonatomic) NSTimeInterval updateDate;
@property (nonatomic, retain) NSString * updatedBy;
@property (nonatomic) NSTimeInterval valueDate;
@property (nonatomic, retain) NSString * valuedBy;
@property (nonatomic, retain) NSSet *noteHIExmpt;
@property (nonatomic, retain) RealPropInfo *realPropInfo;
@end

@interface HIExmpt (CoreDataGeneratedAccessors)

- (void)addNoteHIExmptObject:(NoteHIExmpt *)value;
- (void)removeNoteHIExmptObject:(NoteHIExmpt *)value;
- (void)addNoteHIExmpt:(NSSet *)values;
- (void)removeNoteHIExmpt:(NSSet *)values;

@end
