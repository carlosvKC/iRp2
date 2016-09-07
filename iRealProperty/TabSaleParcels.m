#import "TabSaleParcels.h"
#import "iRealProperty.h"
#import "DialogBoxNote.h"
#import "AxDataManager.h"
#import "RealProperty.h"
#import "Helper.h"


@implementation TabSaleParcels

@synthesize defaultSale; // contain the current sale object

-(BOOL)getDataFromDelegate:(id)grid
{
    return YES;
}

-(int)numberOfRows:(id)grid
{
    return [results count];
}
-(id)getCellData:(id)grid rowIndex:(int)rowIndex columnIndex:(int)columnIndex
{
    if(rowIndex >= [results count])
        return nil;

    NSArray *array = [results objectAtIndex:rowIndex];
    
    if(columnIndex >= [array count])
        return nil;
    
    return [array objectAtIndex:columnIndex];
}
-(void)initDefaultValues
{
    defaultBaseEntity = @"SaleParcels";
    dialogNewTitle = @"";
    dialogExistingTitle = @"";
    defaultGridName = @"GridSaleParcels";
    defaultSort = @"parcel";
    defaultSortOrderAsc = YES;
}
-(void)viewDidLoad
{
    [super viewDidLoad];
    GridController *gController = [[self gridList] objectForKey:defaultGridName];
    gController.delegate = self;
    gController.gridControlBar.delegate = self; 
    
    [gController.gridControlBar setButtonVisible:NO];
}
-(NSArray *)getGridContent
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"saleGuid=%@", defaultSale.guid];
    NSArray *saleParcels = [AxDataManager dataListEntity:@"SaleParcel" andSortBy:@"saleGuid" andPredicate:predicate];
    results = [[NSMutableArray alloc]init];
    
    for(SaleParcel *saleParcel in saleParcels)
    {
        
        RealPropInfo *info = saleParcel.realPropInfo;
        
        //[AxDataManager getEntityObject:@"RealPropInfo" andPredicate:[NSPredicate predicateWithFormat:@"realPropId=%d", saleParcel.realPropId]];
        NSMutableArray *array = [[NSMutableArray alloc]init];
        NSString *string;
        if(info!=nil)
            string = [NSString stringWithFormat:@"%@-%@", info.major, info.minor];
        else
            string = @"Commercial parcel";
        [array addObject:string];
        [array addObject:string];
        [results addObject:array];
    }

    return results;
}
-(void)gridRowSelection:(id)grid rowIndex:(int)rowIndex
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"saleGuid=%@", defaultSale.guid];

    //NSArray *saleParcels = [AxDataManager dataListEntity:@"SaleParcel" andSortBy:@"saleId" andPredicate:predicate];
    NSArray *saleParcels = [AxDataManager dataListEntity:@"SaleParcel" andSortBy:@"parcel" andPredicate:predicate];

    if(rowIndex<0 || rowIndex>=saleParcels.count)
        return;
    
    SaleParcel *saleParcel = [saleParcels objectAtIndex:rowIndex];
    RealPropInfo *info = saleParcel.realPropInfo;

    if(info==nil)
    {
        [Helper alertWithOk:@"Commercial Parcel" message:@"You have selected a parcel that is not in this database"];
        return;
    }
    RealProperty *rp = [RealProperty instance];
    [rp validateAndSwitchToParcel:[NSNumber numberWithInt:info.realPropId]];
}
-(void)gridRowSelection:(id)grid rowIndex:(int)rowIndex selected:(BOOL)selected
{
}
//
// Refresh the grid
-(void)loadParcelForSale:(Sale *)newSale
{
    defaultSale = newSale;
    GridController *gController = [[self gridList] objectForKey:defaultGridName];
    // [gController setGridContent:[self getGridContent]];
    [self getGridContent];
    [gController refreshAllContent];
}


@end
