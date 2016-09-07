
#import <UIKit/UIKit.h>

@interface SyncCustomCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *syncEntityLbl;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *syncActivityIndicator;

@property (weak, nonatomic) IBOutlet UILabel *syncStatusLbl;

@property (weak, nonatomic) IBOutlet UIImageView *syncStatusImage;
@end
