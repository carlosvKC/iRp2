//
//  ApplHist.h
//  iRealProperty
//
//  Created by Regis Bridon on 6/21/12.
//  Copyright (c) 2012 to be changed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RealPropInfo;

@interface ApplHist : NSManagedObject

    @property (nonatomic) int16_t area;
    @property (nonatomic, retain) NSString * guid;
    @property (nonatomic) BOOL hasNote;
    @property (nonatomic) int32_t impsVal;
    @property (nonatomic) int32_t landVal;
    @property (nonatomic) NSTimeInterval mFInterfaceDate;
    @property (nonatomic) int16_t mFInterfaceFlag;
    @property (nonatomic) int32_t newConstrVal;
    @property (nonatomic, retain) NSDecimalNumber * pcntChng;
    @property (nonatomic) int32_t post_Code;
    @property (nonatomic, retain) NSString * rpGuid;
    @property (nonatomic, retain) NSString * revalOrMaint;
    @property (nonatomic) int16_t rollYr;
    @property (nonatomic, retain) NSString * rowStatus;
    @property (nonatomic, retain) NSString * selectAppr;
    @property (nonatomic) NSTimeInterval selectDate;
    @property (nonatomic) int16_t selectMethod;
    @property (nonatomic) int16_t selectReason;
    @property (nonatomic) NSTimeInterval serverUpdateDate;
    @property (nonatomic, retain) NSString * stagingGUID;
    @property (nonatomic) int32_t totalVal;
    @property (nonatomic) NSTimeInterval updateDate;
    @property (nonatomic, retain) NSString * updatedBy;
    @property (nonatomic, retain) RealPropInfo *realPropInfo;

@end
