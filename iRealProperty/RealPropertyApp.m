#import "RealPropertyApp.h"
#import "RealProperty.h"
#import "TabSearchController.h"
#import "TabBookmarkController.h"
#import "TabMapController.h"
#import "TabOptionsController.h"
#import "TabSyncController.h"
#import "TabMyDayController.h"
#import "TabNotesController.h"
#import "Helper.h"
#import "LoginScreen.h"
#import "ReadPictures.h"
#import "SelectedObject.h"
#import "Reachability.h"
#import "Crittercism.h"
#import "Version.h"
#import "DatabaseDate.h"
#import "DaveGlobals.h"
#import "AzureFileStatusChecker.h"
#import "MediaView.h"


#define TIMESWITCHTOBACKGROUND (5*60.0)

void HandleExceptions(NSException *exception);

void SignalHandler(int sig);


@implementation RealPropertyApp


    @synthesize window;

    @synthesize tabBarController;
    @synthesize tabPropertyController;
    @synthesize tabSearchController;
    @synthesize tabMapController;
    @synthesize tabMyDayController;
    @synthesize tabBookmarkController;
    @synthesize tabOptionsController;
    @synthesize tabSyncController;
    @synthesize tabNotesController;
    @synthesize tabFeedbackController;
    @synthesize xmlCoreDefinition;
    @synthesize pictureManager = imageFile;
    @synthesize syncFiles;
    @synthesize countOfChangedAzureFiles;
    @synthesize searchMode;
    @synthesize imgPicker;

    static Configuration *currentConfig = nil;
    static Reachability  *reachability;

    static BOOL isUserLoggedInTestMode = NO;
    static BOOL allowToSync            = NO;
    static BOOL queryReady             = NO;

    static int taxYear;
    static int currentUserLevel;

    static NSString *workingArea;
    static NSString *currentUser;
    static NSString *workingDirectory;
    static NSString *cycleStartDate;
    static NSString *saleStartDate;
    static NSString *permanentStore;

    static AzureFileStatusChecker *theFileStatusChecker;

    static BOOL onlyOneAlert = NO;

    +(void)onlyOneAlert:(BOOL)zoom
    {
        onlyOneAlert = zoom;
    }



    + (void)setTaxYear:(int)taxY
        {
            taxYear = taxY;
        }



    + (void)setCycleStartDate:(NSString *)date
        {
            cycleStartDate = date;
        }



    + (void)setSaleStartDate:(NSString *)date
        {
            saleStartDate = date;
        }



    + (NSString *)saleStartDate
        {
            return saleStartDate;
        }



    + (int)taxYear;
        {
            return taxYear;
        }



    + (NSString *)cycleStartDate
        {
            return cycleStartDate;
        }



    + (void)allowToSync:(BOOL)sync
        {
            allowToSync = sync;
        }



    + (BOOL)allowToSync
        {
            return allowToSync;
        }



// Current property being modified
    static int loadedProperty = 0;



    + (int)propertyBeingModified
        {
            return loadedProperty;
        }



    + (void)setPropertyBeingModified:(int)propId
        {
            loadedProperty = propId;
        }

    static NSString *loadedPropGuid = @"";

    +(NSString *)PropertyBeingModifiedGuid
        {
            return loadedPropGuid;
        }

+ (void)setPropertyBeingModifiedGuid:(NSString *)rpGuid
    {
    if ([rpGuid length]> 0)
        loadedPropGuid = rpGuid;
    }
//
// Return current user name
    + (NSString *)getUserName
        {
         return currentUser;
          //  return @"USR2";
        }


    + (void)setQueryReady:(BOOL)qready
        {
            queryReady = qready;
        }



    + (BOOL)queryReady
        {
            return queryReady;
        }



    + (BOOL)reachNetworkStatus
        {
            NetworkStatus status = [reachability currentReachabilityStatus];
            if (status == NotReachable)
                return NO;
            return YES;
        }



    + (BOOL)reachNetworkThroughWifi
        {

            NetworkStatus status = [reachability currentReachabilityStatus];
            if (status == ReachableViaWiFi)
                return YES;
            return NO;
        }



    + (BOOL)reachNetworkThrough3G
        {

            NetworkStatus status = [reachability currentReachabilityStatus];
            if (status == ReachableViaWWAN)
                return YES;
            return NO;
        }



    + (NSString *)reachNetwork
        {
            NetworkStatus status = [reachability currentReachabilityStatus];

            if (status == ReachableViaWiFi)
                return @"";
            if (status == ReachableViaWWAN && !currentConfig.syncOver3G)
                return @"WiFi is not currently accessible. To sync over 3G, turn on the Sync Over 3G in the option menu.";
            if (status == NotReachable)
                return @"No WiFi or 3G currently available. Check to make sure that you have coverage";
            return @"";
        }



//
// Return the current working area
//
    + (NSString *)getWorkingArea
        {
            return workingArea;
        }



    + (NSString *)getPermanentStore
        {
            return permanentStore;
        }



    + (NSString *)getWorkingPath
        {
            if ([workingDirectory length] == 0)
                {
                    workingDirectory = [NSString stringWithFormat:@"%@/%@", workingArea, workingArea];
                }
            return workingDirectory;
        }



//
// Get the current level of the user -- 0 lowest, 2 is the one with the highest rank
    + (int)getUserLevel
        {
            return currentUserLevel;
        }



// Get the configuration
    + (Configuration *)getConfiguration
        {
            return currentConfig;
        }



    + (void)setConfiguration:(Configuration *)configuration
        {
            currentConfig = configuration;
        }



//
// Setup the current area
//
    - (void)setWorkingArea:(NSString *)areaName
        {
            currentConfig.currentArea = areaName;
            [[AxDataManager configContext] save:nil];

            workingArea      = areaName;
            workingDirectory = nil;

            NSArray  *paths             = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentDirectory = [paths objectAtIndex:0];


            NSString *fileName;
            fileName  = [documentDirectory stringByAppendingFormat:@"/%@.Media.sqlite", [RealPropertyApp getWorkingPath]];
            // try to open the new DB files
            imageFile = [[ReadPictures alloc] initWithDataBase:fileName];
        }



    - (void)cleanUpZipCache
        {
            [zipBuffer removeAllObjects];
            zipBuffer = nil;
        }



    - (ReadPictures *)currentPictureClass
        {
            return imageFile;
        }


