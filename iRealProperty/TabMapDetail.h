#import <UIKit/UIKit.h>
#import "ScreenController.h"
#import "CheckBoxView.h"
#import "InspectionManager.h"
#import "BaseView.h"
#import "ScreenController.h"
#import "UIDragableToolbar.h"
#import "MenuTable.h"
#import "BookmarkReason.h"
#import "DashboardToDoTableViewDelegate.h"

@class NSManagedObject;
@class AGSMapView;
@class MediaBldg;
@class TabPicturesController;
@class TabMapDetail;




// Entry definition
@interface DetailsDefinition : NSObject
    @property(nonatomic, strong) NSString   *labelName;     // Name to use on the label
    @property(nonatomic, strong) NSString   *labelValue;    // Value to display
@end



// Section definition
@interface DetailsSection : NSObject
    @property(nonatomic, strong) NSString *sectionName; // Section name to use
    @property(nonatomic, strong) NSMutableArray *details;   // Entries for that section
@end



// protocol
@protocol TabMapDetailDelegate <NSObject>
    -(void)tabMapDetailIsDone;
    -(void)tabMapDetailSwitchHome:(RealPropInfo *)info;
    -(void)tabMapDetailSwitchCamera:(RealPropInfo *)info;
    -(void)tabMapDetailRefreshLayers;
    -(void)tabMapDetailPosition:(RealPropInfo *)info;
@end



// Table View definition
@interface DetailTableViewController : UITableViewController
    {
        // List of entries
        NSMutableArray  *entries;
        
        // List of sections
        NSMutableArray  *sectionDetails;
        
        // current realProp
        NSString *parcelNbr;  
        NSString *parcelInfo;
        NSString *rpGuid;
    }
    @property(nonatomic, strong) NSString *parcelNbr;
   -(void)initDataWithRealPropId:(int)realPropId;
    -(void)initDataWithrpGuid:(NSString *)rpInfoGuid;

@end



@interface TabMapDetail : ScreenController<CheckBoxDelegate, UIDragableToolbarDelegate, MenuTableDelegate, DashboardToDoTableViewDelegate, UIPopoverControllerDelegate>
    {
        // Display information
        // 2/20/13 HNN support vacant properties
        NSSet *media;

        int        propertyId;
        NSString      *rpGuid;
        
        CheckBoxView *chkImps;
        CheckBoxView *chkLand;
        CheckBoxView *chkBoth;
        
        InspectionManager *inspection;
        
        RealPropInfo    *realPropInfo;   
        
        int         mediaIndex;
        int         maxMediaIndex;
        TabPicturesController *tabPicturesController;
        
        MenuTable       *menu;
        
        BookmarkReason *bmReason;
        
    }
    - (IBAction)displayPicture:(id)sender;
    // Retain the map parent view
    @property(nonatomic, strong) AGSMapView *parentMap;
    @property (weak, nonatomic) IBOutlet UITableView *tableView;
    @property( strong, nonatomic) DetailTableViewController *tableController;
    @property (weak, nonatomic) IBOutlet UIDragableToolbar *draggableBar;
    @property (weak, nonatomic) id<TabMapDetailDelegate>delegate;

    -(void)initDataWithRealPropId:(int)realPropId;
    -(void)initDataWithrpGuid:(NSString *)rpInfoGuid realPropId:(int)realPropId;

    -(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;
    - (IBAction)selectHomeButton:(id)sender;
    - (IBAction)selectCameraButton:(id)sender;
    - (IBAction)selectRightButton:(id)sender;
    - (IBAction)selectPosition:(id)sender;

    - (IBAction)selectBookmark:(id)sender;
    - (IBAction)selectLeftButton:(id)sender;
    @property (weak, nonatomic) IBOutlet UIButton *rightButton;
    @property (weak, nonatomic) IBOutlet UIButton *leftButton;
    @property (weak, nonatomic) IBOutlet UIButton *cameraButton;
    @property (weak, nonatomic) IBOutlet UIButton *toDoButton;
    @property (weak, nonatomic) IBOutlet UIButton *bookmarkButton;
@end
