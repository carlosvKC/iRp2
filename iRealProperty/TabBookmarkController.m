#import "TabBookmarkController.h"
#import "AxDataManager.h"
#import "Helper.h"
#import "Bookmark.h"
#import "TabMapDetail.h"
#import "SelectedObject.h"
#import "RealProperty.h"
#import "RealPropertyApp.h"
#import "TabSearchController.h"
#import "IRNote.h"
#import "MenuTable.h"

@implementation TabBookmarkController

    @synthesize scrollView;
    @synthesize noBookmarkDefined;
    @synthesize mapDetail;



    - (id)initWithNibName:(NSString *)nibNameOrNil
                   bundle:(NSBundle *)nibBundleOrNil
        {
            self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
            if (self)
                {
                    self.title            = @"Bookmark";
                    self.tabBarItem.image = [UIImage imageNamed:@"Book Open"];
                }
            return self;
        }



    - (void)didReceiveMemoryWarning
        {
            [super didReceiveMemoryWarning];
            // Release any cached data, images, etc that aren't in use.
        }



    - (void)bookmarkDraggedBy:(BookmarkController *)bookmark
                        delta:(CGPoint)delta
        {
        }


#pragma mark

//
// Add bookmarks to the screen
//
    - (void)addBookmarksToView
        {
            if (bookmarkViews == nil)
                {
                    bookmarkViews = [[NSMutableArray alloc] init];
                }
            else
                {
                    // Remove the existing ones
                    for (BookmarkController *b in bookmarkViews)
                        {
                            [b.view removeFromSuperview];
                            [b removeFromParentViewController];
                        }
                    [bookmarkViews removeAllObjects];
                }
            // Create a new controller to add to the view
            BookmarkController *tempBookmark = [[BookmarkController alloc] initWithNibName:@"Bookmark" bundle:nil];
            [self.view addSubview:tempBookmark.view];

            int bookmarkViewWidth  = tempBookmark.view.frame.size.width;
            int bookmarkViewHeight = tempBookmark.view.frame.size.height;

            [tempBookmark.view removeFromSuperview];
            tempBookmark = nil;

            NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"updatedBy=%@ AND rowStatus <> 'D'", [RealPropertyApp getUserName] ];
            //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(rowStatus <> 'D')"];
            // Add all the bookmarks to the scroll view -- ordered by the date they were added
            NSArray *bookmarks = [AxDataManager dataListEntity:@"Bookmark" andPredicate:predicate2 andSortBy:@"addedDate" sortAscending:NO withContext:[AxDataManager defaultContext ]];

            if (bookmarks.count == 0)
                {
                    noBookmarkDefined.hidden = NO;
                    [self.view addSubview:noBookmarkDefined];
                    [self.view bringSubviewToFront:noBookmarkDefined];

                    return;
                }
            else
                {
                    noBookmarkDefined.hidden = YES;
                    [noBookmarkDefined removeFromSuperview];
                }

            CGFloat width           = self.scrollView.frame.size.width;
            // get the number of horizontal bookmark
            int     bookmarksOnLine = (width - 2 * kBookmarkBorder) / bookmarkViewWidth;
            CGFloat separator       = (width - 2 * kBookmarkBorder - bookmarksOnLine * bookmarkViewWidth) / (bookmarksOnLine - 1);

            CGPoint corner  = CGPointMake(kBookmarkBorder, kBookmarkBorder);
            int     nOnLine = 0;            // how many on one line


            for (int index = 0; index < bookmarks.count; index++)
                {
                    Bookmark *bookmark = [bookmarks objectAtIndex:index];
                    BookmarkController   *bmc       = [[BookmarkController alloc] initWithNibName:@"Bookmark" bundle:nil];
                    bmc.bookmark = bookmark;

                    bmc.view.frame = CGRectMake(corner.x, corner.y, bookmarkViewWidth, bookmarkViewHeight);

                    bmc.delegate = self;
                    [self.scrollView addSubview:bmc.view];
                    [self addChildViewController:bmc];

                    nOnLine++;
                    if (nOnLine == bookmarksOnLine)
                        {
                            nOnLine = 0;
                            corner  = CGPointMake(kBookmarkBorder, corner.y + bookmarkViewHeight + kBookmarkSep);
                        }
                    else
                        {
                            corner = CGPointMake(corner.x + bookmarkViewWidth + separator, corner.y);
                        }
                    [bookmarkViews addObject:bmc];
                }
            int maxWidth = corner.y + bookmarkViewHeight + kBookmarkSep;

            if (maxWidth > self.scrollView.frame.size.height)
                {
                    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, maxWidth);

                }
        }



    - (void)hideDeleteView:(BOOL)hidden
        {
            for (BookmarkController *bmc in bookmarkViews)
                {
                    bmc.btnDelete.hidden = hidden;
                }
        }



    - (void)activateController
        {
            [self addBookmarksToView];
        }


