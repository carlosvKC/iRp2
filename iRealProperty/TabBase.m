#import "TabBase.h"
#import "TabBaseDetail.h"
#import "AxDataManager.h"
#import "Helper.h"
#import "MediaView.h"
#import "PictureDetails.h"
#import "CaptureView.h"
#import "TrackChanges.h"
#import "RealPropertyApp.h"
#import "BaseView.h"
#import "CameraViewGrid.h"
#import "TabDetailsController.h"
#import "ReadPictures.h"


#define ATdegreesToRadians(x) (M_PI * x / 180.0)

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
#define IOS7_SDK_AVAILABLE 1
#endif

@implementation TabBase
{
    UIAlertView* cameraOrientationAlert;
    CGFloat _lastScale; //< the current zoom scale before update

}

    @synthesize controlBar, detailController, activeSubController, gridController, animationOn;

static NSInteger orientseason;


    - (id)initWithNibName:(NSString *)nibNameOrNil
                   bundle:(NSBundle *)nibBundleOrNil
        {
            self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
            if (self)
                {
                    gridController      = nil;
                    detailController    = nil;
                    baseNibName         = nibNameOrNil;
                    activeSubController = nil;
                    nibReader           = [[NIBReader alloc] initWithNibName:nibNameOrNil];
                }
            return self;
        }



    - (id)initWithNibName:(NSString *)portrait
                landscape:(NSString *)landscape
        {
            self = [super initWithNibName:portrait bundle:nil];
            if (self)
                {
                    gridController      = nil;
                    detailController    = nil;
                    baseNibName         = portrait;
                    activeSubController = nil;
                    nibReader           = [[NIBReader alloc] initWithNibName:portrait landscape:landscape];
                }
            return self;
        }



    - (id)initWithNibName:(NSString *)portrait
               portraitId:(int)pId
                landscape:(NSString *)landscape
              landscapeId:(int)lId
        {
            self = [super initWithNibName:portrait bundle:nil];
            if (self)
                {
                    gridController      = nil;
                    detailController    = nil;
                    baseNibName         = portrait;
                    activeSubController = nil;
                    nibReader           = [[NIBReader alloc] initWithNibName:portrait portraitId:pId landscape:landscape landscapeId:lId];
                }
            return self;
        }

#pragma mark - Default methods

//
// Assing the detailed information from a row the detail controller tempBaseEntity
    - (void)selectCurrentDetail
        {
            NSManagedObject *temp;
            NSManagedObject *row = [setEntities objectAtIndex:currentIndex];
            if (row == nil)
            NSLog(@"DisplaycurrentDetail: object is nil...");

            temp = row;
            // Cloning [AxDataManager copyManagedObject:row destination:temp withSets:YES withLinks:YES];

            [detailController setWorkingBase:temp];
        }



//
// Switch back to display the grid
//
    - (void)displayGrid
        {
            UIView *view = [self.view viewWithTag:501];
            if (view == nil)
            NSLog(@"displayGrid: cant find view #501");

            [view addSubview:gridController.view];
            [self addChildViewController:gridController];

            [view bringSubviewToFront:detailController.view];

            if (animationOn)
                {
                    doingAnimation = YES;
                    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^
                        {
                            detailController.view.frame = CGRectOffset(detailController.view.frame, 1024, 0);
                        }
                                     completion:^(BOOL finished)
                                         {
                                             [detailController removeFromParentViewController];
                                             [detailController.view removeFromSuperview];
                                             detailController.view.frame = CGRectOffset(detailController.view.frame, -1024, 0);
                                             doingAnimation = NO;
                                             detailController.workingBase = nil;
                                         }];
                }
            else
                {
                    [detailController removeFromParentViewController];
                    [detailController.view removeFromSuperview];
                    detailController.workingBase = nil;
                }
            gridIsDisplay = YES;
        }



    - (void)displayDetail
        {   
            // This is the blank placeholder view that will hold the detail view
            UIView *view = [self.view viewWithTag:501];
            if (view == nil)
                {
                    NSLog(@"displayDetail: cant find view #501");
                    return;
                }

            [self addChildViewController:detailController];
            [view addSubview:detailController.view];

            // DBaun: I'm assuming this is so it can be removed below.
            [view bringSubviewToFront:gridController.view];
            
            RealProperty *rp = [RealProperty instance];

            [rp updateBadge];

            if (animationOn)
                {
                    doingAnimation = YES;
                    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^
                        {
                            gridController.view.frame = CGRectOffset(gridController.view.frame, -1024, 0);
                        }
                                     completion:^(BOOL finished)
                                         {
                                             // DBaun: When the user is finished with the detail form, this code removes it.
                                             [gridController removeFromParentViewController];
                                             [gridController.view removeFromSuperview];
                                             gridController.view.frame = CGRectOffset(gridController.view.frame, 1024, 0);
                                             doingAnimation = NO;
                                         }];
                }
            else
                {
                    [gridController removeFromParentViewController];
                    [gridController.view removeFromSuperview];
                }
            
            gridIsDisplay    = NO;
        }



//
// Switch the GridControlBar
//
    - (void)switchControlBar:(enum GridControlBarConstant)bar
///check if it brings autoRotate ......take it off
        {
            UIView *controlBarView = [self.view viewWithTag:502];
            if (controlBarView == nil)
                {
                    return;
                }
            
            [controlBar.view removeFromSuperview];
            [controlBar removeFromParentViewController];
            
            NSString *nibName;
            int barMode;
            
            [self removeBlockingViews];
            
            switch (bar)
                {
                    case kGridControlModeDeleteAdd:
                        nibName = @"GridControlBarDeleteAdd";
                        barMode = kGridControlModeDeleteAdd;
                        break;
                    case kGridControlModeNextPrevious:
                        nibName = @"GridControlBarNextPrevious";
                        barMode = kGridControlModeNextPrevious;
                        break;
                    case kGridControlModeDeleteCancel:
                        nibName = @"GridControlBarDeleteCancel";
                        barMode = kGridControlModeDeleteCancel;
                        break;
                    case kGridControlModeSaveCancel:
                        nibName = @"GridControlBarSaveCancel";
                        barMode = kGridControlModeSaveCancel;
                        [self addBlockingViews:[Helper isDeviceInLandscape]];
                        break;

                    default:
                        return;
                        break;
                }
            
            GridController *gController    = [gridController getFirstGridController];
            GridDefinition *gridDefinition = gController.gridDefinition;
            
            if (gridDefinition != nil && bar == kGridControlModeDeleteAdd)
                {
                    if ([RealPropertyApp getUserLevel] < gridDefinition.editLevel || gridDefinition.editLevel == -1)
                        {
                            // Non editable
                            barMode = kGridControlModeEmpty;
                            nibName = @"GridControlBarEmpty";
                        }
                }

            //controlBar = [[GridControlBar alloc] initWithNibName:nibName barMode:barMode];
            //
            controlBar = [[GridControlBar alloc] initWithNibName:nibName barMode:barMode];
            
            controlBar.delegate       = self;
            controlBar.gridController = nil;
            
            [self addChildViewController:controlBar];
            [controlBarView addSubview:controlBar.view];
            
            controlBar.view.frame = controlBarView.frame;
            currentBar = bar;
        }