- (UIImage *)getImageFromZipWithMediaType:(NSString *)fileName
                                mediatype:(int)mediaType;
{
    // If no image cache has been created yet, then create one.
    if (zipBuffer == nil)
    {
        zipBuffer = [[NSMutableDictionary alloc] initWithCapacity:MAX_ZIP_BUFFER];
    }
    
    // 4/29/16 HNN image cache is only for mini pictures. full size needs to get from sqlite so that picture
    // is nice and clear
    if (mediaType==kMediaMini)
    {
        // Check if the file exists in the image cache.
        UIImage *resultImg = [zipBuffer valueForKey:fileName];
        
        if (resultImg != nil)
        {
            //NSLog(@"Retrieve from cache '%@'",fileName);
            return resultImg;
        }
        
    
    }

    UIImage *image = [imageFile findImageWithMediaType:fileName mediaType:mediaType];
    
    if (image == nil)
        return nil;
    
    // If code reached this point then the image was found from a database query using 'findImage', and does not exist in the image cache yet.
    // If the image cache is full (based on the size we allocated), then we need to remove an image in order to make room for a new one.
    
    
    // 4/29/16 HNN image cache is only for mini pictures. full size needs to get from sqlite so that picture
    // is nice and clear
    if (mediaType==kMediaMini)
    {
        //cv
        if ([zipBuffer count] == MAX_ZIP_BUFFER - 1)
        {
            // Remove first image
            NSEnumerator *enumerator = [zipBuffer keyEnumerator];
            id key = [enumerator nextObject];
            [zipBuffer removeObjectForKey:key];
            NSLog(@"Remove key '%@' from cache", key);
        }
    
        // Save it in the buffer'
        //NSLog(@"Add key '%@' to cache", fileName);
    
        // Add the image we just obtained from the database to the image cache.
        [zipBuffer setValue:image forKey:fileName];
    }
    return image;
}

//
// Return an image based on the name of the file// on the Images table
// If the image is found (based on Guid) in the cache, then it will be returned from there without a database search.
// If the image is NOT in the cache, then call 'findImage' to locate it.
//
//    - (UIImage *)getImageFromZip:(NSString *)fileName
//        {
//            // If no image cache has been created yet, then create one.
//            if (zipBuffer == nil)
//                {
//                    zipBuffer = [[NSMutableDictionary alloc] initWithCapacity:MAX_ZIP_BUFFER];
//                }
//
//            // Check if the file exists in the image cache.
//            UIImage *resultImg = [zipBuffer valueForKey:fileName];
//
//            if (resultImg != nil)
//                {
//                    //NSLog(@"Retrieve from cache '%@'",fileName);
//                    return resultImg;
//                }
//
//            UIImage *image = [imageFile findImage:fileName];
//
//            if (image == nil)
//                return nil;
//
//            // If code reached this point then the image was found from a database query using 'findImage', and does not exist in the image cache yet.
//            // If the image cache is full (based on the size we allocated), then we need to remove an image in order to make room for a new one.
//          
//            
//            //cv
//            if ([zipBuffer count] == MAX_ZIP_BUFFER - 1)
//                {
//                    // Remove first image
//                    NSEnumerator *enumerator = [zipBuffer keyEnumerator];
//                    id key = [enumerator nextObject];
//                    [zipBuffer removeObjectForKey:key];
//                    NSLog(@"Remove key '%@' from cache", key);
//                }
//
//            // Save it in the buffer'
//            //NSLog(@"Add key '%@' to cache", fileName);
//
//            // Add the image we just obtained from the database to the image cache.
//            [zipBuffer setValue:image forKey:fileName];
//            
//            return image;
//        }



//
// Update the current user and time
//
    + (void)updateUserDate:(id)baseEntity
        {
            [baseEntity setValue:[RealPropertyApp getUserName] forKey:@"updatedBy"];

            [baseEntity setValue:[Helper localDate] forKey:@"updateDate"];
        }



//
// Find all the working areas installed in the application - areas are between 00 and 99
//
    + (NSArray *)findAllAreas
        {
            return [Helper findAllDirectories:@"Area"];
        }



//
// Active the property map and zoom on a property
//
    - (void)selectPropertyOnMap:(id)pin
        {
            tabBarController.selectedViewController = tabMapController;
            [(TabMapController *) tabMapController selectParcel:pin];
        }



// Same features but with multiple properties
    - (void)selectMultiplePropertiesOnMap
        {
            // create the empty arrea
            NSMutableArray *array = [[NSMutableArray alloc] init];

            SelectedProperties *properties = [RealProperty selectedProperties];
            // Get the current set of normal properties
            for (int i = 0; i < properties.memGridIndex.count; i++)
                {
                    NSNumber    *number = [properties.memGridIndex objectAtIndex:i];
                    RowProperty *row    = [properties.memGrid objectAtIndex:[number intValue]];
                    number = [[NSNumber alloc] initWithInt:((RealPropInfo *) row.realPropInfo).realPropId];
                    [array addObject:number];
                }

            tabBarController.selectedViewController = tabMapController;

            NSMutableArray *selectedArray = [[NSMutableArray alloc] init];

            NSArray *indexes = [properties listOfSelectedRows];

            for (NSNumber *num in indexes)
                {
                    RowProperty *row    = [properties.memGrid objectAtIndex:[num intValue]];
                    NSNumber    *number = [[NSNumber alloc] initWithInt:((RealPropInfo *) row.realPropInfo).realPropId];
                    [selectedArray addObject:number];

                }

            [(TabMapController *) tabMapController selectMultipleParcel:array selectedParcels:selectedArray];
        }



//
// If the user has not logged yet, or if the simpleToken has expired, then
// request a new login against AD
//
    - (void)logUser:(BOOL)expiredToken
        {
            // This is a cold boot -- always log the user
            loginScreen = [[LoginScreen alloc] initWithNibName:@"LoginScreen" bundle:nil];

            [self.tabBarController.view addSubview:loginScreen.view];
            [self.tabBarController.view bringSubviewToFront:loginScreen.view];
            [self.tabBarController addChildViewController:loginScreen];

            if (expiredToken)
                {
                    [Helper alertWithOk:@"Expired Login" message:@"Your login credentials have expired. Please log with an active connection to receive valid credentials."];
                }

        }



    void HandleExceptions(NSException *exception)
        {
            NSLog(@"This is where we save the application data during a exception");
            // Save application data on crash
        }



    void SignalHandler(int sig)
        {
            NSLog(@"This is where we save the application data during a signal");
            // Save application data on crash
        }



