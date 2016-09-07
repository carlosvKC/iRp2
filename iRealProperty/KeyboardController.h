#import <UIKit/UIKit.h>


@interface KeyboardController : UIViewController <UITextFieldDelegate, UITextViewDelegate>
{
    CGRect keyboardControllerViewFrame;
    UIViewController *keyboardController;
    int extraOffset;
    UITextField *activeTextField;
    enum
    {
        kOrientationPortrait = 0,
        kOrientationLandscape = 1
    } _currentOrientation; 

}
@property(nonatomic, weak) UIResponder *firstResponder;

- (void)registerForKeyboardNotifications:(UIViewController *)newController withDelta:(int)height;
- (void)registerForKeyboardNotifications;
- (void)deregisterFromKeyboardNotifications;
- (void)textFieldDidBeginEditing:(UITextField *)textField;
- (void)textFieldDidEndEditing:(UITextField *)textField;
@end
