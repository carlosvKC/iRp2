
#import "GridResizer.h"
#import "GridHeaderController.h"


@implementation GridResizer

@synthesize controller;
@synthesize offset;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
    {
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    NSString *pict = @"CrossArrow.png";
    UIImage *img = [UIImage imageNamed:pict]; 
    if(img==nil)
    {
        NSLog(@"can't open '%@'", pict);
        return;
    }
       
    [img drawAtPoint:CGPointMake(rect.origin.x + (rect.size.width - img.size.width)/2, 
                                    rect.origin.y + (rect.size.height-img.size.height)/2)];
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{
    UITouch *aTouch = [touches anyObject];
    offset = [aTouch locationInView: self];
    delta = [aTouch locationInView:self.superview];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *aTouch = [touches anyObject];
    CGPoint location = [aTouch locationInView:self.superview];
    GridHeaderController *ctrl = (GridHeaderController *)controller;    
    
    BOOL res = [ctrl resizerMove:location.x-delta.x];
    // NSLog(@"move by %d (res=%d)",(int)(location.x-delta.x),res);
    if(res==YES)
        return;
    delta = location;
    [UIView beginAnimations:@"Dragging the separator" context:nil];
    self.frame = CGRectMake(location.x-offset.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
    [UIView commitAnimations];
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event 
{
    GridHeaderController *ctrl = (GridHeaderController *)controller;

    [ctrl resizerDone];
}


@end
