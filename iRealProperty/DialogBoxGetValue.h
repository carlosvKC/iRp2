#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ComboBoxPopOver.h"
#import "AxDelegates.h"


@class ComboBoxController;


@interface DialogBoxGetValue : UIViewController <UITextFieldDelegate, ComboBoxDelegate, ComboBoxPopOverDelegate> {
        ComboBoxPopOver *dropdownMenu;
        NSMutableArray  *values;
    }

    @property(weak, nonatomic) IBOutlet UITextField *textArea;
    @property(weak, nonatomic) IBOutlet UITextField *textSubArea;
    @property(weak, nonatomic) IBOutlet UITextField *textApplGroup;

    @property(nonatomic, weak) id <ModalViewControllerDelegate> delegate;
    @property(weak, nonatomic) IBOutlet UIButton *dropdownButton;

    - (IBAction)dropdownAction:(id)sender;

@end
