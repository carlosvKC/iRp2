#import "TabMapController.h"
#import "RendererXmlBreaker.h"

#import "SelectedObject.h"
#import "RealProperty.h"
#import "RealPropertyApp.h"
#import "TabSearchController.h"
#import "Helper.h"

@implementation TabMapController

static UIView *tabMapControllerView;

+(UIView *)tabMapControllerView
{
    return tabMapControllerView;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        self.title = @"Map";
        self.tabBarItem.image = [UIImage imageNamed:@"Web.png"];
    }
    return self;
}
							
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
#pragma mark - Miscelleneous functions
-(void)resetLayersConfiguration
{
    [arcgisMap resetLayersConfiguration];
}
-(void) resetRenderersConfiguration
{
    [arcgisMap resetRenderersConfiguration];
}
#pragma mark - ArcGisViewControllerDelegate implementation
//
// Adjust the zoom level of the map
-(void)arcGisViewController:(ArcGisViewController *)arcGisView refreshZoomLevel:(NSString *)zoomText
{
    // Update the text of the button
    UIBarItem *btn = [menuBar getBarButtonItem:kBtnZoomLevel];
    btn.title = zoomText;
}

-(void)arcGisViewController:(ArcGisViewController *)arcGisView didClickCalloutAccessoryButtonForParcel:(int)parcelId
{
    // display detail view or popover with the detial of the parcel with the recieved pin
}
- (void)arcGisViewController:(ArcGisViewController*)arcGisView selectionHasChanged:(NSArray *)array
{
#if 0
    // adjust the buttons
    int count = [array count];
    if(count==0)
    {
        [menuBar setItemEnable:kBtnSelectParcel isEnable:NO];
        [menuBar setItemEnable:kBtnClearParcel isEnable:NO];
    }
    else
    {
        [menuBar setItemEnable:kBtnSelectParcel isEnable:YES];
        [menuBar setItemEnable:kBtnClearParcel isEnable:YES];
    }
#endif
}
#pragma mark - Delegates
-(void)menuTableMenuSelected:(NSString *)menuName withTag:(int)tag withParam:(id)param
{
    if([menuName isEqualToString:@"MenuZoomLevel"])
    {
        // refresh the zoom level
        //[self refreshZoomLevel:(NSString *)param];
        NSString *doubleStr = (NSString *)param;
        [arcgisMap adjustZoomLevel:[doubleStr doubleValue]];
        return;
    }
    else if([menuName isEqualToString:@"MenuMesure"])
    {
        if([param isEqualToString:@"Polygon"])
        {
            if (![arcgisMap isSketching])
            {
                [menuBar setItemSelected:kBtnMeasure isSelected:YES];
                [arcgisMap startSketchPolygon];
            }
            else 
            {
                [menuBar setItemSelected:kBtnMeasure isSelected:NO];
                [arcgisMap endSketching];
            }
        }
        else 
        {
            if (![arcgisMap isSketching])
            {
                [menuBar setItemSelected:kBtnMeasure isSelected:YES];
                [arcgisMap startSketchPolyline];
            }
            else 
            {
                [menuBar setItemSelected:kBtnMeasure isSelected:NO];
                [arcgisMap endSketching];
            }

        }
    }
}
-(void)menuTableBeforeDisplay:(NSString *)menuName withItems:(NSArray *)array
{
}
// Selection is done of the toolbar
-(void)menuBarBtnSelected:(int)tag
{
    arcgisMap.menuBar = menuBar;
    switch(tag)
    {
        case kBtnLayers:
            // Display the list of layers
            [_rendererPickerPopover dismissPopoverAnimated:NO];
            [arcgisMap configLayer:[menuBar getBarButtonItem:kBtnLayers]];
            break;
        case kBtnRenderers:
            // Display the list of renderers
        {
            [arcgisMap hideConfigLayer];
            if (_rendererPicker == nil)
            {
                _rendererPicker = [[RenderersPicker alloc] initWithNibName:@"RenderersPicker" bundle:NULL];
                _rendererPicker.arcgisMap = arcgisMap;
                _rendererPicker.renderers = arcgisMap.xmlBreaker.allRenderers;
                
                UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:_rendererPicker];

                _rendererPickerPopover = [[UIPopoverController alloc] initWithContentViewController:nav];
            }
            _rendererPicker.delegate = self;
            [_rendererPickerPopover presentPopoverFromBarButtonItem:[menuBar getBarButtonItem:tag] permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
            _rendererPickerPopover.delegate = self;
     
        }
            break;
        case kBtnZoomLevel:
            // Display the zoom level
            menu = [[MenuTable alloc]initFromResource:@"MenuZoomLevel"];
            [menu presentMenu:[menuBar getBarButtonItem:kBtnZoomLevel] withDelegate:self];
            break;
        case kBtnDropPin:
            // Drop a pin (current location)

            [arcgisMap dropCurrentPosition];
            break;
        case kBtnCompass:
            // switch to compass
            [arcgisMap toggleCompass];
            break;
        case kBtnClearParcel:
            // Clear all the pushpins
            [arcgisMap removePushpins];
            break;
        case kBtnSelectParcel:
            // Get all the selected parcels and go to a list of parcels
            [self switchToParcelGrid:[arcgisMap retrievePushpins]];
            break;
        case kBtnMeasure:
            // Display measure mode
            menu = [[MenuTable alloc]initFromResource:@"MenuMesure"];
            [menu presentMenu:[menuBar getBarButtonItem:kBtnMeasure] withDelegate:self];
           
            break;
        case kBtnGoogle:
            // Use google as the background layer
            [arcgisMap toogleGoogleMap];
            break;
        case kBtnCenterParcel:
            [arcgisMap centerParcel];
            break;
  
    }
}
-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    _rendererPickerPopover = nil;
    _rendererPicker = nil;
}
-(void)selectParcel: (id)pin 
{
    if (arcgisMap != NULL)
    {
        [arcgisMap highlightParcel:pin];
        [arcgisMap centerParcel];
        [arcgisMap tabMapDetailIsDone];
    }
}

