#import <UIKit/UIKit.h>
@class StreetController;

@interface TableSectionInfo : NSObject
{
}
@property(nonatomic, retain) NSString *label;
@property int firstEntry, count;
@end

@interface TableListController : UITableViewController
{
    NSMutableArray *tableSections;
}
-(void)prepareIndex;
@property(nonatomic, strong) NSMutableArray *dataList;
@property(nonatomic, weak) UIViewController *streetController;
@property BOOL useIndex;
@property(nonatomic, weak) NSMutableArray *filter;
@end
