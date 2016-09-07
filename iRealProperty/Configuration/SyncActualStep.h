//
//  SyncActualStep.h
//  iRealProperty
//
//  Created by Jorge Chaves on 10/2/12.
//  Copyright (c) 2012 to be changed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface SyncActualStep : NSManagedObject

@property (nonatomic) int16_t actualStep;
@property (nonatomic) NSTimeInterval endDate;
@property (nonatomic, retain) NSString * stagingGuid;
@property (nonatomic) NSTimeInterval startDate;
@property (nonatomic) double serverSyncDate;

@end