#pragma mark - Override the following methods

//
// Init the default values of the grid
    - (void)initDefaultValues
        {

        }



//
// Return the list of rows -- setEntities is assigned the result as well
    - (NSArray *)getDefaultOrderedList
        {

            return nil;
        }



//
// Draw an image from the grid
    - (void)drawImgEntity:(NSObject *)grid
                 rowIndex:(int)rowIndex
              columnIndex:(int)columnIndex
                 intoRect:(CGRect)rect
        {
        }



// this method is called when new data is updated
    - (void)updateDetailMedia
        {
        }



// Delete one object
    - (BOOL)deleteSelection:(NSManagedObject *)object
        {
            return NO;
        }



// Save the current form
    - (void)addNewDetails
        {
        }



// Save the the current details
    - (void)saveCurrentDetails
        {
        }



// buble up the change in the content
    - (void)entityContentHasChanged:(ItemDefinition *)entity
        {
        }



//
// Get information from mediaDialogBox -- Override
//
    - (void)addNewMedia
        {
        }



    - (void)addnewCadMedia
        {
        }



    - (void)deleteMedia:(id)media
        {
        }



    // Update the default media information
    - (void)defaultMediaInformation:(id)media
        {
            if (cameraImage == nil)
                return;
            RealPropertyApp *appDelegate = (RealPropertyApp *) [[UIApplication sharedApplication] delegate];
            

            [media setValue:[NSNumber numberWithBool:YES] forKey:@"active"];
            [media setValue:@"" forKey:@"desc"];
            [media setValue:[NSNumber numberWithInt:1] forKeyPath:@"imageType"];
            [media setValue:[Helper localDate] forKey:@"mediaDate"];
            [media setValue:[NSNumber numberWithInt:kMediaImage] forKeyPath:@"mediaType"];
            [media setValue:[NSNumber numberWithBool:NO] forKey:@"primary"];
            NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:[Helper localDate]];
            [media setValue:[NSNumber numberWithInt:[components year]] forKeyPath:@"year"];
            [media setValue:@"I" forKey:@"rowStatus"];
            [media setValue:[NSNumber numberWithInt:1] forKeyPath:@"order"];
            [media setValue:[NSNumber numberWithBool:YES] forKeyPath:@"postToWeb"];
            NSString *mediaGuid = [Requester createNewGuid];
            [media setValue:mediaGuid forKey:@"guid"];
            
            // 5/21/15 HNN undo Carlos' saving image; go back to original logic
            //[[appDelegate pictureManager] saveNewImg:cameraImage guid:mediaGuid mediaType:kMediaImage ext:@"PNG"];
            [[appDelegate pictureManager] saveNewImage:cameraImage withMedia:media];

            [RealPropertyApp updateUserDate:media];
            //    }
        }

        // Update the default media information with interior pics
        - (void)defaultMediaInformation:(id)media postToWeb:(BOOL)interiorPict;
            {
                if (cameraImage == nil)
                    return;
                RealPropertyApp *appDelegate = (RealPropertyApp *) [[UIApplication sharedApplication] delegate];
    
                [media setValue:[NSNumber numberWithBool:YES] forKey:@"active"];
                [media setValue:@"" forKey:@"desc"];
                [media setValue:[NSNumber numberWithInt:1] forKeyPath:@"imageType"];
                [media setValue:[Helper localDate] forKey:@"mediaDate"];
                [media setValue:[NSNumber numberWithInt:kMediaImage] forKeyPath:@"mediaType"];
                [media setValue:[NSNumber numberWithBool:NO] forKey:@"primary"];
                NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:[Helper localDate]];
                [media setValue:[NSNumber numberWithInt:[components year]] forKeyPath:@"year"];
                [media setValue:@"I" forKey:@"rowStatus"];
                [media setValue:[NSNumber numberWithInt:1] forKeyPath:@"order"];
                [media setValue:[NSNumber numberWithBool:interiorPict] forKeyPath:@"postToWeb"];
                NSString *mediaGuid = [Requester createNewGuid];
                [media setValue:mediaGuid forKey:@"guid"];
                
                // 5/21/15 HNN undo Carlos' changes and call original saveNewImage
                //[[appDelegate pictureManager] saveNewImg:cameraImage guid:mediaGuid mediaType:kMediaImage ext:@"PNG"];
                [[appDelegate pictureManager] saveNewImage:cameraImage withMedia:media];
                [RealPropertyApp updateUserDate:media];
            }

#pragma mark - Grid delegates


    - (void)gridRowSelection:(NSObject *)grid
                    rowIndex:(int)rowIndex
        {
            currentIndex = rowIndex;

            GridController  *gController = (GridController *) grid;
            NSArray         *rows        = [gController getGridContent];
            NSManagedObject *row         = [rows objectAtIndex:rowIndex];


            // Copy the managed object into a temporary variable
            // Cloning -- NSManagedObject *tempBaseEntity = [AxDataManager clone:row withSets:YES withLinks:YES];
            NSManagedObject *tempBaseEntity = row;
            detailController.screenIndex = rowIndex;
            [detailController setWorkingBase:tempBaseEntity];
            detailController.isNewContent = NO;
            detailController.isDirty      = NO;

            // Call the setup rules to make sure the data is properly filled
            [detailController setupBusinessRules:tempBaseEntity];
            [detailController setScreenEntities];
            // to update them now
            for (ItemDefinition *item in detailController.entities)
                {
                    if (item.type == ftGrid)
                        {
                            [detailController setupGrid:tempBaseEntity withItem:(ItemDefinition *) item];
                        }
                }
            [self displayDetail];
            [self updateDetailMedia];

            // Update the grid
            [self switchControlBar:kGridControlModeNextPrevious];
            // Update the current position vs. the entire number of entries
            // [controlBar setSmallLabelText:[NSString stringWithFormat:@"%d/%d",rowIndex+1,[rows count]]];
            [controlBar setCounter:rowIndex + 1 max:[rows count]];
        }



