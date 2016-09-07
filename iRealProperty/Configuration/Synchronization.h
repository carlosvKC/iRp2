//
//  Synchronization.h
//  iRealProperty
//
//  Created by George on 7/18/12.
//  Copyright (c) 2012 to be changed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SyncEntity;

@interface Synchronization : NSManagedObject

@property (nonatomic) BOOL pendingSyncToPrep;
@property (nonatomic) NSTimeInterval syncDate;
@property (nonatomic) int16_t syncDirection;
@property (nonatomic, retain) NSString * syncStagingGUID;
@property (nonatomic) int64_t totalRecordsToDownload;
@property (nonatomic, retain) NSSet *entities;
@end

@interface Synchronization (CoreDataGeneratedAccessors)

- (void)addEntitiesObject:(SyncEntity *)value;
- (void)removeEntitiesObject:(SyncEntity *)value;
- (void)addEntities:(NSSet *)values;
- (void)removeEntities:(NSSet *)values;

@end
