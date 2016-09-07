//
//  FilesSync.h
//  iRealProperty
//
//  Created by Regis Bridon on 6/20/12.
//  Copyright (c) 2012 to be changed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface FilesSync : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic) int64_t length;
@property (nonatomic) NSTimeInterval updateDate;
@property (nonatomic, retain) NSString * eTag;
@property (nonatomic, retain) NSString * area;

@end
