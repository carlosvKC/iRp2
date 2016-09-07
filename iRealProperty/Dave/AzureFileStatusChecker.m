//
// Created by David Baun on 9/21/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "AzureFileStatusChecker.h"
#import "AzureBlobFilesInfoForContainer.h"
#import "RealPropertyApp.h"
#import "Helper.h"


//static const int ddLogLevel = LOG_LEVEL_VERBOSE;


@implementation AzureFileStatusChecker {
    @private
        AzureBlobFilesInfoForContainer *areaRequest;
        AzureBlobFilesInfoForContainer *commonRequest;
        NSMutableArray                 *requestsQueue;
        Configuration                  *currentConfig;
        //int requestsCompleted;
        NSString                       *theContainerName;  // Could be AreaXX, TestAreaXX, Common, or TestCommon.
        id changedBlobsDelegate;


    @public
        // Accessible from anywhere, even outside this code image (app or library)
    @protected
        // Accessible only by this class and it's subclasses
    @package
        // Accessible from anywhere in the current code image (app or library)

    }


    - (id)init
        {
            self = [super init];
            if (self)
                {
                    requestsQueue = [[NSMutableArray alloc] init];
                    //requestsCompleted = 0;
                }

            return self;
        }



// For now the delegate is RealPropertyApp, and that's all this class's code was designed for.
    - (void)checkForChangedFilesInAreaAndNotifyDelegate:(id)theDelegate
        {
            currentConfig = [RealPropertyApp getConfiguration];

            if (currentConfig.currentArea == nil)
                return;

            currentConfig.lastCheckinAzureTime = [[NSDate date] timeIntervalSinceReferenceDate];

            theContainerName     = [Helper versionSpecificContainerName:currentConfig.currentArea];
            changedBlobsDelegate = theDelegate;

            if (![RealPropertyApp allowToSync])
                {
                    // NSLog(@"Skipping call to checkForChangedFilesInArea because allowToSync variable is FALSE");
                    return;
                }

            NSString *status = [RealPropertyApp reachNetwork];
            if ([status length] > 0)
                {
                    NSLog(@"Network Message: %@", status);
                    NSLog(@"Skipping call to checkForChangedFilesInArea because of network issue");
                    //NSLog(@"Leave");
                    return;
                }

            areaRequest   = [[AzureBlobFilesInfoForContainer alloc] initWithContainerName:theContainerName andSecurityToken:currentConfig.simpleToken andDelegate:self];
            commonRequest = [[AzureBlobFilesInfoForContainer alloc] initWithContainerName:[Helper versionSpecificContainerName:@"common"] andSecurityToken:currentConfig.simpleToken andDelegate:self];

            [requestsQueue addObject:areaRequest];
            [requestsQueue addObject:commonRequest];

            [areaRequest kickoffAzureRequest];
            [commonRequest kickoffAzureRequest];
        }



    // Compares the records from table named FilesSync in local database PersonalNotes.sqlite against
    // a list of files on Azure to determine if the ETag has changed on the Azure side, which would
    // indicate that we need to update files locally by downloading the updated Azure files.
    //  DBaun ~~> It would be awesome to use Notifications here so interested objects could listen, but I'm not informed enough on that yet to use it now.
    - (void)processTheRequestedBlobs:(AzureBlobFilesInfoForContainer *)theBlobRequestResults;
        {
            [requestsQueue removeObject:theBlobRequestResults];

            if ([requestsQueue count] != 0)
                return;


            // NSLog(@"*** Process results ***");
            // NSLog(@" ** Area   Request has %i blobs", [areaRequest.webRequestedAzureBlobs count]);
            // NSLog(@" ** Common Request has %i blobs", [commonRequest.webRequestedAzureBlobs count]);


            NSArray                *theFilesSyncAreasToQueryFor;
            NSArray                *filesSyncRecords;
            NSManagedObjectContext *personalNotesSqlite;
            NSPredicate            *predicate;
            NSMutableArray         *webRequestedBlobs;
            NSMutableArray         *changedBlobs;


            webRequestedBlobs = [[NSMutableArray alloc] init];


            if ([areaRequest.webRequestedAzureBlobs count] > 0)
                {
                    [Helper ensureFilesSyncRecordsExistForAzureBlobs:areaRequest.webRequestedAzureBlobs andContainer:[Helper versionSpecificContainerName:theContainerName]];
                    [webRequestedBlobs addObjectsFromArray:areaRequest.webRequestedAzureBlobs];
                }

            if ([commonRequest.webRequestedAzureBlobs count] > 0)
                {
                    [Helper ensureFilesSyncRecordsExistForAzureBlobs:commonRequest.webRequestedAzureBlobs andContainer:[Helper versionSpecificContainerName:@"common"]];
                    [webRequestedBlobs addObjectsFromArray:commonRequest.webRequestedAzureBlobs];
                }


            personalNotesSqlite = [AxDataManager noteContext];

            // DBaun NOTE: NOT SURE IF theAreaName NEEDS TO BE CASED PROPERLY IN ORDER TO WORK, BUT I'M DOING IT ANYWAY.
            // DBaun NOTE: NOT SURE HOW THIS PREDICATE WORKS... BUT IT SEEMS TO TURN THE ARRAY INTO A STRING OF VALUES FOR THE "IN" CLAUSE
            theFilesSyncAreasToQueryFor = [NSArray arrayWithObjects:[[Helper versionSpecificContainerName:theContainerName] lowercaseString], [[Helper versionSpecificContainerName:@"common"] lowercaseString], nil];
            predicate                   = [NSPredicate predicateWithFormat:@"area IN %@", theFilesSyncAreasToQueryFor];
            filesSyncRecords            = [AxDataManager dataListEntity:@"FilesSync" andSortBy:@"name" andPredicate:predicate withContext:personalNotesSqlite];
            changedBlobs                = [Helper getChangedBlobsFromAzureBlobs:webRequestedBlobs andFilesSyncRecords:filesSyncRecords];

            // NSLog(@"The FilesSync table      contains %i records", [filesSyncRecords count]);
            // NSLog(@"The web Azure Blobs list contains %i records", [webRequestedBlobs count]);
            // NSLog(@"The changed blobs count is        %i records", [changedBlobs count]);


            if ([changedBlobsDelegate respondsToSelector:@selector(updateUIWithChangedETagsInfo:)])
                {
                    // DBaun NOTE: The dispatch method is more handy because it doesn't have the same restrictions on method parameter passing as performSelectorOnMainThread.
                    dispatch_async(dispatch_get_main_queue(), ^
                        {
                            [changedBlobsDelegate updateUIWithChangedETagsInfo:[changedBlobs count]];

                        });
                }
            else
                NSLog(@"Not going to call updateUIWithChangedETagsInfo because this delegate doesn't respond to that selector.");

        }


