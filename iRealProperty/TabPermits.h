#import <UIKit/UIKit.h>
#import "TabBase.h"
#import "TabPermitsGrid.h"
#import "TabPermitsDetail.h"

@class TabHistoryController;

@interface TabPermits : TabBase

@property(nonatomic, weak) TabHistoryController *itsController;
@end