-(void)selectMultipleParcel: (NSArray*)pins  selectedParcels:(NSArray *)selectedParcels
{
    if (arcgisMap != NULL)
    {
       [arcgisMap highlightParcels:pins selectedParcels:selectedParcels];
    }
}

-(void)rendererSelected:(id)renderer withName:(NSString *)name ofType:(rendererTypesEnu)type
{
    [_rendererPickerPopover dismissPopoverAnimated:YES];
    _rendererPickerPopover = nil;
    _rendererPicker = nil;
    
    [arcgisMap setParcelRenderer:renderer withTitle:name];
}
#pragma mark - Switch to select view controller
-(void)tabBardidSelectViewController:(UIViewController *)controller
{
    // Gathering all the selections
    
}

#pragma mark - Display the list of selected parcels
//
// Switch back to the search list
//
-(void)switchToParcelGrid:(NSArray *)selectedParcels
{
    RealPropertyApp *app = (RealPropertyApp *)[[UIApplication sharedApplication] delegate];

    if(searchGrid==nil)
    {
        searchGrid = [[TabSearchGrid alloc]initWithNibName:@"TabSearchGrid" bundle:nil];
        searchGrid.delegate = self;
        [self.view addSubview:searchGrid.view];
    }
    
    TabSearchController *searchController = (TabSearchController *)app.tabSearchController;

    // We need to create a default search definition
    SearchDefinition2 *searchDefinition = [searchController.searchBase findDefaultMapDefinition];
    if(searchDefinition==nil)
    {
        NSLog(@"Can't find searchDefinition for defaultmap. Use defaultmap=yes");
        return;
    }
    
    GridDefinition *gridDefinition = [EntityBase getGridWithName:searchDefinition.resultRef];
    selObject = [[SelectedProperties alloc]initWithSearchDefinition:searchDefinition colDefinition:gridDefinition.columns];
    [selObject createMultipleEntries:selectedParcels];
    
    // Need to refresh the grid
    [searchGrid createGridFromSearch:searchDefinition colDefinition:gridDefinition.columns];
    searchGrid.selObject = selObject;
    
    [searchGrid.gridController setSingleSelection:NO];

    [searchGrid.gridController refreshAllContent];  // to force a redisplay
    [searchGrid updateResults];
    [self.view bringSubviewToFront:searchGrid.view];
    
    // [searchGrid changeSegment:0];
    // Put the screen off-screen
    searchGrid.view.frame = CGRectMake(1024, 0, searchGrid.view.frame.size.width, searchGrid.view.frame.size.height);

    // ANIMATE: move from right to left
    
    [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        searchGrid.view.frame =  CGRectOffset(searchGrid.view.frame,-1024,0); 
    } completion:nil];
    
}
-(void)tabSearchGridAddChildViewController:(GridController *)grid
{
    [self addChildViewController:grid];
}

