
#import "DVShape.h"
#import "DVModelView.h"

@interface DVShapeArc : DVShape<NSCopying>
{
    CGPoint     _center;
    CGFloat     _startAngle;
    CGFloat     _endAngle;
    CGFloat     _radius;
    CGFloat     _middle;
    CGFloat     _height;
}
@property(nonatomic) CGFloat radius;
@property(nonatomic) CGFloat startAngle;
@property(nonatomic) CGFloat endAngle;
@property(nonatomic, getter = getMiddlePoint) CGPoint middlePoint;
@property(nonatomic) CGFloat height;


-(id)initArc:(CGPoint)center radius:(CGFloat)radius;
-(id)initArc:(CGPoint)center radius:(CGFloat)radius startAngle:(CGFloat)sAngle endAngle:(CGFloat)eAngle;

-(CGPoint)getStartPoint;
-(CGPoint)getEndPoint;
-(void)flipVertical:(BOOL)vertical aroundPoint:(CGPoint)center;


-(void)swapEnds;
@end
