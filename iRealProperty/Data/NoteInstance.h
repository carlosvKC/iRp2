//
//  NoteInstance.h
//  iRealProperty
//
//  Created by Regis Bridon on 6/21/12.
//  Copyright (c) 2012 to be changed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MediaNote;

@interface NoteInstance : NSManagedObject

@property (nonatomic) int16_t area;
@property (nonatomic, retain) NSString * guid;
@property (nonatomic, retain) NSString * note;
@property (nonatomic, retain) NSString * rowStatus;
@property (nonatomic) NSTimeInterval serverUpdateDate;
@property (nonatomic, retain) NSString * src;
@property (nonatomic, retain) NSString * srcGuid;

@property (nonatomic, retain) NSString * stagingGUID;
@property (nonatomic, retain) NSString * unit;
@property (nonatomic) NSTimeInterval updateDate;
@property (nonatomic, retain) NSString * updatedBy;
@property (nonatomic, retain) NSSet *mediaNote;
@end

@interface NoteInstance (CoreDataGeneratedAccessors)

- (void)addMediaNoteObject:(MediaNote *)value;
- (void)removeMediaNoteObject:(MediaNote *)value;
- (void)addMediaNote:(NSSet *)values;
- (void)removeMediaNote:(NSSet *)values;

@end
