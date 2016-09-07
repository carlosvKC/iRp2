#import "DVKeyboard.h"


@interface DVKeyboard ()

@end

@implementation DVKeyboard
@synthesize display;
@synthesize delegate = _delegate;
@synthesize currentTool;
@synthesize direction;
@synthesize crossSelected;
@synthesize optionMetric;
@synthesize optionGridHidden;
@synthesize layerTitle;
@synthesize layerLine;
@synthesize option = _option;
@synthesize showLegend = _showLegend;
@synthesize labelAction;
@synthesize optionGridAlign;

#define BACKGROUND_GRAY @"btnGray.png"
#define BACKGROUND_RED  @"btnRed38.png"
#define BACKGROUND_BLUE @"btnBlue38.png"

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
    [super viewDidLoad];
    optionGridAlign = YES;
    direction = 1;
    [self createButton:10 withTitle:@"0"];
    [self createButton:11 withTitle:@"1"];
    [self createButton:12 withTitle:@"2"];
    [self createButton:13 withTitle:@"3"];
    [self createButton:14 withTitle:@"4"];
    [self createButton:15 withTitle:@"5"];
    [self createButton:16 withTitle:@"6"];
    [self createButton:17 withTitle:@"7"];
    [self createButton:18 withTitle:@"8"];
    [self createButton:19 withTitle:@"9"];
    if(optionMetric)
        [self createButton:20 withTitle:@"."];
    else
        [self createButton:20 withTitle:@"'"];
    [self createButton:21 withTitle:@"C"];
    [self createButton:22 withTitle:@"Enter"];
    [self createButton:23 withImage:[UIImage imageNamed:@"CutWhite.png"]];
    [self createButton:24 withImage:[UIImage imageNamed:@"CopyWhite.png"]];
    [self createButton:40 withImage:[UIImage imageNamed:@"flip.png"]];
    
    [self createButton:25 withImage:[UIImage imageNamed:@"arrowUpWhite.png"]];
    [self createButton:26 withImage:[UIImage imageNamed:@"arrowRightWhite.png"]];
    [self createButton:27 withImage:[UIImage imageNamed:@"arrowDownWhite.png"]];
    [self createButton:28 withImage:[UIImage imageNamed:@"arrowLeftWhite.png"]];
    [self createButton:29 withImage:[UIImage imageNamed:@"KeyboardCross.png"]];
    
    [self createButton:38 withTitle:@"Options"];
    [self createButton:36 withTitle:@"Done" withImage:nil background:BACKGROUND_BLUE];
    [self createButton:37 withTitle:@"Exit" withImage:nil background:BACKGROUND_RED];
    
    // Resize the fonts
    UIButton *btn = (UIButton *)[self.view viewWithTag:38];
    UIFont *font = [UIFont fontWithName:@"Futura-Medium" size:28.0];
    btn.titleLabel.font = font;

    btn = (UIButton *)[self.view viewWithTag:36];
    font = [UIFont fontWithName:@"Futura-Medium" size:20.0];
    btn.titleLabel.font = font;
    
    btn = (UIButton *)[self.view viewWithTag:37];
    font = [UIFont fontWithName:@"Futura-Medium" size:20.0];
    btn.titleLabel.font = font;
    
   for(int i=0;i<6;i++)
    {
        [self updateTool:i selected:NO];
    }
    [self updateTool:kToolGrid selected:YES];
    [self updateTool:kToolAlign selected:YES];
   
    [self clear];

    [self selectArrow:direction selected:YES];
    [self selectTool:kToolLine];   // select line by default
    
    // Add a brush to the background
    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"brushGray.png"]];    
    
    [self setCrossSelected:YES];
}
- (IBAction)changeBacground:(id)sender 
{
    [_delegate dvKeyboardSelectTool:kToolAdjustBackground];
}

