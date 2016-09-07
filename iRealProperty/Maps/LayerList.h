
#import <UIKit/UIKit.h>

@class ArcGisViewController;
@class LayerInfo;



@protocol LayerListDelegate
- (void)showLayer:(LayerInfo*)target;
- (void)hideLayer:(LayerInfo*)target;
- (void)openLayer:(LayerInfo*)target;
- (void)moveLayer:(LayerInfo*)target toIndex: (int)newIndex;
- (void)layerConfiChanged:(LayerInfo*)target;
@end


@interface LayerList : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    UITableView* tvList;
    ArcGisViewController * mapController;
    NSArray* fileList;
}

@property (nonatomic, strong) IBOutlet UITableView* tvList;
@property (nonatomic, strong) ArcGisViewController * mapController;
@property (nonatomic, strong) NSArray* fileList;
-(void)visibleSwitchValueChanged:(id)sender;
-(IBAction) Cancel;
@end
