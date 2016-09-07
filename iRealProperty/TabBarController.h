#import <UIKit/UIKit.h>
#import "KeyboardController.h"
#import "SyncFiles.h"
#import "MKNumberBadgeView.h"

@protocol TabBarDelegate <NSObject>
@required
@optional
-(void)tabBardidSelectViewController:(UIViewController *)controller;
-(BOOL)tabBarShoudSwitchController:(UIViewController *)controller;
-(void)tabBarWillSwitchController:(UIViewController *)controller;
@end


@interface TabBarController : UIViewController<UITabBarDelegate>
{
    UIViewController *_selectedViewController;
    NSArray *_items;
    BOOL _barAtBottom;
    
    // Handle events while tranisition
    BOOL    _isTransitioning;
    
    NSTimeInterval  lastClick;
    UITabBarItem    *lastItem;
}
// Reposition the bar at the top or bottom
-(void)setBarAtBottom:(BOOL)position;
// Return the top view
+(UIView *)topView;

@property (weak, nonatomic) IBOutlet UIView *tabBarView;
@property (weak, nonatomic) IBOutlet UITabBar *tabBar;

@property (strong, nonatomic) UIViewController *selectedViewController;
@property (strong, nonatomic) NSArray *items;

@property (weak, nonatomic) id<TabBarDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIButton *debugViewBtn;
- (IBAction)debugView:(id)sender;
-(void)addBadgeToTab:(int)index value:(int)value;
-(void)removeBadgeFromTab:(int)index;
-(void)switchToNewController:(UIViewController *)tobeSelected;
-(BOOL)isBarAtBottom;
@end
