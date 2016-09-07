
#import <UIKit/UIKit.h>
#import "GridContentController.h"
#import "GridHeaderController.h"
#import "AxGridView.h"
#import "GridSelection.h"
#import "GridControlBar.h"
#import "GridSelection.h"
#import "GridFilter.h"
#import "GridInfoDesign.h"
#import "AxDelegates.h"

@class GridContentController;
@class GridHeaderController;
@class GridDefinition;

@interface GridController : UIViewController<ModalViewControllerDelegate> 
{
    int     gridViewTagId;
    BOOL    autoCount;
    // internal variables.
    int     contentCellHeight;
    int     filteredColumnIndex;
    enum GridControlBarConstant savedBarMode, currentBarMode;
}
@property(nonatomic, strong) GridHeaderController *gridHeaderController;
@property(nonatomic, strong) GridContentController *gridContentController;
@property(nonatomic, strong) NSArray *gridEntities;
@property(nonatomic, strong) GridInfoDesign *gridDesign;
@property(nonatomic, strong) GridControlBar *gridControlBar;
@property(nonatomic, weak) id<GridDelegate> delegate;
@property BOOL isEditMode;
@property(nonatomic, strong) GridDefinition *gridDefinition;
@property(nonatomic) BOOL cancelFilterMode;
@property(nonatomic) BOOL showFilterOption;

- (id)initWithHeaderAndTag:(NSArray *)headerDefinition :(int)viewTagId;
-(id) initWithGridDefinition:(GridDefinition *)gridDef;
- (void)contentDidScroll: (UIScrollView *)scrollView;
- (void)headerDidScroll: (UIScrollView *)scrollView;
- (void) adjustColumnWidth:(int)column :(int)newWidth;

-(void)initHeaderCellDesign;
-(void)adjustColumnToWidth:(CGFloat)tableWidth;
-(void)autoFitToView;
-(void)autoFitToView:(CGFloat)width;
-(void)calculateCellWidth;

//-(void) setNumberColumn:(BOOL)value;
- (id)initWithParams:(NSArray *)headerDefinition viewTagId:(int)viewTagId height:(int)height numberCol: (BOOL) numberCol;
- (void)reinitWithParams: (NSArray *)headerDefinition viewTagId:(int)viewTagId height:(int)height numberCol: (BOOL) numberCol;

-(BOOL) isGridAutoCount;
-(void) setSingleSelection: (BOOL) singleOnly;

-(void) selectedRows: (NSArray *)rows rowIndex:(int)rowIndex;   // Called when rows are selected or deselected
// Setup content when using a NSArray or NSArray
-(void) setGridContent: (NSArray *)rows;

// Retrieve the content
-(NSArray *) getGridContent;
// Force a complete refresh of the content
-(void) refreshAllContent;

// Update the content frame
-(void)updateContentFrame:(CGRect)rect;
// Enter edit mode
-(void)enterEditMode;
-(void)cancelEditMode;

// toggle the control bar
-(void)switchControlBar:(enum GridControlBarConstant)bar;

// Return the selected rows
-(NSArray *)getSelectedRows;

// Deselect all rows
-(void) deselectAllRows;
// Select all rows
-(void) selectAllRows;

// Remove filters and sorting
-(void) clearFilters;
-(void) clearSortings;

-(void) headerMenuSelection: (enum gridSelectionConstant)menuChoice :(int)columnIndex;
-(void) selectRows:(NSArray *)rows;
// Resize the grid to a new view dimension
-(void)resizeToView:(UIView *)view headerHeight:(CGFloat)headerHeight;
@end
