#import "TabSearchGrid.h"
#import "ControlBar.h"
#import "TabSearchController.h"
#import "Helper.h"
#import "RealPropertyApp.h"
#import "SelectedObject.h"
#import "RealProperty.h"


@implementation TabSearchGrid

@synthesize delegate;
@synthesize gridController;
@synthesize searchDefinition;
@synthesize selObject;

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

#pragma mark - Grid Delegates

// Return TRUE if the delegate provides the data (instead of the attached arrays)
-(BOOL)getDataFromDelegate:(NSObject *)grid
{
    return YES;
}
-(void)gridRowSelection:(NSObject *)grid rowIndex:(int)rowIndex
{
}
-(void)gridRowSelection:(id)grid rowIndex:(int)rowIndex selected:(BOOL)selected
{
    [selObject selectRow:rowIndex selected:selected];
}
// Number of rows in the grid
-(int)numberOfRows:(NSObject *)grid
{
    // we can have less object after a filter...
    return [selObject.memGridIndex count];
}
// A grid has been selected
-(void)gridMediaSelection:(id)grid media:(id)media columnIndex:(int)columnIndex
{
}
// An add a picture button has been selected
-(void)gridMediaAddPicture:(id)grid
{
}
// Return the content of a cell (when the delgate provides the information
-(id)getCellData:(id)grid rowIndex:(int)rowIndex columnIndex:(int)columnIndex
{
    return [selObject getCellDataRowIndex:rowIndex columnIndex:columnIndex];
}
-(void)performQueries
{
    selObject = [RealProperty selectedProperties];
    
    if(selObject==nil)
    {
        selObject = [[SelectedProperties alloc]initWithSearchDefinition:searchDefinition colDefinition:colDefinition];
        [RealProperty setSelectedProperties:selObject];
    }
    else 
    {
        return;
    }
    [selObject performQueries];
}
#pragma mark - Asynchronous functions
-(void)showActivityBar:(NSString *)title
{

    UIView *topView = [TabBarController topView];
    CGRect bounds = [Helper getScreenBoundsForCurrentOrientation];
    
    UIView *screenView = [[UIView alloc]initWithFrame:bounds];
    screenView.backgroundColor = [[UIColor alloc]initWithRed:0.3 green:0.3 blue:0.3 alpha:0.0];
    
    [topView addSubview:screenView];
    [topView bringSubviewToFront:screenView];
    
    [screenView addSubview:progressView];
    [screenView bringSubviewToFront:progressView];
    blockingView = screenView;
    
    progressView.center = CGPointMake(screenView.frame.size.width/2.0, screenView.frame.size.height/4.0);
        
    progressBar.progress = 0.0;
    progressLabel.text = title;
    progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timerUpdateMethod:) userInfo:nil repeats:YES];
    
    UIButton *btn = [Helper createBlueButton:btnArea.frame withTitle:@"Stop"];
    [btnArea removeFromSuperview];
    [progressView addSubview:btn];
    [btn addTarget:self action:@selector(stopLoading:) forControlEvents:UIControlEventTouchUpInside];
}
-(void)stopLoading:(id)btn
{
    [workerThread cancel];
    [self hideActivityBar];
}
-(void)hideActivityBar
{
    [blockingView removeFromSuperview];
    blockingView = nil;
    [progressTimer invalidate];
    progressTimer = nil;
}
-(void)timerUpdateMethod:(NSTimer *)timer
{
    if(selObject.taskInProgress)
    {
        progressBar.progress = selObject.progressValue / selObject.progressMaxValue;
    }
    else
    {
        [selObject synchronizeObject:[AxDataManager getContext:@"default"]];
        workerThread = nil;
        [self hideActivityBar];

        // force a redisplay
        if(callbackAtCompletion!=nil)
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [targetAtCompletion performSelector:callbackAtCompletion];
    }
}
// Threaded loader
-(void)gridFilterLoadASyncData:(id)target selector:(SEL)selector title:(NSString *)title index:(int)columnIndex
{
    callbackAtCompletion = selector;
    targetAtCompletion = target;

    selObject.progressMaxValue = [selObject.memGrid count];
    if(selObject.progressMaxValue==0)
        selObject.progressMaxValue = 1;
    selObject.progressValue = 0;

    [self showActivityBar:title];
    workerThread = [[NSThread alloc]initWithTarget:selObject selector:@selector(loadMemGrid:) object:[NSNumber numberWithInt:columnIndex]];
    [workerThread setName:@"loadMemGrid"];
    selObject.taskInProgress = YES;

    [workerThread start];
}
//
// Sorting is requested to be performed
// def is the column to perform the operation (ItemDefinition)
-(void)headerSortSelection:(GridController *)grid entityDefinition:(ItemDefinition *)def
{
    callbackAtCompletion = @selector(headerSortSelection);
    sortIndex = 0;
    BOOL filtered = NO;
    for(ItemDefinition *item in colDefinition)
    {
        if(item==def)
        {
            break;
        }
        sortIndex++;
    }
    for(ItemDefinition *item in colDefinition)
    {
        if(item.filterOptions.filterValue!=nil)
        {
            filtered = YES;
            break;
        }
    }
    if(filtered)
    {
        [[RealProperty selectedProperties]reSort];
        [grid refreshAllContent];
        [self restoreSavedStatus];
        return;        
    }
    
    NSString *string = [NSString stringWithFormat:@"sort %d records...", selObject.memGrid.count];
    
    // Must be 1)simple name, 2)no join queries and 3)same entity name and no filters...
    if(![def isComplex] && searchDefinition.joinQueries.count==0 && [def.entityName caseInsensitiveCompare:searchDefinition.query.entityName]==NSOrderedSame)
    {
        searchDefinition.query.entitySortBy = def.path;
        searchDefinition.query.ascending = (def.filterOptions.sortOption == kFilterAscent)?YES:NO;
        [RealProperty setSelectedProperties:nil];
        [self performQueries];
        [grid refreshAllContent];
        [self restoreSavedStatus];
        return;
    }
    [self gridFilterLoadASyncData:self  selector:callbackAtCompletion title:string index:sortIndex];
}
-(void)headerSortSelection
{
    ItemDefinition *col = [colDefinition objectAtIndex:sortIndex];
    [selObject sortHeaderByColumnIndex:sortIndex ascending:col.filterOptions.sortOption==kFilterAscent type:col.type];
    [gridController refreshAllContent];
}
#pragma - Filter functions
//
// Retrieve unique values
//
-(void)gridFilterRetrieveUniqueEntries:(id)grid columnIndex:(int)columnIndex completion:(BlockWithArray)code
{
    ItemDefinition *col = [colDefinition objectAtIndex:columnIndex];
    
    // Must be 1)simple name, 2)no join queries and 3)same entity name
    if(![col isComplex] && searchDefinition.joinQueries.count==0 && [col.entityName caseInsensitiveCompare:searchDefinition.query.entityName]==NSOrderedSame)
    {
        // Read to do a select dictinct
        NSArray *results = [AxDataManager distinctSelect:searchDefinition.query.entityName fieldName:col.path sortAscending:YES andPredicate:searchDefinition.query.predicate withContext:[AxDataManager defaultContext]];
        NSMutableArray *array = [[NSMutableArray alloc]initWithCapacity:results.count];
        
        NSArray *luItems2 = nil;
        
        if(col.type==ftLookup)
            luItems2 = [LUItems2 LUItemsFromLookup:col.lookup];

        for(id object in results)
        {
            if([object isKindOfClass:[NSDictionary class]])
            {
                id res = [object objectForKey:col.path];
                if(col.type==ftLookup)
                {
                    LUItems2 *item = [luItems2 objectAtIndex:[res intValue]];
                    res = item.LUItemShortDesc;
                }
                [array addObject:[NSString stringWithFormat:@"%@", res]];
            }
        }
        
        code(array);
    }
    else
    {
        retrieveUniqueValues = code;
        filterIndex = columnIndex;
        callbackAtCompletion = @selector(retrieveFilters);
        NSString *string = [NSString stringWithFormat:@"lookup %d records...", selObject.memGrid.count];
        [self gridFilterLoadASyncData:self  selector:callbackAtCompletion title:string index:columnIndex];
    }
}
//
// Collect the filers
//
-(void)retrieveFilters
{
    NSMutableArray *filters = [[NSMutableArray alloc]init];
    
    for(RowProperty *row in selObject.memGrid)
    {
        id object = [row.columns objectAtIndex:filterIndex];
        if([object isKindOfClass:[NSNull class]])
            continue;
        if(![filters containsObject:object])
        {
            [filters addObject:object];
        }
    }
    
    NSArray *orderedFilters = [filters sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        
        if([obj1 isKindOfClass:[NSString class]] && [obj2 isKindOfClass:[NSString class]])
        {
            
            NSString *str1 = obj1;
            NSString *str2 = obj2;

            return [str1 caseInsensitiveCompare:str2];
        }
        else if([obj1 isKindOfClass:[NSNumber class]] && [obj2 isKindOfClass:[NSNumber class]])
        {
            double val1 = [obj1 doubleValue];
            double val2 = [obj2 doubleValue];
            
            return val1 - val2;
        }
        else if([obj1 isKindOfClass:[NSDate class]] && [obj2 isKindOfClass:[NSDate class]])
        {
            double val1 = [obj1 timeIntervalSinceReferenceDate];
            double val2 = [obj2 timeIntervalSinceReferenceDate];
            
            return val1 - val2;
        }
        return NSOrderedAscending;
    }];

    // need to convert back
    NSMutableArray *strs = [[NSMutableArray alloc]initWithCapacity:[orderedFilters count]];
    
    for(id object in orderedFilters)
    {
        [strs addObject:[NSString stringWithFormat:@"%@", object]];
    }
    orderedFilters = nil;
    retrieveUniqueValues(strs);

}
//
// Called to perform the filters
//
-(void)headerFilterSelection
{
    [selObject performFilters];
    [gridController refreshAllContent];
    [self updateResults];
}


