#import "BaseRequest.h"
#import "SBJSON.h"

#import "ChangeSetResponse.h"


@implementation BaseRequest

// const CGFloat httpRequestTimeout = 180.0;
    const CGFloat httpRequestTimeout           = 360.0; // 3/7/13 HNN set timeout to 6 minutes because users were getting timeout errors for large updates
    const CGFloat httpDownloaderRequestTimeout = 30.0;
    NSString *const keyOfAccount     = @"StorageAccount";
    NSString *const pingSiteHostName = @"www.google.com";

// Error codes
    int const requestErr_Network_Not_Available = 1;
    int const requestErr_Network_HttpError     = 2;



//
// cancels the async request
//
    - (void)cancelRequest
        {
            if (connection != nil)
                {
                    [connection cancel];
                }
        }



//
// Parse the comming data from Data Service.
//
    + (NSDictionary *)parseData:(NSData *)content
        {
            // get parsed data
            NSString     *result     = [[NSString alloc] initWithBytes:[content bytes] length:[content length] encoding:NSUTF8StringEncoding];
            SBJsonParser *parser     = [[SBJsonParser alloc] init];
            NSDictionary *parsedData = [parser objectWithString:result error:nil];

            return parsedData;
        }



//
// Parse the comming string from Data Service.
//
    + (NSDictionary *)parseDataFromString:(NSString *)content
        {
            // get parsed data
            SBJsonParser *parser     = [[SBJsonParser alloc] init];
            NSDictionary *parsedData = [parser objectWithString:content error:nil];

            return parsedData;
        }



//
// Gets the azure account key from the response.
//
    - (NSString *)getAzureAccountFromResponse:(NSArray *)responseDict
        {
            NSString          *result;
            // Sets http requests headers
            for (NSDictionary *entityData in responseDict)
                {
                    NSString *Key = [entityData valueForKey:@"blobHeaderKey"];
                    if ([Key isEqualToString:keyOfAccount])
                        {
                            result = [entityData valueForKey:@"blobHeaderValue"];
                            break;
                        }
                }
            return result;
        }



