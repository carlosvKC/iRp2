#import <UIKit/UIKit.h>
#import "RealProperty.h"
#import "AxDelegates.h"
#import "RealProperty.h"
@class CheckBoxView;
@class InspectionManager;

@interface ImpsViewController : UIViewController<CheckBoxDelegate>
    {
        CheckBoxView *chkImps;
        CheckBoxView *chkLand;
        CheckBoxView *chkBoth;
        
        InspectionManager *inspection;
        
        RealPropInfo    *realPropInfo;
    }

    - (id)initWihRealPropInfo:(RealPropInfo *)propInfo nibName:(NSString *)nibNameOrNil;

    @property(nonatomic, weak) RealProperty *itsController;

@end