-(void)setDelegate:(id<DVKeykoardDelegate>)d
{
    _delegate = d;
    NSArray *layers = [_delegate dvKeyboardGetLayers];
    
    for(DVLayer *layer in layers)
    {
        if(layer.isDefault)
        {
            [self updateLayer:layer];
            break;
        }
    }
}
- (void)viewDidUnload
{
    [self setDisplay:nil];
    [self setLayerTitle:nil];
    [self setLayerLine:nil];
    [self setLabelAction:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}
-(void)createButton:(int)tag withImage:(UIImage *)icon 
{
    [self createButton:tag withTitle:@"" withImage:icon background:BACKGROUND_GRAY];
}
-(void)createButton:(int)tag withTitle:(NSString *)title 
{
    [self createButton:tag withTitle:title withImage:nil background:BACKGROUND_GRAY];
}
-(void)createButton:(int)tag withTitle:(NSString *)title withImage:(UIImage *)icon background:(NSString *)imageName
{
    UIImage *image = [UIImage imageNamed:imageName];
    UIView *view = [self.view viewWithTag:tag];
    if(view==nil)
    {
        NSLog(@"Can't find the view with tag %d", tag);
        return;
    }
    [view removeFromSuperview];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = view.frame; // Use the same area
    UIImage *strechable = [image stretchableImageWithLeftCapWidth:6 topCapHeight:0];
    
    if(icon!=nil)
    {
        CGPoint point;

        UIGraphicsBeginImageContext(view.frame.size);
        [strechable drawInRect:CGRectMake(0, 0, view.frame.size.width, view.frame.size.height)];
        point = CGPointMake((view.frame.size.width - icon.size.width)/2, (view.frame.size.height - icon.size.height)/2);
        [icon drawAtPoint:point];
        strechable = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    [btn setBackgroundImage:strechable forState:UIControlStateNormal];
    UIFont *font = [UIFont fontWithName:@"Futura-Medium" size:30.0];
    
    btn.titleLabel.font = font;
    btn.titleLabel.shadowOffset = CGSizeMake(2.0, 2.0);
    [btn setTitle:title forState:UIControlStateNormal];
    btn.titleLabel.textColor = [UIColor whiteColor];
    
    btn.tag = tag;
	[btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];    
}
#pragma mark - Button action
-(void)btnAction:(id)sender
{
    UIButton *btn = sender;
    switch(btn.tag)
    {
        case 10:
        case 11:
        case 12:
        case 13:
        case 14:
        case 15:
        case 16:
        case 17:
        case 18:
        case 19:
            [self addDigit:btn.tag-10];
            break;
        case 20:
            [self addDot];
            break;
        case 21:
            [self clear];
            break;
        case 22:    // Enter key
        {
            CGFloat value = 0;

            NSArray *array;
            if(self.optionMetric)
                array = [input componentsSeparatedByString:@","]; 
            else
                array = [input componentsSeparatedByString:@"'"];
            if([array count] >=1)
                value = [[array objectAtIndex:0] intValue];
            if([array count]>=2)
            {
                int decimal = [[array objectAtIndex:1] intValue];
                
                if(self.optionMetric)
                {
                    CGFloat max = 10;
                    while(decimal > max)
                    {
                        max *= 10;
                    }
                    value += (decimal/10);
                }
                else
                {
                    value += (1.0/12.0)*decimal;
                }
                
            }
            [_delegate dvKeyboardInput:value direction:direction];
            [self clear];
        }
            break;
        case 23:
            [_delegate dvKeyboardCut];
            break;
        case 24:
            [_delegate dvKeyboardPaste];
            break;
        case 25:
        case 26:
        case 27:
        case 28:
            [self selectArrow:btn.tag-25];
            break;
        case 29:
            [self toggleCross];
            break;
        case 30:
            [self selectTool:kToolLine];
            break;
        case 31:
            [self selectTool:kToolText];
            break;
        case 32:
            [self selectTool:kToolArc];
            break;
        case 33:
            [self selectTool:kToolClose];
            break;
        case 34:
            [self selectTool:kToolAlign];
            break;
        case 35:
            [self selectTool:kToolGrid];
            break;
        case 36:
            [self saveAndExit];
            break;
        case 37:
            [self confirmExit];
            break;
        case 38:
            [self selectOption];
            break;
        case 40:
            [self flip];
            break;
        case 50:
            [_delegate dvKeyboardClose];
            break;
    }
    [self displayLabel];
}
-(void)addDigit:(int)digit
{
    if(!hasDot)
    {
        if(digitsBeforeDot==3)
            return;
        input = [input stringByAppendingFormat:@"%c", '0' + digit];
        digitsBeforeDot++;
    }
    else
    {
        if(digitsAfterDot==2)
            return;
        input = [input stringByAppendingFormat:@"%c", '0' + digit];
        digitsAfterDot++;
    }
}
-(void)addDot
{
    if(!hasDot)
    {
        hasDot = YES;
        digitsAfterDot = 0;
        if(optionMetric)
            input = [input stringByAppendingFormat:@"."];    
        else
            input = [input stringByAppendingFormat:@"'"];        
    }
}
-(void)clear
{
    input = @"";
    hasDot = NO;
    digitsBeforeDot = 0;
    [self displayLabel];
}
-(void)displayLabel
{
    display.text = input;
}
-(void)selectArrow:(int)arrow
{
    // Change the directioon
    if(direction!=arrow)
    {
        [self selectArrow:direction selected:NO];
        direction = arrow;
        [self selectArrow:direction selected:YES];
        return;
    }
    [_delegate dvKeyboardArrow:arrow];
}
-(void)selectArrow:(int)dir selected:(BOOL)selected
{

    NSString *background;
    if(selected)
        background = BACKGROUND_BLUE;
    else
        background = BACKGROUND_GRAY;
    UIImage *image;
    
    switch(dir)
    {
        case 0: image = [UIImage imageNamed:@"arrowUpWhite.png"]; break;
        case 1: image = [UIImage imageNamed:@"arrowRightWhite.png"]; break;
        case 2: image = [UIImage imageNamed:@"arrowDownWhite.png"]; break;
        case 3: image = [UIImage imageNamed:@"arrowLeftWhite.png"]; break;     
    }
    
    [self createButton:dir+25 withTitle:@"" withImage:image background:background];
}
-(void)toggleCross
{
    crossSelected = !crossSelected;
    [self updateCross];
    [_delegate dvKeyboardCross:crossSelected];
}
-(void)updateCross
{
    if(crossSelected)
    {
        // When selected, only the arrow get activated
        [self createButton:29 withTitle:@"" withImage:[UIImage imageNamed:@"KeyboardCross.png"] background:BACKGROUND_RED];
        //[self selectArrow:direction selected:NO];
    }
    else
    {
        // change direction only
        [self createButton:29 withTitle:@"" withImage:[UIImage imageNamed:@"KeyboardCross.png"] background:BACKGROUND_GRAY];
        //[self selectArrow:direction selected:YES];
    }
}
-(void)setCrossSelected:(BOOL)selected
{
    crossSelected = selected;
    [self updateCross];
}
-(void)selectTool:(int)tool
{
    switch(tool)
    {
        case kToolLine:
        case kToolText:
        case kToolArc:
            [self updateTool:currentTool selected:NO];
            currentTool = tool;
            [self updateTool:tool selected:YES];
            [_delegate dvKeyboardSelectTool:currentTool];
            break;
        case kToolClose:
            [_delegate dvKeyboardClose];
            break;
        case kToolAlign:
            optionGridAlign = !optionGridAlign;
            [self updateTool:kToolAlign selected:optionGridAlign];
            [_delegate dvKeyboardAlign:optionGridAlign];
            break;
        case kToolGrid:
            optionGridHidden = !optionGridHidden;
            [self updateTool:kToolGrid selected:!optionGridHidden];
            [_delegate dvKeyboardShowGrid:!optionGridHidden];
            break;
    }
}
-(void)setCurrentTool:(int)tool
{
    [self updateTool:currentTool selected:NO];
    currentTool = tool;
    [self updateTool:tool selected:YES];
}
-(void)updateTool:(int)tool selected:(BOOL)selected
{
    UIImage *image;
    NSString *background;
    if(selected)
        background = BACKGROUND_BLUE;
    else
        background = BACKGROUND_GRAY;
    switch (tool)
    {
        case 0:
            image = [UIImage imageNamed:@"KeyboardLine.png"];
            labelAction.text = @"Line Length";
            break;
        case 1:
            image = [UIImage imageNamed:@"KeyboardLetter.png"];
            labelAction.text = @"";
            break;
        case 2:
            image = [UIImage imageNamed:@"KeyboardHalfCircle.png"];
            labelAction.text = @"Diameter";
            break;
        case 3:
            image = [UIImage imageNamed:@"KeyboardClose.png"];
            labelAction.text = @"";
            break;
        case 4:
            image =[UIImage imageNamed:@"KeyboardFixGrid.png"];
            labelAction.text = @"";
            break;
        case 5:
            image = [UIImage imageNamed:@"KeyboardGrid.png"];
            labelAction.text = @"";
            break;
    }
    [self createButton:30+tool withTitle:@"" withImage:image background:background];
}
//
// Display the option
-(void)selectOption
{
    // Load the keyboard option
    _option = [[DVKeyboardOption alloc]initWithNibName:@"DVKeyboardOption" bundle:nil];
    _option.delegate = self;

    _option.showBackground = _showBackground ;
    _option.showLegend = _showLegend;
    _option.contentSizeForViewInPopover = _option.view.frame.size;
    popover = [[UIPopoverController alloc]initWithContentViewController:_option];
    popover.delegate = self;
    [popover presentPopoverFromRect:[self.view viewWithTag:38].frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
}
#pragma mark - Flip horizontally or vertically a shape
-(void)flip
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Flip" message:@"Select which direction to flip" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Vertical", @"Horizontal", nil];
    [alert show];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex)
    {
        case 0:
            break;
        case 1: // vertical
            [_delegate dvFlipVertical:YES];
            break;
        case 2: // Horizontal
            [_delegate dvFlipVertical:NO];
            break;
        default:
            break;
    }
}
#pragma mark - Handle the layers
- (IBAction)btnSelectLayers:(id)sender 
{
    _layerList = [[DVLayerList alloc]init];
    _layerList.layerList = [_delegate dvKeyboardGetLayers];
    _layerList.contentSizeForViewInPopover = CGSizeMake(394,44*(_layerList.layerList.count-1));
    _layerList.delegate = self;
    
    popover = [[UIPopoverController alloc]initWithContentViewController:_layerList];
    popover.delegate = self;
    
    [popover presentPopoverFromRect:layerLine.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}
-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    // [popoverController dismissPopoverAnimated:NO];
    popover = nil;
    _layerList = nil;
}
-(void)dvLayerListDefault:(DVLayer *)layer
{
    // New layer
    [popover dismissPopoverAnimated:YES];
    [_delegate dvKeyboardSelectLayer:layer];
    // Update the title
    [self updateLayer:layer];
    
    popover = nil;
}
-(void)updateLayer:(DVLayer *)layer
{
    layerTitle.text = layer.name;
    layerLine.dvLayer = layer;
    [layerLine setNeedsDisplay];
}
-(void)dvLayerListRefresh
{
    [_delegate dvKeyboardRefreshAll];
}

