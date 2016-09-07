#import "TabNotes.h"
#import "TabHistoryController.h"
#import "AxDataManager.h"
#import "iRealProperty.h"
#import "Helper.h"
#import "AxDataManager.h"
#import "DialogBoxNote.h"
#import "RealPropertyApp.h"
#import "TrackChanges.h"
#import "SaleNotes.h"

@implementation TabNotes
@synthesize itsController;

//
// Init the default values of the grid
- (void)initDefaultValues
{
    defaultSort = @"updateDate";
    defaultSortOrderAsc = NO;
    defaultBaseEntity = @"NoteRealPropInfo";
    tabIndex = kTabNote;
}
//
// Create the appropriate dialog box for this grid. Returns a UIViewController type
//
-(DialogGrid *)createCustomDialog
{
    DialogBoxNote *dialog = [[DialogBoxNote alloc]initWithNibName:@"DialogBoxNote" bundle:nil];
    return dialog;
}
//
// Delete one object
//
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
                // cv 10/06/14 Mark Image(s) for deletion as well
                if ([note.mediaNote count] > 0 )
                {
                    NSSet *mediaSet = note.mediaNote;
                    for (MediaNote *noteMedia in mediaSet)
                    {   noteMedia.rowStatus = @"D";
                        noteMedia.updateDate = [[Helper localDate]timeIntervalSinceReferenceDate];
                    }
                }
                return YES;
            }
        }
    }
    return NO;
}
//
// Return the list of rows -- setEntities is assigned the result as well
//
- (NSArray *)getDefaultOrderedList
{
    RealPropInfo *info = [RealProperty realPropInfo];
    NSMutableArray *notes = [[NSMutableArray alloc]init];
    
    // RealPropInfo notes
    for(NoteRealPropInfo *note in info.noteRealPropInfo)
        if(![note.rowStatus isEqualToString:@"D"])
            [notes addObject:note];

    // Sale notes
    for(SaleParcel *saleParcel in info.saleParcel)
    {
        Sale *sale = saleParcel.sale;
        for(NoteSale *note in sale.noteSale)
            if(![note.rowStatus isEqualToString:@"D"])
                [notes addObject:note];
    }
    
    // Review notes
    for(Review *review in info.review)
    {
        for(NoteReview *note in review.noteReview)
            if(![note.rowStatus isEqualToString:@"D"])
                [notes addObject:note];
    }
    
    // HIExmpt notes
    for(HIExmpt *hi in info.hIExempt)
    {
        for(NoteHIExmpt *note in hi.noteHIExmpt)
            if(![note.rowStatus isEqualToString:@"D"])
                    [notes addObject:note];
    }
    return [AxDataManager orderArray:notes property:defaultSort ascending:defaultSortOrderAsc];
}
// Save the current form - It can be added only to the RealPropInfo
-(void)addNewDetails
{
    RealPropInfo *info = [RealProperty realPropInfo];
    NoteRealPropInfo *note = (NoteRealPropInfo *)detailController.workingBase;
    note.guid = [Helper generateGUID];
    note.rowStatus = @"I";
    note.src = @"realprop";
    note.srcGuid = info.guid;
    
    [RealPropertyApp updateUserDate:note];
    [info addNoteRealPropInfoObject:note];
    
    for(MediaNote *mediaNote in note.mediaNote)
    {
        mediaNote.noteGuid = note.guid;    
    }
}
// Save the the current details
-(void)saveCurrentDetails
{
    GridController *gController = [gridController getFirstGridController];
    NSArray *rows = [gController getGridContent];
    
    //  cv 10/01/2014 Add count to eliminated selection on deletion
    if (rows.count > 0)
    {
        //cv 11/5/15 disable use of adding & not saving, moving to other row and save on not logical row
        NoteRealPropInfo *noterpInfo = (NoteRealPropInfo *)[rows objectAtIndex:currentIndex];
        if ([noterpInfo.rowStatus isEqualToString:@""])
        {
            NSLog(@"No need to update User current note row");
            return;
        }
 
        NSManagedObject *row = [rows objectAtIndex:currentIndex];
        if(![row isKindOfClass:[NoteRealPropInfo class]])
        {
            NSLog(@"Internal error in saveCurrentDetails");
            return;
        }
        // Cloning [AxDataManager copyManagedObject:detailController.workingBase destination:row withSets:YES withLinks:YES];
        row = detailController.workingBase;
        [RealPropertyApp updateUserDate:row];
    }
}
-(void)entityContentHasChanged:(ItemDefinition *)entity
{
    // If any content has changed, change indicate status
    [self.propertyController segmentUsed:kTabNote];
    self.isDirty = YES;
    NoteInstance *note = (NoteInstance *)[detailController workingBase];
    if(![note.rowStatus isEqualToString:@"I"] && ![note.rowStatus isEqualToString:@"D"])
        note.rowStatus = @"U";
}

- (void)addNewMedia
{
    MediaNote *media = [AxDataManager getNewEntityObject:@"MediaNote"];
    [self defaultMediaInformation:media];
    
    if(detailController.mediaController==nil)
    {
        // create the Media controller the first time
        [detailController addMedia:kTabNoteImage mediaArray:nil];
    }
    NoteInstance *note = (NoteInstance *)[detailController workingBase];

    media.noteGuid = note.guid;    
    [note addMediaNoteObject:media];
    // Refresh the grid
    // 2/21/13 HNN sort before calling refresh medias because I don't want to sort accross mediatypes (land, bldg, accy, etc)
    [self refreshMedias:[RealProperty sortMedia:[AxDataManager setToArray:note.mediaNote]]];
    //[self refreshMedias:[AxDataManager orderSet:note.mediaNote property:@"mediaDate" ascending:NO]];
}
-(void) deleteMedia:(id)media
{
    NoteInstance *note = (NoteInstance *)[detailController workingBase];
    NSManagedObjectContext *context = [AxDataManager defaultContext];

    if([[media rowStatus] isEqualToString:@"I"])
    {
        [note removeMediaNoteObject:media];
        [context deleteObject:media];
    }
    else
        [media setRowStatus:@"D"];
//undo        [media setUpdateDate:[[Helper localDate]timeIntervalSinceReferenceDate]];
    
    // 2/21/13 HNN sort before calling refresh medias because I don't want to sort accross mediatypes (land, bldg, accy, etc)
    [self refreshMedias:[RealProperty sortMedia:[AxDataManager setToArray:note.mediaNote]]];
    //[self refreshMedias:[AxDataManager orderSet:note.mediaNote property:@"mediaDate" ascending:NO]];
    self.isDirty = YES;
    [self entityContentHasChanged:nil];
}
// this method is called when new data is updated
- (void)updateDetailMedia
{
    if(detailController.mediaController==nil)
    {
        // create the Media controller the first time
        [detailController addMedia:kTabNoteImage mediaArray:nil];
    }
    NoteInstance *note = (NoteInstance *)[detailController workingBase];
    
    NSArray *medias = [AxDataManager orderSet:note.mediaNote property:@"MediaDate" ascending:NO];
    
    [detailController.mediaController updateMedias:medias];
}  
@end
