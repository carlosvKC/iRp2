@protocol DownloaderDelegate;

#import <Foundation/Foundation.h>
#import "BaseRequest.h"


typedef enum enumDownloadSteps {
    downloadingAuthorizationKey = 0,
    downloadingBlob             = 1,
    resumingBlobDownload        = 2
} blobDownloadSteps;


@interface Downloader : BaseRequest
    {
        id <DownloaderDelegate> delegate;
        NSString            *strFileNameWithPath;
        blobDownloadSteps   downloadStage;
        NSMutableData       *responseData;
        NSString            *azureBlobName;
        NSString            *azureContainerName;
        BOOL                isResumeDownload;
        int                 numOfDownloadRetry;
        unsigned long long  blobLength;
        __strong NSFileHandle *fileHandle;
    }

    @property(nonatomic, retain) id <DownloaderDelegate> delegate;
    @property(nonatomic) CGFloat floatReceivedData;
    @property(nonatomic, retain) NSString *securityToken;
    @property(nonatomic, strong) NSString *azureContainerName;
    @property(nonatomic, strong) NSString *azureBlobName;

    - (id)initWithServiceURL:(NSString *)serviceURL
               securityToken:(NSString *)token;

    - (void)downloadFile:(NSString *)blobName
             inContainer:(NSString *)containerName
                  inPath:(NSString *)path
          withFileLength:(unsigned long long)fileLength
        resumingDownload:(BOOL)resume;

    - (NSString *)getFileName;

//    - (NSString *)descriptionWithMethodName:(NSString *)nameOfCaller
//                                   andTitle:(NSString *)titleMessage;
@end



@protocol DownloaderDelegate <NSObject>

    @required
        - (void)downloaderDidFail:(Downloader *)d
                        withError:(NSError *)error; //will be called when error is recived

    @optional
        - (void)downloaderDidReceiveData:(Downloader *)d; //will be called each time data has been received
        - (void)downloaderDidLoadData:(Downloader *)d; //will be called when the download has finished

@end

