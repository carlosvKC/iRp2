//
//  DatabaseDate.h
//  iRealProperty
//
//  Created by George on 8/14/12.
//  Copyright (c) 2012 to be changed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DatabaseDate : NSManagedObject

@property (nonatomic) NSTimeInterval lastUpdateDate;

@end
