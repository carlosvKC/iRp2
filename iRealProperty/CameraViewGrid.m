
#import "CameraViewGrid.h"

@implementation CameraViewGrid

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];

    return self;
}


- (void)drawRect:(CGRect)rect
{
//    CGContextRef gc = UIGraphicsGetCurrentContext();
//        // Clean up background
//    CGFloat clearColor[4] = {1.0, 1.0, 1.0, 0.0 };
//    CGContextSetFillColor(gc, clearColor);
//    CGContextFillRect(gc, rect);
//    
//    CGContextSetAllowsAntialiasing(gc, NO); // Avoid anti aliasing on vertical and horizontal lines
//    
//    CGFloat gridColor[4] = { 255.0/255.0, 255.0/255.0, 255.0/255.0, 1.0 };
//    CGContextSetStrokeColor(gc, gridColor);
//    CGContextSetLineWidth(gc, 1.0);
//    
//    // Draw horizontal lines        
//    for(int i=0;i<2;i++)
//    {
//        CGFloat y = (i+1)*(rect.size.height/3.0);
//        CGContextMoveToPoint(gc, 0, y);
//        CGContextAddLineToPoint(gc, rect.size.width, y);
//        
//    }
//    // Draw vertical lines
//    for(int i=0;i<2;i++)
//    {
//        CGFloat x = (i+1)*(rect.size.width/3.0);
//        CGContextMoveToPoint(gc, x, 0);
//        CGContextAddLineToPoint(gc, x, rect.size.height);
//    }
//    // Make the drawing visible
//    CGContextStrokePath(gc);
}


@end
