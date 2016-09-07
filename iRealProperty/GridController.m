#import "GridController.h"
#import "Helper.h"
#import "EntityBase.h"
#import "EntityStructure.h"


@implementation GridController

@synthesize gridHeaderController;
@synthesize gridContentController;
@synthesize gridEntities;
@synthesize gridDesign;
@synthesize gridControlBar;
@synthesize delegate;
@synthesize isEditMode;
@synthesize gridDefinition;
@synthesize cancelFilterMode;
@synthesize showFilterOption;

- (id)initWithHeaderAndTag: (NSMutableArray *)headerDefinition :(int)viewTagId
{
    self = [super init];
    if (self)
    {
        // Setup the header cells
        gridEntities = headerDefinition;

        gridViewTagId = viewTagId;
        
        gridDesign = [[GridInfoDesign alloc]init];
        gridDesign.numCols = [gridEntities count];
        gridControlBar = nil;

        [self initHeaderCellDesign];
        [self calculateCellWidth];
        autoCount = FALSE;
        contentCellHeight = 36;        
        isEditMode = FALSE;      
    }
    return self;
}
-(id) initWithGridDefinition:(GridDefinition *)gridDef
{
    self = [super init];
    if(self)
    {
        gridDefinition = gridDef;
        [self reinitWithParams:gridDefinition.columns viewTagId:gridDefinition.tag height:gridDefinition.rowHeight numberCol:gridDefinition.autoColumn];
    }
    return self;
}
- (id)initWithParams: (NSArray *)headerDefinition viewTagId:(int)viewTagId height:(int)height numberCol: (BOOL) numberCol
{
    self = [super init];
    if (self) 
    {
        [self reinitWithParams:headerDefinition viewTagId:viewTagId height:height numberCol:numberCol];
    }
    return self;
}

- (void)reinitWithParams: (NSArray *)headerDefinition viewTagId:(int)viewTagId height:(int)height numberCol: (BOOL) numberCol
{
    // Setup the header cells
    autoCount = numberCol;
    
    for(ItemDefinition *entity in headerDefinition)
    {
        if(entity.filterOptions==nil && entity.type!=ftAuto)
        {
            entity.filterOptions = [[GridFilterOptions alloc]init];
            entity.filterOptions.sortOption = kFilterNone;
            entity.filterOptions.columnName = entity.labelName;
            entity.filterOptions.columnType = entity.type;
        }
    }
    
    gridEntities = headerDefinition;
    
    gridViewTagId = viewTagId;
    
    gridDesign = [[GridInfoDesign alloc]init];
    gridDesign.numCols = [gridEntities count];
    gridControlBar = nil;
    
    [self initHeaderCellDesign];
    [self calculateCellWidth];
    autoCount = numberCol;
    contentCellHeight = height;
    
    isEditMode = NO;

}
-(BOOL) isGridAutoCount
{
    return autoCount;
}
-(void)setGridAutoCount:(BOOL)value
{
    autoCount = value;
}
-(void) setGridContent: (NSArray *)rows
{
    gridContentController.gridContent = rows;
    
    // Adjust content
    AxGridView *contentView = (AxGridView *)[gridContentController.view.subviews objectAtIndex:0];
    [contentView layoutData];

}
-(NSArray *)getGridContent
{
    return gridContentController.gridContent;
}
-(void) setSingleSelection: (BOOL) singleOnly;
{
    [gridContentController setSingleSelection:singleOnly];
}

