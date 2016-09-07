#import <UIKit/UIKit.h>
#import "GridController.h"
#import "AxDelegates.h"


@class RealPropInfo;
@class ControlBar;
@class TabSearchController;
@class SearchDefinition2;       //cvSearchDef
@class SelectedProperties;

@protocol TabSearchGridDelegate <NSObject>

@optional
-(void)tabSearchGridsetAutoSearch:(NSNumber *)search;
-(void)tabSearchGridswitchToMultipleParcels;
-(void)tabSearchGridselectMultiplePropertiesOnMap;
-(void)tabSearchGridChangedSelection;
-(void)tabSearchGridAddController:(GridController *)grid;
@required
-(void)tabSearchGridReturn;


@end

enum  
{
    kBtnSearchGridDetail = 10,
    kBtnSearchGridMap = 11
};

@interface TabSearchGrid : UIViewController<GridDelegate, MenuBarDelegate>
{
    ControlBar      *_menuBar;
    GridController  *gridController;
    NSMutableArray  *colDefinition;
    
    
    BOOL            _selectAll;
        
    // Synchronization with the activity
    
    NSTimer *progressTimer;
    
    NSThread    *workerThread;

    IBOutlet UIView *progressView;
    __weak IBOutlet UILabel *progressLabel;
    __weak IBOutlet UIProgressView *progressBar;
    __weak IBOutlet UIView *btnArea;
    UIView      *blockingView;
    SEL         callbackAtCompletion;
    id          targetAtCompletion;

    int         sortIndex;
    
    // Segmented control
    UISegmentedControl *segControl;
    
    BlockWithArray retrieveUniqueValues; 
    int         filterIndex;
}

// Create a grid
-(void)createGridFromSearch:(SearchDefinition2 *)search colDefinition:(NSMutableArray *)columnsDefinition;

// Delete a grid
-(void)removeGrid;

// Execute the queries
-(void)performQueries;

-(void)updateResults;

// Restore status
-(void)restoreSavedStatus;
// Perform the initial sort
-(void)performSort;
// Change the segment
-(void)changeSegment:(int)index;


@property(nonatomic, weak) id<TabSearchGridDelegate> delegate;
@property(nonatomic, strong) GridController  *gridController;
@property(nonatomic, strong) SearchDefinition2 *searchDefinition;
@property(nonatomic, strong) SelectedProperties  *selObject;

@end
