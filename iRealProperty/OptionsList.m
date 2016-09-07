#import "OptionsList.h"
#import "RealPropertyApp.h"
#import "OptionCellTabBar.h"
#import "OptionCellReset.h"
#import "TabMapController.h"
#import "Helper.h"
#import "TabOptionsController.h"

#import "RealProperty.h"
#import "TabSearchController.h"
#import "Container.h"
#import "Blob.h"
#import "AzureBlob.h"
#import "AzureContainer.h"
#import "FMDatabase.h"



@implementation OptionsList

    @synthesize menuBar, itsController;

#pragma mark - 

#pragma mark - View life cycle

    - (id)initWithStyle:(UITableViewStyle)style
        {
            self = [super initWithStyle:style];
            if (self)
                {
                }
            return self;
        }



    - (id)initWithNibName:(NSString *)nibNameOrNil
              withOptions:(Options *)options
        {
            self = [super initWithNibName:nibNameOrNil bundle:nil];
            if (self)
                {

                    _options = options;
                }
            return self;
        }



    - (void)viewDidLoad
        {
            [super viewDidLoad];
            // [self.tableView setAllowsSelection:NO];

        }



    - (void)viewDidUnload
        {
            [super viewDidUnload];
        }



    - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
        {
            return YES;
        }

#pragma mark - Table view data source

    - (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
        {
            return _options.sectionArray.count;
        }



    - (NSInteger)tableView:(UITableView *)tableView
     numberOfRowsInSection:(NSInteger)section
        {
            OptionSection *optSection = [_options.sectionArray objectAtIndex:section];
            return optSection.optionArray.count;
        }



    // Create the appropriate cell based on content.
    // This builds the Options List page, cell by cell, using the Options.m/.h data
    - (UITableViewCell *)tableView:(UITableView *)tableView
             cellForRowAtIndexPath:(NSIndexPath *)indexPath
        {
            UITableViewCell *cell;

            OptionSection *optSection = [_options.sectionArray objectAtIndex:[indexPath section]];
            Option        *option     = [optSection.optionArray objectAtIndex:[indexPath row]];

            if ([option.param caseInsensitiveCompare:@"help"] == NSOrderedSame)
                {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
                    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                    cell.textLabel.text = option.label;
                    cell.accessoryType  = UITableViewCellAccessoryDetailDisclosureButton;
                    return cell;
                }
            else if ([option.param caseInsensitiveCompare:@"logout"] == NSOrderedSame)
                {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
                    cell.textLabel.text = option.label;
                    cell.accessoryType  = UITableViewCellAccessoryDetailDisclosureButton;

                    Configuration *config      = [RealPropertyApp getConfiguration];
                    NSString      *simpleToken = config.simpleToken;

                    NSDate *date = [Helper expirationDate:simpleToken];
                    if (date == nil)
                        {
                            cell.detailTextLabel.text = @"Login not validated";

                        }
                    else
                        {
                            cell.detailTextLabel.text = [NSString stringWithFormat:@"Login expires on %@", [Helper fullStringFromDate:date]];

                        }

                    return cell;
                }
            else if ([option.param caseInsensitiveCompare:@"changearea"] == NSOrderedSame)
                {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
                    [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
                    cell.textLabel.text       = option.label;
                    cell.accessoryType        = UITableViewCellAccessoryDisclosureIndicator;
                    cell.detailTextLabel.text = [RealPropertyApp getWorkingArea];
                    currentAreaCell = cell;
                    return cell;
                }
            else if ([option.param caseInsensitiveCompare:@"syncnow"] == NSOrderedSame)
                {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
                    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                    cell.textLabel.text = option.label;
                    cell.accessoryType  = UITableViewCellAccessoryDisclosureIndicator;
                    downloadCell = cell;
                    [self updateDownloadCell];
                    return cell;
                }
            else if ([option.param caseInsensitiveCompare:@"managearea"] == NSOrderedSame)
                {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
                    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                    cell.textLabel.text = option.label;
                    cell.accessoryType  = UITableViewCellAccessoryDisclosureIndicator;
                    return cell;
                }
            else if ([option.param caseInsensitiveCompare:@"signature"] == NSOrderedSame)
                {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
                    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                    cell.textLabel.text       = option.label;
                    cell.detailTextLabel.text = [RealPropertyApp getUserName];
                    return cell;
                }
            else if ([option.param caseInsensitiveCompare:@"disk"] == NSOrderedSame)
                {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
                    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                    cell.textLabel.text = option.label;
                    long long documentSize = [Helper documentsFolderSize];

                    // We can safely assume that it can be expressed in MB
                    long long megabytes = 1024 * 1024;
                    long long gigabytes = megabytes * 1024;

                    double result;
                    if (documentSize < gigabytes)
                        {
                            result = (double) documentSize / (double) megabytes;
                            cell.detailTextLabel.text = [NSString stringWithFormat:@"%0.2f MB", result];
                        }
                    else
                        {
                            result = (double) documentSize / (double) gigabytes;
                            cell.detailTextLabel.text = [NSString stringWithFormat:@"%0.2f GB", result];
                        }
                    return cell;
                }
            else if ([option.param caseInsensitiveCompare:@"version"] == NSOrderedSame)
                {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
                    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                    cell.textLabel.text = option.label;
                    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
                    cell.detailTextLabel.text = version;
                    return cell;
                }
            else if ([option.param caseInsensitiveCompare:@"updatefile"] == NSOrderedSame)
                {
                    // File to updates
                    cell       = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
                    updateCell = cell;

                    [self updateOptionCellWithAreaFileStateMsg];

                    return cell;
                }
            else if ([option.param caseInsensitiveCompare:@"menubar"] == NSOrderedSame ||
                    [option.param caseInsensitiveCompare:@"openToSearch"] == NSOrderedSame ||
                    [option.param caseInsensitiveCompare:@"sync3g"] == NSOrderedSame ||
                    [option.param caseInsensitiveCompare:@"syncimages3g"] == NSOrderedSame)
                {
                    NSArray          *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"OptionCellTabBar" owner:self options:nil];
                    OptionCellTabBar *cell;
                    for (id currentObject in topLevelObjects)
                        {
                            if ([currentObject isKindOfClass:[UITableViewCell class]])
                                {
                                    cell = (OptionCellTabBar *) currentObject; //Get the cell with the custom UI cell information
                                    break;
                                }
                        }
                    UISwitch *btnSwitch = ((OptionCellTabBar *) cell).btnToggle;
                    [btnSwitch addTarget:self action:@selector(switchTabBar:) forControlEvents:UIControlEventValueChanged];
                    cell.label.text = option.label;
                    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                    Configuration *config = [RealPropertyApp getConfiguration];

                    if ([option.param caseInsensitiveCompare:@"menubar"] == NSOrderedSame)
                        {
                            [btnSwitch setOn:config.menuAtBottom];
                            btnSwitch.tag = 100;
                        }
                    else if ([option.param caseInsensitiveCompare:@"sync3g"] == NSOrderedSame)
                        {
                            [btnSwitch setOn:config.syncOver3G];
                            btnSwitch.tag = 200;
                            //8 5 15 cv - Hoang --> Let's just turn it on then and they'll need to know that whatever connection they have will be used
                            //btnSwitch.enabled = NO;  // DBaun - Hoang wanted to disable the Sync over 3G option per an email Nov 5, 2014.
                        }
                    else if ([option.param caseInsensitiveCompare:@"fixVcad"] == NSOrderedSame)
                    {
                        [btnSwitch setOn:config.syncOver3G];
                        btnSwitch.tag = 200;
                        //8 5 15 cv - Hoang --> Let's just turn it on then and they'll need to know that whatever connection they have will be used
                        //btnSwitch.enabled = NO;  // DBaun - Hoang wanted to disable the Sync over 3G option per an email Nov 5, 2014.
                    }
                    
                    else if ([option.param caseInsensitiveCompare:@"syncimages3g"] == NSOrderedSame)
                        {
                            [btnSwitch setOn:config.syncImageOver3G];
                            btnSwitch.tag = 300;
                        }
                    else if ([option.param caseInsensitiveCompare:@"openToSearch"] == NSOrderedSame)
                        {
                            [btnSwitch setOn:config.tabToLog];
                            btnSwitch.tag = 400;
                        }
                    return cell;
                }
            else if ([option.param caseInsensitiveCompare:@"effects"] == NSOrderedSame)
                {
                    NSArray          *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"OptionCellTabBar" owner:self options:nil];
                    OptionCellTabBar *cell;
                    for (id currentObject in topLevelObjects)
                        {
                            if ([currentObject isKindOfClass:[UITableViewCell class]])
                                {
                                    cell = (OptionCellTabBar *) currentObject; //Get the cell with the custom UI cell information
                                    break;
                                }
                        }
                    UISwitch *btnSwitch = ((OptionCellTabBar *) cell).btnToggle;
                    [btnSwitch addTarget:self action:@selector(switchEffects:) forControlEvents:UIControlEventValueChanged];
                    cell.label.text = option.label;
                    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                    Configuration *config = [RealPropertyApp getConfiguration];
                    [btnSwitch setOn:config.useEffects];
                    return cell;
                }
            else if ([option.param caseInsensitiveCompare:@"resetlayers"] == NSOrderedSame ||
                    [option.param caseInsensitiveCompare:@"resetrenderers"] == NSOrderedSame ||
                     [option.param caseInsensitiveCompare:@"fixVcad"] == NSOrderedSame
                     )
                {
                    NSArray         *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"OptionCellReset" owner:self options:nil];
                    OptionCellReset *cell;
                    for (id currentObject in topLevelObjects)
                        {
                            if ([currentObject isKindOfClass:[UITableViewCell class]])
                                {
                                    cell = (OptionCellReset *) currentObject; //Get the cell with the custom UI cell information
                                    break;
                                }
                        }
                    UIButton *btnReset = ((OptionCellReset *) cell).cellReset;
                    [btnReset addTarget:self action:@selector(resetBtn:) forControlEvents:UIControlEventTouchUpInside];
                    cell.label.text = option.label;
                    if ([option.param caseInsensitiveCompare:@"resetlayers"] == NSOrderedSame)
                        _resetParcel = btnReset;
                    else if ([option.param caseInsensitiveCompare:@"fixVcad"] == NSOrderedSame)
        
                        _fixVcad = btnReset;
                    else
                        _resetLayers = btnReset;
                    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                    return cell;
                }
            if ([option.param caseInsensitiveCompare:@"changecode"] == NSOrderedSame || [option.param caseInsensitiveCompare:@"requiredafter"] == NSOrderedSame)
                {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
                    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                    cell.accessoryType  = UITableViewCellAccessoryDisclosureIndicator;
                    cell.textLabel.text = option.label;
                    return cell;
                }
            else
                {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
                    cell.textLabel.text = option.label;
                    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                }
            return cell;
        }



    - (NSString *)tableView:(UITableView *)tableView
    titleForHeaderInSection:(NSInteger)section
        {
            OptionSection *optSection = [_options.sectionArray objectAtIndex:section];
            return optSection.label;
        }



    - (NSString *)tableView:(UITableView *)tableView
    titleForFooterInSection:(NSInteger)section
        {
            OptionSection *optSection = [_options.sectionArray objectAtIndex:section];
            return optSection.footer;
        }



    - (void)updateDownloadCell
        {
            // DBaun 2014-03-12: Added the nil test because app would crash if defaultContext wasn't available.
            if ([AxDataManager defaultContext] == nil)
            {
                downloadCell.detailTextLabel.text = @"Last Sync Unavailable";
            }
            else
            {
            NSDate *date = [NSDate dateWithTimeIntervalSinceReferenceDate:[RealPropertyApp getLastSyncDate:[AxDataManager defaultContext]]];

            NSString *lastUpdate = [Helper fullStringFromDate:date];
            downloadCell.detailTextLabel.text = [NSString stringWithFormat:@"Last sync on %@", lastUpdate];
            }
            
            
        }


