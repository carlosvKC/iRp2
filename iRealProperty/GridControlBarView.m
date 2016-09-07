//
//  GridControlBarView.m
//  iRealProperty
//

#import "GridControlBarView.h"

@implementation GridControlBarView
@synthesize itsController;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
- (void)drawRect:(CGRect)rect
{
    CGFloat gradientColor[8];
    
    CGFloat topColor [4] = {0.7,0.7,0.7,1.0};
    CGFloat bottomColor[4] = {0.0,0.0,0.0,1.0};
    
    for(int i=0;i<4;i++)
    {
        gradientColor[i] = topColor[i];
        gradientColor[i+4] = bottomColor[i];
    }
    
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGColorSpaceRef spaceRef = CGColorSpaceCreateDeviceRGB();
    
    CGGradientRef gradient = CGGradientCreateWithColorComponents(spaceRef, gradientColor, nil, 2);
    CGContextDrawLinearGradient(c, gradient, CGPointMake(rect.size.width/2,0), CGPointMake(rect.size.width/2,rect.size.height), kCGGradientDrawsBeforeStartLocation);  

}
@end