#pragma mark - Call back event

    - (void)menuBarBtnSelected:(int)tag
        {

            if (tag == kBtnBookmarkMap)
                {
                    [self switchToMaps];
                    return;
                }
            if (tag == kBtnBookmarkGrid)
                {
                    gridVisible = !gridVisible;
                    if (gridVisible)
                        [self displayGrid];
                    else
                        [self displayDetail];
                    return;
                }

            editMode = !editMode;
            UIBarButtonItem *btn = [menuBar getBarButtonItem:kBmBtnDelete];

            GridController *grid = [gridController getFirstGridController];
            if (editMode)
                {
                    btn.title = @"Done";
                    [self hideDeleteView:NO];
                    if (gridVisible)
                        {
                            [grid setSingleSelection:YES];
                            [grid enterEditMode];
                            [menuBar setItemEnable:kBookmarkTrash isEnable:YES];
                        }
                }
            else
                {
                    [self hideDeleteView:YES];
                    btn.title = @"Edit";
                    if (gridVisible)
                        {
                            [grid setSingleSelection:YES];
                            [menuBar setItemEnable:kBookmarkTrash isEnable:NO];
                            [grid cancelEditMode];

                        }
                }

            if (tag == kBookmarkTrash)
                {
                    NSArray *selected = [grid getSelectedRows];
                    [self deleteSelectedRows:selected];
                    
                }
        }



    - (void)deleteSelectedRows:(NSArray *)selectedRows
        {
            GridController         *grid            = [gridController getFirstGridController];
            // Look for the NSSet to be deleted
            NSMutableArray         *objectsToDelete = [[NSMutableArray alloc] init];
            NSManagedObjectContext *context         = [AxDataManager defaultContext];
            for (id  row in selectedRows)
                {
                    NSString *rowstatus = @"D";
                    [row setValue:rowstatus forKey:@"rowStatus"];
                    
                    NSString *stageGuid=@"";
                    stageGuid =[row valueForKey:@"stagingGUID"];
                    if ([stageGuid length]== 0)
                    {
                    [objectsToDelete addObject:row];
                    }
                }
            // delete the objects
            for (int i                              = 0; i < [objectsToDelete count]; i++)
                {
                    [context deleteObject:[objectsToDelete objectAtIndex:i]];

                }
            //[context updatedObjects:[objectsToDelete];
             
            [context save:nil];
            objectsToDelete = nil;
            [self addBookmarksToView];
            [grid setGridContent:[self getDefaultOrderedList]];

            [grid refreshAllContent];
            [grid deselectAllRows];
            [TabBookmarkController updateBookmarkErrors];
            [[AxDataManager defaultContext] save:nil];


        }



