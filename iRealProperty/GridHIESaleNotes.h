#import <UIKit/UIKit.h>
#import "SingleGrid.h"

@interface GridHIESaleNotes : SingleGrid

@property(nonatomic, retain)HIExmpt *defaultHIExmpt;

// Load the new sale information into the grid
-(void)loadNotes:(HIExmpt *)newSale;
-(void)addNewContent:(NSManagedObject *)baseEntity;
-(void)contentHasChanged;
@end
