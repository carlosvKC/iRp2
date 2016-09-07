#import <UIKit/UIKit.h>
#import "AxDelegates.h"

@interface DatePicker : UIViewController
{
    UIPopoverController *popoverController;
}
- (id)initWithParams:(UIView *)cmbView destRect:(CGRect)rect date:(NSDate *)date;
@property(nonatomic, weak) id<ComboBoxPopOverDelegate> delegate;

@end