// Data is from the content rows
    - (id)getCellData:(NSObject *)grid
             rowIndex:(int)rowIndex
          columnIndex:(int)columnIndex
        {
            return nil;
        }



// Not called
    - (int)numberOfRows:(NSObject *)grid
        {
            return 0;
        }



    - (void)swipeLeft
        {
            [self gridControlBarAction:nil action:kGridControlBarBtnLeft];
        }



    - (void)swipeRight
        {
            [self gridControlBarAction:nil action:kGridControlBarBtnRight];
        }


// DBaun 062914 (New Permit Form) Comments and formatting
// Handle the different actions from the grid
    - (void)gridControlBarAction:(NSObject *)grid
                          action:(int)param
        {
            GridController *gController = [gridController getFirstGridController];
            int startIndex = currentIndex;

            if ([Helper findAndResignFirstResponder:self.view] == NO)
                return;

            switch (currentBar)
                {
                    case kGridControlModeDeleteAdd:
                        if (param == kGridControlBarBtnAdd)
                            {
                                // Example values for Accessory tab
                                //      NSString            defaultBaseEntity = 'Accy'
                                //      NSManagedObject     tempBaseEntity    = 'Accy'
                                //      UIViewController    SELF              = 'TabAccy'
                                //      UIViewController    detailController  = 'TabAccyDetail'
                          
                                [gController deselectAllRows];
                                id tempBaseEntity = [AxDataManager getNewEntityObject:defaultBaseEntity];
                                [detailController setWorkingBase:tempBaseEntity];

                                detailController.isNewContent = YES;
                                detailController.isDirty      = NO;
                                // Call the setup rules to make sure the data is properly filled
                                [detailController setupBusinessRules:tempBaseEntity];
                                [detailController setScreenEntities];
                                [self displayDetail];
                                [self updateDetailMedia];
                                [self switchControlBar:kGridControlModeSaveCancel];
                            }
                        
                        if (param == kGridControlBarBtnDel)
                            {
                                [gController enterEditMode];
                                [self switchControlBar:kGridControlModeDeleteCancel];
                            }
                        
                        break;
                    case kGridControlModeNextPrevious:
                        if (param == kGridControlBarBtnList)
                            {
                                if (![self validateBusinessRules])
                                    return;
                                [gController deselectAllRows];
                                // If detail is dirty, needs to update it
                                if (detailController.isDirty)
                                    {
                                        [self saveCurrentDetails];
                                    }
                                // Switch back to grid list
                                [self switchControlBar:kGridControlModeDeleteAdd];
                                [self displayGrid];
                                // Update the Grid
                                [gController setGridContent:[self getDefaultOrderedList]];
                                [gController refreshAllContent];
                            }
                    if (param == kGridControlBarBtnLeft || param == kGridControlBarBtnRight)
                        {
                            if (![self validateBusinessRules])
                                return;
                            // Move to another object
                            if (detailController.isDirty)
                                {
                                    // [self.propertyController segmentUsed:tabIndex];
                                    [self saveCurrentDetails];
                                }
                            if (param == kGridControlBarBtnLeft)
                                {
                                    if (currentIndex == 0)
                                        break;
                                    currentIndex--;
                                }
                            else
                                {
                                    if (currentIndex == [[gController getGridContent] count] - 1)
                                        break;
                                    currentIndex++;
                                }

                            // Capture the current screen
                            CaptureView *captView = [[CaptureView alloc] initWithView:detailController.view];
                            [self gridRowSelection:gController rowIndex:currentIndex];

                            UIView *view = [self.view viewWithTag:501];
                            [view addSubview:captView];
                            [view bringSubviewToFront:captView];
                            if (currentIndex > startIndex)
                                {
                                    doingAnimation = YES;
                                    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^
                                        {
                                            captView.frame = CGRectOffset(captView.frame, 1024, 0);
                                        }
                                                     completion:^(BOOL finished)
                                                         {
                                                             [captView removeFromSuperview];
                                                             doingAnimation = NO;
                                                         }];
                                }
                            else
                                {
                                    [view bringSubviewToFront:detailController.view];
                                    detailController.view.frame = CGRectOffset(detailController.view.frame, 1024, 0);
                                    doingAnimation = YES;
                                    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^
                                        {
                                            detailController.view.frame = CGRectOffset(detailController.view.frame, -1024, 0);
                                        }
                                                     completion:^(BOOL finished)
                                                         {
                                                             [captView removeFromSuperview];
                                                             doingAnimation = NO;
                                                         }];
                                }
                            // captView = nil;

                        }
                    break;

                    case kGridControlModeDeleteCancel:
                        // Grid -- Delete and Cancel
                        if (param == kGridControlBarBtnCancel)
                            {
                                [gController cancelEditMode];
                                [self switchControlBar:kGridControlModeDeleteAdd];
                                [gController setSingleSelection:YES];

                            }
                    if (param == kGridControlBarBtnConfirmDel)
                        {
                            NSArray              *selectedRows = [gController getSelectedRows];
                            for (NSManagedObject *row in selectedRows)
                                {
                                    if ([self deleteSelection:row])
                                        {
                                            self.isDirty = YES;
                                            [self entityContentHasChanged:nil];
                                        }
                                }

                            [gController setGridContent:[self getDefaultOrderedList]];
                            [gController refreshAllContent];
                            [gController setSingleSelection:YES];
                        }
                        break;
                    case kGridControlModeSaveCancel:
                        // Grid Detail -- Save and cancel
                        if (param == kGridControlBarBtnSave)
                            {
                                if (![self shouldSwitchView])
                                    {
                                        [self.propertyController updateBadge:NO];
                                        // continue even if there are errors
                                    }
                                
                                [self validateBusinessRules];

                                // Save new information
                                if (detailController.isNewContent)
                                    [self addNewDetails];
                                else
                                    [self saveCurrentDetails];
                                
                                // Switch back to grid view
                                [self displayGrid];
                                [self switchControlBar:kGridControlModeDeleteAdd];
                                // Update the Grid
                                [gController setGridContent:[self getDefaultOrderedList]];
                                [gController refreshAllContent];
                                // New content has been added - signal to the top bar (in case it is not done yet...)
                                [self.propertyController segmentUsed:tabIndex];
                            }
                    if (param == kGridControlBarBtnCancel)
                        {
                            [self cancelValidationError];
                            [detailController cancelValidationError];
                            [self displayGrid];
                            [self switchControlBar:kGridControlModeDeleteAdd];
                            [gController deselectAllRows];
                            [self.propertyController updateBadge:YES];
                            
                            // Remove the object that is not necessary since it was canceled
                            NSManagedObject        *object  = [detailController workingBase];
                            NSManagedObjectContext *context = [AxDataManager getContext:@"default"];
                            [context deleteObject:object];
                        }
                    break;
                }
        }