//
// Application starts here
//
    - (BOOL)      application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
        {

            partialLogin = NO;

            theFileStatusChecker = [[AzureFileStatusChecker alloc] init];
            


            
            
#if 0
    // installs HandleExceptions as the Uncaught Exception Handler
    NSSetUncaughtExceptionHandler(&HandleExceptions);
    // create the signal action structure 
    struct sigaction newSignalAction;
    // initialize the signal action structure
    memset(&newSignalAction, 0, sizeof(newSignalAction));
    // set SignalHandler as the handler in the signal action structure
    newSignalAction.sa_handler = &SignalHandler;
    // set SignalHandler as the handlers for SIGABRT, SIGILL and SIGBUS
    sigaction(SIGABRT, &newSignalAction, NULL);
    sigaction(SIGILL, &newSignalAction, NULL);
    sigaction(SIGBUS, &newSignalAction, NULL);
#endif

            [Crittercism initWithAppID:@"4fea71eeeeaf4135d0000001"
                                andKey:@"udlki8oa6zfs7ebbgl4gmvtzysek"
                             andSecret:@"xwqrf3lkodt14rgiuh9acdtnl2nbpjif"
                 andMainViewController:nil];

            reachability = [Reachability reachabilityForInternetConnection];
            [reachability startNotifier];

            // Get the personal notes ready
            [AxDataManager createManagedObjectContext:@"note" storeName:@"PersonalNotes.sqlite" modelName:@"Note"];

            [self determineIfThisIsNewInstall];

            [self installCommonFilesFromBundleIfNeeded];

            // Must be able to load that XML!
            xmlCoreDefinition = [[EntityBase alloc] initWithXMLFile:@"iRealProperty2"];

            [AxDataManager createManagedObjectContext:@"config" storeName:@"Preferences2.sqlite" modelName:@"Preferences2"];

            // Prepare the other controllers
            tabBarController = [[TabBarController alloc] initWithNibName:@"TabBarController" bundle:nil];

            // Override point for customization after application launch.
            tabPropertyController = [[RealProperty alloc] initWithNibName:@"RealProperty" bundle:nil];
            tabSearchController   = [[TabSearchController alloc] initWithNibName:@"TabSearchController" bundle:nil];
            tabMapController      = [[TabMapController alloc] initWithNibName:@"TabMapController" bundle:nil];
            tabMyDayController    = [[TabMyDayController alloc] initWithNibName:@"TabMyDayController" bundle:nil];
            tabBookmarkController = [[TabBookmarkController alloc] initWithNibName:@"TabBookmarkController" bundle:nil];
            tabNotesController    = [[TabNotesController alloc] initWithNibName:@"TabNotesController" bundle:nil];
            tabOptionsController  = [[TabOptionsController alloc] initWithNibName:@"TabOptionsController" bundle:nil];
            tabSyncController     = [[TabSyncController alloc] initWithNibName:@"TabSyncController" bundle:nil];
            tabFeedbackController = [[TabFeedbackController alloc] initWithNibName:@"TabFeedbackController" bundle:nil];

            // Tab Bar
            tabBarController.delegate = self;

            NSArray *controllers = [[NSArray alloc] initWithObjects:tabMyDayController, tabSearchController, tabPropertyController, tabMapController, tabBookmarkController, tabNotesController, tabOptionsController, tabSyncController, nil];


            self.window                    = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
            self.window.rootViewController = tabBarController;
            [self.window makeKeyAndVisible];
            tabBarController.items = controllers;
            //   tabBarController.selectedViewController = tabSearchController;

            // Log the user
            [self logUser:NO];


            return YES;
        }



    - (void)createOverlayWindow
        {
        }



