#import "LayerCell.h"
#import "LayerInfo.h"
#import "LayerList.h"

@implementation LayerCell

@synthesize item;
@synthesize visibleSwitch;
@synthesize symbolView;
@synthesize layerFriendlyName;
@synthesize itsDelegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)awakeFromNib
{
    [super awakeFromNib];
}

-(IBAction)visibleSwitchValueChanged:(id)sender
{
    return;
    if(itsDelegate!=nil)
        [itsDelegate visibleSwitchValueChanged:sender];
}

@end
