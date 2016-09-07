/*
*   I imported this file into this project from the "corrupt" project on 2013-10-07
*   I believe at this time, this will be the latest copy of this file.
*/

#import "AzureBlobFilesInfoForContainer.h"
#import "AzureBlob.h"
#import "DaveGlobals.h"
#import "SBJsonParser.h"
#import "XMLReader.h"
#import "AzureFileStatusChecker.h"
#import "RealPropertyApp.h"


typedef enum enumNextAzureStep {
    parseAzureAuthorization = 0,
    parseAzureBlobs         = 1
} NextAzureStep;


// Makes an asynch web request for a particular container (AreaXX or common).
@implementation AzureBlobFilesInfoForContainer {

    @private
        NextAzureStep requestType;
        NSURLConnection *myConnection;
        NSMutableData   *responseData;
        NSString        *dataServiceURL;
        NSString        *theSecurityToken;
        id <AzureBlobRequestCompletedDelegate> theBlobsDelegate;

    @public
        // Accessible from anywhere, even outside this code image (app or library)
    @protected
        // Declarations here are accessible only by this class and it's subclasses
    @package
        // Accessible from anywhere in the current code image (app or library)
    }


    // Because init is inherited from NSObject, I don't think I can just leave this method out, and just as bad, I have to provide a
    // method implementation that doesn't make sense because I don't think it's possible to forbid creators from calling this method.
    - (id)init
        {
            return [self initWithContainerName:@"" andSecurityToken:nil andDelegate:nil];
        }



    //
    // Supply nil to AzureFileStatusChecker if you don't need those services, and are only after a list of blobs for the specified container.
    //
    - (id)initWithContainerName:(NSString *)azureFolderName
               andSecurityToken:(NSString *)securityToken
                    andDelegate:(id <AzureBlobRequestCompletedDelegate>)delegate
        {
            self = [super init];
            if (self)
                {
                    // NSLog(@"The container name is %@", azureFolderName);

                    self.webRequestedAzureBlobs = [[NSMutableArray alloc] init];
                    self.containerToRetrieve    = [azureFolderName lowercaseString];

                    dataServiceURL   = [RealPropertyApp getDataUrl];
                    theSecurityToken = [[NSString alloc] initWithString:securityToken];
                    theBlobsDelegate = delegate;
                }

            return self;
        }



    - (void)kickoffAzureRequest
        {
            if ([self.containerToRetrieve length] > 0)
                [self getAzureAuthorizationForContainer];
        }



//
// Get the blob list from Windows Azure blob storage container
//
    - (void)getAzureAuthorizationForContainer
        {
            //NSLog(@"Enter");

            // Apparently it's mandatory to specify a container you're interested in
            // in the authorization request, otherwise you'll get back an HTTP 403 error.  (2013-09-19)

            // Also, the container name MUST be in LOWERCASE otherwise you'll get HTTP error 400.

            requestType = parseAzureAuthorization;

            NSString *baseUrl = [NSString stringWithFormat:@"%@/%@?type='%@'&Container='%@'&Blob='%@'&offSet=%d&endByte=%d",
                                                           dataServiceURL, @"GetBlobHeaderInformation", @"getlistblobs", [self containerToRetrieve], @"", 0, 0];


            NSURL               *url       = [NSURL URLWithString:baseUrl];
            NSMutableURLRequest *myRequest = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:30];


            [self updateRequest:myRequest withToken:theSecurityToken];

            if (responseData == nil)
                responseData = [NSMutableData data];


            //[DaveGlobals debugDictionary:[myRequest allHTTPHeaderFields] withTitleMessage:@"Initiating web request with the following settings..."];

            /*
                HTTP headers and URL used to build the connection request at bottom...

                "https://info.kingcounty.gov/Assessor/iRealPropertyProxy/iRealPropertyProxy.svc/GetBlobHeaderInformation?type='getlistblobs'&Container='common'&Blob=''&offSet=0&endByte=0"

                 Authorization = WRAP access_token="http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name=kc\baund
                                                    &Issuer=http://self
                                                    &Audience=http://localhost:61719/iRealPropertyService.svc
                                                    &ExpiresOn=1379702481
                                                    &HMACSHA256=EEluGPSZoanZNfdqQCyw33RM8dodInnvT6PrCMJ%2fz%2fo%3d"
                 Accept-Encoding    = gzip
                 DataServiceVersion = 2.0
                 Accept             = Application/json
            */

            myConnection = [[NSURLConnection alloc] initWithRequest:myRequest delegate:self startImmediately:YES]; //request is sending here

            //NSLog(@"Leave");
        }



