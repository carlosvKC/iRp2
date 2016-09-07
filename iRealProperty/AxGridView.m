#import "AxGridView.h"
#import "AxGridViewCellInfoProtocol.h"

NSInteger const AXGridViewInvalid = -1;


@interface AxGridViewCellInfo : NSObject <AxGridViewCellInfoProtocol> {
	NSUInteger xPosition, yPosition;
	CGRect frame;
	CGFloat x, y, width, height;
}
@property (nonatomic, assign) CGFloat x, y, width, height;
@end

@implementation AxGridViewCellInfo
@synthesize xPosition, yPosition, x, y, width, height, frame;
- (NSString *)description {
	return [NSString stringWithFormat:@"AxGridViewCellInfo: frame=(%i %i; %i %i) x=%i, y=%i", (NSInteger)self.frame.origin.x, (NSInteger)self.frame.origin.y, (NSInteger)self.frame.size.width, (NSInteger)self.frame.size.height, self.xPosition, self.yPosition];
}
@end

@interface AxGridView ()
- (void)dctInternal_setupInternals;
- (void)loadData;
- (void)checkViews;
- (void)initialiseViews;
- (void)fireEdgeScroll;
- (void)checkNewRowStartingWithCellInfo:(NSObject<AxGridViewCellInfoProtocol> *)info goingUp:(BOOL)goingUp;
- (NSObject<AxGridViewCellInfoProtocol> *)cellInfoForRow:(NSUInteger)row column:(NSUInteger)col;
- (void)checkRow:(NSInteger)row column:(NSInteger)col goingLeft:(BOOL)goingLeft;


- (void)decelerationTimer:(NSTimer *)timer;
- (void)draggingTimer:(NSTimer *)timer;

@property (nonatomic, retain) NSTimer *decelerationTimer, *draggingTimer;
@end

@implementation AxGridView

@dynamic delegate;
@synthesize dataSource;
@synthesize gridCells, numberOfRows, cellOffset, outset;
@synthesize decelerationTimer, draggingTimer;

- (void)dealloc 
{
	super.delegate = nil;
	self.dataSource = nil;
	cellsOnScreen = nil;
	gridRows = nil;
	rowPositions = nil;
	rowHeights = nil;
	 freeCells = nil;
	cellInfoForCellsOnScreen = nil;

}

- (void)setGridDelegate:(id <AxGridViewDelegate>)aDelegate 
{
	self.delegate = aDelegate;
}
- (id <AxGridViewDelegate>)gridDelegate {
	return self.delegate;
}

NSInteger intSort(id info1, id info2, void *context) 
{
	
	AxGridViewCellInfo *i1 = (AxGridViewCellInfo *)info1;
	AxGridViewCellInfo *i2 = (AxGridViewCellInfo *)info2;

    if (i1.yPosition < i2.yPosition)
        return NSOrderedAscending;
    else if (i1.yPosition > i2.yPosition)
        return NSOrderedDescending;
    else if (i1.xPosition < i2.xPosition)
		return NSOrderedAscending;
	else if (i1.xPosition > i2.xPosition)
        return NSOrderedDescending;
	else
		return NSOrderedSame;
}


- (id)initWithFrame:(CGRect)frame {
	
	if (!(self = [super initWithFrame:frame])) return nil;

	[self dctInternal_setupInternals];
    
    if(self)
    {
        self.backgroundColor = [[UIColor alloc]initWithRed:0.1 green:0.2 blue:0.3 alpha:0.4];
    }
	return self;
	
}

- (void)awakeFromNib {
	[self dctInternal_setupInternals];
}

- (void)dctInternal_setupInternals 
{
    if(gridRows!=nil)
        return;
	numberOfRows = AXGridViewInvalid;
	columnIndexOfSelectedCell = AXGridViewInvalid;
	rowIndexOfSelectedCell = AXGridViewInvalid;
	
	gridRows = [[NSMutableArray alloc] init];
	rowPositions = [[NSMutableArray alloc] init];
	rowHeights = [[NSMutableArray alloc] init];
	cellsOnScreen = [[NSMutableArray alloc] init];
	
	freeCells = [[NSMutableArray alloc] init];
	
	cellInfoForCellsOnScreen = [[NSMutableArray alloc] init];

}

