
#import "DraggableBar.h"

@implementation DraggableBar 

@synthesize dragableDelegate = _dragableDelegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
    {
        // Initialization code
        _isDragging = NO;
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!_isDragging)
    {
        for (UITouch*touch in touches) 
        {
            _startTouch = touch;
            _startPoint = [touch locationInView:self];
            break;
        }
        _isDragging = true;
    }
}
-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    _isDragging = false;
    _startTouch = nil;
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_isDragging)
    {
        for (UITouch* touch in touches) 
        {
            if (touch == _startTouch)
            {
                CGPoint currentPoint = [touch locationInView:self];
                [self.dragableDelegate viewDraggedBy:self delta:CGPointMake(currentPoint.x - _startPoint.x, currentPoint.y - _startPoint.y)];
                break;
            }
        }
    }
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event 
{
    _isDragging = false;
    _startTouch = nil;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