//
// Parse the authorization for blob list and call the azure method.
//
    - (void)parseAzureAuthorizationAndRequestContainerBlobList
        {
            //NSLog(@"Enter");

            requestType = parseAzureBlobs;
            // Parse Json response
            NSDictionary *parsedData = [AzureBlobFilesInfoForContainer parseData:responseData];

            /*
                The content of the parsed response data is ...
                 d = {
                    GetBlobHeaderInformation = "{
                        \"d\" : [
                        {\"__metadata\": { \"type\": \"RealPropertyModel.GetBlobHeaderInformation\" }
                            , \"blobHeaderKey\": \"StorageAccount\", \"blobHeaderValue\": \"irealproperty\"
                        }, {
                        \"__metadata\": { \"type\": \"RealPropertyModel.GetBlobHeaderInformation\" }
                            , \"blobHeaderKey\": \"x-ms-date\", \"blobHeaderValue\": \"Thu, 19 Sep 2013 23:21:27 GMT\"
                        }, {
                        \"__metadata\": { \"type\": \"RealPropertyModel.GetBlobHeaderInformation\" }
                            , \"blobHeaderKey\": \"x-ms-version\", \"blobHeaderValue\": \"2009-09-19\"
                        }, {
                        \"__metadata\": { \"type\": \"RealPropertyModel.GetBlobHeaderInformation\" }
                            , \"blobHeaderKey\": \"Authorization\", \"blobHeaderValue\": \"SharedKey irealproperty:iu7NhNyrY1dca7MazzcKhOJyVus/1j8/LOYtGp5B+7Y=\"
                        }
                        ]
                        }";
                }
			*/

            if (parsedData != nil)
                {
                    parsedData = [self getJsonDictionaryFromProxyResponse:parsedData forMethod:@"GetBlobHeaderInformation"];
                    // In JSON the base dictionary key is named "d"
                    NSArray  *JSONentities = [parsedData valueForKey:@"d"];
                    NSString *azureAccount = [self getAzureAccountFromResponse:JSONentities];  // The azure account has historically been 'irealproperty'


                    // Builds the Azure URL to download the blob file list using REST call
                    NSString *baseUrl = [NSString stringWithFormat:@"http://%@.blob.core.windows.net/%@?restype=container&comp=list&include=snapshots&include=metadata",
                                                                   azureAccount, self.containerToRetrieve];

                    NSURL               *url       = [NSURL URLWithString:baseUrl];
                    NSMutableURLRequest *myRequest = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:30];

                    // Sets http requests headers
                    for (NSDictionary *entityData in JSONentities)
                        {
                            NSString *Key = [entityData valueForKey:@"blobHeaderKey"];
                            if (![Key isEqualToString:@"StorageAccount"])
                                {
                                    NSString *Val = [entityData valueForKey:@"blobHeaderValue"];
                                    [myRequest setValue:Val forHTTPHeaderField:Key];
                                }
                        }
                    [myRequest setValue:@"irealproperty.blob.core.windows.net" forHTTPHeaderField:@"Host"];
                    [myRequest setValue:@"Keep-Alive" forHTTPHeaderField:@"Connection"];

                    //db debug results dictionary
                    //[DaveGlobals debugDictionary:[myRequest allHTTPHeaderFields] withTitleMessage:@"Initiating web request with the following settings..."];

                    /*
                      HTTP headers and URL used to build the connection request at bottom...

                      "http://irealproperty.blob.core.windows.net/common?restype=container&comp=list&include=snapshots&include=metadata"

                         Host           = irealproperty.blob.core.windows.net
                         Connection     = Keep-Alive
                         x-ms-date      = Thu, 19 Sep 2013 23:21:27 GMT
                         x-ms-version   = 2009-09-19
                         StorageAccount = irealproperty
                         Authorization  = SharedKey irealproperty:iu7NhNyrY1dca7MazzcKhOJyVus/1j8/LOYtGp5B+7Y=
                    */

                    myConnection = [NSURLConnection connectionWithRequest:myRequest delegate:self]; //request is sent async here
                }

            //NSLog(@"Leave");
        }



