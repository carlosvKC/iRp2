
#import "DVKeyboardOption.h"
#import "Helper.h"
#import "DVImagePicker.h"
#import "RealProperty.h"
#import "AxDataManager.h"


@implementation DVKeyboardOption
@synthesize delegate;
@synthesize realPropInfo;
@synthesize showBackground;
@synthesize showLegend;
@synthesize btnAdjustBackground;
@synthesize btnAdjustLegend;
@synthesize btnCopyLayer;
@synthesize btnPasteLayer;
@synthesize btnCopyDrawing;
@synthesize btnPasteDrawing;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {

    }
    return self;
}

- (void)viewDidLoad
{
    
    realPropInfo = [RealProperty realPropInfo];
    
    [super viewDidLoad];
    // Create the background list of pictures
    UIView *view = [self.view viewWithTag:50];
    
    [self addImagePicker:view];
            
    UISwitch *sw = (UISwitch *)[self.view viewWithTag:51];
    [sw addTarget:self action:@selector(switchShowBackground:) forControlEvents:UIControlEventValueChanged];
    [sw setOn:showBackground animated:NO];
    
    // By default adjust background is reset to off
    sw = (UISwitch *)[self.view viewWithTag:52];
	
    // DBaun 2014-08-04: Commenting out next line because the selector exists NOWHERE in code that I can find.
    //[sw addTarget:self action:@selector(switchAdjustBackground:) forControlEvents:UIControlEventValueChanged];
	
    [sw setOn:NO animated:NO];


    // By default adjust background is reset to off
    sw = (UISwitch *)[self.view viewWithTag:62];
    
    // DBaun 2014-08-04: Commenting out next line because the selector exists NOWHERE in code that I can find.
    // [sw addTarget:self action:@selector(switchAdjustLegend:) forControlEvents:UIControlEventValueChanged];
	
    [sw setOn:NO animated:NO];

    sw = (UISwitch *)[self.view viewWithTag:61];
    [sw addTarget:self action:@selector(switchShowLegend:) forControlEvents:UIControlEventValueChanged];
    [sw setOn:showLegend animated:NO];
    
    /*
    btnAdjustLegend.enabled = NO;
    btnAdjustBackground.enabled = NO;
    
    btnPasteDrawing.enabled = NO;
    btnPasteLayer.enabled = NO;
     */
}
- (void)viewDidUnload
{
    [self setBtnAdjustBackground:nil];
    [self setBtnAdjustLegend:nil];
    [self setBtnCopyLayer:nil];
    [self setBtnPasteLayer:nil];
    [self setBtnCopyDrawing:nil];
    [self setBtnPasteDrawing:nil];

    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
#pragma - Event handling
-(void)setShowLegend:(BOOL)value
{
    UISwitch *sw = (UISwitch *)[self.view viewWithTag:61];
    [sw setOn:value];
}
-(void)switchShowLegend:(UISwitch *)sender
{
    [delegate dvKeyboardOptionShowLegend:sender.on];
    [delegate dvKeyboardOptionClose];
    btnAdjustLegend.enabled = sender.on;
}
-(void)switchShowBackground:(UISwitch *)sender
{
    [delegate dvKeyboardOptionShowBackground:sender.on];
    [delegate dvKeyboardOptionClose];
    btnAdjustBackground.enabled = sender.on;
}
-(void)addImagePicker:(UIView *)view
{
    picker = [[DVImagePicker alloc]initWithNibName:@"DVImagePicker" bundle:nil];
    picker.pickerDelegate = self;
    
    picker.pictList = [RealProperty getAllBuildingPictures:realPropInfo];
    int height = (picker.pictList.count > 4)?4*160:picker.pictList.count*160;
    picker.contentSizeForViewInPopover = CGSizeMake(210, height);
    
    picker.tableView.frame = CGRectMake(0,0,view.frame.size.width, view.frame.size.height);
    [view addSubview:picker.tableView];
    [view bringSubviewToFront:view];
    
    [self addChildViewController:picker];
}
-(void)dvImagePickerSelected:(id)image
{
    [delegate dvKeyboardOptionBackground:image];
    [delegate dvKeyboardOptionClose];
}

- (IBAction)actionAdjustBackground:(UIButton *)sender 
{
    [delegate dvKeyboardOptionAdjustBackground:YES];
    [delegate dvKeyboardOptionClose];
}

- (IBAction)actionAdjustLegend:(id)sender 
{
    [delegate dvKeyboardOptionClose];
    [delegate dvKeyboardOptionAdjustLegend:YES];
}

- (IBAction)actionCopyLayer:(id)sender 
{
    [delegate dvKeyboardOptionClose];
    [delegate dvKeyboardOptionsCopyLayer];
}

- (IBAction)actionPasteLayer:(id)sender 
{
    [delegate dvKeyboardOptionClose];
    [delegate dvKeyboardOptionsPasteLayer];
}

- (IBAction)actionCopyDrawing:(id)sender 
{
    [delegate dvKeyboardOptionClose];
    [delegate dvKeyboardOptionsCopyDrawing];
}

- (IBAction)actionPasteDrawing:(id)sender {
    [delegate dvKeyboardOptionClose];
    [delegate dvKeyboardOptionsPasteDrawing];
}
@end
