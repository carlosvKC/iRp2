//
//  PermitDtl.h
//  iRealProperty
//
//  Created by Regis Bridon on 6/21/12.
//  Copyright (c) 2012 to be changed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Permit;

@interface PermitDtl : NSManagedObject

@property (nonatomic) int16_t area;
@property (nonatomic, retain) NSString * guid;
//@property (nonatomic) NSTimeInterval issueDate;
@property (nonatomic, retain) NSString * itemValue;
@property (nonatomic) int32_t permitItem;
@property (nonatomic, retain) NSString * permitGuid;
@property (nonatomic, retain) NSString * rowStatus;
@property (nonatomic) NSTimeInterval serverUpdateDate;
@property (nonatomic, retain) NSString * stagingGUID;
@property (nonatomic) NSTimeInterval updateDate;
@property (nonatomic, retain) NSString * updatedBy;
@property (nonatomic, retain) Permit *permit;

@end
