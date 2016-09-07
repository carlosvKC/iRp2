#import <CoreData/CoreData.h>

#import "Requester.h"
#import "NSDataBase64.h"
#import "SBJSON.h"
#import "XMLReader.h"
#import "AzureContainer.h"
#import "AzureBlob.h"
#import "syncInformation.h"
#import "ChangeSetResponse.h"
#import "SyncErrorInformation.h"
#import "Helper.h"
#import "DaveGlobals.h"


@implementation Requester

    @synthesize blobServiceURL;
    @synthesize delegate;
    @synthesize containerRequested;

#pragma mark -
#pragma mark execute requests methods

    - (id)init:(NSString *)serviceURL
        {
            self = [super init];
            if (self)
                {
                    dataServiceURL = serviceURL;
                }

            return self;
        }



//
// Calls the Get Est Area synchronous
//
    - (void)executeGetEstAreaAsynchronous:(int)realPropId
                                withTaxYr:(int)taxYr
                               usingToken:(NSString *)securityToken
        {
            requestType = typeGetEstArea;

            // Check the network status
            NSString            *baseUrl = [NSString stringWithFormat:@"%@/GetEstArea?RealPropId=%d&TaxYr=%d", dataServiceURL, realPropId, taxYr];
            NSURL               *url     = [NSURL URLWithString:baseUrl];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:httpRequestTimeout];
            [self updateRequest:request withToken:securityToken];
            if (responseData == nil)
                responseData = [NSMutableData data];
            connection       = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
        }

- (void)executeGetEstAreaAsynchronousRpGuid:(NSString *)rpGuid
                                  withTaxYr:(int)taxYr
                                 usingToken:(NSString *)securityToken;
    {
        requestType = typeGetEstArea;
        
        // Check the network status
        NSString            *baseUrl = [NSString stringWithFormat:@"%@/GetEstArea?rpGuid=%@&TaxYr=%d", dataServiceURL, rpGuid, taxYr];
        NSURL               *url     = [NSURL URLWithString:baseUrl];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:httpRequestTimeout];
        [self updateRequest:request withToken:securityToken];
        if (responseData == nil)
            responseData = [NSMutableData data];
        connection       = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    }


//
// Downloads a blob from the webservice.
//
    - (NSData *)executeDownloadBlobFromWebServiceSynchronous:(NSString *)fileName
                                                  usingToken:(NSString *)securityToken
                                                   withError:(NSError **)error
        {
            if (error != nil)
                *error             = nil;
            NSData   *returnData;
            NSError  *myError;
            NSString *escapedToken = [self getEscapedToken:securityToken withError:&myError];
            if (escapedToken != nil)
                {
                    NSString            *baseUrl = [NSString stringWithFormat:@"%@?docName=%@&wrap_access_token=%@", blobServiceURL, fileName, escapedToken];
                    NSURL               *url     = [NSURL URLWithString:baseUrl];
                    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:httpRequestTimeout];
                    [request setHTTPMethod:@"GET"];

                    NSURLResponse *response = nil;
                    returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&myError];
                    if (myError != nil)
                        *error = myError;
                    else
                        {
                            myError = [self getErrorFromURLResponse:response];
                            if (myError != nil)
                                *error = myError;
                        }
                }
            return returnData;
        }



//
// Uploads the blob in to the webservice.
//
    - (NSError *)executeUploadBlobToWebServiceSynchronous:(NSData *)blob
                                             withFileName:(NSString *)fileName
                                               usingToken:(NSString *)securityToken
                                          andEscapedToken:(NSString *)escapedSecurityToken
        {
            NSError             *myError = nil;
            NSString            *baseUrl = [NSString stringWithFormat:@"%@?docName=%@&wrap_access_token=%@", blobServiceURL, fileName, escapedSecurityToken];
            NSURL               *url     = [NSURL URLWithString:baseUrl];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:httpRequestTimeout];
            [request setHTTPMethod:@"POST"];

            NSMutableData *body         = [NSMutableData data];
            NSString      *boundaryGuid = [Requester createNewGuid];
            NSString      *boundary     = [NSString stringWithFormat:@"---------------------------%@", boundaryGuid];
            NSString      *contentType  = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
            [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
            [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: attachment; name=\"userfile\"; filename=\"%@\"\r\n", fileName] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[NSData dataWithData:blob]];
            [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];

            // close form
            [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];

            // set request body
            [request setHTTPBody:body];

            //return and test
            NSURLResponse *response = nil;

            [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&myError];
            if (myError == nil)
                {
                    myError = [self getErrorFromURLResponse:response];
                    if (myError == nil)
                        {
                            bool isFileOnServer = [self executeIsFileOnServer:fileName usingSecurityToken:securityToken withError:&myError];
                            if (!isFileOnServer)
                                {
                                    myError = [self createRequestError:[NSString stringWithFormat:@"The file did not upload to the server."] withCode:2];
                                    return myError;
                                }
                        }
                }

            return myError;
        }



//
// Start the asynchronous login process 
//
    - (void)executeLogin:(NSString *)userName
            withPassword:(NSString *)password
        {
            requestType = typeUserLogin;

            // Build credential http header text
            NSData   *plainTextData = [[NSString stringWithFormat:@"%@:%@", userName, password] dataUsingEncoding:NSUTF8StringEncoding];
            NSString *base64String  = [plainTextData base64EncodedString];

            // Create the http request to get the simple web token and also validates the user credentials
            NSMutableURLRequest *request    =
                                        [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/GetSimpleToken", dataServiceURL]]
                                                                     cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                                 timeoutInterval:httpRequestTimeout];
            // Sets the HTTP headers
            NSString            *authString = [NSString stringWithFormat:@"Basic %@", base64String];
            [request setValue:authString forHTTPHeaderField:@"Authorization"];
            [request setValue:@"Application/json" forHTTPHeaderField:@"Accept"];
            [request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
            if (responseData == nil)
                responseData = [NSMutableData data];

            // Do an asyncrhonous call fo the method. The result are managed by the connection delegate methods below
            connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];

        }



//
// Gets all the entities of entityKind asynchronous
//
    - (void)executeGetEntitiyAsynchronous:(NSString *)entityKind
                               usingToken:(NSString *)securityToken
        {
            requestType         = typeGetEntities;
            requestedEntitykind = entityKind;
            // Check the network status

            NSString            *baseUrl = [NSString stringWithFormat:@"%@/%@", dataServiceURL, entityKind];
            NSURL               *url     = [NSURL URLWithString:baseUrl];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:httpRequestTimeout];
            [self updateRequest:request withToken:securityToken];
            if (responseData == nil)
                responseData = [NSMutableData data];
            connection       = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
        }



//
// Gets all the entities of entityKind synchronous
//
    - (NSString *)executeGetEntitiySynchronous:(NSString *)entityKind
                                    usingToken:(NSString *)securityToken
                               withStagingGuid:(NSString *)stagingGuid
                                     withError:(NSError **)error
        {
            if (error != nil)
                *error = nil;
            NSString *JSONentities;
            requestType         = typeGetEntities;
            requestedEntitykind = entityKind;

            NSString *filterStr = @"stagingGUID%20eq%20''";
            filterStr = [filterStr stringByAppendingString:stagingGuid];
            filterStr = [filterStr stringByAppendingString:@"''"];
            // cv adding i 
            NSString *baseUrl = [NSString stringWithFormat:@"%@/GetEntity?entityKind='i%@_prep'&filter='%@'", dataServiceURL, entityKind, filterStr];
            NSURL    *url     = [NSURL URLWithString:baseUrl];
            NSError  *myError;
            NSData   *content = [self executeRequestForURL:url withToken:securityToken andError:&myError];
            if (myError == nil)
                {
                    NSDictionary *parsedData = [BaseRequest parseData:content];
                    if (parsedData != nil)
                        {
                            //parsedData = [self getJsonDictionaryFromProxyResponse:parsedData forMethod:@"GetEntity"];
                            //JSONentities = [parsedData valueForKey:@"d"];
                            JSONentities = [self getStringFromProxyResponse:parsedData forMethod:@"GetEntity"];
                        }
                }
            else
                {
                    *error = myError;
                }

            return JSONentities;
        }



