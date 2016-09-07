#import "ManageAreas.h"
#import "DCRoundSwitch.h"
#import "Helper.h"
#import "Configuration.h"
#import "AzureBlob.h"
#import "AzureContainer.h"
#import "RealPropertyApp.h"


@implementation DownloadableArea

    @synthesize name, areaSize, selected, localStorage;



    - (NSString *)description
        {
            return [NSString stringWithFormat:@"Downloadble area='%@', size=%lf selected=%d localStorage=%d", name, areaSize, selected, localStorage];
        }

@end


@implementation ManageAreas


    @synthesize tableView;
    @synthesize btnSynchronize;
    @synthesize delegate;

    @synthesize rows = _rows;



    - (void)viewDidLoad
        {
            [super viewDidLoad];

            tableView.delegate   = self;
            tableView.dataSource = self;

            btnSync = [Helper createBlueButton:btnSynchronize.frame withTitle:@"Add/Remove Areas"];

            [btnSynchronize removeFromSuperview];

            [self.view addSubview:btnSync];

            [btnSync addTarget:self action:@selector(synchronize:) forControlEvents:UIControlEventTouchUpInside];
        }



    - (void)viewDidUnload
        {
            [self setTableView:nil];
            [self setBtnSynchronize:nil];
            [super viewDidUnload];
        }



    - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
        {
            return YES;
        }



//
// This is called when "Add/Remove Areas" button is pressed.
// It will delete any areas selected for delete, and download
// any areas selected for download.
//
    - (void)synchronize:(id)btn
        {
            int count = 0;
            DownloadableArea      *deleteArea;
            
            // Check if there are areas to delete
            for (DownloadableArea *area in self.rows)
                {
                    if (!area.selected && area.localStorage)
                        {
                            count++;
                            deleteArea = area;
                        }
                }

            if (count > 0)
                {
                    NSString *message;
                    if (count == 1)
                        message = @"Are you sure you want to delete this area? All changes since last synchronization will be lost.";
                    else
                        message = @"Are you sure you want to delete these areas? All changes since last synchronization will be lost.";
                    
                    NSString    *title = [NSString stringWithFormat:@"Delete Area %@", deleteArea.name];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete", nil];
                    [alert show];
                }
            else
                {
                    [self.delegate manageAreaSync:_rows withContainers:azureContainers];
                }
        }



// Delete an area that the user indicated they wanted deleted via the Manage Areas form.
    - (void)alertView:(UIAlertView *)alertView
 clickedButtonAtIndex:(NSInteger)buttonIndex
        {
            if (buttonIndex == 0)
                return;
            // Ok -- delete the directories and all the files contained

            for (DownloadableArea *area in self.rows)
                {
                    if (!area.selected && area.localStorage)
                        {
                            [Helper deleteDirectory:[Helper fileSystemContainerName:area.name]];
                        }
                }
            // Now call the synchronize areas
            [self.delegate manageAreaSync:_rows withContainers:azureContainers];
        }