// Data is attached to the grid, not provided by this controller
    - (BOOL)getDataFromDelegate:(NSObject *)gridController
        {
            return NO;
        }



// Resign all the subviews that are in edit mode
    - (void)gridControlBarResignFirstResponder:(NSObject *)grid
        {
            [self checkTextfieldsAreValid];
        }
#pragma mark - Delegates
    - (void)gridMediaSelection:(id)grid
                         media:(id)media
                   columnIndex:(int)columnIndex
        {
            if (btnDelete != nil)
                {
                    [btnDelete removeFromSuperview];
                    btnDelete = nil;
                    return;
                }
            AxGridPictController *ctrl = grid;

            [self.propertyController switchToPictureController:ctrl.mediaArray selected:media fromController:self];

            topView.hidden = YES;
        }



    - (void)gridMediaLongSelection:(id)grid
                            inCell:(id)cell
                         withMedia:(id)media
        {
            if ([self isKindOfClass:[TabDetailsController class]])
                return;
            MediaAccy *mediaType = media;
            [btnDelete removeFromSuperview];
            btnDelete = nil;
            UIImage *image = [UIImage imageNamed:@"delete2.png"]; // 50x50
            CGRect frame = CGRectMake(0, 0, 50, 50);
            btnDelete = [UIButton buttonWithType:UIButtonTypeCustom];
            btnDelete.frame = frame;
            [btnDelete setImage:image forState:UIControlStateNormal];
            [btnDelete addTarget:self action:@selector(deleteAction:) forControlEvents:UIControlEventTouchUpInside];
            UIView *cellView = cell;
            [cellView addSubview:btnDelete];
            [cellView bringSubviewToFront:btnDelete];

            mediaAccy = mediaType;
            _grid     = grid;
        }

- (void)gridMediaAddPicture:(id)grid
{
    
    // If this is iOS 8,(because it's Greater Than 7.9) and the application is in Landscape, then warn the user to turn to Portrait and lock the orientation, then leave this method.
    // This is a workaround for the camera acting weird when the device isn't locked to portrait, and the camera buttons being off screen so the user couldn't close the camera, and had to crash out of the app.

//cv    if ([[[UIDevice currentDevice] systemVersion] compare:@"7.9" options:NSNumericSearch] == NSOrderedDescending)
//    {
//        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
//        
//        if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight)
//        {
//            cameraOrientationAlert = [[UIAlertView alloc] initWithTitle:@"Oops" message:@"Please start the camera in portrait mode, then lock the orientation using the slider on the side of the device.\nThis will enable the camera to operate properly in portrait and landscape.\nYou can remove the locked orientation after you're done with the camera if you wish." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
//            [cameraOrientationAlert show];
//            
//            return;
//        }
//    }
    
    // Go ahead and display the camera because we're running on a device with a version previous to iOS 8.0 on it, OR
    // we're on iOS 8, but the user is already in Portrait orientation, OR
    // the orientation of the camera isn't relevant for this version of iOS because it's prior to iOS 8.0

    
    RealPropertyApp         *appDelegate = (RealPropertyApp *) [[UIApplication sharedApplication] delegate];
    UIImagePickerController *imgPicker   = appDelegate.imgPicker;
    
    
    NSArray *sourceTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
    
    if ([sourceTypes count] == 0)
    {
        // Add an image as test
        RealPropertyApp *appDelegate = (RealPropertyApp *) [[UIApplication sharedApplication] delegate];
        NSData *data = [[appDelegate pictureManager] getFirstFileDataWithMediaTypeFromDatabase:kMediaPict];
        
        if (data == nil)
            return;
        
        // NSLog(@"The image '%@' size is '%u' bytes", imageName, [data length])
        
        cameraImage = [UIImage imageWithData:data];
        
        [self addNewMedia];
        [[AxDataManager defaultContext] save:nil];

       //cv return;
    }
    while (doingAnimation == true)
    {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.2]];
    }
    if (imgPicker == nil)
    {
        imgPicker = [[UIImagePickerController alloc] init];
        //cv imgPicker.sourceType          = UIImagePickerControllerSourceTypeCamera;
        imgPicker.sourceType    = UIImagePickerControllerSourceTypePhotoLibrary;
        
        imgPicker.allowsEditing       = NO;
        //cv imgPicker.showsCameraControls = NO;
//        imgPicker.cameraViewTransform = *(cameraViewTransform);
//        
//        //cv    view.backgroundColor = [UIColor clearColor];
//        CGSize screenBounds = [UIScreen mainScreen].bounds.size;
//    
//        CGFloat cameraAspectRatio = 4.0f/3.0f;
//    
////        CGFloat camViewHeight = screenBounds.width * cameraAspectRatio;
////        CGFloat scale = screenBounds.height / camViewHeight;
//        
//        //cameraViewTransform = CGAffineTransformMakeScale(1.0, 1.0);
//        
//        imgPicker.cameraViewTransform = CGAffineTransformMakeScale(1.0, 1.0);
//    
//        //imgPicker.cameraViewTransform = CGAffineTransformMakeTranslation(0, (screenBounds.height - camViewHeight) / 2.0);
//        //imgPicker.cameraViewTransform = CGAffineTransformScale(imgPicker.cameraViewTransform, scale, scale);
//        ///////////////////////////////////////////////////////////////////////////////  //////////////////////////////////////////////
        
        appDelegate.imgPicker         = imgPicker;
    }
    // 4/15/16 HNN reuse imgPicker from all areas of the app that allows you to take a picture to avoid
    // memory leak
    //http://blog.airsource.co.uk/index.php/2008/11/12/memory-usage-in-uiimagepickercontroller/
    imgPicker.delegate            = self;

    // Create the camera view
    CGRect frame = appDelegate.window.screen.bounds;
    
    CameraViewGrid *view = [[CameraViewGrid alloc] initWithFrame:frame];
      ///////////////////////////////////////////////////////////////////////////////  /////////////////////////////////////////////////
    

    view.backgroundColor = [UIColor lightGrayColor];
    
    [view setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin];
    
    // Add the buttons cancel and take picture
    btnCancel = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btnCancel setTitle:@"Close Camera" forState:UIControlStateNormal];
    btnCancel.titleLabel.textColor = [UIColor blackColor];
    btnCancel.frame                = CGRectMake(0, 0, 150, 50);
    //cv  btnCancel.backgroundColor      = [UIColor clearColor];
    btnPicture.backgroundColor = [UIColor orangeColor];
    [btnCancel setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin];
    
    [view addSubview:btnCancel];
    [btnCancel addTarget:self action:@selector(cameraCancel:) forControlEvents:UIControlEventTouchUpInside];
    
    btnPicture = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btnPicture setTitle:@"Take Picture" forState:UIControlStateNormal];
    //cv btnPicture.frame           = CGRectMake(0, 0, 150, 50);
    btnPicture.frame           = CGRectMake(750, 0, 150, 50);
    //cv  btnPicture.backgroundColor = [UIColor clearColor];
    btnPicture.backgroundColor = [UIColor blueColor];
    [view addSubview:btnPicture];
 
    btnPicture.titleLabel.textColor = [UIColor blackColor];
    [btnPicture addTarget:self action:@selector(cameraPicture:) forControlEvents:UIControlEventTouchUpInside];
    
    //cv imgLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 250, 40)];
    imgLabel = [[UILabel alloc] initWithFrame:CGRectMake(350, 0, 250, 40)];
    
    imgLabel.textAlignment = NSTextAlignmentCenter;
    imgLabel.textColor     = [UIColor whiteColor];
    imgLabel.font          = [UIFont systemFontOfSize:22.0f];
    imgLabel.shadowColor   = [UIColor blackColor];
    imgLabel.shadowOffset  = CGSizeMake(2, 2);
    
    imgLabel.backgroundColor = [UIColor clearColor];
    
