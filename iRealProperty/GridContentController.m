
#import "GridContentController.h"


@implementation GridContentController

@synthesize gridController;
@synthesize cellHeight;
@synthesize gridContent;
@synthesize selectedRows;

-(id)init
{
    self = [super init];
    if(self)
    {
        gridContent = nil;
        cellHeight = 30;
        singleSelection = YES;
    }
    return self;
}

-(id)initWithRowHeight: (int) height
{
    self = [super init];
    if(self)
    {
        cellHeight = height;
        singleSelection = YES;
    }
    return self;
}
- (void)dealloc 
{
    gridContent = nil;
}
- (void)viewDidLoad 
{
    [super viewDidLoad];
	
	self.gridView.delegate = self;
	self.gridView.dataSource = self;
	self.gridView.bounces = NO;
}
- (void)viewDidUnload
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
    [gridController contentDidScroll:scrollView];
}

- (NSInteger)numberOfRowsInGridView:(AxGridView *)gridView 
{
    if(![gridController.delegate getDataFromDelegate:gridController])
        return [gridContent count];
    else
        return [gridController.delegate numberOfRows:gridController];
}
- (NSInteger)numberOfColumnsInGridView:(AxGridView *)gridView forRowWithIndex:(NSInteger)index 
{
    int count = [gridController.gridEntities count];
	return count;    
}
- (CGFloat)gridView:(AxGridView *)gridView heightForRow:(NSInteger)rowIndex 
{
	return cellHeight;
}
- (CGFloat)gridView:(AxGridView *)gridView widthForCellAtRow:(NSInteger)rowIndex column:(NSInteger)columnIndex 
{
    ItemDefinition *prop = [gridController.gridEntities objectAtIndex:columnIndex];
    return prop.width;
}

- (AxGridViewCell *)gridView:(AxGridView *)gv viewForRow:(NSInteger)rowIndex column:(NSInteger)columnIndex 
{
    ItemDefinition *def;
	NSString *identifier = @"Cell-Content";
                            
	GridContentCell *cell = (GridContentCell *)[gv dequeueReusableCellWithIdentifier:identifier];

    
    
	if (!cell) 
    {
		cell = [[GridContentCell alloc] initWithReuseIdentifier:identifier];
	}
    cell.row = rowIndex;
    cell.column = columnIndex;
    cell.gridContentController = self;
    
    if(columnIndex==0 && [gridController isGridAutoCount])
        cell.label = [NSString stringWithFormat:@"%d", rowIndex+1];
    else
    {
        if(![gridController.delegate getDataFromDelegate:gridController])
        {
            // Expect the data to be in the attached gridContent
            NSManagedObject *row;
            if([gridContent count]>0)
                row = [gridContent objectAtIndex:rowIndex];
             def = [gridController.gridEntities objectAtIndex:columnIndex];
             cell.label = [def getStringValue:row];
        }
        else
        {
            // Else go fetch the data from the delegate
            cell.label = [gridController.delegate getCellData:gridController rowIndex:rowIndex columnIndex:columnIndex];
        }
    }
    return cell;
}
#pragma mark -
#pragma mark DTGridViewDelegate methods

- (void)gridView:(AxGridView *)gv selectionMadeAtRow:(NSInteger)rowIndex column:(NSInteger)columnIndex 
{
    // Check if the list of objects exist first
    if(selectedRows == nil)
        selectedRows = [[NSMutableArray alloc]init];

    // Search if the row is already selected
    NSNumber *rowNumber = [[NSNumber alloc]initWithInt:rowIndex];
    
    if([selectedRows containsObject:rowNumber])
    {
        [selectedRows removeObject:rowNumber];
    }
    else
    {
        if(singleSelection)
        {
            [selectedRows removeAllObjects];
            [selectedRows addObject:rowNumber];
        }
        else
        {
            [selectedRows addObject:rowNumber];
        }  
    }
    // Refresh the grid
    [gridView layoutData];
    // Redirect the click
    [gridController selectedRows:selectedRows rowIndex:rowIndex];
}
-(void) setSingleSelection: (BOOL) singleOnly
{
    if(singleOnly==singleSelection)
        return;
    singleSelection = singleOnly;
}
//
-(void)deselectAllRows
{
    selectedRows = nil;
}
-(void)selectAllRows
{
    selectedRows = [[NSMutableArray alloc]init];
    int max = [self numberOfRowsInGridView:self.gridView];
    for(int i=0;i<max;i++)
    {
        NSNumber *rowNumber = [[NSNumber alloc]initWithInt:i];
        [selectedRows addObject:rowNumber];
    }
}
-(void)selectRows:(NSArray *)rows
{
    selectedRows = [[NSMutableArray alloc]initWithArray:rows];   
}
//
// Return YES if a row is selected
-(BOOL) isRowSelected:(int)rowIndex
{
    for(NSNumber *number in selectedRows)
    {
        if([number intValue]==rowIndex)
            return YES;
    }
    return NO;
}
- (void)gridView:(AxGridView *)gridView scrolledToEdge:(AxGridViewEdge)edge 
{
}

@end