-(void)tabSearchGridReturn
{
    [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:
                         ^{
                            searchGrid.view.frame =  CGRectOffset(searchGrid.view.frame,1024,0); 
                        } 
                     completion:
                         ^(BOOL finished)
                        {
                            // Put the screen off-screen
                            searchGrid.view.frame = CGRectMake(0, 0, searchGrid.view.frame.size.width, searchGrid.view.frame.size.height);
                            [self.view sendSubviewToBack:searchGrid.view];
                            [searchGrid.view removeFromSuperview];
                            [searchGrid removeFromParentViewController];
                            searchGrid = nil;
                            [RealProperty setSelectedProperties:nil];
                        }
     ];
}
//
// Redraw the properties on the map
//
-(void)tabSearchGridswitchToMultipleParcels
{
    RealPropertyApp *appDelegate = (RealPropertyApp*)[[UIApplication sharedApplication] delegate];
    [RealProperty setSelectedProperties:selObject];

    TabSearchController *searchController = (TabSearchController *)appDelegate.tabSearchController;
    searchController.autoSearch = NO;

    [appDelegate switchToProperties];
    [searchGrid menuBarBtnBackSelected];    // return the search
    
}
// Show multiple properties on map
-(void)tabSearchGridselectMultiplePropertiesOnMap
{
    RealPropertyApp *appDelegate = (RealPropertyApp*)[[UIApplication sharedApplication] delegate];
    TabSearchController *searchController = (TabSearchController *)appDelegate.tabSearchController;
    searchController.autoSearch = NO;
    
    NSMutableArray *array = [[NSMutableArray alloc]init];
    
    SelectedProperties *properties = selObject;
    // Get the current set of normal properties
    for(int i=0;i<properties.memGridIndex.count;i++)
    {
        NSNumber *number = [properties.memGridIndex objectAtIndex:i];
        RowProperty *row = [properties.memGrid objectAtIndex:[number intValue]];
        number = [[NSNumber alloc]initWithInt:((RealPropInfo *)row.realPropInfo).realPropId];
        [array addObject:number];
    }
    
    NSMutableArray *selectedArray = [[NSMutableArray alloc]init];
    NSArray *indexes = [properties listOfSelectedRows];
    for(NSNumber *num in indexes)
    {
        RowProperty *row = [properties.memGrid objectAtIndex:[num intValue]];
        NSNumber *number = [[NSNumber alloc]initWithInt:((RealPropInfo *)row.realPropInfo).realPropId];
        [selectedArray addObject:number];
        
    }
        
    [self selectMultipleParcel:array selectedParcels:selectedArray];
    
    [searchGrid menuBarBtnBackSelected];    // return the search
}
-(void)hideSelectedParcels
{
    [searchGrid.view removeFromSuperview];
    searchGrid = nil;
}
//
// Hide the Grid controller
//
-(void)hideGridController
{
    UIView *topView = [self.view viewWithTag:2];
    // Put the screen off-screen
    searchGrid.view.frame = CGRectMake(0, 0, searchGrid.view.frame.size.width, searchGrid.view.frame.size.height);
    [topView sendSubviewToBack:searchGrid.view];
}
//
// The controller is being activated -- put the result of the search on it
//
-(void)activateController
{
    // create the empty arrea
    NSMutableArray *array = [[NSMutableArray alloc]init];
    
    SelectedProperties *properties = [RealProperty selectedProperties];
    // Get the current set of normal properties
    for(int i=0;i<properties.memGridIndex.count;i++)
    {
        NSNumber *number = [properties.memGridIndex objectAtIndex:i];
        RowProperty *row = [properties.memGrid objectAtIndex:[number intValue]];
        number = [[NSNumber alloc]initWithInt:((RealPropInfo *)row.realPropInfo).realPropId];
        [array addObject:number];
    }
    
    NSMutableArray *selectedArray = [[NSMutableArray alloc]init];
    
    NSArray *indexes = [properties listOfSelectedRows];
    
    for(NSNumber *num in indexes)
    {
        int index = [[properties.memGridIndex objectAtIndex:[num intValue]] intValue];
        
        RowProperty *row = [properties.memGrid objectAtIndex:index];
        NSNumber *number = [[NSNumber alloc]initWithInt:((RealPropInfo *)row.realPropInfo).realPropId];
        [selectedArray addObject:number];
        
    }

    [arcgisMap refreshParcelLayer];
    [self selectMultipleParcel:array selectedParcels:selectedArray];   
    RealPropertyApp *appDelegate = (RealPropertyApp*)[[UIApplication sharedApplication] delegate];
    if(appDelegate.searchMode)  
    {
        [arcgisMap centerParcel];
        [arcgisMap tabMapDetailIsDone];
        appDelegate.searchMode = NO;
    }
}
//
// Turn all layers off
//
-(void)tabBarWillSwitchController
{
    // [arcgisMap closeVisibleLayers];
}
#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    arcgisMap = [[ArcGisViewController alloc]initWithNibName:@"ArcGisViewController" bundle:nil];
    // arcgisMap.itsController = self;
    arcgisMap.delegate = self;
    
    // Obtain reference to the placeholder UIView (it's the one with the tag 1010) and will be the view assigned to hold the menuBar
    UIView *view = [self.view viewWithTag:1010];
    if(view==nil)
    {
        NSLog(@"TabMapController: can't find the view with tag 1010");
        return;
    }
    menuBar = [[ControlBar alloc]initWithNibName:@"TabMapControlBar" bundle:nil];
    [view addSubview:menuBar.view];
    [self addChildViewController:menuBar];
    menuBar.delegate = self;
    tabMapControllerView = self.view;
    // Add the map
    float topBarWidth = 0;
    if (view)
        topBarWidth = view.frame.size.height;
    [self addChildViewController:arcgisMap];
    [self.view addSubview:arcgisMap.view];
    
    CGRect rect = [Helper getScreenBoundsForCurrentOrientation];
    
    // Update the map rectangle
    CGRect mapRect = CGRectMake(rect.origin.x, rect.origin.y + topBarWidth, rect.size.width, rect.size.height - topBarWidth);

    // Enlarge the top bar
    view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y,
                            rect.size.width, view.frame.size.height);
    menuBar.view.frame = CGRectMake(menuBar.view.frame.origin.x, menuBar.view.frame.origin.y,
                                    rect.size.width, menuBar.view.frame.size.height);

    // Enlarge the background rect
    self.view.frame = rect;
    
    [arcgisMap.view setFrame:mapRect];
    // [arcgisMap.view setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin];
    
    UIView *gridView = [self.view viewWithTag:2];
    gridView.hidden = YES;
    
    [menuBar setItemEnable:kBtnSelectParcel isEnable:NO];
    [menuBar setItemEnable:kBtnClearParcel isEnable:NO];
    
    if([Helper isDeviceInLandscape])
        [self willRotateToInterfaceOrientation:UIInterfaceOrientationLandscapeLeft duration:0];
    else
        [self willRotateToInterfaceOrientation:UIInterfaceOrientationPortrait duration:0];
    
}
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{

    UIView *view = [self.view viewWithTag:1010];
    if(UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
    {
        view.frame = CGRectMake(0,0,1024,748);
        menuBar.view.frame = CGRectMake(0,0,1024, 44);
        
    }
    else 
    {
        view.frame = CGRectMake(0,0,768,1004);
        menuBar.view.frame = CGRectMake(0,0, 768, 44);
    }
    if(arcgisMap.mapDetail!=nil)
        [arcgisMap.mapDetail willRotateToInterfaceOrientation:toInterfaceOrientation duration:0];
    // Add the map
    float topBarWidth = menuBar.view.frame.size.height;
    CGRect rect = view.frame;
    
    // Update the map rectangle
    CGRect mapRect = CGRectMake(rect.origin.x, rect.origin.y + topBarWidth, rect.size.width, rect.size.height - topBarWidth);
    [arcgisMap.view setFrame:mapRect];
    
    [arcgisMap willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

#pragma mark - LifeCycle
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;

}
-(void)menuBarBtnBackSelected
{
}
@end