//
// After login
//
    - (void)resumeApplication
        {
            BOOL needToDownloadArea = NO;

            // DBaun 10/24/13 03:31pm I SHOULD ALSO PLACE THIS WHERE THE USER CHANGES AREAS, IF IT'S NOT THERE ALREADY.
            // DBaun 11/26/13 02:44pm On second thought, the user changes areas in [OptionsList changeAreaDelegate] and that method FORCES you to close the application and restart it, hence
            // DBaun 11/26/13 02:44pm there would be no point to put the "checkForChangedAzureFiles" call over there since the app will be closing and restarting.

            NSLog(@"[RealPropertyApp resumeApplication] -> [currentConfig.currentArea =  %@", [currentConfig currentArea]);

            if ([currentConfig.currentArea length] > 0)
                {
                    BOOL allowedToSyncCachedVal = [RealPropertyApp allowToSync];
                    [RealPropertyApp allowToSync:YES];
                    [theFileStatusChecker checkForChangedFilesInAreaAndNotifyDelegate:self];

                    //DBaun 02/28/14 08:24am  Commenting this out so that the check for updated files only occurs once per application session.
                    //[NSTimer scheduledTimerWithTimeInterval:TIMER_DELAY target:self selector:@selector(checkForChangedAzureFiles:) userInfo:nil repeats:YES];

                    [RealPropertyApp allowToSync:allowedToSyncCachedVal];
                }

            // If AreaXX files are in the Documents directory, move them to the appropriate AreaXX subdirectory.
            NSArray *areaFilesToMove = [self checkForAreaFilesToMoveFromRootDir];

            if (!partialLogin)
                {
                    // Here because the user token is still valid (not expired)

                    currentUser      = currentConfig.userName;
                    workingArea      = currentConfig.currentArea;
                    currentUserLevel = currentConfig.userLevel;

                    if ([workingArea length] == 0)
                        needToDownloadArea = YES;

                    // Set the current area to be the working area
                    [self setWorkingArea:workingArea];

                    if (![self openRealPropertySqlite])
                        {
                            needToDownloadArea = YES;
                        }

                    [tabBarController setBarAtBottom:currentConfig.menuAtBottom];

                    [self.tabBarController.view bringSubviewToFront:loginScreen.view];   // keep it in front

                    if (currentConfig.tabToLog == 0)
                        tabBarController.selectedViewController = tabMyDayController;
                    else
                        tabBarController.selectedViewController = tabSearchController;


                    if (needToDownloadArea)
                        {
                            // Here because Configuration.currentArea has no value, or RealProperty.sqlite failed to open.
                            // After this runs, assuming the user does a download, the files should be downloaded and put
                            // into the AreaXX folder AND the FilesSync table updated with the latest ETags.
                            // See [DownloadFiles downloadAzureFileDidLoadData] for the FilesSync ETag update.

                            int fx = currentConfig.useEffects;
                            tabBarController.selectedViewController = tabOptionsController;
                            currentConfig.useEffects                = fx;

                            needToDownload = [[UIAlertView alloc] initWithTitle:@"No area selected"
                                                                        message:@"Before being able to use iRealProperty, you need to download or to select an area. Click continue to download an area."
                                                                       delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:nil];
                            [needToDownload show];
                        }
                }

            if (!needToDownloadArea)
                {
                    // Here because Configuration.currentArea has an Area value, and successfully opened RealProperty.sqlite
                    // If the necessary files aren't present, the user will be taken to the Options Tab Page and presented with the Manage Areas screen to do a download.
                    [self verifyNecessaryAreaFilesArePresent];
                    
                }


            syncFiles = [[SyncFiles alloc] init];
            syncFiles.delegate = self;

            [self createETagsForRootDirAreaFiles:areaFilesToMove];

            // Get the first tab ready
            if (currentConfig.tabToLog == 0)
                {
                    tabBarController.selectedViewController = tabMyDayController;
                    [(TabSearchController *) tabMyDayController activateController];
                }
            else
                {
                    tabBarController.selectedViewController = tabSearchController;
                    [(TabSearchController *) tabSearchController activateController];

                }

            // get the latest number of bookmark errors
            [TabBookmarkController updateBookmarkErrors];


            if (newInstall)
                {
                    // Here because either no version record was found in the PersonalNotes.sqlite Version table, or the version record's value doesn't match the Bundle's value.
                    // This ETags update is done here after the login, not before the login, because it needs to contact azure and in order to do that, a valid token is needed, which is obtained at login.
                    [syncFiles createETags:[Helper versionSpecificContainerName:@"common"] andDownloadFiles:YES];
                }

            // Make the transition
            CGRect frame = loginScreen.view.frame;
            [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^
                {
                    loginScreen.view.frame = CGRectOffset(frame, -1024, 0);
                }
                             completion:^(BOOL finished)
                                 {
                                     // Remove the loginScreen
                                     [loginScreen.view removeFromSuperview];
                                     [loginScreen removeFromParentViewController];
                                     //[loginScreen viewDidUnload];
                                     loginScreen = nil;

                                     if (!needToDownloadArea)
                                         allowToSync = YES;

                                 }];


        }



// Sets the newInstall ivar to YES or NO depending on the tests in this method.
    - (void)determineIfThisIsNewInstall
        {
            NSDictionary *dictionary = [[NSBundle mainBundle] infoDictionary];
            NSString     *build      = [dictionary objectForKey:@"CFBundleVersion"];

            NSArray *list = [AxDataManager dataListEntity:@"Version" andSortBy:@"version" andPredicate:[NSPredicate predicateWithFormat:@"1==1"] withContext:[AxDataManager noteContext]];

            newInstall = NO;

            if ([list count] == 0)
                {
                    // Here because no version record found in Version table.  So create a new record and save it.
                    Version *version = [AxDataManager getNewEntityObject:@"Version" andContext:[AxDataManager noteContext]];
                    version.version = build;
                    [[AxDataManager noteContext] save:nil];
                    newInstall = YES;
                }
            else
                {
                    Version *version = [list objectAtIndex:0];
                    if ([version.version caseInsensitiveCompare:build] != NSOrderedSame)
                        {
                            // Here because the version record in the Version table does not match the bundle version.  Update and save.
                            version.version = build;
                            [[AxDataManager noteContext] save:nil];
                            newInstall = YES;
                        }
                }
        }



    - (void)installCommonFilesFromBundleIfNeeded
        {
            [Helper extractAndPlaceCommonFileFromBundle:@"LUItem2.sqlite3" force:newInstall];
            [Helper extractAndPlaceCommonFileFromBundle:@"iRealProperty2.xml" force:newInstall];
            [Helper extractAndPlaceCommonFileFromBundle:@"SearchDefinition2.xml" force:newInstall];
        }



    - (BOOL)openRealPropertySqlite
        {
            if ([AxDataManager createManagedObjectContext:@"default" storeName:[[RealPropertyApp getWorkingPath] stringByAppendingString:@".RealProperty.sqlite"] modelName:@"iRealPropertyDataModel" mustExist:YES] == nil)
                return NO;
            return YES;
        }



    - (void)setBarAtBottom:(BOOL)atBottom
        {
            [tabBarController setBarAtBottom:atBottom];
        }



    - (void)switchToProperty:(id)property
        {
            tabBarController.selectedViewController = tabPropertyController;
            RealProperty *controller = (RealProperty *) tabPropertyController;
            [controller validateAndSwitchToParcel:property];
        }

    - (void)switchToGuid:(NSString *)guid
        {
            tabBarController.selectedViewController = tabPropertyController;
            RealProperty *controller = (RealProperty *) tabPropertyController;
            [controller validateAndSwitchToParcel:guid];
        }


    - (void)switchToProperty:(id)property
                    tabIndex:(int)tabIndex
                        guid:(NSString *)guid
        {
            tabBarController.selectedViewController = tabPropertyController;
            RealProperty *controller = (RealProperty *) tabPropertyController;

            [controller validateAndSwitchToParcel:property tabIndex:tabIndex guid:guid];
        }
    - (void)switchToPropertyGuid:(NSString *)property
                    tabIndex:(int)tabIndex
                        guid:(NSString *)guid
        {
            tabBarController.selectedViewController = tabPropertyController;
            RealProperty *controller = (RealProperty *) tabPropertyController;
            [controller validateAndSwitchToParcel:property tabIndex:tabIndex guid:guid];
        }



    - (void)switchToCamera:(id)property
        {
            tabBarController.selectedViewController = tabPropertyController;
            RealProperty *controller = (RealProperty *) tabPropertyController;
            [controller switchToCamera:property];
        }



