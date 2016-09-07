#import <UIKit/UIKit.h>
#import "DialogGrid.h"
#import "AxDelegates.h"
@class PictureDetails;
@class MediaNote;

@interface DialogBoxNote : DialogGrid<ModalViewControllerDelegate>
{
    UIImage     *noteImage;
    NSString    *description;
    BOOL        primary;
}
- (IBAction)showPictures:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *textHelp;
-(void)refreshMedias;
@end
