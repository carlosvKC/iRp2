//
//  ImageToDownload.h
//  iRealProperty
//
//  Created by Regis Bridon on 8/29/12.
//  modified by Carlos Venero on 3/15/2015
//  Copyright (c) 2012 to be changed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ImageToDownload : NSManagedObject

@property (nonatomic, retain) NSString * entityGuid;
@property (nonatomic, retain) NSString * entityKind;
@property (nonatomic, retain) NSString * errorMessage;
@property (nonatomic, retain) NSString * fileName;
@property (nonatomic, retain) NSString * ext;
@property (nonatomic) int16_t  mediaType;
//@property (nonatomic, retain) NSNumber * mediaType;
//@property (nonatomic) NSInteger * mediaType;
@end