//
// Parse the web response that contains the list of blobs for the Azure container ("Area02" or "common" for example)
//
    - (void)parseReceivedAzureBlobListForRequestedContainer
        {
            //NSLog(@"Enter");


            NSMutableArray *resultArr  = [[NSMutableArray alloc] init];
            NSDictionary   *resultDict = [XMLReader dictionaryForXMLData:responseData error:nil];
            NSArray        *blobList   = [[[resultDict objectForKey:@"EnumerationResults"] objectForKey:@"Blobs"] objectForKey:@"Blob"];

            //db debug results dictionary
            //[DaveGlobals debugDictionary:resultDict withTitleMessage:@"Parsing the following results from the request..."];


            for (id blob in blobList)
                {
                    AzureBlob *newBlob = [[AzureBlob alloc] init:blob];
                    [resultArr addObject:newBlob];
                    [self.webRequestedAzureBlobs addObject:newBlob];
                }

            //[DaveGlobals debugAzureBlobs:resultArr withTitleMessage:@"AzureBlob objects..."];


            if (theBlobsDelegate)
                [theBlobsDelegate processTheRequestedBlobs:self];


            //NSLog(@"Leave");

        }



//
// Manage the end of the request process
//
    - (void)connectionDidFinishLoading:(NSURLConnection *)theConnection
        {

            //NSLog(@"Enter");

            switch (requestType)
                {
                    case parseAzureAuthorization:
                        [self parseAzureAuthorizationAndRequestContainerBlobList];
                        break;

                    case parseAzureBlobs:
                        //NSLog(@"Starting parseReceivedAzureBlobListForRequestedContainer for container %@", self.containerToRetrieve);
                        [self parseReceivedAzureBlobListForRequestedContainer];
                        break;

                    default:
                        break;
                }

            //NSLog(@"Operation for container %@ is done", self.containerToRetrieve);


            //NSLog(@"Leave");

        }



//
// Gets the azure account key from the response.
//
    - (NSString *)getAzureAccountFromResponse:(NSArray *)responseDict
        {
            //NSLog(@"Enter");


            NSString          *result;
            for (NSDictionary *entityData in responseDict)
                {
                    NSString *Key = [entityData valueForKey:@"blobHeaderKey"];
                    if ([Key isEqualToString:@"StorageAccount"])
                        {
                            result = [entityData valueForKey:@"blobHeaderValue"];
                            break;
                        }
                }

            //NSLog(@"The azure account parsed from the response (should be irealproperty) is ... %@", result);
            //NSLog(@"Leave");

            return result;
        }



//
// cancels the async request
//
    - (void)cancelRequest
        {
            if (myConnection != nil)
                {
                    [myConnection cancel];
                }
        }



//
// Generates a NSError for request.
//
    - (NSError *)createRequestError:(NSString *)description
                           withCode:(int)code
        {
            //db Lumberjack
            // NSLog(@"Enter");

            NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
            [errorDetail setValue:description forKey:NSLocalizedDescriptionKey];

            //db Lumberjack
            // NSLog(@"Leave");

            return [[NSError alloc] initWithDomain:@"iRealProperty.Network" code:code userInfo:errorDetail];

        }



//
// Process the response from the proxy service.
//
    - (NSDictionary *)getJsonDictionaryFromProxyResponse:(NSDictionary *)responseDictionary
                                               forMethod:(NSString *)methodName
        {
            //db Lumberjack
            // NSLog(@"Enter");

            SBJsonParser *parser      = [[SBJsonParser alloc] init];
            NSString     *strResponse = [[responseDictionary valueForKey:@"d"] objectForKey:methodName];

            //db Lumberjack
            // NSLog(@"Leave");

            return [parser objectWithString:strResponse error:nil];
        }



