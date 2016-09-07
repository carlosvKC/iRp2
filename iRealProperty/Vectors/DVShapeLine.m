#import "DVShapeLine.h"
#import "MathHelper.h"
#import "DVLabel.h"
#import "Helper.h"

@implementation DVShapeLine

@synthesize start = _start;
@synthesize end = _end;
@synthesize dashSize = _dashSize;


//
// Default init
-(id)initLine:(CGPoint)startPt to:(CGPoint)endPt
{
    self = [super init];
    if(self)
    {
        [self defaultValues];
        
        _start = startPt;
        _end = endPt;
        _length = [MathHelper distanceBetweenPoints:_start pt2:_end];
    }
    return self;
}
-(id)copyWithZone:(NSZone *)zone
{
    DVShapeLine *copy = [[DVShapeLine alloc]init];
    if(copy)
    {
        [super duplicateTo:copy];
        copy->_start = _start;
        copy->_end = _end;
        copy->_dashSize = _dashSize;
    }
    return copy;
}

-(id)initLine:(CGPoint)startPt to:(CGPoint)endPt withDash:(CGFloat)dSize
{
    self = [super init];
    if(self)
    {
        [self defaultValues];
        
        _start = startPt;
        _end = endPt;
        _dashSize = dSize;
    }
    return self;
}
-(void)defaultValues
{
    _width = 2.0;
    _color = [DVModelView  UIColorFromRGB255:0 green:0 blue:0];
    _pattern = kPatternSolid;
    _length = 0;

}
-(NSString *)description
{
    return [NSString stringWithFormat:@"Line %@ to %@, color=%@, label=%@", NSStringFromCGPoint(_start), NSStringFromCGPoint(_end), [_color description], self.label.text];
}
-(void)drawInPath:(CGMutablePathRef)path
{
    CGPoint point = CGPathGetCurrentPoint(path);
    
    if(!CGPointEqualToPoint(point, _start))
    {
        CGPathAddLineToPoint(path, nil, _start.x, _start.y); 
    }
    
    CGPathAddLineToPoint(path, nil, _end.x, _end.y); 

}
// Draw the shape in the current context
-(void)drawShape:(CGContextRef)gc scale:(CGFloat)scale offset:(CGSize)offset lineWidth:(CGFloat)lineWidth lineColor:(UIColor *)lineColor dashTable:(CGFloat *)dashes dashCount:(int)dashCount transparency:(CGFloat)transparency showSelect:(BOOL)showSelect
{
    UIColor *textColor;
    if(!_inheritLayer)
    {
        UIColor *color = [Helper adjustTransparency:_color transparency:transparency];
        CGContextSetStrokeColorWithColor(gc, [color CGColor]);
        CGContextSetLineWidth(gc, _width);    

        CGFloat lengths[2];
        lengths[0] = _dashSize;
        lengths[1] = _dashSize;
        
        CGContextSetLineDash(gc, 0, lengths, (_dashSize==0)?0:2);
        textColor = color;
    }   
    else
    {
        // Use the layer's information
        UIColor *color = [Helper adjustTransparency:lineColor transparency:transparency];
        CGContextSetStrokeColorWithColor(gc, [color CGColor]);
        CGContextSetLineWidth(gc, lineWidth);    
        
        CGContextSetLineDash(gc, 0, dashes, dashCount);
        textColor = color;
    }
    CGPoint startPt, endPt;
    
    startPt = [self.delegate shapeGetPointInScreenCoordinates:_start];
    endPt = [self.delegate shapeGetPointInScreenCoordinates:_end];
    
    CGContextMoveToPoint(gc, startPt.x, startPt.y);
    CGContextAddLineToPoint(gc, endPt.x , endPt.y);
    CGContextStrokePath(gc);
    CGContextSetLineDash(gc, 0, 0, 0);
    
    // If the shape is selected, draw the handles
    if(self.selected && showSelect)
    {        
        [self drawHandle:_start context:gc scale:scale offset:offset];
        [self drawHandle:_end context:gc scale:scale offset:offset];
    }
    if(!CGPointEqualToPoint(_start, _end))
    {
        if(!_hideLabel)
        {
            _label.textColor = textColor;
            [_label positionLabel:_start endPoint:_end];
            [_label drawLabel:gc];
        }
    }
}
-(BOOL)intersectWithShape:(CGRect )rect
{
    if([MathHelper lineIntersectWithRectangle:_start endPoint:_end withRect:rect])
        return YES;
    return NO;
}
-(int)findIntersectEndSegment:(CGRect)rect outPoint:(CGPoint *)point
{
    if(CGRectContainsPoint(rect, _start))
    {
        *point = _start;
        return 1;
    }
    else if(CGRectContainsPoint(rect, _end))
    {
        *point = _end;
        return 2;
    }
    return 0;
}

