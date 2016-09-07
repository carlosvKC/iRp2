
#import "GridInfoDesign.h"

@implementation GridInfoDesign
@synthesize numCols;
@synthesize colTopBorder;
@synthesize colBottomBorder;
@synthesize colHighlightedTopBorder;
@synthesize colHighlightedBottomBorder;

@synthesize borderColor;
@synthesize borderWidth;

@synthesize headerFontColor;
@synthesize headerFontName;
@synthesize headerFontSize;
@synthesize minimumHeaderFontSize;

@synthesize headerTextPosition;
@synthesize radius;

@synthesize backgroundColor;

@synthesize cellFontSize;
@synthesize cellBackgroundColor;
@synthesize cellFontSelectedColor;
@synthesize cellFontColor;
@synthesize cellSelectedColor;
@synthesize cellFontName;
@synthesize minimumCellFontSize;

@synthesize colCellEditColor;

-(id) init
{
    self = [super init];
    
    if(self)
    {
        colTopBorder = [UIColor grayColor];
        colBottomBorder = [UIColor darkGrayColor];
        
        colHighlightedTopBorder = [UIColor darkGrayColor];
        colHighlightedBottomBorder = [UIColor grayColor];
        
        borderColor = [UIColor blackColor];
        borderWidth = 1.0;
        radius = 10.0;
        
        headerFontColor = [UIColor whiteColor];
        headerFontName = @"Helvetica";
        headerFontSize = 17.0;
        minimumHeaderFontSize = 14.0;
        
        cellFontColor = [UIColor blackColor];
        cellFontName = @"Helvetica";
        cellFontSize = 17.0;
        minimumCellFontSize = 14.0;
        
        cellBackgroundColor = [UIColor whiteColor];
            
        backgroundColor = [[UIColor alloc]initWithRed:0.85 green:0.85 blue:0.85 alpha:1.0];
        
        colCellEditColor = [[UIColor alloc]initWithRed:0.8 green:0.8 blue:0.8 alpha:1.0];
    }
    return self;
}


-(void) setHeaderColors: (UIColor *)topColor : (UIColor *)bottomColor : (UIColor *)topHighlitedColor : (UIColor *) bottomHightlitedColor : (UIColor *)borderCol
{
    colTopBorder = topColor;
    colBottomBorder = bottomColor;
    colHighlightedTopBorder = topHighlitedColor;
    colHighlightedTopBorder = bottomHightlitedColor;
    
    borderColor = borderCol;
    
}
-(void) setHeaderFontInfo: (NSString *)nameOfFont :  (CGFloat) textSize : (CGFloat) minTextSize : (UIColor *)fontCol
{
    self.headerFontName = nameOfFont;
    self.headerFontSize = textSize;
    self.minimumHeaderFontSize = minTextSize;
    self.headerFontColor = fontCol;
    
}

@end