// delete a bookmark
    - (void)deleteBookmark:(BookmarkController *)bookmarkView
        {
            NSManagedObjectContext *context         = [AxDataManager defaultContext];

            // Remove the current bookmark from the view and animate everything else!
            [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^
                {
                    // Remove the current bookmark
                    bookmarkView.view.hidden = YES;
                    [bookmarkView.view removeFromSuperview];
                    [bookmarkView removeFromParentViewController];
                    // Look for this entry in the list of views
                    int index = 0;
                    for (; index < bookmarkViews.count; index++)
                        {
                            if ([bookmarkViews objectAtIndex:index] == bookmarkView)
                                break;
                        }
                    CGPoint center = bookmarkView.view.center;
                    for (; index < bookmarkViews.count - 1; index++)
                        {
                            // Shift the center of the bookmark
                            BookmarkController *nextBookmark = [bookmarkViews objectAtIndex:index + 1];
                            CGPoint nextCenter = nextBookmark.view.center;
                            nextBookmark.view.center = center;
                            center = nextCenter;
                        }
                }
                             completion:^(BOOL finished)
                                 {
                                     // Remove from the list of bookmark
                                     [bookmarkViews removeObject:bookmarkView];
                                       // cv should be able to mark bookmark x deletion
                                         if([bookmarkView.bookmark.rowStatus isEqualToString:@"I"])
                                         {
                                     // delete it from the list of bookmarks...
                                             [[AxDataManager defaultContext] deleteObject:bookmarkView.bookmark];
                                             [[AxDataManager defaultContext] save:nil];
                                         }
                                         else
                                         {
                                             bookmarkView.bookmark.rowStatus = @"D";
                                             bookmarkView.bookmark.updateDate =[[Helper localDate]timeIntervalSinceReferenceDate];
                                         }
                                     [TabBookmarkController updateBookmarkErrors];
                                     [context save:nil];
                                     [[AxDataManager defaultContext] save:nil];

                                 }];
        }



    - (void)menuBarBtnBackSelected
        {
        }
