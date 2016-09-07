#import "DVShape.h"
#import "DVModelView.h"


@interface DVShapeLine : DVShape<NSCopying>
{
    // Coordinates in the local system
    CGPoint     _start;
    CGPoint     _end;
    
    CGFloat      _dashSize;
}
@property(nonatomic) CGPoint start;
@property(nonatomic) CGPoint end;
@property(nonatomic) CGFloat dashSize;

-(id)initLine:(CGPoint)startPoint to:(CGPoint)endPoint;
-(id)initLine:(CGPoint)startPoint to:(CGPoint)endPoint withDash:(CGFloat)dSize;
// set the point as the end
-(void)setEnd:(CGPoint)pt;
// set the point as the end
-(void)swapEnd:(CGPoint)pt;

-(void)updateInfo:(CGPoint)startPt to:(CGPoint)endPt;
// Adjust the length of the shape
-(void)adjustLength:(CGFloat)adjustLength;
// Toggle start and end point
-(void)swapEnds;
-(void)flipVertical:(BOOL)vertical aroundPoint:(CGPoint)center;

@end
