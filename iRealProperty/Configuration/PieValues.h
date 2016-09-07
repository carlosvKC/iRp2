//
//  PieValues.h
//  iRealProperty
//
//  Created by Regis Bridon on 8/30/12.
//  Copyright (c) 2012 to be changed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface PieValues : NSManagedObject

@property (nonatomic, retain) NSString * keyName;
@property (nonatomic) int32_t value;
@property (nonatomic, retain) NSString * area;

@end
