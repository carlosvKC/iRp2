//
//  ReviewJrnl.h
//  iRealProperty
//
//  Created by Regis Bridon on 6/21/12.
//  Copyright (c) 2012 to be changed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Review;

@interface ReviewJrnl : NSManagedObject

@property (nonatomic) int32_t apprImpsVal;
@property (nonatomic) int32_t apprLandVal;
@property (nonatomic) int32_t apprTotalVal;
@property (nonatomic) int16_t area;
@property (nonatomic, retain) NSString * rtGuid;
@property (nonatomic) NSTimeInterval entryDate;
@property (nonatomic, retain) NSString * entryType;
@property (nonatomic) int32_t entryTypeItemId;
@property (nonatomic, retain) NSString * guid;
@property (nonatomic, retain) NSString * rowStatus;
@property (nonatomic) NSTimeInterval serverUpdateDate;
@property (nonatomic, retain) NSString * sourcePerson;
@property (nonatomic, retain) NSString * stagingGUID;
@property (nonatomic, retain) NSString * targetPerson;
@property (nonatomic) NSTimeInterval updateDate;
@property (nonatomic, retain) NSString * updatedBy;
@property (nonatomic, retain) Review *review;

@end
