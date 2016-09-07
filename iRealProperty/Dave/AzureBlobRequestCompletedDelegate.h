//
// Created by David Baun on 9/26/13.
// Copyright (c) 2013 to be changed. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>


@class AzureBlobFilesInfoForContainer;


@protocol AzureBlobRequestCompletedDelegate <NSObject>

    -(void)processTheRequestedBlobs:(AzureBlobFilesInfoForContainer *)theBlobRequestResults;

@end