#pragma mark - Switch events


    - (void)switchTabBar:(id)sender
        {
            UISwitch        *switchBtn = sender;
            RealPropertyApp *realApp   = (RealPropertyApp *) [[UIApplication sharedApplication] delegate];

            if (switchBtn.tag == 100)
                {
                    [UIView animateWithDuration:0.4 animations:
                                                            ^(void)
                                                                {
                                                                    [realApp setBarAtBottom:switchBtn.on];
                                                                }
                                     completion:
                                             ^(BOOL val)
                                                 {
                                                     Configuration *config = [RealPropertyApp getConfiguration];
                                                     config.menuAtBottom = switchBtn.on;
                                                     [[AxDataManager configContext] save:nil];
                                                 }];
                }
            else if (switchBtn.tag == 200)
                {
                    Configuration *config = [RealPropertyApp getConfiguration];
                    config.syncOver3G = switchBtn.on;
                    [[AxDataManager configContext] save:nil];
                }
            else if (switchBtn.tag == 300)
                {
                    Configuration *config = [RealPropertyApp getConfiguration];
                    config.syncImageOver3G = switchBtn.on;
                    [[AxDataManager configContext] save:nil];
                }
            else if (switchBtn.tag == 400)
                {
                    Configuration *config = [RealPropertyApp getConfiguration];
                    config.tabToLog = switchBtn.on;
                    [[AxDataManager configContext] save:nil];
                }
        }



    - (void)switchEffects:(id)sender
        {
            UISwitch      *switchBtn = sender;
            Configuration *config    = [RealPropertyApp getConfiguration];
            config.useEffects = switchBtn.on;
            [[AxDataManager configContext] save:nil];
        }



    - (void)resetBtn:(id)sender
        {
            NSString *msg;
            if (sender == _resetLayers)
                {
                    msg        = @"Are you sure to want to reset the layers to their original configuration?";
                    _alertMode = kAlertResetLayers;
                }
            else if (sender == _fixVcad)
                {
                    [self fixVcad];
                    [Helper alertWithOk:@"Fix in Progress" message:@"Files should be fixed."];
                    return;
                }
            else
                {
                    msg        = @"Are you sure to want to reset the renderers to their original configuration?";
                    _alertMode = kAlertResetRenderers;
                }
            _alert = [[UIAlertView alloc] initWithTitle:@"Please Confirm" message:msg delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
            [_alert show];
        }


#pragma mark - Alert delegate


    - (void)    alertView:(UIAlertView *)alertView
didDismissWithButtonIndex:(NSInteger)buttonIndex
        {
            if (_alertMode == kAlertExitApplication)
                {
                    exit(0);
                }
            if (buttonIndex == 1)
                {
                    RealPropertyApp *app = (RealPropertyApp *) [[UIApplication sharedApplication] delegate];

                    TabMapController *map = (TabMapController *) (app.tabMapController);
                    if (_alertMode == kAlertResetLayers)
                        [map resetLayersConfiguration];
                    else if (_alertMode == kAlertResetRenderers)
                        [map resetRenderersConfiguration];
                }
        }


#pragma mark - Table view delegate


    - (void)  tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
        {
            OptionSection *optSection = [_options.sectionArray objectAtIndex:[indexPath section]];
            Option        *option     = [optSection.optionArray objectAtIndex:[indexPath row]];

            // Select a new area
            if ([option.param caseInsensitiveCompare:@"changearea"] == NSOrderedSame)
                {
                    NSArray *array = [RealPropertyApp findAllAreas];
                    _areaList = [[AreasList alloc] initWithNibName:@"AreasList" bundle:nil];
                    _areaList.tableView.frame = self.tableView.frame;
                    _areaList.changeDelegate  = self;

                    _areaList.rows = array;
                    for (int index = 0; index < array.count; index++)
                        {
                            NSString *str = [array objectAtIndex:index];
                            if ([str caseInsensitiveCompare:[RealPropertyApp getWorkingArea]] == NSOrderedSame)
                                {
                                    _areaList.selectedRow = index;
                                    break;
                                }
                        }
                    _detailMode = kDetailSelectArea;

                    nav = [[UINavigationController alloc] initWithRootViewController:_areaList];

                    nav.modalPresentationStyle = UIModalPresentationFormSheet;

                    UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(closeSelectArea:)];
                    anotherButton.tintColor = [UIColor blueColor];

                    _areaList.title                             = @"Select an Area";
                    _areaList.navigationItem.rightBarButtonItem = anotherButton;

                    [itsController presentViewController:nav animated:YES completion:^(void)
                        {
                        }];
                }
                    // Download an area or remove an area
            else if ([option.param caseInsensitiveCompare:@"managearea"] == NSOrderedSame)
                {
                    [self startAreaManagement];
                }
            else if ([option.param caseInsensitiveCompare:@"changecode"] == NSOrderedSame)
                {
                    // Need to pass this to the parent controller
                    [itsController changeLock];
                }
            else if ([option.param caseInsensitiveCompare:@"updatefile"] == NSOrderedSame)
                {
                    [self updateFiles];
                }
            else if ([option.param caseInsensitiveCompare:@"logout"] == NSOrderedSame)
                {
                    Configuration *config = [RealPropertyApp getConfiguration];
                    config.simpleToken = @"";
                    [[AxDataManager configContext] save:nil];
                    exit(EXIT_SUCCESS);
                }
            else if ([option.param caseInsensitiveCompare:@"syncnow"] == NSOrderedSame)
                {
                    [itsController syncNow];
                }
        }



    - (void)startAreaManagement
        {
            _manageArea = [[ManageAreas alloc] initWithNibName:@"ManageAreas" bundle:nil];
            _manageArea.rows = [[NSArray alloc] init];

            _detailMode = kDetailManageArea;
            nav         = [[UINavigationController alloc] initWithRootViewController:_manageArea];

            nav.modalPresentationStyle = UIModalPresentationFormSheet;

            UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(closeManageArea:)];
            anotherButton.tintColor = [UIColor redColor];

            _manageArea.title                             = @"Manage Areas";
            _manageArea.navigationItem.rightBarButtonItem = anotherButton;

            [itsController presentViewController:nav animated:YES completion:^(void)
                {
                }];

            _manageArea.delegate = self;
            [_manageArea getFullListOfContainers];
        }


