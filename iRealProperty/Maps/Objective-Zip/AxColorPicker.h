#import <UIKit/UIKit.h>
#import "HRColorPickerViewController.h"

@protocol AxColorPickerDelegate
- (void)colorSelected:(UIColor*)color forTarget: (id) target;
@end

@interface AxColorPicker : UIViewController<HRColorPickerViewControllerDelegate>
{
    UILabel* hexColorLabel;
    HRColorPickerViewController *colorController;
    id<AxColorPickerDelegate> __unsafe_unretained _delegate;
    UIColor *_resultColor;
}
@property(nonatomic, strong) UIButton *target;
@property (nonatomic, unsafe_unretained) id<AxColorPickerDelegate> delegate;

@end