//
// Get the containers list from Windows Azure blob storage
// The securityToken comes from the Configuration object, which got it from logging in to the application.
// It appears from the code below that requesting containers does not require a security token, but requesting blobs does.
//
//
//  ..........SAMPLE *securityToken LOOKS LIKE THIS..........
//  http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name=kc\baund&Issuer=http://self&Audience=http://localhost:61719/iRealPropertyService.svc&ExpiresOn=1406821478&HMACSHA256=olN7eoCWJCZ%2boB06h4SOF1LIc6ApNUHlsjpaIrKqSPI%3d
//
//  ..........SAMPLE *url LOOKS LIKE THIS..........
//  http://blue.kingcounty.gov/Assessor/iRealPropertyProxy/iRealPropertyProxy.svc/GetBlobHeaderInformation?type='getlistcontainers'&Container=''&Blob=''&offSet=0&endByte=0
//
    - (void)executeGetAzureContainersList:(NSString *)securityToken
                           includingBlobs:(BOOL)includeBlobs
        {
            requestType = typeGetAuthorizationForContainerList;

            NSString *headerType = @"getlistcontainers";
            NSString *baseUrl    = [NSString stringWithFormat:@"%@/%@?type='%@'&Container='%@'&Blob='%@'&offSet=%d&endByte=%d", dataServiceURL, @"GetBlobHeaderInformation", headerType, @"", @"", 0, 0];
            NSURL    *url        = [NSURL URLWithString:baseUrl];

            // Build the request to get the azure authorization
            NSMutableURLRequest *myRequest = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:httpRequestTimeout];
            [self updateRequest:myRequest withToken:securityToken];

            if (responseData == nil)
                responseData           = [NSMutableData data];

            includeBlobsInToContainers = includeBlobs;

            if (includeBlobs)
                {
                    requestSecurityToken = securityToken;
                }
            else
                {
                    requestSecurityToken = nil;
                }

            connection  = [[NSURLConnection alloc] initWithRequest:myRequest delegate:self startImmediately:YES]; //request is sending here
        }



//
// Executes get the blob list from Windows Azure blob storage container
//
    - (void)executeGetAzureBlobList:(NSString *)container
                          withToken:(NSString *)securityToken
        {
            arrayOfAzureContainersToGet = nil;
            requestSecurityToken = nil;

            [self getBlobList:container withToken:securityToken];

        }



//
// Executes synchronous the upload new entities process in to the data service.
//
// First pass -- upload entities with I, U or D in rowStatus
//
    - (NSError *)executeUploadNewEntitiesSync:(NSArray *)newEntities
                                       ofKind:(NSString *)kind
                                    withToken:(NSString *)securityToken
        {
            NSError *myError;
            requestType = typeUploadNewEntities;
            if ([newEntities count] > 0)
                {
                    // Builds the message boundary
                    NSString *batchBoundary = [NSString stringWithFormat:@"batch_%@", [[NSProcessInfo processInfo] globallyUniqueString]];

                    // Builds the URL
                    NSURL               *url     = [NSURL URLWithString:[NSString stringWithFormat:@"%@/uploadEntities", dataServiceURL]];
                    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:httpRequestTimeout];

                    // Format the request header
                    [self updateRequest:request withToken:securityToken];
                    [request setHTTPMethod:@"POST"];
                    [request setValue:[NSString stringWithFormat:@"multipart/mixed; boundary=%@", batchBoundary] forHTTPHeaderField:@"Content-Type"];
                    [request setValue:@"2.0" forHTTPHeaderField:@"DataServiceVersion"];

                    // upload changes in batch.
                    NSMutableString *mutableMessage = [self buildMutableMessage:newEntities ofKind:kind Boundary:batchBoundary];

                    if ([mutableMessage length] > 0)
                        {
                            NSData *data = [mutableMessage dataUsingEncoding:NSUTF8StringEncoding];
                            [request setHTTPBody:data];

                            NSURLResponse *response = nil;

                            // In response, we get a formatted HTTP response with the inserted entities or the error
                            // the inserted entities are put into a sync table. Errors are either network error or bad format in the
                            // initial error
                            NSData *content = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&myError];

                            if (myError == nil)
                                {
                                    myError = [self getErrorFromURLResponse:response];
                                    if (myError == nil)
                                        {
                                            NSString *result = [[NSString alloc] initWithBytes:[content bytes] length:[content length] encoding:NSUTF8StringEncoding];


                                            NSDictionary *parsedData = [BaseRequest parseData:content];
                                            if (parsedData != nil)
                                                {
                                                    result                        = [self getStringFromProxyResponse:parsedData forMethod:@"uploadEntities"];
                                                    NSArray  *parsedResponseArray = [self parseBatchResponse:result];
                                                    NSString *errResult           = @"";
                                                    for (int i = 0; i < [parsedResponseArray count]; i++)
                                                        {
                                                            ChangeSetResponse *csResp = [parsedResponseArray objectAtIndex:i];
                                                            if (![csResp isChangeSetOk])
                                                                {
                                                                    NSManagedObject *actualEntity = [newEntities objectAtIndex:i];
                                                                    NSString        *guid         = [actualEntity valueForKey:@"guid"];

                                                                    errResult = [errResult stringByAppendingFormat:@"Error uploading %@ with identifier = %@.  Error message: %@ /r/n",
                                                                                                                   kind, guid, [csResp getErrorMsg]];
                                                                }
                                                        }
                                                    if ([errResult length] > 0)
                                                        {
                                                            myError = [self createRequestError:errResult withCode:3];
                                                        }
                                                }
                                        }
                                }
                        }
                }
            return myError;
        }



//
// Execute the process to move data from sync to prep tables in the server
//                             images
//
    - (NSError *)executeMoveDataToPrepTablesWithStagingGuidSync:(NSString *)stagingGUID
                                                      withToken:(NSString *)securityToken
                                            andValidationErrors:(NSMutableArray **)validationErrorArray
        {
            NSError *error;
            requestType = typeMoveDataToPrepTables;
            *validationErrorArray = nil;

            // Check the network status
            // 5/9/16  cv Check the queue if syncProcess is ready for request
            NSString *baseUrl = [NSString stringWithFormat:@"%@/MoveDataFromSyncToPrep?StagingGuid='%@'", dataServiceURL, stagingGUID];
            NSURL    *url     = [NSURL URLWithString:baseUrl];

            NSData *content = [self executeRequestForURL:url withToken:securityToken andError:&error];
            if (error == nil)
                {
                    // no communication, error -- look for error in the response
                    NSDictionary *parsedData = [BaseRequest parseData:content];
                    if (parsedData != nil)
                        {
                            parsedData            = [self getJsonDictionaryFromProxyResponse:parsedData forMethod:@"MoveDataFromSyncToPrep"];
                            //NSMutableArray *errArray = [[NSMutableArray alloc]init];
                            NSArray *JSONentities = [parsedData valueForKey:@"d"];
                            if ([JSONentities count] > 0)
                                {
                                    *validationErrorArray = [[NSMutableArray alloc] init];
                                    for (NSDictionary *errorInf in JSONentities)
                                        {
                                            SyncErrorInformation *errObj = [[SyncErrorInformation alloc] init:errorInf];
                                            if ([errObj.errorMessage length] > 0)
                                                {
                                                    if ([errObj.entityKind length] == 0)
                                                        {
                                                            //5/9/16 cv Capture the error regardless of what it is. if errObj is fill do not hide and show regardless
                                                            // we could simplify this statement but seems a friendlier error the better(sqlError)
                                                            // 8/23/13 HNN I want to display the sql error msg
                                                            NSString *search   = @"See the inner exception for details. ---> System.Data.SqlClient.SqlException:";
                                                            NSString *sqlError = @"";
                                                            if ([errObj.errorMessage rangeOfString:search options:NSCaseInsensitiveSearch].location != NSNotFound)
                                                                {
                                                                    sqlError = [errObj.errorMessage substringFromIndex:NSMaxRange([errObj.errorMessage rangeOfString:search options:NSCaseInsensitiveSearch])];
                                                                    if ([sqlError rangeOfString:@"\n" options:NSCaseInsensitiveSearch].location != NSNotFound)
                                                                        sqlError = [sqlError substringToIndex:NSMaxRange([sqlError rangeOfString:@"\n" options:NSCaseInsensitiveSearch])];
                                                                }
                                                            //5/4/16 cv Capture errObj as well regardless if is not a sqlError
                                                            if ([sqlError isEqual: @""])
                                                                error = [self createRequestError:errObj.errorMessage withCode:2];
                                                            else
                                                                error = [self createRequestError:sqlError withCode:2];

                                                            return error;
                                                        }
                                                    [*validationErrorArray addObject:errObj];
                                                }
                                        }
                                }
                        }
                }

            return error;
        }



