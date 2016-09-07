#import <UIKit/UIKit.h>
#import "SingleGrid.h"
#import "AxDelegates.h"

@class RealPropInfo;
@class ControlBar;
@class TabMapController;
@class SearchDefinition;
enum  
{
    kBtnParcelGridDetail = 10,
    kBtnParcelGridMap = 11
};

@interface ParcelList : SingleGrid<MenuBarDelegate>
{
    ControlBar      *_menuBar;
    NSArray         *_parcels;   // List of selected parcels
}
@property(nonatomic, weak) TabMapController *mapController;
@property(nonatomic, strong) NSArray *parcels;
@end
