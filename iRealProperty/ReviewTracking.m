#import "ReviewTracking.h"
#import "DialogBoxNote.h"
#import "AxDataManager.h"


@implementation ReviewTracking

@synthesize defaultReview; // contain the current sale object


-(void)initDefaultValues
{
    defaultBaseEntity = @"ReviewJrnl";
    dialogNewTitle = @"";
    dialogExistingTitle = @"Journal Entry";
    defaultGridName = @"GridTabReviewTracking";
    defaultSort = @"updateDate";
    defaultSortOrderAsc = NO;
}
-(void)setupBusinessRules:(id)baseEntity
{
    GridController *grid = [self.gridList valueForKey:defaultGridName];
    [grid.gridControlBar setButtonVisible:NO];
}
-(NSArray *)getGridContent
{
    return [AxDataManager orderSet:defaultReview.reviewJrnl property:defaultSort ascending:defaultSortOrderAsc];
}
//
// Refresh the grid
-(void)loadTracking:(Review *)newReview
{
    defaultReview = newReview;
    GridController *gController = [[self gridList] objectForKey:defaultGridName];
    
    [gController setGridContent:[self getGridContent]];
    [gController refreshAllContent];
    [gController cancelEditMode];    
    [gController switchControlBar:kGridControlModeDeleteAdd];
    
}
-(void)addNewContent:(NSManagedObject *)baseEntity
{
}
-(void)gridRowSelection:(NSObject *)objectGrid rowIndex:(int)rowIndex
{
}
@end