#pragma mark - Call back to display more detail
    - (void)displayDetail:(BookmarkController *)bookmarkCtrl
        {
            mapDetail = [[TabMapDetail alloc] initWithNibName:@"TabMapDetail" bundle:nil];
            mapDetail.parentMap = nil;

            //[mapDetail initDataWithRealPropId:bookmark.bookmark.realPropId];
            [mapDetail initDataWithrpGuid:bookmarkCtrl.bookmark.rpGuid realPropId:0];
            // TestViewController *testView = [[TestViewController alloc]initWithNibName:@"TestViewController" bundle:nil];

            _popOver = [[UIPopoverController alloc] initWithContentViewController:mapDetail];


            CGRect rect = CGRectMake(bookmarkCtrl.view.frame.origin.x, bookmarkCtrl.view.frame.origin.y - self.scrollView.contentOffset.y, bookmarkCtrl.view.frame.size.width, bookmarkCtrl.view.frame.size.height);


            [_popOver presentPopoverFromRect:rect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];

            _popOver.delegate = self;
        }



    - (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
        {
            [_popOver dismissPopoverAnimated:YES];
            _popOver = nil;
        }
#pragma mark - View lifecycle

    - (void)viewDidLoad
        {
            [super viewDidLoad];
            // Add the Control bar
            UIView *view = [self.view viewWithTag:1010];
            if (view == nil)
                {
                    NSLog(@"MenuBar: can't find the view with tag 1010");
                    return;
                }
            menuBar = [[ControlBar alloc] initWithNibName:@"TabBookmarkControlBar" bundle:nil];
            [view addSubview:menuBar.view];
            [self addChildViewController:menuBar];
            menuBar.delegate = self;

            gridController = [[GridBookmark alloc] initWithNibName:@"GridBookmark" bundle:nil];
            gridController.itsController = nil;
            gridController.view.frame    = CGRectOffset(gridController.view.frame, 0, 44);

            if ([Helper isDeviceInLandscape])
                [self willRotateToInterfaceOrientation:UIInterfaceOrientationLandscapeLeft duration:0];
            else
                [self willRotateToInterfaceOrientation:UIInterfaceOrientationPortrait duration:0];

            [menuBar setItemEnable:kBookmarkTrash isEnable:NO];

        }



    - (void)viewDidUnload
        {
            self.scrollView = nil;
            [self setNoBookmarkDefined:nil];
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
            int width;
            // Resize the screens
            if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
                {
                    width = 1024;
                    noBookmarkDefined.frame = CGRectMake(0, 0, 1024, 748);
                    self.view.frame         = CGRectMake(0, 0, 1024, 697);
                }
            else
                {
                    width = 768;
                    noBookmarkDefined.frame = CGRectMake(0, 0, 768, 1004);
                    self.view.frame         = CGRectMake(0, 0, 768, 953);
                }
            scrollView.frame = CGRectMake(scrollView.frame.origin.x, scrollView.frame.origin.y,
                    width, scrollView.frame.size.height);
            [self addBookmarksToView];

            UIView *view = [self.view viewWithTag:1010];
            view.frame         = CGRectMake(0, 0, width, 44);
            menuBar.view.frame = CGRectMake(0, 0, width, 44);

            if (editMode)
                {
                    [self hideDeleteView:NO];
                }
            [gridController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
        }
#pragma mark - bookmark delegate
    - (void)bookmarkDelete:(BookmarkController *)bmkc
        {
            [self deleteBookmark:bmkc];
//            [self runDashboardQueries];
//            [context save:nil];

        }



    - (void)bookmarkEditNote:(BookmarkController *)bmkc
        {
            IRNote      *note;
            //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"realPropId=%d", bmk.bookmark.realPropId];
            //check wich bookmarks is in use
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"rpGuid=%@", bmkc.bookmark.rpGuid];
            note = [AxDataManager getEntityObject:@"IRNote" andPredicate:predicate andContext:[AxDataManager noteContext]];
            if (note == nil)
                {
                    note = [AxDataManager getNewEntityObject:@"IRNote" andContext:[AxDataManager noteContext]];
                    note.rpGuid = bmkc.realPropInfo.guid;
                    note.major = bmkc.realPropInfo.major;
                    note.minor = bmkc.realPropInfo.minor;
                }
            baseNote = [[BaseNote alloc] initWithNibName:@"BaseNote" bundle:nil];
            baseNote.delegate = self;
            // switch to the keyboard notes
            UIView *view = [self.view viewWithTag:500];
            [view addSubview:baseNote.view];
            [self addChildViewController:baseNote];
            [view bringSubviewToFront:baseNote.view];
            baseNote.currentNote = note;

            UIView *topView = baseNote.view;

            [self animateView:topView];
        }



    - (void)bookmarkMap:(BookmarkController *)bmkc
        {
            // Recreate a list of bookmarks
            SelectedProperties *selectProperties = [[SelectedProperties alloc] initWithRealPropInfo:bmkc.realPropInfo];
            [RealProperty setSelectedProperties:selectProperties];
            RealPropertyApp *app = (RealPropertyApp *) [[UIApplication sharedApplication] delegate];

            TabSearchController *searchController = (TabSearchController *) (app.tabSearchController);
            searchController.autoSearch = NO;

            [app selectPropertyOnMap:[NSNumber numberWithInt:bmkc.realPropInfo.realPropId]];
        }



    - (void)bookmarkDetails:(BookmarkController *)bmkc
        {
            SelectedProperties *selectProperties = [[SelectedProperties alloc] initWithRealPropInfo:bmkc.realPropInfo];
            [RealProperty setSelectedProperties:selectProperties];
            RealPropertyApp *app = (RealPropertyApp *) [[UIApplication sharedApplication] delegate];

            TabSearchController *searchController = (TabSearchController *) (app.tabSearchController);
            searchController.autoSearch = NO;

            //[app switchToProperty:[NSNumber numberWithInt:bmk.realPropInfo.realPropId]];
            [app switchToGuid:bmkc.bookmark.rpGuid];

        }



    - (void)switchToMaps
        {
            [RealProperty setSelectedProperties:nil];

            RealPropertyApp *app = (RealPropertyApp *) [[UIApplication sharedApplication] delegate];

            for (BookmarkController *bmc in bookmarkViews)
                {

                    [app addSelection:bmc.realPropInfo.realPropId];
                }
            [app selectMultiplePropertiesOnMap];

        }



    - (void)animateView:(UIView *)topView
        {
            // Put the screen off-screen
            topView.frame = CGRectMake(1024, 0, topView.frame.size.width, topView.frame.size.height);
            // ANIMATE: move from right to left
            [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^
                {
                    topView.frame = CGRectOffset(topView.frame, -1024, 0);
                }            completion:nil];
        }



// Return to the current screen
    - (void)noteMgrCloseNote:(id)note
        {
            UIViewController *viewController = note;
            UIView           *topView        = viewController.view;

            [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^
                {
                    topView.frame = CGRectOffset(topView.frame, 1024, 0);
                }
                             completion:^(BOOL finished)
                                 {
                                     [baseNote.view removeFromSuperview];
                                     [baseNote removeFromParentViewController];

                                     baseNote = nil;
                                 }];

        }
#pragma mark - dealing with the grid
//
// Switch back to display the grid
//
    - (void)displayGrid
        {
            scrollView.hidden = YES;
            UIView *view = [self.view viewWithTag:500];

            [view addSubview:gridController.view];
            [view bringSubviewToFront:gridController.view];
            [self addChildViewController:gridController];
            [[gridController getFirstGridController] setGridContent:[self getDefaultOrderedList]];

            [[gridController getFirstGridController] setDelegate:self];
        }



    - (void)displayDetail
        {

            [gridController removeFromParentViewController];
            [gridController.view removeFromSuperview];
            scrollView.hidden = NO;
        }


    //cv on this process we do not have bookmark major minor  & have to create 2 contexts, add them into a an array
    // then to set it back for return to gridControler
    - (NSArray *)getDefaultOrderedList
        {
            //NSArray *bookmarks = [AxDataManager dataListEntity:@"Bookmark" andSortBy:@"addedDate" sortAscending:NO withContext:[AxDataManager defaultContext]];
            //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(rowStatus <> 'D')"];
            NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"updatedBy=%@ AND rowStatus <> 'D'", [RealPropertyApp getUserName] ];

            NSArray *bookmarks = [AxDataManager dataListEntity:@"Bookmark" andPredicate:predicate2 andSortBy:@"addedDate" sortAscending:NO withContext:[AxDataManager defaultContext]];

            return bookmarks;
        }



