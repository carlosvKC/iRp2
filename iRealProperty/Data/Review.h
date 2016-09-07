//
//  Review.h
//  iRealProperty
//
//  Created by Regis Bridon on 6/21/12.
//  Copyright (c) 2012 to be changed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class NoteReview, RealPropInfo, ReviewJrnl;

@interface Review : NSManagedObject
    @property (nonatomic, retain) NSString * agent;
    @property (nonatomic) int32_t appealedValue;
    @property (nonatomic, retain) NSString * appealNbr;
    @property (nonatomic) int16_t area;
    @property (nonatomic, retain) NSString * guid;
    @property (nonatomic) int16_t billYr;
    @property (nonatomic) NSTimeInterval hearingDate;
    @property (nonatomic, retain) NSString * hearingInfo;
    @property (nonatomic, retain) NSString * hearingLoc;
    @property (nonatomic, retain) NSString * hearingResult;
    @property (nonatomic, retain) NSString * noteGuid;
    @property (nonatomic) NSTimeInterval orderDate;
    @property (nonatomic, retain) NSString * rpGuid;
    @property (nonatomic, retain) NSString * relatedAppealNbr;
    @property (nonatomic, retain) NSString * respAppr;
    @property (nonatomic, retain) NSString * reviewSource;
    @property (nonatomic) int16_t reviewType;
    @property (nonatomic, retain) NSString * rowStatus;
    @property (nonatomic) NSTimeInterval serverUpdateDate;
    @property (nonatomic) int32_t settlementValue;
    @property (nonatomic, retain) NSString * stagingGUID;
    @property (nonatomic, retain) NSString * statusAssessor;
    @property (nonatomic) int16_t statusAssmtReview;
    @property (nonatomic, retain) NSString * statusBoard;
    @property (nonatomic, retain) NSString * statusStipulation;
    @property (nonatomic, retain) NSString * taxpayername;
    @property (nonatomic, retain) NSString * unit;
    @property (nonatomic) NSTimeInterval updateDate;
    @property (nonatomic, retain) NSString * updatedBy;
    @property (nonatomic, retain) NSSet *noteReview;
    @property (nonatomic, retain) RealPropInfo *realPropInfo;
    @property (nonatomic, retain) NSSet *reviewJrnl;
@end


@interface Review (CoreDataGeneratedAccessors)
    - (void)addNoteReviewObject:(NoteReview *)value;
    - (void)removeNoteReviewObject:(NoteReview *)value;
    - (void)addNoteReview:(NSSet *)values;
    - (void)removeNoteReview:(NSSet *)values;

    - (void)addReviewJrnlObject:(ReviewJrnl *)value;
    - (void)removeReviewJrnlObject:(ReviewJrnl *)value;
    - (void)addReviewJrnl:(NSSet *)values;
    - (void)removeReviewJrnl:(NSSet *)values;
@end
