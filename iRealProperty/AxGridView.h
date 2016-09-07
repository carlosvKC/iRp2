#import <UIKit/UIKit.h>
#import "AxGridViewCell.h"

typedef enum 
{
	DTGridViewScrollPositionNone = 0,
	DTGridViewScrollPositionTopLeft,
	DTGridViewScrollPositionTopCenter,
	DTGridViewScrollPositionTopRight,
	DTGridViewScrollPositionMiddleLeft,
	DTGridViewScrollPositionMiddleCenter,
	DTGridViewScrollPositionMiddleRight,
	DTGridViewScrollPositionBottomLeft,
	DTGridViewScrollPositionBottomCenter,
	DTGridViewScrollPositionBottomRight
} AxGridViewScrollPosition;


typedef enum 
{
	DTGridViewEdgeTop,
	DTGridViewEdgeBottom,
	DTGridViewEdgeLeft,
	DTGridViewEdgeRight
} AxGridViewEdge;

struct AxOutset 
{
	CGFloat top;
	CGFloat bottom;
	CGFloat left;
	CGFloat right;
};

@class AxGridView;

@protocol AxGridViewDelegate <UIScrollViewDelegate>

@optional
/*!
 Called when the grid view loads.
 */
- (void)gridViewDidLoad:(AxGridView *)gridView;
- (void)gridView:(AxGridView *)gridView selectionMadeAtRow:(NSInteger)rowIndex column:(NSInteger)columnIndex;
- (void)gridView:(AxGridView *)gridView selectionLongMadeInCell:(AxGridViewCell *)cell;

- (void)gridViewCellTouchesBegan:(AxGridViewCell *)cell : (UIEvent *)event;
- (void)gridViewCellTouchesCancelled:(AxGridViewCell *)cell : (UIEvent *)event;
- (void)gridViewCellTouchesEnded:(AxGridViewCell *)cell : (UIEvent *)event;

- (void)gridView:(AxGridView *)gridView scrolledToEdge:(AxGridViewEdge)edge;
- (void)pagedGridView:(AxGridView *)gridView didScrollToRow:(NSInteger)rowIndex column:(NSInteger)columnIndex;
- (void)gridView:(AxGridView *)gridView didProgrammaticallyScrollToRow:(NSInteger)rowIndex column:(NSInteger)columnIndex;


NSInteger intSort(id info1, id info2, void *context);
@end

#pragma mark -

@protocol AxGridViewDataSource
- (NSInteger)numberOfRowsInGridView:(AxGridView *)gridView;
- (NSInteger)numberOfColumnsInGridView:(AxGridView *)gridView forRowWithIndex:(NSInteger)index;
- (CGFloat)gridView:(AxGridView *)gridView heightForRow:(NSInteger)rowIndex;
- (CGFloat)gridView:(AxGridView *)gridView widthForCellAtRow:(NSInteger)rowIndex column:(NSInteger)columnIndex;
- (AxGridViewCell *)gridView:(AxGridView *)gridView viewForRow:(NSInteger)rowIndex column:(NSInteger)columnIndex;

@optional
- (NSInteger)spacingBetweenRowsInGridView:(AxGridView *)gridView;
- (NSInteger)spacingBetweenColumnsInGridView:(AxGridView *)gridView;

@end

#pragma mark -
@interface AxGridView : UIScrollView <UIScrollViewDelegate, AxGridViewCellDelegate> 
{
	
	__weak NSObject<AxGridViewDataSource> *dataSource;
	
	CGPoint cellOffset;
	
	UIEdgeInsets outset;
	
	NSMutableArray *gridCells;
	
	NSMutableArray *freeCells;
	NSMutableArray *cellInfoForCellsOnScreen;
	
	NSMutableArray *gridRows;
	NSMutableArray *rowHeights;
	NSMutableArray *rowPositions;
	
	NSMutableArray *cellsOnScreen;
	
	CGPoint oldContentOffset;
	BOOL hasResized;
	
	BOOL hasLoadedData;
		
	NSInteger numberOfRows;
	
	NSUInteger rowIndexOfSelectedCell;
	NSUInteger columnIndexOfSelectedCell;
	
	NSTimer *decelerationTimer;
	NSTimer *draggingTimer;
    
    UIEvent *eventBegan;
}
@property (nonatomic, weak) IBOutlet NSObject<AxGridViewDataSource> *dataSource;
@property (nonatomic, weak) IBOutlet id<AxGridViewDelegate> delegate;
@property (nonatomic, weak) IBOutlet id<AxGridViewDelegate> gridDelegate;
@property (nonatomic) CGPoint cellOffset;
@property (nonatomic) UIEdgeInsets outset;
@property (nonatomic, strong) NSMutableArray *gridCells;
@property (nonatomic) NSInteger numberOfRows;

#pragma mark -
#pragma mark Subclass methods

// These methods can be overridden by subclasses. 
// They should never need to be called from outside classes.

- (void)didEndMoving;
- (void)didEndDragging;
- (void)didEndDecelerating;

- (CGFloat)findWidthForRow:(NSInteger)row column:(NSInteger)column;
- (NSInteger)findNumberOfRows;
- (NSInteger)findNumberOfColumnsForRow:(NSInteger)row;
- (CGFloat)findHeightForRow:(NSInteger)row;
- (AxGridViewCell *)findViewForRow:(NSInteger)row column:(NSInteger)column;

#pragma mark -
#pragma mark Regular methods
- (AxGridViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier;
- (AxGridViewCell *)cellForRow:(NSUInteger)rowIndex column:(NSUInteger)columnIndex;
- (AxGridViewCell *) getGridViewCell:(NSUInteger)row column:(NSUInteger)col;

- (void)scrollViewToRow:(NSUInteger)rowIndex column:(NSUInteger)columnIndex scrollPosition:(AxGridViewScrollPosition)position animated:(BOOL)animated;

- (void)selectRow:(NSUInteger)rowIndex column:(NSUInteger)columnIndex scrollPosition:(AxGridViewScrollPosition)position animated:(BOOL)animated;
- (void)refreshAllCells;
- (void)didLoad;
- (void)reloadData;
- (void)layoutData;
@end
