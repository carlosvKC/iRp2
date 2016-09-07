#import "TabLandController.h"
#import "Helper.h"
#import "AxDataManager.h"
#import "RealPropertyApp.h"
#import "ComboBoxController.h"

#import "RealProperty.h"


@implementation TabLandController
@synthesize segmentedSubtab;

static int subtabIndex = kSubViews;

@synthesize segmentedCtrl;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        activeSubController = nil;

    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

 -(void)updateAcres
{
    UITextField *aTextField = (UITextField *)[self.view viewWithTag:11];
    UITextField *acres = (UITextField *)[self.view viewWithTag:25];
    CGFloat ft = [aTextField.text floatValue];
    acres.text = [NSString stringWithFormat:@"%0.2f", ft/43560.0]; 
}


 /// This method is a good hook for inserting code that
 /// should update other fields when something changes.
-(void)entityContentHasChanged:(ItemDefinition *)entity
{
    NSLog(@"entityContentHasChanged");
    // If any content has changed, change indicate status
    [self.propertyController segmentUsed:kTabLand];
    RealPropInfo *propinfo = [RealProperty realPropInfo];
    Land *land = propinfo.land;
    land.rowStatus = @"U";
    self.isDirty = YES;
    [RealPropertyApp updateUserDate:land];
    [self updateBLVTaxYrAndUpdateDate:entity];
    [self setScreenEntities];
}
     
