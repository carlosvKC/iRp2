//
// Created by David Baun on 10/17/13.
// Copyright (c) 2013 to be changed. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "NSObject+DBaunExtensions.h"


@implementation NSObject (DBaunExtensions)

    -(NSString *)descriptionWithMethodName:(NSString *)nameOfMethod
                                  andTitle:(NSString *)titleMessage
        {
            NSMutableString *outputString;

            outputString = [[NSMutableString alloc] initWithCapacity:250];
            [outputString appendString:@"\n"];


            if ([titleMessage length]>0)
                [outputString appendFormat:@"* Title: %@\n",titleMessage];

            if ([nameOfMethod length]>0)
                [outputString appendFormat:@"* Method: %@\n", nameOfMethod];

            [outputString appendString:[self description]];

            return outputString;
        }

@end