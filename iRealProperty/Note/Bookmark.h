//
//  Bookmark.h
//  iRealProperty
//
//  Created by Regis Bridon on 8/30/12.
//  Modified by Carlos Venero on 3/01/15.
//  Copyright (c) 2012 to be changed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RealPropInfo;


@interface Bookmark : NSManagedObject

@property (nonatomic) NSTimeInterval addedDate;
//@property (nonatomic)int32_t bookmError;
@property (nonatomic, retain) NSString * descr;
@property (nonatomic, retain) NSString * guid;
@property (nonatomic) BOOL hasError;
@property (nonatomic, retain) NSString * rowStatus;
@property (nonatomic, retain) NSString * rpGuid;
@property (nonatomic) int16_t statusItemId;
//@property (nonatomic) int16_t typeItemId;
//@property (nonatomic) int typeItemId;
@property (nonatomic, retain) NSNumber * typeItemId;

@property (nonatomic, retain) NSString * stagingGUID;
@property (nonatomic) NSTimeInterval updateDate;
@property (nonatomic, retain) NSString * updatedBy;
@property (nonatomic, retain) RealPropInfo *realPropInfo;

@end



