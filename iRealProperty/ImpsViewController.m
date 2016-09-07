#import "ImpsViewController.h"
#import "InspectionManager.h"


@implementation ImpsViewController

@synthesize itsController;

- (id)initWihRealPropInfo:(RealPropInfo *)propInfo nibName:(NSString *)nibNameOrNil 
{
    self = [super initWithNibName:nibNameOrNil bundle:nil];
    if (self) 
    {
        realPropInfo = propInfo;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    chkLand = (CheckBoxView *)[self.view viewWithTag:24];
    chkLand.delegate = self;
    chkImps = (CheckBoxView *)[self.view viewWithTag:25];
    chkImps.delegate = self;
    chkBoth = (CheckBoxView *)[self.view viewWithTag:26];
    chkBoth.delegate = self;
    
    chkLand.enabled = YES;
    chkImps.enabled = YES;
    chkBoth.enabled = YES;
    
    inspection = [[InspectionManager alloc]initWithPropId:realPropInfo.realPropId realPropInfo:realPropInfo];
    
    int value = [inspection getCurrentState];
    switch(value)
    {
        case 1:
            chkLand.checked = YES;
            break;
        case 2:
            chkImps.checked = YES;
            break;
        case 3:
            chkBoth.checked = YES;
            chkImps.checked = YES;
            chkLand.checked = YES;
            break;
    }

}
#pragma mark - Handle the checkboxes
-(void)checkBoxClicked:(id)checkBox isChecked:(BOOL)checked
{
    [checkBox setChecked:checked];
    
    if(checkBox==chkBoth)
    {
        [chkImps setChecked:checked];
        [chkLand setChecked:checked];
    }
    
    if(chkImps.checked != chkLand.checked)
        chkBoth.checked = NO;
    if(chkImps.checked==YES && chkLand.checked==YES)
        chkBoth.checked = YES;
    
    int value = 0;
    if(chkBoth.checked)
        value = 3;
    else if(chkLand.checked)
        value = 1;
    else if(chkImps.checked)
        value = 2;

    // User's selection is saved to database here
    [inspection setCurrentState:value commit:YES];
    [itsController setCurrentImps:value];
    [itsController runDashboardQueries];
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

@end