//
// create a URL request for the data server.
//
    - (void)updateRequest:(NSMutableURLRequest *)request
                withToken:(NSString *)securityToken
        {
            NSString *authString = [NSString stringWithFormat:@"WRAP access_token=\"%@\"", securityToken];
            [request setValue:authString forHTTPHeaderField:@"Authorization"];
            [request setValue:@"Application/json" forHTTPHeaderField:@"Accept"];
            [request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
            [request setValue:@"2.0" forHTTPHeaderField:@"DataServiceVersion"];
            [request setTimeoutInterval:httpRequestTimeout];
        }



    - (void)updateRequestForFileDownload:(NSMutableURLRequest *)request
                               withToken:(NSString *)securityToken
        {
            [self updateRequest:request withToken:securityToken];
            [request setTimeoutInterval:httpDownloaderRequestTimeout];
        }



//
// Generates a NSError for request.
//
    - (NSError *)createRequestError:(NSString *)description
                           withCode:(int)code
        {
            NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
            [errorDetail setValue:description forKey:NSLocalizedDescriptionKey];
            return [[NSError alloc] initWithDomain:@"iRealProperty.Network" code:code userInfo:errorDetail];
        }



//
// convert a json string representation of a date in a NSDate. Validate thatis since 1970 the interval.
//
    + (NSDate *)getDateFromJSON:(NSString *)dateString
        {
            NSTimeInterval interval = 0;
            if (dateString != nil && [dateString length] > 0)
                {
                    int     startPos     = [dateString rangeOfString:@"("].location + 1;
                    int     endPos       = [dateString rangeOfString:@")"].location;
                    NSRange range        = NSMakeRange(startPos, endPos - startPos);
                    double  milliseconds = [[dateString substringWithRange:range] doubleValue];
                    interval = (milliseconds / 1000.0);
                }
            else
                {
                    return nil;
                }
            NSDate *pstDate = [NSDate dateWithTimeIntervalSince1970:interval];

            NSTimeZone *tzone   = [NSTimeZone timeZoneWithName:@"PST"];
            NSDate     *utcDate = [pstDate dateByAddingTimeInterval:([tzone secondsFromGMT] * -1)];

            return utcDate;
        }



//
// convert a NSDate in a json string representation of a date. Validate thatis since 1970 the interval.
//
    + (NSString *)getJSONFromDate:(NSDate *)date
        {
            if (date != nil)
                {

                    NSDateFormatter *formater = [[NSDateFormatter alloc] init];
                    [formater setTimeZone:[NSTimeZone timeZoneWithName:@"PST"]];
                    [formater setDateFormat:@"yyyy.MM.dd HH:mm:ss"];
                    NSString *formatedDate = [formater stringFromDate:date];
                    return formatedDate;
                }
            return @"";
        }



//
// get a string representing the decimal number type.
//
    + (NSString *)formattedStringWithDecimal:(NSDecimalNumber *)decimalNumber
        {
            if (decimalNumber != nil)
                {
                    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
                    [formatter setMaximumFractionDigits:2]; //two deimal spaces
                    [formatter setRoundingMode:NSNumberFormatterRoundHalfUp]; //round up

                    NSString *result = [NSString stringWithString:[formatter stringFromNumber:decimalNumber]];
                    return result;
                }
            return @"";
        }



//
// Creates a new guid.
//
    + (NSString *)createNewGuid
        {
            CFUUIDRef   theUUID = CFUUIDCreate(NULL);
            CFStringRef string  = CFUUIDCreateString(NULL, theUUID);
            CFRelease(theUUID);
            return (__bridge NSString *) string;
        }



//
// Parse the response of the call to odata batch method.
//
    - (NSArray *)parseBatchResponse:(NSString *)batchResponseString
        {
            NSMutableArray *resultArray     = [[NSMutableArray alloc] init];
            NSArray        *allLinedStrings = [batchResponseString componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
            if ([allLinedStrings count] > 0)
                {
                    int lineIndex = 0;
                    //NSString *bResp = [allLinedStrings objectAtIndex:lineIndex];
                    lineIndex++;
                    NSString *actLine;
                    while (lineIndex < [allLinedStrings count])
                        {
                            NSRange rangeFound = [self moveResponseTo:allLinedStrings withIndex:&lineIndex andStringToSearch:@"boundary="];
                            if (rangeFound.location != NSNotFound)
                                {
                                    actLine = [allLinedStrings objectAtIndex:lineIndex];
                                    NSString *changeSet = [actLine substringFromIndex:rangeFound.location + rangeFound.length];

                                    rangeFound = [self moveResponseTo:allLinedStrings withIndex:&lineIndex andStringToSearch:@"HTTP/1.1 "];
                                    if (rangeFound.location != NSNotFound)
                                        {
                                            actLine = [allLinedStrings objectAtIndex:lineIndex];
                                            NSString *requestResult = [actLine substringFromIndex:rangeFound.location + rangeFound.length];

                                            rangeFound = [self moveResponseTo:allLinedStrings withIndex:&lineIndex andStringToSearch:@"Content-ID: "];

                                            if (rangeFound.location != NSNotFound)
                                                {
                                                    actLine = [allLinedStrings objectAtIndex:lineIndex];
                                                    NSString *contentId = [actLine substringFromIndex:rangeFound.location + rangeFound.length];

                                                    rangeFound = [self moveResponseTo:allLinedStrings withIndex:&lineIndex andStringToSearch:@"{"];
                                                    if (rangeFound.location != NSNotFound)
                                                        {
                                                            NSString *jsonRequestResponse = @"";
                                                            NSString *closingChangeSet    = [NSString stringWithFormat:@"--%@--", changeSet];
                                                            actLine                       = [allLinedStrings objectAtIndex:lineIndex];
                                                            while (![closingChangeSet isEqualToString:actLine])
                                                                {
                                                                    jsonRequestResponse = [jsonRequestResponse stringByAppendingString:actLine];
                                                                    lineIndex++;
                                                                    actLine = [allLinedStrings objectAtIndex:lineIndex];
                                                                }
                                                            lineIndex++;
                                                            ChangeSetResponse *csResponse = [[ChangeSetResponse alloc] initWithResponse:requestResult andContentId:[contentId intValue] andResponseJsonContent:jsonRequestResponse];
                                                            [resultArray addObject:csResponse];
                                                        }
                                                    else
                                                        break;
                                                }
                                            else
                                                break;
                                        }
                                    else
                                        break;
                                }
                            else
                                break;
                        }
                }
            return resultArray;
        }



//
// Moves to the searched line in to responsesbyLine array.
//
    - (NSRange)moveResponseTo:(NSArray *)responsesByLine
                    withIndex:(int *)actualIndex
            andStringToSearch:(NSString *)strToSearch
        {
            NSString *actLine;
            NSRange strRange;
            while (*actualIndex < [responsesByLine count])
                {
                    actLine  = [responsesByLine objectAtIndex:*actualIndex];
                    strRange = [actLine rangeOfString:strToSearch];
                    if (strRange.location != NSNotFound)
                        {
                            return strRange;
                        }

                    (*actualIndex)++;
                }
            return strRange;
        }



//
// Process the response from the proxy service.
//
    - (NSDictionary *)getJsonDictionaryFromProxyResponse:(NSDictionary *)responseDictionary
                                               forMethod:(NSString *)methodName
        {
            SBJsonParser *parser      = [[SBJsonParser alloc] init];
            NSString     *strResponse = [[responseDictionary valueForKey:@"d"] objectForKey:methodName];
            return [parser objectWithString:strResponse error:nil];
        }



//
// Process the response from the proxy service.
//
    - (NSString *)getStringFromProxyResponse:(NSDictionary *)responseDictionary
                                   forMethod:(NSString *)methodName
        {
            NSString *strResponse = [[responseDictionary valueForKey:@"d"] objectForKey:methodName];
            return strResponse;
        }



    - (NSData *)executeRequestForURL:(NSURL *)url
                           withToken:(NSString *)securityToken
                            andError:(NSError **)error
        {
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:httpRequestTimeout];
            [self updateRequest:request withToken:securityToken];

            NSURLResponse *response = nil;
            NSData        *content  = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:error];
            // error is a network related error
            if (*error == nil)
                {
                    *error = [self getErrorFromURLResponse:response];
                    if (*error == nil)
                        return content;
                    else
                        return nil;
                }
            return nil;
        }



    - (NSError *)getErrorFromURLResponse:(NSURLResponse *)response
        {
            NSError           *myError  = nil;
            NSHTTPURLResponse *httpResp = (NSHTTPURLResponse *) response;
            int resultStatus = (int) [httpResp statusCode];
            if ((resultStatus != 200) && (resultStatus != 202))
                {
                    myError = [self createRequestError:[NSString stringWithFormat:@"Http error, request status code returned: %i", resultStatus] withCode:resultStatus];
                }
            return myError;
        }


@end