#pragma mark - Table view data source



    - (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
        {
            return 1;
        }


    // The datasource for the tableview is the NSArray rows that is defined in this class.
    - (NSInteger)tableView:(UITableView *)tableView
     numberOfRowsInSection:(NSInteger)section
        {

            return [_rows count];
        }


    // The tableview calls this method when it needs to set up the cells for display to the user.
    // Setup the cell by putting the Area name, Area size, and adjusting the button and label text to reflect it's installed status.
    - (UITableViewCell *)tableView:(UITableView *)tblView
             cellForRowAtIndexPath:(NSIndexPath *)indexPath
        {
            UITableViewCell *cell;
            DCRoundSwitch   *switchBtn;
            int tag = 100 + indexPath.row;


            NSString *identifier = @"SelectedCell%d";
            cell = [tblView dequeueReusableCellWithIdentifier:identifier];
            if (cell == nil)
                {
                    cell      = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
                    
                    //DBaun 2014-03-12: Move the switch over closer to "AreaXX" so that there's more room for the size value on the right side of the cell
                    switchBtn = [[DCRoundSwitch alloc] initWithFrame:CGRectMake(150, 5, 160, 30)];
                    switchBtn.tag = tag;
                    [cell.contentView addSubview:switchBtn];
                }
            else
                {
                    for (int i = 100; i < 200; i++)
                        {
                            switchBtn = (DCRoundSwitch *) [cell viewWithTag:i];
                            if (switchBtn != nil)
                                break;
                        }
                }
            switchBtn.tag = tag;
            DownloadableArea *darea = [_rows objectAtIndex:[indexPath row]];


            [switchBtn addTarget:self action:@selector(switchBtn:) forControlEvents:UIControlEventValueChanged];
            if (darea.localStorage)
                {
                    switchBtn.onText      = @"Installed";
                    switchBtn.offText     = @"Remove";
                    switchBtn.onTintColor = [UIColor greenColor];
                }
            else
                {
                    switchBtn.onText      = @"Install";
                    switchBtn.offText     = @"Not installed";
                    switchBtn.onTintColor = [UIColor blueColor];
                    [switchBtn setOn:NO animated:NO];
                }
            [switchBtn setOn:darea.selected animated:NO];


            cell.textLabel.text = darea.name;
            
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%6.4f MB", darea.areaSize];
            
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            
            return cell;
        }



    - (void)switchBtn:(id)sender
        {
            UISwitch         *btn   = sender;
            DownloadableArea *darea = [_rows objectAtIndex:(btn.tag - 100)];
            darea.selected          = btn.on;
        }


#pragma mark - Access the Azure information



    //
    //  ..........SAMPLE OF *requester..........
    //   delegate                           = <ManageAreas: 0xdbb1320>
    //   requestType                        = 2
    //   containerRequested                 = (null)
    //   containerIndex                     = 0
    //   includeBlobsInToContainers         = YES
    //   arrayOfAzureContainersToGet count  = 0
    //
    //  ..........SAMPLE OF *configuration..........
    //     checkAzureFile = 1;
    //     currentArea = Area01;
    //     downloading = 0;
    //     fullUserName = nil;
    //     guid = "EF80C3E4-E5EB-4FD6-9CE2-BA33AFE577A0";
    //     lastCheckinAzureTime = "2014-07-31 01:10:48 +0000";
    //     lockingCode = 0000;
    //     menuAtBottom = 1;
    //     rendererUpdateDate = nil;
    //     requiredAfter = 1;
    //     simpleToken = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name=kc\\baund&Issuer=http://self&Audience=http://localhost:61719/iRealPropertyService.svc&ExpiresOn=1406852595&HMACSHA256=d0SUP1%2fMNWvfRtOWs30yX4";
    //     syncImageOver3G = nil;
    //     syncOver3G = nil;
    //     tabToLog = 0;
    //     useEffects = 1;
    //     userLevel = 2;
    //     userName = DBAU;
    //
    - (void)getFullListOfContainers
        {
            activity = [ATActivityIndicator currentIndicator];
            [activity displayActivity:@"Get Info"];

            requester = [[Requester alloc] init:[RealPropertyApp getDataUrl]];
            requester.delegate = self;

            Configuration *configuration = [RealPropertyApp getConfiguration];

            [requester executeGetAzureContainersList:configuration.simpleToken includingBlobs:YES];
        }



    - (void)requestDidFail:(Requester *)r
                 withError:(NSError *)error
        {
            [activity hide];
            // [self closeManageArea:nil];
            [Helper alertWithOk:@"Error" message:@"Impossible to download the list of areas at this time. Please try again"];
        }



    - (void)requestGetAzureContainersListDone:(Requester *)r
                               withContainers:(NSArray *)containers
        {
            [activity hide];
            azureContainers = containers;

            //BOOL isTestApp = [Helper isThisATestVersion];
            BOOL isTestApp = [RealPropertyApp isUserLoggedInTestMode ];
            
            // This will hold the areas (not common) for display in the Manage Areas form tableview.
            NSMutableArray *areasToDisplayInTableview = [[NSMutableArray alloc] init];
            
            // Which directories exist on the device, indicating the area is already downloaded.
            NSArray *areasAlreadyOnTheDevice = [Helper findAllDirectories:@"Area"];

            
            for (AzureContainer *thisContainer in containers)
                {
                    // Determine which containers retured from Azure should be listed in the Manage Areas tableview.
                    NSRange range;
                    NSString* areaNamePrefix;
                    
                    
                    if (isTestApp)
                        areaNamePrefix = @"TestArea";
                    else
                        areaNamePrefix = @"Area";
                    
                    
                    range = [thisContainer.name rangeOfString:areaNamePrefix options:NSCaseInsensitiveSearch];
                    
                    // If the container name does not start with "Area" or "TestArea"
                    // then skip over the rest of this for loop and continue with next container.
                    if (range.location != 0)
                        continue;
                    
                    // Adjust the container name so that it uses the capitalization defined above and appends the numbers on the end)
                    thisContainer.name = [areaNamePrefix stringByAppendingString:[thisContainer.name substringFromIndex:range.length]];

                    // Skip all the areas except 61 for testing purpose
                    if ([RealPropertyApp isUserLoggedInTestMode])
                        {
                            if ([thisContainer.name caseInsensitiveCompare:@"Area61"] != NSOrderedSame)
                                continue;
                        }


                    DownloadableArea *anAreaToDisplay = [[DownloadableArea alloc] init];

                    // For this container, if it's already on the device, then indicate that so that information can be used later
                    // such as to configure the state of the slider button as Installed or not, so the user can see what's already
                    // on their device.
                    for (NSString  *anInstalledArea in areasAlreadyOnTheDevice)
                        {
                            // TODO: Instead of case insensitive compare of the whole string, i have to check that the string contains area, as area is the only folders stored on device (not testarea)
                            if ([anInstalledArea caseInsensitiveCompare:[thisContainer.name substringFromIndex:4]] == NSOrderedSame)
                                {
                                    anAreaToDisplay.localStorage = YES;
                                    anAreaToDisplay.selected     = YES;
                                    break;
                                }
                        }

                    anAreaToDisplay.name     = thisContainer.name;
                    anAreaToDisplay.areaSize = 0;

                    // Add up the total size of all the blobs on this container to display in the Manage Areas form.
                    unsigned long long totalAreaSize = 0;
                    for (AzureBlob *aBlob in thisContainer.blobs)
                        {
                            totalAreaSize += aBlob.length;
                        }
                    
                    anAreaToDisplay.areaSize = totalAreaSize / (1024.0 * 1024.0);

                    [areasToDisplayInTableview addObject:anAreaToDisplay];
                }

            self.rows  = areasToDisplayInTableview;

            [tableView reloadData];
        }


@end
