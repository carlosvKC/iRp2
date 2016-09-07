#import <QuartzCore/QuartzCore.h>
#import "RealProperty.h"
#import "TabDetailsController.h"
#import "TabLandController.h"
#import "TabBuilding.h"
#import "TabAccy.h"
#import "TabMobile.h"
#import "TabHistoryController.h"
#import "TabHIExmpt.h"
#import "TabInterest.h"
#import "TabNotes.h"
#import "TabValue.h"

#import "AxDataManager.h"
#import "RealPropertyApp.h"

#import "CaptureView.h"

#import "PictureDetails.h"
#import "Helper.h"

#import "SelectedObject.h"
#import "ImpsViewController.h"

#import "IRNote.h"

#import "ValidationController.h"
#import "BookmarkReason.h"

#import "TabBookmarkController.h"

#import "DashboardToDoData.h"
#import "DashboardToDoTableViewController.h"
#import "RealPropertyApp.h"




@implementation RealProperty
{
    // Popover must be stored in an instance variable to avoid going out of scope after method creates it.
    UIPopoverController *theToDoItemsPopover;
    DashboardToDoData *todoData;
}

    @synthesize segmentedCtrl;
    @synthesize isDirty;
    @synthesize parcelNbr;
    @synthesize noProperty;
    @synthesize segmentedControlLightController;

    static RealPropInfo __strong       *realPropInfo;
    static SelectedProperties __strong *selectedProperties;
    static RealProperty                *realProperty;



    + (RealPropInfo *)realPropInfo
        {
            return realPropInfo;
        }



    + (SelectedProperties *)selectedProperties
        {
            return selectedProperties;
        }



    + (RealProperty *)instance
        {
            return realProperty;
        }



    + (void)setSelectedProperties:(SelectedProperties *)p
        {
            selectedProperties = p;
        }



#pragma mark - Initialization
    - (id)initWithNibName:(NSString *)nibNameOrNil
                   bundle:(NSBundle *)nibBundleOrNil
        {
            self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
            if (self)
                {
                    self.title = @"Property";
                    self.tabBarItem.image = [UIImage imageNamed:@"Home.png"];
                    realProperty = self;
                }
            return self;
        }


#pragma mark - Load the data
//
// Load the current parcel (based on the parcel 10 digits number)
//
    - (void)loadParcelWithString:(NSString *)parcelStr
        {
            NSString *major = [parcelStr substringToIndex:6];
            NSString *minor = [parcelStr substringFromIndex:6];

            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"major MATCHES %@ AND minor MATCHES %@", major, minor];

            realPropInfo = [AxDataManager getEntityObject:@"RealPropInfo" andPredicate:predicate];
            
            parcelNbr = realPropInfo.parcelNbr;

            if (realPropInfo == nil)
            NSLog(@"Parcel '%@-%@' can't be loaded", major, minor);

            [self updateLabel:realPropInfo];

            [menuBar setItemEnable:kCtrlBarSave isEnable:NO];
            [menuBar setItemEnable:kCtrlBarUndo isEnable:NO];

            [self checkForValidParcel];
            
        }

    - (void)loadParcelWithGuid:(NSString *)guidRP
        {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"guid=%@", guidRP];
            realPropInfo = [AxDataManager getEntityObject:@"RealPropInfo" andPredicate:predicate];
            parcelNbr = realPropInfo.parcelNbr;
            if (realPropInfo == nil)
                NSLog(@"Parcel guid '%@' can't be loaded", guidRP);
            [self updateLabel:realPropInfo];
            [menuBar setItemEnable:kCtrlBarSave isEnable:NO];
            [menuBar setItemEnable:kCtrlBarUndo isEnable:NO];
            [self checkForValidParcel];
        }

    - (void)loadParcelWithInfo:(RealPropInfo *)real
        {
            realPropInfo = real;
            parcelNbr    = realPropInfo.parcelNbr;
            [self updateLabel:real];
            [menuBar setItemEnable:kCtrlBarSave isEnable:NO];
            [menuBar setItemEnable:kCtrlBarUndo isEnable:NO];
            [self checkForValidParcel];
            
            [self runDashboardQueries];
        }



    - (void)updateLabel:(RealPropInfo *)real
        {
            parcelNbr = real.parcelNbr;
            [menuBar setupBarLabel:[NSString stringWithFormat:@"%@-%@ (%d/%d)", realPropInfo.major, realPropInfo.minor,
                                                              parcelsIndex + 1, selectedProperties.memGridIndex.count]];

            Inspection *inspection = real.inspection;
            [self setCurrentImps:inspection.inspectionTypeItemId];

        }



    - (void)loadParcelWithRealPropId:(int)realPropId
        {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"realPropId=%d", realPropId];
            realPropInfo = [AxDataManager getEntityObject:@"RealPropInfo" andPredicate:predicate];
            parcelNbr    = realPropInfo.parcelNbr;

            if (realPropInfo == nil)
            NSLog(@"Parcel '%d' can't be loaded", realPropId);

            [self updateLabel:realPropInfo];
            [menuBar setItemEnable:kCtrlBarSave isEnable:NO];
            [menuBar setItemEnable:kCtrlBarUndo isEnable:NO];
            [self checkForValidParcel];
        }



    - (void)toolbarBackSelected
        {
        }



    - (void)disableSaveUndoButton
        {
            [menuBar setItemEnable:kCtrlBarSave isEnable:NO];
            [menuBar setItemEnable:kCtrlBarUndo isEnable:NO];

        }