@end




//    - (void)observeValueForKeyPath:(NSString *)keyPath
//                          ofObject:(id)object
//                            change:(NSDictionary *)change
//                           context:(void *)context
//        {
//            if (object == [NSOperationQueue mainQueue] && [@"operationCount" isEqualToString:keyPath])
//                {
//                    NSArray *operations = [change objectForKey:NSKeyValueChangeNewKey];
//
//                    if ([[NSOperationQueue mainQueue] operationCount] > 0)
//                        {
//                            NSLog(@" +++++++ Not done");
//                        }
//                    else
//                        NSLog(@"++++++++++++++++++++++++ Done");
//                }
//            NSLog(@"### ### ### The keypath is %@", keyPath);
//        }


//    -(BOOL)hasActiveOperations:(NSArray *)operations
//        {
//            for (id operation in operations)
//                {
//                    if ( [operation isExecuting] && ! [operation isCancelled])
//                        return YES;
//
//                }
//
//            return NO;
//        }




//          THIS CODE SEEMS TO WORK FINE, BUT MIGHT BE OVERKILL, SO GOING TO SEE HOW IT WORKS WITHOUT USING THIS STUFF
//            NSInvocationOperation *areaOperation         = [[NSInvocationOperation alloc] initWithTarget:areaRequest selector:@selector(kickoffAzureRequest) object:nil];
//            NSInvocationOperation *commonOperation       = [[NSInvocationOperation alloc] initWithTarget:commonRequest selector:@selector(kickoffAzureRequest) object:nil];
//            NSInvocationOperation *allOperationsFinished = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(processRequestedListOfBlobs) object:nil];
//
//            [allOperationsFinished addDependency:areaOperation];
//            [allOperationsFinished addDependency:commonOperation];
//
//            [[NSOperationQueue mainQueue] addObserver:self forKeyPath:@"operationCount" options:NSKeyValueObservingOptionNew context:Nil];
//
//            [[NSOperationQueue mainQueue] addOperation:areaOperation];
//            [[NSOperationQueue mainQueue] addOperation:commonOperation];
//            [[NSOperationQueue mainQueue] addOperation:allOperationsFinished];


//          THIS CODE WON'T WORK UNDER ANY CIRCUMSTANCES BECAUSE OF THE WAY NSURLREQUEST WORKS.
//            [myDownloadsQueue addOperation:areaOperation];
//            [myDownloadsQueue addOperation:commonOperation];
//            [myDownloadsQueue addOperation:allOperationsFinished];


/*
// DBaun NOTE: This isn't going to work because theAreaName is only one area.  What if I need to download files for "common" AND for AreaXX

            if ([changedBlobsDelegate respondsToSelector:@selector(downloadTheseChangedBlobs:forContainer:)])
                [changedBlobsDelegate downloadTheseChangedBlobs:changedBlobs forContainer:theAreaName];
            else
                NSLog(@"Not going to call downloadTheseChangedBlobs:forContainer: because this delegate doesn't respond to that selector.");
*/
