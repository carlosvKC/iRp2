#import "TabPicturesController.h"
#import "RealProperty.h"
#import "AxDataManager.h"
#import "PictureView.h"
#import "PictureDetails.h"
#import "Helper.h"
#import "RealPropertyApp.h"
#import "MediaView.h"
#import "TabDetailsController.h"
#import "ReadPictures.h"


@implementation TabPicturesController

    @synthesize pictLabel;
    @synthesize medias;
    @synthesize currentMedia;
    @synthesize scrollView;
    @synthesize delegate;



    - (id)initWithNibName:(NSString *)nibNameOrNil
                   bundle:(NSBundle *)nibBundleOrNil
        {
            self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
            if (self)
                {
                    nibReader = [[NIBReader alloc] initWithNibName:@"TabPicturesController" portraitId:500 landscape:@"TabPicturesControllerLandscape" landscapeId:500];

                }
            return self;
        }



//
// Filter the different images
    - (void)menuFilter
        {
            menu = [[MenuTable alloc] initFromResource:@"MenuFilterTabPicture"];
            [menu presentMenu:[menuBar getBarButtonItem:kBtnOptions] withDelegate:self];
            [menu setMenuCheck:1 checked:YES];
        }



//
// Edit the detail of each picture
    - (void)updateDetail
        {
            itsDialogBox = [[PictureDetails alloc] initWithNibName:@"PictureDetails" bundle:nil];
            CGSize size = itsDialogBox.view.frame.size;
            itsDialogBox.delegate = self;
            [itsDialogBox viewDidLoad];

            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:itsDialogBox];

            navController.modalPresentationStyle = UIModalPresentationFormSheet;
            [self presentViewController:navController animated:YES  completion:^(void)
                {
                }];

            navController.view.superview.frame  = CGRectMake(0, 0, size.width, size.height);
            navController.view.superview.center = self.view.superview.superview.center;

            [itsDialogBox configureDialogBox:@"Edit Caption" btnVisible:NO];

            id clone = [AxDataManager clone:[pictView getCurrentMedia] withSets:NO withLinks:NO];

            [itsDialogBox setMedia:clone];
        }



    - (void)deleteMedia
        {
            NSSet *media = [medias objectAtIndex:currentIndex];

            [medias removeObjectAtIndex:currentIndex];    // Remove it from the list
            [self.mediaController updateMedias:medias];
            [self.itsController deleteMedia:media];

            // Call the delegate to remove the appropriate media
            if (currentIndex >= [medias count])
                currentIndex = [medias count] - 1;    // can be negative...
            [self updateMediaIndex];
        }
#pragma mark - Delegates
//
// Handle the result of the dialog box
    - (void)didDismissModalView:(UIViewController *)dialogSender
                    saveContent:(BOOL)saveContent
        {
            // Update the content
            MediaAccy *clone = [itsDialogBox getMedia];
            if (saveContent)
                {
                    // Update the current media, and bubble up the change
                    MediaAccy *srcMedia = [pictView getCurrentMedia];

                    srcMedia.desc          = clone.desc;
                    srcMedia.primary       = clone.primary;
                    if (![srcMedia.rowStatus isEqualToString:@"I"] && ![srcMedia.rowStatus isEqualToString:@"U"])
                        srcMedia.rowStatus = @"U";

                    srcMedia.updatedBy  = [RealPropertyApp getUserName];
                    srcMedia.updateDate = [[Helper localDate] timeIntervalSinceReferenceDate];
                    srcMedia.postToWeb  = clone.postToWeb;
                    srcMedia.order      = clone.order;

                    RealPropertyApp *app = (RealPropertyApp *) [[UIApplication sharedApplication] delegate];
                    RealProperty    *rp  = (RealProperty *) (app.tabPropertyController);

                    // kill the clone
                    NSManagedObjectContext *context = [AxDataManager defaultContext];
                    [context deleteObject:clone];
#if 0 // Original clone
        if(rp.isDirty)
        {
            // Already dirty...
            [self.itsController entityContentHasChanged:nil];
        }
        else 
        {
            // Save it now...
            [[AxDataManager defaultContext] save:nil];
        }
#endif
                    rp = nil;
                    [self.itsController entityContentHasChanged:nil];
                    [self gridMediaSelection:nil media:srcMedia columnIndex:0];
                    [self refreshMedias:[RealProperty sortMedia:medias]];

                }
            else
                {
                    // kill the clone
                    NSManagedObjectContext *context = [AxDataManager defaultContext];
                    [context deleteObject:clone];
                }
            itsDialogBox = nil;
            [self dismissViewControllerAnimated:YES  completion:^(void)
                {
                }];
        }
