
#import <Foundation/Foundation.h>

extern const CGFloat httpRequestTimeout;
extern const CGFloat httpDownloaderRequestTimeout;
extern NSString * const keyOfAccount;
extern NSString * const pingSiteHostName;
extern int const requestErr_Network_Not_Available;
extern int const requestErr_Network_HttpError;

@interface BaseRequest : NSObject
{
    NSURLConnection* connection;
    NSString *dataServiceURL;
}


-(NSString *)getAzureAccountFromResponse:(NSArray *)responseDict;
-(void) updateRequest: (NSMutableURLRequest*) request withToken:(NSString *)securityToken;

-(void) updateRequestForFileDownload: (NSMutableURLRequest*) request withToken:(NSString *)securityToken;

-(NSError *) createRequestError:(NSString *)description withCode:(int)code;
-(void)cancelRequest;
-(NSArray *)parseBatchResponse:(NSString *)batchResponseString;

+(NSDate*) getDateFromJSON: (NSString*)dateString;
+(NSString*) getJSONFromDate: (NSDate*)date;
+(NSString *)formattedStringWithDecimal:(NSDecimalNumber *)decimalNumber;
+ (NSString *)createNewGuid;
+ (NSDictionary*) parseData: (NSData*) content;
+ (NSDictionary*) parseDataFromString: (NSString*) content;

-(NSDictionary *)getJsonDictionaryFromProxyResponse:(NSDictionary *)responseDictionary forMethod:(NSString *)methodName;

-(NSString *)getStringFromProxyResponse:(NSDictionary *)responseDictionary forMethod:(NSString *)methodName;

-(NSData *)executeRequestForURL:(NSURL *) url withToken:(NSString *)securityToken andError:(NSError **)error;

-(NSError *)getErrorFromURLResponse:(NSURLResponse*)response;

@end
