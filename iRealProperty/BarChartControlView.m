#import "BarChartControlView.h"


@implementation BarChartControlView
@synthesize titleLbl;
@synthesize barChartRenderArray;
#if 0
// number of pixels left over each legend text
#define LegendMargin 4

// number of pixels left between the legend text and the color marker.
#define LegendColorSeparetor 2

// size in pixels of the Legend item line.
#define LegendItemLineSize 18

// height in pixels of the legend size
#define  LegendMarkHeighSize 14

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
#pragma warning -  will need to change
    titleLbl = (UILabel *)[self viewWithTag:10];
    barChartRender = (BarChartView *)[self viewWithTag:11];
}
//
// Draws the bar charts
//
-(void)drawBarCharWithTitle:(NSString *)title andParameters:(NSArray *)parameters tag:(int)tag error:(NSError **)error
{
    if(error!=nil)
        *error = nil;
    
    titleLbl = (UILabel *)[self viewWithTag:tag+1];
    
    
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
            *error = [[NSError alloc] initWithDomain:@"iRealProperty.Chart" code:1 userInfo:errorDetail];
            return;
        }
        else 
        {
            NSError * myErr;
            ChartItemColor pieceColor = [self getChartItemColorFromUIColor:actParam.color error:&myErr];
            [self addBarSectionWithValue:actParam.value andTitle:actParam.legendText andColor:pieceColor];
        }
    }    
}

//
// Add a new value in the piechart and legend.
//
-(void)addBarSectionWithValue: (float)value andTitle: (NSString*) legendTitle andColor: (ChartItemColor) color
{
    [barChartRender addItemValue:value withColor:color];
}

//
// Gets the PieChartItemColor (RGB) from an UIcolor
//
-(ChartItemColor)getChartItemColorFromUIColor:(UIColor *)color error:(NSError **)error
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
// Clear the chart content.
//
-(void)clearView
{
    [barChartRender clearItems];
    [barChartRender setNeedsDisplay];
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
    [barChartRender InvalidatedCache];
}
-(void)setPieChartRender:(id)data
{
    
}
-(id)getPieChartRender
{
    return nil;
}
@end
