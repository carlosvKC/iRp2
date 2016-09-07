

@protocol SyncManagerDelegate;

#import <Foundation/Foundation.h>
#import "Downloader.h"

@interface SyncManager : NSObject <DownloaderDelegate>
{
    Downloader *downloader;
    BOOL downloadInProgress;
    
    NSString *dataServiceUrl;
    NSString *securityToken;
}

@property(nonatomic, retain) id <SyncManagerDelegate> delegate;

@property(nonatomic) CGFloat floatReceivedData;

-(id)initWithServiceURL:(NSString *)serviceURL securityToken:(NSString *)token;

-(void)downloadFileFromAzure:(NSString *)fileName inContainer:(NSString *)containerName withFileLength:(unsigned long long)fileLength toThisPath:(NSString *)destinyPath resumingDownload:(BOOL)resumeDownload;

-(void)cancelDownloadAzureFile;

@end


@protocol SyncManagerDelegate <NSObject>

@required
-(void)downloadAzureFileDidFail:(SyncManager *)sm withError:(NSError *)error; //will be called when error is recived

@optional
-(void)downloadAzureFileDidReceiveData:(SyncManager *)sm; //will be called each time data has been received
-(void)downloadAzureFileDidLoadData:(SyncManager *)sm; //will be called when the download has finished

@end