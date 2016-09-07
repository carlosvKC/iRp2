#import <UIKit/UIKit.h>
#import "ScreenController.h"
#import "AxDelegates.h"
#import "TabBase.h"

@interface DialogGrid :  TabBase<UITextFieldDelegate, CheckBoxDelegate, ComboBoxDelegate>

// Set the title of the dialog box
-(void)setDialogTitle:(NSString *)title;

// Delegate for all the actions on the modal box
@property(nonatomic, weak) id<ModalViewControllerDelegate> delegate;

@end
