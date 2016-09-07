//
//  SaleParcels.h
//  iRealProperty
//
//  Created by Regis iPad Dev Team on 2/13/12.
//  Copyright (c) 2012 to be changed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Sale;

@interface SaleParcels : NSManagedObject

@property (nonatomic, retain) NSString * parcel;
@property (nonatomic) int32_t realPropId;
@property (nonatomic) int32_t saleId;
@property (nonatomic, retain) Sale *sale;

@end
