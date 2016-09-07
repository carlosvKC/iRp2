#import "Downloader.h"
#import "Helper.h"

@implementation Downloader

    @synthesize delegate;
    @synthesize securityToken;
    @synthesize floatReceivedData;
    @synthesize azureContainerName, azureBlobName;



    - (id)initWithServiceURL:(NSString *)serviceURL
               securityToken:(NSString *)token
        {
            self = [super init];
            if (self)
                {
                    dataServiceURL = serviceURL;
                    securityToken  = token;
                }
            return self;
        }



    //
    // Request the blob file.
    //
    //   ..........SAMPLE OF PARAMETERS TO THIS METHOD..........
    //
    //   blobName 		 = Area02.layers.xml
    //   containerName   = Area02
    //   path            = /Users/davidbaun/Library/Application Support/iPhone Simulator/7.1/.../Documents/Area02/Area02.layers.xml
    //
    //   ..........SAMPLE OF *myRequest URL..........
    //
    //   http://blue.kingcounty.gov/Assessor/iRealPropertyProxy/iRealPropertyProxy.svc/GetBlobHeaderInformation?type='downloadblob'&Container='area02'&Blob='Area02.layers.xml'&offSet=0&endByte=0
    //
    - (void)downloadFile:(NSString *)blobName
             inContainer:(NSString *)containerName
                  inPath:(NSString *)path
          withFileLength:(unsigned long long)fileLength
        resumingDownload:(BOOL)resume
        {
            numOfDownloadRetry  = 0;
            azureBlobName       = blobName;
            azureContainerName  = containerName;
            strFileNameWithPath = path;
            isResumeDownload    = resume;
            blobLength          = fileLength;
            responseData        = [[NSMutableData alloc] init];
            NSString *headerType;
            unsigned long long initialOffset = 0;
            unsigned long long finalByte     = 0;

            if (!isResumeDownload)
                {
                    headerType = @"downloadblob";
                }
            else
                {
                    headerType = @"resumedownloadblob";
                    if ([[NSFileManager defaultManager] fileExistsAtPath:strFileNameWithPath])
                        {
                            NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:strFileNameWithPath error:NULL];
                            initialOffset       = [attrs fileSize];   // begin of the request
                            finalByte           = fileLength;         // size of the file
                        }
                }

            NSString *baseUrl = [NSString stringWithFormat:@"%@/%@?type='%@'&Container='%@'&Blob='%@'&offSet=%qu&endByte=%qu", dataServiceURL, @"GetBlobHeaderInformation", headerType, containerName, blobName, initialOffset, finalByte];
            NSURL    *url     = [NSURL URLWithString:baseUrl];

            // Build the request to get the azure authorization
            NSMutableURLRequest *myRequest = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:httpDownloaderRequestTimeout];

            [self updateRequestForFileDownload:myRequest withToken:self.securityToken];

            downloadStage = downloadingAuthorizationKey;

            connection = [NSURLConnection connectionWithRequest:myRequest delegate:self]; //request is sent here
        }



    //
    // Creates the empty file locally to hold the downloaded data, then starts to download the blob file in chunks
    // (which continues in didReceiveData until the empty file has the whole file (or resume a failed download)).
    //
    //  ..........SAMPLE OF *parsedData..........
    //
    //      blobHeaderKey = StorageAccount;
    //      blobHeaderValue = irealproperty;
    //
    //      blobHeaderKey = "x-ms-date";
    //      blobHeaderValue = "Thu, 31 Jul 2014 21:12:26 GMT";
    //
    //      blobHeaderKey = "x-ms-version";
    //      blobHeaderValue = "2009-09-19";
    //
    //      blobHeaderKey = Authorization;
    //      blobHeaderValue = "SharedKey irealproperty:NhVsJ0KjChcBZheKUBCyE8A/JKXngplFQayH7v9WpUc=";
    //
    //  ..........SAMPLE OF *url..........
    //
    //      http://irealproperty.blob.core.windows.net/area02/Area02.layers.xml
    //
    //
    //  ..........SAMPLE OF *strFileNameWithPath..........
    //
    //      /Users/davidbaun/Library/Application Support/iPhone Simulator/7.1/.../Documents/Area02/Area02.layers.xml
    //
    - (void)startAzureBlobDownload
        {
            downloadStage = downloadingBlob;

            // Parse Json response
            NSDictionary *parsedData = [BaseRequest parseData:responseData];

            if (parsedData != nil)
                {
                    parsedData = [self getJsonDictionaryFromProxyResponse:parsedData forMethod:@"GetBlobHeaderInformation"];

                    NSArray             *JSONentities;
                    NSString            *azureAccount;
                    NSString            *baseUrl;
                    NSURL               *url;
                    NSMutableURLRequest *request;

                    // By default, the JSON base dictionary key is named "d"
                    JSONentities = [parsedData valueForKey:@"d"];
                    azureAccount = [self getAzureAccountFromResponse:JSONentities];

                    // Builds the Azure URL to download the file using REST call.
                    // Container name MUST be lowercase or the request will fail.
                    NSString *correctAreaName = [[Helper versionSpecificContainerName:azureContainerName] lowercaseString];
                    baseUrl = [NSString stringWithFormat:@"http://%@.blob.core.windows.net/%@/%@", azureAccount, correctAreaName, azureBlobName];
                    url     = [NSURL URLWithString:baseUrl];
                    request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60];

                    // Sets all http request headers other than StorageAccount, which is already done.
                    for (NSDictionary *entityData in JSONentities)
                        {
                            NSString *Key = [entityData valueForKey:@"blobHeaderKey"];
                            if (Key != keyOfAccount)
                                {
                                    NSString *Val = [entityData valueForKey:@"blobHeaderValue"];
                                    [request setValue:Val forHTTPHeaderField:Key];
                                }
                        }
                    [request setValue:@"irealproperty.blob.core.windows.net" forHTTPHeaderField:@"Host"];
                    [request setValue:@"Keep-Alive" forHTTPHeaderField:@"Connection"];

                    self.floatReceivedData = 0;

                    fileHandle = nil;

                    if (!isResumeDownload)
                        {
                            // Create the empty file (ex. strFileNameWithPath = /Users/davidbaun/Library/Application Support/iPhone Simulator/7.1/.../Documents/Area03/Area03.LabelSets.xml)
                            if (![[NSFileManager defaultManager] createFileAtPath:strFileNameWithPath contents:nil attributes:nil])
                                {
                                    // The empty file was created in the IF statement.  If it failed to create it, you wind up in here.
                                    [self cancelRequest];
                                    NSLog(@"Error was code: %d - message: %s", errno, strerror(errno));

                                    NSString *errStr = [NSString stringWithFormat:@"Error creating file: %s", strerror(errno)];

                                    NSError *error = [NSError errorWithDomain:errStr code:-1 userInfo:nil];
                                    [delegate downloaderDidFail:self withError:error];
                                    return;
                                }
                        }
                    
                    //
                    // example request for blob http://irealproperty.blob.core.windows.net/area02/Area02.layers.xml
                    // example connection URL: http://irealproperty.blob.core.windows.net/area02/Area02.layers.xml
                    //
                    connection = [NSURLConnection connectionWithRequest:request delegate:self];
                }
        }



    //
    // Returns the downloading file name.
    //
    - (NSString *)getFileName
        {
            return azureBlobName;
        }



    - (void)connection:(NSURLConnection *)cn
      didFailWithError:(NSError *)error
        {
            //if (error.code == NSURLErrorTimedOut && numOfDownloadRetry < 3)
            [self closeFile];
            [connection cancel];
            if (numOfDownloadRetry < 3)
                {
                    connection = nil;
                    numOfDownloadRetry++;
                    [self downloadFile:azureBlobName inContainer:azureContainerName inPath:strFileNameWithPath withFileLength:blobLength resumingDownload:YES];
                }
            else
                {
                    [self.delegate downloaderDidFail:self withError:error];
                }
        }



    //
    // Manage the response of the download request
    //
    - (void)connection:(NSURLConnection *)connection
    didReceiveResponse:(NSURLResponse *)response
        {
            int resultStatus = (int) [(NSHTTPURLResponse *) response statusCode];
            if ((resultStatus != 200) && (resultStatus != 206))
                {
                    NSError *error = [self createRequestError:[NSString stringWithFormat:@"Error while downloading the date (error code=%d)", resultStatus] withCode:requestErr_Network_HttpError];
                    [self.delegate downloaderDidFail:self withError:error];
                    return;
                }

            //store how big file is going to be
            if (downloadStage == downloadingAuthorizationKey)
                {
                    [responseData setLength:0];
                    // Get the http code status
                }
            else
                {
                    //self.floatTotalData = [[NSString stringWithFormat:@"%lli",[response expectedContentLength]] floatValue];
                }

        }



    //
    // Manage the chunk of bytes received
    // DBaun: Build up the file in pieces as they are received, by appending the received chunk to the created file.
    //
    - (void)connection:(NSURLConnection *)connection
        didReceiveData:(NSData *)data
        {
            @try
                {
                    if (downloadStage == downloadingAuthorizationKey)
                        {
                            [responseData appendData:data];
                        }
                    else
                        {
                            self.floatReceivedData = [data length];

                            //add new data to the end of the file
                            if (fileHandle == nil)
                                {
                                    fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:strFileNameWithPath];
                                    [fileHandle seekToEndOfFile];
                                }
                            [fileHandle writeData:data];
                            numOfDownloadRetry = 0;
                        }

                    //if delegate did implement the method didReceiveData let it know about the new data
                    if ([self.delegate respondsToSelector:@selector(downloaderDidReceiveData:)])
                        [self.delegate downloaderDidReceiveData:self];
                }
            @catch (NSException *exception)
                {
                    [self closeFile];
                    NSError *error = [self createRequestError:[NSString stringWithFormat:@"Can't write the file. Verify that the device is not full."] withCode:-1];

                    [self.delegate downloaderDidFail:self withError:error];
                }
        }



    //
    // Manage the end of the process
    //
    - (void)connectionDidFinishLoading:(NSURLConnection *)connection
        {
            if (downloadStage == downloadingAuthorizationKey)
                {
                    // Here because just completed downloading the authorization info and now ready to download the actual file.
                    [self startAzureBlobDownload];
                }
            else
                {
                    if ([self isDownloadedFileOk])
                        {
                            //and let the delegate know that the download has finished
                            if ([self.delegate respondsToSelector:@selector(downloaderDidLoadData:)])
                                [self.delegate downloaderDidLoadData:self];
                        }
                    else
                        {
                            NSError *error = [self createRequestError:[NSString stringWithFormat:@"The file downloaded is corrupted.  Please try again."] withCode:-1];
                            [self.delegate downloaderDidFail:self withError:error];
                        }

                    [self closeFile];
                }
        }



    //
    // CHECKS THAT THE FILE DOWNLOADED CORRECTLY BY CHECKING THE FILE SIZE AGAINST BLOB LENGTH
    //
    //  ..........SAMPLE OF *strFileNameWithPath..........
    //
    //  /Users/davidbaun/Library/Application Support/iPhone Simulator/7.1/.../Documents/Area02/Area02.layers.xml
    //
    - (BOOL)isDownloadedFileOk
        {
            BOOL result = YES;
            if ([[NSFileManager defaultManager] fileExistsAtPath:strFileNameWithPath])
                {
                    NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:strFileNameWithPath error:NULL];
                    if (blobLength != [attrs fileSize])
                        {
                            result = NO;
                        }
                }
            else
                {
                    result = NO;
                }
            return result;
        }


    //
    // DBaun 10/17/13 04:13pm THE VERY FINAL POINT OF FINISHING THE FILE DOWNLOAD FROM AZURE.
    //
    - (void)closeFile
        {
            if (fileHandle != nil)
                {
                    [fileHandle closeFile];
                    fileHandle = nil;
                }
        }



    - (void)dealloc
        {
            //free memory
            delegate            = nil;
            strFileNameWithPath = nil;
            responseData        = nil;
            azureBlobName       = nil;
            azureContainerName  = nil;
        }



    - (NSString *)description
        {
            NSMutableString *outputString;
            outputString = [[NSMutableString alloc] initWithCapacity:250];

            [outputString appendString:@"\n*** [Downloader description] ***\n"];
            [outputString appendFormat:@"delegate              = %@\n", delegate];
            [outputString appendFormat:@"strFileNameWithPath   = %@\n", strFileNameWithPath];
            [outputString appendFormat:@"dataServiceURL        = %@\n", dataServiceURL];
            [outputString appendFormat:@"azureContainerName    = %@\n", azureContainerName];
            [outputString appendFormat:@"azureBlobName         = %@\n", azureBlobName];
            [outputString appendFormat:@"downloadStage         = %i\n", downloadStage];
            [outputString appendFormat:@"isResumeDownload      = %@\n", (isResumeDownload ? @"YES" : @"NO")];
            [outputString appendFormat:@"numOfDownloadRetry    = %i\n", numOfDownloadRetry];

            return outputString;
        }


@end









/*    -(NSString *)descriptionWithMethodName:(NSString *)nameOfCaller andTitle:(NSString *)titleMessage
        {
            NSMutableString *outputString;
            outputString = [[NSMutableString alloc] initWithCapacity:250];

            if (titleMessage)
                [outputString appendFormat:@"* Title: %@\n",titleMessage];

            if (nameOfCaller)
                [outputString appendFormat:@"* Method: %@\n",nameOfCaller];

            [outputString appendString:[self description]];

            return outputString;
        }*/

