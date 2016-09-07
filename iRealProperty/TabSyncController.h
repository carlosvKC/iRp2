
#import <UIKit/UIKit.h>
#import "Synchronizator.h"
#import "ATActivityIndicator.h"
#import "SyncFilesError.h"
#import "DumpSyncInfo.h"

@interface TabSyncController : UIViewController<SynchronizatorDelegate, UITableViewDelegate, UIAlertViewDelegate, SyncValidationErrorDelegate>
{
    Synchronizator *sync;
    NSThread *syncThread;
    ATActivityIndicator *activity;
    BOOL    inSync;
    UIAlertView *alert;
    SyncFilesError *errorDialog;
    UIAlertView *clearError;
    SyncValidationError *validationError;
    DumpSyncInfo *syncInfoDialog;
    UIView      *navView;
}

- (IBAction)startSyncPressed:(id)sender;

@property(nonatomic) BOOL syncStarted; // 8/21/13 HNN need to prevent double taps of sync button to start another sync
@property (weak, atomic) IBOutlet UILabel *syncLabel;

@property (weak, atomic) IBOutlet UIProgressView *syncProgressBar;

- (IBAction)downloadSyncPressed:(id)sender;
-(void)stopSyncIndicators;
-(void)startSyncIndicators:(NSString *)message;
-(void)indicatorMessage:(NSString *)message;


@property (weak, nonatomic) IBOutlet UITableView *syncTableView;

@property (weak, nonatomic) IBOutlet UILabel *syncLastDate;
@property (weak, nonatomic) IBOutlet UILabel *syncDate;
@property (weak, nonatomic) IBOutlet UILabel *syncWarning;
- (IBAction)createSyncError:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *bookmarkError;
- (IBAction)testDownload:(id)sender;


@property (weak, nonatomic) IBOutlet UILabel *activityLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end
