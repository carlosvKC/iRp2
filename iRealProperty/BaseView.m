#import "BaseView.h"
#import "Helper.h"

@implementation BaseView

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    [self initTouch];
    return self;
}
-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    [self initTouch];
    return self;
}
-(id)init
{
    self = [super init];
    [self initTouch];
    return self;
}
-(void)initTouch
{
    UISwipeGestureRecognizer *swipeRecognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeDetected:)];
    swipeRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self addGestureRecognizer:swipeRecognizer];
    
    UISwipeGestureRecognizer *swipeRecognizerLeft = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeDetected:)];
    swipeRecognizerLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self addGestureRecognizer:swipeRecognizerLeft];
 
    /**
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapDetected:)];
    [self addGestureRecognizer:tapRecognizer];
     ***/

}
-(void)swipeDetected:(UISwipeGestureRecognizer *)swiper
{
    if(swiper.direction==UISwipeGestureRecognizerDirectionUp)
    {
        [self swipeTop];
    }
    else if(swiper.direction==UISwipeGestureRecognizerDirectionDown)
    {
        [self swipeBottom];
    }
    else if(swiper.direction==UISwipeGestureRecognizerDirectionRight)
    {
        [self swipeRight];
    }
    else if(swiper.direction==UISwipeGestureRecognizerDirectionLeft)
    {
        [self swipeLeft];
    }
}
-(void)swipeTop
{
    if(delegate!=nil && [delegate respondsToSelector:@selector(swipeTop)])
        [delegate performSelector:@selector(swipeTop)];
}
-(void)swipeBottom
{
    if(delegate!=nil && [delegate respondsToSelector:@selector(swipeBottom)])
        [delegate performSelector:@selector(swipeBottom)];
}
-(void)swipeRight
{
    if(delegate!=nil && [delegate respondsToSelector:@selector(swipeRight)])
        [delegate performSelector:@selector(swipeRight)];
}
-(void)swipeLeft
{
    if(delegate!=nil && [delegate respondsToSelector:@selector(swipeLeft)])
        [delegate performSelector:@selector(swipeLeft)];
}
- (UIViewController *)viewController;
{
    id nextResponder = [self nextResponder];
    if ([nextResponder isKindOfClass:[UIViewController class]]) 
    {
        return nextResponder;
    } 
    else 
    {
        return nil;
    }
}


@end