//
// Go through a list of properties
//
    - (void)switchToProperties
        {
            tabBarController.selectedViewController = tabPropertyController;
            RealProperty *controller = (RealProperty *) tabPropertyController;
            [controller validateAndSwitchToMultipleParcels];
        }



/**
Returns the URL to the application's Documents directory.
*/
    - (NSURL *)applicationDocumentsDirectory
        {
            return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        }



    - (void)    alertView:(UIAlertView *)alertView
didDismissWithButtonIndex:(NSInteger)buttonIndex
        {
            if (alertView == abortAlert)
                {
                    exit(EXIT_FAILURE);
                }
            if (alertView == needToDownload)
                {
                    if (buttonIndex == 0)
                        {
                            [tabBarController switchToNewController:tabOptionsController];          // DBaun: Interesting to watch in Instruments.
                            [(TabOptionsController *) tabOptionsController startAreaManagement];
                        }
                    else if (buttonIndex == 1)
                        {
                            exit(EXIT_SUCCESS);
                        }
                }
        }



    - (void)applicationWillResignActive:(UIApplication *)application
        {
        }



    - (void)applicationDidEnterBackground:(UIApplication *)application
        {
            [self cleanUpZipCache]; // no need to keep the cache around
            timeSwitchToBackground = [NSDate timeIntervalSinceReferenceDate];
        }



    - (void)applicationWillEnterForeground:(UIApplication *)application
        {
        }



    - (void)applicationDidBecomeActive:(UIApplication *)application
        {
            sync = nil;

            if (currentConfig == nil)
                return;

            // Reload config because objects might have deleted
            NSManagedObjectContext *context = [AxDataManager getContext:@"config"];

            currentConfig = [AxDataManager getEntityObject:@"Configuration" andPredicate:[NSPredicate predicateWithFormat:@"1==1"] andContext:context];

            NSString *simpleToken = currentConfig.simpleToken;

            if (![Helper isTokenStillValid:simpleToken])
                {
                    // Need user to login again -- the token has expired
                    partialLogin = YES;
                    [self logUser:YES];
                }
            else
                {
                    if ([NSDate timeIntervalSinceReferenceDate] - timeSwitchToBackground > TIMESWITCHTOBACKGROUND)
                        [self verifyLock];
                }


            [self checkForAreaFilesToMoveFromRootDir];
        }



    - (void)applicationWillTerminate:(UIApplication *)application
        {
        }



// Display the lock screen
    - (void)verifyLock
        {
            KLockScreenController *lockScreen = [[KLockScreenController alloc]
                    initWithLock:NO shouldClearLock:NO];
            lockScreen.view.frame             = CGRectMake(0, 0, 320, 480);
            lockScreen.delegate               = self;
            lockScreen.modalPresentationStyle = UIModalPresentationFormSheet;
            [self.window.rootViewController presentViewController:lockScreen animated:YES  completion:^(void)
                {
                }];

            lockScreen.view.superview.frame = CGRectMake(0, 0, 320, 460);
            CGPoint center = self.window.center;
            if ([Helper isDeviceInLandscape])
                center = CGPointMake(center.y, center.x);
            lockScreen.view.superview.center = center;
        }



// Delegate to validate if the code is correct
    - (BOOL)didSubmitPassCode:(NSString *)code
                    withClear:(BOOL)clear
        {
            NSString *myCode = currentConfig.lockingCode;
            if ([myCode length] == 0)
                return YES;
            if ([myCode compare:code] == NSOrderedSame)
                return YES;
            else
                return NO;
        }



// the user has submitted the right code
    - (void)didSubmitLock:(NSString *)code
        {
        }



    - (void)gridSelectionHasChanged
        {
            RealProperty *controller = (RealProperty *) tabPropertyController;
            [controller moveToMultipleParcels];
        }


#pragma mark - Search manipulation


    - (void)changeSelection:(int)realPropId
                  selection:(BOOL)sel
        {
            [self setupSearchMode];
            // Toggle the selection
            SelectedProperties *selObject = [RealProperty selectedProperties];
            [selObject toggleEntryByRealPropId:realPropId selection:sel];
        }
    -(void)changeSelectionGuid:(NSString *)rpGuid selection:(BOOL)sel
    {
        [self setupSearchMode];
        SelectedProperties *selObject = [RealProperty selectedProperties];
        [selObject toggleEntryByGuId:rpGuid selection:sel];
    }

    - (void)addSelection:(int)realPropId
        {
            [self setupSearchMode];
            // Add a new entry -- the new entry has by default a different color of background
            SelectedProperties *selObject = [RealProperty selectedProperties];
            [selObject addEntryByRealPropId:realPropId];
        }

    -(void)addSelectionGuid:(NSString *)rpGuid
    {
        [self setupSearchMode];
        SelectedProperties *selObject = [RealProperty selectedProperties];
        [selObject addEntryByGuId:rpGuid];
    }

    - (void)removeSelection:(int)realPropId
        {
            [self setupSearchMode];
            // Add a new entry -- the new entry has by default a different color of background
            SelectedProperties *selObject = [RealProperty selectedProperties];
            [selObject removeEntryByRealPropId:realPropId];
        }
    -(void)removeSelectionGuid:(NSString *)rpGuid
    {
        [self setupSearchMode];
        SelectedProperties *selObject = [RealProperty selectedProperties];
        [selObject removeEntryByGuId:rpGuid];
    }

    - (void)addMultipleProperties:(NSArray *)array
        {
            [RealProperty setSelectedProperties:nil];
            [self setupSearchMode];
            SelectedProperties *selObject = [RealProperty selectedProperties];
            [selObject createMultipleEntries:array];
        }



    - (BOOL)isParcelFromMap:(int)realPropId
        {
            SelectedProperties *selObject = [RealProperty selectedProperties];
            return [selObject isFromMap:realPropId];
        }



