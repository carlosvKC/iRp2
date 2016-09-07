#import <Foundation/Foundation.h>

@protocol UIDragableToolbarDelegate

-(void)draggedBy:(CGPoint)delta;

@end

@interface UIDragableToolbar : UIToolbar
{
    BOOL _isDragging;
    CGPoint _startPoint;
    UITouch* _startTouch;
    id<UIDragableToolbarDelegate> __unsafe_unretained _dragableDelegate;
}
@property (nonatomic, unsafe_unretained) id<UIDragableToolbarDelegate> dragableDelegate;
@end
