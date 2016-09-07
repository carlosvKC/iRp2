#import <UIKit/UIKit.h>
#import <ArcGIS/ArcGIS.h>
#import "UIDragableToolbar.h"

@protocol MapLegendDelegate 

-(void) mapLegendCloseButtonClick;

@end

@interface MapLegend : UIViewController<UITableViewDataSource, UITableViewDelegate, UIDragableToolbarDelegate>
{
    NSMutableArray* _legendItems;
    AGSRenderer* _renderer;
    
    id<MapLegendDelegate> __weak _delegate; 
}
@property (nonatomic, weak) id<MapLegendDelegate> delegate;
@property (strong, nonatomic) AGSRenderer* renderer;
@property (weak, nonatomic) IBOutlet UIDragableToolbar *tobBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *closeButton;
@property (weak, nonatomic) IBOutlet UILabel *legendTitle;
@property (weak, nonatomic) IBOutlet UITableView *tv;

- (id)initWithNibName:(NSString *)nibNameOrNil andRenderer: (AGSRenderer*)layerRenderer;
- (IBAction)onClose:(id)sender;
- (IBAction)onEdit:(id)sender;
- (void) loadLegendItems;

@end
