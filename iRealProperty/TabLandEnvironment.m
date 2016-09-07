#import "TabLandEnvironment.h"
#import "TabLandController.h"
#import "RealProperty.h"
#import "AxDataManager.h"
#import "iRealProperty.h"
#import "TrackChanges.h"
#import "Helper.h"

@implementation TabLandEnvironment

@synthesize tabLandController;

-(void)initDefaultValues
{
    defaultBaseEntity = @"EnvRes";
    dialogNewTitle = @"New Environmental Restriction";
    dialogExistingTitle = @"Review Environmentatl Restriction";
    defaultGridName = @"GridTabLandEnvironment";
    defaultSort = @"updateDate";
    defaultSortOrderAsc = YES;
}
//
// Create the appropriate dialog box for this grid. Returns a UIViewController type
//
-(DialogGrid *)createCustomDialog
{
    DialogGrid *dialog = [[DialogBoxEnvironmentalController alloc]initWithNibName:@"DialogBoxEnvironmentalController" bundle:nil];
    return dialog;
}
-(void)viewDidLoad
{
    [super viewDidLoad];
    [self willRotateToInterfaceOrientation:[Helper deviceOrientation] duration:0];
}
-(void)contentHasChanged
{
    EnvRes *envRes = (EnvRes *)baseEntityBeingConsulted;
    if(![envRes.rowStatus isEqualToString:@"I"])
        envRes.rowStatus = @"U";

    [self.tabLandController segmentUsed:kSubEnvironmental];    
}
-(void)deleteSelectedRows:(NSArray *)selectedRows
{
    RealPropInfo *info = [RealProperty realPropInfo];
    Land *land = info.land;
    
    // Look for the NSSet to be deleted
    NSMutableArray *objectsToDelete = [[NSMutableArray alloc]init];
    for(NSManagedObject *row in selectedRows)
    {
        for(EnvRes *env in land.envRes)
        {
            if(env==row)
                [objectsToDelete addObject:env];
        }
    }
    // delete the objects
    for(int i=0;i<[objectsToDelete count];i++)
    {
        EnvRes *env = [objectsToDelete objectAtIndex:i];
        if([env.rowStatus isEqualToString:@"I"])
            [[AxDataManager getContext:@"default"]deleteObject:env];
        else
            env.rowStatus = @"D";
            env.updateDate = [[Helper localDate]timeIntervalSinceReferenceDate];

    }
    if([objectsToDelete count]>0)
        [self.tabLandController segmentUsed:kSubEnvironmental];    
    objectsToDelete = nil;
    [[AxDataManager defaultContext]save:nil];

}
-(NSArray *)getGridContent
{
    RealPropInfo *propInfo = [RealProperty realPropInfo];
    Land *land = propInfo.land;
    NSSet *set = land.envRes;
    
    return [AxDataManager orderSet:set property:defaultSort ascending:defaultSortOrderAsc];
}
-(void)addNewContent:(NSManagedObject *)baseEntity
{
    RealPropInfo *propInfo = [RealProperty realPropInfo];
    Land *land = propInfo.land;
    EnvRes *envRes = (EnvRes *)baseEntity;
    envRes.lndGuid = land.guid;
    envRes.rowStatus = @"I";
    [land addEnvResObject:(EnvRes *)baseEntity];
}
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if(!UIInterfaceOrientationIsPortrait(toInterfaceOrientation))
    {
        self.view.frame = CGRectMake(0,0,1024,211);
    }
    else 
    {
        self.view.frame = CGRectMake(0,0,768,334);
    }
    GridController *grid = [self getFirstGridController];
    [grid resizeToView:self.view headerHeight:30];
    [grid autoFitToView:self.view.frame.size.width];
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}
@end
