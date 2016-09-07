#import "ReviewNotes.h"
#import "DialogBoxNote.h"
#import "AxDataManager.h"
#import "RealProperty.h"
#import "TrackChanges.h"
#import "RealPropertyApp.h"
#import "Helper.h"

@implementation ReviewNotes

@synthesize defaultReview; // contain the current sale object


-(void)initDefaultValues
{
    defaultBaseEntity = @"NoteReview";
    dialogNewTitle = @"New Note";
    dialogExistingTitle = @"Existing Note";
    defaultGridName = @"GridReviewNotes";
    defaultSort = @"updateDate";
    defaultSortOrderAsc = NO;
}
-(void)setupBusinessRules:(id)baseEntity
{
    GridController *grid = [self.gridList valueForKey:defaultGridName];
    [grid.gridControlBar setButtonVisible:NO];
}
//
// Create the appropriate dialog box for this grid. Returns a UIViewController type
//
-(DialogGrid *)createCustomDialog
{
    DialogGrid *dialog = [[DialogBoxNote alloc]initWithNibName:@"DialogBoxNote" bundle:nil];
    return dialog;
}
- (BOOL) deleteSelection:(NSManagedObject *)object
{
    RealPropInfo *info = [RealProperty realPropInfo];
    NSSet *set = info.noteRealPropInfo;
    
    for(NoteRealPropInfo *note in set)
    {
        if(note==object)
        {
            if([note.updatedBy caseInsensitiveCompare:[RealPropertyApp getUserName]]!=NSOrderedSame)
            {
                [Helper alertWithOk:@"Can't delete" message:@"You are not the author of this note and can't delete it."];
                continue;
            }
            if([note.rowStatus isEqualToString:@"I"])
            {
                [info removeNoteRealPropInfoObject:note];
                [[AxDataManager defaultContext]deleteObject:note];
                [[AxDataManager defaultContext]save:nil];
                return NO;
            }
            else
            {
                note.rowStatus = @"D";
                note.updateDate = [[Helper localDate]timeIntervalSinceReferenceDate];
                return YES;
            }
        }
    }
    return NO;
}
-(void)contentHasChanged
{
    //   [self.con
}
// Find the appropriate note and the NoteInstanes that correspond to that particular sale
-(NSArray *)getGridContent
{
    NSArray *array = [AxDataManager orderSet:defaultReview.noteReview property:defaultSort ascending:defaultSortOrderAsc];
    return array;
}
//
// Refresh the grid
-(void)loadNotesForReview:(Review *)newReview
{
    defaultReview = newReview;
    GridController *gController = [[self gridList] objectForKey:defaultGridName];
    
    [gController setGridContent:[self getGridContent]];
    [gController refreshAllContent];

}
-(void)addNewContent:(NSManagedObject *)baseEntity
{
    NoteReview *newNote = (NoteReview *)baseEntity;
    newNote.rowStatus = @"I";
    // check if the sale has a noteId

    // Create a new note and a new instance
    //    newNote.noteId = [TrackChanges getNewId:newNote];
    //    newNote.noteGuid = [Helper generateGUID];
    newNote.src = @"review";
    //    newNote.key = defaultReview.assmtReviewId;
    newNote.srcGuid = defaultReview.guid;
    // Look at the highest number
//    NSSet *set = defaultReview.noteReview;
//    NSEnumerator *enumerator = [set objectEnumerator];
    
//    NoteInstance *instance;
    
//    int max = 1000000;
//    while(instance = [enumerator nextObject])
//    {
//        if(instance.noteInstance > max)
//            max = instance.noteInstance;
//    }
//    newNote.noteInstance = max+1;

    newNote.guid = [Requester createNewGuid];
    [RealPropertyApp updateUserDate:newNote];
    [defaultReview addNoteReviewObject:newNote];
}

-(void)gridRowSelection:(NSObject *)objectGrid rowIndex:(int)rowIndex
{
}
@end
