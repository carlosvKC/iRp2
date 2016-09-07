
#import "SyncCustomCell.h"

@implementation SyncCustomCell
@synthesize syncEntityLbl;
@synthesize syncActivityIndicator;
@synthesize syncStatusLbl;
@synthesize syncStatusImage;

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

@end
