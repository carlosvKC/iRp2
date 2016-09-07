
#import <UIKit/UIKit.h>
#import "SyncValidationError.h"

@protocol SyncValidationErrorDelegate <NSObject>

-(void)syncValidationOpenObject:(SyncValidationError *)error;

@end

@interface SyncFilesError : UITableViewController

@property(nonatomic, weak) id<SyncValidationErrorDelegate> delegate;

@end
