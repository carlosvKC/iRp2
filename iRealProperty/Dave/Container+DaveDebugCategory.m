//
// Created by David Baun on 10/9/13.
// Copyright (c) 2013 to be changed. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "Container+DaveDebugCategory.h"
#import "DaveGlobals.h"


@implementation Container (DaveDebugCategory)

-(NSString *)daveDebugDescription
    {

        return [DaveGlobals debugCoreDataContainer:self withTitleMessage:@""];


    }

@end