- (void)setFrame:(CGRect)aFrame 
{
	
	CGSize oldSize = self.frame.size;
	CGSize newSize = aFrame.size;
	
	if (oldSize.height != newSize.height || oldSize.width != newSize.width) {
		hasResized = YES;
	}
	
	[super setFrame:aFrame];
	
	if (hasResized)  {
        // NSLog(@"setFrame old=%f new=%f",oldSize.width,newSize.width);
		[self setNeedsLayout];
	}
}

- (void)reloadData {
	[self loadData];
	[self setNeedsDisplay];
	[self setNeedsLayout];
}

- (void)drawRect:(CGRect)rect 
{
	
	oldContentOffset = 	CGPointMake(0.0f, 0.0f);
		
	//hasLoadedData = NO;
	
	if (!hasLoadedData)
        [self loadData];
	/* Removed this code on Dec 25 to fix the refresh issue
	for (UIView *v in self.subviews)
        if ([v isKindOfClass:[AxGridViewCell class]])
             [v removeFromSuperview];
	*/
	[self initialiseViews];
	
	[self didLoad];
}

- (void)didLoad 
{
	if ([self.delegate respondsToSelector:@selector(gridViewDidLoad:)])
		[self.delegate gridViewDidLoad:self];
}

- (void)didEndDragging {}
- (void)didEndDecelerating {}
- (void)didEndMoving {}

- (void)layoutSubviews {
	[super layoutSubviews];
	[self checkViews];
	[self fireEdgeScroll];
	
	if (!self.draggingTimer && !self.decelerationTimer && self.dragging)
		self.draggingTimer = [NSTimer scheduledTimerWithTimeInterval:0.0 target:self selector:@selector(draggingTimer:) userInfo:nil repeats:NO];		
	
	if (!self.decelerationTimer && self.decelerating) {
		self.decelerationTimer = [NSTimer scheduledTimerWithTimeInterval:0.0 target:self selector:@selector(decelerationTimer:) userInfo:nil repeats:NO];
		[self.draggingTimer invalidate];
		self.draggingTimer = nil;
	}
}

- (void)decelerationTimer:(NSTimer *)timer {
	self.decelerationTimer = nil;
	[self didEndDecelerating];
	[self didEndMoving];
}

- (void)draggingTimer:(NSTimer *)timer {
	self.draggingTimer = nil;
	[self didEndDragging];
	[self didEndMoving];
}

#pragma mark Adding and Removing Cells

- (void)addCellWithInfo:(NSObject<AxGridViewCellInfoProtocol> *)info {
	
	if (![info isMemberOfClass:[AxGridViewCellInfo class]]) return;
	
	[cellInfoForCellsOnScreen addObject:info];
	
	[cellInfoForCellsOnScreen sortUsingFunction:intSort context:NULL];
	
	AxGridViewCell *cell = [self findViewForRow:info.yPosition column:info.xPosition];
	[cell setNeedsDisplay];
	cell.xPosition = info.xPosition;
	cell.yPosition = info.yPosition;
	cell.delegate = self;
	cell.frame = info.frame;
	
	if (cell.xPosition == columnIndexOfSelectedCell && cell.yPosition == rowIndexOfSelectedCell)
		cell.selected = YES;
	else
		cell.selected = NO;
	
	[[gridCells objectAtIndex:info.yPosition] replaceObjectAtIndex:info.xPosition withObject:cell];
	
	[self insertSubview:cell atIndex:0];
	
	// remove any existing view at this frame	
	for (UIView *v in self.subviews) {
		if ([v isKindOfClass:[AxGridViewCell class]] &&
			v.frame.origin.x == cell.frame.origin.x &&
			v.frame.origin.y == cell.frame.origin.y &&
			v != cell) {
			
			[v removeFromSuperview];
			break;
		}
	}
	
	cell = nil;

}

