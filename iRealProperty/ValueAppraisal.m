
#import "ValueAppraisal.h"
#import "AxDataManager.h"
#import "iRealProperty.h"
#import "RealProperty.h"

@implementation ValueAppraisal

-(void)initDefaultValues
{
    defaultBaseEntity = @"ApplHist";
    defaultGridName = @"GridValueAppraisal";
    defaultSort = @"rollYr";
    defaultSortOrderAsc = NO;
}
// Find the appropriate note and the NoteInstanes that correspond to that particular sale
-(NSArray *)getGridContent
{
    RealPropInfo *propInfo = [RealProperty realPropInfo];

    return [AxDataManager orderSet:propInfo.applHist property:defaultSort ascending:defaultSortOrderAsc];
}
-(void) setupBusinessRules:(id)baseEntity
{
    GridController *ctrl = [self.gridList valueForKey:defaultGridName];
    [ctrl.gridControlBar setButtonVisible:NO];
}

-(void)gridRowSelection:(NSObject *)objectGrid rowIndex:(int)rowIndex
{

}
@end