/// DBaun May 2014 - Blv bug fix.
-(void)updateBLVTaxYrAndUpdateDate:(ItemDefinition*)entity
 {
     if ([entity tag]!=7 && [entity tag]!=8)
         return;
     
     RealPropInfo *propinfo = [RealProperty realPropInfo];
     Land *land = propinfo.land;
     
     // Update Core Data
     // This is a pending save.  The user can still leave the record and rollback changes.
     NSString *taxYear = [NSString stringWithFormat:@"%d",[RealPropertyApp taxYear]];
     
     NSNumberFormatter *nbrFormatter = [[NSNumberFormatter alloc] init];
     [nbrFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
     NSNumber *theTaxYr = [nbrFormatter numberFromString:taxYear];
     
     [land setValue:theTaxYr forKey:@"baseLandValTaxYr"];
     [land setValue:[NSDate dateWithTimeIntervalSinceReferenceDate:[[Helper localDate] timeIntervalSinceReferenceDate]] forKey:@"baseLandValDate"];
 }

     
     
-(void)segmentOn:(int)segment
{
    [segmentedControlLightController changeLightStateOfSegment:segment color:kSegLightGreen];
}
-(void)segmentUsed:(int)segment
{
    [segmentedControlLightController changeLightStateOfSegment:segment color:kSegLightRed];
    [self.propertyController segmentUsed:kTabLand];
}
//
// Check the different indicators for the subs
//
-(BOOL) checkResourceForValue:(NSString *)resource segment:(int)segment base:(id)base
{
    ScreenDefinition *screen = [EntityBase getScreenWithName:resource];
    
    BOOL status = [ScreenController checkIfEntitiesHaveValue:base withScreen:screen];
    if(status)
        [self segmentOn:segment];
    return status;
}
-(void) updateAllIndicators
{
    [segmentedControlLightController resetAll];
    [self checkResourceForValue:@"TabLandViews" segment:kSubViews base:[RealProperty realPropInfo].xland];
    [self checkResourceForValue:@"TabLandDesignations" segment:kSubDesignations base:[RealProperty realPropInfo].xland];
    [self checkResourceForValue:@"TabLandNuisance" segment:kSubNuisance base:[RealProperty realPropInfo].xland];
    [self checkResourceForValue:@"TabLandEnvironment" segment:kSubEnvironmental base:[RealProperty realPropInfo].land];
}
//
// A new media is created
//
- (void)addNewMedia
{
    MediaLand *media = [AxDataManager getNewEntityObject:@"MediaLand"];
    [self defaultMediaInformation:media];
    //[media setRowStatus:@"I"];
    RealPropInfo *propinfo = [RealProperty realPropInfo];
    
    Land *land = propinfo.land;
    media.lndGuid = land.guid;
    [land addMediaLandObject:media];
    // Refresh the grid
    // 2/21/13 HNN sort before calling refresh medias because I don't want to sort accross mediatypes (land, bldg, accy, etc)
    [self refreshMedias:[RealProperty sortMedia:[AxDataManager setToArray:land.mediaLand]]];
    //[self refreshMedias:[AxDataManager orderSet:land.mediaLand property:@"order" ascending:NO]];
}

-(void) deleteMedia:(id)media
{
    RealPropInfo *propinfo = [RealProperty realPropInfo];
    Land *land = propinfo.land;
    // [land removeMediaLandObject:media];
    
    if([[media rowStatus] isEqualToString:@"I"])    // media has been inserted locally, then we can delete
    {
        NSManagedObjectContext *context = [AxDataManager defaultContext];
        [land removeMediaLandObject:media];
        [context deleteObject:media];
    }
    else
        [media setRowStatus:@"D"];  // mark as delete
//undo        [media setUpdateDate:[[Helper localDate]timeIntervalSinceReferenceDate]];
        // 2/21/13 HNN sort before calling refresh medias because I don't want to sort accross mediatypes (land, bldg, accy, etc)
        [self refreshMedias:[RealProperty sortMedia:[AxDataManager setToArray:land.mediaLand]]];
        //[self refreshMedias:[AxDataManager orderSet:land.mediaLand property:@"mediaDate" ascending:NO]];
        self.isDirty = YES;
        [self entityContentHasChanged:nil];
}
#pragma mark - Delegate call
// Call when creating a new media
#pragma mark - View lifecycle

- (void)viewDidLoad
{
    dontUseDetailController = YES;
    
    [super viewDidLoad];
    
    defaultMediaEntity = @"MediaLand";
    
    RealPropInfo *propinfo = [RealProperty realPropInfo];
    Land *land = propinfo.land;

    [self setupBusinessRules:land];
    
    // Setup the working base (here RealPropInfo to manage both Land and XLand)
    self.workingBase = land;
    
    NSArray *medias = [AxDataManager orderSet:land.mediaLand property:@"order" ascending:YES]; 
    // 4/27/16 HNN need to sort land medias on the lab tab
    [self addMedia:kTabLandImage mediaArray:[RealProperty sortMedia:medias]];

    // Create the segment light
    segmentedControlLightController = [[SegmentedControlLightController alloc]initWithSegmentedControl:segmentedCtrl destView:self.view];
    [self addChildViewController:segmentedControlLightController];
    
    // Show the first subviews
    [self switchSubViews:subtabIndex];
    segmentedSubtab = (UISegmentedControl *)[self.view viewWithTag:150];
    
    UIImage *selectedSegment = [[UIImage imageNamed:@"SegmentedControlNormal"] stretchableImageWithLeftCapWidth:6 topCapHeight:0];
    [segmentedSubtab setBackgroundImage:selectedSegment forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    selectedSegment = [[UIImage imageNamed:@"SegmentedControlSelected"] stretchableImageWithLeftCapWidth:6 topCapHeight:0];
    [segmentedSubtab setBackgroundImage:selectedSegment forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    
    
    segmentedSubtab.selectedSegmentIndex = subtabIndex;
    
    // Setup entities in current screen
    [self setScreenEntities];
    
    [self updateAcres];
    [self enableFieldWithTag:25 enable:NO];
    
    // Update the local indicators
    [self updateAllIndicators];
    [self willRotateToInterfaceOrientation:[Helper deviceOrientation] duration:0];   
}
// this method is called when new data is updated
- (void)updateDetailMedia
{
}
- (void)viewDidUnload
{
    [self setSegmentedSubtab:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [gridController viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

-(IBAction)segmentControlSelected:(id)sender
{
    UISegmentedControl *segControl = sender;
    
    // toggle to the appropriate views...
    
    int index = [segControl selectedSegmentIndex];
    
    [self switchSubViews:index];
    
}
-(void)switchSubViews:(int)index
{
    subtabIndex = index;
    // Create the 4 subviews
    UIView *subview = [self.view viewWithTag:kTabLandSubviews];
    if(subview == nil)
        @throw [NSException exceptionWithName:@"TabLandController:switchView" reason:[NSString stringWithFormat:@"Can't find the view with tag=%d", kTabLandSubviews] userInfo:nil];
    
    // Remove the existing view and the existing controller
    if(activeSubController!=nil)
    {
        // there is an existing controller
        [activeSubController.view removeFromSuperview];
        [activeSubController removeFromParentViewController];
    }
    
    // Insert the new controller
    switch(index)
    {
        case kSubViews:
            if(subViewsController==nil)
                subViewsController = [[TabLandViews alloc] initWithNibName:@"TabLandViews" bundle:nil];
            activeSubController = (TabBase *)subViewsController;
            break;
        case kSubNuisance:
            if(subNuisanceController==nil)
                subNuisanceController = [[TabLandNuisance alloc] initWithNibName:@"TabLandNuisance" bundle:nil];
            activeSubController = (TabBase *)subNuisanceController;
            break;
        case kSubDesignations:
            if(subDesignationController==nil)
                subDesignationController = [[TabLandDesignations alloc] initWithNibName:@"TabLandDesignations" bundle:nil];
            activeSubController = (TabBase *)subDesignationController;
            break;
        case kSubEnvironmental:
            if(subEnvironmentalController==nil)
                subEnvironmentalController = [[TabLandEnvironment alloc] initWithNibName:@"TabLandEnvironment" bundle:nil];
            activeSubController = (TabBase *)subEnvironmentalController;
            break;
    }
    ((ScreenController *)activeSubController).propertyController = self.propertyController;
    ((TabSubLand *)activeSubController).tabLandController = self;
    
    [self addChildViewController:activeSubController];
    [subview addSubview:activeSubController.view];
    
    [activeSubController willRotateToInterfaceOrientation:[Helper deviceOrientation] duration:0];
}


    -(void)textFieldDidEndEditing:(UITextField *)aTextField
    {
        
        [super textFieldDidEndEditing:aTextField];
        
        if(aTextField.tag==11)
        {
            [self updateAcres];
        }
        else if(aTextField.tag==7 || aTextField.tag==8)
        {
            NSLog(@"textFieldDidEndEditing");
            // Note that merely leaving this field triggers this method to be called,
            // whether you've changed the data in the field or not.
            
          /* DBaun - This is just left here for historical reference.
            * This turned out to be a bad way to update the tax year and updatedate.
           
            // Update base land value date on the UI
            ComboBoxView *cmbView = (ComboBoxView *)[self.view viewWithTag:9];
            ComboBoxController *cmbController = cmbView.itsController;
            [cmbController setSelectionDate:[Helper localDate]];
            
            // Update Tax Year to RpAssmtYear + 1 on the UI
            NSString *taxYear = [NSString stringWithFormat:@"%d",[RealPropertyApp taxYear]];
            UITextField *taxYearTextField = (UITextField *)[self.view viewWithTag:10];
            taxYearTextField.text = taxYear;
          
            */
        }
    }

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    [segmentedControlLightController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}
-(void)didSwitchToSubController
{
    [super didSwitchToSubController];
    [self rotateSubController:(TabSubLand *)subViewsController];
    [self rotateSubController:(TabSubLand *)subNuisanceController];
    [self rotateSubController:(TabSubLand *)subDesignationController];
    [self rotateSubController:(TabSubLand *)subEnvironmentalController];
    
}
-(void)rotateSubController:(TabSubLand *)controller
{
    if([Helper isDeviceInLandscape])
        [controller willRotateToInterfaceOrientation:UIInterfaceOrientationLandscapeLeft duration:0];
    else
        [controller willRotateToInterfaceOrientation:UIInterfaceOrientationPortrait duration:0];
    
}
#pragma mark - Update
-(BOOL)shouldSwitchView
{
    int res=0;
    if(subViewsController!=nil)
        res += ![subViewsController shouldSwitchView:subViewsController.workingBase];
    if(subNuisanceController!=nil)
        res += ![subNuisanceController shouldSwitchView:subNuisanceController.workingBase ];
    if(subDesignationController!=nil)
        res += ![subDesignationController shouldSwitchView:subDesignationController.workingBase ];
    if(subEnvironmentalController!=nil)
        res += ![subEnvironmentalController shouldSwitchView:subDesignationController.workingBase ];
    
    res += ![super shouldSwitchView:self.workingBase];
    
    if(res==0)
        return YES;
    return NO;
}
-(int)validationError:(int)errorType
{
    int count = 0;
    count += [subViewsController validationError:errorType];
    count += [subNuisanceController validationError:errorType];
    count += [subDesignationController validationError:errorType];
    count += [subEnvironmentalController validationError:errorType];
    
    count += [super validationError:errorType];
    
    return count;
}
-(NSArray *)validationErrorList
{
    NSMutableArray *results = [[NSMutableArray alloc]init];
    
    [results addObjectsFromArray:[subViewsController validationErrorList]];
    [results addObjectsFromArray:[subNuisanceController validationErrorList]];
    [results addObjectsFromArray:[subDesignationController validationErrorList]];
    [results addObjectsFromArray:[subEnvironmentalController validationErrorList]];

    [results addObjectsFromArray:[super validationErrorList]];

    return results;
}

@end
