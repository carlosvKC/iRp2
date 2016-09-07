//
//  MHCharacteristic.h
//  iRealProperty
//
//  Created by Regis Bridon on 6/21/12.
//  Copyright (c) 2012 to be changed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MHAccount;

@interface MHCharacteristic : NSManagedObject

@property (nonatomic) int16_t area;
@property (nonatomic) int16_t class_;
@property (nonatomic) int16_t condition;
@property (nonatomic, retain) NSString * guid;
@property (nonatomic) int32_t length;
@property (nonatomic) int32_t livingArea;
@property (nonatomic, retain) NSString * makeModel;
@property (nonatomic) int32_t mhType;
@property (nonatomic, retain) NSString * mhGuid;
@property (nonatomic) int32_t pcntNetCondition;
@property (nonatomic) int32_t roomAddSqft;
@property (nonatomic, retain) NSString * rowStatus;
@property (nonatomic, retain) NSString * serialNbrVin;
@property (nonatomic) NSTimeInterval serverUpdateDate;
@property (nonatomic) int32_t size;
@property (nonatomic, retain) NSString * stagingGUID;
@property (nonatomic) int32_t tipOutArea;
@property (nonatomic) NSTimeInterval updateDate;
@property (nonatomic, retain) NSString * updatedBy;
@property (nonatomic) int32_t width;
@property (nonatomic) int16_t yrBuilt;
@property (nonatomic, retain) MHAccount *mHAccount;

@end
