
#import <Foundation/Foundation.h>

@interface SyncEntityCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *syncStatusPicture;
@property (weak, nonatomic) IBOutlet UILabel *entityLbl;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *syncActivityIndicator;


@end