//cv    imgLabel.text  = @"";
    imgLabel.text  = @"this is where the Text go for the label";

// cv   imgLabel.frame = CGRectMake((frame.size.width - imgLabel.frame.size.width) / 2, frame.size.height - imgLabel.frame.size.height, imgLabel.frame.size.width, imgLabel.frame.size.height);
    // frame = (387 728; 250 40);
    imgLabel.frame = CGRectMake((frame.size.width - imgLabel.frame.size.width) / 2, frame.size.height - 60, imgLabel.frame.size.width, imgLabel.frame.size.height);
//                                                                                        1024 -40

    [view addSubview:imgLabel];
    
    // cv 6/27/16 define orientation
    if (![Helper isDeviceInLandscape])
        {
    
            imgLabel.frame = CGRectMake((frame.size.width - imgLabel.frame.size.width) / 2, frame.size.height - imgLabel.frame.size.height, imgLabel.frame.size.width, imgLabel.frame.size.height);

            [imgLabel setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin];
    
            [btnPicture setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin];
    
            btnCancel.frame             = CGRectMake(5, frame.size.height - btnCancel.frame.size.height - 5, btnCancel.frame.size.width, btnCancel.frame.size.height);
            btnPicture.frame            = CGRectMake((frame.size.width - btnPicture.frame.size.width) - 5, frame.size.height - btnPicture.frame.size.height - 5, btnCancel.frame.size.width, btnCancel.frame.size.height);
    
        }
    
    
    ///
    
    //        imgPicker.allowsEditing       = NO;
    
    //not good
    //UIPinchGestureRecognizer *pinchRec = [[UIPinchGestureRecognizer alloc] initWithTarget:imgPicker action:@selector(zoom:)];
    
    // so so
    UIPinchGestureRecognizer *pinchRec = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(zoom:)];
    
    // nope
    //UIPinchGestureRecognizer *pinchRec = [[UIPinchGestureRecognizer alloc] initWithTarget:view action:@selector(zoom:)];


    //cv no such a thing as overlayview (cameraOverlayView is good)
    //[self.overlayView addGestureRecognizer:pinchRec];
    [imgPicker.cameraOverlayView addGestureRecognizer:pinchRec];
    
    //cv view doesn't have property
    //imgPicker.cameraOverlayView = view.overlayView;
    
    //imgPicker.cameraOverlayView = imgPicker.cameraOverlayView;
    _lastScale = 1.;
    

    ////

    //imgPicker.cameraOverlayView = view;
    [self presentViewController:imgPicker animated:YES  completion:nil ];
    cameraPictCount = 0;
}

- (void)zoom:(UIPinchGestureRecognizer *) sender
{
    [Helper alertWithOk:@"UIPinchGestureRecognizer" message:@"oh no this again"];
    
    // reset scale when pinch has ended so that future scalings are applied cumulatively and the zoom does not jump back (not sure I understand this)
    if([sender state] == UIGestureRecognizerStateEnded)
    {
        _lastScale = 1.0;
        return;
    }
    
    CGFloat scale = 1.0 - (_lastScale - sender.scale); // sender.scale gives current distance of fingers compared to initial distance. We want a value to scale the current transform with, so diff between previous scale and new scale is what must be used to stretch the current transform
    
    RealPropertyApp         *appDelegate = (RealPropertyApp *) [[UIApplication sharedApplication] delegate];
    UIImagePickerController *imgPicker   = appDelegate.imgPicker;
    
    CGAffineTransform currentTransform = imgPicker.cameraViewTransform;
 
    CGAffineTransform newTransform = CGAffineTransformScale (currentTransform, scale, scale); // stretch current transform by amount given by sender
    
    newTransform.a = MAX(newTransform.a, 1.); // it should be impossible to make preview smaller than screen (or initial size)
    newTransform.d = MAX(newTransform.d, 1.);
    
    imgPicker.cameraViewTransform = newTransform;
    _lastScale = sender.scale;
    
}

    - (void)gridMediaAddPictureToTest:(id)grid
        {
            // If this is iOS 8,(because it's Greater Than 7.9) and the application is in Landscape, then warn the user to turn to Portrait and lock the orientation, then leave this method.
            // This is a workaround for the camera acting weird when the device isn't locked to portrait, and the camera buttons being off screen so the user couldn't close the camera, and had to crash out of the app.
            //if ([[[UIDevice currentDevice] systemVersion] compare:@"7.9" options:NSNumericSearch] == NSOrderedDescending)
            //{
                UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
            
                if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight)
                {
                    cameraOrientationAlert = [[UIAlertView alloc] initWithTitle:@"Oops" message:@"Please start the camera in portrait mode, then lock the orientation using the slider on the side of the device.\nThis will enable the camera to operate properly in portrait and landscape.\nYou can remove the locked orientation after you're done with the camera if you wish." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [cameraOrientationAlert show];
                
                    return;
                }
            //}

            // Go ahead and display the camera because we're running on a device with a version previous to iOS 8.0 on it, OR
            // we're on iOS 8, but the user is already in Portrait orientation, OR
            // the orientation of the camera isn't relevant for this version of iOS because it's prior to iOS 8.0
            RealPropertyApp         *appDelegate = (RealPropertyApp *) [[UIApplication sharedApplication] delegate];
            UIImagePickerController *imgPicker   = appDelegate.imgPicker;

            if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
                return;

            NSArray *sourceTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];

            if ([sourceTypes count] == 0)
                {
                    // Add an image as test
                    RealPropertyApp *appDelegate = (RealPropertyApp *) [[UIApplication sharedApplication] delegate];

                    cameraImage = [[appDelegate pictureManager] findFirstImageWithMediaType:kMediaPict];
                    [self addNewMedia];
                    [[AxDataManager defaultContext] save:nil];
                    return;
                }
            while (doingAnimation == true)
                {
                    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.2]];
                }
            if (imgPicker == nil)
                {

                    imgPicker = [[UIImagePickerController alloc] init];
                    imgPicker.sourceType          = UIImagePickerControllerSourceTypeCamera;
//                    imgPicker.delegate            = self;
                    imgPicker.allowsEditing       = NO;
                    imgPicker.showsCameraControls = NO;
                    appDelegate.imgPicker         = imgPicker;
                }
                // 4/15/16 HNN reuse imgPicker from all areas of the app that allows you to take a picture to avoid
                // memory leak
                //http://blog.airsource.co.uk/index.php/2008/11/12/memory-usage-in-uiimagepickercontroller/
                imgPicker.delegate            = self;
            
            // Create the camera view
            CGRect frame = appDelegate.window.screen.bounds;
            //you might look at UIWindow(inherits from UIView; have bounds and frame
            
            CameraViewGrid *view = [[CameraViewGrid alloc] initWithFrame:frame];
            
            view.backgroundColor = [UIColor clearColor];
            [view setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin];

            // Add the buttons cancel and take picture
            btnCancel = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [btnCancel setTitle:@"Close Camera" forState:UIControlStateNormal];
            btnCancel.titleLabel.textColor = [UIColor blackColor];
            btnCancel.frame                = CGRectMake(0, 0, 150, 50);
            btnCancel.backgroundColor      = [UIColor clearColor];
            [btnCancel setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin];

            [view addSubview:btnCancel];
            [btnCancel addTarget:self action:@selector(cameraCancel:) forControlEvents:UIControlEventTouchUpInside];

            btnPicture = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [btnPicture setTitle:@"Take Picture" forState:UIControlStateNormal];
            btnPicture.frame           = CGRectMake(0, 0, 150, 50);
            btnPicture.backgroundColor = [UIColor clearColor];
            [view addSubview:btnPicture];
            btnPicture.titleLabel.textColor = [UIColor blackColor];
            [btnPicture addTarget:self action:@selector(cameraPicture:) forControlEvents:UIControlEventTouchUpInside];
        
            ///
