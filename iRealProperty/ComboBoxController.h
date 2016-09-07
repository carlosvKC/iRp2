
#import <UIKit/UIKit.h>
#import "LUItems2.h"
#import "ComboBoxView.h"
#import "ComboBoxPopOver.h"
#import "StreetController.h"
#import "AxDelegates.h"

@class ComboBoxView;
@class ComboBoxPopOver;
@class DatePicker;

enum ComboBoxStyleConstant {
    
    kComboBoxStyleLUItems = 0,  // Lookup items
    kComboBoxStyleStreet,   // Street picker
    kComboBoxStyleDate,     // Date picker
    kComboBoxStylePercent,  // Percent picker
    kComboBoxStyleYear,     // Year picker
    kComboBoxStyleText      // List of text
 };
// The ComboBox Controller definition
@interface ComboBoxController : UIViewController<ComboBoxPopOverDelegate>
{
    int streetId;
    int percent;        // Multiple of 5
    int rowIndex;
}
- (id)initForDate:(CGRect)viewRect;
- (id)initWithArrayAndViewRect:(NSArray *)luitems :(ComboBoxView *)view;
- (id)initForStrings:(NSArray *)array inRect:(CGRect)viewRect;
- (void)clickInCombox;
- (void)setSelection:(int)selection;
- (int)getSelection;
- (void)setSelectionWithText:(NSString *)selection;
- (void)setSelectionDate:(NSDate *)date;
- (NSDate *)getSelectionDate;
-(void)initPercent:(int)maximum increment:(int)increment;

//cv 8_6_13
-(void)initPercentNeg:(int)maximum increment:(int)increment;

@property(nonatomic, strong) ComboBoxPopOver *popoverController;
@property(nonatomic, strong) StreetController *streetController;
@property(nonatomic, strong) DatePicker *datePicker;
@property(nonatomic, strong) NSArray *comboListItems;
@property(nonatomic, strong) LUItems2 *comboBoxSelectedItem;
@property int textAlign;
@property enum ComboBoxStyleConstant comboBoxStyle;
@property(nonatomic, weak) id<ComboBoxDelegate> delegate; 
@property(nonatomic) int selectedItem;
@property(nonatomic, strong) NSDate *dateSelection;
@property(nonatomic, getter = isEnabled) BOOL enabled;
@property(nonatomic) BOOL required;
@end
