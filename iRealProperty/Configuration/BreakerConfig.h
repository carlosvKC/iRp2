//
//  BreakerConfig.h
//  iRealProperty
//
//  Created by Regis Bridon on 6/5/12.
//  Copyright (c) 2012 to be changed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RendererConfig;

@interface BreakerConfig : NSManagedObject

@property (nonatomic, retain) NSString * color;
@property (nonatomic) int32_t fill;
@property (nonatomic, retain) NSString * label;
@property (nonatomic, retain) NSString * value;
@property (nonatomic, retain) RendererConfig *rendererConfig;

@end
