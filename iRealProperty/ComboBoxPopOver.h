
#import <Foundation/Foundation.h>
#import "LUItems2.h"
#import "AxDelegates.h"

@interface ComboBoxPopOver : UITableViewController
{
    int maxItems;
    int popoverWidth;
    int popoverHeight;
    
    enum popover
    {
        POPOVER_WIDTH = 320,
        POPOVER_LINE_HEIGHT = 36
    };
    __weak id<ComboBoxPopOverDelegate> delegate;
}

- (id)initWithArrayAndViewRect:(NSArray *)elementList inView:(UIView *)cmbView   destRect:(CGRect)rect selectedRow:(int)row;
- (id)initWithArrayAndViewRect:(NSArray *)elementList inView:(UIView *)cmbView destRect:(CGRect)rect selectedRow:(int)row withMaxItems:(int)nbItems;
-(void) adjustPopoverWidth;
-(void)selectRow:(int)row;

@property(nonatomic, strong) NSArray *comboItems;
@property(nonatomic, strong) UIPopoverController *popoverController;
@property(nonatomic, weak) id<ComboBoxPopOverDelegate> delegate;

@property(nonatomic) int maxItems, popoverWidth, popoverHeight;
@end