- (void)removeCellWithInfo:(AxGridViewCellInfo *)info {
	
		
	if (info.yPosition > [gridCells count]) return;
	
	NSMutableArray *row = [gridCells objectAtIndex:info.yPosition];
	
	if (info.xPosition > [row count]) return;
	
	AxGridViewCell *cell = [row objectAtIndex:info.xPosition];
	
	if (![cell isKindOfClass:[AxGridViewCell class]]) return;
	
	[cell removeFromSuperview];
	
	[row replaceObjectAtIndex:info.xPosition withObject:info];
	
	[cellInfoForCellsOnScreen removeObject:info];
	
	// TODO: Should this be set?
	//cell.frame = CGRectZero;
	
	[freeCells addObject:cell];
		
}

- (CGRect)visibleRect {
    CGRect visibleRect;
    visibleRect.origin = self.contentOffset;
    visibleRect.size = self.bounds.size;
	return visibleRect;
}

- (BOOL)rowOfCellInfoShouldBeOnShow:(NSObject<AxGridViewCellInfoProtocol> *)info {
	
	CGRect visibleRect = [self visibleRect];
	
	CGRect infoFrame = info.frame;
    
    CGFloat infoBottom = infoFrame.origin.y + infoFrame.size.height;
    CGFloat infoTop = infoFrame.origin.y;
    
    CGFloat visibleBottom = visibleRect.origin.y + visibleRect.size.height;
    CGFloat visibleTop = visibleRect.origin.y;
    
    return (infoBottom >= visibleTop && infoTop <= visibleBottom); // works from left to right
}

- (BOOL)cellInfoShouldBeOnShow:(NSObject<AxGridViewCellInfoProtocol> *)info {
	
	if (!info || ![info isMemberOfClass:[AxGridViewCellInfo class]]) return NO;
	
    CGRect visibleRect = [self visibleRect];
    
    CGFloat infoRight = info.frame.origin.x + info.frame.size.width;
    CGFloat infoLeft = info.frame.origin.x;
    
	CGFloat visibleRight = visibleRect.origin.x + visibleRect.size.width;
    CGFloat visibleLeft = visibleRect.origin.x;
    
    if (infoRight >= visibleLeft && infoLeft <=  visibleRight && [self rowOfCellInfoShouldBeOnShow:info]) 
        return YES;
	
	//NSLog(@"%@ NO: %@", NSStringFromSelector(_cmd), NSStringFromCGRect(info.frame));
	
	return NO;
}


#pragma mark -
#pragma mark Finding Information from DataSource

- (CGFloat)findWidthForRow:(NSInteger)row column:(NSInteger)column {
	return [self.dataSource gridView:self widthForCellAtRow:row column:column];
}

- (NSInteger)findNumberOfRows {
	return [self.dataSource numberOfRowsInGridView:self];
}

- (NSInteger)findNumberOfColumnsForRow:(NSInteger)row {
	return [self.dataSource numberOfColumnsInGridView:self forRowWithIndex:row];
}

- (CGFloat)findHeightForRow:(NSInteger)row {
	return [self.dataSource gridView:self heightForRow:row];
}

- (AxGridViewCell *)findViewForRow:(NSInteger)row column:(NSInteger)column {
	return [self.dataSource gridView:self viewForRow:row column:column];
}
#pragma mark -