//

//
// Return to the main menu
    - (void)menuBarBtnBackSelected
        {
            [delegate tabPicturesDelegateDismiss];
            [self.propertyController switchBackFromPictureController];
        }



// Selection is done of the toolbar
    - (void)menuBarBtnSelected:(int)tag
        {
            switch (tag)
                {
                    case kBtnDetail:
                        [self updateDetail];
                    break;
                    case kBtnDelete:
                        [self deleteMedia];
                    break;
                    case kBtnEditVectors:
                        [self clickInPicture:nil];
                    break;
                    default:
                        break;
                }
        }



//
// A media was selected in the current list
    - (void)gridMediaSelection:(id)grid
                         media:(id)media
                   columnIndex:(int)columnIndex
        {
            // Update the media display
            scrollView.zoomScale = 1.0;
            [pictView setMedia:media];

            // Update the label
            MediaAccy *anyMedia = media;
            NSString  *mediaType;

            if ([media isKindOfClass:[MediaAccy class]])
                mediaType = @"Accessory";
            else if ([media isKindOfClass:[MediaBldg class]])
                mediaType = @"Building";
            else if ([media isKindOfClass:[MediaLand class]])
                mediaType = @"Land";
            else if ([media isKindOfClass:[MediaMobile class]])
                mediaType = @"Mobile Home";
            else if ([media isKindOfClass:[MediaNote class]])
                mediaType = @"Note";

            NSDate   *mediadate  = [anyMedia valueForKey:@"mediaDate"];
            NSString *text  = [NSString stringWithFormat:@"%@   -   %@   %@   %@", mediaType, [Helper stringFromDate:mediadate], anyMedia.primary ? @"Primary" : @"", anyMedia.active ? @"" : @"(inactive)"];
            UILabel  *label = (UILabel *) [self.view viewWithTag:13];
            label.text = text;
            // Find out if there are any comments
            label = (UILabel *) [self.view viewWithTag:14];
            label.text = anyMedia.desc;

            currentIndex = columnIndex;
            // cv need to save a trip to sqlLite
            //            NSDate *now= [NSDate date];
            //            NSCalendar *calendar= [NSCalendar currentCalendar];
            //            NSDateComponents *dateyear= [calendar components:(NSSecondCalendarUnit | NSMinuteCalendarUnit |                                                                           NSHourCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit) fromDate:mediadate];
            
            ///
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy"];
            //NSString *yearString = [formatter stringFromDate:[NSDate date]];
            NSString *mediaYr = [formatter stringFromDate:mediadate];
            //NSString *assmtYr = [NSString stringWithFormat:@"%d", [RealPropertyApp taxYear]-1];
            NSString *imgYr = [NSString stringWithFormat:@"%i",anyMedia.year];
            
            ///
//            if (anyMedia.mediaType == kMediaImage && anyMedia.imageType == 2 && ![self.itsController isKindOfClass:[TabDetailsController class]])
            if (anyMedia.mediaType == kMediaPict && anyMedia.imageType == 2 && ![self.itsController isKindOfClass:[TabDetailsController class]])

            { if (([mediaYr isEqualToString:imgYr]))
                [menuBar setItemEnable:kBtnEditVectors isEnable:YES];
            else
                [menuBar setItemEnable:kBtnEditVectors isEnable:NO];
            }
            else
            {
                [menuBar setItemEnable:kBtnEditVectors isEnable:NO];
            }
        }



    - (void)moveToNextPicture
        {
            if (currentIndex >= [medias count] - 1)
                return;
            scrollView.zoomScale = 1.0;
            currentIndex++;

            [self updateMediaIndex];
        }



    - (void)moveToPreviousPicture
        {
            if (currentIndex <= 0)
                return;
            scrollView.zoomScale = 1.0;
            currentIndex--;

            [self updateMediaIndex];
        }



    - (void)updateMediaIndex
        {
            if (currentIndex < 0)
                [self gridMediaSelection:nil media:nil columnIndex:currentIndex];
            else
                [self gridMediaSelection:nil media:[medias objectAtIndex:currentIndex] columnIndex:currentIndex];
        }
