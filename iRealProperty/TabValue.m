#import "TabValue.h"
#import "Helper.h"
#import "Configuration.h"
#import "RealProperty.h"
#import "RealPropertyApp.h"


@implementation TabValue

    @synthesize alert;



    - (id)initWithNibName:(NSString *)nibNameOrNil
                   bundle:(NSBundle *)nibBundleOrNil
        {
            self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
            if (self)
                {
                    // Custom initialization
                }
            return self;
        }



    - (void)didReceiveMemoryWarning
        {
            // Releases the view if it doesn't have a superview.
            [super didReceiveMemoryWarning];


        }
#pragma mark - View lifecycle

    - (void)viewDidLoad
        {
            dontUseDetailController = YES;

            [super viewDidLoad];

            [self setScreenEntities];

            // set up the different values
            cbTaxRoll   = (CheckBoxView *) [self.view viewWithTag:60];
            cbAppraisal = (CheckBoxView *) [self.view viewWithTag:61];
            cbEstimate  = (CheckBoxView *) [self.view viewWithTag:62];

            cbTaxRoll.enabled   = YES;
            cbAppraisal.enabled = YES;
            cbEstimate.enabled  = YES;

            [cbTaxRoll setOn:YES animated:NO];
            [cbAppraisal setOn:YES animated:NO];
            [cbEstimate setOn:YES animated:NO];

            cbTaxRoll.delegate   = self;
            cbAppraisal.delegate = self;
            cbEstimate.delegate  = self;

            valueTaxRoll   = (ValueTaxRoll *) [self.controllerList valueForKey:@"ValueTaxRoll"];
            valueAppraisal = (ValueAppraisal *) [self.controllerList valueForKey:@"ValueAppraisal"];
            valueEstimate  = (ValueEstimate *) [self.controllerList valueForKey:@"ValueEstimate"];

            [self willRotateToInterfaceOrientation:[Helper deviceOrientation] duration:0];

            // Add the calculate button
            UIView   *view = [self.view viewWithTag:245];
            UIButton *btn  = [Helper createBlueButton:view.frame withTitle:@"Calculate"];
            [view removeFromSuperview];
            [self.view addSubview:btn];
            [btn addTarget:self action:@selector(calculate:) forControlEvents:UIControlEventTouchUpInside];
        }



    - (void)checkBoxClicked:(id)checkBox
                  isChecked:(BOOL)checked
        {
            // Update the views
            [self willRotateToInterfaceOrientation:[Helper deviceOrientation] duration:0];
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



    - (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                    duration:(NSTimeInterval)duration
        {
            UIView *backgroundView = [self.view viewWithTag:1];

            if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation))
                backgroundView.frame = CGRectMake(0, 0, 768, 1024);
            else
                backgroundView.frame = CGRectMake(0, 0, 1024, 768);

            int count = 0;

            // Hide all the views that are not visible
            if (cbTaxRoll.on)
                count++;
            [self hideOrShowView:11 tag:100 hidden:!cbTaxRoll.on];

            if (cbAppraisal.on)
                count++;
            [self hideOrShowView:21 tag:200 hidden:!cbAppraisal.on];

            if (cbEstimate.on)
                count++;
            [self hideOrShowView:31 tag:300 hidden:!cbEstimate.on];

            if (count == 0)
                return; // No need to try to find a right size

            CGFloat height, width;
            if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation))
                {
                    height = 830;
                    width  = 768;
                }
            else
                {
                    height = 572;
                    width  = 1024;
                }
            const int titleHeight = 28;

            CGFloat tableHeight = (height / count) - titleHeight;

            CGFloat y = 37;

            if (cbTaxRoll.on)
                {
                    [self changeViewSize:11 x:0 y:y width:width height:titleHeight];
                    [self changeViewSize:100 x:0 y:y + titleHeight width:width height:tableHeight];
                    y += (titleHeight + tableHeight);
                    [valueTaxRoll.grid resizeToView:[self.view viewWithTag:100] headerHeight:30.0];
                    [valueTaxRoll.grid autoFitToView:width];
                }
            if (cbAppraisal.on)
                {
                    [self changeViewSize:21 x:0 y:y width:width height:titleHeight];
                    [self changeViewSize:200 x:0 y:y + titleHeight width:width height:tableHeight];
                    y += (titleHeight + tableHeight);
                    [valueAppraisal.grid refreshAllContent];
                    [valueAppraisal.grid resizeToView:[self.view viewWithTag:200] headerHeight:30.0];
                    [valueAppraisal.grid autoFitToView:width];
                }
            if (cbEstimate.on)
                {
                    [self changeViewSize:31 x:0 y:y width:width height:titleHeight];
                    [self changeViewSize:300 x:0 y:y + titleHeight width:width height:tableHeight];
                    y += (titleHeight + tableHeight);
                    [valueEstimate.grid refreshAllContent];
                    [valueEstimate.grid resizeToView:[self.view viewWithTag:300] headerHeight:30.0];
                    [valueEstimate.grid autoFitToView:width];
                }
        }



    - (void)changeViewSize:(int)tag
                         x:(CGFloat)x
                         y:(CGFloat)y
                     width:(CGFloat)width
                    height:(CGFloat)height
        {
            UIView *view;
            view = [self.view viewWithTag:tag];
            view.frame = CGRectMake(x, y, width, height);

        }



    - (void)hideOrShowView:(int)bandTag
                       tag:(int)tag
                    hidden:(BOOL)hidden
        {
            UIView *view;
            view = [self.view viewWithTag:bandTag];
            view.hidden = hidden;
            view = [self.view viewWithTag:tag];
            view.hidden = hidden;


        }
