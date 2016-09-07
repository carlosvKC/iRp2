#import <UIKit/UIKit.h>
#import "SegmentedControlLightController.h"
#import "RealPropInfo.h"
#import "ScreenController.h"
#import "ControlBar.h"
#import "MenuTable.h"
#import "KeyboardController.h"

#import "TabBarController.h"
#import "BaseNote.h"
#import "DVModelController.h"
#import "DashboardToDoTableViewDelegate.h"

@class TabBase;
@class SelectedProperties;
@class BaseNote;
@class DVModelController;
@class BookmarkReason;

enum PropertyTagsConstant {
    kTabPropertyImage = 200,
    kTabLandImage     = 210,
    kTabLandSubviews  = 220,
    kTabBuildingImage = 110,
    kTabAccyImage     = 110,
    kTabMobileImage   = 250,
    kTabNoteImage     = 110
};

enum ControlBarConstant {
    kCtrlBarLabel = 1,
    kCtrlBarToDo = 2,
    
    kCtrlBarPrevious = 10,
    kCtrlBarNext     = 11,

    kCtrlBarImps = 15,

    kCtrlBarUndo = 20,
    kCtrlBarSave = 21,
    kCtrlBarWebLinks = 22,
    kCtrlBarBookmark = 23,
    kCtrlBarMap = 24,

    kCtrlNewNote = 25,
    kCtrlEditLoc = 26
};

@class ComboBoxController;
@class TabPicturesController;


@interface RealProperty : KeyboardController <MenuBarDelegate, DashboardToDoTableViewDelegate,
                                            UIAlertViewDelegate, MenuTableDelegate, UIPopoverControllerDelegate, TabBarDelegate, NoteMgrDelegate, ModalViewControllerDelegate> {

        __weak UISegmentedControl *segmentedCtrl;
        TabBase                   *activeSubController;
        int currentIndex;

        // List of all the sub controllers
        TabBase *tabDetailsController;
        TabBase *tabLandController;
        TabBase *tabBuildingController;
        TabBase *tabAccyController;
        TabBase *tabMobileController;
        TabBase *tabHistoryController;
        TabBase *tabHIEController;
        TabBase *tabInterestController;
        TabBase *tabNoteController;
        TabBase *tabValuesController;

        TabPicturesController *tabPicturesController;

        // the top menu control bar
        ControlBar *menuBar;
        MenuTable  *menu;

        NSString *switchToParcelNbr;

        // List of objects to go through
        int parcelsIndex;

        // Current alert
        UIAlertView *validateParcelAlert;

        // Track if the invalid view is added or not
        BOOL invalidViewAdded;

        // Selector after the alert
        SEL selectorAfterAlert;

        UIPopoverController *impsPopOver;

        // The working note
        BaseNote *baseNote;

        // Drawing
        DVModelController *modelController;

        // to avoid multiple clicks
        NSTimeInterval lastClick;
        int            lastSelectedIndex;
        BOOL           noAnimation;

        BookmarkReason *bmReason;

        // List of errors
                                 
    }

    enum {
        kTabDetails = 0,
        kTabLand,
        kTabBuilding,
        kTabAccy,
        kTabMobile,
        kTabHistory,
        kTabHIE,
        kTabInterest,
        kTabNote,
        kTabValue,
        kTabPicture = 100
    };

    @property(nonatomic, weak) IBOutlet UISegmentedControl *segmentedCtrl;
// Current active parcel number
    @property(nonatomic, retain) NSString                  *parcelNbr;

// Maintain information about changes
    @property BOOL isDirty;

    @property(nonatomic, strong) IBOutlet UIView *noProperty;

    @property(nonatomic, strong) SegmentedControlLightController *segmentedControlLightController;

    - (IBAction)switchSegment:(id)sender;

    - (void)switchView:(int)index;

    - (void)segmentOn:(int)segment;

    - (void)segmentUsed:(int)segment;

// display the pciture controller
    - (void)switchBackFromPictureController;

// Return from the picture controller
    - (void)switchToPictureController:(NSArray *)medias
                             selected:(id)media
                       fromController:(ScreenController *)controller;

    - (void)menuBarBtnSelected:(int)tag;

// Switch to a new parcel
    - (void)validateAndSwitchToParcel:(id)parcelStr;

// Switch to multiple parcels
    - (void)validateAndSwitchToMultipleParcels;

    - (void)checkForValidParcel;

    - (void)disableSaveUndoButton;

    - (void)switchToCamera:(id)parcel;

// reset the position to the top list
    - (void)moveToMultipleParcels;

    + (RealPropInfo *)realPropInfo;

// Return the most 'accurate' media
    + (MediaBldg *)getBuildingPicture:(RealPropInfo *)realPropInfo;

    + (NSSet *)getPicture:(RealPropInfo *)realPropInfo;

// Next/previous picture of the current one
//+ (MediaBldg *)getNextBuildingPicture:(RealPropInfo *)realPropInfo media:(NSSet *)currentMedia;
//+ (MediaBldg *)getPreviousBuildingPicture:(RealPropInfo *)realPropInfo media:(NSSet *)currentMedia;
    + (NSSet *)getNextPicture:(RealPropInfo *)realPropInfo
                        media:(NSSet *)currentMedia;

    + (NSSet *)getPreviousPicture:(RealPropInfo *)realPropInfo
                            media:(NSSet *)currentMedia;

    + (NSArray *)getAllBuildingPictures:(RealPropInfo *)info;

    + (int)getNumberOfMedias:(RealPropInfo *)realPropInfo;

// 2/20/13 HNN support vacant properties
    + (NSSet *)getPicture:(RealPropInfo *)realPropInfo
                    index:(int)index;

    + (int)findCurrentMedia:(RealPropInfo *)realPropInfo
                      media:(NSSet *)currentMedia;

    + (SelectedProperties *)selectedProperties;

    + (void)setSelectedProperties:(SelectedProperties *)p;

    + (RealProperty *)instance;

    + (NSArray *)sortMedia:(NSArray *)mediaToBeSorted;

    + (NSArray *)findAllMedias:(RealPropInfo *)propinfo;

    + (NSArray *)findAllMedias:(RealPropInfo *)propinfo
                           cnt:(int)cnt;

    - (void)setCurrentImps:(int)value;

    - (void)updateBadge;

    - (void)updateBadge:(BOOL)removeBadge;

    - (void)switchToFirstBuilding;

    - (void)switchToParcel:(id)parcelStr;

    - (void)runDashboardQueries;

// Update the bookmarks
    - (void)validateAndSwitchToParcel:(id)parcelStr
                             tabIndex:(int)index
                                 guid:(NSString *)guid;


    -(void)tabBarWillSwitchController;
@end


