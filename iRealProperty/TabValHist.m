#import "TabValHist.h"
#import "TabHistoryController.h"
#import "AxDataManager.h"
#import "Helper.h"

@implementation TabValHist
@synthesize itsController;

//
// Init the default values of the grid
- (void)initDefaultValues
{
    defaultBaseEntity = @"ValHist";
    defaultSort = @"billYr";
    defaultSortOrderAsc = NO;
}
//
// Return the list of rows -- setEntities is assigned the result as well
- (NSArray *)getDefaultOrderedList
{
    RealPropInfo *info = [RealProperty realPropInfo];
    
    return [AxDataManager orderSet:info.valHist property:@"billYr" ascending:NO];
}
-(void)switchControlBar:(enum GridControlBarConstant)bar
{
    [super switchControlBar:bar];
    
    if(bar==kGridControlModeDeleteAdd)
        [self.controlBar setButtonVisible:NO];
}
-(void)gridRowSelection:(NSObject *)grid rowIndex:(int)rowIndex
{
}
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    // Override to previous chnage to adjust the grid
    
    int width, height;
    
    if(UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
    {
        width = 1024;
        height = 580+8;
    }
    else
    {
        width = 768;
        height = 837+8;
    }
    UIView *view = [self.view viewWithTag:501];
    view.frame = CGRectMake(0, 0, width, height);

    view = [gridController.view viewWithTag:1];
    view.frame = CGRectMake(0, 0, width, height);

    view = [gridController.view viewWithTag:40];
    view.frame = CGRectMake(0, 0, width, height);

    view = [gridController.view viewWithTag:41];
    view.frame = CGRectMake(0, 0, width, 50);

    view = [gridController.view viewWithTag:42];
    view.frame = CGRectMake(0, 50, width, height-50);
}
@end
