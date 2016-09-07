
#import <UIKit/UIKit.h>
#import "DVLayer.h"
#import "DVLayerCell.h"

@protocol DVLayerListDelegate <NSObject>

-(void)dvLayerListRefresh;
-(void)dvLayerListDefault:(DVLayer *)layer;
@end

@interface DVLayerList : UITableViewController

@property(nonatomic, weak) NSArray *layerList;
@property(nonatomic, weak) id<DVLayerListDelegate> delegate;
@end

@interface DVDashView : UIControl
{
    DVLayer *_dvLayer;
}
@property(nonatomic, strong) DVLayer *dvLayer;
@end