
#import "UIRoundedView.h"
#import "Helper.h"

@implementation UIRoundedView
@synthesize backgroundColor;
@synthesize lineColor;
@synthesize radius;
@synthesize lineWidth;

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        self.radius = 12.0f;
        self.lineWidth = 1.0f;
        self.backgroundColor = [Helper UIColorFromRGB255:216 green:216 blue:216];
        self.lineColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
    }
    return self;

}
/***
-(void)drawRect:(CGRect)updateRect
{
   
    CGRect rect = self.bounds;
    CGContextRef c = UIGraphicsGetCurrentContext();   

    const CGFloat *f = CGColorGetComponents([self.backgroundColor CGColor]);
    CGContextSetFillColor(c,f);
    CGContextFillRect(c, updateRect);
    
    f = CGColorGetComponents([self.lineColor CGColor]);
    CGContextSetStrokeColor(c,f);

    rect = CGRectInset(rect, 9.0, 9.0);
    
    CGContextBeginPath(c);
    
    CGFloat minX = CGRectGetMinX(rect);
    CGFloat maxX = CGRectGetMaxX(rect);
    CGFloat minY = CGRectGetMinY(rect);
    CGFloat maxY = CGRectGetMaxY(rect);
    
    CGContextMoveToPoint(c, minX + radius, minY);
    CGContextAddArcToPoint(c, maxX, minY, maxX, minY + radius, radius);
    CGContextAddArcToPoint(c, maxX, maxY, maxX - radius, maxY, radius);
    CGContextAddArcToPoint(c, minX, maxY, minX, maxY - radius, radius);
    CGContextAddArcToPoint(c, minX, minY, minX + radius, minY, radius);
    
    CGContextClosePath(c);
    CGContextStrokePath(c);
}
****/
@end
