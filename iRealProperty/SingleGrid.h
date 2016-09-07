#import <UIKit/UIKit.h>
#import "ScreenController.h"
#import "AxDelegates.h"

@class DialogGrid;

@interface SingleGrid : ScreenController
{
    // Its current dialog box
    DialogGrid *itsDialogBox;

    // name of the default object
    NSString    *defaultBaseEntity;
    
    // Name of the New Dialog Title
    NSString    *dialogNewTitle;
    
    // For editing existing title
    NSString    *dialogExistingTitle;
    
    // Name of the grid
    NSString    *defaultGridName;

    // the current row being open in the dialog box
    NSManagedObject  *baseEntityBeingConsulted;

    UINavigationController *navController;
    UIView *navView;
}
// Override: create a custom dialog box
-(DialogGrid *)createCustomDialog;
-(GridController *)grid;
@end