//
// Executes asynchronous the upload new entities process in to the data service.
//
    - (void)executeUploadNewEntitiesAsync:(NSArray *)newEntities
                                   ofKind:(NSString *)kind
                                withToken:(NSString *)securityToken
        {
            requestType = typeUploadNewEntities;
            if ([newEntities count] > 0)
                {
                    // Builds the message boundary
                    NSString *batchBoundary = [NSString stringWithFormat:@"batch_%@", [[NSProcessInfo processInfo] globallyUniqueString]];

                    // Builds the URL
                    NSURL               *url     = [NSURL URLWithString:[NSString stringWithFormat:@"%@/uploadEntities", dataServiceURL]];
                    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:httpRequestTimeout];

                    // Format the request header
                    [self updateRequest:request withToken:securityToken];
                    [request setHTTPMethod:@"POST"];
                    [request setValue:[NSString stringWithFormat:@"multipart/mixed; boundary=%@", batchBoundary] forHTTPHeaderField:@"Content-Type"];
                    [request setValue:@"2.0" forHTTPHeaderField:@"DataServiceVersion"];

                    // upload changes in batch.
                    NSMutableString *mutableMessage = [self buildMutableMessage:newEntities ofKind:kind Boundary:batchBoundary];

                    if ([mutableMessage length] > 0)
                        {
                            if (responseData == nil)
                                responseData = [NSMutableData data];
                            NSData *data = [mutableMessage dataUsingEncoding:NSUTF8StringEncoding];
                            [request setHTTPBody:data];
                            connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
                        }
                }
            else
                {
                    if ([self.delegate respondsToSelector:@selector(requestUploadEntitiesDone:)])
                        [self.delegate requestUploadEntitiesDone:self];
                }
        }



