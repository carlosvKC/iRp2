#import <UIKit/UIKit.h>
#import "OptionsList.h"
#import "ControlBar.h"
#import "LeftOption.h"
#import "KLockScreenController.h"
#import "Synchronizator.h"


@interface TabOptionsController : UIViewController <MenuBarDelegate, KLockScreenControllerDelegate, SynchronizatorDelegate, UIAlertViewDelegate> {
        OptionsList *_optionsList;
        LeftOption  *_leftOption;
        ControlBar  *menuBar;
        BOOL _validLock;

    @private
        Synchronizator *sync;
        UIView         *navView;
    }


    @property(strong, nonatomic) IBOutlet UIView *mainView;
    @property(weak, nonatomic) IBOutlet UIView   *optionsLeftView;
    @property(weak, nonatomic) IBOutlet UIView   *optionsListView;
    @property(atomic, strong) OptionsList        *optionsList;

    - (void)changeLock;

    - (void)startAreaManagement;

    - (void)syncNow;
@end