// Return the content of a cell (when the delgate provides the information
    - (id)getCellData:(id)grid
             rowIndex:(int)rowIndex
          columnIndex:(int)columnIndex
        {
            return nil;
        }



// Number of rows in the grid
    - (int)numberOfRows:(id)grid
        {
            return 0;
        }



// Return TRUE if the delegate provides the data (instead of the attached arrays)
    - (BOOL)getDataFromDelegate:(id)grid
        {
            return NO;
        }



    - (void)gridRowSelection:(id)grid
                    rowIndex:(int)rowIndex
        {
            GridController *gController = (GridController *) grid;
            NSArray        *rows        = [gController getGridContent];
            Bookmark     *bm          = [rows objectAtIndex:rowIndex];

            //RealPropInfo *info = [AxDataManager getEntityObject:@"RealPropInfo" andPredicate:[NSPredicate predicateWithFormat:@"RealPropId=%d", bm.realPropId]];
            RealPropInfo *info = [AxDataManager getEntityObject:@"RealPropInfo" andPredicate:[NSPredicate predicateWithFormat:@"guid=%@", bm.rpGuid]];

            RealPropertyApp *app = (RealPropertyApp *) [[UIApplication sharedApplication] delegate];

            SelectedProperties *selectProperties = [[SelectedProperties alloc] initWithRealPropInfo:info];
            [RealProperty setSelectedProperties:selectProperties];
            TabSearchController *searchController = (TabSearchController *) (app.tabSearchController);
            searchController.autoSearch = NO;

            //[app switchToProperty:[NSNumber numberWithInt:bm.realPropId]];
            [app switchToGuid:bm.rpGuid];
        }

