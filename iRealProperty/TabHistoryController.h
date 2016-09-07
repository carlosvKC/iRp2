#import <UIKit/UIKit.h>
#import "ScreenController.h"
#import "TabPermits.h"
#import "TabSale.h"
#import "TabReviews.h"
#import "TabChanges.h"
#import "TabValHist.h"
#import "SegmentedControlLightController.h"

enum historySubTab 
{
    kHistPermit = 0,
    kHistSales,
    kHistReviews,
    kHistValHist,
    kHistChanges,
    kHistSaleVerif
};


@interface TabHistoryController : TabBase
{
    
    TabPermits    *tabPermitsController;
    TabSale       *tabSalesController;
    TabReviews    *tabReviewsController;
    
    TabChanges    *tabChangesController;
    TabValHist    *tabValHistController;
    
    SegmentedControlLightController *segmentedControlLightController;

}
    @property(nonatomic, weak) IBOutlet UISegmentedControl *segmentedCtrl;
    -(IBAction)switchSegment:(id)sender;
    -(void)switchView:(int)index;
    -(void)segmentOn:(int)segment;
    -(void)segmentUsed:(int)segment;
    -(void)updateAllIndicators;
@end
