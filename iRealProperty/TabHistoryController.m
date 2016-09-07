#import "TabHistoryController.h"
#import "Helper.h"


@implementation TabHistoryController

    @synthesize segmentedCtrl;

    static int tabSelectedIndex = kHistValHist;

#pragma mark - Init
    - (id)initWithNibName:(NSString *)nibNameOrNil
                   bundle:(NSBundle *)nibBundleOrNil
        {
            self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
            if (self)
                {
                    activeSubController = nil;
                }
            return self;
        }
#pragma mark - Switch between the different views
    - (void)switchSegment:(id)sender
        {
            // Switch to a new segment
            UISegmentedControl *control = sender;
            NSInteger index = [control selectedSegmentIndex];
            [self switchView:index];
        }



// Switch the current view to a new view
    - (void)switchView:(int)index
        {
            UIView *subview  = [self.view viewWithTag:1039];

            if (subview == nil)
                @throw [NSException exceptionWithName:@"TabHistoryController:switchView" reason:[NSString stringWithFormat:@"Can't find the view with tag=%d", 1039] userInfo:nil];

            // Remove the existing view and the existing controller
            [activeSubController.view removeFromSuperview];
            [activeSubController removeFromParentViewController];

            // Insert the new controller
            switch (index)
                {
                    case kHistPermit:
                        if (tabPermitsController == nil)
                            tabPermitsController = [[TabPermits alloc] initWithNibName:@"TabPermits" portraitId:500 landscape:@"TabPermitsLandscape" landscapeId:500];
                        activeSubController = tabPermitsController;
                        break;
                    case kHistSales:
                        if (tabSalesController == nil)
                            tabSalesController = [[TabSale alloc] initWithNibName:@"TabSale" portraitId:500 landscape:@"TabSaleLandscape" landscapeId:500];
                        activeSubController = tabSalesController;
                        break;
                    case kHistReviews:
                        if (tabReviewsController == nil)
                            tabReviewsController = [[TabReviews alloc] initWithNibName:@"TabReviews" portraitId:500 landscape:@"TabReviewsLandscape" landscapeId:500];
                        activeSubController = tabReviewsController;
                        break;
                    case kHistChanges:
                        if (tabChangesController == nil)
                            tabChangesController = [[TabChanges alloc] initWithNibName:@"TabChanges" portraitId:500 landscape:@"TabChangesLandscape" landscapeId:500];
                        activeSubController = tabChangesController;
                        break;
                    case kHistValHist:
                        if (tabValHistController == nil)
                            tabValHistController = [[TabValHist alloc] initWithNibName:@"TabValHist" bundle:nil];
                        activeSubController = tabValHistController;
                        break;
                }
            tabSelectedIndex = index;
            activeSubController.propertyController = self.propertyController;
            activeSubController.itsController      = self;
            [self addChildViewController:activeSubController];
            [subview addSubview:activeSubController.view];

            [activeSubController willRotateToInterfaceOrientation:[Helper deviceOrientation] duration:0];
        }
#pragma mark - Manage the tab lights

    - (void)entityContentHasChanged:(ItemDefinition *)entity
        {
            // If any content has changed, change indicate status
            [self.propertyController segmentUsed:kTabHistory];
            self.isDirty = YES;
        }



    - (void)segmentOn:(int)segment
        {
            [segmentedControlLightController changeLightStateOfSegment:segment color:kSegLightGreen];
            [self.propertyController segmentOn:kTabHistory];
        }



    - (void)segmentUsed:(int)segment
        {
            [segmentedControlLightController changeLightStateOfSegment:segment color:kSegLightRed];
            [self.propertyController segmentUsed:kTabHistory];
        }



    - (void)checkResourceForValue:(NSString *)resource
                          segment:(int)segment
                             base:(id)base
        {
            if (![base isKindOfClass:[NSSet class]])
                {
                    NSLog(@"checkResourceForValue expects a set");
                    return;
                }
            NSSet *set = base;

            if ([set count] > 0)
                [self segmentOn:segment];
        }



    - (void)updateAllIndicators
        {
            [segmentedControlLightController resetAll];
            [self checkResourceForValue:@"TabPermitsDetail" segment:kHistPermit base:[RealProperty realPropInfo].permit];
            [self checkResourceForValue:@"TabSaleDetail" segment:kHistSales base:[RealProperty realPropInfo].saleParcel];
            [self checkResourceForValue:@"TabReviewsDetail" segment:kHistReviews base:[RealProperty realPropInfo].review];
            [self checkResourceForValue:@"TabChangesDetail" segment:kHistChanges base:[RealProperty realPropInfo].chngHist];
            [self checkResourceForValue:@"TabValHistDetail" segment:kHistValHist base:[RealProperty realPropInfo].valHist];
        }
