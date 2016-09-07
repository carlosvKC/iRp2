//
//  ResBldg.h
//  iRealProperty
//
//  Created by Regis Bridon on 6/21/12.
//  Copyright (c) 2012 to be changed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

//@class Land, MediaBldg;
@class RealPropInfo, MediaBldg;

@interface ResBldg : NSManagedObject

@property (nonatomic) int32_t addnlCost;
@property (nonatomic) int16_t area;
@property (nonatomic) int16_t bath3qtrCount;
@property (nonatomic) int16_t bathFullCount;
@property (nonatomic) int16_t bathHalfCount;
@property (nonatomic) int16_t bedrooms;
@property (nonatomic) int16_t bldgGrade;
@property (nonatomic) int16_t bldgGradeVar;
@property (nonatomic, retain) NSString * guid;
@property (nonatomic) int16_t bldgNbr;
@property (nonatomic) int16_t brickStone;
@property (nonatomic) int16_t condition;
@property (nonatomic) BOOL daylightBasement;
@property (nonatomic) int16_t finBasementGrade;
@property (nonatomic) int16_t fpAdditional;
@property (nonatomic) int16_t fpFreeStanding;
@property (nonatomic) int16_t fpMultiStory;
@property (nonatomic) int16_t fpSingleStory;
@property (nonatomic) int16_t heatSource;
@property (nonatomic) int16_t heatSystem;
@property (nonatomic, retain) NSString * nbrFraction;
@property (nonatomic) int16_t nbrLivingUnits;
@property (nonatomic) int16_t obsolescence;
@property (nonatomic) int16_t pcntComplete;
@property (nonatomic) int16_t pcntNetCondition;
@property (nonatomic, retain) NSString * rpGuid;
@property (nonatomic, retain) NSString * rowStatus;
@property (nonatomic) NSTimeInterval serverUpdateDate;
@property (nonatomic) int32_t sqFt1stFloor;
@property (nonatomic) int32_t sqFt2ndFloor;
@property (nonatomic) int32_t sqFtDeck;
@property (nonatomic) int32_t sqFtEnclosedPorch;
@property (nonatomic) int32_t sqFtFinBasement;
@property (nonatomic) int32_t sqFtGarageAttached;
@property (nonatomic) int32_t sqFtGarageBasement;
@property (nonatomic) int32_t sqFtHalfFloor;
@property (nonatomic) int32_t sqFtOpenPorch;
@property (nonatomic) int32_t sqFtTotBasement;
@property (nonatomic) int32_t sqFtTotLiving;
@property (nonatomic) int32_t sqFtUnFinFull;
@property (nonatomic) int32_t sqFtUnFinHalf;
@property (nonatomic) int32_t sqFtUpperFloor;
@property (nonatomic, retain) NSString * stagingGUID;
@property (nonatomic) float stories;
@property (nonatomic, retain) NSString * street;
@property (nonatomic) int32_t streetId;
@property (nonatomic, retain) NSString * streetNbr;
@property (nonatomic, retain) NSString * unitDesc;
@property (nonatomic) NSTimeInterval updateDate;
@property (nonatomic, retain) NSString * updatedBy;
@property (nonatomic) BOOL viewUtilization;
@property (nonatomic) int16_t yrBuilt;
@property (nonatomic) int16_t yrRenovated;
@property (nonatomic, retain) NSString * zipCode;
//@property (nonatomic, retain) Land *land;
@property (nonatomic, retain) RealPropInfo *realpropInfo;
@property (nonatomic, retain) NSSet *mediaBldg;
@end

@interface ResBldg (CoreDataGeneratedAccessors)

- (void)addMediaBldgObject:(MediaBldg *)value;
- (void)removeMediaBldgObject:(MediaBldg *)value;
- (void)addMediaBldg:(NSSet *)values;
- (void)removeMediaBldg:(NSSet *)values;

@end