#pragma mark - Switch between the different tabs
    - (void)switchToPictureController:(NSArray *)medias
                             selected:(id)media
                       fromController:(ScreenController *)controller
        {
            if (tabPicturesController == nil)
                tabPicturesController = [[TabPicturesController alloc] initWithNibName:@"TabPicturesController" bundle:nil];
            tabPicturesController.propertyController = self;
            tabPicturesController.itsController      = controller;
            tabPicturesController.medias             = (NSMutableArray *) medias;
            tabPicturesController.currentMedia       = media;
            tabPicturesController.delegate           = (id <TabPicturesDelegate>) controller;

            UIView *view = [self.view viewWithTag:1020];
            if (view == nil)
                {
                    NSLog(@"cant find view 1020");
                    return;
                }
            [view addSubview:tabPicturesController.view];
            [view bringSubviewToFront:tabPicturesController.view];
            [self addChildViewController:tabPicturesController];

            tabPicturesController.view.frame = CGRectOffset(tabPicturesController.view.frame, 1024, 0);
            // ANIMATE: move from right to left
            [view bringSubviewToFront:tabPicturesController.view];

            [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^
                {
                    tabPicturesController.view.frame = CGRectOffset(tabPicturesController.view.frame, -1024, 0);
                }            completion:nil];

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



    - (void)switchSegment:(id)sender
        {
            UISegmentedControl *control = sender;
#if 0
    NSTimeInterval time = [NSDate timeIntervalSinceReferenceDate];
    
    if(time-lastClick < 0.4)
    {
        control.selectedSegmentIndex = lastSelectedIndex;
        return;
    }
    else
    {
        lastSelectedIndex = control.selectedSegmentIndex;
        lastClick = time;
    }
#endif
            // Switch to a new segment

            NSInteger index = [control selectedSegmentIndex];
            [Helper findAndResignFirstResponder:self.view];
            [self switchView:index];


        }



// Display the first building (this is to allow to take pictures from the dashboard)
    - (void)switchToFirstBuilding
        {
            segmentedCtrl.selectedSegmentIndex = kTabBuilding;
            [self switchView:kTabBuilding];
            noAnimation = YES;
            TabBuilding *building = (TabBuilding *) tabBuildingController;

            ScreenController *gridController = building.gridController;

            // turn on the animation
            building.animationOn = NO;

            [building gridRowSelection:[gridController getFirstGridController] rowIndex:0];
            building.animationOn = YES;
            noAnimation = NO;
        }



    - (void)updateBadge
        {
            // there are errors in the current view.
            [activeSubController shouldSwitchView];
            int errors   = [activeSubController validationError:kValidationError];
            int warnings = [activeSubController validationError:kValidationWarning];

            if (errors + warnings == 0)
                {
                    [segmentedControlLightController removeBadgeAtIndex:[self findExistingIndex:activeSubController]];
                }
            else
                {
                    UIColor *color;
                    if (errors > 0)
                        color = [UIColor redColor];
                    else
                        color = [UIColor orangeColor];

                    [segmentedControlLightController addBadgeAtIndex:[self findExistingIndex:activeSubController] number:warnings + errors color:color];
                }
        }



    - (void)updateUserDate:(TabBase *)controller
        {
            if (![controller isKindOfClass:[TabBase class]])
                return;
            if ([controller respondsToSelector:@selector(activeSubController)] && controller.activeSubController != nil)
                {
                    [self updateUserDate:controller.activeSubController];
                    return;
                }
            if (controller.workingBase != nil)
                {
                    [RealPropertyApp updateUserDate:controller.workingBase];
                    [controller setScreenEntities];
                }
            else
                {
                    [RealPropertyApp updateUserDate:controller.detailController.workingBase];
                    [controller.detailController setScreenEntities];
                }

        }



    - (int)findExistingIndex:(UIViewController *)viewController
        {
            if (viewController == tabDetailsController)
                return kTabDetails;
            if (tabLandController == viewController)
                return kTabLand;
            if (tabBuildingController == viewController)
                return kTabBuilding;
            if (tabAccyController == viewController)
                return kTabAccy;
            if (tabMobileController == viewController)
                return kTabMobile;
            if (tabHistoryController == viewController)
                return kTabHistory;
            if (tabHIEController == viewController)
                return kTabHIE;
            if (tabInterestController == viewController)
                return kTabInterest;
            if (tabNoteController == viewController)
                return kTabNote;
            if (tabValuesController == viewController)
                return kTabValue;
            return 0;

        }



// Switch the current view to a new view
    - (void)switchView:(int)index
        {
            UIView *subview = [self.view viewWithTag:1];

            // Capture the current top view
            CaptureView *captview = [[CaptureView alloc] initWithView:[self.view viewWithTag:1]];

            if (subview == nil)
                @throw [NSException exceptionWithName:@"TabPropertyController:switchView" reason:[NSString stringWithFormat:@"Can't find the view with tag=%d", 1] userInfo:nil];

            UIViewController *newController;
            // Insert the new controller
            switch (index)
                {
                    case kTabDetails:
                        if (tabDetailsController == nil)
                            tabDetailsController = [[TabDetailsController alloc] initWithNibName:@"TabDetails" bundle:nil];
                        newController = tabDetailsController;
                        break;
                    case kTabLand:
                        if (tabLandController == nil)
                            tabLandController = [[TabLandController alloc] initWithNibName:@"TabLand" bundle:nil];
                        newController = tabLandController;
                        break;
                    case kTabBuilding:
                        if (tabBuildingController == nil)
                            tabBuildingController = [[TabBuilding alloc] initWithNibName:@"TabBuilding" landscape:@"TabBuildingLandscape"];
                        newController = tabBuildingController;
                        break;
                    case kTabAccy:
                        if (tabAccyController == nil)
                            tabAccyController = [[TabAccy alloc] initWithNibName:@"TabAccy" landscape:@"TabAccyLandscape"];
                        newController = tabAccyController;
                        break;
                    case kTabMobile:
                        if (tabMobileController == nil)
                            tabMobileController = [[TabMobile alloc] initWithNibName:@"TabMobile" landscape:@"TabMobileLandscape"];
                        newController = tabMobileController;
                        break;
                    case kTabHistory:
                        if (tabHistoryController == nil)
                            tabHistoryController = [[TabHistoryController alloc] initWithNibName:@"TabHistoryController" bundle:nil];
                        newController = tabHistoryController;
                        break;
                    case kTabHIE:
                        if (tabHIEController == nil)
                            tabHIEController = [[TabHIExmpt alloc] initWithNibName:@"TabHIExmpt" bundle:nil];
                        newController = tabHIEController;
                        break;
                    case kTabInterest:
                        if (tabInterestController == nil)
                            tabInterestController = [[TabInterest alloc] initWithNibName:@"TabInterest" bundle:nil];
                        newController = tabInterestController;
                        break;
                    case kTabNote:
                        if (tabNoteController == nil)
                            tabNoteController = [[TabNotes alloc] initWithNibName:@"TabNotes" portraitId:500 landscape:@"TabNotesLandscape" landscapeId:500];
                        newController = tabNoteController;
                        break;
                    case kTabValue:
                        if (tabValuesController == nil)
                            tabValuesController = (TabBase *) [[TabValue alloc] initWithNibName:@"TabValue" bundle:nil];
                        newController = tabValuesController;
                        break;
                }
            // Associate the controller with the error badge
            [segmentedControlLightController linkBadgeToController:index target:newController];

            // it needs to be here to keep the new controller active
            ((ScreenController *) newController).propertyController = self;

            // Add the new view
            [self addChildViewController:newController];
            [subview addSubview:newController.view];

            if ([newController respondsToSelector:@selector(didSwitchToSubController)])
                [newController performSelector:@selector(didSwitchToSubController)];
            // Ready to go. Add the preview top view (except the first time)
            noAnimation = YES;  // fix a bug #8224
            if (activeSubController != nil && !noAnimation)
                {
                    // Move the subview down
                    [subview addSubview:captview];
                    [subview bringSubviewToFront:captview];

                    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                                     animations:^
                                         {
                                             captview.frame = CGRectOffset(captview.frame, 0, 1024);
                                         }
                                     completion:^(BOOL finished)
                                         {
                                             // Remove the existing view and the existing controller
                                             [activeSubController.view removeFromSuperview];
                                             [activeSubController removeFromParentViewController];
                                             currentIndex        = index;
                                             activeSubController = (TabBase *) newController;
                                             [segmentedControlLightController refreshLights];
                                             [captview removeFromSuperview];
                                             [self updateBadge];

                                         }];
                }
            else
                {
                    currentIndex        = index;
                    activeSubController = (TabBase *) newController;
                    [segmentedControlLightController refreshLights];
                    [captview removeFromSuperview];
                    [self updateBadge];
                }
            captview    = nil;

        }



    - (void)removeOneController:(UIViewController *)controller
        {
            [controller.view removeFromSuperview];
            [controller removeFromParentViewController];
            controller.view = nil;
            controller = nil;
        }



    - (void)removeAllControllers
        {
            [self removeOneController:tabAccyController];
            [self removeOneController:tabMobileController];
            [self removeOneController:tabBuildingController];
            [self removeOneController:tabHistoryController];
            [self removeOneController:tabLandController];
            [self removeOneController:tabHIEController];
            [self removeOneController:tabInterestController];
            [self removeOneController:tabNoteController];
            [self removeOneController:tabValuesController];

            activeSubController   = nil;
            tabAccyController     = nil;
            tabMobileController   = nil;
            tabBuildingController = nil;
            tabHistoryController  = nil;
            tabLandController     = nil;
            tabDetailsController  = nil;
            tabHIEController      = nil;
            tabInterestController = nil;
            tabNoteController     = nil;
            tabValuesController   = nil;
        }



// Change the color of the segment indicators
    - (void)setSegmentIndicator:(int)segment
                          value:(enum segLightConstant)indicator
        {
            if (indicator == kSegLightOrange || indicator == kSegLightRed)
                isDirty = YES;
            [segmentedControlLightController changeLightStateOfSegment:segment color:indicator];
        }