#pragma mark - View lifecycle
    - (void)didReceiveMemoryWarning
        {
            [super didReceiveMemoryWarning];
        }



    - (void)viewDidLoad
        {
            dontUseDetailController = YES;
            [super viewDidLoad];

            UISegmentedControl *control = (UISegmentedControl *) [self.view viewWithTag:1038];

            UIImage *selectedSegment = [[UIImage imageNamed:@"SegmentedControlNormal"] stretchableImageWithLeftCapWidth:6 topCapHeight:0];
            [control setBackgroundImage:selectedSegment forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];

            selectedSegment = [[UIImage imageNamed:@"SegmentedControlSelected"] stretchableImageWithLeftCapWidth:6 topCapHeight:0];
            [control setBackgroundImage:selectedSegment forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];


            // Create the segment light
            segmentedControlLightController = [[SegmentedControlLightController alloc] initWithSegmentedControl:segmentedCtrl destView:self.view];
            [self addChildViewController:segmentedControlLightController];

            [self updateAllIndicators];
            // first default view
            [self switchView:tabSelectedIndex];
            segmentedCtrl.selectedSegmentIndex = tabSelectedIndex;

            [self didSwitchToSubController];
        }

    - (void)viewDidUnload
        {
            [super viewDidUnload];
            // Release any retained subviews of the main view.
            // e.g. self.myOutlet = nil;
        }



    - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
        {
            return YES;
        }
#pragma mark - Handle rotation
    - (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                    duration:(NSTimeInterval)duration
        {
            [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
            int width = 0;
            if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
                width = 1024;
            else
                width = 768;

            UIView *view = [self.view viewWithTag:1];
            view.frame = CGRectMake(0, 0, width, 1024);
            view = [self.view viewWithTag:1038];
            view.frame = CGRectMake(0, 0, width, 30);
            view = [self.view viewWithTag:1039];
            view.frame = CGRectMake(0, 30, width, 1024);

            [segmentedControlLightController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
        }



    - (void)didSwitchToSubController
        {
            [super didSwitchToSubController];

            [self rotateSubController:tabPermitsController];
            [self rotateSubController:tabSalesController];
            [self rotateSubController:tabReviewsController];
            [self rotateSubController:tabChangesController];
            [self rotateSubController:tabValHistController];

        }



    - (void)rotateSubController:(TabBase *)controller
        {
            if ([Helper isDeviceInLandscape])
                [controller willRotateToInterfaceOrientation:UIInterfaceOrientationLandscapeLeft duration:0];
            else
                [controller willRotateToInterfaceOrientation:UIInterfaceOrientationPortrait duration:0];

        }
#pragma mark - Update
    - (BOOL)shouldSwitchView
        {
            int res = 0;
            if (tabPermitsController.detailController)
                res += ![tabPermitsController.detailController shouldSwitchView:tabPermitsController.detailController.workingBase];
            if (tabSalesController.detailController)
                res += ![tabSalesController.detailController shouldSwitchView:tabSalesController.detailController.workingBase];
            if (tabReviewsController.detailController)
                res += ![tabReviewsController.detailController shouldSwitchView:tabReviewsController.detailController.workingBase];
            if (tabChangesController.detailController)
                res += ![tabChangesController.detailController shouldSwitchView:tabChangesController.detailController.workingBase];
            if (tabValHistController.detailController)
                res += ![tabValHistController.detailController shouldSwitchView:tabValHistController.detailController.workingBase];

            if (res != 0)
                return NO;
            return YES;
        }



    - (int)validationError:(int)errorType
        {
            int count = 0;
            count += [tabPermitsController.detailController validationError:errorType];
            count += [tabSalesController.detailController validationError:errorType];
            count += [tabReviewsController.detailController validationError:errorType];
            count += [tabChangesController.detailController validationError:errorType];
            count += [tabValHistController.detailController validationError:errorType];

            return count;
        }



    - (NSArray *)validationErrorList
        {
            NSMutableArray *results = [[NSMutableArray alloc] init];

            [results addObjectsFromArray:[tabPermitsController.detailController validationErrorList]];
            [results addObjectsFromArray:[tabSalesController.detailController validationErrorList]];
            [results addObjectsFromArray:[tabReviewsController.detailController validationErrorList]];
            [results addObjectsFromArray:[tabChangesController.detailController validationErrorList]];
            [results addObjectsFromArray:[tabValHistController.detailController validationErrorList]];

            return results;
        }

@end
