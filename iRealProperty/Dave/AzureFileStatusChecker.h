//
// Created by David Baun on 9/21/13.
// Copyright (c) 2013 none yo business. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "AzureBlobRequestCompletedDelegate.h"


@interface AzureFileStatusChecker : NSObject  <AzureBlobRequestCompletedDelegate>

    // Dont need to pass in an area name.  That's already computable inside the method.
    //-(void)checkForChangedFilesInArea:(NSString *)areaName andNotifyDelegate:theDelegate;


    -(void)checkForChangedFilesInAreaAndNotifyDelegate:(id)theDelegate;


    -(void)processTheRequestedBlobs:(AzureBlobFilesInfoForContainer *)theBlobRequestResults;

@end