#pragma - other functions
// Draw an image --called when an entity of type ftImg is foumd
-(void)drawImgEntity:(NSObject *)grid rowIndex:(int)rowIndex columnIndex:(int)columnIndex intoRect:(CGRect)rect
{
}
// Button action from the associated grid control bar
-(void)gridControlBarAction:(NSObject *)grid action:(int)param
{
}
-(void)selectAll
{
    return;
    // Deselect or select all in the grid
    _selectAll = !_selectAll;
    if(_selectAll)
        [gridController selectAllRows];
    else
        [gridController deselectAllRows];
    // Communicate that to the subrow...
    [selObject selectAllRows:_selectAll];
}
//
// Restore the status of the previous search
//
-(void)restoreSavedStatus
{
    // Select the rows
    if(!selObject.restricted)
        [gridController selectRows:[selObject listOfSelectedRows]];
    // Filter, etc.. should be restored as is...
    
    segControl.selectedSegmentIndex = selObject.restricted?1:0;
}
#pragma mark - menu bar btn selection
// The back button has been clicked
-(void)menuBarBtnBackSelected
{
    if([delegate respondsToSelector:@selector(tabSearchGridsetAutoSearch:)])
        [delegate performSelector:@selector(tabSearchGridsetAutoSearch:) withObject:[NSNumber numberWithInt:NO]];
    
    [gridController clearSortings];
    [gridController clearFilters];
    [delegate performSelector:@selector(tabSearchGridReturn)];
    
    // Destroy the default search
    [RealProperty setSelectedProperties:nil];
}
-(void)menuBarBtnSelected:(int)tag
{
    if(tag==100)
    {
        [self selectAll];
        return;
    }
    if(tag!=10 && tag!=11)
        return;

    if([delegate respondsToSelector:@selector(tabSearchGridsetAutoSearch:)])
        [delegate performSelector:@selector(tabSearchGridsetAutoSearch:) withObject:[NSNumber numberWithInt:YES]];

    if(tag==10)
    {
        if([delegate respondsToSelector:@selector(tabSearchGridswitchToMultipleParcels)])
            [delegate performSelector:@selector(tabSearchGridswitchToMultipleParcels)];
    }
    else if(tag==11)
    {
        if([delegate respondsToSelector:@selector(tabSearchGridselectMultiplePropertiesOnMap)])
            [delegate performSelector:@selector(tabSearchGridselectMultiplePropertiesOnMap)];
    }
}
-(void)didChangeSegmentControl:(UISegmentedControl *)control
{
    [self changeSegment:control.selectedSegmentIndex];
    if([delegate respondsToSelector:@selector(tabSearchGridChangedSelection)])
        [delegate performSelector:@selector(tabSearchGridChangedSelection)];
}
-(void)changeSegment:(int)index
{
    if(index==0)
    {
        // Show all the results, no filter
        [selObject toggleSelectionMode:YES];
        selObject.restricted = NO;
        gridController.cancelFilterMode = NO;
    }
    else if(index==1)
    {
        // Restrict to only the selected elements
        [selObject toggleSelectionMode:NO];
        selObject.restricted = YES;
        gridController.cancelFilterMode = YES;
    }
    NSArray *selected = [selObject listOfSelectedRows];
    [gridController selectRows:selected];
    [gridController refreshAllContent];
    [self updateResults];
}
#pragma mark - Create and delete the grid
-(void)updateResults
{
    NSString *str;
    if(selObject.restricted)
        str = [NSString stringWithFormat:@"%@: %d selected out of %d",searchDefinition.title, [selObject.memGridIndex count], [selObject.memGrid count]];
    else
    {
        int count = [self numberOfRows:nil];
        if(count > 1)
            str = [NSString stringWithFormat:@"%@: %d results", searchDefinition.title, count];
        else
            str = [NSString stringWithFormat:@"%@: %d result", searchDefinition.title, count];
    }
    [_menuBar setupBarLabel:str];
}
-(void)createGridFromSearch:(SearchDefinition2 *)search colDefinition:(NSMutableArray *)columnsDefinition
{
    searchDefinition = search;
    RealPropertyApp *appDelegate = (RealPropertyApp*)[[UIApplication sharedApplication] delegate];
    appDelegate.searchMode = YES;
    
    if(gridController!=nil)
    {
        [gridController removeFromParentViewController];
        [gridController.view removeFromSuperview];
        gridController.view = nil;
        gridController = nil;
    }
    // Create a new grid
    
    UIView *gridView = [[UIView alloc]initWithFrame:[self.view viewWithTag:100].frame];

    UIView *newView40 = [[UIView alloc]initWithFrame:[self.view viewWithTag:40].frame];
    [gridView addSubview:newView40];

    UIView *newView41 = [[UIView alloc]initWithFrame:[self.view viewWithTag:41].frame];
    [newView40 addSubview:newView41];

    UIView *newView42 = [[UIView alloc]initWithFrame:[self.view viewWithTag:42].frame];
    [newView40 addSubview:newView42];

    newView40.tag = 40;
    newView41.tag = 41;
    newView42.tag = 42;
    
    GridDefinition *gridDefinition = [EntityBase getGridWithName:searchDefinition.resultRef];
    if(gridDefinition == nil)
    {
        NSString *res = [NSString stringWithFormat:@"Can't find grid '%@'", searchDefinition.resultRef];
        [Helper alertWithOk:@"Error in the search" message:res];
        return;
    }
    colDefinition = gridDefinition.columns;
    
    gridController = [[GridController alloc]initWithParams:colDefinition viewTagId:gridDefinition.tag height:gridDefinition.rowHeight numberCol:gridDefinition.autoColumn];
    gridController.delegate = self;
    gridController.view = gridView;
    
    [gridController viewDidLoad];
    
    [self addChildViewController:gridController];
    [self.view addSubview:gridView];
    
    [self.view bringSubviewToFront:gridView];
    
    UIView *view = [self.view viewWithTag:1011];

    [self.view bringSubviewToFront:view];
    
    gridController.gridDefinition = gridDefinition;
    gridController.showFilterOption = YES;
    
    if(columnsDefinition!=nil)
    {
        colDefinition = columnsDefinition;
        [gridController reinitWithParams:colDefinition viewTagId:gridDefinition.tag height:gridDefinition.rowHeight numberCol:gridDefinition.autoColumn];
    }
    [gridController refreshAllContent];
    [self updateResults];
    
    if([delegate respondsToSelector:@selector(tabSearchGridsetAutoSearch:)])
        [delegate performSelector:@selector(tabSearchGridsetAutoSearch:) withObject:[NSNumber numberWithInt:YES]];

}
-(void)removeGrid
{
    colDefinition = nil;
    [gridController removeFromParentViewController];
    [gridController.view removeFromSuperview];
    gridController = nil;
}
//
// Perform a sort in the table based on the gridDefinition
//
-(void)performSort
{
    GridDefinition *definition = [gridController gridDefinition];
    if([definition.sortOption length]==0)
        return;     // Well, no need for a sort at this point
    
    for(int index=0;index<colDefinition.count;index++)
    {
        ItemDefinition *destDef = [colDefinition objectAtIndex:index];
        if([destDef.labelName length]==0)
            continue;
        if([destDef.labelName caseInsensitiveCompare:definition.sortOption]==NSOrderedSame)
        {
            destDef.filterOptions = [[GridFilterOptions alloc]init];
            destDef.filterOptions.sortOption = definition.sortDescending?kFilterDescent:kFilterAscent;
            destDef.filterOptions.columnIndex = index;
            // [self headerFilterSelection:gridController entityDefinition:destDef];
            [self headerSortSelection:gridController entityDefinition:destDef];
            break;
        }
    }
}
#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Add the Control bar
    UIView *view = [self.view viewWithTag:1011];
    if(view==nil)
    {
        NSLog(@"MenuBar: can't find the view with tag 1011");
        return;
    }
    _menuBar = [[ControlBar alloc]initWithNibName:@"TabSearchGridControlBar" bundle:nil];
    [view addSubview:_menuBar.view];
    [self addChildViewController:_menuBar];
    [_menuBar addBackButonWithTitle:@"New Search"];
    _menuBar.delegate = self;
    
    if([Helper isDeviceInLandscape])
    {
        [self willRotateToInterfaceOrientation:UIInterfaceOrientationLandscapeLeft duration:0];
    }
    else 
    {
        [self willRotateToInterfaceOrientation:UIInterfaceOrientationPortrait duration:0];
    }
    
    NSMutableArray *att = [[NSMutableArray alloc]init];
    [att addObject:@"All"];
    [att addObject:@"Selected"];
    

    segControl = [[UISegmentedControl alloc]initWithItems:att];
    [segControl addTarget:self action:@selector(didChangeSegmentControl:) forControlEvents:UIControlEventValueChanged];
    [segControl setSegmentedControlStyle:UISegmentedControlStyleBar];
    segControl.selectedSegmentIndex = 0;
    UIBarButtonItem *barButtonItem = [_menuBar getBarButtonItem:20];
    int width = barButtonItem.width;
    // [segControl setTintColor:[UIColor grayColor]];
     barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:segControl];
    barButtonItem.width = width;
    [_menuBar replaceItemWith:barButtonItem withTag:20];
}

