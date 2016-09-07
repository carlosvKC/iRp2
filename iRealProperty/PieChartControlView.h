
#import <UIKit/UIKit.h>
#import "PieChartView.h"

@interface PieChartControlView : UIView
{
    
    // Position Y of the last legend line added 
    int _legendLastY;
    
}

// title label
@property (weak, nonatomic) UILabel *titleLbl;

// render of the pie chart
@property (weak, nonatomic) PieChartView *pieChartRender;

// view to draw the legent
@property (weak, nonatomic) UIView *legentArea;

// Draw the pie chart with the parameters. The parameters array must be a class of type PieChartParameter.
-(void)drawPieCharWithTitle:(NSString *)title andParameters:(NSArray *)parameters error:(NSError **)error;

// Clean the data inside th eview
-(void)clearView;

// Refresh the cache object in the piechar view
-(void) releaseCache;

@end
