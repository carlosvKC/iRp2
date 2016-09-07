#import "TabSearchController.h"
#import "RealPropertyApp.h"
#import "StreetController.h"
#import "Helper.h"
#import "RealProperty.h"
#import "SelectedObject.h"

#pragma mark - Definitions
@implementation TabSearchController

    @synthesize searchBase;
    @synthesize searchTable;
    @synthesize searchItems;
    @synthesize autoSearch;
    @synthesize saveHeader, saveRows;



    - (id)initWithNibName:(NSString *)nibNameOrNil
                   bundle:(NSBundle *)nibBundleOrNil
        {
            self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
            if (self)
                {
                    self.title            = @"Search";
                    self.tabBarItem.image = [UIImage imageNamed:@"Search-Small.png"];
                    autoSearch = NO;
                }
            return self;
        }



    - (void)didReceiveMemoryWarning
        {
            [super didReceiveMemoryWarning];

            searchGrid.view = nil;
            searchGrid = nil;
        }

#pragma mark - Menubar delegate

    - (void)menuBarBtnBackSelected
        {
        }



    - (void)menuBarBtnSelected:(int)tag
        {

        }
#pragma mark - Switch between the different searches
    - (void)tableSelection:(SearchDefinition2 *)definition
        {
            // Remove the current controller (if any)
            if (searchController != nil)
                {
                    [searchController removeFromParentViewController];
                    [searchController.view removeFromSuperview];
                    if (searchController == searchItems)
                        {
                            [searchItems removeAllObjects];
                        }
                    //[searchController viewDidUnload];
                }
            // Look at the definition
            searchDefinition = definition;

            switch (definition.searchType)
                {
                    case kSearchByItems:
                        searchController = searchItems;
                    break;
                    case kSearchByParcel:
                        searchController = parcelSearch;
                    break;
                    case kSearchByStreet:;
                    searchController = streetController;
                    break;
                    default:
                        break;
                }
            UIView *view = [self.view viewWithTag:6];
            if ([searchController respondsToSelector:@selector(setItsController:)])
                [searchController performSelector:@selector(setItsController:) withObject:self];

            if (view != nil)
                {
                    [view addSubview:searchController.view];
                    [self addChildViewController:searchController];
                    // Adjust the height
                    [streetController adjustHeight:tableHeight];
                }

            if (searchController == searchItems)
                [searchItems setSearchDefinition:definition];
            else if (searchController == parcelSearch)
                [parcelSearch setSearchDefinition:definition];
        }



//
// A street was selected
//
    - (void)popoverItemSelected:(NSObject *)item
        {
            @try
                {
                    [Helper findAndResignFirstResponder:self.view];
                    NSNumber        *num       = (NSNumber *) item;
                    QueryDefinition *query     = searchDefinition.query;
                    NSPredicate     *predicate = [NSPredicate predicateWithFormat:query.query, [num intValue]];

                    NSArray *array = [AxDataManager dataListEntity:query.entityName andSortBy:query.entitySortBy andPredicate:predicate];


                    if ([array count] == 0)
                        {
                            [Helper alertWithOk:@"No parcel found!" message:@"The selected street does not have any parcel"];
                            return;
                        }
                    else if ([array count] == 1)
                        {

                            RealPropInfo       *propInfo         = (RealPropInfo *) [array objectAtIndex:0];
                            SelectedProperties *selectProperties = [[SelectedProperties alloc] initWithRealPropInfo:propInfo];
                            [RealProperty setSelectedProperties:selectProperties];
                            [self switchToParcel:[NSNumber numberWithInt:propInfo.realPropId]];
                            self.autoSearch = NO;
                            return;
                        }
                    // Case where there are a couple of parcels

                    query.predicate = predicate;
                    [self switchToGridWithArray];
                    self.autoSearch = NO;

#ifdef _LATER_
        fetchedController = [AxDataManager getFetchedResultsController:query.entityName  andSortBy:query.entitySortBy ascending:query.ascending  andPredicate:predicate cacheName:nil];

        NSError *anyError;
        if(![fetchedController performFetch:&anyError])
        {
            [Helper alertWithOk:@"Database Error" message:[anyError localizedDescription]];
            return;
        }
        id<NSFetchedResultsSectionInfo>sectionInfo = [[fetchedController sections] objectAtIndex:0];
        
        if([sectionInfo numberOfObjects]==0)
        {
            [Helper alertWithOk:@"No parcel found!" message:@"The selected street does not have any parcel."];
        }
        else if([sectionInfo numberOfObjects]==1)
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            NSManagedObject *managedObject = [fetchedController objectAtIndexPath:indexPath];

            RealPropInfo *propInfo = [TabSearchGrid getRealPropInfoFromPath:managedObject withPath:@"rRealPropInfo"];
            [self switchToParcel:[NSString stringWithFormat:@"%@%@", propInfo.major, propInfo.minor]]; 
        }
        else
        {
            [self switchToGridWithFetchedResults:searchDefinition];
        }
#endif
                }
            @catch (NSException *exception)
                {
                    NSLog(@"%@", exception);
                    [Helper alertWithOk:@"2) Query Error" message:[exception description]];

                }
        }



