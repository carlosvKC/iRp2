
#import <UIKit/UIKit.h>

@protocol DraggableBarDelegate <NSObject>

-(void)viewDraggedBy:(UIView *)view delta:(CGPoint)delta;

@end


@interface DraggableBar : UIView
{
    BOOL _isDragging;
    CGPoint _startPoint;
    UITouch* _startTouch;
    id<DraggableBarDelegate> __weak _dragableDelegate;
}
@property (nonatomic, weak ) id<DraggableBarDelegate> dragableDelegate;
@end
