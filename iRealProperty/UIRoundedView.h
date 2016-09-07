
#import <UIKit/UIKit.h>
#import "BaseView.h"

@interface UIRoundedView : BaseView
{
    UIColor     *backgroundColor;
    UIColor     *lineColor;
    CGFloat     lineWidth;
    CGFloat     radius;
}
@property(nonatomic,retain) UIColor     *backgroundColor;
@property(nonatomic,retain)UIColor     *lineColor;
@property CGFloat     lineWidth;
@property CGFloat     radius;
@end