//
// Execute the process of calculate estimates
//
    - (NSArray *)executeCalculateEstimatesSync:(NSString *)stagingGuid
                                         TaxYr:(int)taxYr
                                          Area:(int)area
                                       subArea:(int)subArea
                                  andApplGroup:(NSString *)applGroup
                                     withToken:(NSString *)securityToken
                                         error:(NSError **)error
        {
            if (error != nil)
                *error = nil;
            NSError        *myError;
            NSMutableArray *JSONentities;
            requestType = typeCalculateEstimates;

            // Check the network status
            NSString *baseUrl = [NSString stringWithFormat:@"%@/CalEstimatesWithQuery?StagingGuid='%@'&TaxYr=%d&Area=%d&SubArea=%d&ApplGroup='%@'", dataServiceURL, stagingGuid, taxYr, area, subArea, applGroup];
            baseUrl = [baseUrl stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
            NSURL  *url     = [NSURL URLWithString:baseUrl];
            NSData *content = [self executeRequestForURL:url withToken:securityToken andError:&myError];
            if (myError == nil)
                {
                    // no communication, error -- look for error in the response
                    NSDictionary *parsedData = [BaseRequest parseData:content];
                    if (parsedData != nil)
                        {
                            parsedData   = [self getJsonDictionaryFromProxyResponse:parsedData forMethod:@"CalEstimatesWithQuery"];
                            JSONentities = [parsedData valueForKey:@"d"];
                        }
                }
            else
                {
                    *error = myError;
                }

            return JSONentities;
        }



    - (double)executeGetServerDateWithToken:(NSString *)securityToken
                                  withError:(NSError **)error
        {
            if (error != nil)
                *error = nil;
            NSError *myError;
            double serverDate = 0.0;

            // Check the network status
            NSString *baseUrl = [NSString stringWithFormat:@"%@/GetServerDate", dataServiceURL];
            NSURL    *url     = [NSURL URLWithString:baseUrl];
            NSData   *content = [self executeRequestForURL:url withToken:securityToken andError:&myError];
            if (myError == nil)
                {
                    NSString *result;
                    if ([content length] > 0)
                        {
                            // Get the response
                            result = [[NSString alloc] initWithBytes:[content bytes] length:[content length] encoding:NSUTF8StringEncoding];

                            // Parse the JSon response
                            SBJsonParser *parser     = [[SBJsonParser alloc] init];
                            NSDictionary *parsedData = [parser objectWithString:result error:nil];
                            if (parsedData != nil)
                                {
                                    parsedData = [self getJsonDictionaryFromProxyResponse:parsedData forMethod:@"GetServerDate"];
                                    serverDate = [[[parsedData valueForKey:@"d"] objectForKey:@"GetServerDate"] doubleValue];
                                }
                        }
                    return serverDate;
                }
            else
                {
                    *error = myError;
                    return serverDate;
                }
        }



    - (void)executePopulatePrepTablesForStagingGuid:(NSString *)StagingGuid
                                       LastSyncDate:(double)lastSyncDate
                                               Area:(NSString *)area
                                           andToken:(NSString *)securityToken
                                          withError:(NSError **)error
        {
            if (error != nil)
                *error = nil;
            NSError *myError;
            // Check the network status
            NSString *baseUrl = [NSString stringWithFormat:@"%@/PopulatePrepTablesFromServer?StagingGuid='%@'&Area=%@&lastSyncDate=%f", dataServiceURL, StagingGuid, area, lastSyncDate];
            NSURL    *url     = [NSURL URLWithString:baseUrl];
            NSData   *content = [self executeRequestForURL:url withToken:securityToken andError:&myError];
            if (myError == nil)
                {
                    NSString *result;
                    if ([content length] > 0)
                        {
                            // Get the response
                            result = [[NSString alloc] initWithBytes:[content bytes] length:[content length] encoding:NSUTF8StringEncoding];

                            // Parse the JSon response
                            SBJsonParser *parser     = [[SBJsonParser alloc] init];
                            NSDictionary *parsedData = [parser objectWithString:result error:nil];
                            if (parsedData != nil)
                                {
                                    parsedData                 = [self getJsonDictionaryFromProxyResponse:parsedData forMethod:@"PopulatePrepTablesFromServer"];
                                    NSString *populateResponse = [[parsedData valueForKey:@"d"] objectForKey:@"PopulatePrepTablesFromServer"];
                                    if ([populateResponse length] > 0)
                                        {
                                            // 5/10/16 cv display the Sync Wait msg
                                            NSString *search   = @"See the inner exception for details. ---> System.Data.SqlClient.SqlException:";
                                            NSString *syncWaitError = @"";
                                            if ([populateResponse rangeOfString:search options:NSCaseInsensitiveSearch].location != NSNotFound)
                                            {
                                                syncWaitError = [populateResponse substringFromIndex:NSMaxRange([populateResponse rangeOfString:search options:NSCaseInsensitiveSearch])];

                                                if ([syncWaitError rangeOfString:@"\n" options:NSCaseInsensitiveSearch].location != NSNotFound)
                                                    syncWaitError = [syncWaitError substringToIndex:NSMaxRange([syncWaitError rangeOfString:@"\n" options:NSCaseInsensitiveSearch])];
                                            }
                                            
                                            //5/4/16 cv capture errObj regardless if is not a syncWaitError
                                            if ([syncWaitError isEqual: @""] )
                                            {
                                                *error = [self createRequestError:populateResponse withCode:2];
                                                //*error = [self createRequestError:@"Server Error => populateResponse" withCode:1];
                                            }
                                            else
                                            {
                                                *error = [self createRequestError:syncWaitError withCode:2];      //cv more friendly message
                                            }
                                            return;
                                        }
                                }
                        }
                    return;
                }
            else
                {
                    *error = myError;
                    return;
                }
        }



    - (NSArray *)executeGetEntitiesToDownload:(NSString *)StagingGuid
                                    withToken:(NSString *)securityToken
                                    withError:(NSError **)error
        {
            if (error != nil)
                *error = nil;
            NSError *myError;

            // Check the network status
            NSString *baseUrl = [NSString stringWithFormat:@"%@/GetEntityRecordsToDownload?StagingGUID='%@'", dataServiceURL, StagingGuid];
            NSURL    *url     = [NSURL URLWithString:baseUrl];
            NSData   *content = [self executeRequestForURL:url withToken:securityToken andError:&myError];
            if (myError == nil)
                {
                    NSMutableArray *resultArr   = [[NSMutableArray alloc] init];
                    NSString       *result;
                    if ([content length] > 0)
                        {
                            // Get the response
                            result = [[NSString alloc] initWithBytes:[content bytes] length:[content length] encoding:NSUTF8StringEncoding];

                            // Parse the JSon response
                            SBJsonParser *parser     = [[SBJsonParser alloc] init];
                            NSDictionary *parsedData = [parser objectWithString:result error:nil];
                            if (parsedData != nil)
                                {
                                    parsedData = [self getJsonDictionaryFromProxyResponse:parsedData forMethod:@"GetEntityRecordsToDownload"];

                                    NSArray *respArr = [parsedData valueForKey:@"d"];
                                    if (respArr != nil)
                                        {
                                            for (NSDictionary *entInf in respArr)
                                                {
                                                    SyncInformation *syncInf = [[SyncInformation alloc] init];
                                                    syncInf.syncEntityName         = [[entInf objectForKey:@"SourceTable"] stringByReplacingOccurrencesOfString:@"_prep" withString:@""];
                                                    syncInf.syncStatus             = 0;
                                                    syncInf.numberOfEntitiesToSync = [[entInf objectForKey:@"NumRecs"] integerValue];
                                                    syncInf.position               = [self getPositionForEntity:syncInf.syncEntityName];
                                                    [resultArr addObject:syncInf];
                                                }
                                        }
                                }
                        }
                    NSArray        *sortedArray = [resultArr sortedArrayUsingComparator:^(SyncInformation *m1,
                                                                                          SyncInformation *m2)
                        {
                            return m1.position > m2.position;
                        }];

                    return sortedArray;
                }
            else
                {
                    *error = myError;
                    return nil;
                }
        }



    - (NSArray *)executeGetValidationErrors:(NSString *)StagingGuid
                                  withToken:(NSString *)securityToken
                                  withError:(NSError **)error
        {
            if (error != nil)
                *error = nil;
            NSError *myError;

            // Check the network status
            NSString *baseUrl = [NSString stringWithFormat:@"%@/GetSyncErrors?StagingGUID='%@'", dataServiceURL, StagingGuid];
            NSURL    *url     = [NSURL URLWithString:baseUrl];
            NSData   *content = [self executeRequestForURL:url withToken:securityToken andError:&myError];
            if (myError == nil)
                {
                    NSMutableArray *resultArr = [[NSMutableArray alloc] init];
                    NSString       *result;

                    if ([content length] > 0)
                        {
                            // Get the response
                            result = [[NSString alloc] initWithBytes:[content bytes] length:[content length] encoding:NSUTF8StringEncoding];

                            // Parse the JSon response
                            SBJsonParser *parser     = [[SBJsonParser alloc] init];
                            NSDictionary *parsedData = [parser objectWithString:result error:nil];
                            if (parsedData != nil)
                                {
                                    parsedData            = [self getJsonDictionaryFromProxyResponse:parsedData forMethod:@"GetSyncErrors"];
                                    NSArray *JSONentities = [parsedData valueForKey:@"d"];
                                    if ([JSONentities count] > 0)
                                        {
                                            for (NSDictionary *errorInf in JSONentities)
                                                {
                                                    SyncErrorInformation *errObj = [[SyncErrorInformation alloc] init:errorInf];
                                                    [resultArr addObject:errObj];
                                                }
                                        }
                                }
                        }
                    return resultArr;
                }
            else
                {
                    *error = myError;
                    return nil;
                }
        }

#pragma mark -
#pragma mark Request managers methods

    - (int)getPositionForEntity:(NSString *)entityKind
        {
            if ([entityKind caseInsensitiveCompare:@"RealPropInfo"] == NSOrderedSame)
                {
                    return 1;
                }
            else if ([entityKind caseInsensitiveCompare:@"Account"] == NSOrderedSame)
                {
                    return 2;
                }
            else if ([entityKind caseInsensitiveCompare:@"ApplHist"] == NSOrderedSame)
                {
                    return 3;
                }
            else if ([entityKind caseInsensitiveCompare:@"Inspection"] == NSOrderedSame)
                {
                    return 4;
                }
            else if ([entityKind caseInsensitiveCompare:@"Land"] == NSOrderedSame)
                {
                    return 5;
                }
            else if ([entityKind caseInsensitiveCompare:@"XLand"] == NSOrderedSame)
                {
                    return 6;
                }
            else if ([entityKind caseInsensitiveCompare:@"ResBldg"] == NSOrderedSame)
                {
                    return 7;
                }
            else if ([entityKind caseInsensitiveCompare:@"MediaBldg"] == NSOrderedSame)
                {
                    return 8;
                }
            else if ([entityKind caseInsensitiveCompare:@"Accy"] == NSOrderedSame)
                {
                    return 9;
                }
            else if ([entityKind caseInsensitiveCompare:@"MediaAccy"] == NSOrderedSame)
                {
                    return 10;
                }
            //replacing CurrZoning to Bookmark
            else if ([entityKind caseInsensitiveCompare:@"Bookmark"] == NSOrderedSame)
                {
                    return 11;
                }
            else if ([entityKind caseInsensitiveCompare:@"EnvRes"] == NSOrderedSame)
                {
                    return 12;
                }
            else if ([entityKind caseInsensitiveCompare:@"MediaLand"] == NSOrderedSame)
                {
                    return 13;
                }
            else if ([entityKind caseInsensitiveCompare:@"SaleParcel"] == NSOrderedSame)
                {
                    return 14;
                }
            else if ([entityKind caseInsensitiveCompare:@"Sale"] == NSOrderedSame)
                {
                    return 15;
                }
            else if ([entityKind caseInsensitiveCompare:@"SaleWarning"] == NSOrderedSame)
                {
                    return 16;
                }
            else if ([entityKind caseInsensitiveCompare:@"TaxRoll"] == NSOrderedSame)
                {
                    return 17;
                }
            else if ([entityKind caseInsensitiveCompare:@"UndividedInt"] == NSOrderedSame)
                {
                    return 18;
                }
            else if ([entityKind caseInsensitiveCompare:@"ValEst"] == NSOrderedSame)
                {
                    return 19;
                }
            else if ([entityKind caseInsensitiveCompare:@"ValHist"] == NSOrderedSame)
                {
                    return 20;
                }
            else if ([entityKind caseInsensitiveCompare:@"ChngHist"] == NSOrderedSame)
                {
                    return 21;
                }
            else if ([entityKind caseInsensitiveCompare:@"ChngHistDtl"] == NSOrderedSame)
                {
                    return 22;
                }
            else if ([entityKind caseInsensitiveCompare:@"HIExmpt"] == NSOrderedSame)
                {
                    return 23;
                }
            else if ([entityKind caseInsensitiveCompare:@"MHAccount"] == NSOrderedSame)
                {
                    return 24;
                }
            else if ([entityKind caseInsensitiveCompare:@"MHCharacteristic"] == NSOrderedSame)
                {
                    return 25;
                }
            else if ([entityKind caseInsensitiveCompare:@"MHLocation"] == NSOrderedSame)
                {
                    return 26;
                }
            else if ([entityKind caseInsensitiveCompare:@"MediaMobile"] == NSOrderedSame)
                {
                    return 27;
                }
            else if ([entityKind caseInsensitiveCompare:@"Permit"] == NSOrderedSame)
                {
                    return 28;
                }
            else if ([entityKind caseInsensitiveCompare:@"PermitDtl"] == NSOrderedSame)
                {
                    return 29;
                }
            else if ([entityKind caseInsensitiveCompare:@"Review"] == NSOrderedSame)
                {
                    return 30;
                }
            else if ([entityKind caseInsensitiveCompare:@"ReviewJrnl"] == NSOrderedSame)
                {
                    return 31;
                }
            else if ([entityKind caseInsensitiveCompare:@"NoteInstance"] == NSOrderedSame)
                {
                    return 32;
                }
            else if ([entityKind caseInsensitiveCompare:@"MediaNote"] == NSOrderedSame)
                {
                    return 33;
                }
            else if ([entityKind caseInsensitiveCompare:@"LandFootage"] == NSOrderedSame)
            {
                return 34;
            }
            else if ([entityKind caseInsensitiveCompare:@"SaleVerif"] == NSOrderedSame)
            {
                return 35;
            }
            return 0;
        }



//
// Gets the token escaped.
//
    - (NSString *)getEscapedToken:(NSString *)securityToken
                        withError:(NSError **)error
        {
            if (error != nil)
                *error = nil;
            NSError *myError;

            // Check the network status
            NSString *baseUrl = [NSString stringWithFormat:@"%@/GetSimpleEscapedToken", dataServiceURL];
            NSURL    *url     = [NSURL URLWithString:baseUrl];
            NSData   *content = [self executeRequestForURL:url withToken:securityToken andError:&myError];
            if (myError == nil)
                {
                    NSString *result;
                    if ([content length] > 0)
                        {
                            // Get the response
                            result = [[NSString alloc] initWithBytes:[content bytes] length:[content length] encoding:NSUTF8StringEncoding];

                            // Parse the JSon response
                            SBJsonParser *parser     = [[SBJsonParser alloc] init];
                            NSDictionary *parsedData = [parser objectWithString:result error:nil];
                            if (parsedData != nil)
                                {
                                    parsedData             = [self getJsonDictionaryFromProxyResponse:parsedData forMethod:@"GetSimpleEscapedToken"];
                                    // Gets the token
                                    NSDictionary *response = [parsedData valueForKey:@"d"];
                                    result = [response objectForKey:@"GetSimpleEscapedToken"];
                                }
                        }
                    return result;
                }
            else
                {
                    *error = myError;
                    return nil;
                }
        }



//
// Validate if the file exits on the server
//
    - (BOOL)executeIsFileOnServer:(NSString *)fileName
               usingSecurityToken:(NSString *)securityToken
                        withError:(NSError **)error
        {
            if (error != nil)
                *error = nil;
            NSError *myError;
            BOOL boolResult = NO;

            // Check the network status
            NSString *baseUrl = [NSString stringWithFormat:@"%@/IsFileOnServer?fileName='%@'", dataServiceURL, fileName];
            NSURL    *url     = [NSURL URLWithString:baseUrl];
            NSData   *content = [self executeRequestForURL:url withToken:securityToken andError:&myError];
            if (myError == nil)
                {
                    NSString *result;
                    if ([content length] > 0)
                        {
                            // Get the response
                            result = [[NSString alloc] initWithBytes:[content bytes] length:[content length] encoding:NSUTF8StringEncoding];

                            // Parse the JSon response
                            SBJsonParser *parser     = [[SBJsonParser alloc] init];
                            NSDictionary *parsedData = [parser objectWithString:result error:nil];
                            if (parsedData != nil)
                                {
                                    parsedData             = [self getJsonDictionaryFromProxyResponse:parsedData forMethod:@"IsFileOnServer"];
                                    // Gets the token
                                    NSDictionary *response = [parsedData valueForKey:@"d"];
                                    boolResult = [[response objectForKey:@"IsFileOnServer"] boolValue];
                                }
                        }
                    return boolResult;
                }
            else
                {
                    *error = myError;
                    return boolResult;
                }
        }



//
// Builds message body for upload entities process
//
    - (NSMutableString *)buildMutableMessage:(NSArray *)newEntities
                                      ofKind:(NSString *)kind
                                    Boundary:(NSString *)batchBoundary
        {
            // upload changes in batch.
            NSMutableString *mutableMessage = [[NSMutableString alloc] init];

            SBJsonWriter *jsonWriter = [[SBJsonWriter alloc] init];
            int contentId = 1;

            //Build the changeset for each entity
            for (int i = 0; i < [newEntities count]; i++)
                {
                    NSMutableString *changeset = [[NSMutableString alloc] init];
                    [mutableMessage appendFormat:@"--%@\r\n", batchBoundary];
                    NSString *changesetBoundary = [NSString stringWithFormat:@"changeset_%@", [[NSProcessInfo processInfo] globallyUniqueString]];
                    [mutableMessage appendFormat:@"Content-Type: multipart/mixed; boundary=%@\r\n", changesetBoundary];

                    NSMutableString *command = [[NSMutableString alloc] init];

                    [changeset appendFormat:@"--%@\r\n", changesetBoundary];
                    [changeset appendString:@"Content-Type: application/http\r\n"];
                    [changeset appendString:@"Content-Transfer-Encoding: binary\r\n"];
                    [changeset appendString:@"\r\n"];

                    // add insert to message body
                    NSMutableDictionary *metadata = [[NSMutableDictionary alloc] init];
                    //[metadata setObject:[NSString stringWithFormat:@"%@/%@_sync(%d)", dataServiceURL, kind, i] forKey:@"uri"];
                    [metadata setObject:[NSString stringWithFormat:@"/i%@_sync(%d)", kind, i] forKey:@"uri"];
                    NSMutableDictionary *entityData = [[NSMutableDictionary alloc] init];
                    [entityData setObject:metadata forKey:@"__metadata"];

                    // Gets the new entity as dictionary
                    [entityData addEntriesFromDictionary:[self getEntityAsDictionary:[newEntities objectAtIndex:i]]];
                    NSString *entityInJson = [jsonWriter stringWithObject:entityData];

                    [command appendFormat:@"%@\r\n", entityInJson];

                    //NSString* baseUri = [NSString stringWithFormat:@"%@/%@_sync", dataServiceURL, kind];
                    NSString *baseUri = [NSString stringWithFormat:@"/i%@_sync", kind];
                    [changeset appendFormat:@"POST %@ HTTP/1.1\r\n", [NSString stringWithFormat:@"%@", baseUri]];
                    [changeset appendFormat:@"Accept: Application/json\r\n"];
                    [changeset appendFormat:@"Content-ID: %i\r\n", contentId];
                    contentId++;

                    [changeset appendString:@"Content-Type: application/json\r\n"];
                    [changeset appendFormat:@"Content-Length: %i\r\n", [command length]]; //add 4 bytes of the 2 last \r\n
                    [changeset appendString:@"\r\n"];

                    [changeset appendFormat:@"%@", command];

                    // add command to the body
                    [changeset appendFormat:@"--%@--\r\n", changesetBoundary];

                    [mutableMessage appendString:@"\r\n"];

                    [mutableMessage appendFormat:@"%@", changeset];
                }
            [mutableMessage appendFormat:@"--%@--\r\n", batchBoundary];
            return mutableMessage;
        }



//
// Parse an entity and return it as dictionary
//
    - (NSMutableDictionary *)getEntityAsDictionary:(NSManagedObject *)actualEntity
        {

            NSMutableDictionary        *dictionary = [[NSMutableDictionary alloc] init];
            NSArray                    *properties = [[actualEntity entity] properties];
            for (NSPropertyDescription *property in properties)
                {
                    if ([property isKindOfClass:[NSAttributeDescription class]])
                        {
                            // change all this.
                            NSAttributeDescription *attribute    = (NSAttributeDescription *) property;
                            NSString               *propertyName = [property name];
                            @try
                                {
                                    if ([actualEntity valueForKey:propertyName] == nil)
                                        {
                                            [dictionary setObject:[NSNull null] forKey:propertyName];
                                        }
                                    else
                                        {
                                            switch ([attribute attributeType])
                                                {
                                                    case NSBooleanAttributeType:
                                                        {
                                                            NSNumber *boolValue = [NSNumber numberWithBool:[[actualEntity valueForKey:propertyName] boolValue]];
                                                            [dictionary setObject:boolValue forKey:propertyName];
                                                        }
                                                    break;

                                                    case NSDateAttributeType:
                                                        {
                                                            NSString *dateInJson = [BaseRequest getJSONFromDate:[actualEntity valueForKey:propertyName]];
                                                            [dictionary setObject:dateInJson forKey:propertyName];
                                                        }
                                                    break;

                                                    case NSDecimalAttributeType:
                                                        {
                                                            NSString *decimalStr = [BaseRequest formattedStringWithDecimal:[actualEntity valueForKey:propertyName]];
                                                            [dictionary setObject:decimalStr forKey:propertyName];
                                                        }
                                                    break;

                                                    default:
                                                        {
                                                            [dictionary setObject:[actualEntity valueForKey:propertyName] forKey:propertyName];
                                                        }
                                                    break;
                                                }
                                        }
                                }
                            @catch (NSException *ex)
                                {
                                    NSLog(@"getEntityAsDictionary exception: %@", ex);
                                }
                        }
                }
            return dictionary;
        }



//
// Get the blob list in a Windows Azure blob storage container.
// This kicks off steps that will eventually return the list of blobs for an area.
//
//  .........A SAMPLE OF *container ..........
//  @"area01"
//
//  .........A SAMPLE OF *securityToken ..........
//  http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name=kc\baund&Issuer=http://self&Audience=http://localhost:61719/iRealPropertyService.svc&ExpiresOn=1406852595&HMACSHA256=d0SUP1%2fMNWvfRtOWs30yX4R10HS%2f0yAiitwV8aFOUO8%3d
//
//  .........A SAMPLE OF *url ..........
//  http://blue.kingcounty.gov/Assessor/iRealPropertyProxy/iRealPropertyProxy.svc/GetBlobHeaderInformation?type='getlistblobs'&Container='area01'&Blob=''&offSet=0&endByte=0
//
//
    - (void)getBlobList:(NSString *)container
              withToken:(NSString *)securityToken
        {
            requestType          = typeGetAuthorizationForBlobList;
            containerRequested   = container;
            requestSecurityToken = securityToken;
            NSString *headerType = @"getlistblobs";
            NSString *baseUrl    = [NSString stringWithFormat:@"%@/%@?type='%@'&Container='%@'&Blob='%@'&offSet=%d&endByte=%d", dataServiceURL, @"GetBlobHeaderInformation", headerType, container, @"", 0, 0];
            NSURL    *url        = [NSURL URLWithString:baseUrl];

            // Build the request to get the azure authorization
            NSMutableURLRequest *myRequest = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:httpRequestTimeout];
            [self updateRequest:myRequest withToken:securityToken];

            if (responseData == nil)
                responseData = [NSMutableData data];

            connection       = [[NSURLConnection alloc] initWithRequest:myRequest delegate:self startImmediately:YES]; //request is sending here
        }



