#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ComboBoxPopOver.h"
#import "AxDelegates.h"


@class ComboBoxController;


@interface DialogBoxGetYear : UIViewController <UITextFieldDelegate, ComboBoxDelegate, ComboBoxPopOverDelegate> {
        ComboBoxPopOver *dropdownMenu;
        NSMutableArray  *yearValues;
    }

    @property(weak, nonatomic) UITextField *dataField;

    @property(nonatomic, weak) id <ModalViewControllerDelegate> delegate;
    @property(weak, nonatomic) IBOutlet UIButton *dropdownButton;

    - (IBAction)dropdownAction:(id)sender;

@end
