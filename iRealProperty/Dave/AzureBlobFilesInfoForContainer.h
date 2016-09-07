//
// Created by David Baun on 9/18/13.
// Copyright (c) 2013 to be changed. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>


@class AzureFileStatusChecker;


@interface AzureBlobFilesInfoForContainer : NSObject <NSURLConnectionDataDelegate>


    @property(nonatomic, strong) NSMutableArray *webRequestedAzureBlobs;
    @property(nonatomic, copy) NSString *containerToRetrieve;


    -(id)initWithContainerName:(NSString *)azureFolderName
              andSecurityToken:(NSString *)securityToken andDelegate:(AzureFileStatusChecker *)delegate;
    -(void)kickoffAzureRequest;

    -(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
    -(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
    -(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
    -(void)connectionDidFinishLoading:(NSURLConnection *)connection;

@end