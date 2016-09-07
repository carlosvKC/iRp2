#import "BackgroundLayer.h"

@implementation BackgroundLayer

@synthesize backType;
@synthesize constrainDelta;
@synthesize offset;

-(id)init
{
    self = [super init];
    constrainDelta = 25;
    backType = kBackgroundYellowLine;
    return self;
}
-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    constrainDelta = 25;
    backType = kBackgroundYellowLine;
    return self;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        constrainDelta = 25;
        backType = kBackgroundYellowLine;
    }
    return self;
}
- (void)drawRect:(CGRect)rect
{
    CGContextRef gc = UIGraphicsGetCurrentContext();
    constrainDelta = 23;
    backType = kBackgroundYellowLine;
    
    if(backType==kBackgroundYellowLine)
    {
        CGFloat backgroundColor[4] = { 253.0/255.0, 246.0/255.0, 164.0/255.0, 1.0 };
        CGContextSetFillColor(gc, backgroundColor);
        CGContextFillRect(gc, rect);

        CGFloat spacer = 22.0;
        
        CGContextSetAllowsAntialiasing(gc, NO); // Avoid anti aliasing on vertical and horizontal lines
        
        CGFloat lineColor[4] = { 250/255.0, 175/255.0, 175/255.0, 1.0 };
        CGContextSetStrokeColor(gc, lineColor);
        CGContextSetLineWidth(gc, 1.0);
        
        // Draw horizontal lines        
        for(int y=26.0+self.offset;y<rect.size.height;y+=spacer)
        {
            CGContextMoveToPoint(gc, 0, y);
            CGContextAddLineToPoint(gc, rect.size.width, y);
            
        }
        CGContextStrokePath(gc);
        // Draw vertical lines
        CGFloat verticalColor[4] = { 250.0/255.0, 175/255.0, 175/255.0, 1.0 };
        CGContextSetStrokeColor(gc, verticalColor);
        int leftX = 25;
        CGContextMoveToPoint(gc, leftX, 0);
        CGContextAddLineToPoint(gc, leftX, rect.size.height);
        // Make the drawing visible
        CGContextStrokePath(gc);
        
    }
    else if(backType==kBackgroundSmallSquare)
    {
        CGContextSetAllowsAntialiasing(gc, NO); // Avoid anti aliasing on vertical and horizontal lines

        CGFloat gridColor[4] = { 176.0/255.0, 240.0/255.0, 250.0/255.0, 1.0 };
        CGContextSetStrokeColor(gc, gridColor);
        CGContextSetLineWidth(gc, 1.0);
        
        // Draw horizontal lines        
       for(int y=1;y<rect.size.height;y+=constrainDelta)
       {
           CGContextMoveToPoint(gc, 0, y);
           CGContextAddLineToPoint(gc, rect.size.width, y);

        }
        // Draw vertical lines
        for(int x=0;x<rect.size.width;x+= constrainDelta)
        {
            CGContextMoveToPoint(gc, x, 0);
            CGContextAddLineToPoint(gc, x, rect.size.height);
        }
        // Make the drawing visible
        CGContextStrokePath(gc);

    }
}

@end
