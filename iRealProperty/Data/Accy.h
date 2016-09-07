//
//  Accy.h
//  iRealProperty
//
//  Created by Regis Bridon on 6/21/12.
//  Modified by Carlos Venero on 2/1/2015
//  Copyright (c) 2012 to be changed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MediaAccy, RealPropInfo;

@interface Accy : NSManagedObject

@property (nonatomic, retain) NSString * accyDescr;
@property (nonatomic) int16_t accyType;
@property (nonatomic) int32_t accyValue;
@property (nonatomic) int16_t area;
@property (nonatomic) NSTimeInterval dateValued;
@property (nonatomic) int16_t effYr;
@property (nonatomic) int16_t grade;
@property (nonatomic, retain) NSString * guid;
@property (nonatomic) int16_t nbrThisType;
@property (nonatomic) int16_t pcntNetCondition;
@property (nonatomic, retain) NSString * rowStatus;
@property (nonatomic) NSTimeInterval serverUpdateDate;
@property (nonatomic) int32_t size;
@property (nonatomic, retain) NSString * stagingGUID;
@property (nonatomic) int16_t unitOfMeasure;
@property (nonatomic) NSTimeInterval updateDate;
@property (nonatomic, retain) NSString * updatedBy;
@property (nonatomic, retain) NSString * rpGuid;
@property (nonatomic, retain)NSString * bldgGuid;

@property (nonatomic, retain) NSSet *mediaAccy;
@property (nonatomic, retain) RealPropInfo *realPropInfo;
@end

@interface Accy (CoreDataGeneratedAccessors)

- (void)addMediaAccyObject:(MediaAccy *)value;
- (void)removeMediaAccyObject:(MediaAccy *)value;
- (void)addMediaAccy:(NSSet *)values;
- (void)removeMediaAccy:(NSSet *)values;

@end
