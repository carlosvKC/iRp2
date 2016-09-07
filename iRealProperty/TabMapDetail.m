#import "TabMapDetail.h"
#import "AxDataManager.h"
#import "Helper.h"
#import "MediaView.h"
#import "RealPropertyApp.h"
#import <ArcGIS/ArcGIS.h>
#import "RealProperty.h"
#import "TabPicturesController.h"
#import "Bookmark.h"
#import "SelectedObject.h"
#import "DashboardToDoData.h"
#import "DashboardToDoTableViewController.h"

#define _DetailsCellTextHeight_     20
#define _DetailsCellMediaHeight_    80
#define _DetailsLines_              4


@implementation DetailsDefinition

    @synthesize labelName;
    @synthesize labelValue;

@end


@implementation DetailsSection

    @synthesize details;
    @synthesize sectionName;





    - (id)initWithName:(NSString *)name
        {
            self = [super init];
            if (self)
                {
                    details     = [[NSMutableArray alloc] init];
                    sectionName = name;
                }
            return self;
        }
@end


//--------------------------
// tabMapDetail
//--------------------------
@implementation TabMapDetail
{
    DashboardToDoData *todoData;
    UIPopoverController *theToDoItemsPopover;
}

    @synthesize rightButton;
    @synthesize leftButton;
    @synthesize cameraButton;
    @synthesize bookmarkButton;

    @synthesize parentMap;
    @synthesize tableView;
    @synthesize tableController;

    @synthesize draggableBar;
    @synthesize delegate;

#pragma mark - Draggable
    - (void)draggedBy:(CGPoint)delta
        {
            CGPoint origin = self.view.frame.origin;

            origin.x += delta.x;
            origin.y += delta.y;

            if (origin.y < 45)
                origin.y = 45;

            self.view.frame = CGRectMake(origin.x, origin.y, self.view.frame.size.width, self.view.frame.size.height);
        }
