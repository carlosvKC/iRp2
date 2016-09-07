
#import <UIKit/UIKit.h>
#import "StreetDataModel.h"
#import "AxDelegates.h"

@class TableListController;

@interface StreetController : UIViewController<UISearchBarDelegate>
{
    UIPopoverController *popoverController;
    TableListController *streetListController;
    TableListController *typeListController;
    TableListController *suffixListController;
    TableListController *prefixListController;
    StreetDataModel *dataModel;

    NSString    *streetName;
    NSString    *streetType;
    NSString    *dirSuffix;
    NSString    *dirPrefix;
    
    // Filter on the type, prefix and suffix
    NSMutableArray     *filterType;
    NSMutableArray     *filterSuffix;
    NSMutableArray     *filterPrefix;
    
}
@property(nonatomic, weak) IBOutlet UILabel *streetNameLabel;
@property(nonatomic, weak) IBOutlet UISearchBar *searchBar;
@property(nonatomic, weak) IBOutlet UIButton *btnStreetSelect;

@property(nonatomic, weak) id<ComboBoxPopOverDelegate> delegate;


- (id)initWithdViewAndRect:(UIView *)cmbView destRect:(CGRect)rect;
-(IBAction)selectStreetAction:(id)sender;
-(void)setTableSelection:(UITableView *)tableView string:(NSString *)string;
-(void)adjustHeight:(int)newHeight;
@end