//
// Turn the light on
    - (void)segmentOn:(int)segment
        {
            [self setSegmentIndicator:segment value:kSegLightGreen];
        }

    - (void)segmentUsed:(int)segment
        {
            [self setSegmentIndicator:segment value:kSegLightRed];

            // Update button status
            [menuBar setItemEnable:kCtrlBarSave isEnable:YES];
            [menuBar setItemEnable:kCtrlBarUndo isEnable:YES];
            // Keep track of the property being modified
            [RealPropertyApp setPropertyBeingModified:realPropInfo.realPropId];
            [self updateBadge];
            //cv 7/1/2015 the update User gets defined on ctrl itslef for this case since there are specific UserUpdate(sale prcl,sale verif,sale)
            if (![activeSubController.nibName isEqualToString:@"TabHistoryController"])

                [self updateUserDate:activeSubController];
        }

    - (void)updateBadge:(BOOL)removeBadge
        {
            if (removeBadge)
                {
                    [segmentedControlLightController removeBadgeAtIndex:[self findExistingIndex:activeSubController]];
                }
            else
                {
                    [self updateBadge];
                }
        }

    - (void)segmentOff:(int)segment
        {
            [self setSegmentIndicator:segment value:kSegLightGray];
        }



#pragma mark - Update all the indicators
    - (void)checkResourceForValue:(NSString *)resource
                          segment:(int)segment
                       baseEntity:(id)baseEntity
        {
            if (baseEntity == nil)
                return;

            if ([baseEntity isKindOfClass:[NSSet class]])
                {
                    int count = 0; //[baseEntity count];
                    NSEnumerator *enumerator = [baseEntity objectEnumerator];

                    id object;
                    while ((object = [enumerator nextObject]) != nil)
                        {
                            if (![[object valueForKey:@"rowStatus"] isEqualToString:@"D"])
                                count++;
                        }
                    if (count > 0)
                        [self segmentOn:segment];
                    else
                        [self segmentOff:segment];
                    return;
                }
            ScreenDefinition *screen = [EntityBase getScreenWithName:resource];
            if ([ScreenController checkIfEntitiesHaveValue:baseEntity withScreen:screen])
                [self segmentOn:segment];
        }

    - (void)checkResourceForValue:(NSString *)resource
                          segment:(int)segment
        {
            [self checkResourceForValue:resource segment:segment baseEntity:realPropInfo];
        }

    - (BOOL)checkNotes
        {
            if ([realPropInfo.noteRealPropInfo count] > 0)
            {
                NSSet *noteInfo = realPropInfo.noteRealPropInfo;
                //cv 10/07/14 Do not "lightup indicator if object is mark for deletion
                for (NoteRealPropInfo *rpNote in noteInfo)
                    if(![rpNote.rowStatus isEqualToString:@"D"])
                    {
                      return YES;  
                    }
            }
            for (SaleParcel *saleParcel in realPropInfo.saleParcel)
                if(![saleParcel.rowStatus isEqualToString:@"D"])
                {
                    Sale *sale = saleParcel.sale;
                    if ([sale.noteSale count] > 0)
                        return YES;
                }
            for (Review     *review in realPropInfo.review)
                if(![review.rowStatus isEqualToString:@"D"])
                {
                    if ([review.noteReview count] > 0)
                        return YES;
                }
            for (HIExmpt    *hi in realPropInfo.hIExempt)
                if(![hi.rowStatus isEqualToString:@"D"])
                {
                    if ([hi.noteHIExmpt count] > 0)
                        return YES;
                }
            return NO;
        }

    - (void)updateAllIndicators
        {
            if (realPropInfo == nil)
                return;
            [self checkResourceForValue:@"TabDetails" segment:kTabDetails baseEntity:realPropInfo];

            [self checkResourceForValue:@"TabLand" segment:kTabLand baseEntity:realPropInfo.land];
            [self checkResourceForValue:@"TabLandViews" segment:kTabLand baseEntity:realPropInfo.xland];
            [self checkResourceForValue:@"TabLandNuisance" segment:kTabLand baseEntity:realPropInfo.xland];
            [self checkResourceForValue:@"TabLandDesignations" segment:kTabLand baseEntity:realPropInfo.xland];
            [self checkResourceForValue:@"TabLandEnvironment" segment:kTabLand baseEntity:realPropInfo.land];

            [self checkResourceForValue:@"TabBuildingDetail" segment:kTabBuilding baseEntity:realPropInfo.resBldg];
            [self checkResourceForValue:@"TabAccyDetail" segment:kTabAccy baseEntity:realPropInfo.accy];

            [self checkResourceForValue:@"TabMobileDetail" segment:kTabMobile baseEntity:realPropInfo.mHAccount];


            [self checkResourceForValue:@"TabPermitsDetail" segment:kTabHistory baseEntity:realPropInfo.permit];

            [self checkResourceForValue:@"TabSaleDetail" segment:kTabHistory baseEntity:realPropInfo.saleParcel];
            [self checkResourceForValue:@"TabReviewsDetail" segment:kTabHistory baseEntity:realPropInfo.review];
            [self checkResourceForValue:@"TabChangesDetail" segment:kTabHistory baseEntity:realPropInfo.chngHist];
            [self checkResourceForValue:@"TabValHistDetail" segment:kTabHistory baseEntity:realPropInfo.valHist];


            [self checkResourceForValue:@"TabHIExmptDetail" segment:kTabHIE baseEntity:realPropInfo.hIExempt];

            [self checkResourceForValue:@"TabInterestDetail" segment:kTabInterest baseEntity:realPropInfo.undividedInt];

            if ([self checkNotes])
                [self segmentOn:kTabNote];

            [self checkResourceForValue:@"GridValueTaxRoll" segment:kTabValue baseEntity:realPropInfo.taxRoll];
            [self checkResourceForValue:@"GridValueAppraisal" segment:kTabValue baseEntity:realPropInfo.valHist];
            [self checkResourceForValue:@"GridValueEstimate" segment:kTabValue baseEntity:realPropInfo.valEst];

            // Remove the badges
            [segmentedControlLightController removeAllBadges];

        }



    - (void)createDialogBox
        {
            PictureDetails *itsDialogBox = [[PictureDetails alloc] initWithNibName:@"PictureDetails" bundle:nil];
            CGSize size = itsDialogBox.view.frame.size;
            // itsDialogBox.delegate = self;
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:itsDialogBox];
            navController.modalPresentationStyle = UIModalPresentationFormSheet;
            [self presentViewController:navController animated:YES completion:^(void)
                {
                }];

            navController.view.superview.frame  = CGRectMake(0, 0, size.width, size.height);
            navController.view.superview.center = self.view.superview.superview.center;
        }



#pragma mark - Menu functions
//
// If there is no parcel, hide the current screen
//
    - (void)checkForValidParcel
        {
            int count = selectedProperties.memGridIndex.count;
            [noProperty removeFromSuperview];
            invalidViewAdded = NO;

            if (count == 0)
                {
                    [self.view addSubview:noProperty];
                    [self.view bringSubviewToFront:noProperty];
                    invalidViewAdded = YES;
                }
            [segmentedControlLightController removeAllBadges];
        }


//
// switch the parcel without any checking
//
    - (void)switchToParcel:(id)parcelStr
        {
            realPropInfo = nil;
            if ([parcelStr isKindOfClass:[NSString class]])
                if ([parcelStr length]== 10) {
                    [self loadParcelWithString:parcelStr];
                }
                else
                    
                    [self loadParcelWithGuid:parcelStr];
                else if ([parcelStr isKindOfClass:[NSNumber class]])
                    [self loadParcelWithRealPropId:[parcelStr intValue]];
            
            [self removeAllControllers];

            // Confirmation box
            [self updateAllIndicators];
            [self switchView:currentIndex];
            self.segmentedCtrl.selectedSegmentIndex = currentIndex;
            self.isDirty = NO;
            [self checkForValidParcel];
            [self updateBadge];
            [self runDashboardQueries];
            
        }



    - (BOOL)validateParcel
        {
            if (self.isDirty)
                {
                    validateParcelAlert = [[UIAlertView alloc] initWithTitle:@"Attention!" message:@"The content of the current parcel has changed and will be lost if you switch to another parcel" delegate:self cancelButtonTitle:@"Stay On Parcel" otherButtonTitles:@"Discard & Continue", @"Save & Continue", nil];
                    [validateParcelAlert show];

                    return NO;
                }
            return YES;
        }



