//
//  ValHist.h
//  iRealProperty
//
//  Created by Regis Bridon on 6/21/12.
//  Copyright (c) 2012 to be changed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RealPropInfo;

@interface ValHist : NSManagedObject

@property (nonatomic) int32_t apprImpIncrease;
@property (nonatomic) int32_t apprImpsVal;
@property (nonatomic) int32_t apprLandVal;
@property (nonatomic) int16_t area;
@property (nonatomic) int32_t billYr;
@property (nonatomic) NSTimeInterval changeDate;
@property (nonatomic, retain) NSString * changeDocId;
@property (nonatomic, retain) NSString * guid;
@property (nonatomic) int32_t impsVal;
@property (nonatomic) int32_t landVal;
@property (nonatomic, retain) NSString * levyCode;
@property (nonatomic) int16_t omitYr;
@property (nonatomic, retain) NSString * reason;
@property (nonatomic, retain) NSString * rowStatus;
@property (nonatomic) NSTimeInterval serverUpdateDate;
@property (nonatomic, retain) NSString * splitCode;
@property (nonatomic, retain) NSString * stagingGUID;
@property (nonatomic, retain) NSString * taxStatus;
@property (nonatomic, retain) NSString * taxValReason;
@property (nonatomic) int32_t totalApprVal;
@property (nonatomic) int32_t totalVal;
@property (nonatomic, retain) NSString * unit;
@property (nonatomic, retain) RealPropInfo *realPropInfo;

@end
