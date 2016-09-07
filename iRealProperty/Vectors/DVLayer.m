
#import "DVLayer.h"
#import "DVModelView.h"

#import "DVShape.h"
#import "DVLabel.h"
#import "ColorPicker.h"
#import "Helper.h"

@implementation DVLayer
@synthesize hidden = _hidden;
@synthesize color = _color;
@synthesize width = _width;
@synthesize name = _name;
@synthesize isDefault = _isDefault;
@synthesize shapes = _shapes;
@synthesize dashCount = _dashCount;

-(id)initWithName:(NSString *)param
{
    self = [super init];
    if(self)
    {
        _name = param;
        _shapes = [[NSMutableArray alloc]init];
        _width = 1.0;
        _color = [UIColor blackColor];
        _dashCount = 0;
    }
    return self;
}
-(id)initWithName:(NSString *)param lineWidth:(CGFloat)lineWidth lineColor:(UIColor *)lineColor dashTable:(CGFloat *)dashes dashCount:(int)dashCount
{
    self = [super init];
    if(self)
    {
        _name = param;
        _shapes = [[NSMutableArray alloc]init];
        _width = lineWidth;
        _color = lineColor;
        if(dashCount>10)
            dashCount = 10;
        for(int i=0;i<dashCount;i++)
            _dash[i] = *dashes++;
        _dashCount = dashCount;
    }
    return self;    
}
-(NSString *)description
{
    NSString *string = [NSString stringWithFormat:@"{ shape='%@', count=%d\n", _name, _shapes.count];
    for(DVShape *shape in _shapes)
        string = [string stringByAppendingFormat:@"%@\n", [shape description]];
    string = [string stringByAppendingString:@"}\n"];
    return string;
}
-(CGFloat *)getDash
{
    return _dash;
}
-(void)setDash:(CGFloat *)dash
{
}
-(void)addShape:(DVShape *)shape
{
    if([shape isKindOfClass:[DVShapeLine class]] && ((DVShapeLine *)shape).length==0)
        return;
    if([shape isKindOfClass:[DVShapeArc class]] && ((DVShapeArc *)shape).radius==0)
        return;

    [_shapes addObject:shape];
}
-(void)deleteAll
{
    [_shapes removeAllObjects];
}
//
// Draw the content of all the shapes -- scale is the current scale to be draw at
// offset is the current offset from top/left
//
-(void)drawLayer:(CGContextRef)cg scale:(CGFloat)scale offset:(CGSize)offset transparency:(CGFloat)transparency showSelect:(BOOL)showSelect
{
    if(_hidden)
        return;
    for(DVShape *shape in _shapes)
    {
        [shape drawShape:cg scale:scale offset:offset lineWidth:_width lineColor:_color dashTable:_dash dashCount:_dashCount transparency:transparency showSelect:showSelect];
    }
    
}
-(void)drawLayer:(CGContextRef)cg scale:(CGFloat)scale offset:(CGSize)offset transparency:(CGFloat)transparency
{
    [self drawLayer:cg scale:scale offset:offset transparency:transparency showSelect:YES];
}
-(DVShape *)intersectWithShape:(CGRect )rect
{
    DVShape *sp = nil;
    // Look first for the selected shape
    for(DVShape *shape in _shapes)
    {
        if(shape.selected)
        {
            if([shape intersectWithShape:rect])
                return shape;
        }
    }
    // Now return for any shape
    for(DVShape *shape in _shapes)
    {
        if([shape intersectWithShape:rect])
        {
            return shape;
        }
    }
    return sp;
}
-(int)findIntersectEndSegment:(CGRect)rect outPoint:(CGPoint *)pt
{
    return [self findIntersectEndSegment:rect outPoint:pt excludeShape:nil];
}
-(int)findIntersectEndSegment:(CGRect)rect outPoint:(CGPoint *)pt excludeShape:(DVShape *)excludeShape
{
    int result;
    for(DVShape *shape in _shapes)
    {
        if(shape==excludeShape)
            continue;
        if(shape.selected)
        {
            if((result=[shape findIntersectEndSegment:rect outPoint:pt])!=0)
                return result;
        }
    }
    for(DVShape *shape in _shapes)
    {
        if(shape==excludeShape)
            continue;
        if((result=[shape findIntersectEndSegment:rect outPoint:pt])!=0)
            return result;
    }
    return 0;
}
// Mark all the shapes as selected or not
-(void)selectShapes:(BOOL)selected
{
    for(DVShape *shape in _shapes)
        shape.selected = selected;
}
-(NSArray *)getSelectedShapes
{
    NSMutableArray *shapes = [[NSMutableArray alloc]init];
    
    for(DVShape *shape in _shapes)
    {
        if(shape.selected)
            [shapes addObject:shape];
    }
    return shapes;
   
}
// Delete all the selected shape
-(void)deleteSelected
{
    NSMutableArray *array = [[NSMutableArray alloc]init];
    
    for(DVShape *shape in _shapes)
    {
        if(shape.selected)
        {
            [array addObject:shape];
        }
    }
    for(DVShape *shape in array)
    {
        [_shapes removeObject:shape];
    }
}
-(void)deleteShape:(DVShape *)shape
{
    [_shapes removeObject:shape];
}
-(DVShape *)findShapeWithGuid:(NSString *)guid
{
    for(DVShape *shape in _shapes)
    {
        if(shape.guid==guid)
            return shape;
    }
    return nil;
}
-(CGMutablePathRef)calculateArea:(int *)error
{
    // Look for first valid shape
    DVShape *firstShape = nil;
    int count = 0;
    for(DVShape *shape in _shapes)
    {
        if([shape isKindOfClass:[DVShapeArc class]] || [shape isKindOfClass:[DVShapeLine class]])
        {
            count++;
            if(shape.selected)
                firstShape = shape;
        }
    }
    
    if(firstShape==nil && error!=nil)
    {
        *error = -1;
        return nil;
    }
    if(count<3 && error!=nil)
    {
        *error = -2;
        return nil;
    }
    CGMutablePathRef path = CGPathCreateMutable();
    CGPoint pt = firstShape.startPoint;
    
    CGPathMoveToPoint(path, nil, pt.x, pt.y);
    
    [self addShapeToPath:firstShape path:path errorWidth:10];

    // Make sure that the shape is closed
    CGPathCloseSubpath(path);

    return path;
}
-(DVShapeText *)shapeAutoText
{
    for(DVShape *shape in _shapes)
    {
        if([shape isKindOfClass:[DVShapeText class]])
        {
            if(((DVShapeText *)shape).isAutoText)
                return (DVShapeText *) shape;
        }
    }
    return nil;
    
}
//
// Return false if an area can't be closed
//
#define CGRectMakeCenter(CGPOINT,WIDTH) CGRectMake(CGPOINT.x - ((WIDTH)/2), CGPOINT.y - ((WIDTH)/2), WIDTH, WIDTH) 
#if 0
-(BOOL)closeArea:(int)errorWidth
{

    DVShape *selectedShape = nil;
    for(DVShape *shape in _shapes)
    {
        if(shape.selected)
        {
            selectedShape = shape;
            break;
        }
    }
    // Need a selected class
    if(selectedShape==nil || [selectedShape isKindOfClass:[DVShapeText class]])
        return NO;
    // Look for the starting point
    CGPoint startPoint = CGPointZero;
    CGPoint endPoint = CGPointZero;
    
    selectedShape = [self findSegment:selectedShape point:&startPoint errorWidth:errorWidth];
    
    // Look for the starting point - check case where the layer is already closed

    ((DVShapeLine *)selectedShape).label.text = @"First segment";

    // Now look for the end point, going in the other direction
    selectedShape = [self findSegment:selectedShape point:&endPoint errorWidth:errorWidth];
    ((DVShapeLine *)selectedShape).label.text = @"end segment";
    
    if(!CGPointEqualToPoint(startPoint, endPoint))
    {
        DVShapeLine *line = [[DVShapeLine alloc]initLine:startPoint to:endPoint];
        line.color = [UIColor redColor];
        line.label.textColor = line.color;
        line.label.fontSize = 14.0;
        line.label.offset = 10.0;    
        line.delegate = selectedShape.delegate;
        
        // after to make sure that the delegate is set
        [line updateInfo:startPoint to:endPoint];
        [self addShape:line];
        
        line.label.text = @"new line";
    }
    
    return YES;
}
#endif
//
// From a segment, add the next segment to the path. Ignore text
// Error width is the authorized error around the point (in pixels)
-(void)addShapeToPath:(DVShape *)shape path:(CGMutablePathRef)path errorWidth:(int)errorWidth
{
    NSMutableArray *excludeShapes = [[NSMutableArray alloc]init];

    int corner;
    // first path, start from the current shape and start point
    while(true)
    {
        [shape drawInPath:path];
        [excludeShapes addObject:shape];
        
        CGRect rect = CGRectMakeCenter(shape.endPoint, errorWidth);

        // Look around the start point
        shape = [self findNextSegment:rect pointClicked:&corner excludeShapes:excludeShapes];
        
        if(shape==nil)
            break;  // No connection, finish
        
        if([shape isKindOfClass:[DVShapeLine class]])
        {
            // It is a line.
            if(corner==2)
                [((DVShapeLine *)shape) swapEnds];
        }
        else if([shape isKindOfClass:[DVShapeArc class]])
        {
            // it is an end angle
            if(corner==kAngleEnd)
                [((DVShapeArc *)shape) swapEnds];
        }
    }

}

