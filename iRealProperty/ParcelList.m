
#import "ParcelList.h"
#import "ControlBar.h"
#import "TabMapController.h"
#import "Helper.h"
#import "RealPropertyApp.h"


@implementation ParcelList
@synthesize mapController;
@synthesize parcels = _parcels;
-(void)menuBarBtnSelected:(int)tag
{
    if(tag!=10 && tag!=11)
        return;
    GridController *ctrl = [self.gridList valueForKey:defaultGridName];

    NSArray *selectedRows = [ctrl getSelectedRows];
    if([selectedRows count]==0)
    {
        [Helper alertWithOk:@"Warning" message:@"Please select one or several rows"];
        return;
    }
    
    NSMutableArray *rows = [[NSMutableArray alloc]init];
    
    for(RealPropInfo *info in selectedRows)
    {
        NSNumber *realId = [[NSNumber alloc]initWithInt:info.realPropId];
        [rows addObject:realId];
    }
    [mapController hideSelectedParcels];
    
    RealPropertyApp *appDelegate = (RealPropertyApp*)[[UIApplication sharedApplication] delegate];
    if(tag==10)
    {
        [appDelegate switchToProperties];
    }
    else if(tag==11)
    {
        [appDelegate selectMultiplePropertiesOnMap];
    }
}
// The back button has been clicked
-(void)menuBarBtnBackSelected
{
    [mapController switchBackFromGridController];
}

- (void)initDefaultValues
{
    defaultGridName = @"GridSelectedParcelsFromMap";
    defaultBaseEntity = @"RealPropId";
    defaultSort = @"realPropId";
    defaultSortOrderAsc = YES;
}
-(NSArray *)getGridContent
{
    NSMutableArray *array = [[NSMutableArray alloc]initWithCapacity:[_parcels count]];
    for(NSNumber *parcelId in _parcels)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"realPropId=%d", [parcelId intValue]];
        RealPropInfo *info = [AxDataManager getEntityObject:@"RealPropInfo" andPredicate:predicate];
        [array addObject:info];
    }
    return array;
}
-(void)gridRowSelection:(NSObject *)grid rowIndex:(int)rowIndex
{
}
-(void)viewDidLoad
{
    [super viewDidLoad];
    UIView *view = [self.view viewWithTag:1010];
    if(view==nil)
    {
        NSLog(@"MenuBar: can't find the view with tag 1010");
        return;
    }
    _menuBar = [[ControlBar alloc]initWithNibName:@"ParcelListControlBar" bundle:nil];
    [view addSubview:_menuBar.view];
    [self addChildViewController:_menuBar];
    [_menuBar addBackButonWithTitle:@"Map"];
    _menuBar.delegate = self;
    GridController *ctrl = [self.gridList valueForKey:defaultGridName];
    [ctrl.gridControlBar setButtonVisible:NO];
    
    if([ctrl.getGridContent count]==1)
        [_menuBar setupBarLabel:@"Selected parcel in map"];
    else
        [_menuBar setupBarLabel:@"Selected parcels in map"];
    [ctrl setSingleSelection:NO];
}
@end