#pragma mark - zoom delegate
    - (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
        {
            return pictView;
        }
#pragma mark - View lifecycle
    - (void)viewDidLoad
        {
            [super viewDidLoad];

            defaultFilter = kPictureAll;

            // Add the menu bar
            UIView *view = [self.view viewWithTag:1010];
            if (view == nil)
                {
                    NSLog(@"MenuBar: can't find the view with tag 1010");
                    return;
                }
            RealPropInfo *propinfo = [RealProperty realPropInfo];

            menuBar = [[ControlBar alloc] initWithNibName:@"TabPicturesControlBar" bundle:nil];
            [view addSubview:menuBar.view];
            [self addChildViewController:menuBar];
            [menuBar addBackButon];
            [menuBar setupBarLabel:[NSString stringWithFormat:@"Picture of %@-%@", propinfo.major, propinfo.minor]];
            menuBar.delegate = self;


            [self addMedia:200 mediaArray:[RealProperty sortMedia:medias]];

            // Add the destination media
            UIView *destView = [self.view viewWithTag:10];
            pictView = [[PictureView alloc] initWithFrame:destView.frame];
            [destView addSubview:pictView];
            pictView.itsController = self;
            [self gridMediaSelection:nil media:currentMedia columnIndex:0];

            scrollView.minimumZoomScale = 1.0;
            scrollView.maximumZoomScale = 10.0;
            scrollView.contentSize      = pictView.frame.size;
            scrollView.delegate         = self;

            [self willRotateToInterfaceOrientation:[Helper deviceOrientation] duration:0];
        }



    - (void)viewDidUnload
        {
            [self setScrollView:nil];
            [super viewDidUnload];
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



    - (void)didReceiveMemoryWarning
        {
            [super didReceiveMemoryWarning];
            // Release any cached data, images, etc that aren't in use.
        }



    - (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                    duration:(NSTimeInterval)duration
        {
            [nibReader rotateViews:self.view landscapeMode:UIInterfaceOrientationIsLandscape(toInterfaceOrientation)];
            pictView.frame = [self.view viewWithTag:10].frame;
            [self gridMediaSelection:nil media:[medias objectAtIndex:currentIndex] columnIndex:currentIndex];
        }



    - (void)setMedias:(NSMutableArray *)list
        {
            medias = [[NSMutableArray alloc] initWithArray:list];
        }



    - (IBAction)clickInPicture:(id)sender
        {
            BOOL copy = NO;
            RealPropInfo *info = [RealProperty realPropInfo];
            MediaBldg       *media    = [medias objectAtIndex:currentIndex];

            if (media.mediaType != kMediaPict || media.imageType != kMediaFplan)
                return;

            if (modelController != nil)
                return;
            
            if (sender != nil)
                return;

            if ([self.itsController isKindOfClass:[TabDetailsController class]])
                {
                    UIAlertView *alert = [Helper alertWithOk:@"No editing" message:@"Please edit the drawing from the appropriate tab (i.e. building, mobile or accessory"];
                    [alert show];
                    return;
                }
            
            
            // Now detect if it is a VCADD file or a new file
            //NSString        *xmlName  = [NSString stringWithFormat:@"%@.cadxml", media.guid ];
            RealPropertyApp *app      = (RealPropertyApp *) [[UIApplication sharedApplication] delegate];
            ReadPictures    *pictures = [app pictureManager];
            NSData          *data     = [pictures getFileDataWithMediaTypeFromDatabase:media.guid mediaType:kMediaFplan];
            
            if (data == nil && media.imageType == kMediaFplan)
            {
                UIAlertView *alert = [Helper alertWithOk:@"Vcadd format" message:@"You can't edit a vcadd file from iRealProperty. Please use the desktop version."];
                [alert show];
                return;
            }
            
            
//            // Now detect if it is a VCADD file
//            if ( (media.postToWeb == 0) && (media.imageType == kMediaFplan)  && (media.mediaType ==kMediaPict) && (media.rowStatus=@"") )
//            {
//                ReadPictures *pictures = [app pictureManager];
//            
//                NSData  *data = [pictures getXmlFileData:media.guid];
//                if (data == nil)
//                    {
//                        UIAlertView *alert = [Helper alertWithOk:@"Vcadd format" message:@"You can't edit a vcadd file from iRealProperty. Please use the desktop version."];
//                        [alert show];
//                        return;
//                    }
//            }
//            
//

            modelController = [[DVModelController alloc] initWithNibName:@"DVModelController" bundle:nil];
            modelController.realPropInfo = info;
            modelController.delegate     = self;
            
            modelController.mediaMode = kCadUpdate;
            
            // 4/26/16 HNN preserve existing drawing by saving changes to a new media record
//            newObject = NO;
            if (data == nil)
            {
                MediaBldg *emptyMedia = [delegate performSelector:@selector(createEmptyMediaObject)];
                modelController.mediaBldg = emptyMedia;
                modelController.mediaMode = kCadNew;
                copy = YES;
            }
            else
            {
                if ([media.rowStatus caseInsensitiveCompare:@"I"]==NSOrderedSame)
                    modelController.mediaMode = kCadUpdateNew;
                modelController.mediaBldg = media;
            }
            
            
            UIViewController *controller = app.window.rootViewController;
            [controller.view addSubview:modelController.view];
            [controller addChildViewController:modelController];
            [controller.view bringSubviewToFront:modelController.view];
            
            UIView *topView = modelController.view;

//            if (copy)  ///is NO or <nil> same when stagingGuid > 0
//                        // po copy should be <nil> to skip
//                {
//                    NSString *xmlName = [NSString stringWithFormat:@"%@.cadxml", media.guid ];

            [modelController loadModel:media.guid];
//                    newObject = YES;
//                }


            topView.frame = CGRectOffset(topView.frame, 1024, 0);

            [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^
                {
                    topView.frame = CGRectOffset(topView.frame, -1024, 0);
                }            completion:nil];
        }



    - (void)dvModelCompleted:(DVModelController *)model
                  completion:(BOOL)cancel
                     animate:(BOOL)animate
        {
            if ([delegate respondsToSelector:@selector(dvModelCompleted:completion:animate:)])
                {
                    [delegate dvModelCompleted:model completion:cancel animate:NO];
                }
            if (!cancel)
                {
                    // 4/26/16 HNN reuse guid of new drawings
                    id media = model.mediaBldg;
                    

                    // 4/26/16 HNN preserve existing drawing by saving changes to a new media record
                    // 4/27/16 HNN new drawing and updates to existing drawing are new drawings that needs to be added to the resbldg.media collection. once a new drawing is added the resbldg.media collection, any updates to that drawing is on the same object so we don't need to add to the resbldg.media collection
                    if (model.mediaMode==kCadUpdate || model.mediaMode==kCadNew)
                    {
                        [medias addObject:media];
//                        medias = [[RealProperty sortMedia:medias] copy];
                    
                        
                    }
                    else
                        [medias replaceObjectAtIndex:currentIndex withObject:media];
                    
                    
                    // 4/27/16 HNN need to update index after the sort orelse it'll be pointing to the wrong drawing
                    medias = [[RealProperty sortMedia:medias] mutableCopy]; // 4/27/16 HNN changed from copy to mutablecopy else the replaceobjectatindex above will crash
                    currentIndex = [medias indexOfObject:media];
                    [self updateMediaIndex];
                    [self refreshMedias:medias];

                   [self.itsController entityContentHasChanged:nil];
                    [pictView setMedia:media];
                    [pictView setNeedsDisplay];
                }

            UIView *topView = modelController.view;

            [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseOut
                             animations:^
                                 {
                                     topView.frame = CGRectOffset(topView.frame, 1024, 0);
                                 }
                             completion:^(BOOL finished)
                                 {
                                     [modelController.view removeFromSuperview];
                                     [modelController removeFromParentViewController];
                                     //[modelController viewDidUnload];
                                     modelController = nil;
                                 }];


        }

@end
