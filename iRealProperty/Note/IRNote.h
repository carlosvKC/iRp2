//
//  IRNote.h
//  iRealProperty
//
//  Created by Regis Bridon on 8/30/12.
//  Copyright (c) 2012 to be changed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

//@class IRLine;
@class IRLine;

@interface IRNote : NSManagedObject

@property (nonatomic, retain) NSString * major;
@property (nonatomic, retain) NSString * minor;
@property (nonatomic, retain) NSString * note;
@property (nonatomic, retain) NSString * parcelNbr;
@property (nonatomic) int32_t realPropId;
@property (nonatomic, retain) NSString * rpGuid;
@property (nonatomic) int32_t type;
@property (nonatomic) NSTimeInterval updateDate;
@property (nonatomic, retain) NSSet *iRLine;
@end

@interface IRNote (CoreDataGeneratedAccessors)

- (void)addIRLineObject:(IRLine *)value;
- (void)removeIRLineObject:(IRLine *)value;
- (void)addIRLine:(NSSet *)values;
- (void)removeIRLine:(NSSet *)values;

@end
