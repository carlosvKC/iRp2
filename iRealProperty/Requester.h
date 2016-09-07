@protocol RequesterDelegate;

#import <Foundation/Foundation.h>
#import "BaseRequest.h"


typedef enum enumRequestType {
    typeUserLogin                        = 0,
    typeGetEntities                      = 1,
    typeGetAuthorizationForContainerList = 2,
    typeGetAzureContainerList            = 3,
    typeGetAuthorizationForBlobList      = 4,
    typeGetAzureBlobList                 = 5,
    typeUploadNewEntities                = 6,
    typeMoveDataToPrepTables             = 7,
    typeGetEstArea                       = 8,
    typeCalculateEstimates               = 9
} RequestTypeValue;


@interface Requester : BaseRequest {
        id <RequesterDelegate> delegate;
        RequestTypeValue       requestType;
        NSMutableData  *responseData;
        NSString       *requestedEntitykind;
        NSString       *containerRequested;
        NSMutableArray *arrayOfAzureContainersToGet;
        NSString       *requestSecurityToken;
        int  containerIndex;
        BOOL includeBlobsInToContainers;
    }

    @property(nonatomic, retain) id <RequesterDelegate> delegate;
    @property(nonatomic, strong) NSString *blobServiceURL;
    @property(nonatomic, strong) NSString *containerRequested;

    - (id)init:(NSString *)serviceURL;

// log agains the service -- the delegate will be called back
    - (void)executeLogin:(NSString *)userName
            withPassword:(NSString *)password;

    - (void)executeGetEstAreaAsynchronous:(int)realPropId
                                withTaxYr:(int)taxYr
                               usingToken:(NSString *)securityToken;

    - (void)executeGetEstAreaAsynchronousRpGuid:(NSString *)rpGuid
                                withTaxYr:(int)taxYr
                               usingToken:(NSString *)securityToken;
    - (void)executeGetEntitiyAsynchronous:(NSString *)entityKind
                               usingToken:(NSString *)securityToken;

    - (void)executeGetAzureContainersList:(NSString *)securityToken
                           includingBlobs:(BOOL)includeBlobs;

    - (void)executeGetAzureBlobList:(NSString *)container
                          withToken:(NSString *)securityToken;

    - (NSError *)executeUploadNewEntitiesSync:(NSArray *)newEntities
                                       ofKind:(NSString *)kind
                                    withToken:(NSString *)securityToken;

    - (void)executeUploadNewEntitiesAsync:(NSArray *)newEntities
                                   ofKind:(NSString *)kind
                                withToken:(NSString *)securityToken;

    - (NSError *)executeMoveDataToPrepTablesWithStagingGuidSync:(NSString *)stagingGUID
                                                      withToken:(NSString *)securityToken
                                            andValidationErrors:(NSMutableArray **)validationErrorArray;

    - (NSString *)executeGetEntitiySynchronous:(NSString *)entityKind
                                    usingToken:(NSString *)securityToken
                               withStagingGuid:(NSString *)stagingGuid
                                     withError:(NSError **)error;

    - (NSData *)executeDownloadBlobFromWebServiceSynchronous:(NSString *)fileName
                                                  usingToken:(NSString *)securityToken
                                                   withError:(NSError **)error;

    - (NSError *)executeUploadBlobToWebServiceSynchronous:(NSData *)blob
                                             withFileName:(NSString *)fileName
                                               usingToken:(NSString *)securityToken
                                          andEscapedToken:(NSString *)escapedSecurityToken;

    - (NSArray *)executeCalculateEstimatesSync:(NSString *)stagingGuid
                                         TaxYr:(int)taxYr
                                          Area:(int)area
                                       subArea:(int)subArea
                                  andApplGroup:(NSString *)applGroup
                                     withToken:(NSString *)securityToken
                                         error:(NSError **)error;

    - (double)executeGetServerDateWithToken:(NSString *)securityToken
                                  withError:(NSError **)error;

    - (void)executePopulatePrepTablesForStagingGuid:(NSString *)StagingGuid
                                       LastSyncDate:(double)lastSyncDate
                                               Area:(NSString *)area
                                           andToken:(NSString *)securityToken
                                          withError:(NSError **)error;

    - (NSArray *)executeGetEntitiesToDownload:(NSString *)StagingGuid
                                    withToken:(NSString *)securityToken
                                    withError:(NSError **)error;

    - (NSArray *)executeGetValidationErrors:(NSString *)StagingGuid
                                  withToken:(NSString *)securityToken
                                  withError:(NSError **)error;

    - (BOOL)executeIsFileOnServer:(NSString *)fileName
               usingSecurityToken:(NSString *)securityToken
                        withError:(NSError **)error;

    - (NSString *)getEscapedToken:(NSString *)securityToken
                        withError:(NSError **)error;

@end


//
// Request delegate protocol definition
//
@protocol RequesterDelegate <NSObject>

@required
    - (void)requestDidFail:(Requester *)r
                 withError:(NSError *)error; //will be called each time data has been received

@optional
//will be called each time data has been received
    - (void)requestDidReceiveData:(Requester *)r;

//will be called when the login process is done
    - (void)requestLoginDone:(Requester *)r
                   loginInfo:(NSDictionary *)loginInfo;

//will be called when the entity get process is done
    - (void)requestEntitiesDone:(Requester *)r
                   withEntities:(NSArray *)Entities
                         ofKind:(NSString *)entityKind;

//will be called when the get Azure containers process is done
    - (void)requestGetAzureContainersListDone:(Requester *)r
                               withContainers:(NSArray *)containers;

//will be called when the get Azure blobs for an container process is done
    - (void)requestGetAzureBlobsListDone:(Requester *)r
                               withBlobs:(NSArray *)blobs;

// will be called when the get entities process is done
    - (void)requestUploadEntitiesDone:(Requester *)r;

// will be called when the request to move data from sync to prep is done.
    - (void)requestMoveDataFromSyncToPrepDone:(Requester *)r;

    - (void)requestGetEstAreaDone:(Requester *)r
                    withApplGroup:(NSString *)applGroup
                          andArea:(int)area
                       andSubArea:(int)subArea;

@end