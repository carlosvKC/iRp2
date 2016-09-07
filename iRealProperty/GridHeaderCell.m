
// Draw only the top border of the cell

#import "GridHeaderCell.h"
#import "GridHeaderController.h"


@implementation GridHeaderCell
@synthesize column;
@synthesize gridHeaderController;

static void ContextLeftRoundedRect(CGContextRef c, CGRect rect, CGFloat radius) 
{
    CGFloat minX = CGRectGetMinX(rect);
    CGFloat maxX = CGRectGetMaxX(rect);
    CGFloat minY = CGRectGetMinY(rect);
    CGFloat maxY = CGRectGetMaxY(rect);
    
 
    CGContextMoveToPoint(c, minX, maxY);
    CGContextAddArcToPoint(c, minX, minY, minX + radius, minY, radius);
    CGContextAddLineToPoint(c, maxX, minY);
    CGContextAddLineToPoint(c, maxX, maxY);
    CGContextAddLineToPoint(c, minX, maxY);
}
static void ContextRightRoundedRect(CGContextRef c, CGRect rect, CGFloat radius) 
{
    CGFloat minX = CGRectGetMinX(rect);
    CGFloat maxX = CGRectGetMaxX(rect);
    CGFloat minY = CGRectGetMinY(rect);
    CGFloat maxY = CGRectGetMaxY(rect);
    
    CGContextMoveToPoint(c, minX, minY);
    CGContextAddArcToPoint(c, maxX, minY, maxX, minY + radius, radius); // right top
    //CGContextAddArcToPoint(c, maxX, maxY, maxX - radius, maxY, radius); // right bottom
    //CGContextAddArcToPoint(c, minX, maxY, minX, maxY - radius, radius); // left bottom
    //CGContextAddArcToPoint(c, minX, minY, minX + radius, minY, radius);
    
    CGContextAddLineToPoint(c, maxX, minY+radius);
    CGContextAddLineToPoint(c, maxX, maxY);
    CGContextAddLineToPoint(c, minX, maxY);
    CGContextClosePath(c);
}
// 
// Draw a path (clipping)
static void PathLeftRoundedRect(CGMutablePathRef p, CGRect rect, CGFloat radius) 
{
    CGFloat minX = CGRectGetMinX(rect);
    CGFloat maxX = CGRectGetMaxX(rect);
    CGFloat minY = CGRectGetMinY(rect);
    CGFloat maxY = CGRectGetMaxY(rect);
    
    CGPathMoveToPoint(p, NULL, minX + radius, minY);
    CGPathMoveToPoint(p, NULL, minX, maxY);
    CGPathAddArcToPoint(p, NULL, minX, minY, minX + radius, minY, radius);
    CGPathAddLineToPoint(p, NULL, maxX, minY);
    CGPathAddLineToPoint(p, NULL, maxX, maxY);
    CGPathAddLineToPoint(p, NULL, minX, maxY);
    CGPathCloseSubpath(p);
}
static void PathRightRoundedRect(CGMutablePathRef p, CGRect rect, CGFloat radius) 
{
    CGFloat minX = CGRectGetMinX(rect);
    CGFloat maxX = CGRectGetMaxX(rect);
    CGFloat minY = CGRectGetMinY(rect);
    CGFloat maxY = CGRectGetMaxY(rect);
    
    CGPathMoveToPoint(p, NULL, minX, minY);
    CGPathAddArcToPoint(p, NULL, maxX, minY, maxX, minY + radius, radius); 
    
    CGPathAddLineToPoint(p, NULL, maxX, minY+radius);
    CGPathAddLineToPoint(p, NULL, maxX, maxY);
    CGPathAddLineToPoint(p, NULL, minX, maxY);
    CGPathCloseSubpath(p);
}
//
// ------------------------------------------------
// Main method to draw the content of the cell
// ------------------------------------------------
-(id) init
{
    self = [super init];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

-(void) drawRect:(CGRect)rect
{
    const CGFloat *topColor, *bottomColor;
    
    GridInfoDesign *headerInfo = gridHeaderController.gridController.gridDesign;
    
    NSArray *entities = gridHeaderController.gridController.gridEntities;
    
    ItemDefinition *entity = [entities objectAtIndex:column];
    
    // there is a bug in the refresh and resizing the columns
    topColor = CGColorGetComponents([headerInfo.colTopBorder CGColor]);
    bottomColor = CGColorGetComponents([headerInfo.colBottomBorder CGColor]);

    CGFloat gradientColor[8];
    for(int i=0;i<4;i++)
    {
        gradientColor[i] = topColor[i];
        gradientColor[i+4] = bottomColor[i];
    }

    CGContextRef c = UIGraphicsGetCurrentContext();
    CGColorSpaceRef spaceRef = CGColorSpaceCreateDeviceRGB();
    
   
    CGGradientRef gradient = CGGradientCreateWithColorComponents(spaceRef, gradientColor, nil, 2);
    CGContextDrawLinearGradient(c, gradient, CGPointMake(rect.size.width/2,0), CGPointMake(rect.size.width/2,rect.size.height), kCGGradientDrawsBeforeStartLocation);  

    CGGradientRelease(gradient);
    
    CGContextSetLineWidth(c, headerInfo.borderWidth);  
    CGContextSetStrokeColor(c, CGColorGetComponents( [headerInfo.borderColor CGColor] ));
    CGContextSetAllowsAntialiasing(c, NO);
    // Top line
    CGContextMoveToPoint(c, 0, 1);
    CGContextAddLineToPoint(c, rect.size.width, 1); 
    
    // Left line
    CGContextMoveToPoint(c, 0, 0);
    CGContextAddLineToPoint(c, 0, rect.size.height);        
    
    // right line (only the last cell)
    if(column==headerInfo.numCols-1)
    {
        CGContextMoveToPoint(c, rect.size.width-1, 0);
        CGContextAddLineToPoint(c, rect.size.width-1, rect.size.height);        
    }
    // Bottom line
    CGContextMoveToPoint(c, 0, rect.size.height);
    CGContextAddLineToPoint(c, rect.size.width, rect.size.height);
    
    CGContextStrokePath(c); 
    CGContextSetAllowsAntialiasing(c, YES);
    // Draw Text
   
    [headerInfo.headerFontColor set];
    
    [[UIColor whiteColor] set];
    
    rect = CGRectMake(rect.origin.x+4, rect.origin.y+4, rect.size.width-8, rect.size.height-8);
    
    if(entity.filterOptions!=nil)
    {
        BOOL filter = NO;
        BOOL sort = NO;
        
        UIImage *imgSort, *imgFilter;
        CGSize size = CGSizeMake(0, 0);

        if(entity.filterOptions.sortOption==kFilterAscent)
        {
            sort = YES;
            imgSort = [UIImage imageNamed:@"SortingDescending"];
            size = imgSort.size;
        }
        else if(entity.filterOptions.sortOption==kFilterDescent)
        {
            sort = YES;
            imgSort = [UIImage imageNamed:@"SortingAscending"];
            size = imgSort.size;
        }
        if(entity.filterOptions.filterValue!=nil)
        {
            filter = YES;
            imgFilter = [UIImage imageNamed:@"SortingFilter"];
            size = imgFilter.size;
        }

        if(sort)
        {
            CGPoint dest = CGPointMake(2, 2);

            // CGPoint dest = CGPointMake(2, (rect.size.height-imgSort.size.height)/2);
            [imgSort drawAtPoint:dest];
        }
        if(filter)
        {
            // CGPoint dest = CGPointMake(2, 2-imgFilter.size.height);
            CGPoint dest = CGPointMake(2, rect.size.height-imgFilter.size.height+6);
            [imgFilter drawAtPoint:dest];           
        }
        if(sort || filter)
            rect = CGRectInset(rect, size.width+2 , 0);
    }
    NSString *label = entity.labelName;
        
    UIFont *tempFont = [UIFont fontWithName:headerInfo.headerFontName size:headerInfo.headerFontSize];
    CGFloat pointSize = headerInfo.headerFontSize;
    while(true)
    {
        CGSize destSize = CGSizeMake(rect.size.width, 10000.0);
        CGSize textSize = [label sizeWithFont:tempFont constrainedToSize:destSize lineBreakMode:NSLineBreakByWordWrapping];
        
        if(textSize.height < rect.size.height || pointSize <= headerInfo.minimumHeaderFontSize)
        {
            destSize.height = rect.size.height;
            textSize = [label sizeWithFont:tempFont constrainedToSize:destSize lineBreakMode:NSLineBreakByWordWrapping];

            CGRect textRect = CGRectMake(rect.origin.x, rect.origin.y + (rect.size.height - textSize.height)/2  , rect.size.width, textSize.height);
            [label drawInRect:textRect withFont:tempFont lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentCenter];
            
            break;
        }
        else
        {
            pointSize -= 1.0;
            tempFont = [UIFont fontWithName:headerInfo.headerFontName size:pointSize];
          
        }
    }
    tempFont = nil;
    CGColorSpaceRelease(spaceRef);
}

@end
