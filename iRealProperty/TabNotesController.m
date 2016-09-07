#import "TabNotesController.h"
#import "ControlBar.h"
#import "AxDataManager.h"
#import "IRNote.h"
#import "XMLSurvey.h"
#import "MenuTable.h"
#import "SurveyNote.h"

#import "Helper.h"
#import "RealProperty.h"
#import "RealPropertyApp.h"
#import "SelectedObject.h"
#import "TabSearchController.h"

@implementation TabNotesController

@synthesize fetchedController;

#pragma - Load the data
-(void)loadNotes
{
    // Create a predicate
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"1==1"];

//    fetchedController = [AxDataManager getFetchedResultsController:@"IRNote" andSortBy:@"updateDate" ascending:NO andPredicate:predicate batchSize:20 withContext:[AxDataManager noteContext] cacheName:@"Note-Cache"];

    fetchedController = [AxDataManager getFetchedResultsController:@"IRNote" andSortBy:@"updateDate" ascending:NO andPredicate:predicate batchSize:20 withContext:[AxDataManager noteContext] cacheName:nil];

    NSError *anyError;
    if(![fetchedController performFetch:&anyError])
    {
        return;
    }
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"My Notes";
        self.tabBarItem.image = [UIImage imageNamed:@"Edit"];
    }
    return self;
}
// Init the default values for the variables of this grid manager
-(void)initDefaultValues
{
    defaultGridName = @"GridPersonalNotes";
    defaultBaseEntity = @"RealPropInfo";
    defaultSort = @"RealPropId";
    defaultSortOrderAsc = NO;
}
//
// Create the appropriate dialog box for this grid. Returns a UIViewController type
//
-(DialogGrid *)createCustomDialog
{
    return nil;
}
-(void)deleteSelectedRows:(NSArray *)selectedRows
{
    // Look for the NSSet to be deleted
    NSMutableArray *objectsToDelete = [[NSMutableArray alloc]init];
    for(NSNumber *row in selectedRows)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[row intValue] inSection:0];
        IRNote *note = [fetchedController objectAtIndexPath:indexPath];
        [objectsToDelete addObject:note];
    }
    // delete the objects
    NSManagedObjectContext *context = [AxDataManager noteContext];
    for(int i=0;i<[objectsToDelete count];i++)
    {
        [context deleteObject:[objectsToDelete objectAtIndex:i]];
    }
    [context save:nil];
    objectsToDelete = nil;
    GridController *grid = [self.gridList valueForKey:defaultGridName];
    [self loadNotes];
    [grid refreshAllContent];
    [grid deselectAllRows];
    [[AxDataManager defaultContext]save:nil];

}
//
// Load info
//
-(void)viewDidLoad
{
    [self loadNotes];
    [super viewDidLoad];
    
    
    // Add the Control bar
    UIView *view = [self.view viewWithTag:1010];
    if(view==nil)
    {
        NSLog(@"MenuBar: can't find the view with tag 1010");
        return;
    }
    menuBar = [[ControlBar alloc]initWithNibName:@"NoteControlBar" bundle:nil];
    [view addSubview:menuBar.view];
    [self addChildViewController:menuBar];
    menuBar.delegate = self;
    
    GridController *grid = [self.gridList valueForKey:defaultGridName];
    [grid switchControlBar:kGridControlModeEmpty];
    
    // Load the XML data
    xmlSurvey = [[XMLSurvey alloc]initWithXMLFile:@"Surveys.xml"];
    
    // Create the survey menu
    surveyMenu = [[NSMutableArray alloc]init];
    for(SurveyDefinition *survey in xmlSurvey.surveys)
    {
        MenuItem *item = [[MenuItem alloc]init];
        item.menuLabel = survey.title;
        item.menuTag = survey.surveyTag;
        [surveyMenu addObject:item];
    }
    if([Helper isDeviceInLandscape])
        [self willRotateToInterfaceOrientation:UIInterfaceOrientationLandscapeLeft duration:0];
    else
        [self willRotateToInterfaceOrientation:UIInterfaceOrientationPortrait duration:0];
    [menuBar setItemEnable:kNotesTrash isEnable:NO];
}
-(void)viewDidUnload
{
    
}
#pragma mark - Menu Delegates
-(void)menuTableMenuSelected:(NSString *)menuName withTag:(int)tag withParam:(id)param
{
    menu = nil;
    for(SurveyDefinition *survey in xmlSurvey.surveys)
    {
        if(survey.surveyTag==tag)
        {
            [self switchToSurvey:survey];
            break;
        }
    }

}
#pragma mark - Grid Delegates
// A row has been selected
// Return TRUE if the delegate provides the data (instead of the attached arrays)
-(BOOL)getDataFromDelegate:(NSObject *)grid
{
    return YES;
}
-(void)gridRowSelection:(NSObject *)grid rowIndex:(int)rowIndex
{
    // Select a row to edit it (in the current mode)
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:rowIndex inSection:0];
    IRNote *note = [fetchedController objectAtIndexPath:indexPath];

   
    [self baseNote:note];
    
}
//
// Return the content of a cell 
//
-(id)getCellData:(NSObject *)gridParam rowIndex:(int)rowIndex columnIndex:(int)columnIndex
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:rowIndex inSection:0];
    NSManagedObject *managedObject = [fetchedController objectAtIndexPath:indexPath];

    GridController *grid = (GridController *)gridParam;
    ItemDefinition *def = [grid.gridEntities objectAtIndex:columnIndex];    

    NSString *result = [def getStringValue:managedObject];
    
    if([result length] > 50)
    {
        NSRange range;
        range.length = 50;
        range.location = 0;
        result = [result substringWithRange:range];
    }
    
    return result;
}
// Number of rows in the grid
-(int)numberOfRows:(NSObject *)grid
{
    id<NSFetchedResultsSectionInfo>sectionInfo = [[fetchedController sections] objectAtIndex:0];
    int rows = [sectionInfo numberOfObjects];
    return rows;
}
// Sorting is requested to be performed
// def is the column to perform the operation (ItemDefinition)
-(void)headerSortSelection:(NSObject *)grid entityDefinition:(id)def
{
    ItemDefinition *item = (ItemDefinition *)def;
    
    NSFetchRequest *fetchRequest = fetchedController.fetchRequest;
    
    BOOL ascent = item.filterOptions.sortOption==kFilterAscent?YES:NO;
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:item.path ascending:ascent]; 
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    
    fetchRequest.sortDescriptors = sortDescriptors;
    [fetchedController performFetch:nil];
    
    GridController *g = (GridController *)grid;
    [g refreshAllContent];
}
// Draw an image --called when an entity of type ftImg is foumd
-(void)drawImgEntity:(NSObject *)gridParam rowIndex:(int)rowIndex columnIndex:(int)columnIndex intoRect:(CGRect)rect
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:rowIndex inSection:0];
    NSManagedObject *managedObject = [fetchedController objectAtIndexPath:indexPath];
        
    IRNote *note = (IRNote *)managedObject;
    UIImage *image;
    switch (note.type) {
        case kNotesKeyboard:
            image = [UIImage imageNamed:@"Keyboard.png"];
            break;
        case kNotesSurvey:
            image = [UIImage imageNamed:@"Format Number.png"];
            break;
        default:
            break;
    }
    CGRect destRect = CGRectMake((rect.size.width-image.size.width)/2, 
                                 (rect.size.height-image.size.height)/2,
                                 image.size.width, image.size.height);
    [image drawInRect:destRect];
}
#pragma mark - Delegates
-(void)animateView:(UIView *)topView
{
    // Put the screen off-screen
    topView.frame = CGRectMake(1024, 0, topView.frame.size.width, topView.frame.size.height);
    // ANIMATE: move from right to left
    [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        topView.frame =  CGRectOffset(topView.frame,-1024,0); 
    } completion:nil];    
}
// Switch to the survey
-(void)switchToSurvey:(SurveyDefinition *)survey
{
    if(surveyNote==nil)
    {
        surveyNote = [[SurveyNote alloc]initWithNibName:@"SurveyNote" bundle:nil];
        surveyNote.currentNote = [AxDataManager getNewEntityObject:@"IRNote" andContext:[AxDataManager noteContext]];

    }
    surveyNote.delegate = self;
    // switch to the survey notes
    UIView *view = [self.view viewWithTag:1];
    [view addSubview:surveyNote.view];
    [self addChildViewController:surveyNote];
    [view bringSubviewToFront:surveyNote.view];

    UIView *topView = surveyNote.view;
    surveyNote.surveyDefinition = survey;

    [self animateView:topView];
}

