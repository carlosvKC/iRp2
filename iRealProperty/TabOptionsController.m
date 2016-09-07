#import "TabOptionsController.h"
#import "EntityBase.h"
#import "RealPropertyApp.h"
#import "Helper.h"


@implementation TabOptionsController

    @synthesize mainView;
    @synthesize optionsLeftView;
    @synthesize optionsListView;
    @synthesize optionsList;

#pragma mark - menubar delegate
    - (void)menuBarBtnBackSelected
        {
        }



    - (void)menuBarBtnSelected:(int)tag
        {
        }



    - (void)changeLock
        {
            KLockScreenController *lockScreen = [[KLockScreenController alloc]
                    initWithLock:YES shouldClearLock:YES];
            lockScreen.view.frame             = CGRectMake(0, 0, 320, 480);
            lockScreen.delegate               = self;
            lockScreen.modalPresentationStyle = UIModalPresentationFormSheet;
            [self presentViewController:lockScreen animated:YES completion:^(void)
                {
                }];

            lockScreen.view.superview.frame = CGRectMake(0, 0, 320, 460);
            CGRect  frame  = [Helper getScreenBoundsForCurrentOrientation];
            CGPoint center = CGPointMake(frame.size.width / 2, frame.size.height / 2);
            if ([Helper isDeviceInLandscape])
                center = CGPointMake(center.y, center.x);
            lockScreen.view.superview.center = center;
        }

#pragma mark - View lifecyle
    - (id)initWithNibName:(NSString *)nibNameOrNil
                   bundle:(NSBundle *)nibBundleOrNil
        {
            self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
            if (self)
                {
                    self.title            = @"Options";
                    self.tabBarItem.image = [UIImage imageNamed:@"20-gear2"];
                }
            return self;
        }



    - (void)viewDidLoad
        {
            [super viewDidLoad];
            Options *options = [EntityBase getOptionsDefinition:@"settings"];

            _optionsList = [[OptionsList alloc] initWithNibName:@"OptionsList" withOptions:options];
            [optionsListView addSubview:_optionsList.tableView];
            _optionsList.tableView.frame = CGRectMake(0, 0, optionsListView.frame.size.width, optionsListView.frame.size.height);
            _optionsList.itsController   = self;
            [self addChildViewController:_optionsList];

            _leftOption = [[LeftOption alloc] initWithNibName:@"LeftOption" bundle:nil];
            [optionsLeftView addSubview:_leftOption.tableView];
            _leftOption.tableView.frame = CGRectMake(0, 0, optionsLeftView.frame.size.width, optionsLeftView.frame.size.height);
            [self addChildViewController:_leftOption];
            /**/

            UIView *view = [self.view viewWithTag:1010];
            if (view == nil)
                {
                    NSLog(@"MenuBar: can't find the view with tag 1010");
                    return;
                }
            menuBar = [[ControlBar alloc] initWithNibName:@"TabOptionsControlBar" bundle:nil];
            [view addSubview:menuBar.view];
            [self addChildViewController:menuBar];
            menuBar.delegate = self;

            _optionsList.menuBar = menuBar;

            self.optionsList = _optionsList;

            if ([Helper isDeviceInLandscape])
                [self willRotateToInterfaceOrientation:UIInterfaceOrientationLandscapeLeft duration:0];
            else
                [self willRotateToInterfaceOrientation:UIInterfaceOrientationPortrait duration:0];
        }



    - (void)viewDidUnload
        {
            [self setOptionsListView:nil];
            menuBar = nil;
            [self setOptionsLeftView:nil];
            [self setMainView:nil];
            [super viewDidUnload];
        }



    - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
        {
            return YES;
        }



    - (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                    duration:(NSTimeInterval)duration
        {
            if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
                {
                    UIView *view = [self.view viewWithTag:1010];
                    view.frame            = CGRectMake(0, 0, 1024, 44);
                    mainView.frame        = CGRectMake(0, 0, 1024, 748);
                    optionsListView.frame = CGRectMake(258, 44, 766, 656);
                    optionsLeftView.frame = CGRectMake(0, 44, 257, 656);
                }
            else
                {
                    UIView *view = [self.view viewWithTag:1010];
                    view.frame            = CGRectMake(0, 0, 768, 44);
                    mainView.frame        = CGRectMake(0, 0, 768, 1004);
                    optionsListView.frame = CGRectMake(258, 44, 510, 912);
                    optionsLeftView.frame = CGRectMake(0, 44, 257, 912);
                }
        }



    - (void)startAreaManagement
        {
            [_optionsList startAreaManagement];
        }


#pragma - lock code delegate


    - (BOOL)didSubmitPassCode:(NSString *)code
                    withClear:(BOOL)clear
        {
            Configuration *config = [RealPropertyApp getConfiguration];
            if ([code compare:config.lockingCode] == NSOrderedSame)
                return YES;
            return NO;
        }



    - (void)didSubmitLock:(NSString *)code
        {
            Configuration *config = [RealPropertyApp getConfiguration];
            config.lockingCode = code;
            [[AxDataManager configContext] save:nil];
        }



    - (void)activateController
        {
            [_optionsList activateController];
        }


#pragma - sync


    - (void)syncNow
        {
            if ([RealPropertyApp cancelTestUser])
                {
                    return;
                }

            RealPropertyApp *app = (RealPropertyApp *) [[UIApplication sharedApplication] delegate];
            if ([app isSyncing])
                {
                    UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"Sync in progress" message:@"There is another synchronization in progress. Please wait before trying again." delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
                    [view show];
                    return;
                }

            // network is not reacheable via WiFi
            NSString *errorMsg = [RealPropertyApp reachNetwork];

            if ([errorMsg length] > 0)
                {
                    UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"No Network" message:errorMsg delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                    [view show];
                    return;
                }
            @try
                {
                    [RealPropertyApp allowToSync:NO];

                    sync = [[Synchronizator alloc] init:[RealPropertyApp getDataUrl]];
                    sync.delegate = self;

                    Configuration *configuration = [RealPropertyApp getConfiguration];

                    sync.forceRestart   = NO;
                    sync.securityToken  = configuration.simpleToken;
                    sync.blobServiceURL = [RealPropertyApp getBlobUrl];
                    sync.area           = [[RealPropertyApp getWorkingArea] substringFromIndex:4];
                    NSArray  *paths             = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                    NSString *documentDirectory = [paths objectAtIndex:0];
                    NSString *imageDBPath       = [documentDirectory stringByAppendingFormat:@"/%@.Media.sqlite", [RealPropertyApp getWorkingPath]];
                    sync.imageDatabasePath = imageDBPath;

                    [sync performSelectorInBackground:@selector(executeAutomaticDownload) withObject:nil];
                    

                    // Create a temp window to block any input
                    RealPropertyApp  *app        = (RealPropertyApp *) [[UIApplication sharedApplication] delegate];
                    UIViewController *controller = app.window.rootViewController;

                    navView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 1024)];
                    navView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
                    navView.opaque          = NO;

                    [controller.view addSubview:navView];
                    [controller.view bringSubviewToFront:navView];

                    ATActivityIndicator *indicator = [ATActivityIndicator currentIndicator];
                    [indicator displayActivity:@"Getting Changes"];

                    // Stop putting iPad to sleep
                    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];


                }
            @catch (NSException *exception)
                {
                    NSLog(@"Exception in download=%@", exception);
                }

        }
