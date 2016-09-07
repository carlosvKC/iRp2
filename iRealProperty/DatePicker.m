#import "DatePicker.h"


@implementation DatePicker

@synthesize delegate;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
    }
    return self;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
//
// Init View and Rect
//
- (id)initWithParams:(UIView *)cmbView destRect:(CGRect)rect date:(NSDate *)date
{
    self = [super init];

    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:self];

    UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithTitle:@"Select Date" style:UIBarButtonItemStylePlain target:self action:@selector(doneSelection:)];
    anotherButton.tintColor = [UIColor blueColor];
    
    self.navigationItem.rightBarButtonItem = anotherButton;
    self.contentSizeForViewInPopover = CGSizeMake(300,216);

    // Get the current date
    UIDatePicker *datePicker = (UIDatePicker *)[self.view viewWithTag:10];

    datePicker.date = date; // dt;
    popoverController = [[UIPopoverController alloc]initWithContentViewController:nav];
    [popoverController presentPopoverFromRect:rect inView:cmbView permittedArrowDirections:UIPopoverArrowDirectionUp animated:TRUE];
    
    return self;
}
-(void)doneSelection:(id)sender
{
    // Get the date, etc.
    [popoverController dismissPopoverAnimated:YES];
    
    // Get the current date
    UIDatePicker *datePicker = (UIDatePicker *)[self.view viewWithTag:10];
    
    NSDate *date = [datePicker date];
    if([delegate respondsToSelector:@selector(popoverItemSelected:)])
        [delegate popoverItemSelected:date];
}
#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;

}

@end
