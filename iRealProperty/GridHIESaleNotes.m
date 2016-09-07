#import "GridHIESaleNotes.h"
#import "DialogBoxNote.h"
#import "AxDataManager.h"
#import "TabSaleDetail.h"
#import "TrackChanges.h"
#import "RealPropertyApp.h"

@implementation GridHIESaleNotes

@synthesize defaultHIExmpt; // contain the current sale object


-(void)initDefaultValues
{
    defaultBaseEntity = @"NoteHIExmpt";
    dialogNewTitle = @"New Note";
    dialogExistingTitle = @"Existing Note";
    defaultGridName = @"HIESaleNotes";
    defaultSort = @"updateDate";
    defaultSortOrderAsc = YES;
}
//
// Create the appropriate dialog box for this grid. Returns a UIViewController type
//
-(DialogGrid *)createCustomDialog
{
    DialogBoxNote *dialog = [[DialogBoxNote alloc]initWithNibName:@"DialogBoxNote" bundle:nil];
    return dialog;
}
-(void)deleteSelectedRows:(NSArray *)selectedRows
{
    // Look for the NSSet to be deleted
    NSMutableArray *objectsToDelete = [[NSMutableArray alloc]init];
    for(NSManagedObject *row in selectedRows)
    {
        for(NoteHIExmpt *ni in defaultHIExmpt.noteHIExmpt)
        {
            if(ni==row)
                [objectsToDelete addObject:ni];
        }
    }
    // delete the objects
    for(int i=0;i<[objectsToDelete count];i++)
    {
        NoteHIExmpt *ni = [objectsToDelete objectAtIndex:i];
        [defaultHIExmpt removeNoteHIExmptObject:ni];
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

-(void)updateContent
{
    
    NSSet *set = defaultHIExmpt.noteHIExmpt;
    
    for (id object in set)
    {
//        if ( ![[object rowStatus] isEqualToString:@"I"])
//        {
            [object setRowStatus:@"U"];
            
//        }
        continue;
    }
}


// Find the appropriate note and the NoteInstanes that correspond to that particular sale
-(NSArray *)getGridContent
{
    NSArray *array = [AxDataManager orderSet:defaultHIExmpt.noteHIExmpt property:defaultSort ascending:defaultSortOrderAsc];
    return array;
}
//
// Refresh the grid
-(void)loadNotes:(HIExmpt *)exmpt
{
    defaultHIExmpt = exmpt;
    GridController *gController = [[self gridList] objectForKey:defaultGridName];
    
    [gController setGridContent:[self getGridContent]];
    [gController refreshAllContent];
    [gController cancelEditMode];    
    [gController switchControlBar:kGridControlModeDeleteAdd];
    
}
-(void)addNewContent:(NSManagedObject *)baseEntity
{
    NoteHIExmpt *newNote = (NoteHIExmpt *)baseEntity;
    
    // check if the sale has a noteId
    //if([defaultHIExmpt.noteGuid length] == 0)
    //defaultHIExmpt.noteGuid = newNote.guid;
    // Create a new note and a new instance
        //cvNote2 newNote.rpGuid = [RealProperty realPropInfo].guid;
    newNote.src = @"hiexmpt";
    newNote.srcGuid = defaultHIExmpt.guid;
    newNote.rowStatus = @"I";
    
    // Look at the highest number
//    NSSet *set = defaultHIExmpt.noteHIExmpt;
//    NSEnumerator *enumerator = [set objectEnumerator];
    
//    NoteInstance *instance;
    
//    int max = 1000000;
//    while(instance = [enumerator nextObject])
//    {
//        if(instance.noteInstance > max)
//            max = instance.noteInstance;
//    }
//    newNote.noteInstance = max+1;
    //cv instead of using instance as instance +1 we'll just add a new Guid
    newNote.guid = [Requester createNewGuid];
    [RealPropertyApp updateUserDate:newNote];
    [defaultHIExmpt addNoteHIExmptObject:newNote];
}

@end
