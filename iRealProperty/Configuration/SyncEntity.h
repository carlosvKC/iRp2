//
//  SyncEntity.h
//  iRealProperty
//
//  Created by George on 7/17/12.
//  Copyright (c) 2012 to be changed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Synchronization;

@interface SyncEntity : NSManagedObject

@property (nonatomic, retain) NSString * entityKind;
@property (nonatomic) int32_t position;
@property (nonatomic) int16_t syncStatus;
@property (nonatomic, retain) NSString * jsonEntities;
@property (nonatomic, retain) Synchronization *sync;

@end