// Switch to the keyboard notes
-(void)baseNote:(id)note
{
    if(baseNote==nil)
        baseNote = [[BaseNote alloc]initWithNibName:@"BaseNote" bundle:nil];
    baseNote.delegate = self;
    // switch to the keyboard notes
    UIView *view = [self.view viewWithTag:1];
    [view addSubview:baseNote.view];
    [self addChildViewController:baseNote];
    [view bringSubviewToFront:baseNote.view];
    baseNote.currentNote = note;
    
    UIView *topView = baseNote.view;
    
    [self animateView:topView];
}
// Return to the current screen
-(void)noteMgrCloseNote:(id)note
{
    UIViewController *viewController = note;
    UIView *topView = viewController.view;
    
    [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        topView.frame =  CGRectOffset(topView.frame,1024,0); 
    }
    completion:^(BOOL finished)
    {
        [baseNote.view removeFromSuperview];
        [baseNote removeFromParentViewController];
        [surveyNote.view removeFromSuperview];
        [surveyNote removeFromParentViewController];

        
        // Get the grid
        GridController *grid = [self.gridList valueForKey:defaultGridName];
        [self loadNotes];
        [grid refreshAllContent];
        [grid deselectAllRows];
//        [grid enterEditMode]
        [grid cancelEditMode];
        
        baseNote = nil;
        surveyNote = nil;
    }];

}
-(void)noteMgrSwitchToProperty:(id)note
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"guid=%@", baseNote.currentNote.rpGuid];
    RealPropInfo *info = [AxDataManager getEntityObject:@"RealPropInfo" andPredicate:predicate];
    if(info==nil)
        return;
    
    [self noteMgrCloseNote:note];
    // Switch to a single property
    SelectedProperties *selectProperties = [[SelectedProperties alloc]initWithRealPropInfo:info];
    [RealProperty setSelectedProperties:selectProperties];
    
    RealPropertyApp *app = (RealPropertyApp *)[[UIApplication sharedApplication] delegate];
    
    [app switchToProperties];
    ((TabSearchController *)app.tabSearchController).autoSearch = NO;

}
// Selection is done of the toolbar
-(void)menuBarBtnSelected:(int)tag
{
    GridController *grid;
    
    switch (tag)
    {
        case kNotesKeyboard:
        case kNotesDraw:
        case kNotesVoice:
            // Create a new keyboard note
            // [self keyboardNotes:nil];
            [self baseNote:nil];
            break;
        case kNotesSurvey:
            menu = [[MenuTable alloc]initWithMenuItems:surveyMenu];
            [menu presentMenu:[menuBar getBarButtonItem:kNotesSurvey] withDelegate:self];
            break;
        case kNotesDelete:
            if(!inEditMode)
            {
                grid = [self.gridList valueForKey:defaultGridName];
                [grid setSingleSelection:YES];
                [grid enterEditMode];
                // Change the title
                [menuBar setItemTitle:kNotesDelete title:@"Done"];
                [menuBar setItemEnable:kNotesTrash isEnable:YES];
                inEditMode = YES;
            }
            else
            {
                inEditMode = NO;
                // Change the title
                [menuBar setItemTitle:kNotesDelete title:@"Edit"]; 
                grid = [self.gridList valueForKey:defaultGridName];
                [grid setSingleSelection:YES];
                [menuBar setItemEnable:kNotesTrash isEnable:NO];
                [grid cancelEditMode];
            }
            break;
        case kNotesTrash:
        {
            grid = [self.gridList valueForKey:defaultGridName];
            NSArray *selected = [grid getSelectedRows];
            [self deleteSelectedRows:selected];
        }
            break;
        default:
            break;
    }
}
-(void)menuTableBeforeDisplay:(NSString *)menuName withItems:(NSArray *)array
{
}
-(void)activateController
{
    [self loadNotes];
    GridController *grid;

    [grid enterEditMode];
    [grid cancelEditMode];
    
    [self loadNotes];


}
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    GridController *gController = [[self gridList] objectForKey:defaultGridName];
    CGRect frame;
    
    if(UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
    {
        frame = CGRectMake(0, 43, 1024, 657);
        UIView *view = [self.view viewWithTag:1010];
        view.frame = CGRectMake(0,0,1024,44);
        menuBar.view.frame = view.frame;
        self.view.frame = CGRectMake(0,0,1024,700);
        
    }
    else
    {
        frame = CGRectMake(0, 43, 768, 913);        
        UIView *view = [self.view viewWithTag:1010];
        view.frame = CGRectMake(0,0,768,44);
        menuBar.view.frame = view.frame;
        self.view.frame = CGRectMake(0,0,768,956);
    }
    [gController updateContentFrame:frame];
    [gController autoFitToView];
    [gController refreshAllContent];
}

@end