//            btnPictureInt = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//            [btnPictureInt setTitle:@"Take Interior Picture" forState:UIControlStateNormal];
//            btnPictureInt.frame           = CGRectMake(0, 0, 150, 50);
//            btnPictureInt.backgroundColor = [UIColor clearColor];
//            [view addSubview:btnPictureInt];
//            btnPictureInt.titleLabel.textColor = [UIColor blackColor];
//            [btnPictureInt addTarget:self action:@selector(cameraPicture:) forControlEvents:UIControlEventTouchUpInside];
            
            // couple of issues. I'm not sure where the label is placed
            

            ///
            imgLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 250, 40)];
            imgLabel.textAlignment = NSTextAlignmentCenter;
            imgLabel.textColor     = [UIColor whiteColor];
            imgLabel.font          = [UIFont systemFontOfSize:22.0f];
            imgLabel.shadowColor   = [UIColor blackColor];
            imgLabel.shadowOffset  = CGSizeMake(2, 2);

            imgLabel.backgroundColor = [UIColor clearColor];

            imgLabel.text  = @"";
            //imgLabel.frame = CGRectMake((frame.size.width - imgLabel.frame.size.width) / 2, frame.size.height - imgLabel.frame.size.height, imgLabel.frame.size.width, imgLabel.frame.size.height);
            // the label should be a bit up
            imgLabel.frame = CGRectMake((frame.size.width - imgLabel.frame.size.width) / 2, frame.size.height - imgLabel.frame.size.height +20, imgLabel.frame.size.width, imgLabel.frame.size.height);

            [view addSubview:imgLabel];

            [imgLabel setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin];

            [btnPicture setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin];

            [btnPictureInt setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin];

           
            btnCancel.frame  = CGRectMake(5, frame.size.height - btnCancel.frame.size.height - 5, btnCancel.frame.size.width, btnCancel.frame.size.height);
            btnPicture.frame = CGRectMake((frame.size.width - btnPicture.frame.size.width) - 5, frame.size.height - btnPicture.frame.size.height - 5, btnCancel.frame.size.width, btnCancel.frame.size.height);
            //                                  --->                                                ^^
            //btnPictureInt.frame = CGRectMake((frame.size.width - btnPicture.frame.size.width) - 5, frame.size.height - btnPicture.frame.size.height +20, btnCancel.frame.size.width, btnCancel.frame.size.height);

            
            //DBaun - Before Hoang found a workaround, I was trying to move the buttons as shown below for a temporary fix for iOS 8
//            UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
//
//            if (orientation == UIDeviceOrientationLandscapeLeft)
//                view.transform = CGAffineTransformRotate(CGAffineTransformIdentity, ATdegreesToRadians(90));
//            //btnCancel.frame             = CGRectMake(400,680, btnCancel.frame.size.width, btnCancel.frame.size.height);
//            btnCancel.frame  = CGRectMake(100,300, btnCancel.frame.size.width, btnCancel.frame.size.height);
//            
//            if (orientation == UIDeviceOrientationLandscapeRight)
//                view.transform = CGAffineTransformRotate(CGAffineTransformIdentity, ATdegreesToRadians(-90));
//            btnCancel.frame  = CGRectMake(100,300, btnCancel.frame.size.width, btnCancel.frame.size.height);
//
//
//            //btnCancel.frame             = CGRectMake(400,680, btnCancel.frame.size.width, btnCancel.frame.size.height);
//            //btnPicture.frame            = CGRectMake(560,680, btnCancel.frame.size.width, btnCancel.frame.size.height);
//            
            imgPicker.cameraOverlayView = view;
            [self presentViewController:imgPicker animated:YES  completion:nil ];
            cameraPictCount = 0;
        }

