#import "FilesSync.h"
#import "SyncFiles.h"
#import "RealPropertyApp.h"
#import "Helper.h"


@implementation SyncFiles

    @synthesize mode = _mode;
    @synthesize delegate;



    - (id)init
        {
            self = [super init];
            if (self)
                {
                }
            return self;
        }



    - (void)requestDidFail:(Requester *)r
                 withError:(NSError *)error
        {
            if ([delegate respondsToSelector:@selector(syncFileRequestDidFail:withError:)])
                [delegate syncFileRequestDidFail:r withError:error];
            else
                    NSLog(@"%@", error);
        }



    - (void)requestGetAzureContainersListDone:(Requester *)r
                               withContainers:(NSArray *)containers
        {

        }






    //
    // Adds/Updates the ETags for the container named areaName
    //
    - (void)createETags:(NSString *)areaName
       andDownloadFiles:(BOOL)yesOrNo
        {
            if (yesOrNo)
                _mode = kDownloadNewFilesForChangedBlobs;
            else
                _mode = kAddOrUpdateFilesSyncRecords;

            // Find out if a configuration instance can be obtained before continuing.
            Configuration *config = [RealPropertyApp getConfiguration];

            if (config == nil)
                return;

            requester = [[Requester alloc] init:[RealPropertyApp getDataUrl]];
            requester.delegate = self;

            // Get the list of files (blobs) for the areaName (container), which could be "common" or "Area##"
            // When this async call returns, it will branch to kAddOrUpdateFilesSyncRecords in handler.
            [requester executeGetAzureBlobList:areaName withToken:config.simpleToken];
        }



    //
    // This method looks for files that have changed since last load, and via requestGetAzureBlobsListDone:withBlobs:
    // it will download the new files.  As of now, this only happens via the Options Tab Page when the user taps the
    // tableview cell to start the download of changed files.
    //
    - (void)downloadNewFiles
        {
            _mode = kDownloadNewFilesForChangedBlobs;

            // Get the default area
            Configuration *config = [RealPropertyApp getConfiguration];

            if (config == nil)
                return;

            // HNN 2/5/13  don't put realproperty.sqlite and production.sqlite in the cloud or else the
            // all files are up-to-date could wipe out the local realproperty.sqlite and production.sqlite
            // which would cause the user to lose all their changes they need to initially load the
            // data from iTunes so that this feature only gets the latest xml and layers.sqlite from the cloud

            // Get the list of AreaXX blobs
            NSString *areaName = [[Helper versionSpecificContainerName:config.currentArea] lowercaseString];
            requester = [[Requester alloc] init:[RealPropertyApp getDataUrl]];
            requester.delegate = self;
            [requester executeGetAzureBlobList:areaName withToken:config.simpleToken];

            // Get the list of common blobs
            requesterCommon = [[Requester alloc] init:[RealPropertyApp getDataUrl]];
            requesterCommon.delegate = self;
            [requesterCommon executeGetAzureBlobList:[Helper versionSpecificContainerName:@"common"] withToken:config.simpleToken];
        }



    // ..........A SAMPLE OF *azureObtainedBlobs LOOKS LIKE THIS..........
    //  - - - - - - - - - - - - - - - - - - -
    //  blob name:           LUItem2.sqlite3
    //  blob type:           BlockBlob
    //  blob length          559104
    //  blob eTag:           0x8D106BA510CE434
    //  blob lastModifDate:  Wed, 05 Mar 2014 18:46:12 GMT
    //  blob url:            http://irealproperty.blob.core.windows.net/common/LUItem2.sqlite3
    //  - - - - - - - - - - - - - - - - - - -
    //  blob name:           SearchDefinition.xml
    //  blob type:           BlockBlob
    //  blob length          30682
    //  blob eTag:           0x8D139D9DE3C5537
    //  blob lastModifDate:  Fri, 09 May 2014 20:10:33 GMT
    //  blob url:            http://irealproperty.blob.core.windows.net/common/SearchDefinition.xml
    //  - - - - - - - - - - - - - - - - - - -
    //  blob name:           iRealProperty.xml
    //  blob type:           BlockBlob
    //  blob length          98158
    //  blob eTag:           0x8D153D2C0461670
    //  blob lastModifDate:  Wed, 11 Jun 2014 21:25:07 GMT
    //  blob url:            http://irealproperty.blob.core.windows.net/common/iRealProperty.xml
    //
    - (void)requestGetAzureBlobsListDone:(Requester *)r
                               withBlobs:(NSArray *)azureObtainedBlobs
        {
            if (_mode == kAddOrUpdateFilesSyncRecords)
                {
                    [Helper addOrUpdateFilesSyncRecordsForContainer:r.containerRequested withAzureBlobs:azureObtainedBlobs];
                    _mode = kSyncComplete;
                }
            else if (_mode == kDownloadNewFilesForChangedBlobs)
                {
                    NSMutableArray *changedBlobs;

                    changedBlobs = [Helper countChangedETagsForContainer:r.containerRequested withAzureBlobs:azureObtainedBlobs];

                    // RealPropertyApp does not respond to the downloadTheseChangedBlobs selector below, which means when this code is called
                    // from [RealPropertyApp resumeApplication] download blobs will not be called. (common files won't be downloaded)
                    if ([delegate respondsToSelector:@selector(downloadTheseChangedBlobs:forContainer:)])
                        [delegate downloadTheseChangedBlobs:changedBlobs forContainer:r.containerRequested];
                }
        }


    - (NSString *)description
        {
            NSMutableString *outputString;
            outputString = [[NSMutableString alloc] initWithCapacity:250];

            NSString *theMode;
            if (_mode == 0)
                theMode = @"kSyncComplete";
            else if (_mode == 1)
                theMode = @"kAddOrUpdateFilesSyncRecords";
            else
                theMode = @"kDownloadNewFilesForChangedBlobs";


            [outputString appendString:@"\n*** SyncFiles ***\n"];
            [outputString appendFormat:@"_mode             = %@\n", theMode];
            [outputString appendFormat:@"delegate          = %@\n", delegate];

            return outputString;
        }


@end