//
// Multiple variables are selected
//
    - (void)searchWithArray:(NSDictionary *)variables
        {
            @try
                {
                    QueryDefinition *query = searchDefinition.query;

                    if (query.query.length == 0)
                        return;
                    NSMutableString *queryResult  = [[NSMutableString alloc] initWithString:query.query];
                    NSPredicate     *varPredicate = [NSPredicate predicateWithFormat:[ItemDefinition replaceDateFilter:queryResult]];
                    queryResult = nil;
                    NSPredicate *predicate = [varPredicate predicateWithSubstitutionVariables:variables];
                    query.predicate = predicate;
                    NSLog(@"search predicate=%@", predicate);

                    // check if there is a join search
                    if ([searchDefinition.joinQueries count] > 0)
                        {
                            for (int i = 0; i < [searchDefinition.joinQueries count]; i++)
                                {
                                    QueryDefinition *query = [searchDefinition.joinQueries objectAtIndex:i];
                                    if ([query.query length] == 0)
                                        continue;
                                    NSMutableString *queryResult  = [[NSMutableString alloc] initWithString:query.query];
                                    NSPredicate     *varPredicate = [NSPredicate predicateWithFormat:[ItemDefinition replaceDateFilter:queryResult]];
                                    queryResult = nil;
                                    NSPredicate *predicate = [varPredicate predicateWithSubstitutionVariables:variables];
                                    query.predicate = predicate;
                                    NSLog(@"join predicate=%@", predicate);
                                }
                        }
                    if (!autoSearch)
                        [RealProperty setSelectedProperties:nil];
                    [self switchToGridWithArray];
                }
            @catch (NSException *exception)
                {
                    NSLog(@"%@", exception);
                    // [Helper alertWithOk:@"3) Query Error" message:[exception description]];

                }
        }



    - (void)deleteSearchGrid
        {
            [searchGrid removeGrid];
            [searchGrid.view removeFromSuperview];
            [searchGrid removeFromParentViewController];
            searchGrid = nil;
        }



    - (void)switchToParcel:(id)parcel
        {
            // Save the data before deleting
            [self deleteSearchGrid];
            RealPropertyApp *appDelegate = (RealPropertyApp *) [[UIApplication sharedApplication] delegate];
            [appDelegate switchToProperty:parcel];
        }



    - (void)switchToMultipleParcels
        {
            [self deleteSearchGrid];
            RealPropertyApp *appDelegate = (RealPropertyApp *) [[UIApplication sharedApplication] delegate];
            [appDelegate switchToProperties];
        }



    - (void)selectMultiplePropertiesOnMap
        {
            [self deleteSearchGrid];
            RealPropertyApp *appDelegate = (RealPropertyApp *) [[UIApplication sharedApplication] delegate];
            [appDelegate selectMultiplePropertiesOnMap];
        }



    - (void)switchToGridWithArray
        {

            if (searchGrid == nil)
                [self createSearchGrid];

            if (!autoSearch)
                [RealProperty setSelectedProperties:nil];

            // Need to refresh the grid
            [searchGrid createGridFromSearch:searchDefinition colDefinition:saveHeader];

            searchGrid.searchDefinition = searchDefinition;

            [searchGrid performQueries];

            [searchGrid.gridController refreshAllContent];
            searchGrid.delegate = self;
            [searchGrid.gridController setSingleSelection:NO];

            [searchGrid updateResults];

            [searchGrid performSort];

            UIView *topView = [self.view viewWithTag:2];
            [topView addSubview:searchGrid.view];

            // Put the screen off-screen
            searchGrid.view.frame = CGRectMake(1024, 0, searchGrid.view.frame.size.width, searchGrid.view.frame.size.height);
            [topView bringSubviewToFront:searchGrid.view];
            // ANIMATE: move from right to left

            [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^
                {
                    searchGrid.view.frame = CGRectOffset(searchGrid.view.frame, -1024, 0);
                }            completion:nil];
        }



    - (void)switchBackFromGridController
        {
            [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^
                {
                    searchGrid.view.frame = CGRectOffset(searchGrid.view.frame, 1024, 0);
                }            completion:^(BOOL finished)
                {
                    UIView *topView       = [self.view viewWithTag:2];
                    // Put the screen off-screen
                    searchGrid.view.frame = CGRectMake(0, 0, searchGrid.view.frame.size.width, searchGrid.view.frame.size.height);
                    [topView sendSubviewToBack:searchGrid.view];
                    [self deleteSearchGrid];
                }];
        }


