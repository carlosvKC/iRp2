#import "DVShapeArc.h"
#import "MathHelper.h"
#import "DVLabel.h"

@implementation DVShapeArc

@synthesize center = _center;
@synthesize radius = _radius;
@synthesize startAngle = _startAngle;
@synthesize endAngle = _endAngle;
@synthesize endPoint;
@synthesize startPoint;
@synthesize middlePoint;
@synthesize height = _height;


-(NSString *)description
{
    return [NSString stringWithFormat:@"{ center=%@ radius=%f stAngle=%f endAngle=%f width=%f",
            NSStringFromCGPoint(_center), _radius, _startAngle, _endAngle, _width];
}
-(id)initArc:(CGPoint)center radius:(CGFloat)radius 
{
    return [self initArc:center radius:radius startAngle:0 endAngle:2*M_PI];
}
-(id)initArc:(CGPoint)center radius:(CGFloat)radius startAngle:(CGFloat)sAngle endAngle:(CGFloat)eAngle
{
    self = [super init];
    if(self)
    {
        _width = 2.0;
        _color = [DVModelView  UIColorFromRGB255:0 green:0 blue:0];
        _pattern = kPatternSolid;
        
        _center = center;
        _endAngle = eAngle;
        _startAngle = sAngle;
        _radius = radius;
        _length = 2*radius;
    }
    return self;     
}




-(id)copyWithZone:(NSZone *)zone
{
    DVShapeArc *copy = [[DVShapeArc alloc]init];
    if(copy)
    {
        [super duplicateTo:copy];
        copy->_center = _center;
        copy->_startAngle = _startAngle;
        copy->_endAngle = _endAngle;
        copy->_radius = _radius;
        copy->_middle = _middle;
        copy->_height = _height;
    }
    return copy;
}

-(void)setStartAngle:(CGFloat)startAngle
{
    if(startAngle > 2*M_PI)
        startAngle -= 2*M_PI;
    _startAngle = startAngle;
    if(ABS(_startAngle-_endAngle) < 0.01)
    {
        _endAngle = _startAngle + 2*M_PI;
    }
    [self updateLabel];
}
-(void)setEndAngle:(CGFloat)endAngle
{
    if(endAngle> 2*M_PI)
        endAngle -= 2*M_PI;
    _endAngle = endAngle;
    if(ABS(_startAngle-_endAngle) < 0.01)
    {
        _endAngle = _startAngle + 2*M_PI;
    }
    [self updateLabel];
}
-(void)setRadius:(CGFloat)r
{
    _radius = r;
    _length = 2 * _radius;
    [self updateLabel];
}
-(void)setCenter:(CGPoint)c
{
    _center = c;
    [self updateLabel];
}
-(void)drawInPath:(CGMutablePathRef)path
{
    CGPoint point = CGPathGetCurrentPoint(path);
    CGPoint sPoint = [MathHelper circlePoint:_center radius:_radius angle:_startAngle];
    
    if(!CGPointEqualToPoint(point, sPoint))
    {
        CGPathAddLineToPoint(path, nil, sPoint.x, sPoint.y);
    }
    CGPathAddArc(path, nil, _center.x, _center.y, _radius, _startAngle, _endAngle, 0);
}
// Draw the shape in the current context
-(void)drawShape:(CGContextRef)gc scale:(CGFloat)scale offset:(CGSize)offset lineWidth:(CGFloat)lineWidth lineColor:(UIColor *)lineColor dashTable:(CGFloat *)dashes dashCount:(int)dashCount transparency:(CGFloat)transparency showSelect:(BOOL)showSelect
{
    UIColor *textColor;
    if(!_inheritLayer)
    {
        CGContextSetStrokeColorWithColor(gc, [_color CGColor]);
        CGContextSetLineWidth(gc, _width);    
        CGContextSetLineDash(gc, 0, 0,0);
        textColor = _color;
    }   
    else
    {
        // Use the layer's information
        CGContextSetStrokeColorWithColor(gc, [lineColor CGColor]);
        CGContextSetLineWidth(gc, lineWidth);    
        
        CGContextSetLineDash(gc, 0, dashes, dashCount);
        textColor = lineColor;
    }

    
    CGPoint pt = [self.delegate shapeGetPointInScreenCoordinates:_center];
    
    CGContextAddArc(gc, pt.x, pt.y, _radius *scale, _startAngle, _endAngle, 0);
    
    CGContextStrokePath(gc);
    if(self.selected && showSelect)
    {
        [self drawHandle:_center context:gc scale:scale offset:offset color:[UIColor blueColor]];       
        CGPoint pt = [MathHelper angleToPoint:_center radius:_radius angle:_startAngle];
        [self drawHandle:pt context:gc scale:scale offset:offset];
        pt = [MathHelper angleToPoint:_center radius:_radius angle:_endAngle];
        [self drawHandle:pt context:gc scale:scale offset:offset];
        
        _middle = _startAngle + (_endAngle - _startAngle)/2.0;
        pt = [MathHelper angleToPoint:_center radius:_radius angle:_middle];
        [self drawHandle:pt context:gc scale:scale offset:offset color:[UIColor blueColor]];
        
    }
    if(_radius>0 && !_hideLabel)
    {
        _label.textColor = textColor;
        [_label drawLabel:gc];
    }
}
-(BOOL)intersectWithShape:(CGRect )rect
{
    if([MathHelper circleIntersectWithRectangle:_center radius:_radius rect:rect])
    {
        // Check for all the 4 points of the rectangle
        CGPoint pt = rect.origin;
        // top/left
        if([self intersectWithPoint:pt])
            return YES;
        //top right
        pt = CGPointMake(rect.origin.x+rect.size.width, rect.origin.y);
        if([self intersectWithPoint:pt])
            return YES;
        // bottom right
        pt = CGPointMake(rect.origin.x+rect.size.width, rect.origin.y+rect.size.height);
        if([self intersectWithPoint:pt])
            return YES;
        // bottom left
        pt = CGPointMake(rect.origin.x, rect.origin.y+rect.size.height);
        if([self intersectWithPoint:pt])
            return YES;
        return NO;
    }
    // Check if the click is in the center (object must be selected first)
    if(CGRectContainsPoint(rect, _center) && self.selected)
        return YES;

    return NO;
}
-(BOOL)intersectWithPoint:(CGPoint)pt
{
    return YES;
    // Need to review carefully the different angles...
    CGFloat angle = [MathHelper angleToRadian:_center point:pt];   
    if(_endAngle > _startAngle)
    {
        if(angle>=_startAngle && angle<=_endAngle)
            return YES;
    }
    else 
    {
        if(angle>=_endAngle && angle<=_startAngle)
            return YES;
    }
    return NO;
}
-(int)findIntersectEndSegment:(CGRect)rect outPoint:(CGPoint *)point
{
    CGPoint pt = [MathHelper angleToPoint:_center radius:_radius angle:_startAngle];
    
    if(CGRectContainsPoint(rect, pt))
    {
        *point = pt;
        return kAngleStart;
    }
    pt = [MathHelper angleToPoint:_center radius:_radius angle:_endAngle];
    if(CGRectContainsPoint(rect, pt))
    {
        *point = pt;
        return kAngleEnd;
    }    
    if(CGRectContainsPoint(rect, _center))
    {
        *point = [MathHelper angleToPoint:_center radius:_radius angle:_endAngle];
        return kAngleCenter;
    }

    pt = [MathHelper angleToPoint:_center radius:_radius angle:_middle];
    if(CGRectContainsPoint(rect, pt))
    {
        *point = pt;
        return kAngleShape;
    }

    return kAngleNone;
}
-(void)swapEnd:(CGPoint)point
{
    return;

    CGPoint pt = [MathHelper angleToPoint:_center radius:_radius angle:_startAngle];
    if(CGPointEqualToPoint(pt, point))
        return;
    CGFloat angle = _startAngle;
    _startAngle = _endAngle;
    _endAngle = angle;

}
-(void)swapEnds
{
    return;
    CGFloat angle = _startAngle;
    _startAngle = _endAngle;
    _endAngle = angle;
}

