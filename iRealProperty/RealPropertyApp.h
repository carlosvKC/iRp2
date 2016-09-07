#import <UIKit/UIKit.h>
#import "AxDataManager.h"
#import "ControlBar.h"
#import "EntityBase.h"
#import "Synchronizator.h"
#import "TabBarController.h"
#import "TabFeedbackController.h"
#import "KLockScreenController.h"
#import "SyncManager.h"


@class ZipFile;
@class LoginScreen;
@class ReadPictures;
@class TabBarController;
@class Configuration;
@class TabSearchController;
@class AzureBlob;

#define MAX_ZIP_BUFFER     60
#define GRID_NUMBER_WIDTH  35

#define TIMER_DELAY (15) // How often is the method on the timer called

// DBaun 11/26/13 01:10pm CHANGE THIS BACK TO 45 MIN BEFORE RELEASE
#define DOWNLOADSYNC_AZURE  60  // (45*60)  // How often is azure contacted for updated blob information

#define AZUREAUTOMDOWNLOAD_TIMER_DELAY (30*60)        // Automatic update(download)


@interface RealPropertyApp : NSObject <UIApplicationDelegate, UIAlertViewDelegate, TabBarDelegate, KLockScreenControllerDelegate,
        SyncFileDelegate, SynchronizatorDelegate, SyncManagerDelegate> {
        // indicates if the app is currently doing a synchronization against axcim.
        BOOL isCurrentlySyncronizing;

        NSManagedObjectContext       *_managedObjectContext; //Context for access the Core Data entities
        NSManagedObjectModel         *_managedObjectModel; //Model for the Core Data Entities
        NSPersistentStoreCoordinator *_persistentStoreCoordinator;

        // configuration context
        NSManagedObjectContext       *_configManagedObjectContext; //Context for access the Core Data entities (only the configuration file)
        NSManagedObjectModel         *_configManagedObjectModel; //Model for the Core Data Entities
        NSPersistentStoreCoordinator *_configPersistentStoreCoordinator;

        // Personal Notes context
        NSManagedObjectContext       *_noteManagedObjectContext; //Context for access the Core Data entities (only the configuration file)
        NSManagedObjectModel         *_noteManagedObjectModel; //Model for the Core Data Entities
        NSPersistentStoreCoordinator *_notePersistentStoreCoordinator;

        // Special alert when file format is different
        UIAlertView *abortAlert;

        UIAlertView *needToDownload;


    @private
        // Contains all the image file for the current area
        ReadPictures *imageFile;

        // Temp buffer of images
        NSMutableDictionary *zipBuffer;

        // Login screen
        LoginScreen *loginScreen;

        // Time at which the application entered background
        NSTimeInterval timeSwitchToBackground;

        // Temp login
        BOOL partialLogin;

        // Executes automatic download synchronization
        NSTimer *downloadSyncTimer;

        // Synchronizator to execute the download.
        __strong Synchronizator *sync;

        SyncManager *syncManager;

        NSObject *syncMgrCallBackObj;

        BOOL newInstall;
    }

// Keep track of each property is being modified
    + (int)propertyBeingModified;

    + (void)setPropertyBeingModified:(int)propId;
    +(NSString *)PropertyBeingModifiedGuid;

    + (void)setPropertyBeingModifiedGuid:(NSString *)rpGuid;

// Switch to a property information
    - (void)switchToProperty:(id)property;

    - (void)switchToProperties;

    - (void)switchToProperty:(id)property
                    tabIndex:(int)tabIndex
                        guid:(NSString *)guid;
    - (void)switchToPropertyGuid:(NSString *)property
                    tabIndex:(int)tabIndex
                        guid:(NSString *)guid;
    - (void)switchToGuid:(NSString *)guid;

// Switch to the map controller
    - (void)selectPropertyOnMap:(id)pin;

    - (void)selectMultiplePropertiesOnMap;

    - (void)switchToCamera:(id)property;

    - (void)fireDownloadSync;

// return on search controller
// Return the name of the current user
    + (NSString *)getUserName;

// Return the user level
    + (int)getUserLevel;

// Update the entity definition of a given user
    + (void)updateUserDate:(id)baseEntity;

// Return the name of the current area
    + (NSString *)getWorkingArea;

// Return all the preferences
    + (Configuration *)getConfiguration;

    + (void)setConfiguration:(Configuration *)config;

// Setup the name of the current area
    - (void)setWorkingArea:(NSString *)area;

// Return the name of the working path (i.e. Area91/Area91...)
    + (NSString *)getWorkingPath;