- (void)viewDidUnload
{
    progressView = nil;
    progressLabel = nil;
    progressBar = nil;
    btnArea = nil;
    [super viewDidUnload];

    delegate = nil;
    gridController = nil;
    searchDefinition = nil;
    _menuBar = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if(UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
    {
        self.view.frame = CGRectMake(0, 0, 1024, 700);
        
        UIView *view = [self.view viewWithTag:1011];
        view.frame = CGRectMake(0,0,1024,44);
        _menuBar.view.frame = view.frame;
        
        view = [self.view viewWithTag:40];
        view.frame = CGRectMake(0,44,1024,654);
        view = [self.view viewWithTag:41];
        view.frame = CGRectMake(0,0,1024,40);
        view = [self.view viewWithTag:42];
        view.frame = CGRectMake(0,40,1024,614);        
    }
    else
    {
        self.view.frame = CGRectMake(0, 0, 768, 956);
        UIView *view = [self.view viewWithTag:1011];
        view.frame = CGRectMake(0,0,768,44);
        _menuBar.view.frame = view.frame;
        
        view = [self.view viewWithTag:40];
        view.frame = CGRectMake(0,44,768,910);
        view = [self.view viewWithTag:41];
        view.frame = CGRectMake(0,0,768,40);
        view = [self.view viewWithTag:42];
        view.frame = CGRectMake(0,40,768,870);
        
    }
}
@end
