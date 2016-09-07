#import "CaptureView.h"

// Private
@interface CaptureView (/* Private */)
- (void)settingImageFromView:(UIView *)view;
@end

// Public
@implementation CaptureView

@synthesize imageCapture = _imageCapture;

-(id)initWithFrame:(CGRect)frame 
{
    if ((self = [super initWithFrame:frame])) 
    {
        // Initialization code.
    }
    return self;
}

-(id)initWithView:(UIView *)view 
{
    if ((self = [super initWithFrame:[view bounds]])!=nil) 
    {
        [self settingImageFromView:view];
    }
    return self;  
}
-(void)settingImageFromView:(UIView *)view 
{
    CGRect rect = [view bounds];  

    UIGraphicsBeginImageContext(rect.size);  
    CGContextRef context = UIGraphicsGetCurrentContext();  
    [view.layer renderInContext:context];  
    _imageCapture = UIGraphicsGetImageFromCurrentImageContext();  

    UIGraphicsEndImageContext();   
}
-(void)drawRect:(CGRect)rect
{
    CGPoint accPoint = CGPointMake(0,0);
    [_imageCapture drawAtPoint:accPoint];
}
- (void)dealloc 
{
    _imageCapture = nil;
}

@end