// Look for a segment that matches the point. Ignore DVShapeText (and self)
-(DVShape *)findNextSegment:(CGRect)rect pointClicked:(int *)result excludeShapes:(NSArray *)excludeShapes
{
    CGPoint pt;
    for(DVShape *shape in _shapes)
    {
        if([shape isKindOfClass:[DVShapeText class]])
            continue;
        if([excludeShapes containsObject:shape])
            continue;
        // Now look for a specific shape
        if((*result=[shape findIntersectEndSegment:rect outPoint:&pt])!=0)
            return shape;
    }
    return nil;
}
// Return the XML definition of the layer
-(NSString *)getLayerXML:(BOOL)isDefault area:(CGFloat)area
{
    NSString *xml = [NSString stringWithFormat:@"\t<Layer name=\"%@\" width=\"%f\" color=\"%@\" area=\"%f\" ", _name, _width, [_color stringFromColor], area];
    
    if(_dashCount!=0)
    {
        NSString *dash = @"dash=\"";
        for(int i=0;i<_dashCount;i++)
        {
            
            dash = [dash stringByAppendingFormat:@"%f", _dash[i]];
            if(i<_dashCount-1)
                dash = [dash stringByAppendingString:@","];
        }
        xml = [xml stringByAppendingFormat:@"%@\"", dash];
    }
    if(isDefault)
        xml = [xml stringByAppendingString:@" default=\"yes\""];
    xml = [xml stringByAppendingString:@" >\n"];
    // Now return all the shapes
    for(DVShape *shape in _shapes)
    {
        NSString *shapeXml = [shape getShapeXML];
        xml = [xml stringByAppendingFormat:@"\t\t%@\n", shapeXml];
    }
    return xml;
}
-(CGRect)getLayerFrame
{
    CGRect rect = CGRectZero;
    
    for(DVShape *shape in _shapes)
    {
        CGRect shapeRect = [shape getShapeFrame];
        
        if(CGRectEqualToRect(shapeRect, CGRectZero))
            continue;
        
        if(CGRectEqualToRect(rect, CGRectZero))
            rect = shapeRect;
        else
            rect = CGRectUnion(rect, shapeRect);
    }
    return rect;
    
}
-(void)flipVertical:(BOOL)vertical aroundPoint:(CGPoint)pt
{
    for(DVShape *shape in _shapes)
    {
        [shape flipVertical:vertical aroundPoint:pt];
    }
}
-(CGPoint)drawLegend:(CGContextRef)gc dest:(CGPoint)dest area:(CGFloat)area
{
    CGFloat textWidth = 100.0;
    CGFloat lineWidth = 60.0;
    CGFloat texty = dest.y;
    DVModelView *modelView = [DVModelView instance];
    CGPoint pt = [self drawTextAtLoc:_name location:dest fontSize:0 maxWidth:textWidth*modelView.scale];
    
    // Create a temp line
    CGPoint startPt = CGPointMake(dest.x + textWidth, dest.y + 12);
    CGPoint endPt = CGPointMake(startPt.x + lineWidth, startPt.y);
    
    
    CGPoint startPtInView = [modelView locationInView:startPt];
    CGPoint endPtInView = [modelView locationInView:endPt];
    
    CGContextSetStrokeColorWithColor(gc, [_color CGColor]);
    CGContextSetLineWidth(gc, _width);    
    
    CGContextSetLineDash(gc, 0, _dash, _dashCount);

    CGContextMoveToPoint(gc, startPtInView.x, startPtInView.y);
    CGContextAddLineToPoint(gc, endPtInView.x , endPtInView.y);
    CGContextStrokePath(gc);
    CGContextSetLineDash(gc, 0, 0, 0);
    
    if(area>=1)
    {
        NSString *temp = [NSString stringWithFormat:@"%d sq ft", (int)area];
        CGPoint point = CGPointMake(endPt.x + 10, texty);
        [self drawTextAtLoc:temp location:point fontSize:0 maxWidth:textWidth*modelView.scale];
    }
    return pt;
}
// Draw one line and move the "cursor" to next line
// Draw one line and move the "cursor" to next line
-(CGPoint)drawTextAtLoc:(NSString *)text location:(CGPoint)loc fontSize:(CGFloat)fontSize maxWidth:(int)maxWidth
{
    NSString *fontName = @"Helvetica";
    DVModelView *modelView = [DVModelView instance];
    CGPoint locInView = [modelView locationInView:loc];
    if(fontSize==0)
        fontSize = 19.0;    // Default size
    
    if(maxWidth==0)
        maxWidth = 10000;
    CGFloat fontHeight = fontSize + 5;
    CGRect rect = CGRectMake(locInView.x, locInView.y, maxWidth, fontHeight*modelView.scale);
    [Helper drawTextInRect:text fontName:fontName fontSize:fontSize* modelView.scale minimumFontSize:10.0*modelView.scale destRect:rect textAlign:NSTextAlignmentLeft];
    
    return CGPointMake(loc.x, loc.y + fontHeight);
}
-(void)dealloc
{
    _shapes = nil;
    _name = nil;
    _color = nil;
    self.name = nil;
    self.dash = nil;
    self.color = nil;
    self.shapes = nil;
}
@end