-(void)recalculateCells
{
    hasLoadedData = YES;
	
	if (![self.dataSource respondsToSelector:@selector(numberOfRowsInGridView:)])
		return;
	
	self.numberOfRows = [self findNumberOfRows];
	
	if (!self.numberOfRows)
		return;
	
	[gridRows removeAllObjects];
	[rowHeights removeAllObjects];
	[rowPositions removeAllObjects];
	
	NSMutableArray *cellInfoArrayRows = [[NSMutableArray alloc] init];
	
	CGFloat maxHeight = 0;
	CGFloat maxWidth = 0;
	
	
	for (NSInteger i = 0; i < self.numberOfRows; i++) {
		
		NSInteger numberOfCols = [self findNumberOfColumnsForRow:i];
		
		NSMutableArray *cellInfoArrayCols = [[NSMutableArray alloc] init];
		
		for (NSInteger j = 0; j < numberOfCols; j++) {
			
			
			AxGridViewCellInfo *info = [[AxGridViewCellInfo alloc] init];
			
			info.xPosition = j;
			info.yPosition = i;
			
			
			CGFloat height = [self findHeightForRow:i];
			CGFloat width = [self findWidthForRow:i column:j];
			
			//info.frame.size.height = [dataSource gridView:self heightForRow:i]; // ???
			//info.frame.size.width = [dataSource gridView:self widthForCellAtRow:i column:j]; // ????
			CGFloat y;
			CGFloat x;
			
			if (i == 0) {
				y = 0.0f;
				//info.frame.origin.y = 0.0;
			} else {
				AxGridViewCellInfo *previousCellRow = [[cellInfoArrayRows objectAtIndex:i-1] objectAtIndex:0];
				y = previousCellRow.frame.origin.y + previousCellRow.frame.size.height;
				
				if (cellOffset.y != 0)
					y += cellOffset.y;
			}
			
			if (j == 0) {
				x = 0.0f;
			} else {
				AxGridViewCellInfo *previousCellRow = [cellInfoArrayCols objectAtIndex:j-1];
				x = previousCellRow.frame.origin.x + previousCellRow.frame.size.width;
				if (cellOffset.x != 0)
					x += cellOffset.x;
			}
			
			if (maxHeight < y + height)
				maxHeight = y + height;
			
			if (maxWidth < x + width)
				maxWidth = x + width;
			
			info.frame = CGRectMake(x,y,width,height);
			
			[cellInfoArrayCols addObject:info];
		}
		
		[cellInfoArrayRows addObject:cellInfoArrayCols];
	}
	self.contentSize = CGSizeMake(maxWidth, maxHeight);
	
	self.gridCells = cellInfoArrayRows;
}
//
// New data has been introduced (i.e. new row, change of column width, etc)
-(void)layoutData
{
    [self recalculateCells];
    // Remove all the subviews
    [cellInfoForCellsOnScreen removeAllObjects];  
    cellInfoForCellsOnScreen = nil;
    cellInfoForCellsOnScreen = [[NSMutableArray alloc] init];
    
    NSArray *subviewsCopy = [self.subviews copy];
    
    for (UIView *cell in subviewsCopy)
    {
        if ([cell isKindOfClass:[AxGridViewCell class]])
        {
            [cell removeFromSuperview];
        }
    }
	[self initialiseViews];
}
// reload the grid data
- (void)loadData
{
    [self recalculateCells];
	if ([self.subviews count] > [self.gridCells count]) {
		// the underlying data must have reduced, time to iterate
		NSSet *gridCellsSet = [NSSet setWithArray:self.gridCells];
		NSArray *subviewsCopy = [self.subviews copy];
		
		for (UIView *cell in subviewsCopy) {
			if ([cell isKindOfClass:[AxGridViewCell class]] &&![gridCellsSet member:cell])
            {
				[cell removeFromSuperview];
            }
		}
	}
}

