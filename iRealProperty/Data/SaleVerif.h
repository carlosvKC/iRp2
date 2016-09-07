//
//  SaleVerif.h
//  iRealProperty
//
//  Created by carlos venero on 4/29/14.
//  Copyright (c) 2014 to be changed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Sale;

@interface SaleVerif : NSManagedObject

@property (nonatomic, retain) NSString * guid;
@property (nonatomic, retain) NSString * rowStatus;
@property (nonatomic, retain) NSString * saleGuid;
@property (nonatomic) NSTimeInterval serverUpdateDate;
@property (nonatomic, retain) NSString * stagingGUID;
@property (nonatomic) NSTimeInterval updateDate;
@property (nonatomic, retain) NSString * updatedBy;
@property (nonatomic) int16_t verificationLevel;
@property (nonatomic) NSTimeInterval vYVerifDate;
@property (nonatomic) int16_t vYVerifiedAtMarket;
@property (nonatomic, retain) NSString * vYVerifiedBy;
@property (nonatomic, retain) Sale *sale;
@property (nonatomic) int32_t nonRepComp1;
@property (nonatomic) int32_t nonRepComp2;

@end

