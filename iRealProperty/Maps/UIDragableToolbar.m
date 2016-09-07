#import "UIDragableToolbar.h"

@implementation UIDragableToolbar

@synthesize dragableDelegate = _dragableDelegate;

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!_isDragging)
    {
        for (UITouch*touch in touches) {
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
        for (UITouch* touch in touches) {
            if (touch == _startTouch)
            {
                CGPoint currentPoint = [touch locationInView:self];
                [self.dragableDelegate draggedBy:CGPointMake(currentPoint.x - _startPoint.x, currentPoint.y - _startPoint.y)];
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
@end