//
// Parse the coming data from Data Service.
//
    + (NSDictionary *)parseData:(NSData *)content
        {
            //NSLog(@"Enter");

            // get parsed data
            NSString     *result     = [[NSString alloc] initWithBytes:[content bytes] length:[content length] encoding:NSUTF8StringEncoding];
            SBJsonParser *parser     = [[SBJsonParser alloc] init];
            NSDictionary *parsedData = [parser objectWithString:result error:nil];

            //[DaveGlobals debugDictionary:parsedData withTitleMessage:@"The content of the parsed data is ..."];
            /*
                 The content of the parsed response data is ...
                  d = {
                     GetBlobHeaderInformation = "{
                         \"d\" : [
                         {\"__metadata\": { \"type\": \"RealPropertyModel.GetBlobHeaderInformation\" }
                             , \"blobHeaderKey\": \"StorageAccount\", \"blobHeaderValue\": \"irealproperty\"
                         }, {
                         \"__metadata\": { \"type\": \"RealPropertyModel.GetBlobHeaderInformation\" }
                             , \"blobHeaderKey\": \"x-ms-date\", \"blobHeaderValue\": \"Thu, 19 Sep 2013 23:21:27 GMT\"
                         }, {
                         \"__metadata\": { \"type\": \"RealPropertyModel.GetBlobHeaderInformation\" }
                             , \"blobHeaderKey\": \"x-ms-version\", \"blobHeaderValue\": \"2009-09-19\"
                         }, {
                         \"__metadata\": { \"type\": \"RealPropertyModel.GetBlobHeaderInformation\" }
                             , \"blobHeaderKey\": \"Authorization\", \"blobHeaderValue\": \"SharedKey irealproperty:iu7NhNyrY1dca7MazzcKhOJyVus/1j8/LOYtGp5B+7Y=\"
                         }
                         ]
                         }";
                 }
             */

            //NSLog(@"Leave");

            return parsedData;
        }



//
// create a URL request for the data server.
//
    - (void)updateRequest:(NSMutableURLRequest *)request
                withToken:(NSString *)securityToken
        {
            //NSLog(@"Enter");

            NSString *authString = [NSString stringWithFormat:@"WRAP access_token=\"%@\"", securityToken];
            [request setValue:authString forHTTPHeaderField:@"Authorization"];
            [request setValue:@"Application/json" forHTTPHeaderField:@"Accept"];
            [request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
            [request setValue:@"2.0" forHTTPHeaderField:@"DataServiceVersion"];
            [request setTimeoutInterval:30];

            //NSLog(@"Leave");
        }


#pragma mark - Web Request Connection State Methods

//
// Manage the response of the download request
//
    - (void)connection:(NSURLConnection *)theConnection
    didReceiveResponse:(NSURLResponse *)response
        {
            //NSLog(@"Enter");

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
                    [self cancelRequest];
                    NSError *error = [self createRequestError:[NSString stringWithFormat:@"Http error, request status code returned: %i", resultStatus] withCode:resultStatus];
                    [self requestDidFailWithError:error];
                }

            //NSLog(@"Leave");
        }



//
// Manage the chunk of bytes received
//
    - (void)connection:(NSURLConnection *)theConnection
        didReceiveData:(NSData *)data
        {
            //db Lumberjack
            //NSLog(@"Enter");

            switch (requestType)
                {
                    default:
                        [responseData appendData:data];
                    break;
                }

            //db Lumberjack
            //NSLog(@"Leave");

        }



//
// Manage the asynchronous method did fail with error
//
    - (void)connection:(NSURLConnection *)theConnection
      didFailWithError:(NSError *)error
        {
            [self requestDidFailWithError:error];
        }



//
// Manage an error in the request.
//
    - (void)requestDidFailWithError:(NSError *)error
        {
            // NSLog(@"Enter");

            [self performSelectorOnMainThread:@selector(synchronizatorRequestDidFailWithError:) withObject:error waitUntilDone:YES];

            // NSLog(@"Leave");

        }



    - (void)synchronizatorRequestDidFailWithError:(NSError *)error
        {
            // NSLog(@"Enter");
        //
        //DBaun 03/02/2014: Im going to comment this out entirely so the user will see NO alertview for a blob related error, since they don't know what to do with that error anyway
        //
        //    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Azure Blob Query Errors" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        //    [alert show];
            // Reset timer
            [[UIApplication sharedApplication] setIdleTimerDisabled:NO];

            // NSLog(@"Leave");

        }

@end