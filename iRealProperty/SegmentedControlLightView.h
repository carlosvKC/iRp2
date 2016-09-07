
#import <UIKit/UIKit.h>

enum segLightConstant {
    kSegLightNone = 0,
    kSegLightGray,
    kSegLightGreen,
    kSegLightOrange,
    kSegLightRed
    };

@interface SegmentedControlLightView : UIView
@property int segment;
@property enum segLightConstant   segLight;
@end