//
// Manage the response of the download request
//
    - (void)connection:(NSURLConnection *)theConnection
    didReceiveResponse:(NSURLResponse *)response
        {
            switch (requestType)
                {
                    default:
                        [responseData setLength:0];
                    break;
                }

            // Get the http code status
            NSHTTPURLResponse *resp = (NSHTTPURLResponse *) response;
            int resultStatus = (int) [resp statusCode];
            if ((resultStatus != 200) && (resultStatus != 202))
                {
                    NSLog(@"%@",[DaveGlobals debugConnection:theConnection withTitleMessage:(NSString *)[NSString stringWithFormat:@"\n[Downloader connection:didReceiveResponse:] FAILED WITH THIS URL \n%@", [response URL]]]);
                    [self cancelRequest];
                    NSError *error = [self createRequestError:[NSString stringWithFormat:@"Http error, request status code returned: %i", resultStatus] withCode:resultStatus];
                    [self.delegate requestDidFail:self withError:error];
                }
        }



//
// Manage the asynchronous method did fail with error
//
    - (void)connection:(NSURLConnection *)cn
      didFailWithError:(NSError *)error
        {
            [self.delegate requestDidFail:self withError:error];
        }



//
// Manage the chunk of bytes received
//
    - (void)connection:(NSURLConnection *)connection
        didReceiveData:(NSData *)data
        {
            switch (requestType)
                {
                    default:
                        [responseData appendData:data];
                    break;
                }

        }