-(void)swapEnd:(CGPoint)pt
{
    CGPoint point;
    
    if(CGPointEqualToPoint(_start, pt))
    {
        point = _end;
        _end = _start;
        _start = point;
    }
}
-(void)swapEnds
{
    CGPoint point= _end;
    _end = _start;
    _start = point;
}
-(void)setEnd:(CGPoint)pt
{
    _end = pt;
    // Calculate the distance
    [self updateInfo:_start to:_end];
}
-(void)setStart:(CGPoint)pt
{
    _start = pt;
    [self updateInfo:_start to:_end];
}
// Update the length of the wall
-(void)setLength:(CGFloat)l
{
    _length = l;
    // _end = [MathHelper pointAtDistanceOfPoint:_start end:_end distance:l];
}
-(void)adjustLength:(CGFloat)l
{
    l *= [self.delegate shapePixelPerUnit];
    _end = [MathHelper pointAtDistanceOfPoint:_start end:_end distance:l];
    [self updateInfo:_start to:_end];
    
}
-(CGFloat)getLength
{
    CGFloat l = [MathHelper distanceBetweenPoints:_start pt2:_end];
    _length = l;
    return l;
}
-(void)updateInfo:(CGPoint)startPt to:(CGPoint)endPt
{
    self.length = [MathHelper distanceBetweenPoints:startPt pt2:endPt];
    if(self.delegate!=nil)
        self.label.text = [self.delegate shapeFloatToFeet:self.length];
}
-(void)autoUpdate
{
    [self updateInfo:_start to:_end];
}
-(CGPoint)getCenter
{
    CGPoint center;
    center.x = _start.x + (_end.x - _start.x)/2;
    center.y = _start.y + (_end.y - _start.y)/2; 
    
    return center;
}
-(void)setCenter:(CGPoint)point
{
    // Reposition the shape
    CGPoint center = [self getCenter];
    CGFloat deltax = point.x - center.x;
    CGFloat deltay = point.y - center.y;
    
    _start = CGPointMake(_start.x + deltax, _start.y + deltay);
    _end = CGPointMake(_end.x + deltax, _end.y + deltay);
}
-(CGPoint)getStartPoint
{
    return _start;
}
-(CGPoint)getEndPoint
{
    return _end;
}
-(NSString *)getShapeXML
{
    return [NSString stringWithFormat:@"<shape type=\"line\" start=\"%@\" end=\"%@\" lblOffset=\"%f\" lblHidden=\"%d\"  />", NSStringFromCGPoint(_start), NSStringFromCGPoint(_end), _label.offset, _label.hidden];
}
-(CGRect)getShapeFrame
{
    CGRect rect = CGRectMake(_start.x, _start.y, _end.x - _start.x, _end.y - _start.y);
    rect = CGRectStandardize(rect);
    rect = CGRectInset(rect, -_width, -_width);
    
    return rect;
}
-(void)setStartAngle:(CGFloat)angle
{
}
-(void)setEndAngle:(CGFloat)angle
{

}
-(void)dealloc
{
}
-(void)flipVertical:(BOOL)vertical aroundPoint:(CGPoint)center
{
    if(vertical)
    {
        CGFloat delta = _start.x - center.x;
        _start.x -= 2*delta;
        delta = _end.x - center.x;
        _end.x -= 2*delta;
    }
    else
    {
        CGFloat delta = _start.y - center.y;
        _start.y -= 2*delta;
        delta = _end.y - center.y;
        _end.y -= 2*delta;
    }
}
@end
