#import "TabReviews.h"
#import "TabHistoryController.h"
#import "AxDataManager.h"
#import "Helper.h"

@implementation TabReviews
//
// Init the default values of the grid
- (void)initDefaultValues
{
    defaultSort = @"billYr";
    defaultSortOrderAsc = NO;
    defaultBaseEntity = @"Review";
    currentIndex = 0;
    tabIndex = kHistReviews;
}
//
// Return the list of rows -- setEntities is assigned the result as well
- (NSArray *)getDefaultOrderedList
{
    RealPropInfo *info = [RealProperty realPropInfo];
    NSSet *set = info.review;
    
    setEntities = [AxDataManager orderSet:set property:defaultSort ascending:defaultSortOrderAsc];
    
    return setEntities;
}
-(void)switchControlBar:(enum GridControlBarConstant)bar
{
    [super switchControlBar:bar];
    
    if(bar==kGridControlModeDeleteAdd)
        [self.controlBar setButtonVisible:NO];
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    CGFloat width = 768;
    if(UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
        width = 1024;;
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:0];
    
    // resize the 2 tables
    ScreenController *object = [detailController.controllerList valueForKey:@"ReviewNotes"];
    GridController *grid = [object.gridList valueForKey:@"GridReviewNotes"];
    [grid resizeToView:[detailController.view viewWithTag:20] headerHeight:30.0];
    [grid autoFitToView:width];
    object = [detailController.controllerList valueForKey:@"ReviewTracking"];
    grid = [object.gridList valueForKey:@"GridTabReviewTracking"];
    [grid resizeToView:[detailController.view viewWithTag:21] headerHeight:30.0];
    [grid autoFitToView:width];
}

@end