#pragma mark - Delegate


//
// The areas the user marked for download on the Manage Areas form
// are going to be downloaded.
//
    - (void)manageAreaSync:(NSArray *)areas
            withContainers:(NSArray *)containers
        {
            _mode = kOptionListSyncAll;

            [self closeManageArea:0];
            [self validateCurrentArea];

            // Delete the existing containers (if there are any left over)

            NSManagedObjectContext *personalNotesSqlite = [AxDataManager noteContext];

            NSArray *sqliteContainers = [AxDataManager dataListEntity:@"Container" andSortBy:@"name" sortAscending:YES withContext:personalNotesSqlite];

            for (id object in sqliteContainers)
                {
                    [personalNotesSqlite deleteObject:object];
                }

            // DBaun 2013-10-13
            // Going to delete all the Blobs from the blob table here since it doesn't seem to be doing it anywhere ever,
            // and the table relationships are not deleting the blobs when their parent container is deleted.
            NSArray *sqliteBlobs = [AxDataManager dataListEntity:@"Blob" andSortBy:@"type" sortAscending:YES withContext:personalNotesSqlite];

            for (id object in sqliteBlobs)
                {
                    [personalNotesSqlite deleteObject:object];
                }

            NSError *error = nil;
            [personalNotesSqlite save:&error];

            if (error != nil)
                {
                    NSLog(@"Err desc-%@", [error localizedDescription]);
                    NSLog(@"Err reason-%@", [error localizedFailureReason]);
                }

            // go through the list of selected items to find which container(s) to download
            int count = 0;
            for (DownloadableArea *area in areas)
                {
                    if (area.selected && !area.localStorage)
                        {
                            // new area to select
                            // Add the info from the container
                            for (AzureContainer *azContainer in containers)
                                {
                                    if ([azContainer.name caseInsensitiveCompare:area.name] == NSOrderedSame)
                                        {
                                            [self addContainerAndBlobsToDownloadQueue:azContainer];
                                            count++;
                                        }
                                }
                        }
                }
            if (count == 0)
                {
                    return;
                }


            // Now we are ready for downloading all the files
            downloadController = [[DownloadFiles alloc] initWithNibName:@"DownloadFiles" bundle:nil];

            nav = [[UINavigationController alloc] initWithRootViewController:downloadController];
            nav.modalPresentationStyle = UIModalPresentationFormSheet;

            downloadController.title    = @"Downloading Areas";
            downloadController.delegate = self;

            // Prevent the application from syncing during a download
            [RealPropertyApp allowToSync:NO];

            [itsController presentViewController:nav animated:YES  completion:^(void)
                {
                }];

        }



