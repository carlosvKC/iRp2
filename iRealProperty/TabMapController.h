
#import <UIKit/UIKit.h>
#import "AxDelegates.h"
#import "ControlBar.h"
#import "MenuTable.h"
#import "Maps/ArcGisViewController.h"
#import "Maps/RenderersPicker.h"
#import "TabSearchGrid.h"
#import "TabBarController.h"

@class TabSearchGrid;

enum
{
    kBtnLayers = 1,     // Display all the layers
    kBtnRenderers =2,      // Display the renderers
    kBtnZoomLevel = 3,      // Display the current zoom level. Drop down to the different levels.
    kBtnDropPin = 4,        // Drop current location on the map -- adjust map to show current position
    kBtnCompass = 5,        // Compass mode
    kBtnMeasure = 6,        // Start the measure mode
    kBtnGoogle = 7,          // Use Google map as the back-end map
    kBtnCenterParcel = 8,
    kBtnSelectParcel = 10,
    kBtnClearParcel = 11
};

@class ArcGisViewController;

@interface TabMapController : UIViewController<MenuBarDelegate, MenuTableDelegate, ArcGisViewControllerDelegate, RenderersPickerDelegate, UIPopoverControllerDelegate, TabSearchGridDelegate, TabBarDelegate>
{
    MenuTable *menu;
    ControlBar *menuBar;
    ArcGisViewController *arcgisMap;
    
    RenderersPicker *_rendererPicker;
    UIPopoverController *_rendererPickerPopover;
    TabSearchGrid  *searchGrid;
    SelectedProperties *selObject;
    NSThread    *pinLoader;
    
    NSTimeInterval  _updateDate;
}
-(void)selectParcel: (id)pin;
-(void)selectMultipleParcel: (NSArray*)pins  selectedParcels:(NSArray *)selectedParcels;
-(void)menuBarBtnBackSelected;
-(void)switchToParcelGrid:(NSArray *)selectedParcels;
-(void)hideSelectedParcels;
-(void)resetLayersConfiguration;
-(void)resetRenderersConfiguration;
-(void)tabBarWillSwitchController;
+(UIView *)tabMapControllerView;

@end
