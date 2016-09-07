#import <UIKit/UIKit.h>
#import "SingleGrid.h"
#import "iRealProperty.h"

@interface SaleWarnings : SingleGrid

@property(nonatomic, retain)Sale *defaultSale;

// Load the new sale information into the grid
-(void)loadWarningForSale:(Sale *)newSale;

@end

