#import "SegmentedControlLightView.h"

@implementation SegmentedControlLightView
@synthesize segLight;
@synthesize segment;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        segLight = kSegLightNone;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    NSString *pictName = nil;
    
    switch (segLight) {
        case kSegLightGray:
            pictName = @"dotgray.png";
            break;
        case kSegLightGreen:
            pictName = @"dotgreen.png";
            break;
        case kSegLightOrange:
            pictName = @"dotorange.png";
            break;
        case kSegLightRed:
            pictName = @"dotred.png";
            break;
        default:
            pictName = nil;
            break;
    }
    
    CGContextRef c = UIGraphicsGetCurrentContext();
    
    CGFloat trans[4] = {1.0,1.0,1.0,0.0};
    CGContextSetFillColor(c, trans);
    CGContextFillRect(c, rect);
   
    UIImage *img = [UIImage imageNamed:pictName];
    
    if(img==nil)
        return;

    [img drawInRect:rect];
}

@end