#pragma - static methods
    + (void)updateBookmarkErrors
        {
            RealPropertyApp *appDelegate = (RealPropertyApp *) [[UIApplication sharedApplication] delegate];

            int count = [AxDataManager countEntities:@"Bookmark" andPredicate:[NSPredicate predicateWithFormat:@"hasError !=0"] andContext:[AxDataManager defaultContext]];
            //  cv weird one ==> SELECT COUNT( DISTINCT t0.Z_PK) FROM ZIRBOOKMARK t0 WHERE  t0.ZHASERROR <> 0 int count = [AxDataManager countEntities:@"Bookmark" andPredicate:[NSPredicate predicateWithFormat:@"realPropId=%d", info.realPropId] andContext:[AxDataManager defaultContext]];

            if (count == 0)
                [appDelegate.tabBarController removeBadgeFromTab:4];
            else
                [appDelegate.tabBarController addBadgeToTab:4 value:count];
        }



    + (void)updateBookmarkErrors:(int)filter
                        withInfo:(RealPropInfo *)info
        {
            // Add and remove bookmark based on filters
            NSPredicate          *predicate = [NSPredicate predicateWithFormat:@"guid=%@ AND hasError!=0", info.guid];
            NSManagedObjectContext *context   = [AxDataManager defaultContext];

            NSArray *array = [AxDataManager dataListEntity:@"Bookmark" andPredicate:predicate andSortBy:@"typeItemId" sortAscending:YES withContext:context];
            // First pass, delete all the bookmarks that are not present in the filer
            int delete [] = {kBookmarkErrorLand, kBookmarkErrorBuilding, kBookmarkErrorMobile, kBookmarkErrorAccessory, kBookmarkErrorHistory,
                    kBookmarkErrorHIE, kBookmarkErrorInterest, kBookmarkErrorNote, kBookmarkErrorValue, kBookmarkErrorDetails,kBookmarkErrorSync};

            NSArray *bookmarkReason = [[NSArray alloc] initWithObjects:
                                                               @"Land Error",
                                                               @"Building Error",
                                                               @"Mobile Error",
                                                               @"Accessory Error",
                                                               @"History Error",
                                                               @"HIE Error",
                                                               @"Interest Error",
                                                               @"Note Error",
                                                               @"Value Error",
                                                               @"Details Error"
                                                               @"Do not synch Bookmark Error", nil];

            NSMutableSet    *set = [[NSMutableSet alloc] init];
            for (Bookmark *bookmark in array)
                {
                    for (int i = 0; i < sizeof(delete) / sizeof(delete[0]); i++)
                        {
                            int val = delete[i] & filter;

                            //if (bookmark.typeItemId == delete[i] && !val)
                            //    {
                            //        [set addObject:bookmark];
                            //        break;
                            //    }
                            if (bookmark.typeItemId == [NSNumber numberWithInt:delete[i] && !val])
                            {
                                [set addObject:bookmark];
                                break;
                            }
                          
                        }
                }
#if 0 // Remove the automatic delete

    for(Bookmark *bookmark in set)
        [context deleteObject:bookmark];
#endif
            // Move on to the next phase: add bookmarks that have been defined
            for (int i = 0; i < sizeof(delete) / sizeof(delete[0]); i++)
                {
                    if ((filter & delete[i]))
                        {
                            // Add the bookmark
                            [TabBookmarkController createBookmark:[bookmarkReason objectAtIndex:i] withInfo:info typeItem:delete[i] typeItemId:(i)];
                        }
                }

            [context save:nil];
        }



// -- not from an error  //in use for Sync error
    + (void)createBookmark:(NSString *)reason
                  withInfo:(RealPropInfo *)info
                      typeItem:(int)bookmarkType
               withContext:(NSManagedObjectContext *)context
        {
            MenuTable *myMenu = [[MenuTable alloc] initFromResource:@"MenuBookmark"];
            NSNumber *typeItemId = [NSNumber numberWithInt:[myMenu getMenuItemFromDescInt:reason]];

            
            Bookmark *bookmark = [AxDataManager getEntityObject:@"Bookmark" andPredicate:[NSPredicate predicateWithFormat:@"guid=%@ AND typeitemId=%d", info.guid,typeItemId] andContext:context];
            
            if (bookmark == nil || [bookmark.descr caseInsensitiveCompare:reason] != NSOrderedSame)
                {                    
                    Bookmark *bookmark = [AxDataManager getNewEntityObject:@"Bookmark" andContext:context];
        			bookmark.rpGuid 	  = info.guid;
                    bookmark.typeItemId = typeItemId;

                    if (bookmarkType == kBookmarkErrorRegular)
                        bookmark.hasError = NO;
                    else
                        bookmark.hasError = YES;
                    bookmark.descr = reason;
                    bookmark.rowStatus = @"I";
                    bookmark.updatedBy = [RealPropertyApp getUserName];
                    bookmark.updateDate  = [[Helper localDate] timeIntervalSinceReferenceDate];
                    //bookmark.realPropInfo = info;
                    bookmark.addedDate = [[Helper localDate] timeIntervalSinceReferenceDate];

                }
            else
                {
                    bookmark.addedDate = [[Helper localDate] timeIntervalSinceReferenceDate];
                }
            [context save:nil];

        }

