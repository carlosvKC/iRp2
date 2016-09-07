

#import <Foundation/Foundation.h>

enum gridSelectionConstant {
    gridSelectionClear = 0,
    gridSelectionAllClear,
    gridSelectionAsc,
    gridSelectionDesc,
    gridSelectionFilter
    };

@class GridController;

@interface GridSelection : UIView
{
    UIMenuController    *menuController;

}
@property(nonatomic, retain)GridController *gridController;
@property int columnIndex;

-(void)showGridMenuInRect: (CGRect) menuRect inView:(UIView *)inView withColumnIndex:(int)columnIndex withDefinition:(NSArray *)definitions;
@end