// Return a file
//    - (UIImage *)getImageFromZip:(NSString *)fileName;

- (UIImage *)getImageFromZipWithMediaType:(NSString *)fileName
                                mediatype:(int)mediaType;


// Return the current readPictureClass
    - (ReadPictures *)currentPictureClass;

// Clean up the zip file cache
    - (void)cleanUpZipCache;

// Resume the application after login
    - (void)resumeApplication;

// Selection change -- when dealing with a map
    - (void)addSelection:(int)realPropId;
    -(void)addSelectionGuid:(NSString *)rpGuid;

    - (void)changeSelection:(int)realPropId
                  selection:(BOOL)sel;
    -(void)changeSelectionGuid:(NSString *)rpGuid selection:(BOOL)sel;

    - (BOOL)isParcelFromMap:(int)realPropId;

    - (void)removeSelection:(int)realPropId;
    -(void)removeSelectionGuid:(NSString *)rpGuid;

// Setup the bar at the top or bottom
    - (void)setBarAtBottom:(BOOL)atTop;

// decide to redo the query or not
    + (void)setQueryReady:(BOOL)qready;

    + (BOOL)queryReady;

// Open the main store
    - (BOOL)openRealPropertySqlite;

// Find all the possible areas
    + (NSArray *)findAllAreas;

// Global colors
    + (UIColor *)requiredBackgroundColor;

    + (UIColor *)disabledBackgroundColor;

    + (UIColor *)errorBackgroundColor;

    + (UIColor *)editableBackgroundColor;

// Services
    + (NSString *)getDataUrl;

    + (NSString *)getBlobUrl;

    + (void)loginAsTester:(BOOL)value;

    + (BOOL)isUserLoggedInTestMode;

    + (BOOL)cancelTestUser;

// Add multiple properties
    - (void)addMultipleProperties:(NSArray *)array;

// The grid selection has changed
    - (void)gridSelectionHasChanged;

// tax years
    + (void)setTaxYear:(int)taxY;

    + (void)setCycleStartDate:(NSString *)startY;

    + (void)setSaleStartDate:(NSString *)startY;

    + (int)taxYear;

    + (NSString *)cycleStartDate;

    + (NSString *)saleStartDate;

// Reach network
    + (BOOL)reachNetworkStatus;

    + (BOOL)reachNetworkThroughWifi;

    + (BOOL)reachNetworkThrough3G;

    + (NSString *)reachNetwork;

// Allow to sync (or not)
    + (void)allowToSync:(BOOL)sync;

    + (BOOL)allowToSync;

    - (BOOL)isSyncing;

    - (void)checkForChangedAzureFiles:(NSTimer *)timer;


// Synchronization Manager.
    - (void)downloadAzureFile:(NSString *)fileName
                  inContainer:(NSString *)container
                       toPath:(NSString *)destinyPath
               withFileLength:(int64_t)fileLength
          andResumingDownload:(BOOL)resumeDownload
            andCallBackObject:(NSObject *)callBackObj;

    - (void)cancelAzureFileDownload;

// Return the date of the last sync
    + (double)getLastSyncDate:(NSManagedObjectContext *)context;


// All the tab controllers
    @property(strong, nonatomic) UIViewController        *tabPropertyController;
    @property(strong, nonatomic) UIViewController        *tabSearchController;
    @property(strong, nonatomic) UIViewController        *tabMapController;
    @property(strong, nonatomic) UIViewController        *tabMyDayController;
    @property(strong, nonatomic) UIViewController        *tabBookmarkController;
    @property(strong, nonatomic) UIViewController        *tabOptionsController;
    @property(strong, nonatomic) UIViewController        *tabSyncController;
    @property(strong, nonatomic) UIViewController        *tabNotesController;
    @property(strong, nonatomic) UIViewController        *tabFeedbackController;
    @property(strong, nonatomic) UIImagePickerController *imgPicker;
// used to indicate if a new search
    @property(nonatomic) BOOL searchMode;


// The principal XML definition
    @property(nonatomic, strong) EntityBase *xmlCoreDefinition;

// Graphical elements
    @property(nonatomic, strong) UIWindow         *window;
    @property(strong, nonatomic) TabBarController *tabBarController;

// The picture manager
    @property(nonatomic, strong) ReadPictures *pictureManager;

// automatic file synchronization
    @property(nonatomic, strong) SyncFiles *syncFiles;
    @property(nonatomic) int countOfChangedAzureFiles;
@end
