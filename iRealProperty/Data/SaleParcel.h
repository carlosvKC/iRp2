//
//  SaleParcel.h
//  iRealProperty
//
//  Created by Regis Bridon on 6/21/12.
//  Copyright (c) 2012 to be changed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RealPropInfo, Sale;

@interface SaleParcel : NSManagedObject
    @property (nonatomic) int16_t area;
    @property (nonatomic, retain) NSString * guid;
    @property (nonatomic, retain) NSString * parcel;
    @property (nonatomic, retain) NSString * rpGuid;
    @property (nonatomic, retain) NSString * rowStatus;
    @property (nonatomic, retain) NSString * saleGuid;
    @property (nonatomic) NSTimeInterval serverUpdateDate;
    @property (nonatomic, retain) NSString * stagingGUID;
    @property (nonatomic, retain) RealPropInfo *realPropInfo;
    @property (nonatomic, retain) Sale *sale;
@end