// Recalculate the label
-(void)updateLabel
{
    CGPoint startPt = CGPointMake(_center.x - _radius, _center.y);
    CGPoint endPt = CGPointMake(_center.x + _radius, _center.y);
    
    // Calculate the angle 
    int a = (_startAngle * 180)/M_PI+0.1;
    int b = (_endAngle * 180)/M_PI+0.1;
    
    a = ABS(a-b);
    _label.text = [NSString stringWithFormat:@"%@", [self.delegate shapeFloatToFeet:2*_radius]];
    [_label positionLabel:startPt endPoint:endPt];
    
    NSString *text = [NSString stringWithFormat:@"%lf\"  %d`/%d`", 2*_radius/ [self.delegate shapePixelPerUnit], 360-a, 360-b];
    [self.delegate shapeDisplayInfo:text];
}
-(void)autoUpdate
{
    [self updateLabel];
}
-(CGPoint)getCenter
{
    return _center;
}
-(CGFloat)getLength
{
    return 2*_radius;
}
-(CGPoint)getPointOnCircle:(CGFloat)angle
{
    return [MathHelper circlePoint:_center radius:_radius angle:angle];
}
-(CGPoint)getStartPoint
{
    return [self getPointOnCircle:_startAngle];
}
-(CGPoint)getEndPoint
{
    return [self getPointOnCircle:_endAngle];
}
-(CGPoint)getMiddlePoint
{
    return [self getPointOnCircle:_middle];
}
-(NSString *)getShapeXML
{
    return [NSString stringWithFormat:@"<shape type=\"arc\" center=\"%@\" radius=\"%f\" startAngle=\"%f\" endAngle=\"%f\" lblOffset=\"%f\" lblHidden=\"%d\" />", NSStringFromCGPoint(_center), _radius, _startAngle, _endAngle, _label.offset, _label.hidden ];
}
// This rectangle includes the entire circle. It could be optimized a little bit
-(CGRect)getShapeFrame
{
    CGRect rect = CGRectMake(_center.x - _radius, _center.y - _radius, 2*_radius, 2*_radius);
    rect = CGRectInset(rect, - _width, - _width);
    
    return rect;
}
-(void)dealloc
{
}
-(void)flipVertical:(BOOL)vertical aroundPoint:(CGPoint)center
{
    CGFloat angle = _startAngle;
    _startAngle = _endAngle;
    _endAngle = angle;
}

@end
