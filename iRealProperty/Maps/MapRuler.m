
#import "MapRuler.h"

@implementation MapRuler

@synthesize toolBar;
@synthesize delegate = _delegate;
@synthesize rulerTitle;
@synthesize lenghtLabel;
@synthesize areaLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
    self.toolBar.dragableDelegate = self;
}

- (void)viewDidUnload
{
    [self setLenghtLabel:nil];
    [self setAreaLabel:nil];
    [self setToolBar:nil];
    [self setRulerTitle:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (IBAction)onDone:(id)sender {
    [_delegate mapRulerDoneButtonClick];
}

#pragma mark - UIDraggeableToolbar
-(void)draggedBy:(CGPoint)delta
{
    [self.view setCenter:CGPointMake(self.view.center.x + delta.x, self.view.center.y + delta.y)];
}
@end