//
// Create a search if it does not exist
//
    - (void)setupSearchMode
        {
            TabSearchController *searchController = (TabSearchController *) tabSearchController;

            searchController.autoSearch = YES;
            // GridDefaultFromMap
            SelectedProperties *selObject;

            selObject = [RealProperty selectedProperties];

            if (selObject == nil)
                {
                    // We need to create a default search definition
                    SearchDefinition2 *searchDefinition = [searchController.searchBase findDefaultMapDefinition];
                    if (searchDefinition == nil)
                        {
                            NSLog(@"Can't find the definition of Default Map (one search definition must have defaultmap=\"yes\"");
                            return;
                        }

                    GridDefinition *gridDefinition = [EntityBase getGridWithName:searchDefinition.resultRef];
                    selObject = [[SelectedProperties alloc] initWithSearchDefinition:searchDefinition colDefinition:gridDefinition.columns];

                    [RealProperty setSelectedProperties:selObject];
                }
        }


#pragma mark - global colors


    + (UIColor *)requiredBackgroundColor
        {
            UIColor *color = [[UIColor alloc] initWithRed:253.0 / 255.0 green:207 / 255.0 blue:207 / 255.0 alpha:1.0];
            return color;
        }



    + (UIColor *)errorBackgroundColor
        {
            UIColor *color = [[UIColor alloc] initWithRed:255 / 255.0 green:50.0 / 255.0 blue:50.0 / 255.0 alpha:1.0];
            return color;
        }



    + (UIColor *)disabledBackgroundColor
        {
            UIColor *color = [[UIColor alloc] initWithRed:225 / 255.0 green:228 / 255.0 blue:233 / 255.0 alpha:1.0];
            return color;
        }



    + (UIColor *)editableBackgroundColor
        {
            return [UIColor whiteColor];
        }


#pragma mark - TabBarControllerDelegate


    - (void)tabBardidSelectViewController:(UIViewController *)viewController
        {
            if ([viewController respondsToSelector:@selector(activateController)])
                {
                    [viewController performSelector:@selector(activateController)];
                    
                }
        }



    - (void)tabBarWillSwitchController:(UIViewController *)viewController
        {
            if ([viewController respondsToSelector:@selector(tabBarWillSwitchController)])
                {
                    [viewController performSelector:@selector(tabBarWillSwitchController)];
                }
        }



    - (BOOL)tabBarShoudSwitchController:(UIViewController *)viewController
        {
            if ([viewController respondsToSelector:@selector(tabBarShoudSwitchController)])
                {
                    id result = [viewController performSelector:@selector(tabBarShoudSwitchController)];

                    if ([result intValue] != 0)
                        return YES;
                    else
                        {
                            return NO;
                        }
                }
            return YES;
        }


#pragma mark - Synchronizator Manager


    - (void)loadSyncManager
        {
            if (syncManager == nil)
                {
                    NSString      *serviceURL = [RealPropertyApp getDataUrl];
                    Configuration *config     = [RealPropertyApp getConfiguration];
                    syncManager = [[SyncManager alloc] initWithServiceURL:serviceURL securityToken:config.simpleToken];
                    syncManager.delegate = self;
                }
        }



	//   ..........SAMPLE OF PARAMETERS TO THIS METHOD..........
	//
	//   container 		 = Area02
	//   destinationPath = /Users/davidbaun/Library/Application Support/iPhone Simulator/7.1/Applications/8A2A07B6-725C-4FC2-ADD6-29A398ECEB1C/Documents/Area02/Area02.layers.xml
	//   fileName 		 = Area02.layers.xml
	//   callBackObj 	 = DownloadFiles
	//  	DownloadFiles currentContainer.name  = Area02
	//  	DownloadFiles currentBlob.name       = Area02.layers.xml
	//  	DownloadFiles currentBlob.URL        = http://irealproperty.blob.core.windows.net/area02/Area02.layers.xml
	//  	DownloadFiles updateCommon           = NO
	//
    - (void)downloadAzureFile:(NSString *)fileName
                  inContainer:(NSString *)container
                       toPath:(NSString *)destinyPath
               withFileLength:(int64_t)fileLength
          andResumingDownload:(BOOL)resumeDownload
            andCallBackObject:(NSObject *)callBackObj
        {

            [DaveGlobals debugParameters:(NSDictionary *) [[NSDictionary alloc]
                    initWithObjectsAndKeys:fileName, @"fileName", container, @"container", destinyPath, @"destinationPath", (resumeDownload ? @"YES" : @"NO"), @"resumeDownload", callBackObj, @"callBackObj", nil]
                        withTitleMessage:@"* Arguments to [RealPropertyApp downloadAzureFile]"];

            [self loadSyncManager];

            syncMgrCallBackObj = callBackObj; // currently this is DownloadFiles

            [syncManager downloadFileFromAzure:fileName inContainer:container withFileLength:fileLength toThisPath:destinyPath resumingDownload:resumeDownload];
        }



    - (void)cancelAzureFileDownload
        {
            if (syncManager != nil)
                {
                    [syncManager cancelDownloadAzureFile];
                }
        }



    - (void)downloadAzureFileDidFail:(SyncManager *)sm
                           withError:(NSError *)error
        {
            if ([syncMgrCallBackObj respondsToSelector:@selector(downloadAzureFileDidFailWithError:)])
                [syncMgrCallBackObj performSelector:@selector(downloadAzureFileDidFailWithError:) withObject:error];
            syncMgrCallBackObj = nil;
        }



    - (void)downloadAzureFileDidReceiveData:(SyncManager *)sm
        {
            if ([syncMgrCallBackObj respondsToSelector:@selector(downloadAzureFileDidReceiveDataWithLength:)])
                {
                    NSNumber *dataLength = [NSNumber numberWithFloat:sm.floatReceivedData];
                    [syncMgrCallBackObj performSelector:@selector(downloadAzureFileDidReceiveDataWithLength:) withObject:dataLength];
                }
        }



    - (void)downloadAzureFileDidLoadData:(SyncManager *)sm
        {
            if ([syncMgrCallBackObj respondsToSelector:@selector(downloadAzureFileDidLoadData)])
                {
                    [syncMgrCallBackObj performSelector:@selector(downloadAzureFileDidLoadData)];
                }
        }


