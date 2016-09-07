//
//  Configuration.h
//  iRealProperty
//
//  Created by Regis Bridon on 9/21/12.
//  Copyright (c) 2012 to be changed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Configuration : NSManagedObject

@property (nonatomic) BOOL checkAzureFile;
@property (nonatomic, retain) NSString * currentArea;
@property (nonatomic) int32_t downloading;
@property (nonatomic, retain) NSString * fullUserName;
@property (nonatomic, retain) NSString * guid;
@property (nonatomic) NSTimeInterval lastCheckinAzureTime;
@property (nonatomic, retain) NSString * lockingCode;
@property (nonatomic) BOOL menuAtBottom;
@property (nonatomic) NSTimeInterval rendererUpdateDate;
@property (nonatomic) int32_t requiredAfter;
@property (nonatomic, retain) NSString * simpleToken;
@property (nonatomic) BOOL syncImageOver3G;
@property (nonatomic) BOOL syncOver3G;
@property (nonatomic) int32_t useEffects;
@property (nonatomic) int32_t userLevel;
@property (nonatomic, retain) NSString * userName;
@property (nonatomic) int32_t tabToLog;
@property (nonatomic) int32_t  AssmntYrPlusOne; //cv 6/5/16 for use fixVcad use temporarily 

@end