#pragma mark - handle rotation
    - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
        {
            return YES;
        }



    - (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                    duration:(NSTimeInterval)duration
        {
            int height = 648;
            if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation))
                height = 892;

            UIView *view;
            view = self.view;
            view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y,
                    375, height);
            // Adjust the borders
            view = [self.view viewWithTag:10];
            view.frame = CGRectMake(0, 33, 2, height - 33);
            view = [self.view viewWithTag:11];
            view.frame = CGRectMake(0, height - 2, 375, 2);
            view = [self.view viewWithTag:12];
            view.frame = CGRectMake(373, 33, 2, height - 33);

            // Adjust the table height
            tableView.frame = CGRectMake(0, 239, 375, height - 239);
        }



    - (id)initWithNibName:(NSString *)nibNameOrNil
                   bundle:(NSBundle *)nibBundleOrNil
        {
            self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
            return self;
        }


    - (IBAction)selectToDoButton:(id)sender {
        // Display the popover
        [self displayDashboardPopoverOnButton:self.toDoButton];
    }


    - (IBAction)selectHomeButton:(id)sender
        {
            SelectedProperties *selectProperties = [RealProperty selectedProperties];

            if (selectProperties == nil || selectProperties.memGrid.count == 0)
                {
                    selectProperties = [[SelectedProperties alloc] initWithRealPropInfo:realPropInfo];
                    [RealProperty setSelectedProperties:selectProperties];
                }
            //cv///
//            NSPredicate  *predicate    = [NSPredicate predicateWithFormat:@"guid=%@", rpGuid];
//            RealPropInfo *rpInfo = [AxDataManager getEntityObject:@"RealPropInfo" andPredicate:predicate];

            [delegate tabMapDetailSwitchHome:realPropInfo];
//            rpInfo = nil;
        }



    - (IBAction)selectCameraButton:(id)sender
        {
            SelectedProperties *selectProperties = [[SelectedProperties alloc] initWithRealPropInfo:realPropInfo];
            [RealProperty setSelectedProperties:selectProperties];

            [delegate tabMapDetailSwitchCamera:realPropInfo];
        }



    - (IBAction)selectRightButton:(id)sender
        {
            mediaIndex++;

            // 2/20/13 HNN support vacant properties
            media = [RealProperty getPicture:realPropInfo index:mediaIndex];

            [self displayMedia];
            [self adjustArrows];
        }



    - (IBAction)selectPosition:(id)sender
        {
            [delegate tabMapDetailPosition:realPropInfo];
        }



    - (IBAction)selectBookmark:(id)sender
        {
            menu = [[MenuTable alloc] initFromResource:@"MenuBookmark"];
            [menu presentMenu:bookmarkButton.frame withView:self.view withDelegate:self];
        }



    - (void)menuTableMenuSelected:(NSString *)menuName
                          withTag:(int)tag
                        withParam:(id)param
        {
            NSManagedObjectContext *context = [AxDataManager defaultContext];
            if ([(NSString *) param compare:@"d10"] == NSOrderedSame)
                {
                    [self createBookmarkReason];
                    return;
                }
            NSInteger typeItemId = [[param substringFromIndex:1] integerValue];

            NSString *menuNameStr = menuName;
            if ([menuNameStr compare:@"MenuBookmark"] == NSOrderedSame)
                {
                    NSPredicate  *predicate = [NSPredicate predicateWithFormat:@"rpGuid=%@ AND typeItemId=%d", rpGuid,typeItemId];
                    Bookmark *bookmark  = [AxDataManager getEntityObject:@"Bookmark" andPredicate:predicate andContext:[AxDataManager defaultContext]];
                    if (bookmark == nil)
                        {
                            // Add the current property to the list of objects
                            Bookmark *bookmark = [AxDataManager getNewEntityObject:@"Bookmark" andContext:[AxDataManager defaultContext]];
                            bookmark.rpGuid = rpGuid;
                            bookmark.addedDate  = [[Helper localDate] timeIntervalSinceReferenceDate];
                            bookmark.descr = [menu getMenuName:param];
                            bookmark.typeItemId = [NSNumber numberWithInt:typeItemId];
                            bookmark.hasError = NO;
                            bookmark.rowStatus =@"I";
                            bookmark.updateDate = [[Helper localDate] timeIntervalSinceReferenceDate];
                            bookmark.updatedBy = [RealPropertyApp getUserName];
                            
                            [realPropInfo addBookmarkObject:bookmark];
                            
                        }
                    else
                        {
                            bookmark.addedDate = [[Helper localDate] timeIntervalSinceReferenceDate];
                        }
                    [bookmarkButton setImage:[UIImage imageNamed:@"BookmarkEmpty.png"] forState:UIControlStateNormal];
                    [context save:nil];
                    [[AxDataManager defaultContext] save:nil];
                }
        }



    - (IBAction)selectLeftButton:(id)sender
        {
            mediaIndex--;

            // 2/20/13 HNN support vacant properties
            media = [RealProperty getPicture:realPropInfo index:mediaIndex];

            [self displayMedia];
            [self adjustArrows];
        }



    - (void)adjustArrows
        {
            if (maxMediaIndex <= 1)
                {
                    leftButton.enabled  = NO;
                    rightButton.enabled = NO;
                    return;
                }
            if (mediaIndex == 0)
                {
                    leftButton.enabled  = NO;
                    rightButton.enabled = YES;
                    return;
                }
            if (mediaIndex == maxMediaIndex - 1)
                {
                    leftButton.enabled  = YES;
                    rightButton.enabled = NO;
                    return;
                }
            leftButton.enabled  = YES;
            rightButton.enabled = YES;
            return;
        }



    - (void)didReceiveMemoryWarning
        {
            // Releases the view if it doesn't have a superview.
            [super didReceiveMemoryWarning];

            // Release any cached data, images, etc that aren't in use.
        }



    - (void)initDataWithRealPropId:(int)realPropId
        {
            tableController = [[DetailTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
            
            propertyId = realPropId;
            [tableController initDataWithRealPropId:realPropId];
            [self updateBookmark];

        }

    - (void)initDataWithrpGuid:(NSString *)rpInfoGuid realPropId:(int)realPropId
        {
            tableController = [[DetailTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
            [tableController initDataWithrpGuid:rpInfoGuid];
            rpGuid = rpInfoGuid;
            propertyId = realPropId;
            [self updateBookmark];
        }

#pragma mark - Update the bookmark button


- (void)updateBookmark
        {

            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"rpGuid=%@", rpGuid];
            Bookmark  *bm        = [AxDataManager getEntityObject:@"Bookmark" andPredicate:predicate andContext:[AxDataManager defaultContext]];
            if (bm == nil)
                [bookmarkButton setImage:[UIImage imageNamed:@"BookmarkEmpty.png"] forState:UIControlStateNormal];
            else
                [bookmarkButton setImage:[UIImage imageNamed:@"Book Open.png"] forState:UIControlStateNormal];
        }



    - (void)createBookmarkReason
        {
            bmReason = [[BookmarkReason alloc] initWithNibName:@"BookmarkReason" bundle:nil];
            bmReason.delegate = self;

            [bmReason willRotateToInterfaceOrientation:[Helper deviceOrientation] duration:0];
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:bmReason];
            navController.modalPresentationStyle = UIModalPresentationFormSheet;
            [self presentViewController:navController animated:YES completion:^(void)
                {
                }];

            // use the box full size
            // navController.view.superview.frame = bmReason.view.frame; // CGRectMake(0, 0, size.width, size.height);
            //navController.view.superview.center = self.view.superview.superview.center;
        }



    - (void)didDismissModalView:(NSObject *)dialog
                    saveContent:(BOOL)saveContent
        {
            if (saveContent)
                {
                    [self createBookmarkWithReason:((BookmarkReason *) dialog).details.text hasError:NO withInfo:realPropInfo];
                }
            [self dismissViewControllerAnimated:YES completion:nil];
        }

- (void)createBookmarkWithReason:(NSString *)reason
                        hasError:(BOOL)hasError
                        withInfo:(RealPropInfo *)info
{
    NSPredicate    *predicate = [NSPredicate predicateWithFormat:@"rpGuid=%@ AND descr=%@", rpGuid, reason];
    
    Bookmark    *bookmark  = [AxDataManager getEntityObject:@"Bookmark" andPredicate:predicate andContext:[AxDataManager defaultContext]];
    if (bookmark == nil)
    {
        // Add the current property to the list of objects
        Bookmark *bookmark = [AxDataManager getNewEntityObject:@"Bookmark" andContext:[AxDataManager defaultContext]];
        bookmark.rpGuid = rpGuid;
        bookmark.addedDate  = [[Helper localDate] timeIntervalSinceReferenceDate];
        bookmark.typeItemId = [NSNumber numberWithInt:10];
        bookmark.hasError   = hasError;
        bookmark.descr  = reason;
        bookmark.rowStatus = @"I";
        bookmark.updatedBy = [RealPropertyApp getUserName];
        bookmark.updateDate  = [[Helper localDate] timeIntervalSinceReferenceDate];        
        [info addBookmarkObject:bookmark];
        
    }
    else
    {
        bookmark.addedDate = [[Helper localDate] timeIntervalSinceReferenceDate];
        //bookmark.type    = reason;
        bookmark.descr  = reason;
        bookmark.hasError  = hasError;
    }
    NSManagedObjectContext *context   = [AxDataManager defaultContext];
    [context save:nil];
    [bookmarkButton setImage:[UIImage imageNamed:@"BookmarkEmpty.png"] forState:UIControlStateNormal];
}


//    - (void)createBookmarkWithReason:(NSString *)reason
//                            hasError:(BOOL)hasError
//        {
//            NSPredicate    *predicate = [NSPredicate predicateWithFormat:@"rpGuid=%@ AND descr=%@", rpGuid, reason];
//
//            Bookmark    *bookmark  = [AxDataManager getEntityObject:@"Bookmark" andPredicate:predicate andContext:[AxDataManager defaultContext]];
//            if (bookmark == nil)
//                {
//                    // Add the current property to the list of objects
//                    Bookmark *bookmark = [AxDataManager getNewEntityObject:@"Bookmark" andContext:[AxDataManager defaultContext]];
//                    bookmark.rpGuid = rpGuid;
//                    bookmark.addedDate  = [[Helper localDate] timeIntervalSinceReferenceDate];
//                    bookmark.typeItemId = [NSNumber numberWithInt:10];
//                    bookmark.hasError   = hasError;
//                    bookmark.descr  = reason;
//                    bookmark.rowStatus = @"I";
//                    bookmark.updatedBy = [RealPropertyApp getUserName];
//                    bookmark.updateDate  = [[Helper localDate] timeIntervalSinceReferenceDate];
//                    //need to know which parcel the user has click on it
//                    
//                    [realPropInfo addBookmarkObject:bookmark];
//
//                }
//            else
//                {
//                    bookmark.addedDate = [[Helper localDate] timeIntervalSinceReferenceDate];
//                    //bookmark.type    = reason;
//                    bookmark.descr  = reason;
//                    bookmark.hasError  = hasError;
//                }
//            NSManagedObjectContext *context   = [AxDataManager defaultContext];
//            [context save:nil];
//            [bookmarkButton setImage:[UIImage imageNamed:@"BookmarkEmpty.png"] forState:UIControlStateNormal];
//        }

#pragma mark - View lifecycle

    - (void)displayMedia
        {
            UIImageView *imageView = (UIImageView *) [self.view viewWithTag:45];
            if (media != nil)
                imageView.image = [MediaView getImageFromMiniMedia:media];
            // 2/21/13 HNN resize propertionally
            imageView.contentMode = UIViewContentModeScaleAspectFit;
        }



    - (void)viewDidLoad
        {
            [super viewDidLoad];

            tableController.tableView            = tableView;
            tableController.tableView.delegate   = tableController;
            tableController.tableView.dataSource = tableController;
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"realPropId=%d", propertyId];
            realPropInfo = [AxDataManager getEntityObject:@"RealPropInfo" andPredicate:predicate];
            
            rpGuid = realPropInfo.guid;
            if (realPropInfo == nil)
                return;

            // Get the appropriate media
            media = [RealProperty getPicture:realPropInfo];
            [self displayMedia];
            mediaIndex    = [RealProperty findCurrentMedia:realPropInfo media:media];
            maxMediaIndex = [RealProperty getNumberOfMedias:realPropInfo];

            [self adjustArrows];

            self.workingBase = realPropInfo;
            [self setScreenEntities];

            // Handle the checkboxes

            chkLand = (CheckBoxView *) [self.view viewWithTag:24];
            chkLand.delegate = self;
            chkImps = (CheckBoxView *) [self.view viewWithTag:25];
            chkImps.delegate = self;
            chkBoth = (CheckBoxView *) [self.view viewWithTag:26];
            chkBoth.delegate = self;

            chkLand.enabled = YES;
            chkImps.enabled = YES;
            chkBoth.enabled = YES;

            inspection = [[InspectionManager alloc] initWithPropId:propertyId realPropInfo:realPropInfo];

            int value                     = [inspection getCurrentState];
            switch (value)
                {
                    case 1:
                        chkLand.checked = YES;
                    break;
                    case 2:
                        chkImps.checked = YES;
                    break;
                    case 3:
                        chkBoth.checked = YES;
                    chkImps.checked     = YES;
                    chkLand.checked     = YES;
                    break;
                }
            draggableBar.dragableDelegate = self;

            UIView *view = [self.view viewWithTag:50];
            [view removeFromSuperview];
            UIButton *btn = [Helper createBlueButton:view.frame withTitle:@"done"];
            [self.view addSubview:btn];
            [btn addTarget:self action:@selector(closeView:) forControlEvents:UIControlEventTouchUpInside];

            [self willRotateToInterfaceOrientation:[Helper deviceOrientation] duration:0];

            NSSet *set = realPropInfo.resBldg;

            if (set.count == 0)
                cameraButton.hidden = YES;

            [self updateBookmark];
            
        }



    - (void)viewDidUnload
        {
            [self setTableView:nil];
            [self setRightButton:nil];
            [self setLeftButton:nil];
            [self setDraggableBar:nil];
            [self setCameraButton:nil];
            [self setToDoButton:nil];
            [super viewDidUnload];
            // Release any retained subviews of the main view.
            // e.g. self.myOutlet = nil;
        }



    - (void)viewWillAppear:(BOOL)animated
        {
            [super viewWillAppear:animated];
        }



    - (void)viewDidAppear:(BOOL)animated
        {
            [super viewDidAppear:animated];
            
            // RUN QUERIES
            // ADD OR REMOVE THE BADGE AS NEEDED.
            [self runDashboardQueries];
        }



    - (void)viewWillDisappear:(BOOL)animated
        {
            [super viewWillDisappear:animated];
        }



    - (void)viewDidDisappear:(BOOL)animated
        {
            [super viewDidDisappear:animated];
        }



    - (void)closeView:(id)btn
        {
            [delegate tabMapDetailIsDone];
        }
#pragma mark - Handle the checkboxes
    - (void)checkBoxClicked:(id)checkBox
                  isChecked:(BOOL)checked
        {
            [checkBox setChecked:checked];

            if (checkBox == chkBoth)
                {
                    [chkImps setChecked:checked];
                    [chkLand setChecked:checked];
                }

            if (chkImps.checked != chkLand.checked)
                chkBoth.checked = NO;
            if (chkImps.checked == YES && chkLand.checked == YES)
                chkBoth.checked = YES;

            int value = 0;
            if (chkBoth.checked)
                value = 3;
            else if (chkLand.checked)
                value = 1;
            else if (chkImps.checked)
                value = 2;
            [inspection setCurrentState:value commit:YES];
            // Need to bubble up to the map to redisplay
            [delegate tabMapDetailRefreshLayers];
        }
#pragma mark - display the picture

    - (void)switchToPictureController:(NSArray *)medias
                             selected:(id)mediaParam
                       fromController:(ScreenController *)controller
        {
            if (tabPicturesController == nil)
                tabPicturesController = [[TabPicturesController alloc] initWithNibName:@"TabPicturesController" bundle:nil];
            
            tabPicturesController.propertyController = nil;
            tabPicturesController.itsController      = self;
            tabPicturesController.medias             = (NSMutableArray *) medias;
            tabPicturesController.currentMedia       = mediaParam;
            tabPicturesController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            
            [self presentViewController:tabPicturesController animated:YES completion:^(void){}];
            
//            UIView *view = [self.view viewWithTag:1020];
//            if (view == nil)
//                {
//                    NSLog(@"cant find view 1020");
//                    return;
//                }
//            [view addSubview:tabPicturesController.view];
//            [view bringSubviewToFront:tabPicturesController.view];
//            [self addChildViewController:tabPicturesController];

//            tabPicturesController.view.frame = CGRectOffset(tabPicturesController.view.frame, 1024, 0);
//            // ANIMATE: move from right to left
//            [view bringSubviewToFront:tabPicturesController.view];
//
//            [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^
//                {
//                    tabPicturesController.view.frame = CGRectOffset(tabPicturesController.view.frame, -1024, 0);
//                }            completion:nil];

            
            
        }



    - (void)switchBackFromPictureController
        {
            [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^
             {
                 tabPicturesController.view.frame = CGRectOffset(tabPicturesController.view.frame, 1024, 0);
             }            completion:^(BOOL finished)
             {
                 [tabPicturesController.view removeFromSuperview];
                 [tabPicturesController removeFromParentViewController];
                 tabPicturesController.view = nil;
                 tabPicturesController = nil;
             }];
        }



// Display the details of the pictures
    - (IBAction)displayPicture:(id)sender
        {
            
            // Media is defined as an NSSet, and switchToPictureController expects an NSArray
            NSArray *picts = [RealProperty getAllBuildingPictures:realPropInfo];
            [self switchToPictureController:picts selected:nil fromController:self];
        }



#pragma mark - Dashboard ToDo members

    - (void)runDashboardQueries
    {
        if (!todoData)
            todoData = [[DashboardToDoData alloc]init];
        
        if (!realPropInfo) {
            NSLog(@"No valid realPropInfo, so exiting method")
            return;
        }

        
        [todoData theToDoItemsforAssmtYr:[RealPropertyApp taxYear]-1
                           andRealPropId:realPropInfo.realPropId
                               andRpGuid:realPropInfo.guid
                              andLndGuid:realPropInfo.lndGuid
                             andPropType:realPropInfo.propType // @"R"
                      withManagedContext:realPropInfo.managedObjectContext];
        
        if ([todoData.toDoItems count]>0) {
            //MKNumberBadgeView *theBadge = [[MKNumberBadgeView alloc]initWithFrame:CGRectMake(32, -5, 18, 18)]; // :CGRectMake(0, 0, 15, 15)
            MKNumberBadgeView *theBadge = [self getBadgeFromToDoButton:self.toDoButton];
            theBadge.shadow = YES;
            theBadge.shine = YES;
            theBadge.fillColor = [UIColor redColor];
            theBadge.strokeColor = [UIColor whiteColor];
            theBadge.backgroundColor = [UIColor redColor];
            theBadge.alignment = NSTextAlignmentCenter;
            theBadge.value = [todoData.toDoItems count];
            
            [self.toDoButton addSubview:theBadge];
            [self.toDoButton setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
            
        }
        else
            [self removeBadgeFromToDoButton:self.toDoButton];
        
    }



    -(MKNumberBadgeView*)getBadgeFromToDoButton:(UIButton*)theButton
    {
        MKNumberBadgeView *theBadge = nil;
        
        if ([[theButton subviews] count]>0)
        {
            //Get reference to the subview, and if it's a badge, remove it from it's parent (the button)
            
            int initalValue = [[theButton subviews] count]-1;
            
            for (int i=initalValue; i>=0; i--) {
                
                //NSLog(@"Found a ToDo button subview of class %@",NSStringFromClass([[[theButton subviews] objectAtIndex:i] class]));
                
                if ([[[theButton subviews] objectAtIndex:i] isMemberOfClass:[MKNumberBadgeView class]])
                {
                    if (theBadge == nil) {
                        theBadge = [[theButton subviews] objectAtIndex:i];
                    }
                    else {
                        [[[theButton subviews] objectAtIndex:i] removeFromSuperview];
                        [theButton setTitleColor:[UIColor lightTextColor] forState:UIControlStateNormal];
                    }
                }
            }
        }
        
        if (theBadge == nil) {
            theBadge = [[MKNumberBadgeView alloc]initWithFrame:CGRectMake(32, -5, 18, 18)];
        }
        
        return theBadge;
    }



    -(void)removeBadgeFromToDoButton:(UIButton*)theButton
    {
        if ([[theButton subviews] count]>0)
        {
            int initalValue = [[theButton subviews] count]-1;
            //Get reference to the subview, and if it's a badge, remove it from it's parent (the button)
            for (int i=initalValue; i>=0; i--) {
                
                if ([[[theButton subviews] objectAtIndex:i] isMemberOfClass:[MKNumberBadgeView class]])
                {
                    [[[theButton subviews] objectAtIndex:i] removeFromSuperview];
                    [theButton setTitleColor:[UIColor lightTextColor] forState:UIControlStateNormal];
                }
            }
        }
        
    }


    -(void)displayDashboardPopoverOnButton:(id)theButton
    {
        // Create the popover content view controller from the nib.
        // Create a popover and initialize it with the tableview
        // Size the popover... width MUST be between 320 and 600
        // Present the popover
        
        int popoverHeight = 1;
        
        if ([todoData.toDoItems count]>0)
        {
            popoverHeight = [todoData.toDoItems count];
            
            DashboardToDoTableViewController *theTableViewController = [[DashboardToDoTableViewController alloc] init];
            theTableViewController.dashboardToDoDelegate = self;
            theTableViewController.listOfItems = todoData.toDoItems;
            theToDoItemsPopover = [[UIPopoverController alloc] initWithContentViewController:theTableViewController];
            theToDoItemsPopover.delegate = self;
            
            [theToDoItemsPopover setPopoverContentSize:CGSizeMake(320, popoverHeight*44) animated:YES];
            [theToDoItemsPopover presentPopoverFromRect:[theButton bounds] inView:theButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:(YES)];
        }
        
    }


    - (void)popoverControllerDidDismissPopover:(UIPopoverController *)popover
    {
        if (theToDoItemsPopover && ( popover == theToDoItemsPopover))
            popover = nil;
    }



    - (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController
    {
        return YES;
    }


    -(void)toDoListSelectedItem:(NSString *)item
    {
        
    }

@end




#pragma mark - Handle the data store
@implementation DetailTableViewController

    @synthesize parcelNbr;



    - (void)createSection:(id)baseEntity
                 withName:(NSString *)name
         screenDefinition:(ScreenDefinition *)screen
        {
            DetailsSection *section = [[DetailsSection alloc] initWithName:name];

            for (ItemDefinition *prop in screen.items)
                {
                    id object;
                    @try
                        {
                            if ([prop.entityName length] == 0 || prop.type == ftGrid || prop.type == ftEmbedded)
                                continue;
                            object = [ItemDefinition getItemValue:baseEntity property:prop.path];

                            if ([object isKindOfClass:[NSString class]] && [object length] == 0)
                                continue;
                            if ([object isKindOfClass:[NSNumber class]] && [object intValue] == 0)
                                continue;

                            NSString *string = [ItemDefinition getStringValue:baseEntity withPath:prop.path withType:prop.type withLookup:prop.lookup];
                            if ([string length] != 0)
                                {
                                    DetailsDefinition *detail = [[DetailsDefinition alloc] init];
                                    detail.labelName  = prop.labelName;
                                    detail.labelValue = string;
                                    [section.details addObject:detail];
                                }
                        }
                    @catch (NSException *ex)
                        {
                            NSLog(@"createSection error when retrieving '%@'", prop.path);
                            continue;
                        }
                    if (object == nil)
                        continue;
                }
            if ([section.details count] > 0)
                {
                    [sectionDetails addObject:section];
                }
        }



//
// Look at the details provided into "details"
//
    static NSString *fieldName;
    static BOOL fieldSortAscending;



    - (void)createDetails:(MultiScreenItem *)details
         withRealPropInfo:(RealPropInfo *)realPropInfo
        {
            // required to make sure to get the right zoning...
            [ItemDefinition setDistrictId:realPropInfo.districtId];

            ScreenDefinition *screen = [EntityBase getScreenWithName:details.screenName];
            if (screen == nil)
                {
                    NSLog(@"Can't find the screenDefinition=%@", details.screenName);
                    return;
                }
            id base;
            if ([details.path length] == 0)
                base = realPropInfo;
            else
                {
                    @try
                        {
                            base = [realPropInfo valueForKeyPath:details.path];
                        }
                    @catch (NSException *exception)
                        {
                            NSLog(@"Can't find path %@ on RealPropInfo", details.path);
                        }
                }
            if (![base isKindOfClass:[NSSet class]])
                [self createSection:base withName:details.label screenDefinition:screen];
            else
                {
                    NSArray *sortedArray;

                    if ([details.sortField length] != 0)
                        {
                            fieldName          = details.sortField;
                            fieldSortAscending = details.sortAscending;
                            // Sort the set
                            sortedArray        = [base sortedArrayUsingComparator:^(id object1,
                                                                                    id object2)
                                {
                                    @try
                                        {
                                            id m1 = [object1 valueForKey:fieldName];
                                            id m2 = [object2 valueForKey:fieldName];

                                            int order = NSOrderedSame;

                                            if ([m1 isKindOfClass:[NSString class]] && [m2 isKindOfClass:[NSString class]])
                                                order = [m1 caseInsensitiveCompare:m2];
                                            else if ([m1 isKindOfClass:[NSDate class]] && [m2 isKindOfClass:[NSDate class]])
                                                order = [m1 compare:m2];
                                            else if ([m1 isKindOfClass:[NSNumber class]] && [m2 isKindOfClass:[NSNumber class]])
                                                order = [m1 compare:m2];

                                            if (order == NSOrderedSame)
                                                return order;
                                            if (fieldSortAscending)
                                                return order;
                                            // Reverse sorting
                                            if (order == NSOrderedAscending)
                                                return NSOrderedDescending;
                                            return NSOrderedAscending;
                                        }
                                    @catch (NSException *exception)
                                        {
                                            NSLog(@"Object does not have %@", fieldName);
                                        }
                                    return NSOrderedSame;
                                }];
                        }
                    else
                        {
                            sortedArray = [base allObjects];
                        }

                    int count = 1;

                    for (id object in sortedArray)
                        {
                            NSString *string = [NSString stringWithFormat:@"%@ #%d", details.label, count++];
                            [self createSection:object withName:string screenDefinition:screen];
                        }

                }
        }



//
// Load a RealPropInfo using a RealPropId
// and create the different sections and entries required
//
    - (void)initDataWithRealPropId:(int)realPropId
        {
            NSPredicate  *predicate    = [NSPredicate predicateWithFormat:@"realPropId=%d", realPropId];
            RealPropInfo *realPropInfo = [AxDataManager getEntityObject:@"RealPropInfo" andPredicate:predicate];

            if (realPropInfo == nil)
                return;
            sectionDetails = [[NSMutableArray alloc] init];

            MultiScreenDefinition *mlsDefinition = [EntityBase getMultiScreenWithName:@"TabDetailsInMap"];
            for (MultiScreenItem  *item in mlsDefinition.screens)
                {
                    [self createDetails:item withRealPropInfo:realPropInfo];
                }
            //media = [RealPropertyApp getBuildingPicture:realPropInfo];

            parcelInfo   = [NSString stringWithFormat:@"%@-%@", realPropInfo.major, realPropInfo.minor];
            parcelNbr    = [realPropInfo.parcelNbr copy];
            rpGuid       = [realPropInfo.guid copy];
            //realPropInfo = nil;

            self.contentSizeForViewInPopover = self.tableView.frame.size;
        }

/// Load rpInfo using Guid
// and create the different sections and entries required
//
    - (void)initDataWithrpGuid:(NSString *)rpInfoGuid;
        {
            NSPredicate  *predicate    = [NSPredicate predicateWithFormat:@"guid=%@", rpInfoGuid];
            RealPropInfo *realPropInfo = [AxDataManager getEntityObject:@"RealPropInfo" andPredicate:predicate];
            if (realPropInfo == nil)
                return;
                sectionDetails = [[NSMutableArray alloc] init];
    
                MultiScreenDefinition *mlsDefinition = [EntityBase getMultiScreenWithName:@"TabDetailsInMap"];
                for (MultiScreenItem  *item in mlsDefinition.screens)
                    {
                        [self createDetails:item withRealPropInfo:realPropInfo];
                    }
    
                parcelInfo   = [NSString stringWithFormat:@"%@-%@", realPropInfo.major, realPropInfo.minor];
                parcelNbr    = [realPropInfo.parcelNbr copy];
                //realPropInfo = nil;
    
                self.contentSizeForViewInPopover = self.tableView.frame.size;

        }
#pragma mark - Table view data source

    - (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
        {
            return [sectionDetails count];
        }



    - (NSInteger)tableView:(UITableView *)tableView
     numberOfRowsInSection:(NSInteger)section
        {
            DetailsSection *sect = [sectionDetails objectAtIndex:section];
            return [sect.details count];
        }



    - (UITableViewCell *)tableView:(UITableView *)aTableView
             cellForRowAtIndexPath:(NSIndexPath *)indexPath
        {
            NSString *CellIdentifier = @"TextCell";

            // Get info on the section
            DetailsSection    *sect       = [sectionDetails objectAtIndex:[indexPath section]];
            DetailsDefinition *definition = [sect.details objectAtIndex:[indexPath row]];


            if (definition.labelName.length == 0)
                CellIdentifier = @"TextCellSingle";
            UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];

            if (cell == nil)
                {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                    int height = _DetailsCellTextHeight_;
                    if (definition.labelName.length == 0)
                        height *= _DetailsLines_;


                    CGRect cellRect = CGRectMake(0, 0, cell.frame.size.width, height);
                    cell.frame = cellRect;

                    if (definition.labelName.length == 0)
                        {
                            CGFloat w     = cell.frame.size.width;
                            CGRect  frame = CGRectMake(10, 0, w, cell.frame.size.height);
                            UILabel *label1 = [[UILabel alloc] initWithFrame:frame];
                            label1.numberOfLines = _DetailsLines_;
                            label1.tag           = 20;
                            label1.font          = [UIFont systemFontOfSize:14.0f];
                            [cell addSubview:label1];
                        }
                    else
                        {
                            // Add two labels to the cell
                            CGFloat sep   = 20;
                            CGFloat ratio = 0.4;

                            CGFloat w     = cell.frame.size.width;
                            CGRect  frame = CGRectMake(10, 0, ratio * w, cell.frame.size.height);
                            UILabel *label1 = [[UILabel alloc] initWithFrame:frame];
                            label1.tag  = 10;
                            label1.font = [UIFont systemFontOfSize:14.0f];
                            [cell addSubview:label1];

                            frame = CGRectMake(ratio * w + sep, 0, (1.0 - ratio) * w - sep, cell.frame.size.height);
                            UILabel *label2 = [[UILabel alloc] initWithFrame:frame];
                            label2.font = [UIFont systemFontOfSize:14.0f];
                            label2.tag  = 20;
                            [cell addSubview:label2];
                        }
                }

            UILabel *label1 = (UILabel *) [cell viewWithTag:10];
            UILabel *label2 = (UILabel *) [cell viewWithTag:20];

            label1.text = definition.labelName;
            label2.text = definition.labelValue;

            return cell;
        }



    - (NSString *)tableView:(UITableView *)tableView
    titleForHeaderInSection:(NSInteger)section
        {
            DetailsSection *sect = [sectionDetails objectAtIndex:section];
            return sect.sectionName;
        }
#pragma mark - Table view delegate
    - (void)                   tableView:(UITableView *)tableView
accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
        {
        }



    - (CGFloat)tableView:(UITableView *)tableView
 heightForRowAtIndexPath:(NSIndexPath *)indexPath
        {
            // Get info on the section
            DetailsSection    *sect       = [sectionDetails objectAtIndex:[indexPath section]];
            DetailsDefinition *definition = [sect.details objectAtIndex:[indexPath row]];

            if (definition.labelName.length == 0)
                return _DetailsLines_ * _DetailsCellTextHeight_;
            return _DetailsCellTextHeight_;
        }



    - (void)  tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
        {
        }



    - (void)viewDidUnload
        {
            [super viewDidUnload];
        }

@end
