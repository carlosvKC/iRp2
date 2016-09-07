//
//  Land.h
//  iRealProperty
//
//  Created by Regis Bridon on 6/21/12.
//  Copyright (c) 2012 to be changed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

//@class CurrentZoning, EnvRes, MediaLand, RealPropInfo, LandFootage;
@class EnvRes, MediaLand, RealPropInfo, LandFootage;

@interface Land : NSManagedObject
    @property (nonatomic) int16_t access;
    @property (nonatomic) int16_t area;
    @property (nonatomic) int32_t baseLandVal;
    @property (nonatomic) NSTimeInterval baseLandValDate;
    @property (nonatomic, retain) NSDecimalNumber * baseLandValSqFt;
    @property (nonatomic) int16_t baseLandValTaxYr;
    @property (nonatomic) int16_t baseLandValUnit;
    @property (nonatomic) int16_t currentZoning;
    @property (nonatomic, retain) NSString * guid;
    @property (nonatomic) int16_t hBUAsIfVacant;
    @property (nonatomic) int16_t hBUAsImproved;
    @property (nonatomic) int16_t inadequateParking;
    @property (nonatomic) int32_t pcntBaseLandValImpacted;
    @property (nonatomic) int16_t pcntUnusable;
    @property (nonatomic) int16_t presentUse;
    @property (nonatomic) int16_t restrictiveSzShape;
    @property (nonatomic, retain) NSString * rowStatus;
    @property (nonatomic, retain) NSString * rpGuid;
    @property (nonatomic) NSTimeInterval serverUpdateDate;
    @property (nonatomic, retain) NSNumber * sewerSystem;
    @property (nonatomic, retain) NSString * stagingGUID;
    @property (nonatomic) int16_t streetSurface;
    @property (nonatomic) int16_t topography;
    @property (nonatomic) int16_t unbuildable;
    @property (nonatomic) NSTimeInterval updateDate;
    @property (nonatomic, retain) NSString * updatedBy;
    @property (nonatomic) int16_t waterSystem;
    @property (nonatomic) NSTimeInterval zoningChgDate;
//    @property (nonatomic, retain) NSSet *currZoning;
    @property (nonatomic, retain) NSSet *envRes;
    @property (nonatomic, retain) NSSet *mediaLand;
    @property (nonatomic, retain) RealPropInfo *realPropInfo;
@end

@interface Land (CoreDataGeneratedAccessors)
//    - (void)addCurrZoningObject:(CurrentZoning *)value;
//    - (void)removeCurrZoningObject:(CurrentZoning *)value;
//    - (void)addCurrZoning:(NSSet *)values;
//    - (void)removeCurrZoning:(NSSet *)values;

    - (void)addEnvResObject:(EnvRes *)value;
    - (void)removeEnvResObject:(EnvRes *)value;
    - (void)addEnvRes:(NSSet *)values;
    - (void)removeEnvRes:(NSSet *)values;

    - (void)addMediaLandObject:(MediaLand *)value;
    - (void)removeMediaLandObject:(MediaLand *)value;
    - (void)addMediaLand:(NSSet *)values;
    - (void)removeMediaLand:(NSSet *)values;
    //- (void)addResBldg:(NSSet *)values;
    //- (void)removeResBldg:(NSSet *)values;

// 4/29/16 HNN these were not added by coredata because the relationship has to be many. set landfootage.land=land to set relationship instead
//- (void)addLandFootageObject:(LandFootage *)value;
//- (void)removeLandFootageObject:(LandFootage *)value;
//- (void)addLandFootage:(NSSet *)values;
//- (void)removeLandFootage:(NSSet *)values;
@end