- (void)checkViews 
{
		
	if ([cellInfoForCellsOnScreen count] == 0) {
		[self initialiseViews];
		return;
	}
	
	NSMutableDictionary *leftRightCells = [[NSMutableDictionary alloc] init];
		
	NSArray *orderedCells = [cellInfoForCellsOnScreen copy];
	
	BOOL isGoingUp = NO;
	BOOL isGoingDown = NO;
	BOOL isGoingLeft = NO;
	BOOL isGoingRight = NO;
	
	if (self.contentOffset.y < oldContentOffset.y && self.contentOffset.y >= 0)
		isGoingUp = YES;
	else if (self.contentOffset.y > oldContentOffset.y && self.contentOffset.y + self.frame.size.height < self.contentSize.height)
		isGoingDown = YES;
	else if (hasResized)
		isGoingUp = YES;
	
	if (self.contentOffset.x < oldContentOffset.x && self.contentOffset.x >= 0)
		isGoingLeft = YES;
	else if (self.contentOffset.x > oldContentOffset.x && self.contentOffset.x + self.frame.size.width < self.contentSize.width)
		isGoingRight = YES;
	else if (hasResized)
		isGoingRight = YES;
    
    //NSLog(@"isGoingUp: %i, isGoingDown: %i, co.y: %f, old.y: %f", isGoingUp, isGoingDown, self.contentOffset.y, oldContentOffset.y);
	
	hasResized = NO;
	oldContentOffset = self.contentOffset;
	
	for (AxGridViewCellInfo *info in orderedCells) {
		
		if (isGoingLeft) {
			if (info.xPosition > 0 && info.frame.origin.x > self.contentOffset.x) {
				if (![leftRightCells objectForKey:[NSString stringWithFormat:@"%i", info.yPosition]])
					[leftRightCells setObject:info forKey:[NSString stringWithFormat:@"%i", info.yPosition]];
				else if ([[leftRightCells objectForKey:[NSString stringWithFormat:@"%i", info.yPosition]] xPosition] > info.xPosition)
					[leftRightCells setObject:info forKey:[NSString stringWithFormat:@"%i", info.yPosition]];
			}
		} else if (isGoingRight) {
			if ([[self.gridCells objectAtIndex:info.yPosition] count] - 1 > info.xPosition && info.frame.origin.x + info.frame.size.width < self.contentOffset.x + self.frame.size.width) {
				if (![leftRightCells objectForKey:[NSString stringWithFormat:@"%i", info.yPosition]])
					[leftRightCells setObject:info forKey:[NSString stringWithFormat:@"%i", info.yPosition]];
				else if ([[leftRightCells objectForKey:[NSString stringWithFormat:@"%i", info.yPosition]] xPosition] < info.xPosition)
					[leftRightCells setObject:info forKey:[NSString stringWithFormat:@"%i", info.yPosition]];
			}
		}
		
		if (![self cellInfoShouldBeOnShow:info])
			[self removeCellWithInfo:info];
		
	}
	
	if (isGoingLeft) {
		for (NSString *yPos in [leftRightCells allKeys]) {			
			AxGridViewCellInfo *info = [leftRightCells objectForKey:yPos];
			[self checkRow:info.yPosition column:info.xPosition goingLeft:YES];
		}
		
	} else if (isGoingRight) {
		for (NSString *yPos in [leftRightCells allKeys]) {
			AxGridViewCellInfo *info = [leftRightCells objectForKey:yPos];
			[self checkRow:info.yPosition column:info.xPosition goingLeft:NO];
		}
	}
		
	if (isGoingUp)
		[self checkNewRowStartingWithCellInfo:[orderedCells objectAtIndex:0] goingUp:YES];
	else if (isGoingDown)
		[self checkNewRowStartingWithCellInfo:[orderedCells lastObject] goingUp:NO];
	
}

- (void)initialiseViews {
	
	for (NSUInteger i = 0; i < [cellInfoForCellsOnScreen count]; i++) 
    {
		AxGridViewCellInfo *info = [cellInfoForCellsOnScreen objectAtIndex:i];
		
		if (![self cellInfoShouldBeOnShow:info])
			[self removeCellWithInfo:info];
		
	}
	
	for (NSUInteger i = 0; i < [gridCells count]; i++) {
		
		NSMutableArray *row = [gridCells objectAtIndex:i];
		
		for (NSUInteger j = 0; j < [row count]; j++) {	
			
			id object = [row objectAtIndex:j];
			
			if ([object isMemberOfClass:[AxGridViewCellInfo class]]) {
				
				AxGridViewCellInfo *info = (AxGridViewCellInfo *)object;
				
				if ([self cellInfoShouldBeOnShow:info])
					[self addCellWithInfo:info];
				
			}
		}
	}
}
- (void)refreshAllCells
{
    for(UIView *view in cellInfoForCellsOnScreen)
    {
        [view setNeedsDisplay];
    }
}
- (void)checkRow:(NSInteger)row column:(NSInteger)col goingLeft:(BOOL)goingLeft {
	
	NSObject<AxGridViewCellInfoProtocol> *info = [self cellInfoForRow:row column:col];
	
	if (!info) return;
	
	if ([self cellInfoShouldBeOnShow:info])
		[self addCellWithInfo:info];
		
	if (goingLeft) {
		if (info.frame.origin.x > self.contentOffset.x)
			[self checkRow:row column:(col - 1) goingLeft:goingLeft];
	} else {
		if (info.frame.origin.x + info.frame.size.width < self.contentOffset.x + self.frame.size.width)
			[self checkRow:row column:(col + 1) goingLeft:goingLeft];
	}
}

