#import "MobileCharacteristic.h"
#import "Helper.h"
#import "RealPropertyApp.h"

@implementation MobileCharacteristic

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        nibReader = [[NIBReader alloc]initWithNibName:@"MobileCharacteristic" portraitId:600 landscape:@"MobileCharacteristicLandscape" landscapeId:600];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [Helper findAndResignFirstResponder:self.view];
    BOOL landscapeMode = NO;
    if(UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
        landscapeMode = YES;
    
    // When the controller is a single controller, rotate content
    [nibReader rotateViews:self.view landscapeMode:landscapeMode];
}
-(void)entityContentHasChanged:(ItemDefinition *)entity
{
    [super entityContentHasChanged:entity];
    // If any content has changed, change indicate status
    MHCharacteristic *account = (MHCharacteristic *)self.workingBase;
    [RealPropertyApp updateUserDate:account];
    if(![account.rowStatus isEqualToString:@"I"] && ![account.rowStatus isEqualToString:@"D"])
        account.rowStatus = @"U";

}
@end
