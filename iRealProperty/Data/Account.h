//
//  Account.h
//  iRealProperty
//
//  Created by Regis Bridon on 6/21/12.
//  Copyright (c) 2012 to be changed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RealPropInfo;

@interface Account : NSManagedObject

@property (nonatomic, retain) NSString * acct;
@property (nonatomic) int16_t area;
@property (nonatomic, retain) NSString * guid;
@property (nonatomic, retain) NSString * rowStatus;
@property (nonatomic) NSTimeInterval serverUpdateDate;
@property (nonatomic, retain) NSString * stagingGUID;
@property (nonatomic, retain) RealPropInfo *realPropInfo;

@end