#pragma mark - Synchronizator deletates

    - (void)synchronizatorRequestDidFail:(Synchronizator *)s
                               withError:(NSError *)error
        {
            [s unload];
            TabSyncController *tabSync = (TabSyncController *) tabSyncController;
            tabSync.syncLabel.text = @"";
            [tabSync stopSyncIndicators];
            //5/5/16 cv Raise error regardless the source
            if (error != nil)
                {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sync Errors" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
                
                onlyOneAlert = NO;
                }
            // Reset timer
            [[UIApplication sharedApplication] setIdleTimerDisabled:NO];

        }

    - (void)synchronizatorRequestDidFailByValidationErrors:(Synchronizator *)s
                                              withSyncGuid:(NSString *)syncGuid
                                                 andErrors:(NSArray *)errors
        {
            [self synchronizatorDownloadEntitiesDone:s];
            [TabBookmarkController updateBookmarkErrors];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sync Errors" message:@"Please check the bookmark tab or the Sync tab for more details." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            onlyOneAlert = YES;
            [alert show];

        }



    - (void)synchronizatorDownloadEntitiesDone:(Synchronizator *)s
        {
            [s unload];

            TabSyncController *tabSync = (TabSyncController *) tabSyncController;
            tabSync.syncLabel.text = @"";

            [tabSync stopSyncIndicators];
            // Reset timer
            [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
        }



    - (void)indicatorMessage:(NSString *)message
        {
            TabSyncController *tabSync = (TabSyncController *) tabSyncController;
            [tabSync indicatorMessage:message];

        }


#pragma mark - Automatic download sync


    - (BOOL)isSyncing
        {
            if (sync == nil)
                return NO;
            return sync.downloadSyncInProgress;
        }



//
// This method is called regularly. Find out if enough time has expired before doing sync
//
    - (void)checkForChangedAzureFiles:(NSTimer *)timer
        {
            if (isUserLoggedInTestMode)
                return;     // no sync up for test users

            NSString *status = [RealPropertyApp reachNetwork];
            if ([status length] > 0)
                {
                    NSLog(@"Not checking azure for changed files for '%@' because network is not reachable", currentConfig.currentArea);
                    return;
                }


            NSTimeInterval now           = [[NSDate date] timeIntervalSinceReferenceDate];    // reference date
            NSTimeInterval lastCheckTime = currentConfig.lastCheckinAzureTime;

            if (now - lastCheckTime > DOWNLOADSYNC_AZURE)
                {
                    NSLog(@"Checking azure for changed files on timer for '%@' because now - lastCheckTime > DOWNLOADSYNC_AZURE is true.", currentConfig.currentArea);
                    [theFileStatusChecker checkForChangedFilesInAreaAndNotifyDelegate:self];
                    currentConfig.lastCheckinAzureTime = [[NSDate date] timeIntervalSinceReferenceDate];
                    return;
                }
            else
                    NSLog(@"Not going to check azure for changed files in '%@' on timer because not enough time elapsed yet.", [Helper versionSpecificContainerName:currentConfig.currentArea]);

/*
            // DBaun 2013-09-28 This is going to remain commented out per discussion with Hoang.
            // DBaun 2013-09-29 BUGFIX: This next line was trying to get the syncdate from the wrong database context.
            NSTimeInterval lastDownloadTime = [RealPropertyApp getLastSyncDate:[AxDataManager defaultContext]];
            if (now - lastDownloadTime < AZUREAUTOMDOWNLOAD_TIMER_DELAY)
                {
                    return;
                }

            [self downloadSync];
*/
        }



    - (void)downloadSync
        {
            // Something else is going on
            if (![RealPropertyApp allowToSync])
                return;

            // network is not reachable via WiFi
            NSString *status = [RealPropertyApp reachNetwork];

            if ([status length] > 0)
                return;

            TabSyncController *syncController = (TabSyncController *) tabSyncController;

            [syncController startSyncIndicators:@"Downloading"];

            @try
                {
                    // do a first sync
                    if (sync == nil)
                        {
                            sync = [[Synchronizator alloc] init:[RealPropertyApp getDataUrl]];
                            sync.delegate = self;
                            Configuration *configuration = [RealPropertyApp getConfiguration];
                            sync.forceRestart   = NO;
                            sync.securityToken  = configuration.simpleToken;
                            sync.blobServiceURL = [RealPropertyApp getBlobUrl];
                            sync.area           = [[RealPropertyApp getWorkingArea] substringFromIndex:4];
                            NSArray  *paths             = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                            NSString *documentDirectory = [paths objectAtIndex:0];
                            NSString *imageDBPath  = [documentDirectory stringByAppendingFormat:@"/%@.Media.sqlite", [RealPropertyApp getWorkingPath]];
                            sync.imageDatabasePath = imageDBPath;
                        }
                    if (!sync.downloadSyncInProgress)
                        {
                            [sync performSelectorInBackground:@selector(executeAutomaticDownload) withObject:nil];
                        }
                    else
                        {
                            [self synchronizatorDownloadEntitiesDone:sync];
                        }
                }
            @catch (NSException *exception)
                {
                    NSLog(@"Exception in download=%@", exception);
                }
        }



    - (void)fireDownloadSync
        {
            [self downloadSync];
        }


#pragma mark - Number of files that have changed in the current area (on Azure)


    - (void)updateUIWithChangedETagsInfo:(int)count
        {
            if (count == 0)
                [tabBarController removeBadgeFromTab:6];
            else
                [tabBarController addBadgeToTab:6 value:count];

            countOfChangedAzureFiles = count;

            /* DBaun 10/24/13 08:39am
                THE PURPOSE OF THIS CODE IS BECAUSE IF YOU'RE CURRENTLY SITTING ON THE OPTIONS PAGE
                THE OPTIONS BUTTON TEXT WON'T BE UPDATED BECAUSE NOTHING CALLS IT.  ONLY THIS METHOD
                IS BEING CALLED BY THE BACKGROUND TASK.  SO WHAT THIS DOES IS CHECKS IF YOU'RE ON THE
                TAB OPTIONS PAGE AND IF SO UPDATES THE TEXT ON THE OPTIONS TAB PAGE SO IT STAYS IN
                SYNC WITH THE NUMBER OF UPDATES SHOWN ON THE TAB BAR BADGE.
            */

            TabOptionsController *theTabOptionsPage = (TabOptionsController *) self.tabOptionsController;
            [theTabOptionsPage.optionsList updateUIWithChangedETagsInfo:count];
        }



#pragma mark - Files management


    - (NSArray *)checkForAreaFilesToMoveFromRootDir
        {
            // Get all the files that starts with "Area" in the top directory
            NSArray *filesToMove = [Helper findAllFiles:@"Area" directory:@""];

            // Well, move all the files in the appropriate directory
            for (NSString *fileName in filesToMove)
                {
                    // the file should start by area followed by a number
                    NSRange range = [fileName rangeOfString:@"Area"];
                    int     area  = [[fileName substringFromIndex:range.location + range.length] intValue];
                    // Create a directory if it does not exist
                    NSString *dir = [NSString stringWithFormat:@"Area%02d", area];

                    [Helper createDirectory:dir];
                    // Move the file from top directory
                    [Helper moveFile:fileName to:[dir stringByAppendingPathComponent:fileName]];
                }
            [[AxDataManager configContext] save:nil];
            return filesToMove;
        }



    - (void)createETagsForRootDirAreaFiles:(NSArray *)filesToMove
        {
            if ([filesToMove count] != 0)
                {

                    NSString      *areaName = @"";
                    for (NSString *fileName in filesToMove)
                        {
                            // the file should start by area followed by a number
                            NSRange range = [fileName rangeOfString:@"Area"];
                            int     area  = [[fileName substringFromIndex:range.location + range.length] intValue];

                            // Build the name of the AreaXX directory
                            NSString *dir = [NSString stringWithFormat:@"Area%02d", area];

                            if ([areaName caseInsensitiveCompare:dir] != NSOrderedSame)
                                {
                                    areaName = dir;
                                    [syncFiles createETags:[areaName lowercaseString] andDownloadFiles:NO];
                                }

                        }
                }

        }



    - (void)verifyNecessaryAreaFilesArePresent
        {
            NSArray *files = [[NSArray alloc] initWithObjects:
                                                      @"LabelSets.xml",
                                                      @"layers.sqlite",
                                                      @"layers.xml",
                                                      @"menuStructure.xml",
                                                      @"Media.sqlite",
                                                      @"RealProperty.sqlite",
                                                      @"Renderers.xml",
                                                      @"tiles",
                                                      nil];

            NSString      *missingFiles = @"";
            for (NSString *file in files)
                {
                    NSString *fileName = [NSString stringWithFormat:@"%@.%@", workingDirectory, file];
                    if (![Helper checkFileExist:fileName])
                        {
                            missingFiles = [missingFiles stringByAppendingString:[NSString stringWithFormat:@" %@.%@", workingArea, file]];
                        }
                }
            if ([missingFiles length] > 0)
                {
                    NSString *message = [NSString stringWithFormat:@"The files (%@) are missing. Continue to download the files or Quit to copy the files using iTunes", missingFiles];
                    needToDownload    = [[UIAlertView alloc] initWithTitle:@"Missing Files" message:message delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:@"Quit", nil];
                    [needToDownload show];
                }
        }


#pragma mark - the different working URLs


    + (void)loginAsTester:(BOOL)value
        {
            isUserLoggedInTestMode = value;
        }



    + (BOOL)isUserLoggedInTestMode
        {
            return isUserLoggedInTestMode;
        }



    + (BOOL)cancelTestUser
        {
            // 9/12/13 HNN allow in test mode
//    if(isUserLoggedInTestMode)
//    {
//        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Not Available" message:@"This function is not available in test mode." delegate:nil cancelButtonTitle:@"Continue" otherButtonTitles: nil];
//        [alertView show];
//        return YES;
//    }
            return NO;
        }



    + (NSString *)getDataUrl
        {
            NSString     *path      = [[NSBundle mainBundle] pathForResource:@"Properties" ofType:@"plist"];
            NSDictionary *plistData = [NSDictionary dictionaryWithContentsOfFile:path];

            if (isUserLoggedInTestMode)
                return [plistData valueForKey:@"DataServiceTestURL"];
            else
                return [plistData valueForKey:@"DataServiceProductionURL"];

            // DBaun NOTE: FOR MY OWN TESTING, I HAVE TO RETURN THIS WEB ADDRESS HARDCODED TO GET AROUND THE PROPERTIES.PLIST IN THE SIMULATOR BUNDLE WHICH APPARENTLY I CANNOT DIRECTLY REPLACE.
            //return @"https://info.kingcounty.gov/Assessor/iRealPropertyProxy/iRealPropertyProxy.svc";
            //return @"https://info.kingcounty.gov/Assessor/iRealPropertyProxy/iRealPropertyProxy.svc";

        }



    + (NSString *)getBlobUrl
        {
            NSString     *path      = [[NSBundle mainBundle] pathForResource:@"Properties" ofType:@"plist"];
            NSDictionary *plistData = [NSDictionary dictionaryWithContentsOfFile:path];

            if (isUserLoggedInTestMode)
                return [plistData valueForKey:@"BlobServiceTestURL"];
            else
                return [plistData valueForKey:@"BlobServiceProductionURL"];
        }


#pragma mark - iRealProperty data helper


    + (double)getLastSyncDate:(NSManagedObjectContext *)context
        {
            double resultValue = 0.0;

            NSArray *syncDateArray = [AxDataManager dataListEntity:@"DatabaseDate" andPredicate:nil andSortBy:@"lastUpdateDate" sortAscending:YES withContext:context];
            if ([syncDateArray count] > 0)
                {
                    DatabaseDate *syncDate = [syncDateArray objectAtIndex:0];
                    resultValue = syncDate.lastUpdateDate;
                }
            return resultValue;
        }



    - (NSString *)description
        {
            NSMutableString *outputString;
            outputString = [[NSMutableString alloc] initWithCapacity:250];

            [outputString appendString:@"\n*** [RealPropertyApp description] ***\n"];
            [outputString appendFormat:@"newInstall       = %@\n", (newInstall ? @"YES" : @"NO")];
            [outputString appendFormat:@"partialLogin     = %@\n", (partialLogin ? @"YES" : @"NO")];
            [outputString appendFormat:@"allowToSync      = %@\n", (allowToSync ? @"YES" : @"NO")];
            [outputString appendFormat:@"reachNetwork     = %@\n", ([[RealPropertyApp reachNetwork] length] > 0 ? @"YES" : @"NO")];
            [outputString appendFormat:@"workingArea      = %@\n", workingArea];
            [outputString appendFormat:@"workingDirectory = %@\n", workingDirectory];
            [outputString appendString:@"\n"];
            [outputString appendString:[currentConfig description]];

            return outputString;
        }


@end


