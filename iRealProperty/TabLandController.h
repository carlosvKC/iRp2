
#import <UIKit/UIKit.h>
#import "RealProperty.h"
#import "ScreenController.h"
#import "GridController.h"
#import "SegmentedControlLightController.h"
#import "TabBase.h"
#import "TabLandViews.h"
#import "TabLandNuisance.h"
#import "TabLandDesignations.h"
#import "TabLandEnvironment.h"

enum tabLandSubviews {
    kSubViews = 0,
    kSubNuisance,
    kSubDesignations,
    kSubEnvironmental
};


@interface TabLandController : TabBase
{
    UITextField *textField;
    
    ScreenController   *subViewsController;
    ScreenController   *subNuisanceController;
    ScreenController   *subDesignationController;
    ScreenController   *subEnvironmentalController;
    
    SegmentedControlLightController *segmentedControlLightController;
}
@property(nonatomic, weak) IBOutlet UISegmentedControl *segmentedCtrl;
-(IBAction)segmentControlSelected:(id)sender;
-(void)switchSubViews:(int)index;
-(void)segmentOn:(int)segment;
-(void)segmentUsed:(int)segment;
-(void)updateAllIndicators;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedSubtab;
@end
