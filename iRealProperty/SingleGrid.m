#import "SingleGrid.h"
#import "DialogBoxEnvironmentalController.h"
#import "AxDataManager.h"
#import "Helper.h"
#import "RealPropertyApp.h"
#import "ValidationController.h"

@implementation SingleGrid

#pragma mark - manages a single grid
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
#pragma mark - Override those methods

// Init the default values for the variables of this grid manager
-(void)initDefaultValues
{
}
//
// Create the appropriate dialog box for this grid. Returns a UIViewController type
//
-(DialogGrid *)createCustomDialog
{
    return nil;
}
-(void)deleteSelectedRows:(NSArray *)rows
{
}
-(void)contentHasChanged
{
}
-(NSArray *)getGridContent
{
    return nil;
}
-(void)addNewContent:(NSManagedObject *)baseEntity
{
}
#pragma mark - Standard methods
// create the dialog box
-(void)createDialogBox
{
    itsDialogBox = [self createCustomDialog];
    CGSize size = itsDialogBox.view.frame.size;
    itsDialogBox.delegate = self;
    navController = [[UINavigationController alloc]initWithRootViewController:itsDialogBox];
    
#if 0
    navController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:navController animated:YES  completion:^(void) {} ];
    
    navController.view.superview.frame = CGRectMake(0, 0, size.width, size.height);
    navController.view.superview.center = self.view.superview.superview.center; 
#endif

    RealPropertyApp *app = (RealPropertyApp *)[[UIApplication sharedApplication] delegate];
    UIViewController *controller = app.window.rootViewController;

    CGRect screen = [Helper getScreenBoundsForCurrentOrientation];
    navView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 1024, 1024)];
    navView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    navView.opaque = NO;
    
    [controller.view addSubview:navView];
    [controller.view bringSubviewToFront:navView];
    
    
    navController.view.frame = CGRectMake((screen.size.width - size.width)/2, 
                                          (screen.size.height - size.height)/2,
                                          size.width, size.height);
    
    [navView addSubview:navController.view];
    [controller addChildViewController:navController];
    [navView bringSubviewToFront:navController.view];
        
    
    // Animate the navcontroller
    CGFloat height = screen.size.height - navController.view.frame.origin.y;

    navController.view.frame = CGRectOffset(navController.view.frame, 0, height);
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{ 
            navController.view.frame = CGRectOffset(navController.view.frame, 0, -height);
            navView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    } 
                     completion:nil];
}



-(void)deleteRows:(GridController *)gController
{
    NSArray *selectedRows = [gController getSelectedRows];
    [self deleteSelectedRows:selectedRows];
    
    [gController setGridContent:[self getGridContent]];
    [gController refreshAllContent];
    [gController cancelEditMode];
}

