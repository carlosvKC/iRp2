
#import <UIKit/UIKit.h>

@interface GridResizer : UIView
{
    CGPoint         offset,
                    delta;
    UIViewController *controller;
}
@property(nonatomic, retain) UIViewController *controller;
@property CGPoint offset;
@end