/*
    typeUserLogin = 0,
    typeGetEntities = 1,
    typeGetAuthorizationForContainerList = 2,
    typeGetAzureContainerList = 3,
    typeGetAuthorizationForBlobList = 4,
    typeGetAzureBlobList = 5,
    typeUploadNewEntities = 6,
    typeMoveDataToPrepTables = 7,
    typeGetEstArea = 8,
    typeCalculateEstimates = 9

*/




//
// Manage the end of the process
//
    - (void)connectionDidFinishLoading:(NSURLConnection *)connection
        {

            switch (requestType)
                {
                    case typeUserLogin:
                        [self parseLoginResponse];
                    break;

                    case typeGetEntities:
                        [self parseGetEntityResponse];
                    break;

                    case typeGetAuthorizationForContainerList:
                        [self parseGetAuthorizationForContainerList];
                    break;

                    case typeGetAzureContainerList:
                        [self parseGetAzureContainerList];
                    break;

                    case typeGetAuthorizationForBlobList:
                        [self parseGetAuthorizationForBlobList];
                    break;

                    case typeGetAzureBlobList:
                        [self parseGetAzureBlobList];
                    break;

                    case typeUploadNewEntities:
                        [self parseUploadEntitiesResponse];
                    break;

                    case typeMoveDataToPrepTables:
                        [self parseMoveDataFromSyncToPrepResponse];
                    break;

                    case typeGetEstArea:
                        [self parseGetEstAreaResponse];
                    break;

                    default:
                        break;
                }
        }


#pragma mark -
#pragma mark Callback methods

//
// Do a call back when unload entities process is done.
//
    - (void)parseUploadEntitiesResponse
        {
            //NSString *responseStr = [[NSString alloc]initWithData:responseData encoding:NSUTF8StringEncoding];
            if ([self.delegate respondsToSelector:@selector(requestUploadEntitiesDone:)])
                [self.delegate requestUploadEntitiesDone:self];
        }



//
// Do a call back when the process to move data from sync to prep is done.
//
    - (void)parseMoveDataFromSyncToPrepResponse
        {
            if ([self.delegate respondsToSelector:@selector(requestMoveDataFromSyncToPrepDone:)])
                [self.delegate requestMoveDataFromSyncToPrepDone:self];
        }



//
// Parse get azure container list response and call the callback method.
//
//
//  ..........SAMPLE *containersList LOOKS LIKE THIS..........
//  {
//      Name = area01;
//      Properties =     {
//          Etag = 0x8D0D954B15E426A;
//          "Last-Modified" = "Tue, 07 Jan 2014 00:15:23 GMT";
//      };
//      Url = "http://irealproperty.blob.core.windows.net/area01";
//  },
//  {
//      Name = area02;
//      Properties =     {
//          Etag = 0x8D0D954B2424A87;
//          "Last-Modified" = "Tue, 07 Jan 2014 00:15:25 GMT";
//      };
//      Url = "http://irealproperty.blob.core.windows.net/area02";
//  },
//  {
//      Name = area03;
//      Properties =     {
//          Etag = 0x8D0D954B34D3909;
//          "Last-Modified" = "Tue, 07 Jan 2014 00:15:26 GMT";
//      };
//      Url = "http://irealproperty.blob.core.windows.net/area03";
//  },
//
    - (void)parseGetAzureContainerList
        {
            NSMutableArray *resultArr      = [[NSMutableArray alloc] init];
            NSDictionary   *resultDict     = [XMLReader dictionaryForXMLData:responseData error:nil];
            NSArray        *ContainersList = [[[resultDict objectForKey:@"EnumerationResults"] objectForKey:@"Containers"] objectForKey:@"Container"];

            for (id value in ContainersList)
                {
                    AzureContainer *newContainer = [[AzureContainer alloc] init:value];
                    [resultArr addObject:newContainer];
                }


            if (!includeBlobsInToContainers || ([resultArr count] == 0))
                {
                    if ([self.delegate respondsToSelector:@selector(requestGetAzureContainersListDone:withContainers:)])
                        [self.delegate requestGetAzureContainersListDone:self withContainers:resultArr];
                }
            else
                {
                    arrayOfAzureContainersToGet = resultArr;
                    containerIndex               = 0;
                    AzureContainer *actContainer = [arrayOfAzureContainersToGet objectAtIndex:containerIndex];
                    [self getBlobList:actContainer.name withToken:requestSecurityToken];
                }

        }



