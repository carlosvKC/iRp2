#import <UIKit/UIKit.h>
#import "ComboBoxPopOver.h"
#import "AxDelegates.h"

@class ComboBoxController;


enum gridFilterOptionConstant 
{
    kFilterDontFilter = -1,
    kFilterNone = 0,
    kFilterAscent = 1,
    kFilterDescent = 2
};

enum gridFilterTextConstant
{
    kFilterTextEqual = 0,
    kFilterTextNotEqual = 1,
    kFilterTextContain = 2,
    kFilterTextDontContain = 3
};
enum gridFilterNumContant
{
    kFilterNumEqual = 0,
    kFilterNumNotEqual,
    kFilterNumLarger,
    kFilterNumLargerEqual,
    kFilterNumLess,
    kFilterNumLessEqual
};

@interface GridFilterOptions : NSObject
{
    int         _filterOperation;
    int         _columnType;
    int         _columnIndex;
    NSString    *_columnName;
    // Hold NSString, Int & double value
    id          _filterValue;
    enum gridFilterOptionConstant _sortOption;    
}
@property(nonatomic) int filterOperation;
@property(nonatomic, strong) NSObject *filterValue;
@property enum gridFilterOptionConstant sortOption;
@property(nonatomic) int columnType;
@property(nonatomic, strong) NSString *columnName;
@property(nonatomic) int columnIndex;
@end


enum gridFilterConstant 
{
    kGridInput = 100,
    kGridLabel
};

@interface GridFilter : UIViewController<UITextFieldDelegate, ComboBoxDelegate, ComboBoxPopOverDelegate>
{
    NSArray *_actionsArray;
    ComboBoxController *cmbActions, *cmbDate;
    ComboBoxPopOver *dropdownMenu;
}
@property (weak, nonatomic) IBOutlet UITextField *dataField;

@property(strong, nonatomic) NSArray *uniqueValues;

@property(nonatomic, weak) id<ModalViewControllerDelegate> delegate;
@property(nonatomic, weak) id<GridDelegate> gridDelegate;
@property(nonatomic, strong) GridFilterOptions *filterOptions;
@property (weak, nonatomic) IBOutlet UIButton *dropdownButton;
- (IBAction)dropdownAction:(id)sender;

@end
