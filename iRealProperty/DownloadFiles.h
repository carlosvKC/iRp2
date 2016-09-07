#import <UIKit/UIKit.h>


@protocol DownloadFilesDelegate <NSObject>

    - (void)downloadFileTerminate:(BOOL)animated;
@end


@interface DownloadFiles : UIViewController <UIAlertViewDelegate>

    @property(weak, nonatomic) IBOutlet UITextView *textView;

    @property(weak, nonatomic) IBOutlet UIView         *cancelView;
    @property(weak, nonatomic) IBOutlet UIProgressView *progressBar;
    @property(weak, nonatomic) IBOutlet UILabel        *infoText;
    @property(weak, nonatomic) id <DownloadFilesDelegate> delegate;
    @property(nonatomic) BOOL                             saveDirectory;
    @property(nonatomic) BOOL                             hideCancel;

    -(void)downloadAzureFileDidFailWithError:(NSError *)error;
    -(void)downloadAzureFileDidReceiveDataWithLength:(NSNumber *)dataLength;
    -(void)downloadAzureFileDidLoadData;
@end

