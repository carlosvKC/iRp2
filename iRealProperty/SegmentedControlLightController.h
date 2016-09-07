#import <UIKit/UIKit.h>
#import "SegmentedControlLightView.h"

@class MKNumberBadgeView;

@interface ErrorBadge: NSObject
@property(nonatomic, strong) MKNumberBadgeView *badgeView;
@property(nonatomic) id target;
@property(nonatomic) int index;
@property(nonatomic) int targetIndex;
-(id)initWithView:(MKNumberBadgeView *)view index:(int)i;
@end

@interface SegmentedControlLightController : UIViewController<UIPopoverControllerDelegate>
{
    NSMutableArray *lightArray;
    UISegmentedControl *segmentedControl;
    // List of warnings associated with each tab
    NSMutableArray *badges;
    
    UIView *_destView;
    UIViewController *_messageController;
    UIPopoverController *_messagePopover;
    CGRect  _lastFrame;
}
-(id) initWithSegmentedControl:(UISegmentedControl *)segControl destView:(UIView *)destView;
-(void) refreshLights;
-(void) changeLightStateOfSegment:(int)segment color:(enum segLightConstant)color;
-(enum segLightConstant) getLightStateOfSegment:(int)segment;
-(void) resetAll;
- (void)addBadgeAtIndex:(int)index number:(int)count color:(UIColor *)color;
- (void)removeBadgeAtIndex:(int)index;
- (void)removeAllBadges;
-(void)linkBadgeToController:(int)index target:(id)target;
-(void)moveBadgesToView:(UIView *)destView target:(id)target;
-(void)restoreBadges:(id)target;
@end
