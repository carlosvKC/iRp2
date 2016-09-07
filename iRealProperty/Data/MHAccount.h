//
//  MHAccount.h
//  iRealProperty
//
//  Created by Regis Bridon on 6/21/12.
//  Copyright (c) 2012 to be changed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MHCharacteristic, MHLocation, MediaMobile, RealPropInfo;

@interface MHAccount : NSManagedObject

@property (nonatomic) int16_t acctStatus;
@property (nonatomic) int16_t area;
@property (nonatomic) int32_t bldgNbr;
@property (nonatomic, retain) NSString * imageButton;
@property (nonatomic) NSTimeInterval lastInspectionDate;
@property (nonatomic) int32_t mhType;
@property (nonatomic, retain) NSString * guid;

@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSString * rpGuid;

@property (nonatomic, retain) NSString * rowStatus;
@property (nonatomic) NSTimeInterval serverUpdateDate;
@property (nonatomic, retain) NSString * spaceNbr;
@property (nonatomic, retain) NSString * stagingGUID;
@property (nonatomic) int32_t taxAcctNbr;
@property (nonatomic, retain) NSString * taxPayerName;
@property (nonatomic) BOOL txExempt;
@property (nonatomic) NSTimeInterval updateDate;
@property (nonatomic, retain) NSString * updatedBy;
@property (nonatomic, retain) NSSet *mediaMobile;
@property (nonatomic, retain) MHCharacteristic *mHCharacteristic;
@property (nonatomic, retain) MHLocation *mHLocation;
@property (nonatomic, retain) RealPropInfo *realPropInfo;
@end

@interface MHAccount (CoreDataGeneratedAccessors)

- (void)addMediaMobileObject:(MediaMobile *)value;
- (void)removeMediaMobileObject:(MediaMobile *)value;
- (void)addMediaMobile:(NSSet *)values;
- (void)removeMediaMobile:(NSSet *)values;

- (void)addMHCharObject:(MHCharacteristic *)value;
- (void)addMHLocObject:(MHLocation *)value;

@end
