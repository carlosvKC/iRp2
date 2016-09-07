#import <UIKit/UIKit.h>
#import "SingleGrid.h"

@interface TabSaleParcels : SingleGrid<GridDelegate>
{
    NSMutableArray  *results;
}
@property(nonatomic, retain)Sale *defaultSale;

// Load the new sale information into the grid
-(void)loadParcelForSale:(Sale *)newSale;

@end

