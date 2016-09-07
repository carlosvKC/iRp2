

#import "GridHeaderController.h"
#import "Helper.h"
#import "GridController.h"

@implementation GridHeaderController

@synthesize rowHeight;
@synthesize gridController;

- (void)initBaseInfo
{
    rowHeight = self.view.frame.size.height;
    resizeView = nil;
}

- (void)dealloc 
{
    resizeView = nil;
}

- (void)viewDidLoad 
{
    [super viewDidLoad];
	
	self.gridView.delegate = self;
	self.gridView.dataSource = self;
	self.gridView.bounces = NO;
    
    // Don't show the scrolls
    self.gridView.showsVerticalScrollIndicator = FALSE;
    self.gridView.showsHorizontalScrollIndicator = FALSE;
}
-(void)viewDidUnload
{
    [self.gridView removeFromSuperview];
    self.gridView = nil;
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
    return YES;

}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [gridController headerDidScroll:scrollView];
}
- (void) setGridController : (GridController *)controller
{
    gridController = controller;
}
#pragma mark -
#pragma mark AxGridViewDataSource methods

- (NSInteger)numberOfRowsInGridView:(AxGridView *)gridView 
{
	return 1;
}
- (NSInteger)numberOfColumnsInGridView:(AxGridView *)gridView forRowWithIndex:(NSInteger)index 
{
    int count = [gridController.gridEntities count];
	return count;
}

- (CGFloat)gridView:(AxGridView *)gridView heightForRow:(NSInteger)rowIndex 
{
    return rowHeight;
}
- (CGFloat)gridView:(AxGridView *)gridView widthForCellAtRow:(NSInteger)rowIndex column:(NSInteger)columnIndex 
{
    ItemDefinition *prop = [gridController.gridEntities objectAtIndex:columnIndex];
    return prop.width;
}
//
// Where the data is actually loaded
//
- (AxGridViewCell *)gridView:(AxGridView *)gv viewForRow:(NSInteger)rowIndex column:(NSInteger)columnIndex 
{
    
	GridHeaderCell *cell = (GridHeaderCell *)[gv dequeueReusableCellWithIdentifier:@"cellHeader"];
    
	if (!cell) 
    {
		cell = [[GridHeaderCell alloc] initWithReuseIdentifier:@"cellHeader"];
	}
    cell.column = columnIndex;
    cell.gridHeaderController = self;
    return cell;
}
-(void) adjustColumnWidth:(int)column :(int)newWidth
{
    if(column <0 || column >= [gridController.gridEntities count])
        return;
    ItemDefinition *obj = [gridController.gridEntities objectAtIndex:column];
    obj.width = newWidth;
}

#pragma mark -
#pragma mark DTGridViewDelegate methods
- (void) filterDone
{
    selectView = nil;
}
//
// Short touch in the header cell -- display the selector there
//
- (void)gridView:(AxGridView *)gv selectionMadeAtRow:(NSInteger)rowIndex column:(NSInteger)columnIndex 
{
    if([gridController cancelFilterMode])
        return;
    if(selectView!=nil)
    {
        selectView = nil;
        return;
    }
    ItemDefinition *def = [gridController.gridEntities objectAtIndex:columnIndex];

    if(def.type==ftAuto || def.type==ftImg)
        return;
    if(def.filterOptions==nil || def.filterOptions.sortOption==kFilterDontFilter)
        return;
    activeCell = [gridController.gridEntities objectAtIndex:columnIndex];
    activeColumn = columnIndex;
    
    // Calculate offset from beginning
    int width = 0;
    int x = 0;
    for(int i=0;i<=columnIndex;i++)
    {
        x += width;
        def = [gridController.gridEntities objectAtIndex:i];
        width = def.width;
    }
    selectView = [[GridSelection alloc]initWithFrame:CGRectMake(x+width/2, 8 /*rowHeight-8*/, 0, 0)];

    [selectView setBackgroundColor:[UIColor whiteColor]];
    
    [gv addSubview:selectView];
    [gv bringSubviewToFront:selectView];
    
    selectView.gridController = gridController;
    selectView.columnIndex = columnIndex;

    [selectView showGridMenuInRect:selectView.frame inView:gv withColumnIndex:columnIndex withDefinition:gridController.gridEntities];

}
//
// Long touch: select the current header cell and show the separator
//
- (void)gridView:(AxGridView *)gv selectionLongMadeInCell:(AxGridViewCell *)cell
{
    int columnIndex = cell.xPosition;

    if(resizeView!=nil)
    {
        [resizeView removeFromSuperview];
        resizeView = nil;
    }
    activeCell = [gridController.gridEntities objectAtIndex:columnIndex];
    activeColumn = columnIndex;

    gv.CanCancelContentTouches = NO;
    
    // Calculate offset from beginning
    int width = 0;
    for(int i=0;i<=columnIndex;i++)
    {
        ItemDefinition *def = [gridController.gridEntities objectAtIndex:i];
        width += def.width;
    }
    int max = [self numberOfColumnsInGridView:gv forRowWithIndex:0];
    // Create another view on the top of the grid to move the selector

    if(columnIndex == max-1)
    {
        resizeView = [[GridResizer alloc]initWithFrame:CGRectMake(width -80, 0, 50, rowHeight)];
    }
    else
    {
        resizeView = [[GridResizer alloc]initWithFrame:CGRectMake(width -35, 0, 50, rowHeight)];
    }
    [gv addSubview:resizeView];
    [gv bringSubviewToFront:resizeView];
    
    resizeView.offset = CGPointMake(width,0);
    
    resizeView.controller = self;
 
}
-(void)resizerDone
{
    [gridController adjustColumnWidth:activeColumn :activeCell.width];
    [resizeView removeFromSuperview];
    resizeView = nil;
}
//
// Return YES to cancel the move
-(BOOL)resizerMove:(int)delta
{
    if(activeCell.width + delta < 30)
        return YES;
    int width;
    BOOL res = NO;
    if(activeCell.width + delta < activeCell.maxWidth)
    {
        width = activeCell.width + delta;
    }
    else
    {
        width = activeCell.maxWidth;
        res = YES;
    }
    // Adjust the change of views    
    // [gridController adjustColumnWidth:activeColumn :width];
    activeCell.width = width;
    
    // adjust the header
    AxGridView *headerView = (AxGridView *)[self.view.subviews objectAtIndex:0];
    [headerView layoutData];   

    return res;
}
-(void)playAction:id
{
}

- (void)gridView:(AxGridView *)gridView scrolledToEdge:(AxGridViewEdge)edge {
}

@end
