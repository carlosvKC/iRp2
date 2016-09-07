//
//  LastSynchronization.h
//  iRealProperty
//
//  Created by Regis Bridon on 6/5/12.
//  Copyright (c) 2012 to be changed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface LastSynchronization : NSManagedObject

@property (nonatomic) NSTimeInterval date;
@property (nonatomic) int16_t direction;

@end
