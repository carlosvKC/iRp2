#import <UIKit/UIKit.h>
@class BaseNote;

@interface OptionList : UITableViewController<UIPopoverControllerDelegate>
{
    UIPopoverController *_popover;
}
@property(nonatomic, strong) NSArray *options;
@property(nonatomic, weak) BaseNote *itsController;

-(void)showOptions:(CGRect)rect inView:(UIView *)view;
@end