//
// Parse the authorization for blob list and call the azure method.
//
// ..........A SAMPLE OF *parsedData LOOKS LIKE THIS..........
//  {
//      d =     (
//                  {
//              "__metadata" =             {
//                  type = "RealPropertyModel.GetBlobHeaderInformation";
//              };
//              blobHeaderKey = StorageAccount;
//              blobHeaderValue = irealproperty;
//          },
//                  {
//              "__metadata" =             {
//                  type = "RealPropertyModel.GetBlobHeaderInformation";
//              };
//              blobHeaderKey = "x-ms-date";
//              blobHeaderValue = "Wed, 30 Jul 2014 15:48:33 GMT";
//          },
//                  {
//              "__metadata" =             {
//                  type = "RealPropertyModel.GetBlobHeaderInformation";
//              };
//              blobHeaderKey = "x-ms-version";
//              blobHeaderValue = "2009-09-19";
//          },
//                  {
//              "__metadata" =             {
//                  type = "RealPropertyModel.GetBlobHeaderInformation";
//              };
//              blobHeaderKey = Authorization;
//              blobHeaderValue = "SharedKey irealproperty:Rz3HDIw9T2qsNAgwkgiCZpEunmZajXcvyc7M6VoRwXo=";
//          }
//      );
//  }
//
//
// ..........A SAMPLE OF *url FOR *request OF common CONTAINER LOOKS LIKE THIS..........
//  http://irealproperty.blob.core.windows.net/common?restype=container&comp=list&include=snapshots&include=metadata
//
//
    - (void)parseGetAuthorizationForBlobList
        {
            requestType = typeGetAzureBlobList;
            // Parse Json response
            NSDictionary *parsedData = [BaseRequest parseData:responseData];
            if (parsedData != nil)
                {
                    parsedData            = [self getJsonDictionaryFromProxyResponse:parsedData forMethod:@"GetBlobHeaderInformation"];
                    // Defaul by Json the base dictionary key is named "d"
                    NSArray *JSONentities = [parsedData valueForKey:@"d"];

                    NSString            *azureAccount = [self getAzureAccountFromResponse:JSONentities];
                    // Builds the Azure URL to download the file using REST call
                    NSString            *baseUrl      = [NSString stringWithFormat:@"http://%@.blob.core.windows.net/%@?restype=container&comp=list&include=snapshots&include=metadata", azureAccount, containerRequested];
                    NSURL               *url          = [NSURL URLWithString:baseUrl];
                    NSMutableURLRequest *request      = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:httpRequestTimeout];

                    // Sets http requests headers
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
                    connection = [NSURLConnection connectionWithRequest:request delegate:self]; //request is send here
                }
        }



//
// Parse get azure container list response and call the callback method.
//
// ..........A SAMPLE OF *resultDict LOOKS LIKE THIS..........
//  {
//      EnumerationResults =     {
//          "@ContainerName" = "http://irealproperty.blob.core.windows.net/area01";
//          Blobs =         {
//              Blob =             (
//                                  {
//                      Name = "Area01.LabelSets.xml";
//                      Properties =                     {
//                          BlobType = BlockBlob;
//                          "Content-Length" = 794;
//                          "Content-Type" = "text/xml";
//                          Etag = 0x8D0D954B27A320C;
//                          "Last-Modified" = "Tue, 07 Jan 2014 00:15:25 GMT";
//                          LeaseStatus = unlocked;
//                      };
//                      Url = "http://irealproperty.blob.core.windows.net/area01/Area01.LabelSets.xml";
//                  },
//                                  {
//                      Name = "Area01.Renderers.xml";
//                      Properties =                     {
//                          BlobType = BlockBlob;
//                          "Content-Length" = 24254;
//                          "Content-Type" = "text/xml";
//                          Etag = 0x8D0D954B28A8627;
//                          "Last-Modified" = "Tue, 07 Jan 2014 00:15:25 GMT";
//                          LeaseStatus = unlocked;
//                      };
//                      Url = "http://irealproperty.blob.core.windows.net/area01/Area01.Renderers.xml";
//                  },
//                                  {
//                      Name = "Area01.layers.xml";
//                      Properties =                     {
//                          BlobType = BlockBlob;
//                          "Content-Length" = 5174;
//                          "Content-Type" = "text/xml";
//                          Etag = 0x8D0D954B2A1B83F;
//                          "Last-Modified" = "Tue, 07 Jan 2014 00:15:25 GMT";
//                          LeaseStatus = unlocked;
//                      };
//                      Url = "http://irealproperty.blob.core.windows.net/area01/Area01.layers.xml";
//                  },
//                                  {
//                      Name = "Area01.menuStructure.xml";
//                      Properties =                     {
//                          BlobType = BlockBlob;
//                          "Content-Length" = 3605;
//                          "Content-Type" = "text/xml";
//                          Etag = 0x8D0D954B2A2F0C7;
//                          "Last-Modified" = "Tue, 07 Jan 2014 00:15:25 GMT";
//                          LeaseStatus = unlocked;
//                      };
//                      Url = "http://irealproperty.blob.core.windows.net/area01/Area01.menuStructure.xml";
//                  }
//              );
//          };
//      };
//  }
//
//
//  ..........A SAMPLE OF *actContainer LOOKS LIKE THIS..........
//  container name:           area01
//  container eTag:           0x8D0D954B15E426A
//  container lastModifDate:  Tue, 07 Jan 2014 00:15:23 GMT
//  container url:            http://irealproperty.blob.core.windows.net/area01
//
//
    - (void)parseGetAzureBlobList
        {
            NSMutableArray *arrayOfAzureBlobs = [[NSMutableArray alloc] init];
            NSDictionary   *resultDict = [XMLReader dictionaryForXMLData:responseData error:nil];
            NSArray        *listOfBlobInfo = [[[resultDict objectForKey:@"EnumerationResults"] objectForKey:@"Blobs"] objectForKey:@"Blob"];

            for (id blobInfo in listOfBlobInfo)
                {
                    AzureBlob *newBlob = [[AzureBlob alloc] init:blobInfo];
                    [arrayOfAzureBlobs addObject:newBlob];
                }

            if (arrayOfAzureContainersToGet == nil)
                {
                    if ([self.delegate respondsToSelector:@selector(requestGetAzureBlobsListDone:withBlobs:)])
                        [self.delegate requestGetAzureBlobsListDone:self withBlobs:arrayOfAzureBlobs];
                }
            else
                {
                    if (containerIndex == ([arrayOfAzureContainersToGet count] - 1))
                        {
                            // If all the containers have been processed (because container index has been incremented up to the number of containers in the array,
                            // then continue here by passing the list of containers (and their associated blobs) to the method below.
                            
                            if ([self.delegate respondsToSelector:@selector(requestGetAzureContainersListDone:withContainers:)])
                                [self.delegate requestGetAzureContainersListDone:self withContainers:arrayOfAzureContainersToGet];
                            
							arrayOfAzureContainersToGet = nil;
                            requestSecurityToken = nil;
                        }
                    else
                        {
                            // Grab the current container from the class level array variable "arrayOfAzureContainersToGet"
                            // This array is a list of all the containers, and it starts with all the container names, but each container has no
                            // associated blobs, so these next two lines populate the blobs in the particular container in the array that matches
                            // the current containerIndex.
                            
                            AzureContainer *actContainer = [arrayOfAzureContainersToGet objectAtIndex:containerIndex];
                            actContainer.blobs = arrayOfAzureBlobs;

                            containerIndex++;

                            AzureContainer *nextContainer = [arrayOfAzureContainersToGet objectAtIndex:containerIndex];

                            [self getBlobList:nextContainer.name withToken:requestSecurityToken];
                        }
                }

        }



