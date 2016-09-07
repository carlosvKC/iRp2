
#import <QuartzCore/QuartzCore.h>
#import "PieChartControlView.h"
#import "ChartParameter.h"

@implementation PieChartControlView
@synthesize titleLbl;
@synthesize pieChartRender;
@synthesize legentArea;

// number of pixels left over each legend text
const int LegendMargin = 4;

// number of pixels left between the legend text and the color marker.
const int LegendColorSeparetor = 2;

// size in pixels of the Legend item line.
const int LegendItemLineSize = 18;

// height in pixels of the legend size
const int LegendMarkHeighSize = 14;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
    {
        _legendLastY = 0;
        [self findViews];
    }
    return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) 
    {
        _legendLastY = 0;
        [self findViews];
    }
    return self;
}
-(void)findViews
{
    titleLbl = (UILabel *)[self viewWithTag:10];
    pieChartRender = (PieChartView *)[self viewWithTag:11];
    legentArea = (UIView *)[self viewWithTag:12];
}

//
// Draws the pie chart.
//
-(void)drawPieCharWithTitle:(NSString *)title andParameters:(NSArray *)parameters error:(NSError **)error
{
    if(*error!=nil)
        *error = nil;
    if (title != nil) 
    {
        titleLbl.text = title;
    }
    else 
    {
        titleLbl.text = @"";
    }
    for (ChartParameter *actParam in parameters) 
    {
        if (![actParam isKindOfClass:[ChartParameter class]])
        {
            NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
            [errorDetail setValue:@"Invalid parameter class type." forKey:NSLocalizedDescriptionKey];
            *error = [[NSError alloc] initWithDomain:@"iRealProperty.PieChart" code:1 userInfo:errorDetail];
            return;
        }
        else 
        {
            NSError * myErr;
            ChartItemColor piePieceColor = [self getPieChartItemColorFromUIColor:actParam.color error:&myErr];
            [self addPieSectionWithValue:actParam.value andTitle:actParam.legendText andColor:piePieceColor];
        }
    }    
}

//
// Add a new value in the piechart and legend.
//
-(void)addPieSectionWithValue: (float)value andTitle: (NSString*) legendTitle andColor: (ChartItemColor) color
{
    [pieChartRender addItemValue:value withColor:color];
    
    // add horizontal legend.
    UILabel* LegendText;
    UILabel* LegendMark;
    
    // Init legend text
    LegendText = [[UILabel alloc] initWithFrame:CGRectMake(LegendMargin + LegendItemLineSize + LegendColorSeparetor, _legendLastY + LegendMargin, 300, LegendItemLineSize)];
    
    // configure legend text.
    LegendText.backgroundColor = [UIColor clearColor];
    LegendText.text =[NSString stringWithFormat:@"%@ (%.0f)", legendTitle, value];
    LegendText.textColor = [UIColor blackColor];
    LegendText.textAlignment = NSTextAlignmentLeft;
    LegendText.font = [UIFont fontWithName:@"Futura-Medium" size:14];
    //[LegendText sizeToFit];
    [legentArea addSubview:LegendText];
    
    // Init legend mark
    LegendMark= [[UILabel alloc] initWithFrame:CGRectMake(LegendMargin, _legendLastY + LegendMargin + LegendColorSeparetor, LegendItemLineSize, LegendMarkHeighSize)];
    LegendMark.layer.cornerRadius = 3.0;
    LegendMark.backgroundColor = [UIColor colorWithRed:color.red green:color.green blue:color.blue alpha:color.alpha];
    [legentArea addSubview:LegendMark];
    
    _legendLastY += LegendItemLineSize;
}

//
// Gets the PieChartItemColor (RGB) from an UIcolor
//
-(ChartItemColor)getPieChartItemColorFromUIColor:(UIColor *)color error:(NSError **)error
{
    *error = nil;
    ChartItemColor resultItemColor;
    
    if ([self canProvideRGBComponents:color]) 
    {
        const CGFloat *c = CGColorGetComponents(color.CGColor);
        resultItemColor.red = c[0];
        resultItemColor.green = c[1];
        resultItemColor.blue = c[2];
        resultItemColor.alpha = c[CGColorGetNumberOfComponents(color.CGColor)-1]; 
    }
    else
    {
        NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
        [errorDetail setValue:@"Invalid UI Color, the color does not support RGB." forKey:NSLocalizedDescriptionKey];
        *error = [[NSError alloc] initWithDomain:@"iRealProperty.PieChart" code:2 userInfo:errorDetail];
    }
    
    return resultItemColor;
}

//
// Validates if the UIColor can return a RGB
//
- (BOOL) canProvideRGBComponents:(UIColor *)color  
{
    return ((CGColorSpaceGetModel(CGColorGetColorSpace(color.CGColor)) == kCGColorSpaceModelRGB) ||   
            (CGColorSpaceGetModel(CGColorGetColorSpace(color.CGColor)) == kCGColorSpaceModelMonochrome));  
}

//
// Clear the pie chart content.
//
-(void)clearView
{
    [pieChartRender clearItems];
    [pieChartRender setNeedsDisplay];
    for (UIView* child in [legentArea subviews]) 
    {
        [child removeFromSuperview];
    }
    _legendLastY = 0;
}

//
// Remove the cache image of the piechart.
//
-(void) releaseCache
{
    [pieChartRender InvalidatedCache];
}

@end
