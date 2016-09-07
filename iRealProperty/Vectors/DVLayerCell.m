
#import "DVLayerCell.h"

@implementation DVLayerCell
@synthesize visibleSwitch;
@synthesize layerName;
@synthesize lineView;
@synthesize layerSelected;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) 
    {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}
-(void)awakeFromNib
{
    [super awakeFromNib];
}
-(void)dealloc
{
    self.layerName = nil;
    self.layerSelected = nil;
    self.lineView = nil;
}
@end