// DBaun 10/16/13 08:40pm THIS IS WHERE I CAN DISMISS THE DOWNLOAD PAGE (IT IS GETTING STUCK IN A BUG AND I COULDN'T FIND OUT WHERE TO DISMISS IT.
// The specific error message that appears in the logs but not on screen is "Warning: Attempt to present <UINavigationController: 0xbacacf0> on <TabBarController: 0xba94570> while a presentation is in progress!"

    - (void)downloadFileTerminate:(BOOL)animated
        {
            [RealPropertyApp allowToSync:NO];
            [itsController dismissViewControllerAnimated:animated completion:^
                {
                    nav                = nil;
                    downloadController = nil;
                    [self validateCurrentArea];
                    [RealPropertyApp allowToSync:YES];

                    if (_mode == kOptionListFilesHaveChanged)
                        {
                            RealPropertyApp *app = (RealPropertyApp *) [[UIApplication sharedApplication] delegate];
                            [app updateUIWithChangedETagsInfo:0];
                            [self updateOptionCellWithAreaFileStateMsg];
                        }
                }];
        }



    - (void)addContainerAndBlobsToDownloadQueue:(AzureContainer *)azContainer
        {
            NSManagedObjectContext *personalNotesSqlite = [AxDataManager noteContext];
            Container              *container           = [AxDataManager getNewEntityObject:@"Container" andContext:personalNotesSqlite];

            container.name             = azContainer.name;
            container.eTag             = azContainer.etag;
            container.lastModifiedDate = azContainer.lastModifiedDate;
            container.url              = azContainer.url;

            // Add the blobs
            for (AzureBlob *azBlob in azContainer.blobs)
                {
                    Blob *blob = [AxDataManager getNewEntityObject:@"Blob" andContext:personalNotesSqlite];
                    blob.name             = azBlob.name;
                    blob.type             = azBlob.type;
                    blob.length           = azBlob.length;
                    blob.contentType      = azBlob.contentType;
                    blob.eTag             = azBlob.eTag;
                    blob.lastModifiedDate = azBlob.lastModifiedDate;
                    blob.leaseStatus      = azBlob.leaseStatus;
                    blob.url              = azBlob.url;

                    [container addBlobsObject:blob];
                }

            [personalNotesSqlite save:nil];

        }



    - (void)closeSelectArea:(id)sender
        {
            [itsController dismissViewControllerAnimated:YES  completion:^(void)
                {
                }];
            nav       = nil;
            _areaList = nil;
            [self.tableView reloadData];
        }



    - (void)closeManageArea:(id)sender
        {
            [itsController dismissViewControllerAnimated:NO  completion:^(void)
                {
                }];
            nav         = nil;
            _manageArea = nil;
            [self.tableView reloadData];
            activity = [ATActivityIndicator currentIndicator];
            [activity hide];
        }



