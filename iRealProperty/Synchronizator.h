
@protocol SynchronizatorDelegate;
#import <Foundation/Foundation.h>
#import "Requester.h"
#import "EntityStartStatus.h"
#import "CalcEstimationParameter.h"
#import "SyncErrorInformation.h"

typedef enum enumSyncDirection
{
    syncDirectionUpload = 0,
    syncDirectionDownload = 1
} syncDirection;

typedef enum enumSyncStatus
{
    syncStatusPending = 0,
    syncStatusInProgress = 1,
    syncStatusDownloaded = 2,
    syncStatusProcessed = 3,
    syncStatusDone = 4
} syncStatus;

typedef enum enumSyncStep
{
    syncStepUploadingEntities = 0,
    syncStepMovingDataFromSyncToPrep = 1,
    syncStepGetValidationErrors = 2,
    syncStepPopulatingPrepTables = 3,
    syncStepDownloadingEntites = 4,
    SyncStepProcessingDownloadedEntities = 5
} syncStep;

@interface Synchronizator : NSObject <RequesterDelegate, UIAlertViewDelegate>
{
    id <SynchronizatorDelegate> delegate;
    int actualEntityKindIndex;
    NSString *syncStagingGUID;
    bool syncInProgress;
    NSString *dataServiceURL;
    syncDirection actualSyncDirection;
    NSManagedObjectContext *syncContext;
    NSManagedObjectContext *prefContext;
    NSDate *lastSyncDate;
    NSString *valErrorSyncGuid;
    int totalImagesToUpload;
    double serverSyncDate;
    bool continueAutomaticSync;
}

@property(nonatomic, retain) id <SynchronizatorDelegate> delegate;
@property(nonatomic, strong) Requester *requester;
@property(nonatomic, strong) NSString *securityToken;
@property(nonatomic) BOOL forceRestart;
@property(nonatomic, strong) NSArray *entitiesToSync;
@property(nonatomic, strong) NSString *imageDatabasePath;
@property(nonatomic, strong) NSString *blobServiceURL;
@property(nonatomic, strong) NSString *area;
@property(nonatomic) BOOL downloadSyncInProgress;
@property (strong, nonatomic)UIAlertView *alert;
@property(nonatomic) int notSyncedEntities;
@property(nonatomic) int entitiesToSyncCount;

-(id)init:(NSString *)serviceURL;

-(void)executeUploadEntitesSynchronous:(NSMutableArray *)entityKinds;

-(void)executeGetEntityListToUpload;

-(void)dumpChangedEntities;

-(void)executeFullSyncCircle:(NSMutableArray *)entityKinds;

//-(void)executeSyncEntitiesForCalculateEstimates:(CalcEstimationParameter *)paraData;
// Create the list of entities to be uploaded
-(NSMutableArray *)createEntityList;

-(void)executeAutomaticDownload;

-(void)createBookmark:(SyncErrorInformation *)valError;

-(void)unload;
@end

//
// Synchronizator delegate protocol definition
//
@protocol SynchronizatorDelegate <NSObject>

@required

// will be called each time error has been received
-(void)synchronizatorRequestDidFail:(Synchronizator *)s withError:(NSError *)error;

// will be called each time validation errors has been received
-(void)synchronizatorRequestDidFailByValidationErrors:(Synchronizator *)s withSyncGuid:(NSString *)syncGuid andErrors:(NSArray *)errors;

@optional

// will be called each time when an upload entity sync starts.
-(void)synchronizatorUploadOneEntityStarts:(EntityStartStatus *)status;

// will be called when the Move data process from sync to prep starts.
-(void)synchronizatorMoveDataFromSyncToPrepStarts:(Synchronizator *)s;

// will be called when the upload pictures starts.
-(void)synchronizatorUploadingPictureStarts:(Synchronizator *)s actualPicture:(int)actualPicture numberOfPicturesToUpload:(int)totalPicturesToUpload;

// will be called when the upload entities process is done.
-(void)synchronizatorUploadEntitiesDone:(Synchronizator *)s;

// will be called when the Download entities process is done.
-(void)synchronizatorDownloadEntitiesDone:(Synchronizator *)s;

// will be called each time when a download entity sync starts.
-(void)synchronizatorDownloadOneEntityStarts:(EntityStartStatus *)status;

-(void)synchronizatorBeforeStartSync:(NSArray *)entitiesToDownload;

// Called with a new text message
-(void)synchronizatorDownloadMessage:(NSString *)string;

//will be called when the get entity list to update is done.
-(void)synchronizatorGetEntityListToUploadDone:(NSArray *)entitiesToUpload lastSyncDate:(NSDate *)lastSyncDate;

// will be called when the Sync entities for calculate estimates process is done.
-(void)synchronizatorSyncEntitiesForCalculateEstimatesDone:(Synchronizator *)s;

// Update message to end-user
-(void)indicatorMessage:(NSString *)message;

-(void)finishAlert;
@end