-(void) orientationchngfn
{
    UIDeviceOrientation dorientation =[UIDevice currentDevice].orientation;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
        if(UIDeviceOrientationIsPortrait(dorientation))
            
        {
            orientseason=0;
        }
        else if (UIDeviceOrientationIsLandscape(dorientation))
        {
            orientseason=1;
        }
        if(orientseason==0)
        {
            btnCancel.frame=CGRectMake(5, 44, 310, 419);
            
            
        }
        else if(orientseason==1)
        {
            btnCancel.frame=CGRectMake(5, 44, 470, 276);
            
        }
        
    }
    else {
        if(UIDeviceOrientationIsPortrait(dorientation))
            
        {
            orientseason=0;
        }
        else if (UIDeviceOrientationIsLandscape(dorientation))
        {
            
            orientseason=1;
        }
        if(orientseason==0)
        {
            btnCancel.frame=CGRectMake(5, 44, 758, 940);
            
            
        }
        else if(orientseason==1)
        {
            btnCancel.frame=CGRectMake(5, 44, 1014, 684);
            
        }
    }
    
}


    - (void)cameraCancel:(id)sender
        {
            RealPropertyApp *appDelegate = (RealPropertyApp *) [[UIApplication sharedApplication] delegate];
            [appDelegate.imgPicker dismissViewControllerAnimated:YES completion:^(void)
                {
                    [appDelegate.imgPicker removeFromParentViewController];
                    [appDelegate.imgPicker.view removeFromSuperview];
                    // HN by cv 4/12 potential memory leak
                    //http://blog.airsource.co.uk/index.php/2008/11/12/memory-usage-in-uiimagepickercontroller/
                     //appDelegate.imgPicker = nil;
                }];
        }



    - (void)cameraPicture:(id)sender
        {
            // take the picture here
            RealPropertyApp         *appDelegate = (RealPropertyApp *) [[UIApplication sharedApplication] delegate];
            UIImagePickerController *imgPicker   = appDelegate.imgPicker;

            [imgPicker takePicture];
            cameraPictCount++;
            if (cameraPictCount == 1)
                imgLabel.text = [NSString stringWithFormat:@"1 picture added"];
            else
                imgLabel.text = [NSString stringWithFormat:@"%d pictures added", cameraPictCount];
            //self.isDirty = YES;
            
            //[self entityContentHasChanged:nil];
            [btnCancel addTarget:self action:@selector(cameraCancel:) forControlEvents:UIControlEventTouchUpInside];
        }

