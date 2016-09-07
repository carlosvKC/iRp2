
#import <UIKit/UIKit.h>
#import "LUItems2.h"

@class ComboBoxController;
@class LUItems2;

#define comboxBoxImageNormal @"DropBox.png"
#define comboxBoxImageDisabled @"DropBox-Disabled.png"
#define comboxBoxImageRequired @"DropBoxRequired.png"

#define comboBoxInsetTop    0.0
#define comboBoxInsetLeft   5.0
#define comboBoxInsetBottom 0.0
#define comboBoxInsetRight  5.0


@interface ComboBoxView : UIView
{
    BOOL enabled;
    LUItems2 *itsItem;
    NSString *labelText;
    CGRect labelTextRect;
}
- (void)drawRect:(CGRect)rect;
- (id)initWithFrame:(CGRect)frame;
- (void)setComboItem:(LUItems2 *)item;
- (void)setComboItemWithString:(NSString *)string;
- (void)setEnabled:(BOOL)value;
- (BOOL)isEnabled;
- (void)setSelection:(int)selection;
- (int)getSelection;

@property(nonatomic, weak) ComboBoxController *itsController;
@property(nonatomic, strong) UIFont *labelFont;
@property CGFloat labelFontSize;
@property(nonatomic, strong) UIColor *labelFontColor;
@property CGFloat labelMinimumFontSize;
@property(nonatomic) int index;
@end