#pragma mark - View lifecycle

    - (void)viewDidLoad
        {
            [super viewDidLoad];
            // Load the XML file for all the searches
            searchBase = [[SearchBase alloc] initWithXMLFile:@"SearchDefinition2"];

            if (searchBase.searchGroups == nil)
                return;

            // Create the list of searches on the left
            searchTable = [[TabSearchTable alloc] initWithNibNameAndSearch:@"TabSearchTable" searchBase:searchBase];

            UIView *view = [self.view viewWithTag:5];
            [view addSubview:searchTable.view];
            searchTable.view.frame    = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height);
            searchTable.itsController = self;
            [self.view bringSubviewToFront:searchTable.view];

            [self addChildViewController:searchTable];


            searchItems = [[TabSearchItems alloc] initWithNibName:@"TabSearchItems" bundle:nil];
            searchItems.itsController = self;
            parcelSearch = [[ParcelSearch alloc] initWithNibName:@"ParcelSearch" bundle:nil];
            parcelSearch.itsController = self;
            streetController = [[StreetController alloc] initWithNibName:@"SearchStreetController" bundle:nil];
            streetController.delegate = self;

            searchController = nil; // nothing inserted yet

            // add the first definition
            SearchGroup      *group = [searchBase.searchGroups objectAtIndex:0];
            SearchDefinition2 *def   = [group.searchDefinitions objectAtIndex:0];

            [self tableSelection:def];

            NSIndexPath *index = [NSIndexPath indexPathForRow:0 inSection:0];
            [searchTable.tableView selectRowAtIndexPath:index animated:NO scrollPosition:UITableViewScrollPositionNone];
            // Add the Control bar
            view = [self.view viewWithTag:1010];
            if (view == nil)
                {
                    NSLog(@"MenuBar: can't find the view with tag 1010");
                    return;
                }

            menuBar = [[ControlBar alloc] initWithNibName:@"TabSearchControlBar" bundle:nil];
            [view addSubview:menuBar.view];
            [self addChildViewController:menuBar];


            menuBar.delegate = self;

            [self willRotateToInterfaceOrientation:[Helper deviceOrientation] duration:0];


        }



    - (void)createSearchGrid
        {
            UIView *topView = [self.view viewWithTag:2];

            searchGrid = [[TabSearchGrid alloc] initWithNibName:@"TabSearchGrid" bundle:nil];
            searchGrid.view.frame = CGRectMake(0, 0, topView.frame.size.width, topView.frame.size.height);

            [searchGrid.view removeFromSuperview];

            [topView addSubview:searchGrid.view];
            [topView sendSubviewToBack:searchGrid.view];
            [self addChildViewController:searchGrid];

            searchGrid.delegate = self;
            [searchGrid.gridController setSingleSelection:NO];

        }



