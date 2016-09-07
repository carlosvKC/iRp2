#import "AxColorPicker.h"
#import "HRColorUtil.h"
#import "HRColorPickerViewController.h"

@implementation AxColorPicker

@synthesize target = _target;
@synthesize delegate = _delegate;

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
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}
#pragma mark - Delegate from the color
-(void)performSelection:(id)sender
{
    // Got the result here
    [colorController save];
    [self.delegate colorSelected:_resultColor forTarget:self.target];
}
- (void)setSelectedColor:(UIColor*)color
{
    _resultColor = color;
}

#pragma mark - View lifecycle
-(void)viewDidLoad
{
    [super viewDidLoad];
    colorController = [HRColorPickerViewController fullColorPickerViewControllerWithColor:[self.target backgroundColor]];
    colorController.delegate = self;
    UIView *view = [self.view viewWithTag:1];
    [view addSubview:colorController.view];
    [self addChildViewController:colorController];

    self.contentSizeForViewInPopover = view.frame.size;
    
    // Add the done button
    UIImage *blueButtonImage = [UIImage imageNamed:@"btnBlue38.png"];
    view = [self.view viewWithTag:10];
	CGRect rect = view.frame;
    [view removeFromSuperview];
	UIButton *btnDone = [UIButton buttonWithType:UIButtonTypeCustom];
	btnDone.frame = rect;
	UIImage *strechable = [blueButtonImage stretchableImageWithLeftCapWidth:6 topCapHeight:0];
	[btnDone setBackgroundImage:strechable forState:UIControlStateNormal];
	[btnDone setTitle:@"Select" forState:UIControlStateNormal];
	
	btnDone.titleLabel.textColor = [UIColor whiteColor];
	
	[btnDone addTarget:self action:@selector(performSelection:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:btnDone];
    [self.view bringSubviewToFront:btnDone];
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
