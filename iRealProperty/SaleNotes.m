#import "SaleNotes.h"
#import "DialogBoxNote.h"
#import "AxDataManager.h"
#import "TabSaleDetail.h"
#import "TrackChanges.h"
#import "RealPropertyApp.h"
#import "Helper.h"

@implementation SaleNotes

@synthesize defaultSale; // contain the current sale object


-(void)initDefaultValues
{
    defaultBaseEntity = @"NoteSale";
    dialogNewTitle = @"New Note";
    dialogExistingTitle = @"Existing Note";
    defaultGridName = @"GridSaleNotes";
    defaultSort = @"updateDate";
    defaultSortOrderAsc = YES;
}
//
// Create the appropriate dialog box for this grid. Returns a UIViewController type
//
-(DialogGrid *)createCustomDialog
{
    dialog = [[DialogBoxNote alloc]initWithNibName:@"DialogBoxNote" bundle:nil];
    dialog.contentSizeForViewInPopover = dialog.view.frame.size;


    return dialog;
}
-(void)gridRowSelection:(NSObject *)objectGrid rowIndex:(int)rowIndex
{
    [super gridRowSelection:objectGrid rowIndex:rowIndex];
    [dialog refreshMedias];
    // Reset the different views (not sure why, but can't get them to work properly from the NIB)
#if 0
    UIView *view;
    view = [dialog.view viewWithTag:1];
    view.frame = CGRectMake(20, 20, 462, 160);
    view = [dialog.view viewWithTag:110];
    view.frame = CGRectMake(0, 190, 502, 138);
    
    [dialog.view bringSubviewToFront:view];
    view.backgroundColor = [UIColor redColor];
    
    view = [dialog.view viewWithTag:111];
    view.frame = CGRectMake(0, 0, 139, 110);
    view = [dialog.view viewWithTag:110];
    view.frame = CGRectMake(0, 110, 139, 28);
    view = [dialog.view viewWithTag:300];
    view.frame = CGRectMake(400, 200, 56, 43);
    [dialog.view bringSubviewToFront:view];
#endif
}
-(void)deleteSelectedRows:(NSArray *)selectedRows
{
    // Look for the NSSet to be deleted
    NSMutableArray *objectsToDelete = [[NSMutableArray alloc]init];
    for(NSManagedObject *row in selectedRows)
    {
        for(NoteSale *ni in defaultSale.noteSale)
        {
            if(ni==row)
                [objectsToDelete addObject:ni];
        }
    }
    // delete the objects
    for(int i=0;i<[objectsToDelete count];i++)
    {
        NoteSale *ni = [objectsToDelete objectAtIndex:i];
        if([ni.rowStatus isEqualToString:@"I"])
        {
            [defaultSale removeNoteSaleObject:ni];
            [[AxDataManager defaultContext]deleteObject:ni];
        }
        else
            ni.rowStatus = @"D";
            ni.updateDate = [[Helper localDate]timeIntervalSinceReferenceDate];
    }
    objectsToDelete = nil;
    [[AxDataManager defaultContext]save:nil];

}
-(void)contentHasChanged
{
    TabSaleDetail *tab = (TabSaleDetail *)self.itsController;
    [self updateContent];
    [tab contentHasChanged];    
}
// Find the appropriate note and the NoteInstanes that correspond to that particular sale
-(NSArray *)getGridContent
{
    NSArray *array = [AxDataManager orderSet:defaultSale.noteSale property:defaultSort ascending:defaultSortOrderAsc];
    return array;
}
//
// Refresh the grid
-(void)loadNotesForSale:(Sale *)newSale
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
    NoteSale *newNote = (NoteSale *)baseEntity;
    newNote.rowStatus = @"I";
    // check if the sale has a noteId
    //if([defaultSale.noteGuid length] == 0)
        //  defaultSale.noteId = [TrackChanges getNewId:newNote];
    // Create a new note and a new instance
    newNote.src = @"sale";
    newNote.srcGuid = defaultSale.guid;
    
    newNote.guid = [Requester createNewGuid];
    [RealPropertyApp updateUserDate:newNote];
    [defaultSale addNoteSaleObject:newNote];
    
    // update the note instance
    for(MediaNote *mediaNote in newNote.mediaNote)
    {
        //mediaNote.instanceId = newNote.noteInstance;
        // mediaNote.noteId = newNote.noteId;
        mediaNote.noteGuid = newNote.guid;
    }
}

-(void)updateContent
{
    
    NSSet *set = defaultSale.noteSale;
    
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