//
// Delegate call: change the current area
//
    - (void)changeAreaDelegate:(int)indexPath
        {
            NSString        *workingArea = [_areaList.rows objectAtIndex:indexPath];
            RealPropertyApp *realApp     = (RealPropertyApp *) [[UIApplication sharedApplication] delegate];

            [realApp setWorkingArea:workingArea];

            [RealProperty setSelectedProperties:nil];

            ((TabSearchController *) (realApp.tabSearchController)).autoSearch = NO;

            // Release the objects stores
            [AxDataManager releaseManagedObjectStore:@"default"];

            [realApp openRealPropertySqlite];

            [itsController dismissViewControllerAnimated:YES  completion:^(void)
                {
                }];
            
            nav       = nil;
            _areaList = nil;
            
            [self.tableView reloadData];
            
            // Just to be sure, restart the application
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Change Area" message:@"iRealProperty will now close to switch to the new area. Please restart the application." delegate:self cancelButtonTitle:@"Quit iRealProperty" otherButtonTitles:nil];
            _alertMode = kAlertExitApplication;
            
            [alert show];
        }



//
// Force the syncrhonization
//
    - (void)synchronizeNow:(id)sender
        {
            // Make sure that at least one area is selected
        }



    - (void)tableView:(UITableView *)tableView
accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
        {
            OptionSection *optSection = [_options.sectionArray objectAtIndex:[indexPath section]];
            Option        *option     = [optSection.optionArray objectAtIndex:[indexPath row]];

            if ([option.param caseInsensitiveCompare:@"help"] == NSOrderedSame)
                {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://docs.google.com/folder/d/0ByAeiYuWBOFPOFJYMnFUcTBXNk0/edit"]];
                }
        }



//
// Get the list of areas that have been downloaded to ensure
// that the current area is still valid
//
    - (void)validateCurrentArea
        {
            NSArray       *array  = [Helper findAllDirectories:@"Area"];
            Configuration *config = [RealPropertyApp getConfiguration];

            BOOL found = NO;
            for (NSString *str in array)
                {
                    if ([str caseInsensitiveCompare:config.currentArea] == NSOrderedSame)
                        {
                            found = YES;
                            break;
                        }
                }

            if (found && [config.currentArea length] > 0)
                return;

            // The current selected area does not exist anymore
            config.currentArea                   = @"";
            currentAreaCell.detailTextLabel.text = @"No Area Selected";
            [currentAreaCell setNeedsDisplay];

            NSManagedObjectContext *context = [AxDataManager getContext:@"config"];
            [context save:nil];
        }



    - (void)menuBarBtnBackSelected
        {
        }



    - (void)updateFiles
        {
            if ([RealPropertyApp cancelTestUser])
                {
                    return;
                }

            RealPropertyApp *app = (RealPropertyApp *) [[UIApplication sharedApplication] delegate];

            if ([app isSyncing] && [RealPropertyApp allowToSync])
                {
                    [Helper alertWithOk:@"Download in Progress" message:@"There is already another download in progress. Please wait until completed."];
                    return;
                }

            [RealPropertyApp allowToSync:NO];

            _mode = kOptionListFilesHaveChanged;

            activity = [ATActivityIndicator currentIndicator];
            [activity displayActivity:@"Getting Info"];

            SyncFiles *sync = [[SyncFiles alloc] init];
            sync.delegate = self;

            [sync downloadNewFiles];
        }



    // This method is called internally by this class to update the option cell text
    // The count information that participates in the text label comes from a property on RealPropertyApp
    - (void)updateOptionCellWithAreaFileStateMsg
        {
            RealPropertyApp *app;
            Configuration   *config;
            NSDate          *date;
            NSString        *lastUpdate;
            NSString        *text;

            app        = (RealPropertyApp *) [[UIApplication sharedApplication] delegate];
            config     = [RealPropertyApp getConfiguration];
            date       = [NSDate dateWithTimeIntervalSinceReferenceDate:config.lastCheckinAzureTime];
            lastUpdate = [Helper fullStringFromDate:date];

            [updateCell setSelectionStyle:UITableViewCellSelectionStyleNone];

            //DBaun NOTE: 2014-02-27 It would be nice to fix this at some point so that if the check for changed files has never taken place yet, then the message would say so, instead of saying everything is up-to-date which technically is not correct.

            if ([config.currentArea length]==0)
                {
                    updateCell.textLabel.text       = @"No Area Selected Yet";
                    updateCell.accessoryType        = UITableViewCellAccessoryDisclosureIndicator;
                    updateCell.detailTextLabel.text = @"";
                }
            else if (app.countOfChangedAzureFiles == 0)
                {
                    updateCell.textLabel.text       = @"All files are up-to-date";
                    updateCell.accessoryType        = UITableViewCellAccessoryDisclosureIndicator;
                    updateCell.detailTextLabel.text = lastUpdate;

                }
            else
                {
                    updateCell.textLabel.text = @"Some files need to be updated";

                    if (app.countOfChangedAzureFiles == 1)
                        text = @"One file to be updated";
                    else
                        text = [NSString stringWithFormat:@"%d files to be updated", app.countOfChangedAzureFiles];

                    updateCell.textLabel.text       = text;
                    updateCell.accessoryType        = UITableViewCellAccessoryDisclosureIndicator;
                    updateCell.detailTextLabel.text = lastUpdate;
                }
        }



    // This method will be called every time azure is checked for an updated count of changed ETags.
    - (void)updateUIWithChangedETagsInfo:(int)count
        {
            [self updateOptionCellWithAreaFileStateMsg];
        }