+ (void)createBookmarkfromRPInfo:(NSString *)reason
              withInfo:(RealPropInfo *)info
              typeItem:(int)bookmarkType
               typeItemId:(int)boomarkTypeItemId
           withContext:(NSManagedObjectContext *)context
    {
   
    
        //check which bookmark I'm using
        Bookmark *bookmark = [AxDataManager getEntityObject:@"Bookmark" andPredicate:[NSPredicate predicateWithFormat:@"guid=%@ AND typeitemId=%d", info.guid, boomarkTypeItemId] andContext:context];
        
        if (bookmark == nil || [bookmark.descr caseInsensitiveCompare:reason] != NSOrderedSame)
        {
            // Add the current property to the list of objects
            //MenuTable *myMenu = [[MenuTable alloc] initFromResource:@"MenuBookmark"];
        
            Bookmark *bookmark = [AxDataManager getNewEntityObject:@"Bookmark" andContext:context];
            bookmark.rpGuid 	  = info.guid;
            bookmark.addedDate    = [[Helper localDate] timeIntervalSinceReferenceDate];
            bookmark.typeItemId = [NSNumber numberWithInt:boomarkTypeItemId];

            if (bookmarkType == kBookmarkErrorRegular)
                bookmark.hasError = NO;
            else
                bookmark.hasError = YES;
            bookmark.descr = reason;
            bookmark.rowStatus = @"I";
            bookmark.updatedBy = [RealPropertyApp getUserName];
            bookmark.updateDate  = [[Helper localDate] timeIntervalSinceReferenceDate];
            [info addBookmarkObject:bookmark];
        
        }
        else
        {
            bookmark.addedDate = [[Helper localDate] timeIntervalSinceReferenceDate];
        }
        [context save:nil];
    
    }


// regular process from menuBookmark ;
+ (void)createBookmark:(NSString *)reason
                  withInfo:(RealPropInfo *)info
                      typeItem:(int)bookmarkType
                        typeItemId:(int)bookmarkTypeItem
        {
        NSManagedObjectContext *context = [AxDataManager defaultContext];
           
           // [TabBookmarkController createBookmarkWithReason:reason hasError:false withInfo:info ];
//          [TabBookmarkController createBookmark:reason withInfo:info typeItem:bookmarkTypeItem withContext:context];
            
            [TabBookmarkController createBookmarkfromRPInfo:reason withInfo:info
                                                  typeItem:bookmarkType
                                                  typeItemId:bookmarkTypeItem
                                                withContext:context];
         }

+ (void)createBookmarkWithReason:(NSString *)reason
                        withInfo:(RealPropInfo *)info
{
    NSPredicate    *predicate = [NSPredicate predicateWithFormat:@"rpGuid=%@ AND descr=%@", info.guid, reason];
    
    Bookmark    *bookmark  = [AxDataManager getEntityObject:@"Bookmark" andPredicate:predicate andContext:[AxDataManager defaultContext]];
    if (bookmark == nil)
    {
        // Add the current property to the list of objects
        Bookmark *bookmark = [AxDataManager getNewEntityObject:@"Bookmark" andContext:[AxDataManager defaultContext]];
        bookmark.rpGuid = info.guid;
        bookmark.addedDate  = [[Helper localDate] timeIntervalSinceReferenceDate];
        bookmark.typeItemId = [NSNumber numberWithInt:10];
        bookmark.hasError   = 0; //hasError;
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
        bookmark.hasError  = 0;//hasError;
    }
    NSManagedObjectContext *context   = [AxDataManager defaultContext];
    [context save:nil];
    //[bookmarkButton setImage:[UIImage imageNamed:@"BookmarkEmpty.png"] forState:UIControlStateNormal];
}


@end