#pragma mark - Calculate method
    - (void)calculate:(id)sender
        {
            [self createGetYearDialog];
            // [self createGetValueDialog];
        }



    - (void)createGetYearDialog
        {
            dialogGetYear = [[DialogBoxGetYear alloc] initWithNibName:@"DialogBoxGetYear" bundle:nil];
            CGSize size = dialogGetYear.view.frame.size;
            dialogGetYear.delegate = self;
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:dialogGetYear];
            navController.modalPresentationStyle = UIModalPresentationFormSheet;
            [self presentViewController:navController animated:YES completion:^(void)
                {
                }];

            navController.view.superview.frame  = CGRectMake(0, 0, size.width, size.height);
            navController.view.superview.center = self.view.superview.superview.center;
        }



    - (void)createGetValueDialog:(NSString *)applGroup
                         andArea:(NSString *)area
                      andSubArea:(NSString *)subArea
        {
            dialogGetValue = [[DialogBoxGetValue alloc] initWithNibName:@"DialogBoxGetValue" bundle:nil];
            CGSize size = dialogGetValue.view.frame.size;
            dialogGetValue.delegate           = self;
            dialogGetValue.textApplGroup.text = applGroup;
            dialogGetValue.textArea.text      = area;
            dialogGetValue.textSubArea.text   = subArea;

            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:dialogGetValue];
            navController.modalPresentationStyle = UIModalPresentationFormSheet;
            [self presentViewController:navController animated:YES  completion:^(void)
                {
                }];
            navController.view.superview.frame  = CGRectMake(0, 0, size.width, size.height);
            navController.view.superview.center = self.view.superview.superview.center;
        }



    - (void)didDismissModalView:(id)dialog
                    saveContent:(BOOL)saveContent
        {
            RealPropInfo *realPropInf = [RealProperty realPropInfo];
            if (dialog == dialogGetYear)
                {
                    if (saveContent)
                        {
                            req = [[Requester alloc] init:[RealPropertyApp getDataUrl]];
                            req.delegate   = self;
                            // selected the dialog get year
                            NSString *year = ((DialogBoxGetYear *) dialog).dataField.text;
                            // Years has been selected
                            // RealPropInfo *real = [RealProperty realPropInfo];

                            activity = [ATActivityIndicator currentIndicator];
                            [activity displayActivity:@"Saving"];

                            Configuration *configuration = [RealPropertyApp getConfiguration];
                            taxYr = [year intValue];
                            [req executeGetEstAreaAsynchronous:realPropInf.realPropId withTaxYr:taxYr usingToken:configuration.simpleToken];
                        }
                    else
                        {
                            [dialogGetYear dismissViewControllerAnimated:YES completion:nil];
                        }
                }
            else if (dialog == dialogGetValue)
                {
                    // get the values
                    // retrieve the data here
                    activity = [ATActivityIndicator currentIndicator];
                    [activity displayActivity:@"Retrieving Info"];

                    NSString *applGroup = ((DialogBoxGetValue *) dialog).textApplGroup.text;
                    NSString *subArea   = ((DialogBoxGetValue *) dialog).textSubArea.text;
                    NSString *area      = ((DialogBoxGetValue *) dialog).textArea.text;

                    sync = [[Synchronizator alloc] init:[RealPropertyApp getDataUrl]];
                    sync.delegate = self;
                    Configuration *configuration = [RealPropertyApp getConfiguration];
                    sync.forceRestart   = NO;
                    sync.securityToken  = configuration.simpleToken;
                    sync.blobServiceURL = [RealPropertyApp getBlobUrl];
                    CalcEstimationParameter *calEstParam = [[CalcEstimationParameter alloc] init];
                    calEstParam.Area       = [area intValue];
                    calEstParam.SubArea    = [subArea intValue];
                    calEstParam.ApplGroup  = applGroup;
                    calEstParam.RealPropId = realPropInf.realPropId;
                    calEstParam.TaxYr      = taxYr;
                    [sync performSelectorInBackground:@selector(executeSyncEntitiesForCalculateEstimates:) withObject:calEstParam];
                }
        }

