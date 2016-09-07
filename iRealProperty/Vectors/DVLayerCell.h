
#import <UIKit/UIKit.h>
#import "DVLayerList.h"

@class DVDashView;

@interface DVLayerCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UISwitch *visibleSwitch;
@property (weak, nonatomic) IBOutlet UILabel *layerName;

@property (weak, nonatomic) IBOutlet UIImageView *layerSelected;
@property (weak, nonatomic) IBOutlet DVDashView *lineView;

@end
