#import "SaleWarnings.h"
#import "DialogBoxNote.h"
#import "AxDataManager.h"
#import "TabSaleDetail.h"
#import "DialogBoxSaleWarning.h"
#import "RealPropertyApp.h"
#import "Helper.h"

@implementation SaleWarnings

@synthesize defaultSale; // contain the current sale object


-(void)initDefaultValues
{
    defaultBaseEntity = @"SaleWarning";
    dialogNewTitle = @"New Sale Warning";
    dialogExistingTitle = @"Sale Warning";
    defaultGridName = @"GridSaleWarnings";
    defaultSort = @"updateDate";
    defaultSortOrderAsc = YES;
}
//
// Create the appropriate dialog box for this grid. Returns a UIViewController type
//
-(DialogGrid *)createCustomDialog
{
    DialogGrid *dialog = [[DialogBoxSaleWarning alloc]initWithNibName:@"DialogBoxSaleWarning" bundle:nil];
    return dialog;
}
// Delete sales warning
-(void)deleteSelectedRows:(NSArray *)selectedRows
{
    RealPropInfo *info = [RealProperty realPropInfo];
    NSSet *saleParcels = info.saleParcel;  // List of sales...

    Sale *sale;
    
    for(SaleParcel *saleParcel in saleParcels)
    {
        Sale *s = saleParcel.sale;
        if(s.guid==defaultSale.guid)
        {
            sale = s;
            break;
        }
    }
    if(sale==nil)
        return;

    
    // Look for the NSSet to be deleted
    NSMutableArray *objectsToDelete = [[NSMutableArray alloc]init];
    for(NSManagedObject *row in selectedRows)
    {
        for(SaleWarning *sw in defaultSale.saleWarning)
        {
            if(sw==row)
                [objectsToDelete addObject:sw];
        }
    }
    // delete the objects
    for(int i=0;i<[objectsToDelete count];i++)
    {
        SaleWarning *sw = [objectsToDelete objectAtIndex:i];
        if([sw.rowStatus isEqualToString:@"I"])
        {
            [sale removeSaleWarningObject:sw];
            [[AxDataManager defaultContext]deleteObject:sw];
        }
        else
            sw.rowStatus = @"D";
            sw.updateDate = [[Helper localDate]timeIntervalSinceReferenceDate];
    }
    objectsToDelete = nil;
    [[AxDataManager defaultContext]save:nil];
}
-(void)contentHasChanged
{
    TabSaleDetail *tab = (TabSaleDetail *)self.itsController;
    [self updateContent];
    [tab entityContentHasChanged:nil];    
}
// Find the appropriate note and the NoteInstances that correspond to that particular sale
-(NSArray *)getGridContent
{
    RealPropInfo *propInfo = [RealProperty realPropInfo];
    
    NSSet *saleParcels = propInfo.saleParcel;  // List of sales...

    for(SaleParcel *saleParcel in saleParcels)
    {
        Sale *sale = saleParcel.sale;
        
        if(sale.guid==defaultSale.guid)
        {
            NSArray *array = [AxDataManager orderSet:sale.saleWarning property:defaultSort ascending:defaultSortOrderAsc];
            return array;
        }
    }
    return nil;
}
//
// Refresh the grid
-(void)loadWarningForSale:(Sale *)newSale
{
    defaultSale = newSale;
    GridController *gController = [[self gridList] objectForKey:defaultGridName];
    
    [gController setGridContent:[self getGridContent]];
    [gController refreshAllContent];
    [gController cancelEditMode];    
    [gController switchControlBar:kGridControlModeDeleteAdd];
    
}
-(void)addNewContent:(NSManagedObject *)baseEntity
{
    RealPropInfo *propInfo = [RealProperty realPropInfo];

    NSSet *saleParcels = propInfo.saleParcel;  // List of sales...
    for(SaleParcel *saleParcel in saleParcels)
    {
        Sale *sale = saleParcel.sale;
        if(sale.guid==defaultSale.guid)
        {
            SaleWarning *saleWarning = (SaleWarning *)baseEntity;
            saleWarning.rowStatus = @"I";
            // Create the new object
            [RealPropertyApp updateUserDate:saleWarning];
            saleWarning.saleGuid = sale.guid;
            [sale addSaleWarningObject:saleWarning];
        }
    }
}
-(void)updateContent
{
    
    NSSet *set = defaultSale.saleWarning;
    
    for (id object in set)
    {
        if ( ![[object rowStatus] isEqualToString:@"I"])
        {
            [object setRowStatus:@"U"];
            
        }
        continue;
    }
}
@end
