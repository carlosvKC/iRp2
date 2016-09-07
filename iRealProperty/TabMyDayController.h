#import <UIKit/UIKit.h>
#import "PieChartControlView.h"
#import "ChartParameter.h"
#import "ControlBar.h"
#import "BarChartControlView.h"

@interface TabMyDayController : UIViewController
{
    PieChartControlView * pieView;
    PieChartControlView * pieView2;
    PieChartControlView * pieView3;
    
    BarChartControlView *barView;
    ControlBar *menuBar;
    
    NSArray *pieArray;
    
    NSOperationQueue *queue;
}
@property (weak, nonatomic) IBOutlet PieChartControlView *pieSaleVerification;

@property (weak, nonatomic) IBOutlet PieChartControlView *piePhysicalInspection;

@property (weak, nonatomic) IBOutlet PieChartControlView *pieMaintIncomplete;
@property (weak, nonatomic) IBOutlet PieChartControlView *pieMaintComplete;
@property(strong, atomic) NSMutableDictionary *pieValues;

@property (weak, nonatomic) IBOutlet UILabel *labelUserName;
@end