-(void)saveAndExit
{
    [_delegate dvKeyboardAction:kOptionSave];
}
-(void)confirmExit
{
    [_delegate dvKeyboardAction:kOptionCancel];
}

#pragma mark - DVKeyboard Option
-(void)dvKeyboardOptionAdjustBackground:(BOOL)on
{
    _adjustBackground = on;
    [_delegate dvKeyboardAdjustBackground:on];
}
-(void)dvKeyboardOptionBackground:(MediaBldg *)image
{
    _showBackground = YES;
    [_delegate dvKeyboardBackground:image];
}
-(void)dvKeyboardOptionAdjustLegend:(BOOL)on
{
    _adjustLegend = on;
    [_delegate dvKeyboardAdjustLegend:on];
}

-(void)dvKeyboardOptionClose
{
    [popover dismissPopoverAnimated:YES];
    popover = nil;    
}
-(void)dvKeyboardOptionShowBackground:(BOOL)on
{
    _showBackground = on;
    [_delegate dvKeyboardShowBackground:on];
}
-(void)dvKeyboardOptionShowLegend:(BOOL)on
{
    _showLegend = on;
    [_delegate dvKeyboardShowLegend:on];
}
- (IBAction)backgroundTouched:(id)sender 
{
    
}
-(void)dvKeyboardOptionsCopyLayer
{
    [_delegate dvKeyboardCopyLayer];
}
-(void)dvKeyboardOptionsPasteLayer
{
    [_delegate dvKeyboardPasteLayer];
}
-(void)pasteLayerButtonActive:(BOOL)active
{
    _option.btnPasteLayer.enabled = active;
}
-(void)dvKeyboardOptionsCopyDrawing
{
    [_delegate dvKeyboardCopyDrawing];
}
-(void)dvKeyboardOptionsPasteDrawing;
{
    [_delegate dvKeyboardPasteDrawing];
}
-(void)dealloc
{
    input = nil;
    _layerList = nil;
    popover = nil;
    _option = nil;
    self.layerTitle = nil;
    self.layerLine = nil;
    self.display = nil;
    self.delegate = nil;
    self.option = nil;
    self.labelAction = nil;
}
@end
