#import "TabInterest.h"
#import "TabHistoryController.h"
#import "AxDataManager.h"
#import "RealProperty.h"
#import "UndividedInt.h"

@implementation TabInterest
@synthesize itsController;

//
// Init the default values of the grid
- (void)initDefaultValues
{
    defaultBaseEntity = @"UndividedInt";
    defaultSort = @"parcel";
    defaultSortOrderAsc = YES;
}
//
// Return the list of rows -- setEntities is assigned the result as well
- (NSArray *)getDefaultOrderedList
{
    RealPropInfo *info = [RealProperty realPropInfo];
    
    return [AxDataManager orderSet:info.undividedInt property:defaultBaseEntity ascending:defaultSortOrderAsc];
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
-(void)entityContentHasChanged:(ItemDefinition *)entity
{
    // If any content has changed, change indicate status
    [self.propertyController segmentUsed:kTabInterest];
    self.isDirty = YES;
    
    UndividedInt *undivided = (UndividedInt *) (detailController.workingBase);
    undivided.rowStatus = @"U";

}
@end
