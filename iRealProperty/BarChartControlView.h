
#import <UIKit/UIKit.h>
#import "BarChartView.h"

@interface BarChartControlView : UIView
{
    
    // Position Y of the last legend line added 
    int _legendLastY;
    
}

// title label
@property (weak, nonatomic) UILabel *titleLbl;

// render of the bar charts
@property (weak, nonatomic) NSArray *barChartRenderArray;


// Draw the bar chart with the parameters. The parameters array must be a class of type PieChartParameter.
-(void)drawBarCharWithTitle:(NSString *)title andParameters:(NSArray *)parameters error:(NSError **)error;

// Clean the data inside th eview
-(void)clearView;

// Refresh the cache object in the piechar view
-(void) releaseCache;

@end
