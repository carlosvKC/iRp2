//
//  MHLocation.h
//  iRealProperty
//
//  Created by Regis Bridon on 6/21/12.
//  Copyright (c) 2012 to be changed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MHAccount;

@interface MHLocation : NSManagedObject

@property (nonatomic) int16_t addrUsage;
@property (nonatomic) int16_t area;
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * dirPrefix;
@property (nonatomic, retain) NSString * dirSuffix;
@property (nonatomic, retain) NSString * guid;
@property (nonatomic, retain) NSString * mhGuid;
@property (nonatomic, retain) NSString * nbrFraction;
@property (nonatomic) int32_t parkId;
@property (nonatomic, retain) NSString * rowStatus;
@property (nonatomic) NSTimeInterval serverUpdateDate;
@property (nonatomic, retain) NSString * spaceNbr;
@property (nonatomic, retain) NSString * stagingGUID;
@property (nonatomic, retain) NSString * streetName;
@property (nonatomic, retain) NSString * streetNbr;
@property (nonatomic, retain) NSString * streetType;
@property (nonatomic) NSTimeInterval updateDate;
@property (nonatomic, retain) NSString * updatedBy;
@property (nonatomic, retain) MHAccount *mHAccount;

@end
