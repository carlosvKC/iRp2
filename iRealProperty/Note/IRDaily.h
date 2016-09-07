//
//  IRDaily.h
//  iRealProperty
//
//  Created by Regis Bridon on 8/30/12.
//  Copyright (c) 2012 to be changed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface IRDaily : NSManagedObject

@property (nonatomic) NSTimeInterval addedDate;
@property (nonatomic, retain) NSString * major;
@property (nonatomic, retain) NSString * minor;
@property (nonatomic) int32_t realPropId;

@end
