//
//  IRLine.h
//  iRealProperty
//
//  Created by Regis Bridon on 8/30/12.
//  Copyright (c) 2012 to be changed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class IRNote;

@interface IRLine : NSManagedObject

@property (nonatomic, retain) NSString * color;
@property (nonatomic, retain) NSData * line;
@property (nonatomic) float width;
@property (nonatomic, retain) IRNote *iRNote;

@end
