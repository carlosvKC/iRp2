//
//  Blob.h
//  iRealProperty
//
//  Created by Regis Bridon on 8/30/12.
//  Copyright (c) 2012 to be changed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Container;

@interface Blob : NSManagedObject

@property (nonatomic, retain) NSString * contentType;
@property (nonatomic) float downloaded;
@property (nonatomic, retain) NSString * eTag;
@property (nonatomic, retain) NSString * lastModifiedDate;
@property (nonatomic, retain) NSString * leaseStatus;
@property (nonatomic) int64_t length;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) Container *container;

@end