#pragma mark - Synchronizator deletates
    - (void)cleanUp
        {
            [[ATActivityIndicator currentIndicator] hide];
            [navView removeFromSuperview];
            navView = nil;
            [RealPropertyApp allowToSync:YES];
        }



    - (void)indicatorMessage:(NSString *)message
        {
            ATActivityIndicator *indicator = [ATActivityIndicator currentIndicator];
            [indicator displayActivity:message];
        }



    - (void)synchronizatorRequestDidFail:(Synchronizator *)s
                               withError:(NSError *)error
        {
            [s unload];
            [self cleanUp];
            [_optionsList.tableView reloadData];
            if (![error.localizedDescription isEqualToString:@"Server error."]) {
                UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"Sync Error" message:[NSString stringWithFormat:@"%@", error] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [view show];
            }
            else
            {NSLog(@"Error Download Changes %@", [error localizedDescription]);}
            // Reset timer
            [[UIApplication sharedApplication] setIdleTimerDisabled:NO];

        }



    - (void)synchronizatorRequestDidFailByValidationErrors:(Synchronizator *)s
                                              withSyncGuid:(NSString *)syncGuid
                                                 andErrors:(NSArray *)errors
        {
            [self cleanUp];
            UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"Sync Error" message:@"Please check the bookmark or the sync tab for validation errors." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [view show];
        }



    - (void)synchronizatorDownloadEntitiesDone:(Synchronizator *)s
        {
            [s unload];
            // get the time to refresh the cells
            [_optionsList.tableView reloadData];

            [self cleanUp];
            UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"Sync Complete!" message:@"Synchronization complete!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [view show];
            // Reset timer
            [[UIApplication sharedApplication] setIdleTimerDisabled:NO];

        }

@end
