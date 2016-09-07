#import <UIKit/UIKit.h>
#import "Options.h"
#import "AxDelegates.h"
#import "AreasList.h"
#import "ATActivityIndicator.h"
#import "ManageAreas.h"
#import "DownloadFiles.h"
#import "SyncFiles.h"


@class ControlBar;
@class AreasList;
@class ManageAreas;
@class TabOptionsController;
@class Requester;

enum {
    kOptionListSyncAll,
    kOptionListFilesHaveChanged
};


@interface OptionsList : UITableViewController <UIAlertViewDelegate, MenuBarDelegate, ChangeAreaDelegate, UITableViewDelegate, ManageAreaDelegate, DownloadFilesDelegate, UIAlertViewDelegate,
        SyncFileDelegate> {
        Options     *_options;
        UIButton    *_btnSwitch;
        UIButton    *_resetParcel;
        UIButton    *_resetLayers;
        UIButton    *_fixVcad;
          
        UIAlertView *_alert;
        enum {
            kAlertResetLayers,
            kAlertResetRenderers,
            kAlertExitApplication
        }           _alertMode;

        AreasList   *_areaList;
        ManageAreas *_manageArea;

        enum {
            kDetailManageArea,
            kDetailSelectArea
        }   _detailMode;

        UIView                 *_manageView;
        UINavigationController *nav;
        ATActivityIndicator    *activity;
        DownloadFiles          *downloadController;

        UITableViewCell *currentAreaCell;

        int _mode;  // indicate what to change
        UITableViewCell *updateCell;
        UITableViewCell *downloadCell;
    }

    @property(nonatomic, strong) ControlBar         *menuBar;
    @property(nonatomic, weak) TabOptionsController *itsController;

    - (id)initWithNibName:(NSString *)nibNameOrNil
              withOptions:(Options *)options;

    - (void)startAreaManagement;

    - (void)updateOptionCellWithAreaFileStateMsg;

    - (void)activateController;

    - (void)updateDownloadCell;
@end
