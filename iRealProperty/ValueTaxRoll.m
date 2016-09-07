#import "ValueTaxRoll.h"
#import "AxDataManager.h"
#import "iRealProperty.h"
#import "RealProperty.h"
#import "Helper.h"

@implementation ValueTaxRoll

-(void)initDefaultValues
{
    defaultBaseEntity = @"TaxRoll";
    defaultGridName = @"GridValueTaxRoll";
    defaultSort = @"billYr";
    defaultSortOrderAsc = NO;
}
// Find the appropriate note and the NoteInstanes that correspond to that particular sale
-(NSArray *)getGridContent
{
    RealPropInfo *propInfo = [RealProperty realPropInfo];
    return [AxDataManager orderSet:propInfo.taxRoll property:defaultSort ascending:defaultSortOrderAsc];
}
-(void) setupBusinessRules:(id)baseEntity
{
    GridController *ctrl = [self.gridList valueForKey:defaultGridName];
    [ctrl.gridControlBar setButtonVisible:NO];
}
-(void)gridRowSelection:(NSObject *)grid rowIndex:(int)rowIndex
{
  
}
@end
