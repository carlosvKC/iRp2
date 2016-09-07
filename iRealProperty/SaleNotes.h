#import <UIKit/UIKit.h>
#import "SingleGrid.h"

@class DialogBoxNote;

@interface SaleNotes : SingleGrid
{
    DialogBoxNote *dialog;
}

@property(nonatomic, retain)Sale *defaultSale;
// Load the new sale information into the grid
-(void)loadNotesForSale:(Sale *)newSale;
-(void)addNewContent:(NSManagedObject *)baseEntity;
-(void)contentHasChanged;
@end
