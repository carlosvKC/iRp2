#import <UIKit/UIKit.h>

@class LayerInfo;
@class LayerList;
// to display information of an available layer to the user
@interface LayerCell : UITableViewCell 
{
    __weak UISwitch* visibleSwitch;
    __weak UIImageView* symbolView;
    __weak UILabel* layerFriendlyName;
    LayerInfo* item;
}

@property (nonatomic, strong) LayerInfo* item;
@property (nonatomic, weak) IBOutlet UISwitch* visibleSwitch;
@property (nonatomic, weak) IBOutlet UILabel* layerFriendlyName;
@property (nonatomic, weak) IBOutlet UIImageView* symbolView;
@property (nonatomic, weak) LayerList *itsDelegate;

-(IBAction)visibleSwitchValueChanged:(id)sender;
@end