#pragma mark - call back after the alert view

    - (void)moveToOneParcel
        {
            [self switchToParcel:switchToParcelNbr];
            parcelsIndex = [selectedProperties indexOfInfo:realPropInfo];
            parcelNbr    = switchToParcelNbr;
            [self updateLabel:realPropInfo];
            [self adjustArrows];
        }



    - (void)moveToNextParcel
        {
            parcelsIndex++;
            [self adjustArrows];

            NSNumber *number = [[NSNumber alloc] initWithInt:[selectedProperties findPropertyId:parcelsIndex]];
            [self switchToParcel:number];
        }



    - (void)moveToPreviousParcel
        {
            parcelsIndex--;
            [self adjustArrows];

            NSNumber *number = [[NSNumber alloc] initWithInt:[selectedProperties findPropertyId:parcelsIndex]];
            [self switchToParcel:number];
        }



//
// Start moving at the parcel at the top of the list
//
    - (void)moveToMultipleParcels
        {
            parcelsIndex = 0;
            [self adjustArrows];
            NSNumber *number = [[NSNumber alloc] initWithInt:[selectedProperties findPropertyId:parcelsIndex]];
            [self switchToParcel:number];

        }



    - (void)adjustArrows
        {
            [menuBar setItemEnable:kCtrlBarNext isEnable:NO];
            [menuBar setItemEnable:kCtrlBarPrevious isEnable:NO];

            // Move to next
            if (parcelsIndex < [selectedProperties.memGridIndex count] - 1)
                [menuBar setItemEnable:kCtrlBarNext isEnable:YES];

            if (parcelsIndex > 0)
                [menuBar setItemEnable:kCtrlBarPrevious isEnable:YES];

        }


#pragma mark - switch between parcels
//
// Switch to a new parcel and check if the current is dirty
//
    - (void)validateAndSwitchToParcel:(id)parcelStr
                             tabIndex:(int)index
                                 guid:(NSString *)guid
        {
            switchToParcelNbr  = parcelStr;
            selectorAfterAlert = nil;
            if (![self validateParcel])
                {
                    selectorAfterAlert = @selector(moveToOneParcel);
                    return;
                }
            [self switchToParcel:switchToParcelNbr];
            parcelsIndex = [selectedProperties indexOfInfo:realPropInfo];
            parcelNbr    = switchToParcelNbr;
            [self updateLabel:realPropInfo];
            [self adjustArrows];
            // Need to move to the appropriate index
            // need to select the tab -- skip this part for the time being [self switchView:index];
        }



    - (void)validateAndSwitchToParcel:(id)parcelStr
        {
            switchToParcelNbr  = parcelStr;
            selectorAfterAlert = nil;
            if (![self validateParcel])
                {
                    selectorAfterAlert = @selector(moveToOneParcel);
                    return;
                }
            [self moveToOneParcel];
        }



    - (void)switchToCamera:(id)parcelStr
        {
            switchToParcelNbr  = parcelStr;
            selectorAfterAlert = nil;
            if (![self validateParcel])
            {
                selectorAfterAlert = @selector(moveToOneParcel);
            }
            else
            {
                [self moveToOneParcel];
            }
            [self switchToFirstBuilding];
            [(TabBase *) tabBuildingController gridMediaAddPicture:nil];

        }



    - (void)btnNext
        {
            if (![self validateParcel])
                {
                    selectorAfterAlert = @selector(moveToNextParcel);
                    return;
                }
            [self moveToNextParcel];

        }



    - (void)btnPrevious
        {
            if (![self validateParcel])
                {
                    selectorAfterAlert = @selector(moveToNextParcel);
                    return;
                }
            [self moveToPreviousParcel];
        }



    - (void)validateAndSwitchToMultipleParcels
        {
            if (![self validateParcel])
                {
                    selectorAfterAlert = @selector(moveToMultipleParcels);
                    return;
                }
            [self moveToMultipleParcels];
        }