//
// When this controller becomes active
//
    - (void)activateController
        {
            NSString *label = [NSString stringWithFormat:@"Search in %@", [RealPropertyApp getWorkingArea]];
            [menuBar setupBarLabel:label];

            if (self.autoSearch)
                {
                    SelectedProperties *sel = [RealProperty selectedProperties];
                    if (sel)
                        searchDefinition = sel.searchDefinition;
                    [searchItems performSearch:self];
                    [searchGrid restoreSavedStatus];
                }
            if ([Helper isDeviceInLandscape])
                [self willRotateToInterfaceOrientation:UIInterfaceOrientationLandscapeLeft duration:0];
            else
                [self willRotateToInterfaceOrientation:UIInterfaceOrientationPortrait duration:0];

        }
#pragma mark - Tab SearchGrid delegate
    - (void)tabSearchGridAddChildViewController:(GridController *)grid
        {
            [self addChildViewController:grid];
        }



    - (void)tabSearchGridReturn
        {

            [self switchBackFromGridController];
        }



    - (void)tabSearchGridswitchToMultipleParcels
        {
            [self switchToMultipleParcels];
        }



    - (void)tabSearchGridselectMultiplePropertiesOnMap
        {
            [self selectMultiplePropertiesOnMap];
        }



    - (void)tabSearchGridsetAutoSearch:(NSNumber *)search
        {
            autoSearch = [search intValue];
        }



    - (void)tabSearchGridChangedSelection
        {
            RealPropertyApp *appDelegate = (RealPropertyApp *) [[UIApplication sharedApplication] delegate];
            [appDelegate gridSelectionHasChanged];
        }



    - (void)tabSearchGridAddController:(GridController *)grid
        {
            [self addChildViewController:grid];
        }
#pragma mark - TabBar delegate
    - (void)tabBarWillSwitchController
        {
            // time to clean up (if not already)
           [self deleteSearchGrid];      //cv MapDetailCamera
        }



    - (void)viewDidUnload
        {
            [super viewDidUnload];
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



    - (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                    duration:(NSTimeInterval)duration
        {
            UIView *view;
            // Adjust the different sub-views
            if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
                {
                    // Landscape mode

                    view = [self.view viewWithTag:2];
                    view.frame = CGRectMake(0, 0, 1024, 748);

                    view = [self.view viewWithTag:5];
                    view.frame             = CGRectMake(0, 44, 548, 660);
                    searchTable.view.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height);
                    view = [self.view viewWithTag:6];
                    view.frame = CGRectMake(548, 44, 476, 660);

                    [streetController adjustHeight:610];
                    tableHeight = 610;

                    view = [self.view viewWithTag:1010];
                    view.frame = CGRectMake(0, 0, 1024, view.frame.size.height);

                    menuBar.view.frame = view.frame;
                }
            else
                {
                    view = [self.view viewWithTag:2];
                    view.frame = CGRectMake(0, 0, 768, 1004);

                    view = [self.view viewWithTag:5];
                    view.frame             = CGRectMake(0, 44, 292, 916);
                    searchTable.view.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height);
                    view = [self.view viewWithTag:6];
                    view.frame = CGRectMake(292, 44, 476, 916);
                    [streetController adjustHeight:866];
                    tableHeight = 866;
                    view        = [self.view viewWithTag:1010];
                    view.frame = CGRectMake(0, 0, 768, view.frame.size.height);

                    menuBar.view.frame = view.frame;
                }
        }

@end
