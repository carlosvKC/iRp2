#import "TabSyncController.h"
#import "Helper.h"
#import "Configuration.h"
#import "RealPropertyApp.h"
#import "SyncCustomCell.h"
#import "SyncInformation.h"
#import "OpenEntity.h"


@implementation TabSyncController

    @synthesize activityLabel;
    @synthesize activityIndicator;
    @synthesize bookmarkError;
    @synthesize syncTableView;
    @synthesize syncLastDate;
    @synthesize syncDate;
    @synthesize syncWarning;
    @synthesize syncLabel;
    @synthesize syncProgressBar;
    @synthesize syncStarted; // 8/21/13 HNN need to prevent double taps of sync button to start another sync

    - (id)initWithNibName:(NSString *)nibNameOrNil
                   bundle:(NSBundle *)nibBundleOrNil
        {
            self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
            if (self)
                {
                    self.title            = @"Sync";
                    self.tabBarItem.image = [UIImage imageNamed:@"sync"];
                }
            return self;
        }



    - (void)didReceiveMemoryWarning
        {
            [super didReceiveMemoryWarning];

        }

#pragma mark - Request the lock before accessing this area

#pragma mark - View lifecycle

    - (void)viewDidLoad
        {
            [super viewDidLoad];
            // Do any additional setup after loading the view, typically from a nib
            if (sync == nil)
                {
                    sync = [[Synchronizator alloc] init:[RealPropertyApp getDataUrl]];
                    sync.delegate = self;
                }
            [self updateSyncInfo];

            syncWarning.hidden     = YES;
            syncProgressBar.hidden = YES;
            syncLabel.hidden       = NO;
            bookmarkError.hidden   = YES;

            UIView   *view = [self.view viewWithTag:1000];
            UIButton *btn  = [Helper createBlueButton:view.frame withTitle:@"Synchronize Changes"];
            btn.tag = 1000;
            [view removeFromSuperview];
            [self.view addSubview:btn];
            [btn addTarget:self action:@selector(startSyncPressed:) forControlEvents:UIControlEventTouchUpInside];

            view = [self.view viewWithTag:1001];
            btn  = [Helper createRedButton:view.frame withTitle:@"View Sync Errors"];
            btn.tag = 1001;
            [view removeFromSuperview];
            [self.view addSubview:btn];
            [btn addTarget:self action:@selector(displayWarningErrors:) forControlEvents:UIControlEventTouchUpInside];
            [self activateController];

            activityLabel.hidden     = YES;
            activityIndicator.hidden = YES;
        }



    - (void)updateSyncInfo
        {
            if (inSync)
                return;
            activity = [ATActivityIndicator currentIndicator];
            [activity displayActivity:@"Getting Sync Info"];
            [sync executeGetEntityListToUpload];
        }



    - (void)countErrors
        {
            int errors = [AxDataManager countEntities:@"SyncValidationError" andContext:[AxDataManager configContext]];
            UIButton *btn = (UIButton *) [self.view viewWithTag:1001];
            if (errors > 0)
                btn.hidden = NO;
            else
                btn.hidden = YES;

        }



    - (void)viewDidUnload
        {
            [self setActivityIndicator:nil];
            [self setActivityLabel:nil];
            [self setBookmarkError:nil];
            [self setSyncWarning:nil];
            [self setSyncDate:nil];
            [self setSyncLastDate:nil];
            [self setSyncTableView:nil];
            [self setSyncProgressBar:nil];
            [self setSyncLabel:nil];
        }



    - (void)viewWillAppear:(BOOL)animated
        {
            [super viewWillAppear:animated];
        }



    - (void)viewDidAppear:(BOOL)animated
        {
            [super viewDidAppear:animated];
        }



    - (void)viewWillDisappear:(BOOL)animated
        {
            [super viewWillDisappear:animated];
        }



    - (void)viewDidDisappear:(BOOL)animated
        {
            [super viewDidDisappear:animated];
        }



    - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
        {
            return YES;
        }



    - (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                    duration:(NSTimeInterval)duration
        {
            UIView *view;
            if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
                {
                    self.view.frame     = CGRectMake(0, 0, 1024, 768);
                    syncTableView.frame = CGRectMake(36, 410, 956, 258);

                    // move the other objects
                    view = [self.view viewWithTag:1500];
                    view.frame = CGRectMake(260, 64, 238, 31);
                    view = [self.view viewWithTag:1501];
                    view.frame = CGRectMake(506, 64, 316, 31);
                    view = [self.view viewWithTag:1000];
                    view.frame = CGRectMake(361, 129, 302, 41);
                    view = [self.view viewWithTag:1502];
                    view.frame = CGRectMake(291, 196, 444, 36);
                    view = [self.view viewWithTag:1503];
                    view.frame = CGRectMake(27, 258, 963, 9);
                    view = [self.view viewWithTag:1504];
                    view.frame = CGRectMake(286, 275, 444, 36);
                    view = [self.view viewWithTag:1001];
                    view.frame = CGRectMake(361, 328, 302, 41);
                }
            else
                {
                    self.view.frame     = CGRectMake(0, 0, 768, 1024);
                    syncTableView.frame = CGRectMake(36, 410, 698, 522);

                    view = [self.view viewWithTag:1500];
                    view.frame = CGRectMake(117, 64, 238, 31);
                    view = [self.view viewWithTag:1501];
                    view.frame = CGRectMake(363, 64, 316, 31);
                    view = [self.view viewWithTag:1000];
                    view.frame = CGRectMake(233, 138, 302, 41);
                    view = [self.view viewWithTag:1502];
                    view.frame = CGRectMake(162, 203, 444, 36);
                    view = [self.view viewWithTag:1503];
                    view.frame = CGRectMake(27, 258, 697, 9);
                    view = [self.view viewWithTag:1504];
                    view.frame = CGRectMake(153, 267, 444, 36);
                    view = [self.view viewWithTag:1001];
                    view.frame = CGRectMake(233, 327, 302, 41);
                }
        }



//
// This method is called by Synchronizator delegate when the the entity list to update is generated.
//
    - (void)synchronizatorGetEntityListToUploadDone:(NSArray *)entitiesToUpload
                                       lastSyncDate:(NSDate *)lastSyncDate
        {
            [activity hide];
            NSString *dateString;
            if (lastSyncDate != nil)
                {
                    NSTimeInterval ti = [NSDate timeIntervalSinceReferenceDate] - [lastSyncDate timeIntervalSinceReferenceDate];

                    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                    [dateFormat setDateFormat:@"h:mm a"];
                    NSString *ds = [dateFormat stringFromDate:lastSyncDate];

                    if (ti < 60)
                        dateString = @"Up to date";
                    else if (ti <= 30 * 60) // less than 30 minutes
                        dateString = [NSString stringWithFormat:@"%d min ago at %@", (int) rintf(ti / 60), ds];
                    else
                        {
                            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                            [dateFormat setDateFormat:@"EEEE MMMM d, YYYY"];
                            dateString = [NSString stringWithFormat:@"%@ at %@", [dateFormat stringFromDate:lastSyncDate], ds];
                        }
                }
            else
                {
                    dateString = @"Not synchronized yet";
                }
            syncDate.text = dateString;
            [syncTableView reloadData];
        }



    - (IBAction)startSyncPressed:(id)sender
        {
            // 8/21/13 HNN prevent double taps from starting additional sync
            if (syncStarted == YES)
                return;
            syncStarted = YES;

            // verify that there is no pending change
            RealProperty *realProperty = [RealProperty instance];

            if (realProperty.isDirty)
                {
                    RealPropInfo *info = [RealProperty realPropInfo];

                    NSString *message = [NSString stringWithFormat:@"The property '%@-%@' has unsaved changes. Please save or cancel the changes before doing a synchronization", info.major, info.minor];

                    UIAlertView *alertBox = [[UIAlertView alloc] initWithTitle:@"Unsaved Data" message:message delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
                    [alertBox show];
                    syncStarted = NO;
                    return;
                }
            // verify that there is no DoNotSynch Bookmark
            // cv 10/02/14 Do not include mark x deletion bookmarks
            //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(rowStatus <> 'D' AND descr = ("Do not synchronize"))"];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(rowStatus <> 'D' AND typeItemId = 9)"];

            // Add all the bookmarks to the scroll view -- ordered by the date they were added
            NSArray *bookmarks = [AxDataManager dataListEntity:@"Bookmark" andPredicate:predicate andSortBy:@"addedDate" sortAscending:NO withContext:[AxDataManager defaultContext ]];
            
            if (bookmarks.count > 0)
            {                
                NSString *message = [NSString stringWithFormat:@"Do not Synch Bookmark apply. Please delete Bookmark before doing a synchronization"];
                
                UIAlertView *alertBox = [[UIAlertView alloc] initWithTitle:@"Do not Synch Bookmark" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertBox show];
                syncStarted = NO;
                return;
            }
            NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"(rowStatus <> 'D' AND typeItemId > 99)"];
            
            // Add all the bookmarks to the scroll view -- ordered by the date they were added
            NSArray *bookmarks2 = [AxDataManager dataListEntity:@"Bookmark" andPredicate:predicate2 andSortBy:@"addedDate" sortAscending:NO withContext:[AxDataManager defaultContext ]];
            
            if (bookmarks2.count > 0)
            {
                NSString *message = [NSString stringWithFormat:@"Error Bookmarks apply. Please delete error Bookmark before doing a synchronization"];
                
                UIAlertView *alertBox = [[UIAlertView alloc] initWithTitle:@"Bookmark errors" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertBox show];
                syncStarted = NO;
                return;
            }
            

            // 2/25/13 HNN allow synch testing in dev/test environment since we're hitting a different database
            //    if([RealPropertyApp cancelTestUser])
            //    {
            //        return;
            //    }
            if (syncWarning.hidden == NO)
                {
                    syncStarted = NO;
                    return;
                }

            NSString *error = [RealPropertyApp reachNetwork];

            if ([error length] > 0)
                {
                    UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"No Network" message:error delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [view show];
                    syncStarted = NO;
                    return;
                }


            RealPropertyApp *app = (RealPropertyApp *) [[UIApplication sharedApplication] delegate];
            if ([app isSyncing])
                {
                    UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"Sync in progress" message:@"There is another synchronization in progress. Please wait before trying again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [view show];
                    syncStarted = NO;
                    return;
                }

            [self startSyncIndicators:@"Start Sync"];

            [self syncStart];

            Configuration *configuration = [RealPropertyApp getConfiguration];
            syncLabel.text = [NSString stringWithFormat:@"Synchronizing %d changes to the server", [self countChanges]];

            [syncProgressBar setProgress:0.0 animated:true];
            sync.forceRestart   = NO;
            sync.securityToken  = configuration.simpleToken;
            sync.blobServiceURL = [RealPropertyApp getBlobUrl];
            sync.area           = [[RealPropertyApp getWorkingArea] substringFromIndex:4];


            NSArray  *paths             = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentDirectory = [paths objectAtIndex:0];
            NSString *imageDBPath       = [documentDirectory stringByAppendingFormat:@"/%@.Media.sqlite", [RealPropertyApp getWorkingPath]];
            sync.imageDatabasePath = imageDBPath;
            [sync performSelectorInBackground:@selector(executeFullSyncCircle:) withObject:sync.entitiesToSync];

            syncWarning.hidden = NO;
            // Stop the timer to avoid stopping the iPad
            [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
            syncStarted = NO;

        }



    - (int)countChanges
        {
            int count = 0;
            for (SyncInformation *syncEnt in sync.entitiesToSync)
                //check for Sale & saleVerif
//                if (![syncEnt.syncEntityName isEqualToString:@"SaleVerif"]) {
//                }
                count += syncEnt.numberOfEntitiesToSync;
            return count;
        }



    - (void)synchronizatorRequestDidFail:(Synchronizator *)s
                               withError:(NSError *)error
        {
           // [Helper alertWithOk:@"communication with the sync server failed." message:error.description];
            [self stopSyncIndicators];
            activity = [ATActivityIndicator currentIndicator];
            [activity hide];
            [self stopAllAnimationsInList];
             syncLabel.text  = [NSString stringWithFormat:@"%@ (%@)", @"communication with the sync server failed. Please try again.", error.description];
            
            //syncLabel.text         = @"The communication with the sync server failed. Please try again.";
            syncWarning.hidden     = YES;
            syncProgressBar.hidden = YES;

            alert = [[UIAlertView alloc] initWithTitle:@"Communication Error" message:syncLabel.text delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            // Reset timer
            [[UIApplication sharedApplication] setIdleTimerDisabled:NO];

        }



    - (void)synchronizatorRequestDidFailByValidationErrors:(Synchronizator *)s
                                              withSyncGuid:(NSString *)syncGuid
                                                 andErrors:(NSArray *)errors
        {
            activity = [ATActivityIndicator currentIndicator];
            [activity hide];
            syncLabel.text         = @"Validation errors. Please see the log for details.";
            syncWarning.hidden     = YES;
            syncProgressBar.hidden = YES;
            alert = [[UIAlertView alloc] initWithTitle:@"Validation Error" message:syncLabel.text delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }



    - (void)stopAllAnimationsInList
        {
            int entityIndex = 0;
            NSMutableArray       *indexPathsArr = [[NSMutableArray alloc] init];
            for (SyncInformation *syncEnt in sync.entitiesToSync)
                {
                    if (syncEnt.syncStatus == syncStatusInProgress)
                        {
                            syncEnt.syncStatus = syncStatusPending;
                            NSIndexPath *indPath = [NSIndexPath indexPathForRow:entityIndex inSection:0];
                            [indexPathsArr addObject:indPath];
                        }
                    entityIndex++;
                }
            [self.syncTableView reloadRowsAtIndexPaths:indexPathsArr withRowAnimation:UITableViewRowAnimationNone];
        }



    - (void)synchronizatorUploadOneEntityStarts:(EntityStartStatus *)status
        {
            [syncProgressBar setProgress:((float) status.actualEntityIndex / (float) status.totalEntities) animated:true];
            syncLabel.text = [NSString stringWithFormat:@"Uploading: %@", status.entityKind];

            int tableViewIndex            = status.actualEntityIndex - 1;
            NSIndexPath    *indPath;
            NSMutableArray *indexPathsArr = [[NSMutableArray alloc] init];
            if (tableViewIndex > 0)
                {
                    indPath = [NSIndexPath indexPathForRow:(tableViewIndex - 1) inSection:0];
                    [indexPathsArr addObject:indPath];

                }
            indPath = [NSIndexPath indexPathForRow:tableViewIndex inSection:0];
            [indexPathsArr addObject:indPath];
            [self.syncTableView reloadRowsAtIndexPaths:indexPathsArr withRowAnimation:UITableViewRowAnimationNone];
            [self.syncTableView scrollToRowAtIndexPath:indPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }



    - (void)synchronizatorMoveDataFromSyncToPrepStarts:(Synchronizator *)s
        {
            NSMutableArray *indexPathsArr = [[NSMutableArray alloc] init];
            NSIndexPath    *indPath       = [NSIndexPath indexPathForRow:([sync.entitiesToSync count] - 1) inSection:0];
            [indexPathsArr addObject:indPath];
            [self.syncTableView reloadRowsAtIndexPaths:indexPathsArr withRowAnimation:UITableViewRowAnimationNone];
            syncLabel.text = @"Moving data from sync tables to prep tables";
        }



    - (void)synchronizatorUploadingPictureStarts:(Synchronizator *)s
                                   actualPicture:(int)actualPicture
                        numberOfPicturesToUpload:(int)totalPicturesToUpload
        {
            syncLabel.text = [NSString stringWithFormat:@"Uploading Image %d of %d", actualPicture, totalPicturesToUpload];
        }



    - (void)synchronizatorUploadEntitiesDone:(Synchronizator *)s
        {
            RealPropertyApp *app = (RealPropertyApp *) [[UIApplication sharedApplication] delegate];
            if (s.entitiesToSyncCount > 0)
                {
                    [app fireDownloadSync];
                    syncLabel.text = @"Now updating server, please wait until completion.";
                }
            else
                {
                    syncLabel.text = @"";
                    [self stopSyncIndicators];
                    // Reset timer
                    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
                }
            [self syncDone];
            if (s.notSyncedEntities > 0)
                {
                    UIAlertView *alertBookmark = [[UIAlertView alloc] initWithTitle:@"Sync Error" message:[self createBookmarkInfoMessage:s.notSyncedEntities] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                    [alertBookmark show];
                }
        }
#pragma mark - Manage top left indicators
    - (void)stopSyncIndicators
        {
            [[ATActivityIndicator currentIndicator] hide];
            [navView removeFromSuperview];
            navView = nil;
        }



    - (void)startSyncIndicators:(NSString *)message
        {
            // Create a temp window to block any input
            RealPropertyApp  *app        = (RealPropertyApp *) [[UIApplication sharedApplication] delegate];
            UIViewController *controller = app.window.rootViewController;

            if (navView == nil)
                {
                    navView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 1024)];
                    navView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
                    navView.opaque          = NO;

                    [controller.view addSubview:navView];
                    [controller.view bringSubviewToFront:navView];
                }

            ATActivityIndicator *indicator = [ATActivityIndicator currentIndicator];
            [indicator displayActivity:message];

        }



    - (void)indicatorMessage:(NSString *)message
        {
            ATActivityIndicator *indicator = [ATActivityIndicator currentIndicator];
            [indicator displayActivity:message];
        }



    - (void)syncDone
        {
            syncWarning.hidden     = YES;
            syncProgressBar.hidden = YES;
            [self synchronizatorGetEntityListToUploadDone:nil lastSyncDate:[Helper localDate]];
        }



    - (void)syncStart
        {
            syncWarning.hidden     = NO;
            syncProgressBar.hidden = NO;
            syncLabel.hidden       = NO;
        }



    - (void)displayWarningErrors:(id)sender
        {
            errorDialog = [[SyncFilesError alloc] initWithStyle:UITableViewStylePlain];
            errorDialog.delegate = self;
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:errorDialog];

            navController.modalPresentationStyle = UIModalPresentationFormSheet;

            UIBarButtonItem *cancelButton =
                                    [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(cancelDialogBox:)];
            errorDialog.navigationItem.rightBarButtonItem = cancelButton;
            errorDialog.navigationItem.title              = @"Synchronization Errors";
            UIBarButtonItem *clearButton =
                                    [[UIBarButtonItem alloc] initWithTitle:@"Clear Errors"
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(clearDialogBox:)];
            errorDialog.navigationItem.leftBarButtonItem = clearButton;

            [self presentViewController:navController animated:YES  completion:^(void)
                {
                }];
        }



    - (void)syncValidationOpenObject:(SyncValidationError *)error
        {
            validationError = error;
            [self dismissViewControllerAnimated:YES completion:^(void)
                {
                    errorDialog = nil;
                    // Now we can redirect to the appropriate object
                    [OpenEntity Open:validationError.entityKind withGuid:validationError.entityGuid];
                }
            ];

        }



    - (void)cancelDialogBox:(id)sender
        {
            [self dismissViewControllerAnimated:YES completion:^(void)
                {
                    errorDialog = nil;
                }
            ];
        }



// Delete all the errors in the preferences file
    - (void)clearDialogBox:(id)sender
        {
            clearError = [[UIAlertView alloc] initWithTitle:@"Delete Messages" message:@"Are you sure to delete all the error messages?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
            [clearError show];
        }



    - (IBAction)downloadSyncPressed:(id)sender
        {
#if 0
    if(syncWarning.hidden == NO)
        return;
    [self syncStart];
    
    sync = [[Synchronizator alloc]init:[RealPropertyApp getDataUrl]];
    sync.delegate = self;
    Configuration *configuration = [RealPropertyApp getConfiguration];
    
    NSMutableArray *entitiesToSync = [sync createEntityList];
    
    syncLabel.text = @"Starting sync from server to iPad";
    [syncProgressBar setProgress:0.0 animated:true];
    
    sync.securityToken = configuration.simpleToken;
    sync.forceRestart = YES;
    
    [sync performSelectorInBackground:@selector(executeDownloadEntitesSynchronous:) withObject:entitiesToSync];
    syncWarning.hidden = NO;
#endif
        }



    - (void)synchronizatorBeforeStartSync:(NSArray *)entitiesToDownload
        {
            [syncTableView reloadData];
        }



    - (void)synchronizatorDownloadEntitiesDone:(Synchronizator *)s
        {
            syncLabel.text = @"Synchronization Complete!";

            NSMutableArray *indexPathsArr = [[NSMutableArray alloc] init];
            NSIndexPath    *indPath       = [NSIndexPath indexPathForRow:([sync.entitiesToSync count] - 1) inSection:0];
            [indexPathsArr addObject:indPath];
            [self.syncTableView reloadRowsAtIndexPaths:indexPathsArr withRowAnimation:UITableViewRowAnimationNone];
            [self syncDone];
        }



// will be called each time when a download entity sync starts.
    - (void)synchronizatorDownloadOneEntityStarts:(EntityStartStatus *)status;
        {
            [syncProgressBar setProgress:((float) (status.actualEntityIndex) / (float) (status.totalEntities)) animated:true];
            syncLabel.text = [NSString stringWithFormat:@"Downloading: %@", status.entityKind];
            int tableViewIndex            = status.actualEntityIndex - 1;
            NSIndexPath    *indPath;
            NSMutableArray *indexPathsArr = [[NSMutableArray alloc] init];
            if (tableViewIndex > 0)
                {
                    indPath = [NSIndexPath indexPathForRow:(tableViewIndex - 1) inSection:0];
                    [indexPathsArr addObject:indPath];

                }
            indPath = [NSIndexPath indexPathForRow:tableViewIndex inSection:0];
            [indexPathsArr addObject:indPath];
            [self.syncTableView reloadRowsAtIndexPaths:indexPathsArr withRowAnimation:UITableViewRowAnimationNone];
            [self.syncTableView scrollToRowAtIndexPath:indPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];

        }

#pragma mark - Table view data source


    - (NSInteger)tableView:(UITableView *)tableView
     numberOfRowsInSection:(NSInteger)section
        {
            if (sync.entitiesToSync != nil)
                {
                    return [sync.entitiesToSync count];
                }
            return 0;
        }



    - (UITableViewCell *)tableView:(UITableView *)tableView
             cellForRowAtIndexPath:(NSIndexPath *)indexPath
        {
            static NSString *CellIdentifier = @"Cell";
            UITableViewCell *cell           = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

            if (cell == nil)
                {
                    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"SyncCustomCell" owner:self options:nil];
                    for (id currentObject in topLevelObjects)
                        {
                            if ([currentObject isKindOfClass:[UITableViewCell class]])
                                {
                                    cell = (UITableViewCell *) currentObject; //Get the cell with the custom UI cell information
                                    break;
                                }
                        }
                }
            SyncInformation *syncEnt = [sync.entitiesToSync objectAtIndex:indexPath.row];
            if ([syncEnt.syncDescription length] == 0)
                syncEnt.syncDescription                  = syncEnt.syncEntityName;
            ((SyncCustomCell *) cell).syncEntityLbl.text = syncEnt.syncDescription;
            NSString *msgEntity = @"changes";
            if (syncEnt.numberOfEntitiesToSync == 1)
                {
                    msgEntity = @"change";
                }
            switch (syncEnt.syncStatus)
                {
                    case syncStatusInProgress:
                        {
                            ((SyncCustomCell *) cell).syncActivityIndicator.hidden = NO;
                            [((SyncCustomCell *) cell).syncActivityIndicator startAnimating];
                            if (syncEnt.numberOfEntitiesToSync == 0)
                                ((SyncCustomCell *) cell).syncStatusLbl.text = @"No changes";
                            else
                                ((SyncCustomCell *) cell).syncStatusLbl.text = [NSString stringWithFormat:@"Synchronizing: %d %@", syncEnt.numberOfEntitiesToSync, msgEntity];
                            ((SyncCustomCell *) cell).syncStatusImage.hidden = YES;
                        }
                    break;

                    case syncStatusPending:
                        {
                            [((SyncCustomCell *) cell).syncActivityIndicator stopAnimating];
                            ((SyncCustomCell *) cell).syncActivityIndicator.hidden = YES;
                            if (syncEnt.numberOfEntitiesToSync == 0)
                                ((SyncCustomCell *) cell).syncStatusLbl.text       = @"No changes";
                            else
                                ((SyncCustomCell *) cell).syncStatusLbl.text = [NSString stringWithFormat:@"Pending: %d %@", syncEnt.numberOfEntitiesToSync, msgEntity];
                            ((SyncCustomCell *) cell).syncStatusImage.hidden = YES;
                        }
                    break;

                    case syncStatusDone:
                        {
                            [((SyncCustomCell *) cell).syncActivityIndicator stopAnimating];
                            ((SyncCustomCell *) cell).syncActivityIndicator.hidden = YES;
                            if (syncEnt.numberOfEntitiesToSync == 0)
                                ((SyncCustomCell *) cell).syncStatusLbl.text       = @"No changes";
                            else
                                {
                                    ((SyncCustomCell *) cell).syncStatusLbl.text     = [NSString stringWithFormat:@"Synchronized: %d %@", syncEnt.numberOfEntitiesToSync, msgEntity];
                                    ((SyncCustomCell *) cell).syncStatusImage.hidden = NO;
                                }
                        }
                    break;

                    default:
                        break;
                }
            cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
            return cell;
        }



    - (void)                   tableView:(UITableView *)tableView
accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
        {
            SyncInformation *syncEnt = [sync.entitiesToSync objectAtIndex:indexPath.row];

            // retrieve the list of entities to dump
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"rowStatus<>''"];
            NSArray     *array     = [AxDataManager dataListEntity:syncEnt.syncEntityName andPredicate:predicate andSortBy:@"rowStatus" sortAscending:YES withContext:[AxDataManager defaultContext]];

            [self dumpEntities:array entityName:syncEnt.syncEntityName];

        }



    - (void)    tableView:(UITableView *)tableView
didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
        {
        }



    - (void)activateController
        // check where NoteInstance gets called and what is being checked   zrowStatus U zSrc = hiexmpt
        {
            [self updateSyncInfo];
            [syncTableView reloadData];
            int n = [self countChanges];

            if (n == 0)
                syncLabel.text = [NSString stringWithFormat:@"There are no changes"];
            else if (n == 1)
                syncLabel.text = [NSString stringWithFormat:@"There is only one change"];
            else
                syncLabel.text = [NSString stringWithFormat:@"There are %d changes", n];
            bookmarkError.text = @"";
            [self countErrors];
            
        }



    - (void)alertView:(UIAlertView *)alertView
 clickedButtonAtIndex:(NSInteger)buttonIndex
        {
            if (alertView == clearError)
                {
                    if (buttonIndex == 0)
                        return;
                    // Delete all the entries
                    [self dismissViewControllerAnimated:YES completion:^(void)
                        {
                            errorDialog = nil;
                            NSManagedObjectContext   *context   = [AxDataManager configContext];
                            NSPredicate              *predicate = [NSPredicate predicateWithFormat:@"1==1"];
                            NSArray                  *array     = [AxDataManager dataListEntity:@"SyncValidationError" andPredicate:predicate andSortBy:@"date" sortAscending:YES withContext:context];
                            for (SyncValidationError *error in array)
                                [context deleteObject:error];
                            array = nil;
                            [context save:nil];
                            [self countErrors];
                        }
                    ];

                }
        }



// this method is used to create errors...
    - (void)createErrors
        {
            NSManagedObjectContext *context = [AxDataManager configContext];
            SyncValidationError    *error   = [AxDataManager getNewEntityObject:@"SyncValidationError" andContext:context];

            error.date       = [NSDate timeIntervalSinceReferenceDate] - 10000;
            error.entityGuid = nil;
            error.entityKind = @"";
            error.errorMsg   = @"This should be a message without a link";
            error.syncGuid   = @"";
            [context insertObject:error];

            error = [AxDataManager getNewEntityObject:@"SyncValidationError" andContext:context];
            error.date       = [NSDate timeIntervalSinceReferenceDate] - 15000;
            error.entityGuid = @"f5a0e5a1-23ad-433d-9325-8018fc565bd5";
            error.entityKind = @"Land";
            error.errorMsg   = @"This error is on a land";
            error.syncGuid   = @"";
            [context insertObject:error];

            error = [AxDataManager getNewEntityObject:@"SyncValidationError" andContext:context];
            error.date       = [NSDate timeIntervalSinceReferenceDate] - 5000;
            error.entityGuid = @"e751c046-0cd8-4434-b1f8-da4fc0d1bd81";
            error.entityKind = @"ResBldg";
            error.errorMsg   = @"This error should link to a building";
            error.syncGuid   = @"";
            [context insertObject:error];

            [context save:nil];

        }



    - (IBAction)createSyncError:(id)sender
        {
            [self createErrors];
        }
#pragma mark - display the content of the objects that are selected
    - (void)dumpEntities:(NSArray *)entities
              entityName:(NSString *)entityName
        {
            syncInfoDialog = [[DumpSyncInfo alloc] initWithNibName:@"DumpSyncInfo" bundle:nil];
            if (syncInfoDialog == nil)
                return;

            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:syncInfoDialog];

            navController.modalPresentationStyle = UIModalPresentationFormSheet;

            UIBarButtonItem *cancelButton =
                                    [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(cancelSyncInfo:)];
            syncInfoDialog.navigationItem.rightBarButtonItem = cancelButton;
            syncInfoDialog.navigationItem.title              = @"Dump Entities";

            UITextView *textView = (UITextView *) [syncInfoDialog.view viewWithTag:100];
            textView.text = @"";

            for (NSManagedObject *object in entities)
                [self addToText:object entityName:entityName textView:textView];

            [self presentViewController:navController animated:YES  completion:^(void)
                {
                }];
        }



    - (void)addToText:(NSManagedObject *)object
           entityName:(NSString *)entityName
             textView:(UITextView *)textView
        {
            //loop through all attributes and assign then to the clone
            NSDictionary *attributes = [[NSEntityDescription entityForName:entityName inManagedObjectContext:[AxDataManager defaultContext]] attributesByName];

            for (NSString *attr in attributes)
                {

                    NSString *desc = [[object valueForKey:attr] description];
                    textView.text = [textView.text stringByAppendingFormat:@"%@: %@\n", attr, desc];
                }

        }



    - (void)cancelSyncInfo:(id)sender
        {
            [self dismissViewControllerAnimated:YES completion:^(void)
                {
                    syncInfoDialog = nil;
                }];
        }



    - (NSString *)createBookmarkInfoMessage:(int)changes
        {
            NSString *result;

            if (changes == 1)
                return @"1 change will not be uploaded due to a bookmark error";

            result = [NSString stringWithFormat:@"%d changes will not be uploaded due to data validation errors, please check your bookmark.", changes];
            return result;
        }



    - (IBAction)testDownload:(id)sender
        {
            RealPropertyApp *app = (RealPropertyApp *) [[UIApplication sharedApplication] delegate];
            [app checkForChangedAzureFiles:nil];
        }


@end