//
// Parse the authorization for containers list and call the azure method.
//
//  ..........A SAMPLE OF *parsedData LOOKS LIKE THIS..........
//  {
//      d =     (
//                  {
//              "__metadata" =             {
//                  type = "RealPropertyModel.GetBlobHeaderInformation";
//              };
//              blobHeaderKey = StorageAccount;
//              blobHeaderValue = irealproperty;
//          },
//                  {
//              "__metadata" =             {
//                  type = "RealPropertyModel.GetBlobHeaderInformation";
//              };
//              blobHeaderKey = "x-ms-date";
//              blobHeaderValue = "Thu, 31 Jul 2014 01:20:40 GMT";
//          },
//                  {
//              "__metadata" =             {
//                  type = "RealPropertyModel.GetBlobHeaderInformation";
//              };
//              blobHeaderKey = "x-ms-version";
//              blobHeaderValue = "2009-09-19";
//          },
//                  {
//              "__metadata" =             {
//                  type = "RealPropertyModel.GetBlobHeaderInformation";
//              };
//              blobHeaderKey = Authorization;
//              blobHeaderValue = "SharedKey irealproperty:E6FOvwFDngadQNbvEK1UicNL3EsaIZeHo+UNAMckYRk=";
//          }
//      );
//  }
//
//  ..........A SAMPLE OF *url LOOKS LIKE THIS..........
//  http://irealproperty.blob.core.windows.net/?comp=list
//
//
    - (void)parseGetAuthorizationForContainerList
        {
            requestType = typeGetAzureContainerList;

            // Parse Json response
            NSDictionary *parsedData = [BaseRequest parseData:responseData];

            if (parsedData != nil)
                {
                    parsedData = [self getJsonDictionaryFromProxyResponse:parsedData forMethod:@"GetBlobHeaderInformation"];

                    // By convention, the JSON base dictionary key is named "d"
                    NSArray *JSONentities = [parsedData valueForKey:@"d"];

                    NSString *azureAccount = [self getAzureAccountFromResponse:JSONentities];

                    // Builds the Azure URL to download the file using REST call
                    NSString            *baseUrl = [NSString stringWithFormat:@"http://%@.blob.core.windows.net/?comp=list", azureAccount];
                    NSURL               *url     = [NSURL URLWithString:baseUrl];
                    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:httpRequestTimeout];

                    // Sets http requests headers
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


                    connection = [NSURLConnection connectionWithRequest:request delegate:self]; //request is send here
                }
        }



//
// Parse the GetEntity response do the callback to the delegate method.
//
    - (void)parseGetEntityResponse
        {
            NSArray      *JSONentities;
            NSDictionary *parsedData = [BaseRequest parseData:responseData];
            if (parsedData != nil)
                {
                    parsedData   = [self getJsonDictionaryFromProxyResponse:parsedData forMethod:@"GetEntity"];
                    JSONentities = [parsedData valueForKey:@"d"];
                }
            if ([self.delegate respondsToSelector:@selector(requestEntitiesDone:withEntities:ofKind:)])
                [self.delegate requestEntitiesDone:self withEntities:JSONentities ofKind:requestedEntitykind];
        }



//
// Parse the login response do the callback to the delegate method.
//
    - (void)parseLoginResponse
        {
            NSMutableDictionary *loginDict = [[NSMutableDictionary alloc] init];

            if ([responseData length] > 0)
                {
                    // Get the response
                    NSString *result = [[NSString alloc] initWithBytes:[responseData bytes] length:[responseData length] encoding:NSUTF8StringEncoding];

                    // Parse the JSon response
                    SBJsonParser *parser     = [[SBJsonParser alloc] init];
                    NSDictionary *parsedData = [parser objectWithString:result error:nil];
                    if (parsedData != nil)
                        {
                            parsedData             = [self getJsonDictionaryFromProxyResponse:parsedData forMethod:@"GetSimpleToken"];
                            // Gets the token
                            NSDictionary *response = [[parsedData valueForKey:@"d"] objectForKey:@"GetSimpleToken"];

                            [loginDict setValue:[response objectForKey:@"simpleWebToken"] forKey:@"token"];
                            [loginDict setValue:[response objectForKey:@"userCode"] forKey:@"code"];
                            [loginDict setValue:[response objectForKey:@"userLevel"] forKey:@"level"];

                            NSString *assmtYrStr = [[response objectForKey:@"assmtYr"] stringValue];
                            int assmtYrInt = [assmtYrStr intValue];
                            assmtYrInt += 1;

                            NSString *taxYr = [NSString stringWithFormat:@"%d", assmtYrInt];
                            [loginDict setValue:taxYr forKey:@"taxYear"];

                            id value = [response objectForKey:@"cycleStartDate"];
                            NSDate   *startDate    = [BaseRequest getDateFromJSON:value];
                            NSString *startDateStr = [Helper stringFromDate:startDate];
                            [loginDict setValue:startDateStr forKey:@"cyleStartDate"];

                            value        = [response objectForKey:@"saleStartDate"];
                            startDate    = [BaseRequest getDateFromJSON:value];
                            startDateStr = [Helper stringFromDate:startDate];
                            [loginDict setValue:startDateStr forKey:@"saleStartDate"];
                        }
                }
            if ([self.delegate respondsToSelector:@selector(requestLoginDone:loginInfo:)])
                [self.delegate requestLoginDone:self loginInfo:loginDict];
        }



//
// Parse the Get Est Area response do the callback to the delegate method.
//
    - (void)parseGetEstAreaResponse
        {
            NSString *applGroup;
            int area    = 0;
            int subArea = 0;
            if ([responseData length] > 0)
                {
                    // Get the response
                    NSString *result = [[NSString alloc] initWithBytes:[responseData bytes] length:[responseData length] encoding:NSUTF8StringEncoding];

                    // Parse the JSon response
                    SBJsonParser *parser     = [[SBJsonParser alloc] init];
                    NSDictionary *parsedData = [parser objectWithString:result error:nil];
                    if (parsedData != nil)
                        {
                            parsedData             = [self getJsonDictionaryFromProxyResponse:parsedData forMethod:@"GetEstArea"];
                            // Gets the token
                            NSDictionary *response = [[parsedData valueForKey:@"d"] objectForKey:@"GetEstArea"];
                            applGroup = [response objectForKey:@"ApplGroup"];
                            area      = [[response objectForKey:@"Area"] integerValue];
                            subArea   = [[response objectForKey:@"SubArea"] integerValue];
                        }
                }
            if ([self.delegate respondsToSelector:@selector(requestGetEstAreaDone:withApplGroup:andArea:andSubArea:)])
                [self.delegate requestGetEstAreaDone:self withApplGroup:applGroup andArea:area andSubArea:subArea];
        }



    - (void)dealloc
        {
            //free memory
            delegate = nil;
        }



    -(NSString *)description
        {
            NSMutableString *outputString;
            outputString = [[NSMutableString alloc] initWithCapacity:250];

            [outputString appendString:@"*** [Requester description] ***\n"];

            AzureContainer *theCurrentContainer;


            if ([arrayOfAzureContainersToGet count]>0)
                theCurrentContainer = [arrayOfAzureContainersToGet objectAtIndex:(NSUInteger)containerIndex];


            [outputString appendFormat:@"delegate                           = %@\n",delegate];
            [outputString appendFormat:@"requestType                        = %i\n",requestType];
            if(theCurrentContainer){
            [outputString appendFormat:@"currentContainer.blobs count       = %i\n",[theCurrentContainer.blobs count]];
            [outputString appendFormat:@"currentContainer.etag              = %@\n",theCurrentContainer.etag];
                }
            [outputString appendFormat:@"containerRequested                 = %@\n",containerRequested];
            [outputString appendFormat:@"containerIndex                     = %i\n",containerIndex];
            [outputString appendFormat:@"includeBlobsInToContainers         = %@\n",(includeBlobsInToContainers ? @"YES" : @"NO")];
            [outputString appendFormat:@"arrayOfAzureContainersToGet count  = %i\n",[arrayOfAzureContainersToGet count]];

            return outputString;
        }

@end