// Handle the IMPS section
    - (void)btnImps
        {
            
            if (impsPopOver != nil)
                return;

            ImpsViewController *imps = [[ImpsViewController alloc] initWihRealPropInfo:realPropInfo nibName:@"ImpsViewController"];
            imps.itsController = self;

            imps.contentSizeForViewInPopover = CGSizeMake(imps.view.frame.size.width,
                    imps.view.frame.size.height);

            impsPopOver = [[UIPopoverController alloc] initWithContentViewController:imps];
            impsPopOver.delegate = self;

            [impsPopOver presentPopoverFromBarButtonItem:[menuBar getBarButtonItem:kCtrlBarImps] permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
        }


//
// Discard the current changes (if they exist) and reset the content as it was
//
    - (void)btnUndo
        {
            // NSUndoManager;

            if (self.isDirty)
                {
                    NSManagedObjectContext *context = [AxDataManager getContext:@"default"];
                    [context rollback];
                    [self switchToParcel:parcelNbr];
                }
        }



    - (BOOL)checkForSaving:(TabBase *)baseController
        {
            if (baseController == nil)
                return YES;
            return [baseController shouldSaveData];
        }



//
// Save the current property
// Add it to a list of properties to sync up
    - (BOOL)btnSave
        {
            NSManagedObjectContext *context = [AxDataManager getContext:@"default"];
            [Helper findAndResignFirstResponder:self.view];

            int errorMask = 0;

            // Collect the number of possible errors
            if (![self checkForSaving:tabDetailsController])
                errorMask |= kBookmarkErrorDetails;

            if (![self checkForSaving:tabLandController])
                errorMask |= kBookmarkErrorLand;

            if (![self checkForSaving:tabBuildingController])
                errorMask |= kBookmarkErrorBuilding;

            if (![self checkForSaving:tabMobileController])
                errorMask |= kBookmarkErrorMobile;

            if (![self checkForSaving:tabAccyController])
                errorMask |= kBookmarkErrorAccessory;

            if (![self checkForSaving:tabHistoryController])
                errorMask |= kBookmarkErrorHistory;

            if (![self checkForSaving:tabHIEController])
                errorMask |= kBookmarkErrorHIE;

            if (![self checkForSaving:tabInterestController])
                errorMask |= kBookmarkErrorInterest;

            if (![self checkForSaving:tabNoteController])
                errorMask |= kBookmarkErrorNote;

            if (![self checkForSaving:tabValuesController])
                errorMask |= kBookmarkErrorValue;

            NSError *error;
            
            if (![context save:&error])
                {
                    NSLog(@"Context save error: %@", [error userInfo]);
                    return NO;
                }
            [self updateAllIndicators];

            // if the property has error, it is automatically added as an error
            [TabBookmarkController updateBookmarkErrors:errorMask withInfo:realPropInfo];
            [TabBookmarkController updateBookmarkErrors];

            // Update the sub-tabs
            if (tabLandController != nil)
                [(TabLandController *) tabLandController updateAllIndicators];
            if (tabHistoryController != nil)
                [(TabHistoryController *) tabHistoryController updateAllIndicators];

            self.isDirty = NO;

            [self disableSaveUndoButton];
            [RealPropertyApp setPropertyBeingModified:0];

            [RealPropertyApp setQueryReady:NO];
            
            [self runDashboardQueries];
            
            return YES;
        }



    - (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
        {
            // 0 is cancel the switch and stay on same parcel
            // 1 is discard the change, so continue on same parcel
            // 2 is save & continue

            if (alertView == validateParcelAlert)
                {
                    if (buttonIndex == 0)
                        {
                            return;
                        }
                    else if (buttonIndex == 2)
                        {
                            if ([self btnSave] == NO)
                                {
                                    return;
                                }

                        }
                    else if (buttonIndex == 1)
                        {
                            // discard changes
                            [self btnUndo];
                        }
                    // Continue the selection -- current change is being eliminated
                    if (selectorAfterAlert != nil)
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                        [self performSelector:selectorAfterAlert];
                }
        }


#pragma mark - Delegates
    - (void)menuBarBtnBackSelected
        {
        }


// Selection is done of the toolbar
    - (void)menuBarBtnSelected:(int)tag
        {

            ScreenController *ctrl = (ScreenController *) activeSubController;
            if (![ctrl checkTextfieldsAreValid])
                return;
            if (impsPopOver != nil)
                {
                    [impsPopOver dismissPopoverAnimated:NO];
                    impsPopOver = nil;
                }
            if (menu != nil)
                {
                    [menu cancelMenu];
                    menu = nil;
                }
            switch (tag)
                {
                        
                    case kCtrlBarToDo:
                    {
                         // Display the ToDo popover
                        NSLog(@"The todo bar button has been tapped");
                        UIButton *dashboardToDoButton = [menuBar getDashboardToDoButton];
                        [self displayDashboardPopoverOnButton:dashboardToDoButton];
                        break;
                    }
                    case kCtrlBarBookmark:
                    {
                        // Display the bookmarks
                        menu = [[MenuTable alloc] initFromResource:@"MenuBookmark"];
                        [menu presentMenu:[menuBar getBarButtonItem:kCtrlBarBookmark] withDelegate:self];
                        break;
                    }
                    case kCtrlBarWebLinks:
                    {
                        menu = [[MenuTable alloc] initFromResource:@"MenuWeb"];
                        //cv 4/1/15 adding parcelNbr for dynamic web links
                        [menu storeParcelNbr:[selectedProperties findParcelNbr:parcelsIndex]];
                        [menu presentMenu:[menuBar getBarButtonItem:kCtrlBarWebLinks] withDelegate:self];
                        break;
                    }
                    case kCtrlBarImps:
                        [self btnImps];
                        break;
                    case kCtrlBarNext:
                        [self btnNext];
                        break;
                    case kCtrlBarPrevious:
                        [self btnPrevious];
                        break;
                    case kCtrlBarSave:
                        [self btnSave];
                        break;
                    case kCtrlBarUndo:
                        [self btnUndo];
                        break;
                    case kCtrlBarMap:
                        {
                            RealPropertyApp *appDelegate = (RealPropertyApp *) [[UIApplication sharedApplication] delegate];
                            NSNumber        *number      = [[NSNumber alloc] initWithInt:[selectedProperties findPropertyId:parcelsIndex]];

                            [appDelegate selectPropertyOnMap:number];
                        }
                        break;
                    case kCtrlNewNote:
                        [self createNote];
                        break;
                    default:
                        break;
                }
        }



    - (void)menuTableBeforeDisplay:(NSString *)menuName
                         withItems:(NSArray *)array
        {
        }



    - (void)menuTableMenuSelected:(NSString *)menuName
                          withTag:(int)tag
                        withParam:(id)param
        {
            NSString *string = menuName;
            NSString *paramString = nil;
            //            for( id obj in param ){
            //               // [obj description];
            //                NSLog("%@", [obj description]);
            //            }
            if ([string compare:@"MenuBookmark"] == NSOrderedSame)
                paramString =[param description];
                {
                    if (([paramString compare:@"b7"] == NSOrderedSame) || ([paramString compare:@"b8"] == NSOrderedSame) || ([paramString compare:@"b5"] == NSOrderedSame)
                        || ([paramString compare:@"b11"] == NSOrderedSame) || ([paramString compare:@"b2"] == NSOrderedSame) || ([paramString compare:@"b3"] == NSOrderedSame)
                        || ([paramString compare:@"b4"] == NSOrderedSame) || ([paramString compare:@"b6"] == NSOrderedSame) || ([paramString compare:@"c0"] == NSOrderedSame)
                        ||([paramString compare:@"c1"] == NSOrderedSame) || ([paramString compare:@"d9"] == NSOrderedSame)
                        )
                        {
                            MenuTable *myMenu = [[MenuTable alloc] initFromResource:@"MenuBookmark"];
                            [TabBookmarkController createBookmark:[myMenu getMenuName:param] withInfo:realPropInfo typeItem:kBookmarkErrorRegular typeItemId:[myMenu getTypeItem:param]];
                            [self runDashboardQueries];
                            
                        // it will be nice to get the icon
                        createBookmarkDesc:[myMenu getMenuName:param];
                            
                            return;
                        }
                    
                    if ([paramString compare:@"d10"] == NSOrderedSame) //|| ([param caseInsensitiveCompare:@"web"] == NSOrderedSame))
                        {
                            [self createBookmarkReason];
                            return;
                        }


                    if ([paramString compare:@"nosync"] == NSOrderedSame)
                        {
                            MenuTable *myMenu = [[MenuTable alloc] initFromResource:@"MenuBookmark"];
                            [TabBookmarkController createBookmark:[myMenu getMenuName:param] withInfo:realPropInfo typeItem:kBookmarkErrorRegular typeItemId:[myMenu getTypeItem:param]];
                            return;
                        }
                    
                    MenuTable *myMenu = [[MenuTable alloc] initFromResource:@"MenuBookmark"];
                    [TabBookmarkController createBookmark:[myMenu getMenuName:param] withInfo:realPropInfo typeItem:kBookmarkErrorRegular typeItemId:[myMenu getTypeItem:param]];
                }
            if([string compare:@"MenuWeb"] == NSOrderedSame); paramString = [param description];
                {
                    if ([paramString compare:@"w1"] == NSOrderedSame)
                        {
                    MenuTable *myMenu = [[MenuTable alloc] initFromResource:@"MenuBookmark"];
                    [TabBookmarkController createBookmark:[myMenu getMenuName:param] withInfo:realPropInfo typeItem:kBookmarkErrorRegular typeItemId:[myMenu getTypeItem:param]];
                    return;
                        }
                }
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

    + (void)createBookmarkDesc:(NSString *)reason
        {
    
    
        }

    - (void)didDismissModalView:(NSObject *)dialog
                    saveContent:(BOOL)saveContent
        {
            if (saveContent)
                {
                    //[TabBookmarkController createBookmark:((BookmarkReason *) dialog).details.text withInfo:realPropInfo typeItem:kBookmarkErrorRegular typeItemId:10];
                    [TabBookmarkController createBookmarkWithReason:((BookmarkReason *) dialog).details.text withInfo:realPropInfo];
                }
            [self dismissViewControllerAnimated:YES completion:nil];
        }


#pragma mark - Returns media for parcel
    + (int)getNumberOfMedias:(RealPropInfo *)realPropInfo
        {
            NSArray *array = [self findAllMedias:realPropInfo cnt:0];
            return array.count;
        }



    + (NSSet *)getPicture:(RealPropInfo *)realPropInfo
                    index:(int)index
        {
            NSArray *resMedia = [self findAllMedias:realPropInfo cnt:0];
            if (resMedia.count == 0)
                return nil;

            if (index < 0 || index >= [resMedia count])
                return nil;

            return [resMedia objectAtIndex:index];
        }



    + (NSArray *)getAllBuildingPictures:(RealPropInfo *)realPropInfo
        {
            NSArray *resMedia = [self findAllBuildingMedias:realPropInfo cnt:0];
            return resMedia;
        }



//+ (MediaBldg *)getNextBuildingPicture:(RealPropInfo *)realPropInfo media:(NSSet *)currentMedia
//{
//    int index = [RealProperty findCurrentMedia:realPropInfo media:currentMedia];
//    if(index== -1)
//        return nil;
//    NSArray *array= [self findAllBuildingMedias:realPropInfo cnt:0];
//    if(array.count==0)
//        return nil;
//    if(index==[array count]-1)
//        return nil;
//    index++;
//    return [array objectAtIndex:index];
//}
//+ (MediaBldg *)getPreviousBuildingPicture:(RealPropInfo *)realPropInfo media:(NSSet *)currentMedia
//{
//    int index = [RealProperty findCurrentMedia:realPropInfo media:currentMedia];
//    if(index== -1)
//        return nil;
//    NSArray *array= [self findAllBuildingMedias:realPropInfo cnt:0];
//    if(array.count==0)
//        return nil;
//    if(index==0)
//        return nil;
//    index--;
//    return [array objectAtIndex:index];
//}
// 2/20/13 HNN get next picture; supports vacant land, mobile homes, etc
    + (NSSet *)getNextPicture:(RealPropInfo *)realPropInfo
                        media:(NSSet *)currentMedia
        {
            int index = [RealProperty findCurrentMedia:realPropInfo media:currentMedia];
            if (index == -1)
                return nil;
            NSArray *array = [self findAllMedias:realPropInfo cnt:0];
            if (array.count == 0)
                return nil;
            if (index == [array count] - 1)
                return nil;
            index++;
            return [array objectAtIndex:index];

        }



// 2/20/13 HNN get next picture; supports vacant land, mobile homes, etc
    + (NSSet *)getPreviousPicture:(RealPropInfo *)realPropInfo
                            media:(NSSet *)currentMedia
        {
            int index = [RealProperty findCurrentMedia:realPropInfo media:currentMedia];
            if (index == -1)
                return nil;
            NSArray *array = [self findAllMedias:realPropInfo cnt:0];
            if (array.count == 0)
                return nil;
            if (index == 0)
                return nil;
            index--;
            return [array objectAtIndex:index];

        }



    + (int)findCurrentMedia:(RealPropInfo *)realPropInfo
                      media:(NSSet *)currentMedia
        {

            NSArray *array = [self findAllMedias:realPropInfo cnt:0];

            for (int i = 0; i < array.count; i++)
                {
                    NSSet *media = [array objectAtIndex:i];
                    if (media == currentMedia)
                        return i;
                }
            return -1;
        }



    + (MediaBldg *)getBuildingPicture:(RealPropInfo *)realPropInfo
        {
            MediaBldg *media = nil;

            @try
                {
                    // Find an appropriate media -- if any
                    NSArray *array = [self findAllBuildingMedias:realPropInfo cnt:1];

                    if (array.count > 0)
                        return [array objectAtIndex:0];
                }
            @catch (NSException *exception)
                {

                }
            return media;
        }



/// 2/20/13 HNN get default pict for the parcel
    + (NSSet *)getPicture:(RealPropInfo *)realPropInfo
        {
            @try
                {
                    // Find an appropriate media -- if any
                    NSArray *array = [self findAllMedias:realPropInfo cnt:1];

                    if (array.count > 0)
                        return [array objectAtIndex:0];

                }
            @catch (NSException *exception)
                {

                }
            return nil;
        }



// 2/20/13 HNN added cnt param so that we don't have to process all the bldg media if we only want the first
    + (NSArray *)findAllBuildingMedias:(RealPropInfo *)propinfo
                                   cnt:(int)cnt
        {
            // Compile the list of all medias

            // 2/20/13 HNN sort by bldg nbr first
            NSMutableArray *bldgs = [[NSMutableArray alloc] init];
            //Land           *land  = propinfo.land;
            [bldgs addObjectsFromArray:[AxDataManager orderSet:propinfo.resBldg property:@"bldgNbr" ascending:YES]];

            NSMutableArray *medias = [[NSMutableArray alloc] init];
            // Residence pictures
            for (ResBldg   *resBldg in bldgs)
                {
                    //NSArray *sortedArray = [MediaView sortMedia:resBldg.mediaBldg];

                    //[medias addObjectsFromArray:[AxDataManager orderSet:resBldg.mediaBldg property:@"updateDate" ascending:YES]];
                    [medias addObjectsFromArray:[self sortMedia:[AxDataManager setToArray:resBldg.mediaBldg]]];
                    //[medias addObjectsFromArray:sortedArray];

                    if (medias.count >= cnt && cnt > 0)
                        break;
                }
            return medias;
        }



//
// Returns all the media
//
    + (NSArray *)findAllMedias:(RealPropInfo *)propinfo
        {
            return [self findAllMedias:propinfo cnt:0];
        }



//
// Returns all the media
//
    + (NSArray *)findAllMedias:(RealPropInfo *)propinfo
                           cnt:(int)cnt
        {
            // Compile the list of all medias
            NSMutableArray *medias = [[NSMutableArray alloc] init];
            NSArray        *array  = nil;
            // 2/20/13 HNN changed picture order to bldg, mobile, accy, land

            // Residence pictures
            // 2/20/13 HNN get bldg picts in correct order
            [medias addObjectsFromArray:[self findAllBuildingMedias:propinfo cnt:cnt]];

            if (medias.count >= cnt && cnt > 0)
                {
                    array = [[NSArray alloc] initWithArray:medias];
                    return array;
                }


            // Mobile pictures
            for (MHAccount *mhAccount in propinfo.mHAccount)
                {
                    [medias addObjectsFromArray:[self sortMedia:[AxDataManager setToArray:mhAccount.mediaMobile]]];

                    if (medias.count >= cnt && cnt > 0)
                        break;
                }

            if (medias.count >= cnt && cnt > 0)
                {
                    array = [[NSArray alloc] initWithArray:medias];
                    return array;
                }

            // Accessory pictures
            for (Accy *accy in propinfo.accy)
                {
                    [medias addObjectsFromArray:[self sortMedia:[AxDataManager setToArray:accy.mediaAccy]]];
                    if (medias.count >= cnt && cnt > 0)
                        break;
                }

            if (medias.count >= cnt && cnt > 0)
                {
                    array = [[NSArray alloc] initWithArray:medias];
                    return array;
                }

            Land *land = propinfo.land;

            [medias addObjectsFromArray:[self sortMedia:[AxDataManager setToArray:land.mediaLand]]];

            if (medias.count >= cnt && cnt > 0)
                {
                    array = [[NSArray alloc] initWithArray:medias];
                    return array;
                }

            // Sale note
            for (SaleParcel *saleParcel in propinfo.saleParcel)
                {
                    Sale *sale = saleParcel.sale;

                    NSEnumerator *enumerator = [sale.noteSale objectEnumerator];
                    NoteSale     *noteSale;
                    while (noteSale = [enumerator nextObject])
                        {
                            if ([noteSale.mediaNote count])
                                {
                                    [medias addObjectsFromArray:[self sortMedia:[AxDataManager setToArray:noteSale.mediaNote]]];

                                    if (medias.count >= cnt && cnt > 0)
                                        break;
                                }
                        }
                    if (medias.count >= cnt && cnt > 0)
                        break;
                }

            if (medias.count >= cnt && cnt > 0)
                {
                    array = [[NSArray alloc] initWithArray:medias];
                    return array;
                }

            // HIExmpt
            for (HIExmpt *hiexmpt in propinfo.hIExempt)
                {
                    NSEnumerator *enumerator = [hiexmpt.noteHIExmpt objectEnumerator];
                    NoteHIExmpt  *noteHIExmpt;
                    while (noteHIExmpt = [enumerator nextObject])
                        {
                            if ([noteHIExmpt.mediaNote count] != 0)
                                {
                                    [medias addObjectsFromArray:[self sortMedia:[AxDataManager setToArray:noteHIExmpt.mediaNote]]];
                                    if (medias.count >= cnt && cnt > 0)
                                        break;
                                }
                        }
                    if (medias.count >= cnt && cnt > 0)
                        break;
                }

            if (medias.count >= cnt && cnt > 0)
                {
                    array = [[NSArray alloc] initWithArray:medias];
                    return array;
                }


            // Review
            for (Review *review  in propinfo.review)
                {
                    NSEnumerator *enumerator = [review.noteReview objectEnumerator];
                    NoteReview   *noteReview;
                    while (noteReview = [enumerator nextObject])
                        {
                            if ([noteReview.mediaNote count] != 0)
                                {
                                    [medias addObjectsFromArray:[self sortMedia:[AxDataManager setToArray:noteReview.mediaNote]]];
                                    if (medias.count >= cnt && cnt > 0)
                                        break;
                                }
                        }
                    if (medias.count >= cnt && cnt > 0)
                        break;
                }

            if (medias.count >= cnt && cnt > 0)
                {
                    array = [[NSArray alloc] initWithArray:medias];
                    return array;
                }


            // RealPropInfo
            NSEnumerator     *enumerator = [propinfo.noteRealPropInfo objectEnumerator];
            NoteRealPropInfo *noteRealPropInfo;
            while (noteRealPropInfo = [enumerator nextObject])
                {
                    if ([noteRealPropInfo.mediaNote count] != 0)
                        {
                            [medias addObjectsFromArray:[self sortMedia:[AxDataManager setToArray:noteRealPropInfo.mediaNote]]];
                            if (medias.count >= cnt && cnt > 0)
                                break;
                        }
                }

            array = [[NSArray alloc] initWithArray:medias];
            return array;
        }



//
// Sorting function of a media
//
    + (NSArray *)sortMedia:(NSArray *)mediaToBeSorted
        {
            // Resort the Medias
            NSArray *sortedArray = [mediaToBeSorted sortedArrayUsingComparator:^(id a,
                                                                                 id b)
                {
                    // Order by imagetype
                    int imageTypea = [a imageType];
                    int imageTypeb = [b imageType];

                    if (imageTypea > imageTypeb)
                        return NSOrderedDescending;
                    if (imageTypea < imageTypeb)
                        return NSOrderedAscending;

                    // Order by primary
                    int prima = [a primary];
                    int primb = [b primary];

                    if (prima)
                        return NSOrderedAscending;
                    if (primb)
                        return NSOrderedDescending;

                    // Order by year
                    // 4/27/16 HNN added  | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit so that we have that data for the
                    // hour, min, sec comparison below in order to sort to that precision
                    
                    NSDateComponents *componentsa = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit  fromDate:[NSDate dateWithTimeIntervalSinceReferenceDate:[a mediaDate]]];
                    NSDateComponents *componentsb = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:[NSDate dateWithTimeIntervalSinceReferenceDate:[b mediaDate]]];

                    if ([componentsa year] > [componentsb year])
                        return NSOrderedAscending;
                    if ([componentsa year] < [componentsb year])
                        return NSOrderedDescending;

                    // order on the order!
                    int ordera = [a order];
                    int orderb = [b order];

                    if (ordera == 0)
                        ordera = 9999;
                    if (orderb == 0)
                        orderb = 9999;

                    if (ordera != orderb)
                        {
                            return ordera > orderb;
                        }


                    // order on media date
//                    if ([a mediaDate] > [b mediaDate])
//                        return NSOrderedAscending;
//                    if ([a mediaDate] > [b mediaDate])
//                        return NSOrderedDescending;
                    
                    // 4/27/16 HNN not sure why the above media date comparison doesn't work sometimes but its weird that
                    // the mediaDate within this sort shows as yyyy-mm-dd hh:mm:ss:ms when I expected it to be a double since its declared
                    // nstimeinterval. the code below works though
                    if ([componentsa month] > [componentsb month])
                        return NSOrderedAscending;
                    if ([componentsa month] < [componentsb month])
                        return NSOrderedDescending;

                    if ([componentsa day] > [componentsb day])
                        return NSOrderedAscending;
                    if ([componentsa day] < [componentsb day])
                        return NSOrderedDescending;

                    if ([componentsa hour] > [componentsb hour])
                        return NSOrderedAscending;
                    if ([componentsa hour] < [componentsb hour])
                        return NSOrderedDescending;

                    if ([componentsa minute] > [componentsb minute])
                        return NSOrderedAscending;
                    if ([componentsa minute] < [componentsb minute])
                        return NSOrderedDescending;

                    if ([componentsa second] > [componentsb second])
                        return NSOrderedAscending;
                    if ([componentsa second] < [componentsb second])
                        return NSOrderedDescending;
                    
                    return NSOrderedSame;

                }];

            return sortedArray;
        }

#pragma mark - TabBar delegate
    -(void)tabBarWillSwitchController
        {
            if (tabPicturesController == nil)
                return;
            [tabPicturesController.view removeFromSuperview];
            [tabPicturesController removeFromParentViewController];
            tabPicturesController.view = nil;
            tabPicturesController = nil;
        }



    -(void)activateController
        {
            // Adjust the screen...
            if ([Helper isDeviceInLandscape])
                {
                    [self willRotateToInterfaceOrientation:UIInterfaceOrientationLandscapeLeft duration:0];
                }
            else
                {
                    [self willRotateToInterfaceOrientation:UIInterfaceOrientationPortrait duration:0];
                }

            [self checkForValidParcel];
            [self updateBadge];
            [self updateLabel:realPropInfo];
            [self runDashboardQueries];
            
            if (selectedProperties.memGridIndex.count > 0)
                {
                    // Validate that the parcel is still valid
                    if (![selectedProperties isRealPropInfoInIndex:realPropInfo])
                        {
                            // then we need to move to first object on the grid
                            [self moveToMultipleParcels];
                        }
                }
            [self adjustArrows];
        }

#pragma mark - Popover delegate
    - (void)popoverControllerDidDismissPopover:(UIPopoverController *)popover
        {
            //DBaun Dashboard ToDo - I may have to do some work here to distinguish between the ToDo popover and this imps popover.            
            if (theToDoItemsPopover && ( popover == theToDoItemsPopover))
                popover = nil;
            else
                impsPopOver = nil;
        }



    - (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController
        {
            return YES;
        }


    - (void)setCurrentImps:(int)value
        {
            NSString *name;

            switch (value)
                {
                    case 0:
                        name = @"imp2";
                    break;
                    case 2:
                        name = @"imp3";
                    break;
                    case 1:
                        name = @"imp4";
                    break;
                    case 3:
                        name = @"imp1";
                    default:
                        break;
                }
            UIBarButtonItem *btn = [menuBar getBarButtonItem:15];
            btn.image = [UIImage imageNamed:name];
        }


#pragma mark - View lifecycle


    static char *labelTabs[] = {
            "Details",
            "Land",
            "Bldg",
            "Accy",
            "Mobile",
            "Hist.",
            "Hi Ex",
            "Undiv",
            "Note",
            "Value"
    };



    - (void)viewDidLoad
        {
            [super viewDidLoad];
            currentIndex = kTabDetails;
            parcelNbr    = @"";

            for (int i = 0; i < segmentedCtrl.numberOfSegments; i++)
                {
                    [segmentedCtrl setTitle:[NSString stringWithUTF8String:labelTabs[i]] forSegmentAtIndex:i];
                }

            // On the first time, load the default tab which is kTabDetails
            tabDetailsController = [[TabDetailsController alloc] initWithNibName:@"TabDetails" bundle:nil];
            ((ScreenController *) tabDetailsController).propertyController = self;

            // Create the views of the buttons
            segmentedControlLightController = [[SegmentedControlLightController alloc] initWithSegmentedControl:segmentedCtrl destView:self.view];
            [self addChildViewController:segmentedControlLightController];

            [self updateAllIndicators];

            [self switchView:kTabDetails];

            UIView *view = [self.view viewWithTag:1010];
            if (view == nil)
                {
                    NSLog(@"MenuBar: can't find the view with tag 1010");
                    return;
                }
            
            menuBar = [[ControlBar alloc] initWithNibName:@"RealPropertyControlBar" bundle:nil];
            [view addSubview:menuBar.view];
            [self addChildViewController:menuBar];
            [menuBar setupBarLabel:parcelNbr];
            menuBar.delegate = self;

            [self createAndPlaceDashboardToDoButton];
            
               
            [self checkForValidParcel];

        }



    - (void)viewDidUnload
        {
            [[NSNotificationCenter defaultCenter] removeObserver:self];
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



    - (void)didReceiveMemoryWarning
        {
            [super didReceiveMemoryWarning];
            RealPropertyApp *appDelegate = (RealPropertyApp *) [[UIApplication sharedApplication] delegate];
            [appDelegate cleanUpZipCache];
        }



    - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
        {
            return YES;
        }



    - (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                    duration:(NSTimeInterval)duration
        {
            [Helper findAndResignFirstResponder:self.view];
            [segmentedControlLightController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
            UIView *view = [self.view viewWithTag:1];

            if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
                {
                    // Adjust control bar
                    UIView *viewMenu = [self.view viewWithTag:1010];
                    viewMenu.frame     = CGRectMake(0, 0, 1024, 44);
                    menuBar.view.frame = viewMenu.frame;

                    view.frame       = CGRectMake(0, 90, 1024, 656);
                    noProperty.frame = CGRectMake(0, 0, 1024, 748);

                    self.view.frame = CGRectMake(0, 0, 1024, 748);
                }
            else
                {
                    // Adjust control bar
                    UIView *viewMenu = [self.view viewWithTag:1010];
                    viewMenu.frame     = CGRectMake(0, 0, 768, 44);
                    menuBar.view.frame = viewMenu.frame;

                    view.frame       = CGRectMake(0, 90, 768, 866);
                    noProperty.frame = CGRectMake(0, 0, 768, 1004);

                    self.view.frame = CGRectMake(0, 0, 768, 1004);
                }
        }



//
// Edit or create a note attached to this property
//
    - (void)createNote
        {
            IRNote      *note      = nil;
            // Look for a note with the same ID
            //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"rpGuid=%@", realPropInfo.guid];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"realPropId=%d", realPropInfo.realPropId];
            
            
            note = [AxDataManager getEntityObject:@"IRNote" andPredicate:predicate andContext:[AxDataManager noteContext]];
            if (note == nil)
                {
                    note = [AxDataManager getNewEntityObject:@"IRNote" andContext:[AxDataManager noteContext]];
                    note.realPropId = realPropInfo.realPropId;
                    note.rpGuid = realPropInfo.guid;
                    note.major      = realPropInfo.major;
                    note.minor      = realPropInfo.minor;
                    note.parcelNbr  = realPropInfo.parcelNbr;

                }
            baseNote = [[BaseNote alloc] initWithNibName:@"BaseNote" bundle:nil];
            baseNote.delegate = self;
            // switch to the keyboard notes
            UIView *view = [self.view viewWithTag:1020];
            [view addSubview:baseNote.view];
            [self addChildViewController:baseNote];
            [view bringSubviewToFront:baseNote.view];
            baseNote.currentNote = note;
            [baseNote removeHome];
            


            UIView *topView = baseNote.view;

            topView.frame = CGRectOffset(topView.frame, 1024, 0);
            [self deregisterFromKeyboardNotifications];

            [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^
                {
                    topView.frame = CGRectOffset(topView.frame, -1024, 0);
                }            completion:nil];
        }



    - (void)noteMgrCloseNote:(id)note
        {
            UIView *topView = baseNote.view;

            [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseOut

                             animations:^
                                 {
                                     topView.frame = CGRectOffset(topView.frame, 1024, 0);
                                 }
                             completion:^(BOOL finished)
                                 {
                                     [topView removeFromSuperview];
                                     [baseNote removeFromParentViewController];
                                     baseNote = nil;
                                 }
            ];
//            [AxDataManager noteContext] context;
//            NSManagedObjectContext *context = [AxDataManager noteContext];
//            [context save:nil];


        }



// this method is a dummy method to catch edge cases
    - (void)noteMgrSwitchToProperty:(id)note
        {
        }


#pragma mark - Dashboard To Do list

    - (void)runDashboardQueries
    {
        if (!todoData)
            todoData = [[DashboardToDoData alloc]init];
    
        if (!realPropInfo) {
            NSLog(@"No valid realPropInfo, so exiting method");
            return;
        }
        
        UIButton *toDoButton = [menuBar getDashboardToDoButton];
        
        //NSString *theAcctNumber = [NSString stringWithFormat:@"%@%@",realPropInfo.major, realPropInfo.minor];
        
        [todoData theToDoItemsforAssmtYr:[RealPropertyApp taxYear]-1
                           andRealPropId:realPropInfo.realPropId
                               andRpGuid:realPropInfo.guid
                              andLndGuid:realPropInfo.lndGuid
                             andPropType:realPropInfo.propType // @"R"
                      withManagedContext:realPropInfo.managedObjectContext];
        
        if ([todoData.toDoItems count]>0) {
            //MKNumberBadgeView *theBadge = [[MKNumberBadgeView alloc]initWithFrame:CGRectMake(32, -5, 18, 18)]; // :CGRectMake(0, 0, 15, 15)
            MKNumberBadgeView *theBadge = [self getBadgeFromToDoButton:toDoButton];
            theBadge.shadow = YES;
            theBadge.shine = YES;
            theBadge.fillColor = [UIColor redColor];
            theBadge.strokeColor = [UIColor whiteColor];
            theBadge.backgroundColor = [UIColor redColor];
            theBadge.alignment = NSTextAlignmentCenter;
            theBadge.value = [todoData.toDoItems count];

            [toDoButton addSubview:theBadge];
            [toDoButton setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
            
        }
        else
            [self removeBadgeFromToDoButton:toDoButton];
            
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


    // This technique is necessary rather than simply drag and dropping a button on the control bar in the
    // interface builder because a UIButton isn't the type of control that's designed to be placed on a menu bar.
    // The menu bar expects a BarButtonItem.
    // It's also necessary because a BarButtonItem cannot hold a badge (apparently), and placing a UIButton on top of
    // a BarButtonItem also doesn't work because the BarButtonItem clips the badge where it would otherwise extend
    // outside the border of the button it's placed on.
    -(void)createAndPlaceDashboardToDoButton
    {
        // Create and configure a 'ToDo' button, then add it to menubar.
        UIButton *theToDoButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 30)];
        [theToDoButton setTitle:@"ToDo" forState:UIControlStateNormal];
        [theToDoButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        //[theToDoButton setBackgroundImage:[self imageFromColor:[UIColor lightGrayColor]] forState:UIControlStateNormal];
        theToDoButton.layer.cornerRadius = 6;
        theToDoButton.clipsToBounds = NO;
        theToDoButton.layer.masksToBounds = NO;
        //theToDoButton.layer.borderColor = [UIColor blackColor].CGColor;
        theToDoButton.layer.borderWidth = 0;
        theToDoButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        theToDoButton.tag = 2;
        [menuBar addButton:theToDoButton atIndex:2];
    }



    -(void)toDoListSelectedItem:(NSString *)item
    {
        // Not doing anything with the selected ToDo item at this point.
    }

#pragma mark - Dashboard To Do helper code

- (UIImage *) imageFromColor:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    //  [[UIColor colorWithRed:222./255 green:227./255 blue: 229./255 alpha:1] CGColor]) ;
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}



@end