//
// All color information are here
//
-(void)initHeaderCellDesign
{
    [gridDesign setHeaderColors:[[UIColor alloc]initWithRed:80/255.0 green:160/255.0 blue:80/255.0 alpha:1.0] 
                               :[[UIColor alloc]initWithRed:120/255.0 green:220/255.0 blue:120/255.0 alpha:1.0]
                               :[[UIColor alloc]initWithRed:160/255.0 green:220/255.0 blue:160/255.0 alpha:1.0]
                               :[[UIColor alloc]initWithRed:220/255.0 green:220/255.0 blue:120/255.0 alpha:1.0]
                               :[[UIColor alloc]initWithRed:0 green:0 blue:0 alpha:1]];

    [gridDesign setHeaderFontInfo:@"Helvetica" :15.0 :12.0 :[UIColor whiteColor]];
    
    gridDesign.backgroundColor = [[UIColor alloc]initWithRed:0.85 green:0.85 blue:0.85 alpha:1.0];
    
    gridDesign.radius = 0; // 16
    gridDesign.borderWidth = 1.0;
    
    // Init the default cell information
    gridDesign.cellBackgroundColor = [[UIColor alloc]initWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    gridDesign.cellFontColor = [[UIColor alloc]initWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
    gridDesign.cellFontSize = 15.0;
    gridDesign.minimumCellFontSize = 12.0;
    gridDesign.cellFontName = @"Helvetica";
    
    gridDesign.cellFontSelectedColor = [[UIColor alloc]initWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
 
    // gridDesign.cellSelectedColor = [[UIColor alloc]initWithRed:73/255.0 green:130/255.0 blue:223/255.0 alpha:1.0];
    gridDesign.cellSelectedColor = [[UIColor alloc]initWithRed:244/255.0 green:143/255.0 blue:195/255.0 alpha:1.0];

}
//
// Calculate the width of each cell
//
-(void)calculateCellWidth
{
    for(ItemDefinition *def in gridEntities)
    {
        if(def.width == 0)
        {
            UIFont *tempFont = [UIFont fontWithName:gridDesign.headerFontName size:gridDesign.headerFontSize];
            CGSize rectSize = CGSizeMake(10000, 10000);
            CGSize textSize = [def.labelName sizeWithFont:tempFont constrainedToSize:rectSize lineBreakMode:NSLineBreakByWordWrapping];
            def.width = textSize.width+20;
            def.maxWidth = 500;
        }
    }
}
// Remove one filer
-(void)clearOneFilter:(int)index
{
    if(index<0 || index>gridEntities.count)
        return;
    ItemDefinition *item = [gridEntities objectAtIndex:index];
    if(item.filterOptions!=nil)
    {
        item.filterOptions.filterOperation = kFilterNone;
        item.filterOptions.filterValue = nil;
        item.filterOptions.sortOption = kFilterNone;  
    }    
}
// Remove all the filtering
-(void)clearFilters
{
    for(ItemDefinition *entity in gridEntities)
    {
        if(entity.filterOptions!=nil)
        {
            entity.filterOptions.filterOperation = kFilterNone;
            entity.filterOptions.filterValue = nil;
            entity.filterOptions.sortOption = kFilterNone;  
        }
    }
}
// Remove the sortings
-(void)clearSortings
{
    for(ItemDefinition *entity in gridEntities)
    {
        if(entity.filterOptions!=nil)
        {
            entity.filterOptions.sortOption = kFilterNone;  
        }
    }
    
}
- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Create the controller and view for the header
    
    UIView *headerView = [self.view viewWithTag:gridViewTagId+1];
    
    if(headerView == nil)
        @throw [NSException exceptionWithName:@"GridController:viewDidLoad" reason:[NSString stringWithFormat:@"Can't find the view with tag=%d", gridViewTagId+1] userInfo:nil];
    
    
    gridHeaderController = [[GridHeaderController alloc]init];
    gridHeaderController.gridController = self;
    
    gridHeaderController.view = headerView;
    
    [gridHeaderController initBaseInfo];
    [self addChildViewController:gridHeaderController];
    [gridHeaderController viewDidLoad];   
    [headerView setBackgroundColor:[UIColor clearColor]];

    // Create the content view
    UIView *contentView = [self.view viewWithTag:gridViewTagId+2];
    if(contentView == nil)
        @throw [NSException exceptionWithName:@"GridController:viewDidLoad" reason:[NSString stringWithFormat:@"Can't find the view with tag=%d", gridViewTagId+2] userInfo:nil];
    
    gridContentController = [[GridContentController alloc] initWithRowHeight:contentCellHeight];
    gridContentController.gridController = self;
    
    gridContentController.view = contentView;
    [self addChildViewController:gridContentController];
    [gridContentController viewDidLoad];
    [contentView setBackgroundColor:[UIColor clearColor]];
    
    // if the grid has a control bar, look for it
    [self switchControlBar:kGridControlModeDeleteAdd];
     // Clear up background
    [self.view setBackgroundColor:[UIColor clearColor]];
}

//
// Switch the GridControlBar
//
-(void)switchControlBar:(enum GridControlBarConstant)bar
{
    UIView *controlBarView = [self.view viewWithTag:gridViewTagId+3];
    if(controlBarView==nil)
        return;

    [gridControlBar.view removeFromSuperview];
    [gridControlBar removeFromParentViewController];
    id temp = gridControlBar.delegate;
    NSString *nibName;
    switch (bar) {
        case kGridControlModeDeleteAdd:
            nibName = @"GridControlBarDeleteAdd";
            break;
        case kGridControlModeNextPrevious:
            nibName = @"GridControlBarNextPrevious";
            break;
        case kGridControlModeDeleteCancel:
            nibName = @"GridControlBarDeleteCancel";
            break;
        case kGridControlModeSaveCancel:
            nibName = @"GridControlBarSaveCancel";
            break;
        case kGridControlModeEmpty:
            nibName = @"GridControlBarEmpty";
            break;
            
        default:
            return;
            break;
    }
    currentBarMode = bar;
    
    gridControlBar = [[GridControlBar alloc]initWithNibName:nibName barMode:currentBarMode];
    gridControlBar.delegate = temp;
    gridControlBar.gridController = self;
    [self addChildViewController:gridControlBar];
    [controlBarView addSubview:gridControlBar.view];
    [gridControlBar adjustFrame:controlBarView.frame];
}
//
// Enter edit mode
//
-(void)enterEditMode
{
    if(isEditMode)
        return;
    UIView *controlBarView = [self.view viewWithTag:gridViewTagId+3];
    if(controlBarView!=nil)
    {
        savedBarMode = currentBarMode;
        [self switchControlBar:kGridControlModeDeleteCancel];
    }
    isEditMode = YES;
    
    [self refreshAllContent];
//    [self setSingleSelection:YES];
}
//
// Exit edit mode and return to a previous mode
//
-(void)cancelEditMode
{
    if(!isEditMode)
        return;
    UIView *controlBarView = [self.view viewWithTag:gridViewTagId+3];
    if(controlBarView!=nil)
    {
        [self switchControlBar:savedBarMode];
    }
    isEditMode = NO;
    
    [self refreshAllContent];  
//    [self setSingleSelection:YES];
}

// DBaun 062914 (New Permit Form) Possible performance issue here (not mine, just stumbled on it)
-(NSArray *)getSelectedRows
{
    if([self getGridContent]==nil)
        return [gridContentController selectedRows];
    else
    {
        NSMutableArray *rows = [[NSMutableArray alloc]init];
        NSArray *selectedRows = [gridContentController selectedRows];
        for(NSNumber *number in selectedRows)
        {
            NSArray *array = [self getGridContent]; //<DB_PERF> Very bad spot for this. Move it outside the for loop
            if([number intValue]<0 || [number intValue]>=[array count])
                continue;
            [rows addObject:[array objectAtIndex:[number intValue]]];
        }
        return rows;
    }
}
#pragma mark -- Supporting functions
- (void)contentDidScroll:(UIScrollView *)scrollView
{
    // Content has moved -- move the Header Content
    CGPoint pt = scrollView.contentOffset;
    pt.y = 0;
    
    AxGridView *headerView = [gridHeaderController.view.subviews objectAtIndex:0];
    headerView.contentOffset = pt;
}
- (void)headerDidScroll:(UIScrollView *)headerView
{
    // Header has moved -- move the Content
    AxGridView *contentView = [gridContentController.view.subviews objectAtIndex:0];
    CGPoint pt = CGPointMake(headerView.contentOffset.x, contentView.contentOffset.y);
    contentView.contentOffset = pt;
}
//
// Adjust the width of one column
-(void) adjustColumnWidth:(int)column :(int)newWidth
{
    if(column <0 || column >= [gridEntities count])
        return;
    ItemDefinition *obj = [gridEntities objectAtIndex:column];
    obj.width = newWidth;
    
    // adjust the header
    AxGridView *headerView = (AxGridView *)[gridHeaderController.view.subviews objectAtIndex:0];
    [headerView layoutData];   
    // Adjust content
    AxGridView *contentView = (AxGridView *)[gridContentController.view.subviews objectAtIndex:0];
    [contentView layoutData];
}
// Do a full refresh
-(void)refreshAllContent
{
    // [self cleanSorting];
    // [gridContentController deselectAllRows];

    // adjust the header
    AxGridView *headerView = (AxGridView *)[gridHeaderController.view.subviews objectAtIndex:0];
    [headerView layoutData];   
    // Adjust content
    AxGridView *contentView = (AxGridView *)[gridContentController.view.subviews objectAtIndex:0];
    [contentView layoutData];    
}
-(void)refreshAllContentWithSelection
{
    // adjust the header
    AxGridView *headerView = (AxGridView *)[gridHeaderController.view.subviews objectAtIndex:0];
    [headerView layoutData];   
    // Adjust content
    AxGridView *contentView = (AxGridView *)[gridContentController.view.subviews objectAtIndex:0];
    [contentView layoutData];    
}
//
// Adjust the width of all the columns to fit properly in the tableWidth
// Only column that is not resized is the the first column
-(void)adjustColumnToWidth:(CGFloat)tableWidth
{
    int start = 0;
    ItemDefinition *entity = [gridEntities objectAtIndex:0];
    if(entity.type==ftAuto)
    {
        tableWidth -= 35;
        start = 1;
    }

    CGFloat width = 0;
    for(int i=start;i<[gridEntities count];i++)
    {
        ItemDefinition *entity = [gridEntities objectAtIndex:i];
        width += entity.width;
    }
    CGFloat percent = (CGFloat)tableWidth/(CGFloat)width;

    width = 0;
    for(int i=start;i<[gridEntities count];i++)
    {
        ItemDefinition *entity = [gridEntities objectAtIndex:i];
        entity.width = entity.width * percent;
        width += entity.width;
    }  

    // adjust the header
    AxGridView *headerView = (AxGridView *)[gridHeaderController.view.subviews objectAtIndex:0];
    [headerView layoutData];   
    // Adjust content
    AxGridView *contentView = (AxGridView *)[gridContentController.view.subviews objectAtIndex:0];
    [contentView layoutData];
}
//
// Fit the grid to the view
-(void)autoFitToView
{
    [self adjustColumnToWidth:self.view.frame.size.width];
}
-(void)autoFitToView:(CGFloat)width
{
    [self adjustColumnToWidth:width];    
}
//
// Update the frame
//
-(void)updateContentFrame:(CGRect)rect
{
    UIView *headerView = [self.view viewWithTag:gridViewTagId+1];
    UIView *contentView = [self.view viewWithTag:gridViewTagId+2];
    
    CGRect rectHeader = headerView.frame;
    
    // Setup the entire view
    self.view.frame = rect;
    
    headerView.frame = CGRectMake(0, 0, rect.size.width, rectHeader.size.height);
    contentView.frame = CGRectMake(0,rectHeader.size.height, rect.size.width, rect.size.height - rectHeader.size.height);
}

//
// Rows have been selected (or deselected)
-(void) selectedRows: (NSArray *)rows rowIndex:(int)rowIndex
{
    if(delegate!=nil && !isEditMode)
    {
        if([delegate respondsToSelector:@selector(gridRowSelection:rowIndex:)])
            [delegate gridRowSelection:self rowIndex:rowIndex];
        if([delegate respondsToSelector:@selector(gridRowSelection:rowIndex:selected:)])
        {
            BOOL selected = [gridContentController isRowSelected:rowIndex];
            [delegate gridRowSelection:self rowIndex:rowIndex selected:selected];
        }
    }
}
-(void) deselectAllRows
{
    [gridContentController deselectAllRows];
    [self refreshAllContent];
}
-(void) selectAllRows
{
    [gridContentController selectAllRows];
    [self refreshAllContentWithSelection];    
}
-(void) selectRows:(NSArray *)rows
{
    [gridContentController selectRows:rows];
    [self refreshAllContentWithSelection];    
}
// 
// Handles all the menu selection action
//
-(void) headerMenuSelection: (enum gridSelectionConstant)menuChoice :(int)columnIndex
{
    ItemDefinition *entity = [gridEntities objectAtIndex:columnIndex];
    filteredColumnIndex = columnIndex;

    
    if(menuChoice==gridSelectionFilter)
    {
        GridFilter *gridFilter = [[GridFilter alloc]initWithNibName:@"GridFilter" bundle:nil];
        gridFilter.filterOptions = entity.filterOptions;
        gridFilter.filterOptions.columnIndex = columnIndex;
        ItemDefinition *definition = [gridEntities objectAtIndex:columnIndex];
        gridFilter.filterOptions.columnType = definition.type;
        CGSize size = gridFilter.view.frame.size;
        gridFilter.delegate = self;
        gridFilter.gridDelegate = delegate;
        UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:gridFilter];
        navController.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:navController animated:NO completion:^(void) { }];
        navController.view.superview.frame = CGRectMake(0, 0, size.width, size.height);
        UIView *topView = [Helper topViewFrom:self.view];
        navController.view.superview.center = topView.center;
    }
    else if(menuChoice==gridSelectionAllClear)
    {
        [self clearSortings];
        [self clearFilters];
        if([delegate respondsToSelector:@selector(headerFilterSelection)])
            [delegate headerFilterSelection];
    }
    else if(menuChoice==gridSelectionClear)
    {
        // Clear only the filer
        [self clearOneFilter:columnIndex];
        if([delegate respondsToSelector:@selector(headerFilterSelection)])
            [delegate headerFilterSelection];
    }
    else if(menuChoice==gridSelectionAsc)
    {
        [self clearSortings];
        entity.filterOptions.sortOption = kFilterAscent;
        if([delegate respondsToSelector:@selector(headerSortSelection:entityDefinition:)])
            [delegate headerSortSelection:self entityDefinition:entity];
    }
    else if(menuChoice==gridSelectionDesc)
    {
        [self clearSortings];
        entity.filterOptions.sortOption = kFilterDescent;
        if([delegate respondsToSelector:@selector(headerSortSelection:entityDefinition:)])
            [delegate headerSortSelection:self entityDefinition:entity];
    }
    // Refresh the header
    [gridHeaderController filterDone];
    AxGridView *headerView = (AxGridView *)[gridHeaderController.view.subviews objectAtIndex:0];
    [headerView layoutData];
}
-(void) didDismissModalView:(id)params saveContent:(BOOL)saveContent
{
    [self dismissViewControllerAnimated:NO  completion:^(void){}];
    
    if(saveContent)
    {

        AxGridView *headerView = (AxGridView *)[gridHeaderController.view.subviews objectAtIndex:0];
        [headerView layoutData];
        // Execute the filter for this column...
        if([delegate respondsToSelector:@selector(headerFilterSelection)])
            [delegate headerFilterSelection];
    }
    [gridHeaderController filterDone];
}
#pragma mark -- default view controller functions
- (void)viewDidUnload
{
    [super viewDidUnload];
    [gridHeaderController viewDidUnload];
    [gridContentController viewDidUnload];
    [gridHeaderController removeFromParentViewController];
    [gridContentController removeFromParentViewController];
    gridHeaderController = nil;
    gridContentController = nil;
    gridEntities = nil;
    gridDefinition = nil;
    gridControlBar = nil;
    gridDesign = nil;
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
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
#pragma mark - Resize the grid to a new view dimension
-(void)resizeToView:(UIView *)view headerHeight:(CGFloat)headerHeight
{
    UIView *baseView = [view viewWithTag:gridViewTagId];
    baseView.frame = CGRectMake(baseView.frame.origin.x, baseView.frame.origin.y,
                                view.frame.size.width, view.frame.size.height);
    baseView = [baseView superview];
    if(baseView.tag==1)
        baseView.frame = CGRectMake(baseView.frame.origin.x, baseView.frame.origin.y,
                                    view.frame.size.width, view.frame.size.height);
    else
        NSLog(@"*** can't find view with tag 1");

    CGFloat width, top = 0;
    
    width = view.frame.size.width;
    
    UIView *controlBarView = [view viewWithTag:gridViewTagId+3];
    if(controlBarView!=nil)
    {
        controlBarView.frame = CGRectMake(0, 0, width, gridControlBar.view.frame.size.height);
        [gridControlBar adjustFrame:controlBarView.frame];
        top +=  controlBarView.frame.size.height;
    }
    baseView = [view viewWithTag:gridViewTagId+1];

    baseView.frame = CGRectMake(0, top, width, headerHeight );
    top += headerHeight;

    gridHeaderController.view.frame = baseView.frame;
    [gridHeaderController.gridView layoutData];
    
    baseView = [view viewWithTag:gridViewTagId+2];
    CGFloat contentHeight = view.frame.size.height - top;
    baseView.frame = CGRectMake(0, top, width, contentHeight);
    gridContentController.view.frame = baseView.frame;
    // gridContentController.view.frame = baseView.frame;
    [gridContentController.gridView layoutData];

    baseView = [view viewWithTag:gridViewTagId+3];
    [self refreshAllContent];

}
@end