- (NSObject<AxGridViewCellInfoProtocol> *)cellInfoForRow:(NSUInteger)row column:(NSUInteger)col {
	
	if ([self.gridCells count] <= row) return nil;
	
	NSArray *rowArray = [self.gridCells objectAtIndex:row];
	
	if ([rowArray count] <= col) return nil;
	
	return (NSObject<AxGridViewCellInfoProtocol> *)[rowArray objectAtIndex:col];
}
- (AxGridViewCell *) getGridViewCell:(NSUInteger)row column:(NSUInteger)col {
	
	if (row < [self findNumberOfRows]) 
    {
        NSArray *rowArray = [self.gridCells objectAtIndex:row];
        
        if (col < [self findNumberOfColumnsForRow:row])
            return [rowArray objectAtIndex:col];
    }
    return nil;
}

- (void)checkNewRowStartingWithCellInfo:(NSObject<AxGridViewCellInfoProtocol> *)info goingUp:(BOOL)goingUp {
	
	if (!info) return;
		
    if (![self rowOfCellInfoShouldBeOnShow:info]) return;
	
	NSObject<AxGridViewCellInfoProtocol> *infoToCheck = info;
	
	NSInteger row = info.yPosition;
	NSInteger total = [[self.gridCells objectAtIndex:row] count];
	NSInteger goingRightPosition = info.xPosition;
	NSInteger goingLeftPosition = info.xPosition;
	BOOL goingLeft = NO;
	
	while (![self cellInfoShouldBeOnShow:infoToCheck]) {
				
		goingLeft = !goingLeft;
				
		if (goingLeft)
			infoToCheck = [self cellInfoForRow:row column:--goingLeftPosition];
		else
			infoToCheck = [self cellInfoForRow:row column:++goingRightPosition];
				
		if (goingRightPosition > total)
			return;
	}
	
	if ([infoToCheck isEqual:info]) {
		[self checkRow:infoToCheck.yPosition column:infoToCheck.xPosition goingLeft:YES];
		[self checkRow:infoToCheck.yPosition column:infoToCheck.xPosition goingLeft:NO];
	} else {
		[self checkRow:infoToCheck.yPosition column:infoToCheck.xPosition goingLeft:goingLeft];
	}

	NSObject<AxGridViewCellInfoProtocol> *nextInfo = nil;
	
	if (goingUp)
		nextInfo = [self cellInfoForRow:info.yPosition - 1 column:info.xPosition];
	else
		nextInfo = [self cellInfoForRow:info.yPosition + 1 column:info.xPosition];
		
	if (nextInfo)
		[self checkNewRowStartingWithCellInfo:nextInfo goingUp:goingUp];
}

#pragma mark Public methods

