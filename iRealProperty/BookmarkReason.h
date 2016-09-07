
#import <UIKit/UIKit.h>
#import "AxDelegates.h"

@interface BookmarkReason : UIViewController
@property (weak, nonatomic) IBOutlet UITextView *details;
@property(nonatomic, weak) id<ModalViewControllerDelegate> delegate;

@end
