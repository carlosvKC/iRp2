#import <UIKit/UIKit.h>
#import "ScreenController.h"
#import "AxDelegates.h"
#import "DCRoundSwitch.h"


@interface CheckBoxView : DCRoundSwitch // UIView

//- (void)drawRect:(CGRect)rect;
- (id)initWithFrame:(CGRect)frame;

// Its delegate
@property(nonatomic, weak) id<CheckBoxDelegate> delegate;
@property(nonatomic, getter = isChecked) BOOL checked;
@property(nonatomic, getter = isEnabled) BOOL enabled;
@end