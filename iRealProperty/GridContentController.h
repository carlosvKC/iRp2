
#import <Foundation/Foundation.h>
#import "AxGridViewController.h"
#import "ItemDefinition.h"
#import "GridContentCell.h"
#import "GridController.h"
#import "AxDelegates.h"

@class GridController;

@interface GridContentController : AxGridViewController 
{
    BOOL singleSelection;
}
@property(nonatomic,strong) GridController *gridController;
@property int cellHeight;
@property(nonatomic, strong) NSArray    *gridContent;    // List of rows
@property(nonatomic, strong) NSMutableArray    *selectedRows;  // list of selected tows

-(id)initWithRowHeight: (int) height;
-(BOOL) isRowSelected: (int)row;
-(void) setSingleSelection: (BOOL) singleOnly;
-(void) deselectAllRows;
-(void) selectAllRows;
-(void) selectRows:(NSArray *)rows;
@end
