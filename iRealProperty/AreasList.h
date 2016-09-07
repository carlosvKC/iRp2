#import <UIKit/UIKit.h>

@protocol ChangeAreaDelegate <NSObject>
-(void)changeAreaDelegate:(int)indexPath;

@end

@interface AreasList : UITableViewController
{
    NSArray *_rows;
}
@property(nonatomic, strong) NSArray *rows;
@property(nonatomic) int selectedRow;
@property(nonatomic, weak) id<ChangeAreaDelegate>changeDelegate;
@property (weak, nonatomic) IBOutlet UILabel *errorMessage;
@end


