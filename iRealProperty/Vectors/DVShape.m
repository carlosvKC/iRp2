#import "DVShape.h"
#import "DVModelView.h"
#import "DVLabel.h"
#import "Helper.h"


@implementation DVShape

@synthesize color = _color;
@synthesize width = _width;
@synthesize label = _label;
@synthesize length = _length;
@synthesize lastClick = _lastClick;

@synthesize selected;
@synthesize delegate = _delegate;
@synthesize guid = _guid;
@synthesize center;
@synthesize inheritLayer = _inheritLayer;

@synthesize hideLabel = _hideLabel;

-(id)init
{
    self = [super init];
    _handleColor = [DVModelView  UIColorFromRGB255:255 green:0 blue:0];
    _handleWidth = 6.0;
    _label = [[DVLabel alloc]init];
    _length = 0;
    _guid = [Helper generateGUID];
    _inheritLayer = YES;
    return self;
}
-(id)copyWithZone:(NSZone *)zone
{
    DVShape *copy = [[DVShape alloc]init];
    [self duplicateTo:copy];
    return copy;
}
-(void)duplicateTo:(DVShape *)copy
{
    copy->_width = _width;
    copy->_length = _length;
    [copy setColor:_color];
    [copy setGuid:[_guid copy]];
    copy->_handleColor = _handleColor;
    copy->_handleWidth = _handleWidth;
    copy->_label = [_label copy];
    copy->_delegate = _delegate;
    copy->_inheritLayer = _inheritLayer;
    copy->_hideLabel = _hideLabel;

}
// Draw the shape in the current context
-(void)drawShape:(CGContextRef)gc scale:(CGFloat)scale offset:(CGSize)offset lineWidth:(CGFloat)lineWidth lineColor:(UIColor *)lineColor dashTable:(CGFloat *)dashes dashCount:(int)dashCount transparency:(CGFloat)transparency showSelect:(BOOL)showSelect
{
}
-(void)flipVertical:(BOOL)vertical aroundPoint:(CGPoint)center
{
}
-(BOOL)intersectWithShape:(CGRect )rect
{
    return NO;
}
-(int)findIntersectEndSegment:(CGRect)rect outPoint:(CGPoint *)point
{
    return 0;
}
-(void)swapEnd:(CGPoint)pt
{
    
}
-(CGPoint)findIntersectPoint:(int)segment
{
    return CGPointZero;
}
-(void)setDelegate:(id<DVShapeDelegate>)aDelegate
{
    _delegate = aDelegate;
    _label.delegate = aDelegate;
    [self autoUpdate];
}
-(void)drawHandle:(CGPoint)pt context:(CGContextRef)gc scale:(CGFloat)scale offset:(CGSize)offset
{
    pt.x = (pt.x * scale) - offset.width;
    pt.y = (pt.y * scale) - offset.height;
    
    CGContextSetStrokeColorWithColor(gc, [_handleColor CGColor]);
    CGRect rect = CGRectMake(pt.x - _handleWidth, pt.y - _handleWidth,2*_handleWidth, 2*_handleWidth);

    CGContextSetLineDash(gc, 0, 0, 0);
    CGContextSetLineWidth(gc, 1.0);
    CGContextAddRect(gc, rect);
    CGContextStrokePath(gc);
}
-(void)drawHandle:(CGPoint)pt context:(CGContextRef)gc scale:(CGFloat)scale offset:(CGSize)offset color:(UIColor *)color
{
    UIColor *tempColor = _handleColor;
    _handleColor = color;

    [self drawHandle:pt context:gc scale:scale offset:offset];
    _handleColor = tempColor;
}
-(void)drawHandleRound:(CGPoint)pt context:(CGContextRef)gc scale:(CGFloat)scale offset:(CGSize)offset
{
    pt.x = (pt.x * scale) - offset.width;
    pt.y = (pt.y * scale) - offset.height;
    
    CGContextSetFillColorWithColor(gc, [_handleColor CGColor]);
    CGRect rect = CGRectMake(pt.x - _handleWidth, pt.y - _handleWidth,2*_handleWidth, 2*_handleWidth);
    CGContextFillEllipseInRect(gc, rect);
    
}
-(CGPoint)getCenter
{
    return CGPointZero;
}
-(CGPoint)getStartPoint
{
    return CGPointZero;
}
-(CGPoint)getEndPoint
{
    return CGPointZero;
}
-(CGFloat)getLength
{
    return _length;
}
-(void)setStartPoint:(CGPoint)startPoint
{
}
-(void)setEndPoint:(CGPoint)endPoint
{
}
-(CGRect)getShapeFrame
{
    return CGRectZero;
}
-(NSString *)getShapeXML
{
    return @"<shape type=\"shape\" />";
}
-(void)autoUpdate
{
}
-(void)drawInPath:(CGMutablePathRef)path
{
}
-(void)dealloc
{
    _color = nil;
    _handleColor = nil;
    _label = nil;
    _delegate = nil;
    self.delegate = nil;
    self.color = nil;
    self.label = nil;
    self.guid = nil;
}
@end
