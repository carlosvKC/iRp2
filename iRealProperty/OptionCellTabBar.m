
#import "OptionCellTabBar.h"
#import "DCRoundSwitch.h"

@implementation OptionCellTabBar
@synthesize label;
@synthesize btnToggle;
@synthesize detailLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
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

@end