- (AxGridViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier 
{
    int count = [freeCells count];
    for(int i=0;i<count;i++)
    {
        AxGridViewCell *c = [freeCells objectAtIndex:i];
        if([c.identifier isEqualToString:identifier])
        {
            [freeCells removeObjectAtIndex:i];
            [c prepareForReuse];
            count--;
        }
    }
    
	return nil;
}

- (AxGridViewCell *)cellForRow:(NSUInteger)rowIndex column:(NSUInteger)columnIndex {
	
	for (UIView *v in self.subviews) {
		if ([v isKindOfClass:[AxGridViewCell class]]) {
			AxGridViewCell *c = (AxGridViewCell *)v;
			if (c.xPosition == columnIndex && c.yPosition == rowIndex)
				return c;
		}
	}
	
	return nil;
}

- (void)scrollViewToRow:(NSUInteger)rowIndex column:(NSUInteger)columnIndex scrollPosition:(AxGridViewScrollPosition)position animated:(BOOL)animated {
	
	CGFloat xPos = 0, yPos = 0;
	
	CGRect cellFrame = [[[self.gridCells objectAtIndex:rowIndex] objectAtIndex:columnIndex] frame];		
	
	// working out x co-ord
	
	if (position == DTGridViewScrollPositionTopLeft || position == DTGridViewScrollPositionMiddleLeft || position == DTGridViewScrollPositionBottomLeft)
		xPos = cellFrame.origin.x;
	
	else if (position == DTGridViewScrollPositionTopRight || position == DTGridViewScrollPositionMiddleRight || position == DTGridViewScrollPositionBottomRight)
		xPos = cellFrame.origin.x + cellFrame.size.width - self.frame.size.width;
	
	else if (position == DTGridViewScrollPositionTopCenter || position == DTGridViewScrollPositionMiddleCenter || position == DTGridViewScrollPositionBottomCenter)
		xPos = (cellFrame.origin.x + (cellFrame.size.width / 2)) - (self.frame.size.width / 2);
	
	else if (position == DTGridViewScrollPositionNone) {
		
		BOOL isBig = NO;
		
		if (cellFrame.size.width > self.frame.size.width)
			isBig = YES;
		
		if ((cellFrame.origin.x < self.contentOffset.x)
		&& ((cellFrame.origin.x + cellFrame.size.width) > (self.contentOffset.x + self.frame.size.width)))
			xPos = self.contentOffset.x;
		
		else if (cellFrame.origin.x < self.contentOffset.x)
			if (isBig)
				xPos = (cellFrame.origin.x + cellFrame.size.width) - self.frame.size.width;
			else 
				xPos = cellFrame.origin.x;
		
			else if ((cellFrame.origin.x + cellFrame.size.width) > (self.contentOffset.x + self.frame.size.width))
				if (isBig)
					xPos = cellFrame.origin.x;
				else
					xPos = (cellFrame.origin.x + cellFrame.size.width) - self.frame.size.width;
				else
					xPos = self.contentOffset.x;
	}
	
	// working out y co-ord
	
	if (position == DTGridViewScrollPositionTopLeft || position == DTGridViewScrollPositionTopCenter || position == DTGridViewScrollPositionTopRight) {
		yPos = cellFrame.origin.y;
		
	} else if (position == DTGridViewScrollPositionBottomLeft || position == DTGridViewScrollPositionBottomCenter || position == DTGridViewScrollPositionBottomRight) {
		yPos = cellFrame.origin.y + cellFrame.size.height - self.frame.size.height;
		
	} else if (position == DTGridViewScrollPositionMiddleLeft || position == DTGridViewScrollPositionMiddleCenter || position == DTGridViewScrollPositionMiddleRight) {
		yPos = (cellFrame.origin.y + (cellFrame.size.height / 2)) - (self.frame.size.height / 2);
		
	} else if (position == DTGridViewScrollPositionNone) {
		BOOL isBig = NO;
		
		if (cellFrame.size.height > self.frame.size.height)
			isBig = YES;
		
		if ((cellFrame.origin.y < self.contentOffset.y)
		&& ((cellFrame.origin.y + cellFrame.size.height) > (self.contentOffset.y + self.frame.size.height)))
			yPos = self.contentOffset.y;
		
		else if (cellFrame.origin.y < self.contentOffset.y)
			if (isBig)
				yPos = (cellFrame.origin.y + cellFrame.size.height) - self.frame.size.height;
			else
				yPos = cellFrame.origin.y;
			else if ((cellFrame.origin.y + cellFrame.size.height) > (self.contentOffset.y + self.frame.size.height))
				if (isBig)
					yPos = cellFrame.origin.y;
				else
					yPos = (cellFrame.origin.y + cellFrame.size.height) - self.frame.size.height;
				else
					yPos = self.contentOffset.y;
	}
	
	if (xPos == self.contentOffset.x && yPos == self.contentOffset.y)
		return;
	
	if (xPos > self.contentSize.width - self.frame.size.width)
		xPos = self.contentSize.width - self.frame.size.width;
	else if (xPos < 0)
		xPos = 0.0f;
	
	if (yPos > self.contentSize.height - self.frame.size.height)
		yPos = self.contentSize.height - self.frame.size.height;
	else if (yPos < 0)
		yPos = 0.0f;	
	
	[self scrollRectToVisible:CGRectMake(xPos, yPos, self.frame.size.width, self.frame.size.height) animated:animated];
	
	if (!animated)
		[self checkViews];
	
	if ([self.delegate respondsToSelector:@selector(gridView:didProgrammaticallyScrollToRow:column:)])
		[self.delegate gridView:self didProgrammaticallyScrollToRow:rowIndex column:columnIndex];
		
	
}

- (void)selectRow:(NSUInteger)rowIndex column:(NSUInteger)columnIndex scrollPosition:(AxGridViewScrollPosition)position animated:(BOOL)animated {
	
	for (UIView *v in self.subviews) {
		if ([v isKindOfClass:[AxGridViewCell class]]) {
			AxGridViewCell *c = (AxGridViewCell *)v;
			if (c.xPosition == columnIndex && c.yPosition == rowIndex)
				c.selected = YES;
			else if (c.xPosition == columnIndexOfSelectedCell && c.yPosition == rowIndexOfSelectedCell)
				c.selected = NO;
		}
	}
	rowIndexOfSelectedCell = rowIndex;
	columnIndexOfSelectedCell = columnIndex;
	
	// [self scrollViewToRow:rowIndex column:columnIndex scrollPosition:position animated:animated];
}

- (void)fireEdgeScroll {
	
	if (self.pagingEnabled)
		if ([self.delegate respondsToSelector:@selector(pagedGridView:didScrollToRow:column:)])
			[self.delegate pagedGridView:self didScrollToRow:((NSInteger)(self.contentOffset.y / self.frame.size.height)) column:((NSInteger)(self.contentOffset.x / self.frame.size.width))];
	
	if ([self.delegate respondsToSelector:@selector(gridView:scrolledToEdge:)]) {
		
		if (self.contentOffset.x <= 0)
			[self.delegate gridView:self scrolledToEdge:DTGridViewEdgeLeft];
		
		if (self.contentOffset.x >= self.contentSize.width - self.frame.size.width)
			[self.delegate gridView:self scrolledToEdge:DTGridViewEdgeRight];
		
		if (self.contentOffset.y <= 0)
			[self.delegate gridView:self scrolledToEdge:DTGridViewEdgeTop];
		
		if (self.contentOffset.y >= self.contentSize.height - self.frame.size.height)
			[self.delegate gridView:self scrolledToEdge:DTGridViewEdgeBottom];
	}
}
// Methods to handle the short touch and long touch
- (void)gridViewCellTouchesBegan:(AxGridViewCell *)cell : (UIEvent *)event
{
    eventBegan = event;

}
- (void)gridViewCellTouchesCancelled:(AxGridViewCell *)cell : (UIEvent *)event
{
    eventBegan = nil;
}
- (void)gridViewCellTouchesEnded:(AxGridViewCell *)cell : (UIEvent *)event
{

    
    // Up event
    // Now we can calculate the delta between the 2 events
    NSTimeInterval ti = 0;
    if(eventBegan!=nil)
    {
        if(event!=nil)
            ti = event.timestamp - eventBegan.timestamp;
        else
            ti = [NSDate timeIntervalSinceReferenceDate] - eventBegan.timestamp;
    }
    if(ti < 0.5)
    {
        // Short call
        [self gridViewCellWasTouched:cell];
    }
    else if(ti>0.5)
    {
        // Long call
       [self gridViewCellWasLongTouched:cell];
    }
}

- (void)gridViewCellWasTouched:(AxGridViewCell *)cell 
{
	
	[self bringSubviewToFront:cell];
    
	if ([self.delegate respondsToSelector:@selector(gridView:selectionMadeAtRow:column:)])
		[self.delegate gridView:self selectionMadeAtRow:cell.yPosition column:cell.xPosition];
}
- (void)gridViewCellWasLongTouched:(AxGridViewCell *)cell 
{
	[self bringSubviewToFront:cell];
    
	if ([self.delegate respondsToSelector:@selector(gridView:selectionLongMadeInCell:)])
		[self.delegate gridView:self selectionLongMadeInCell:cell];
}

#pragma mark -
#pragma mark Accessors

- (NSInteger)numberOfRows {
	if (numberOfRows == AXGridViewInvalid) {
		numberOfRows = [self.dataSource numberOfRowsInGridView:self];
	}
	
	return numberOfRows;
}

@end

