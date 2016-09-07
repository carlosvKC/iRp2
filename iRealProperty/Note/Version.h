//
//  Version.h
//  iRealProperty
//
//  Created by Regis Bridon on 9/4/12.
//  Copyright (c) 2012 to be changed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Version : NSManagedObject

@property (nonatomic, retain) NSString * version;
@property (nonatomic) NSTimeInterval installed;

@end
