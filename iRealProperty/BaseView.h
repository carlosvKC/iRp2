#import <UIKit/UIKit.h>
#import "AxDelegates.h"

@interface BaseView : UIView
{
    // for wipe left/right
    CGPoint gestureStartPoint;
    
    __weak id<BaseViewDelegate> delegate;
}
@property(nonatomic, weak) id<BaseViewDelegate> delegate;
@end
