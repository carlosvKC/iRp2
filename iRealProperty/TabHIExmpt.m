#import "TabHIExmpt.h"
#import "AxDataManager.h"
#import "iRealProperty.h"
#import "RealProperty.h"
#import "HIExmpt.h"
#import "RealPropertyApp.h"

@implementation TabHIExmpt

//
// Init the default values of the grid
- (void)initDefaultValues
{
//    defaultSort = @"hIExemptId";
    defaultSort = @"firstBillYr";
    defaultSortOrderAsc = YES;
    defaultBaseEntity = @"HIExmpt";
    currentIndex = 0;
    tabIndex = kTabHIE;
}
//
// Return the list of rows -- setEntities is assigned the result as well
- (NSArray *)getDefaultOrderedList
{
    RealPropInfo *info = [RealProperty realPropInfo];
    NSSet *set = info.hIExempt;
    
    setEntities = [AxDataManager orderSet:set property:defaultSort ascending:defaultSortOrderAsc];
    
    return setEntities;
}
-(void)switchControlBar:(enum GridControlBarConstant)bar
{
    [super switchControlBar:bar];
    
    if(bar==kGridControlModeDeleteAdd)
        [self.controlBar setButtonVisible:NO];
}
-(void)contentHasChanged
{
    [self.propertyController segmentUsed:kTabHIE];
}
-(void)entityContentHasChanged:(ItemDefinition *)entity
{
    // If any content has changed, change indicate status
    [self.propertyController segmentUsed:kTabHIE];
    self.isDirty = YES;
    
    HIExmpt *hiExmpt = (HIExmpt *) (detailController.workingBase);
    hiExmpt.rowStatus = @"U";
    hiExmpt.updatedBy = [RealPropertyApp getUserName];
                         

}
@end