- (void)cameraIntPicture:(id)sender
{
    // take the picture here
    RealPropertyApp         *appDelegate = (RealPropertyApp *) [[UIApplication sharedApplication] delegate];
    UIImagePickerController *imgPicker   = appDelegate.imgPicker;
    
    [imgPicker takePicture];
    cameraPictCount++;
    if (cameraPictCount == 1)
        imgLabel.text = [NSString stringWithFormat:@"1 INT picture added"];
    else
        imgLabel.text = [NSString stringWithFormat:@"%d INT pictures added", cameraPictCount];
    //self.isDirty = YES;
    
    //[self entityContentHasChanged:nil];
    [btnCancel addTarget:self action:@selector(cameraCancel:) forControlEvents:UIControlEventTouchUpInside];
}



    - (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
        {
        }



    - (void)imagePickerController:(UIImagePickerController *)picker
    didFinishPickingMediaWithInfo:(NSDictionary *)info
        {
            // Receive the end picture
            cameraImage = [info valueForKey:UIImagePickerControllerOriginalImage];
            // Resize the picture

            CGSize size    = cameraImage.size;
            CGSize newSize = size;

            if (size.height > 1024)
                {
                    CGFloat f = 1024.0 / size.height;
                    newSize = CGSizeMake(size.width * f, 1024.0);
                }
            if (size.width > 1024)
                {
                    CGFloat f = 1024.0 / size.width;
                    newSize   = CGSizeMake(1024.0, size.height * f);
                }
            cameraImage    = [Helper imageWithImage:cameraImage scaledToSize:newSize];

            // cameraImage = [cameraImage fixOrientation];
            [self addNewMedia];
            [[AxDataManager defaultContext] save:nil];
        }



    - (void)deleteAction:(id)btn
        {
            if (btn != btnDelete)
                return;
            // Remove the button for sure!
            [btnDelete removeFromSuperview];
            btnDelete = nil;
            // Remove the picture from the grid & delete it
            [self deleteMedia:mediaAccy];
        }



    - (void)didDismissModalView:(UIViewController *)dialogSender
                    saveContent:(BOOL)saveContent
        {
            if (saveContent)
                {
                    // Update the content
                    if (dialogSender == mediaDialogBox)
                        [self addNewMedia];
                    
                    [self entityContentHasChanged:nil];
                }
            [self dismissViewControllerAnimated:YES completion:^(void)
                {
                }];
        }

#pragma mark - Check if the data is valid

    - (BOOL)shouldSaveData
        {
            if ([self shouldSwitchView] == NO)
                return NO;
            
            if ([self validateBusinessRules] == NO)
                return NO;

            if (!self.isDirty)
                return YES;
            
            [self saveCurrentDetails];
            return YES;
        }



    - (BOOL)validateBusinessRules
        {
            if (detailController != nil && ![detailController validateBusinessRules])
                return NO;

            return YES;
        }

#pragma mark - validation errors

    - (BOOL)shouldSwitchView
        {
            if (detailController == nil)
                {
                    return [self shouldSwitchView:self.workingBase];
                }
            return [detailController shouldSwitchView:detailController.workingBase];
        }



    - (int)validationError:(int)errorType
        {
            if (detailController == nil)
                return [super validationError:errorType];
            return [detailController validationError:errorType];
        }



    - (NSArray *)validationErrorList
        {
            if (detailController == nil)
                return [super validationErrorList];
            return [detailController validationErrorList];
        }

#pragma mark - View lifecycle

	// DBaun 062914 (New Permit Form) Comments and formatting
    // This is where the detail base controller instantiates a detail controller, and detail grid
    // and then decides which to display to the user.
    - (void)viewDidLoad
        {
            [super viewDidLoad];
            [self initDefaultValues];
            
            
            if (dontUseDetailController)
                return;
            // Detail controller
            NSString *detail = [baseNibName stringByAppendingString:@"Detail"];
            
            detailController = [[NSClassFromString(detail) alloc] initWithNibName:detail bundle:nil];
            detailController.itsController      = self;     // the controller for the TabBaseDetail controller is self (TabBase)
            detailController.propertyController = self.propertyController;  // The propertyController is RealProperty

            if (detailController == nil)
                return;

            if ([detailController.view isKindOfClass:[BaseView class]])
                {
                    ((BaseView *) detailController.view).delegate = self;
                }
            // List controller
            NSString *grid = [baseNibName stringByAppendingString:@"Grid"];

            gridController = [[NSClassFromString(grid) alloc] initWithNibName:grid bundle:nil];
            gridController.itsController      = self;
            gridController.propertyController = self.propertyController;

            // Switch to detail controller or list controller based on preferences

            [self displayGrid];
            [[gridController getFirstGridController] setGridContent:[self getDefaultOrderedList]];

            [self switchControlBar:kGridControlModeDeleteAdd];

            // Update the detail medias
            [self updateDetailMedia];

            // Point to the detail media controller
            self.mediaController = detailController.mediaController;

            //cv potential place
            if ([Helper isDeviceInLandscape])
                [self willRotateToInterfaceOrientation:UIInterfaceOrientationLandscapeLeft duration:0];
            else
                [self willRotateToInterfaceOrientation:UIInterfaceOrientationPortrait duration:0];

            // turn on the animation
            animationOn = NO;

            if ([[[gridController getFirstGridController] getGridContent] count] == 1)
                {
                    [self gridRowSelection:[gridController getFirstGridController] rowIndex:0];
                }
            animationOn = YES;

        }



    - (void)viewDidUnload
        {
            [super viewDidUnload];
            // Release any retained subviews of the main view.
            // e.g. self.myOutlet = nil;
        }



    - (void)didSwitchToSubController
        {
            //(lldb) po gridController
//            <TabBuildingGrid: 0x7f323e90>
//            
//            (lldb) po baseNibName
//            TabBuilding
            
            [Helper findAndResignFirstResponder:self.view];
            if ([Helper isDeviceInLandscape])
                [self willRotateToInterfaceOrientation:UIInterfaceOrientationLandscapeLeft duration:0];
            else
                [self willRotateToInterfaceOrientation:UIInterfaceOrientationPortrait duration:0];
        }



    - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
        {
            return TRUE;
        }



    - (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                    duration:(NSTimeInterval)duration
        {
            [Helper findAndResignFirstResponder:self.view];

            BOOL landscapeMode = NO;
            if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
                landscapeMode = YES;

            // When the controller is a single controller, rotate content
            if (detailController == nil)
                [nibReader rotateViews:self.view landscapeMode:landscapeMode];
            else
                {

                    // Rotate the principal controller
                    UIView *view = [self.view viewWithTag:501];
                    if (!landscapeMode)
                        view.frame = CGRectMake(0, 35, 768, 748);
                    else
                        view.frame = CGRectMake(0, 35, 1024, 768);  // DBaun - How can this not be a bug?  The screen is never 1024 x 1024, so I'm changing it to 768.
                    view = [self.view viewWithTag:502];
                    if (!landscapeMode)
                        view.frame = CGRectMake(0, 0, 768, 35);
                    else
                        // cv
                        //view.frame = CGRectMake(0, 0, 1024, 35);
                        view.frame = CGRectMake(0, 0, 1024, 768);

                    view = [self.view viewWithTag:500];
                    if (!landscapeMode)
                        view.frame = CGRectMake(0, 0, 768, 1024);
                    else
                        view.frame = CGRectMake(0, 0, 1024, 768);
                    }

                    // Rotate the detail controller
                    [nibReader rotateViews:detailController.view landscapeMode:landscapeMode];
                    // Rotate the list controller
                    if (gridController != nil)
                        [gridController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];

                    [controlBar btnCancel].titleLabel.textColor = [UIColor whiteColor];

                    // adjust the current bar (if any)
                    [controlBar willRotateToInterfaceOrientation:toInterfaceOrientation duration:0];
                        
                    //}
                    
                    
                    
                    
//                }

            if (topView != nil)        
                {
                    [self removeBlockingViews];
                    [self addBlockingViews:UIInterfaceOrientationIsLandscape(toInterfaceOrientation)];
                }

            
        }



    - (void)didReceiveMemoryWarning
        {
            // Releases the view if it doesn't have a superview.
            [super didReceiveMemoryWarning];

        }



// Create 2 views that used to block the tabs at the top and at the bottom
    - (void)addBlockingViews:(BOOL)landScape
        {
            RealPropertyApp *appDelegate = (RealPropertyApp *) [[UIApplication sharedApplication] delegate];
            BOOL barAtBottom = [appDelegate.tabBarController isBarAtBottom];
            if (landScape)
                {
                    if (topView == nil)
                        topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 87)];
                    if (bottomView == nil)
                        {
                            if (barAtBottom)
                                bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, 748 - 48, 1024, 48)];
                            else
                                bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, 87, 1024, 48)];
                        }
                }
            else
                {
                    if (topView == nil)
                        topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 768, 87)];
                    if (bottomView == nil)
                        {
                            if (barAtBottom)
                                bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, 1004 - 48, 768, 48)];
                            else
                                bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, 87, 768, 48)];
                        }

                }
            topView.backgroundColor    = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
            topView.opaque             = YES;
            bottomView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
            bottomView.opaque          = YES;
            //5/18/16 cv DvModeler does not need the subviews top/bottom views
            if (modelController == nil)
            {
                [appDelegate.tabBarController.view addSubview:topView];
                [appDelegate.tabBarController.view addSubview:bottomView];
            }
            else
            {
                [appDelegate.tabBarController.view insertSubview:topView atIndex:[appDelegate.tabBarController.view.subviews count] -1 ];
                [appDelegate.tabBarController.view insertSubview:bottomView atIndex:[appDelegate.tabBarController.view.subviews count] -1 ];
            }
//            else if (self.buildingToPlan == TRUE)
//            {
//                [appDelegate.tabBarController.view addSubview:topView];
//                [appDelegate.tabBarController.view addSubview:bottomView];
//                self.buildingToPlan = FALSE;
//
//            }
//            else if(self.buildingToPlan == FALSE)
//            {
//                [appDelegate.tabBarController.view insertSubview:topView atIndex:[appDelegate.tabBarController.view.subviews count] -1 ];
//                [appDelegate.tabBarController.view insertSubview:bottomView atIndex:[appDelegate.tabBarController.view.subviews count] -1 ];
//                //self.buildingToPlan = FALSE;
//            }



            
            //count -1
            RealProperty *rp = [RealProperty instance];
            [rp.segmentedControlLightController moveBadgesToView:topView target:self];
        }



    - (void)removeBlockingViews
        {
            [self removeTopView];
            [self removeBottomView];

        }



    - (void)removeTopView
        {
            if (topView == nil)
                return;
            RealProperty *rp = [RealProperty instance];
            [rp.segmentedControlLightController restoreBadges:self];
            [topView removeFromSuperview];
            topView = nil;
        }



    - (void)removeBottomView
        {
            [bottomView removeFromSuperview];
            bottomView = nil;
        }



    - (void)tabPicturesDelegateDismiss
        {
            if (topView != nil)
                topView.hidden = NO;
            [self refreshMedias];
        }

@end
