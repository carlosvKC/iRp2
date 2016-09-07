//
//  SyncManager.m
//  iRealProperty
//
//  Created by Jorge Chaves on 9/3/12.
//  Copyright (c) 2012 to be changed. All rights reserved.
//

#import "SyncManager.h"


@implementation SyncManager

@synthesize floatReceivedData;
@synthesize delegate;

#pragma - Public Methods

    - (id)initWithServiceURL:(NSString *)serviceURL
               securityToken:(NSString *)token
	{
	    self= [super init];
	    if (self)
	    {
	        downloader = nil;
	        downloadInProgress = NO;
	        dataServiceUrl = serviceURL;
	        securityToken = token;
	    }
	    return self;
	}



	-(void)cancelDownloadAzureFile
	{
	    if (downloader != nil)
	    {
	        [downloader cancelRequest];
	        downloader = nil;
	    }
	}



	// Downloads a file from azure
	//
	//   ..........SAMPLE OF PARAMETERS TO THIS METHOD..........
	//
	//   fileName 		 = Area02.layers.xml
	//   containerName   = Area02
	//   destinyPath     = /Users/davidbaun/Library/Application Support/iPhone Simulator/7.1/Applications/8A2A07B6-725C-4FC2-ADD6-29A398ECEB1C/Documents/Area02/Area02.layers.xml
	//
    - (void)downloadFileFromAzure:(NSString *)fileName
                      inContainer:(NSString *)containerName
                   withFileLength:(unsigned long long)fileLength
                       toThisPath:(NSString *)destinyPath
                 resumingDownload:(BOOL)resumeDownload
	{
	    if (![self isOKStartRequest])
	    {
	        return;
	    }

	    [self loadDownloader];
	    downloader.delegate = self;
	    downloadInProgress = YES;

	    [downloader downloadFile:fileName inContainer:[containerName lowercaseString] inPath:destinyPath withFileLength:fileLength resumingDownload:resumeDownload];
	}


	#pragma mark - Downloader delegate

	    - (void)downloaderDidFail:(Downloader *)d
	                    withError:(NSError *)error
	{
	    downloadInProgress = NO;
	    downloader = nil;
	    [self.delegate downloadAzureFileDidFail:self withError:error];
	}



	// File download is complete
	-(void)downloaderDidLoadData:(Downloader *)d
	{
	    downloadInProgress = NO;
	    downloader = nil;
	    if ([self.delegate respondsToSelector:@selector(downloadAzureFileDidLoadData:)])
	        [self.delegate downloadAzureFileDidLoadData:self];
	}



	-(void)downloaderDidReceiveData:(Downloader *)d
	{
	    floatReceivedData = d.floatReceivedData;
	    if ([self.delegate respondsToSelector:@selector(downloadAzureFileDidReceiveData:)])
	        [self.delegate downloadAzureFileDidReceiveData:self];
	}

	#pragma mark - Downloader private methods

	// Loads the downloader object
	-(void)loadDownloader
	{
	    if (downloader == nil)
	    {
	        downloader = [[Downloader alloc]initWithServiceURL:dataServiceUrl securityToken:securityToken];
	    }
	}



	// Checks if is possible start a request
	-(BOOL)isOKStartRequest
	{
	    if (!downloadInProgress)
	    {
	        return YES ;
	    }
	    return NO;
	}


@end
