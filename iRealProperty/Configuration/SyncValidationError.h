//
//  SyncValidationError.h
//  iRealProperty
//
//  Created by Regis Bridon on 8/22/12.
//  Copyright (c) 2012 to be changed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface SyncValidationError : NSManagedObject

@property (nonatomic) NSTimeInterval date;
@property (nonatomic, retain) NSString * entityGuid;
@property (nonatomic, retain) NSString * entityKind;
@property (nonatomic, retain) NSString * errorMsg;
@property (nonatomic, retain) NSString * syncGuid;
@property (nonatomic, retain) NSString * area;

@end
