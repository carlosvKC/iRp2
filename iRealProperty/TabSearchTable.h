#import <UIKit/UIKit.h>
#import "SearchBase.h"

@class TabSearchController;

@interface TabSearchTable : UITableViewController
{
    SearchBase  *searchBase;
}
@property(nonatomic, weak) TabSearchController *itsController;
-(id)initWithNibNameAndSearch:(NSString *)nibNameOrNil searchBase:(SearchBase *)searchBaseParam;

@end
