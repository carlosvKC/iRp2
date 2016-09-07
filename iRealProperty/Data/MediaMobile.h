//
//  MediaMobile.h
//  iRealProperty
//
//  Created by Regis Bridon on 6/21/12.
//  Copyright (c) 2012 to be changed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MHAccount;

@interface MediaMobile : NSManagedObject

@property (nonatomic) BOOL active;
@property (nonatomic) int16_t area;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSString * guid;
@property (nonatomic) int16_t imageType;
@property (nonatomic) NSTimeInterval mediaDate;
//@property (nonatomic) int32_t mediaId;
//@property (nonatomic, retain) NSString * mediaLoc;
@property (nonatomic) int16_t mediaType;
@property (nonatomic) int16_t order;
@property (nonatomic) BOOL postToWeb;
@property (nonatomic) int16_t primary;
@property (nonatomic, retain) NSString * mhGuid;
@property (nonatomic, retain) NSString * rowStatus;
@property (nonatomic) NSTimeInterval serverUpdateDate;
@property (nonatomic, retain) NSString * stagingGUID;
//@property (nonatomic) BOOL thumbnail;
@property (nonatomic) NSTimeInterval updateDate;
@property (nonatomic, retain) NSString * updatedBy;
@property (nonatomic) int16_t year;
@property (nonatomic, retain) MHAccount *mHAccount;

@end