//
// Handles the call for creation (or delete) in the list
//
-(void)gridControlBarAction:(NSObject *)grid action:(int)param
{
    GridController *gController = (GridController *)grid;
    
    switch (param) 
    {
        case kGridControlBarBtnAdd:
        {
            // Create a new dialog box
            [self createDialogBox];
            itsDialogBox.isNewContent = YES;
            NSManagedObject *object = [AxDataManager getNewEntityObject:defaultBaseEntity];
            [itsDialogBox setWorkingBase:object];
            [itsDialogBox setupBusinessRules:object];
            [itsDialogBox setScreenEntities];
            [itsDialogBox setDialogTitle:dialogNewTitle];
        }
            break;
        case kGridControlBarBtnDel:
            [gController enterEditMode];
            break;
        case kGridControlBarBtnCancel:
            [gController cancelEditMode];
            break;
        case kGridControlBarBtnConfirmDel:
            [self deleteRows:gController];
            break;
        default:
            break;
    }
}
//
// A row has been selected
//
-(void)gridRowSelection:(NSObject *)objectGrid rowIndex:(int)rowIndex
{
    [self createDialogBox];
    
    GridController *gController = (GridController *)objectGrid;
    NSArray *rows = [gController getGridContent];
    baseEntityBeingConsulted = [rows objectAtIndex:rowIndex];
    // Cloning -- NSManagedObject *cloned = [AxDataManager clone:baseEntityBeingConsulted withSets:YES withLinks:YES];
    NSManagedObject *cloned = baseEntityBeingConsulted;
    [itsDialogBox setWorkingBase:cloned];
    itsDialogBox.isNewContent = NO;
    [itsDialogBox setDialogTitle:dialogExistingTitle];
    [itsDialogBox setupBusinessRules:cloned];
    [itsDialogBox setScreenEntities];
}
//
// The modal dialog is being dismissed
- (void)didDismissModalView:(UIViewController *)dialogSender saveContent:(BOOL)saveContent
{
    GridController *gController = [[self gridList] objectForKey:defaultGridName];
    [gController deselectAllRows];   
    
    if(saveContent)
    {
        // Make sure to collect all the pieces
        UIResponder *first = [Helper findFirstResponder:dialogSender.view];
        if(first!=nil)
        {
            if(![first resignFirstResponder])
                return;
        }
        // Verify that there are no error
        if(![itsDialogBox shouldSwitchView:[itsDialogBox workingBase]])
        {
            // ok, there is an issue
            ValidationError *object = [[itsDialogBox validationErrorList]objectAtIndex:0];
            [Helper alertWithOk:@"Error" message:object.description];
            return;
        }
        
        // Save the object
        if(itsDialogBox.isNewContent)
        {
            [self addNewContent:[itsDialogBox workingBase]];
            // Update the Grid            
            [gController setGridContent:[self getGridContent]];
            [gController refreshAllContent];               
            // New content has been added
            [self contentHasChanged];
        }
        else
        {
            // If content has changed, save it -- signal to controller if things have changed
            if(itsDialogBox.isDirty)
            {
                [self contentHasChanged];
                [gController refreshAllContent];

            }
        }
    }
    itsDialogBox = nil;
    // [self dismissViewControllerAnimated:YES completion:^(void){}];
    
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseOut       animations:^{ 
            navController.view.frame = CGRectOffset(navController.view.frame, 0, 1024);
            navView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
        } 
        completion:^(BOOL completion){
             [navView removeFromSuperview];
             [navController removeFromParentViewController];
             navView = nil;
             navController = nil;                         
         }];


}
//

-(GridController *)grid;
{
    return [[self gridList] objectForKey:defaultGridName];
}
#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initDefaultValues];

    GridController *gController = [[self gridList] objectForKey:defaultGridName];
    
    if(gController!=nil)
    {
        gController.delegate = self;
        gController.gridControlBar.delegate = self;
        GridDefinition *gridDefinition = gController.gridDefinition;
        if(gridDefinition!=nil)
        {
            if([RealPropertyApp getUserLevel] < gridDefinition.editLevel || gridDefinition.editLevel == -1)
                [gController.gridControlBar setButtonVisible:NO];
        }
        [gController setGridContent:[self getGridContent] ];
        
    }
    [self willRotateToInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation] duration:0];
    return;
    [self setScreenEntities];
    [self setupBusinessRules:[self workingBase]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if(navView!=nil)
        return;
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    // Adjust the dialog box (if they exist)
    if(navView!=nil)
    {
        CGRect screen;
        if(UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
            screen = CGRectMake(0, 0, 1024, 748);
        else
            screen = CGRectMake(0, 0, 768, 1004);
        
        navView.frame = screen;
        CGSize size = navController.view.frame.size;
        
        navController.view.frame = CGRectMake((screen.size.width - size.width)/2, 
                                              (screen.size.height - size.height)/2,
                                              size.width, size.height); 
    }
}
-(void)resizeToView:(UIView *)view
{
    GridController *gController = [[self gridList] objectForKey:defaultGridName];
    [gController resizeToView:view headerHeight:30.0];
}
@end