#pragma mark - Requester delegate

    - (void)requestDidFail:(Requester *)r
                 withError:(NSError *)error
        {
            self.alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [self.alert show];
        }



    - (void)requestGetEstAreaDone:(Requester *)r
                    withApplGroup:(NSString *)applGroup
                          andArea:(int)area
                       andSubArea:(int)subArea
        {
            [activity hide];

            [dialogGetYear dismissViewControllerAnimated:YES completion:^(void)
                {
                    dialogGetYear = nil;
                    NSString *areaStr    = [NSString stringWithFormat:@"%d", area];
                    NSString *subAreaStr = [NSString stringWithFormat:@"%d", subArea];
                    [self createGetValueDialog:applGroup andArea:areaStr andSubArea:subAreaStr];
                }];
        }

#pragma mark - Synchronizator delegate

    - (void)synchronizatorRequestDidFail:(Synchronizator *)s
                               withError:(NSError *)error
        {
            self.alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [self.alert show];
        }



    - (void)synchronizatorRequestDidFailByValidationErrors:(Synchronizator *)s
                                              withSyncGuid:(NSString *)syncGuid
                                                 andErrors:(NSArray *)errors
        {

        }



    - (void)synchronizatorSyncEntitiesForCalculateEstimatesDone:(Synchronizator *)s
        {
            [activity hide];
            [dialogGetValue dismissViewControllerAnimated:YES completion:^(void)
                {
                    dialogGetValue = nil;
                    if (cbTaxRoll.on)
                        [valueTaxRoll.grid refreshAllContent];
                    if (cbAppraisal.on)
                        [valueAppraisal.grid refreshAllContent];
                    if (cbEstimate.on)
                        [valueEstimate.grid refreshAllContent];
                }];
        }



    - (void)synchronizatorRequestDidFailByValidationErrors:(Synchronizator *)s
                                                withErrors:(NSArray *)errors
        {

        }
@end
