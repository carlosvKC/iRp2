#import "TabChanges.h"
#import "TabHistoryController.h"
#import "AxDataManager.h"

#import "RealPropertyApp.h"


@implementation TabChanges
@synthesize itsController;

//
// Init the default values of the grid
- (void)initDefaultValues
{
    defaultSort = @"eventDate";
    defaultSortOrderAsc = NO;
    defaultBaseEntity = @"ChngHist";
    currentIndex = 0;
    tabIndex = kHistReviews;
}
//
// Return the list of rows -- setEntities is assigned the result as well
- (NSArray *)getDefaultOrderedList
{
    RealPropInfo *info = [RealProperty realPropInfo];
    NSSet *set = info.chngHist;
    
    setEntities = [AxDataManager orderSet:set property:defaultSort ascending:defaultSortOrderAsc];
    
    return setEntities;
}
-(void)switchControlBar:(enum GridControlBarConstant)bar
{
    [super switchControlBar:bar];
    
    if(bar==kGridControlModeDeleteAdd)
        [self.controlBar setButtonVisible:NO];
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
    
    UIView *view;
    
    view = [gridController.view viewWithTag:1];
    view.frame = CGRectMake(0, 0, width, height);
    
    view = [gridController.view viewWithTag:40];
    view.frame = CGRectMake(0, 0, width, height);
    
    view = [gridController.view viewWithTag:41];
    view.frame = CGRectMake(0, 0, width, 50);
    
    view = [gridController.view viewWithTag:42];
    view.frame = CGRectMake(0, 50, width, height-50);
    
}
-(void)entityContentHasChanged:(ItemDefinition *)entity
{
    [self.itsController segmentUsed:kHistChanges];
    
    self.isDirty = YES;
    
    //////////////////////////
    ChngHist *chnghist = (ChngHist *)(detailController.workingBase);
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *verifDate = [dateFormatter dateFromString:@"1900-01-01"];
    NSDate *updateDate = [dateFormatter dateFromString:@"1900-01-01"];
    
    
    verifDate = [NSDate date];
    updateDate = [NSDate date];
    NSString *rowStatus=@"U";
    NSString *updatedBy=[RealPropertyApp getUserName];
    [chnghist setValue:rowStatus forKey:@"rowStatus"];
    [chnghist setValue:updateDate forKey:@"updateDate"];
    [chnghist setValue:updatedBy forKey:@"updatedBy"];
        
    }
    


@end
