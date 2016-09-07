#import <Foundation/Foundation.h>
#import "Requester.h"
#import "Configuration.h"


enum SyncFileFlags {
    kSyncComplete = 0,
    kAddOrUpdateFilesSyncRecords = 1,
    kDownloadNewFilesForChangedBlobs = 2
};


@protocol SyncFileDelegate <NSObject>

@optional
    - (void)updateUIWithChangedETagsInfo:(int)count;

    - (void)downloadTheseChangedBlobs:(NSArray *)changedBlobs
                         forContainer:(NSString *)containerName;



    - (void)syncFileRequestDidFail:(Requester *)r
                         withError:(NSError *)error;
@end


@interface SyncFiles : NSObject <RequesterDelegate>
    {
        Requester *requester;
        Requester *requesterCommon;
        int _mode;
    }

    @property(atomic) int                            mode;
    @property(nonatomic, weak) id <SyncFileDelegate> delegate;

    - (void)createETags:(NSString *)areaName
       andDownloadFiles:(BOOL)yesOrNo;

    - (void)downloadNewFiles;

@end
