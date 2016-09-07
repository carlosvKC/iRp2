
#import <Foundation/Foundation.h>
#import "AxGridViewController.h"

#import "ItemDefinition.h"
#import "GridHeaderCell.h"
#import "GridController.h"
#import "GridInfoDesign.h"
#import "GridResizer.h"
#import "GridSelection.h"

@class GridController;

@interface GridHeaderController : AxGridViewController
{
    __weak GridController           *gridController;
    int                      rowHeight;
    // internal vars
    GridResizer              *resizeView;
    GridSelection            *selectView;
    ItemDefinition           *activeCell; 
    int                      activeColumn;
}
- (void)initBaseInfo;
- (BOOL)resizerMove: (int)delta;
- (void)resizerDone;
- (void)filterDone;

@property int rowHeight;
@property(nonatomic, weak) GridController *gridController;
@end


