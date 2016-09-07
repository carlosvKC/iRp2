#import "SyncEntityCell.h"

@implementation SyncEntityCell
@synthesize syncStatusPicture;
@synthesize entityLbl;
@synthesize syncActivityIndicator;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) 
    {
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
