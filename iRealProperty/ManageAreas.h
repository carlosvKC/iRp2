
#import <UIKit/UIKit.h>
#import "Requester.h"
#import "ATActivityIndicator.h"


@protocol ManageAreaDelegate <NSObject>

-(void)manageAreaSync:(NSArray *)areas withContainers:(NSArray *)containers;

@end

@interface DownloadableArea : NSObject

@property(nonatomic, strong) NSString *name;
@property(nonatomic) double areaSize;
@property(nonatomic) BOOL selected;
@property(nonatomic) BOOL localStorage; // already there
@end

@interface ManageAreas : UIViewController<UITableViewDelegate, UITableViewDataSource, RequesterDelegate, UIAlertViewDelegate>
{
    NSArray *_rows; // rows of DownloadableAreas
    UIButton    *btnSync;
    Requester   *requester;
    ATActivityIndicator *activity;
    NSArray     *azureContainers;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *btnSynchronize;
@property (weak, nonatomic) id<ManageAreaDelegate>delegate;
@property(nonatomic, strong) NSArray *rows;

-(void)getFullListOfContainers ;
@end


