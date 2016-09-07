//
//  RendererConfig.h
//  iRealProperty
//
//  Created by Regis Bridon on 6/5/12.
//  Copyright (c) 2012 to be changed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BreakerConfig;

@interface RendererConfig : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *breakerConfig;
@end

@interface RendererConfig (CoreDataGeneratedAccessors)

- (void)addBreakerConfigObject:(BreakerConfig *)value;
- (void)removeBreakerConfigObject:(BreakerConfig *)value;
- (void)addBreakerConfig:(NSSet *)values;
- (void)removeBreakerConfig:(NSSet *)values;

@end
