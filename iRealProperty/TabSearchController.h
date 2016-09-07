#import <UIKit/UIKit.h>
#import "SearchBase.h"
#import "TabSearchTable.h"
#import "TabSearchItems.h"
#import "ControlBar.h"
#import "AxDelegates.h"
#import "SearchDefinition2.h"
#import "ParcelSearch.h"
#import "KeyboardController.h"
#import "TabBarController.h"
#import "TabSearchGrid.h"
#import "GridFilter.h"


@class TabSearchGrid;
@class StreetController;
@class NSFetchedResultsController;

@interface TabSearchController : KeyboardController<MenuBarDelegate, ComboBoxPopOverDelegate, TabBarDelegate, TabSearchGridDelegate>
{
    ControlBar      *menuBar;
    // Current search viewController
    UIViewController *searchController;
    // Parcel search controller
    ParcelSearch    *parcelSearch;
    // Search grid controller
     TabSearchGrid  *searchGrid;
    // Street mode controller
    StreetController *streetController;
    
    SearchDefinition2 *searchDefinition;
    
    NSMutableArray  *memGrid, *memGridIndex;
    int             tableHeight;
}
// Maintain the state from previous searcg
@property(nonatomic, strong) NSArray *saveRows;    // List of selections
@property(nonatomic, strong) NSMutableArray *saveHeader;  // sort & filter

// Result from the XML Search
@property(nonatomic, strong) SearchBase *searchBase;
@property(nonatomic, strong) TabSearchTable *searchTable;
@property(nonatomic, strong) TabSearchItems *searchItems;
// if true, automatically perform a search when displaying the search
@property(nonatomic) BOOL autoSearch;


// Called when a new search has been selected in the table
-(void)tableSelection:(SearchDefinition2 *)definition;
// Switch to a new parcel
-(void)switchToParcel:(id)parcel;
-(void)switchToMultipleParcels;
-(void)selectMultiplePropertiesOnMap;
// Go back to the search screen
-(void)switchBackFromGridController;

-(void)activateController;

-(void)searchWithArray:(NSDictionary *)array;
-(void)switchToGridWithArray;

-(void)tabBarWillSwitchController;

@end