// get my list of changed blobs
    - (void)downloadTheseChangedBlobs:(NSArray *)changedBlobs
                         forContainer:(NSString *)containerName
        {
            activity = [ATActivityIndicator currentIndicator];
            [activity hide];

            Configuration *config;
            config = [RealPropertyApp getConfiguration];

            if (config == nil)
                return;

            config.lastCheckinAzureTime = [[NSDate date] timeIntervalSinceReferenceDate];
            [[AxDataManager configContext] save:nil];

            [self updateOptionCellWithAreaFileStateMsg];

            if (changedBlobs.count == 0)
                {
                    return;
                }


            // Delete the existing containers (if there are any left over)
            NSManagedObjectContext *personalNotesSqlite;
            NSPredicate            *predicate;
            NSArray                *sqliteContainer;
            personalNotesSqlite = [AxDataManager noteContext];

            // DBaun 10/16/13 09:58pm Possible bug I think I fixed here. The code may have been deleting a container that hadn't been downloaded yet because it had no predicate.
            predicate       = [NSPredicate predicateWithFormat:@"name LIKE[c] %@", containerName];
            sqliteContainer = [AxDataManager dataListEntity:@"Container" andSortBy:@"name" andPredicate:predicate withContext:personalNotesSqlite];
            for (id object in sqliteContainer)
                {
                    [personalNotesSqlite deleteObject:object];
                }

            [personalNotesSqlite save:nil];


            // Create the container to sync and the attached blobs
            NSString       *theAreaName;
            AzureContainer *anAzureContainer;
            theAreaName      = [containerName lowercaseString];
            anAzureContainer = [[AzureContainer alloc] init];
            anAzureContainer.name             = theAreaName;
            anAzureContainer.etag             = @"no etag";
            anAzureContainer.lastModifiedDate = @"no date";
            anAzureContainer.url              = theAreaName;
            anAzureContainer.blobs            = (NSMutableArray *) changedBlobs;

            [self addContainerAndBlobsToDownloadQueue:anAzureContainer];

            [RealPropertyApp allowToSync:NO];

            // Now we are ready for downloading all the files
            downloadController = [[DownloadFiles alloc] initWithNibName:@"DownloadFiles" bundle:nil];
            downloadController.hideCancel    = YES;    // Don't show the cancel button
            downloadController.title         = @"Downloading Files";
            downloadController.delegate      = self;
            downloadController.saveDirectory = YES;

            nav = [[UINavigationController alloc] initWithRootViewController:downloadController];
            nav.modalPresentationStyle = UIModalPresentationFormSheet;

            [itsController presentViewController:nav animated:YES completion:^(void)
                {
                }];
        }



    - (void)activateController
        {
            [self updateOptionCellWithAreaFileStateMsg];
        }

    - (void)fixVcad
        {
            // 5/3/16 HNN kludge: fix media.sqlite vcad drawings where the mediatype was incorrectly set to 2 from a prior release
            
            NSArray  *paths             = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            
            NSString *documentDirectory = [paths objectAtIndex:0];
            
            NSString *dataBasePath  = [documentDirectory stringByAppendingFormat:@"/%@.Media.sqlite", [RealPropertyApp getWorkingPath]];
            
            FMDatabase *db       = [FMDatabase databaseWithPath:dataBasePath];
            
            if (![db open])
                
            {
                
                NSLog(@"Could not open db.");
                
            }
            
            
            
            NSString *query  = @"update Images set MediaType=1 where MediaType=2 and ext='WMF'";
            
            
            
            bool result = [db executeUpdate:query ];
            
            if (!result)
                
                NSLog(@"Fail to fix media for vcad drawings");
            
            [db close];
            

        }
@end
