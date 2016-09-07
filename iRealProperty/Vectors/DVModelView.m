// The model contains the list of all the layers. It manages the order of the layers, scale, etc.

#import "DVModelView.h"
#import "MathHelper.h"
#import "DVLabel.h"
#import "DVKeyboard.h"
#import "XMLReader.h"
#import "ColorPicker.h"
#import "Helper.h"
#import "RealPropInfo.h"
#import "RealPropertyApp.h"

static  DVModelView *defaultModelView;
//2/18/14 cv from Regis
static   int *xPoints;
static  int *yPoints;
static  int numPoint;
static  BOOL hasCurves;
static  int maxPoints;

void ExtractPoints (void *info, const CGPathElement *element);

@implementation DVModelView

@synthesize scale = _scale;
@synthesize activeLayer = _activeLayer;
@synthesize offset = _offset;
@synthesize constrainLength = _constrainLength;
@synthesize gridVisible;
@synthesize backgroundImage;
@synthesize imageVisible;
@synthesize crossPoint = _crossPoint;
@synthesize activePoint = _activePoint;
@synthesize pointsPerUnit = _pointsPerUnit;
@synthesize hideDiagonal = _hideDiagonal;
@synthesize currentTool = _currentTool;
@synthesize layers = _layers;
@synthesize hideCross;
@synthesize imageScale = _imageScale;
@synthesize imageOffset = _imageOffset;
@synthesize crossMode;
@synthesize activeShape;
@synthesize sheetSize = _sheetSize;
@synthesize path;
@synthesize showLegend = _showLegend;
@synthesize realPropInfo = _realPropInfo;
@synthesize intersectSegment = _intersectSegment;
@synthesize modelLegend;
@synthesize alignToGrid = _alignToGrid;

void notice(const char *fmt,...);
void log_and_exit(const char *fmt,...);


+(DVModelView *)DefaultModel:(CGRect)frame
{
    // Create a default model view
    DVModelView *dv = [[DVModelView alloc]initWithFrame:frame];
    
    return dv;
}
+(DVModelView *)instance
{
    return defaultModelView;
}
// Default constructor
-(id)init
{
    self = [super init];
    if(self)
    {
        [self setupDefaultValues];
    }
    return self;
    
}
-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        [self setupDefaultValues];
        
    }
    return self;
}
//
// All the default values in this constructor
-(void)setupDefaultValues
{
    defaultModelView = self;
    _alignToGrid = YES;
    _model = DVModelImperial;
    _measure = DVMeasureFoot;

    _pointsPerUnit = 10.0;  // i.e. 10 pixels for each foot
    
    _pointPerSquare = 10;   // space between each line
    _sheetSize = CGSizeMake(300, 300);  // size by unit
    _extraBlocks = 10;
    _lineWidth = 1.0;
    _extraLineWidth = 1.0;
    
    _backgroundColor = [DVModelView  UIColorFromRGB255:255 green:255 blue:255];
    _lineColor = [DVModelView  UIColorFromRGB255:233 green:233 blue:233];
    _extraColor = [DVModelView UIColorFromRGB255:200 green:200 blue:200];
    _activePointColor = [DVModelView UIColorFromRGB255:0 green:255 blue:0];
    
    _scale = 1.0;
    
    _layers = [[NSMutableArray alloc]init];
    
    // Create the top layer reserved for any special tool (i.e. cross hair drawing)
    _toolLayer = [[DVLayer alloc]initWithName:@"_Tools"];
    [_layers addObject:_toolLayer];
    
    
    // Load the default configuration
    // Load the XML file
    NSError *error;
    NSDictionary *xmlDict = [XMLReader dictionaryForURL:@"CADLayers" error:&error];
    id dict = [xmlDict objectForKey:@"CADLayers"];
    
    id array = [dict objectForKey:@"Layer"];
    _activeLayer = nil;
    for(NSDictionary *object in array)
    {
        NSString *name = [object objectForKey:@"@name"];
        CGFloat width = [[object objectForKey:@"@width"]floatValue];
        NSString *dash = [object objectForKey:@"@dash"];
        UIColor *color = [UIColor colorWithString:[object objectForKey:@"@color"]];
        NSString *defaultVal = [object objectForKey:@"@default"];
        
        NSArray *dashValue = [dash componentsSeparatedByString:@","];
        CGFloat dashes[16];
    
        int dashCount = [dashValue count];
        for(int i=0;i<dashCount && i<10;i++)
            dashes[i] = [[dashValue objectAtIndex:i]floatValue];
        
        DVLayer *layer = [[DVLayer alloc]initWithName:name lineWidth:width lineColor:color dashTable:dashes dashCount:dashCount];
        [_layers addObject:layer];
        if(defaultVal!=nil && [defaultVal caseInsensitiveCompare:@"yes"]==NSOrderedSame)
            _activeLayer = layer;
    }
    if(_activeLayer==nil)
        _activeLayer = [array objectAtIndex:0];
    _activeLayer.isDefault = YES;
    _constrainAngle = 15.0;  // increment of 1.0 degree
    _constrainLength = 1.0;         // Every line has to be aligned by on 1 foot
    
    backgroundImage = nil;
    gridVisible = YES;
    imageVisible = NO;
    
    CGRect frame = self.frame;
    _offset = CGSizeMake((_sheetSize.width*_pointsPerUnit-frame.size.width)/2,
                         (_sheetSize.height*_pointsPerUnit-frame.size.height)/2);
    
    _imageScale = 1.0;
    _imageOffset = CGPointZero;

    _crossPoint = CGPointMake( _sheetSize.width * _pointsPerUnit /2,
                              _sheetSize.height * _pointsPerUnit /2);

    _activePoint = _crossPoint;
    
    _showLegend = NO;
    
    // Create the legend object
    CGPoint point = CGPointMake(10, 80);
    
    modelLegend = [[DVLegend alloc]initWithPoint:[self locationInModel:point]];
    modelLegend.delegate = self;

}
//
// Recreate a full model - Return an error
//
-(BOOL)openModel:(NSData *)fileData error:(NSError **)error
{
    // Recreate the list of layers
    _layers = [[NSMutableArray alloc]init];
    // Create the top layer reserved for any special tool (i.e. cross hair drawing)
    _toolLayer = [[DVLayer alloc]initWithName:@"_Tools"];
    [_layers addObject:_toolLayer];
        
    // Create the dictionary
    NSDictionary *xmlDict = [XMLReader dictionaryForXMLData:fileData error:nil];
    if(xmlDict==nil)
    {
        if(error!=nil)
            *error = [NSError errorWithDomain:@"CADRealProperty" code:0 userInfo:nil];
        return NO;
    }
    
    id dict = [xmlDict objectForKey:@"CADiRealProperty"];
    // 3/19/13 HNN added version 1.1; not sure why we are checking version here
    CGFloat version = [[dict objectForKey:@"@version"] floatValue];
    if(version!=1.0)
    {
        if(error!=nil)
            *error = [NSError errorWithDomain:@"CADRealProperty" code:1 userInfo:nil];
        return NO;
//        
    }
    // 2/18/14 cv from Regis -->uncommented back upper lines.
    
    // Get the legend
    id legend = [dict objectForKey:@"Legend"];
    if(legend==nil)
        legend = [dict objectForKey:@"legend"];
    if(legend!=nil)
    {
        NSString *name = [legend objectForKey:@"@visible"];
        NSString *location = [legend objectForKey:@"@loc"];
        
        if([name caseInsensitiveCompare:@"YES"]==NSOrderedSame)
            _showLegend = YES;
        else
            _showLegend = NO;
        modelLegend.location = CGPointFromString(location);
        
    }
    
    // Get the layers
    id object = [dict objectForKey:@"Layer"];
    
    NSArray *layers;
    if([object isKindOfClass:[NSDictionary class]])
    {
        layers = [[NSArray alloc]initWithObjects:object, nil];
    }
    else if([object isKindOfClass:[NSArray class]])
    {
        layers = object;
    }
    else
    {
        NSLog(@"Error!");
        return NO;
    }
    _activeLayer = nil;
    // Read the layers
    for(id layer in layers)
    {
        NSString *name = [layer objectForKey:@"@name"];
        CGFloat width = [[layer objectForKey:@"@width"]floatValue];
        NSString *dash = [layer objectForKey:@"@dash"];
        UIColor *color = [UIColor colorWithString:[layer objectForKey:@"@color"]];
        NSString *defaultVal = [layer objectForKey:@"@default"];
        CGFloat area = [[layer objectForKey:@"@area"]floatValue];
        
        NSArray *dashValue = [dash componentsSeparatedByString:@","];
        CGFloat dashes[16];
        
        int dashCount = [dashValue count];
        for(int i=0;i<dashCount && i<10;i++)
            dashes[i] = [[dashValue objectAtIndex:i]floatValue];
        
        DVLayer *newLayer = [[DVLayer alloc]initWithName:name lineWidth:width lineColor:color dashTable:dashes dashCount:dashCount];
        [_layers addObject:newLayer];
        [modelLegend newArea:name area:area];
        if(defaultVal!=nil && [defaultVal caseInsensitiveCompare:@"yes"]==NSOrderedSame)
            _activeLayer = newLayer;
        // Now look for the different shapes
        id object = [layer objectForKey:@"shape"];
        NSArray *shapes;
        
        if([object isKindOfClass:[NSDictionary class]])
        {
            shapes = [[NSArray alloc]initWithObjects:object, nil];
        }
        else if([object isKindOfClass:[NSArray class]])
        {
            shapes = object;
        } 
        else
            continue;
        for(id shape in shapes)
        {
            DVShape *newShape = nil;
            NSString *type = [shape objectForKey:@"@type"];
            CGPoint startPoint = CGPointFromString([shape objectForKey:@"@start"]);
            CGPoint endPoint = CGPointFromString([shape objectForKey:@"@end"]);
            CGPoint center = CGPointFromString([shape objectForKey:@"@center"]);
            CGFloat radius = [[shape objectForKey:@"@radius"]floatValue];
            CGFloat startAngle = [[shape objectForKey:@"@startAngle"]floatValue];
            CGFloat endAngle = [[shape objectForKey:@"@endAngle"]floatValue];
            CGRect frame = CGRectFromString([shape objectForKey:@"@frame"]);
            NSString *label = [shape objectForKey:@"@label"];
            
            CGFloat offset = [[shape objectForKey:@"@lblOffset"]floatValue];
            BOOL hidden = [[shape objectForKey:@"@lblHidden"]boolValue];
            
            if([type caseInsensitiveCompare:@"line"]==NSOrderedSame)
                newShape = [[DVShapeLine alloc]initLine:startPoint to:endPoint];
            else if([type caseInsensitiveCompare:@"arc"]==NSOrderedSame)
                newShape = [[DVShapeArc alloc]initArc:center radius:radius startAngle:startAngle endAngle:endAngle];
            else if([type caseInsensitiveCompare:@"text"]==NSOrderedSame)
            {
                newShape = [[DVShapeText alloc]initWithFrame:frame];
                ((DVShapeText *)newShape).text = label;
            }
            else 
                continue;
            
            newShape.delegate = self;
            newShape.label.offset = offset;
            newShape.label.hidden = hidden;
            [newLayer addShape:newShape];
        }
    }
    if(_activeLayer==nil)
        _activeLayer = [_layers objectAtIndex:0];
    _activeLayer.isDefault = YES;
    return YES;
}

#pragma mark - Properties
- (void)setScale:(CGFloat)scale
{
    _scale = scale;
    [self setNeedsDisplay];
}
-(void)setDeltaOffset:(CGSize)deltaOffset
{
    _offset.width -= deltaOffset.width;
    if(_offset.width<0)
        _offset.width = 0;
    
    _offset.height -= deltaOffset.height;
    if(_offset.height <0)
        _offset.height = 0;

    [self setNeedsDisplay];
}
#pragma mark - draw self
- (void)drawRect:(CGRect)rect
{
    [self drawModel];
}
//
// Draw the entire model in the current context
//
-(void)drawModel
{
    CGContextRef gc = UIGraphicsGetCurrentContext();
    
    // Clean up background
    CGContextSetFillColor(gc, CGColorGetComponents([_backgroundColor CGColor]));
    CGContextFillRect(gc, self.frame);
    
    if(backgroundImage!=nil && imageVisible)
    {
        CGRect destRect = CGRectMake(- _imageOffset.x ,
                                     - _imageOffset.y , 
                                     self.frame.size.width * _imageScale,
                                     self.frame.size.height * _imageScale);
        [backgroundImage drawInRect:destRect];

    }
    
    if(gridVisible)
    {  
        CGContextSetAllowsAntialiasing(gc, NO); // Avoid anti aliasing on vertical and horizontal lines
        
        CGFloat increment = _pointPerSquare * _scale;
        
        // Draw horizontal lines
        CGContextSetStrokeColor(gc, CGColorGetComponents([_lineColor CGColor]));
        CGContextSetLineWidth(gc, _lineWidth);    

        for(int y=0;y<_sheetSize.height;y++)
        {
            CGFloat destY = (y*increment) - _offset.height;
            CGContextMoveToPoint(gc, 0, destY);
            CGContextAddLineToPoint(gc, _sheetSize.width * increment , destY);
        }
        
        // Draw vertical lines
        for(int x=0;x<_sheetSize.width;x++)
        {
            CGFloat destX = (x*increment) - _offset.width;
            CGContextMoveToPoint(gc, destX, 0);
            CGContextAddLineToPoint(gc, destX, _sheetSize.height * increment);
        }
        // Make the drawing visible
        CGContextStrokePath(gc);
        
        // Thick line
        // Draw horizontal lines
        CGContextSetStrokeColor(gc, CGColorGetComponents([_extraColor CGColor]));
        CGContextSetLineWidth(gc, _extraLineWidth);  

        for(int y=0;y<_sheetSize.height;y += _extraBlocks)
        {
            CGFloat destY = (y*increment) - _offset.height;
            CGContextMoveToPoint(gc, 0, destY);
            CGContextAddLineToPoint(gc, _sheetSize.width * increment , destY);
        }
        
        // Draw vertical lines
        for(int x=0;x<_sheetSize.width; x += _extraBlocks)
        {
            CGFloat destX = (x*increment) - _offset.width;
            CGContextMoveToPoint(gc, destX, 0);
            CGContextAddLineToPoint(gc, destX, _sheetSize.height * increment);
        }
        // Make the drawing visible
        CGContextStrokePath(gc);
        CGContextSetAllowsAntialiasing(gc, YES);
    }
    // Now draw each layer
    for(DVLayer *layer in _layers)
    {
        if(layer.hidden)
            continue;
        if(layer==_activeLayer)
            [layer drawLayer:gc scale:_scale offset:_offset transparency:1.0];
        else
            [layer drawLayer:gc scale:_scale offset:_offset transparency:0.5];
    }
    
    // Draw the cross air
    if(!hideCross)
    {
        int crossLength = (self.crossMode!=DVCrossSmall)?40:15;
        switch(self.crossMode)
        {
            case DVCrossBlue:
                CGContextSetStrokeColorWithColor(gc, [[UIColor blueColor]CGColor]);
                break;
            case DVCrossRed:
                CGContextSetStrokeColorWithColor(gc, [[UIColor redColor]CGColor]);
                break;
            case DVCrossSmall:
                CGContextSetStrokeColorWithColor(gc, [[UIColor blackColor]CGColor]);
               break;
        }
        CGContextSetLineDash(gc, 0, 0, 0);
        
        CGPoint dest = [self locationInView:_crossPoint];
        CGContextSetAllowsAntialiasing(gc, NO);
        CGContextSetLineWidth(gc, 1.0);
        CGContextMoveToPoint(gc, dest.x - crossLength, dest.y );
        CGContextAddLineToPoint(gc, dest.x + crossLength, dest.y);
        
        CGContextMoveToPoint(gc, dest.x, dest.y - crossLength);
        CGContextAddLineToPoint(gc, dest.x, dest.y + crossLength);
        
        CGContextStrokePath(gc);
    }
    CGContextSetAllowsAntialiasing(gc, YES);
#if 0
    CGContextSetFillColor(gc, CGColorGetComponents([_activePointColor CGColor]));
    CGContextFillRect(gc, _fingerRect);
#endif
    // Test code -- to be removed
    if(path!=nil)
    {
        CGRect rect = CGPathGetBoundingBox(path);
        CGAffineTransform matrix = CGAffineTransformMakeTranslation(-rect.origin.x, -rect.origin.y);
        CGPathRef newPath = CGPathCreateCopyByTransformingPath(path, &matrix);
        
        CGContextAddPath(gc, newPath);
        CGContextFillPath(gc);
        
        CGContextStrokePath(gc);
        
        CGPathRelease(path);
        CGPathRelease(newPath);
        path = nil;
    }
    if(_showLegend)
    {
        [modelLegend drawLegend:gc];
    }
}
//2/18/14 cv from Regis insert predefine processors if/endif
#if 0
//
// Calculate the area and returns it in local coordinates
//
-(CGFloat)calculateAreaFromPath
{
    // Get the boundary rectangle
    CGRect rect = CGPathGetBoundingBox(path);
    
    // Now measure how many points are inside/outside the area
    CGFloat count = 0;
    for(CGFloat y=0;y<rect.size.height;y++)
    {
        for(CGFloat x=0;x<rect.size.width;x++)
        {
            CGPoint point = CGPointMake(rect.origin.x + x, rect.origin.y + y);
            if(CGPathContainsPoint(path, nil, point, YES))
                count++;
        }
    }
    return count / (_pointsPerUnit*_pointsPerUnit);
}
#endif

//
// Return a point from the current drawView in the model coordinates
-(CGPoint)locationInModel:(CGPoint)pt
{
    CGPoint point;
    point.x = (pt.x + _offset.width) / _scale;
    point.y = (pt.y + _offset.height) / _scale;
    // NSLog(@"view %f %f to loc %f %f (scale=%f offset=%f %f)", pt.x, pt.y, point.x, point.y, _scale, _offset.width, _offset.height);

    return point;
}
//
// Return a point from the current the model coordinates to local view
-(CGPoint)locationInView:(CGPoint)pt
{
    CGPoint point;
    point.x = pt.x * _scale - _offset.width;
    point.y = pt.y * _scale - _offset.height;
    
    // NSLog(@"loc %f %f to view %f %f (scale=%f offset=%f %f)", pt.x, pt.y, point.x, point.y, _scale, _offset.width, _offset.height);
    
    
    return point;
}

#pragma mark - Handle the active point
+(UIColor *)UIColorFromRGB255: (int)red green:(int)green blue:(int)blue
{
    UIColor *color = [[UIColor alloc]initWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1.0];
    return color;
}
// Constrain the point -- the point is in model coordinate
-(CGPoint)constrainPoint:(CGPoint)pt
{
    if(_alignToGrid)
    {
        CGPoint point;
        point.x = rintf(pt.x / _pointsPerUnit) * _pointsPerUnit;
        point.y = rintf(pt.y / _pointsPerUnit) * _pointsPerUnit;
        return point;
    }
    return pt;
}
//
// Constrain the point -- the point is in model coordinate
-(CGPoint)constrainLine:(CGPoint)pt
{
#if 0
    // For a line, the segment must be a foot multiple
    // the angle with the start point must be one of the _constrainAngle 

    DVShapeLine *shape = (DVShapeLine *)_shape;
    int angle = [MathHelper angleToDegree:shape.start point:pt];
    
    int newAngle = ((angle + (_constrainAngle/2)) / _constrainAngle) * _constrainAngle;
    int distance = [MathHelper distanceBetweenPoints:shape.start pt2:pt];
    int newDistance = ((distance + (_constrainLength/2)) / _constrainLength) * _constrainLength;
    
    double a = ((double)newAngle * 2 * M_PI)/360.0;
    pt.x = cos(a) * newDistance + shape.start.x;
    pt.y = sin(a) * newDistance + shape.start.y;
#endif
    return pt;
}
-(CGPoint)constrainArc:(CGPoint)pt
{
    return pt;
#if 0
    // For an arc, the segment can be half the multiple (i.e 1/2 f)
    // the angle with the start point must be one of the _constrainAngle 

    DVShapeArc *shape = (DVShapeArc *)_shape;
    int angle = [MathHelper angleToDegree:shape.center point:pt];
    
    int newAngle = ((angle + (_constrainAngle/2)) / _constrainAngle) * _constrainAngle;

    int distance = [MathHelper distanceBetweenPoints:shape.center pt2:pt];
    
    int constrain = _constrainLength/2;
    int newDistance = ((distance + (constrain/2)) / constrain) * constrain;
    
    double a = ((double)newAngle * 2 * M_PI)/360.0;
    pt.x = cos(a) * newDistance + shape.center.x;
    pt.y = sin(a) * newDistance + shape.center.y;
#endif
    return pt;
}
// Angle is in radian
-(CGFloat)constrainAngle:(CGFloat)angle
{
    return angle;
    int newAngle = (angle * 180)/M_PI;
    newAngle = ((newAngle + (_constrainAngle/2)) / _constrainAngle) * _constrainAngle;
    double a = ((double)newAngle * 2 * M_PI)/360.0;
    
    return a;
}
//
// Return a segment that can be selected
// pt is in screen coordinates
-(DVShape *)findIntersectShape:(CGPoint)pt
{
    
    CGRect rect = CGRectMake(pt.x - (FINGER_WIDTH/2/_scale),
                             pt.y - (FINGER_WIDTH/2/_scale),
                             FINGER_WIDTH/_scale, FINGER_WIDTH/_scale);
    DVShape *shape = [_activeLayer intersectWithShape:rect];
    // _fingerRect = rect;
    // [self setNeedsDisplay];
    return shape;
}
//
// Return a point that matches an end point
// pt is in screen coordinates
-(int)findIntersectEndSegment:(CGPoint *)pt
{
    return [self findIntersectEndSegment:pt excludeShape:nil];
}
-(int)findIntersectEndSegment:(CGPoint *)pt excludeShape:(DVShape *)excludeShape
{
    CGPoint point = *pt;    
    CGRect rect = CGRectMake(point.x-((FINGER_WIDTH/2)/_scale),
                             point.y-((FINGER_WIDTH/2)/_scale), 
                             FINGER_WIDTH/_scale, FINGER_WIDTH/_scale);
    return [_activeLayer findIntersectEndSegment:rect outPoint:pt excludeShape:excludeShape];
}

// Mark all the shapes as selected or not
-(void)selectShapes:(BOOL)selected
{
    [_activeLayer selectShapes:(BOOL)selected];
}
// Delete selection
-(void)deleteSelected
{
    [_activeLayer deleteSelected];
}
// Return selection
-(NSArray *)getSelectedShapes
{
    return [_activeLayer getSelectedShapes];
}
#pragma mark - Handle the cross point
-(void)setCrossPoint:(CGPoint)point
{
    _crossPoint = point;

    [self drawToCrossPoint];
    [self setNeedsDisplay];
}
// Draw the right angle from the currentPoint to the cross-point
//
-(void)drawToCrossPoint
{
#define SMALL_OFFSET    10.0
    [_toolLayer deleteAll];
    
    if(_currentTool==kToolLine)
    {
        if(rintf(_crossPoint.x) != rintf(_activePoint.x) && rintf(_crossPoint.y) != rintf(_activePoint.y))
        {
            DVShapeLine *line;
            // Horizontal section
            line = [self addCrossDetail:_activePoint end:CGPointMake(_crossPoint.x, _activePoint.y)];
            line.label.text = [self shapeFloatToFeet:_crossPoint.x - _activePoint.x];
            // Vertical section
            line = [self addCrossDetail:CGPointMake(_crossPoint.x, _activePoint.y) end:CGPointMake(_crossPoint.x, _crossPoint.y)];
            line.label.text = [self shapeFloatToFeet:_crossPoint.y - _activePoint.y];
        }
        if(!_hideDiagonal)
        {
            DVShapeLine *line = [[DVShapeLine alloc]initLine:_activePoint to:_crossPoint];
            line.inheritLayer = NO;

            line.length = [MathHelper distanceBetweenPoints:_activePoint pt2:_crossPoint]/_pointsPerUnit;
            line.label.text = [self shapeFloatToFeet:line.length];
            line.color = [UIColor blueColor];
            line.label.textColor = line.color;
            line.label.fontSize = 14.0;
            line.label.offset = 10.0;    
            line.delegate = self;
            [_toolLayer addShape:line];
        }
    }
   
    else if(_currentTool==kToolArc)
    {
        CGPoint center = [MathHelper centerOfLine:_crossPoint end:_activePoint];
        CGFloat radius = [MathHelper distanceBetweenPoints:_activePoint pt2:_crossPoint]/2.0;
        
        if(self.hideDiagonal && [activeShape isKindOfClass:[DVShapeArc class]])
        {
            // Take the value from the current shape
            center = ((DVShapeArc *)activeShape).center;
            radius = ((DVShapeArc *)activeShape).radius;
        }
        
        if(radius > 20 && activeShape!=nil  && [activeShape isKindOfClass:[DVShapeArc class]])
        {
            [self drawArcAngles:(DVShapeArc *)activeShape clean:NO];
        
        }

        if(!_hideDiagonal)
        {
            // draw the circle
            DVShapeArc *arc = [[DVShapeArc alloc]initArc:center radius:radius];
            arc.delegate = self;            
            arc.startAngle = M_PI;
            arc.endAngle = 2*M_PI;
            arc.inheritLayer = NO;
            arc.color = [UIColor blueColor];
  

            [_toolLayer addShape:arc];
        }
    }
    else if(_currentTool==kToolText)
    {
        DVShapeText *text = [[DVShapeText alloc]initWithFrame:CGRectMake(_activePoint.x, _activePoint.y, _crossPoint.x-_activePoint.x, _crossPoint.y-_activePoint.y)];
        text.backColor = [UIColor whiteColor];
        text.delegate = self;
        text.text = @"";
        [_toolLayer addShape:text];
    }
}
-(void)drawArcAngles:(DVShapeArc *)arc clean:(BOOL)clean
{
    if(clean)
        [_toolLayer deleteAll];

    if(arc.radius > 20)
    {
        DVShapeLine *line;
        CGPoint destPt = [MathHelper circlePoint:arc.center radius:arc.radius angle:arc.startAngle];
        // First angle
        line = [self addCrossDetail:arc.center end:destPt];
        line.label.text = [NSString stringWithFormat:@"%d%c",[MathHelper angleToDegreeReversed:arc.startAngle],161];
        // Second angle
        destPt = [MathHelper circlePoint:arc.center radius:arc.radius angle:arc.endAngle];
        line = [self addCrossDetail:arc.center end:destPt];
        line.label.text = [NSString stringWithFormat:@"%d%c", [MathHelper angleToDegreeReversed:((DVShapeArc *)activeShape).endAngle],161];
    }
}
-(DVShapeLine *)addCrossDetail:(CGPoint)start end:(CGPoint)end
{
    DVShapeLine *line = [[DVShapeLine alloc]initLine:start to:end withDash:2.0];
    line.inheritLayer = NO;
    // Add line information

    line.color = [UIColor redColor];
    line.width = 0.5;
    line.delegate = self;    
    // Create label

    line.label.hidden = NO;
    line.label.fontSize = 10.0;
    line.label.offset = 5.0;
    line.label.textColor = line.color;
    // add it to the line
    [_toolLayer addShape:line];
    
    return line;
}
#pragma mark - Utilities
-(void)addShape:(DVShape *)shape
{
    shape.delegate = self;
    [_activeLayer addShape:shape];
    [self setNeedsDisplay];
}
-(NSString *)description
{
    NSString *str = @"";
    for(DVLayer *layer in _layers)
    {
        str = [str stringByAppendingString:[layer description]];
    }
    return str;
}
#pragma mark - ShapeDelegate
-(void)shapeDisplayInfo:(NSString *)info
{
}
-(CGPoint)shapeGetPointInScreenCoordinates:(CGPoint)pt
{
    return [self locationInView:pt];
}
-(CGRect)shapeGetRectInScreenCoordinates:(CGRect)rect
{
    CGPoint origin = [self locationInView:rect.origin];
    return CGRectMake(origin.x, origin.y, rect.size.width * _scale, rect.size.height *_scale);
}
-(int)shapePixelPerUnit
{
    return _pointsPerUnit;
}
// Return the length of a shape expressed in feet/inches
-(NSString *)shapeFloatToFeet:(CGFloat)length
{
    length = ABS(length/_pointsPerUnit);
    int feet = length;
    CGFloat delta = ABS(length - feet);
    int inches = 0;
    if(delta > 0.05)
        inches = rintf(ABS(((CGFloat)length-feet)*12.0));
    if(inches==12)
    {
        inches = 0;
        feet++;
    }
    if(inches==0)
        return [NSString stringWithFormat:@"%d'", feet];
    else
        return [NSString stringWithFormat:@"%d' %d\"", feet, inches];
}
-(CGFloat)shapeGetScale
{
    return _scale;
}
// Return the model in XML
-(NSString *)modelToXML
{
    // 3/19/13 HNN change cad version to 1.1 so that I know that anything created with
    // cad version 1.0 may have contain & rather then &amp;
    // cad version 1.1 will convert & to &amp;
//    NSString *xml = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<CADiRealProperty version=\"1.1\">";
    
    // 2/18/2014 cv from Regis
    NSString *xml = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<CADiRealProperty version=\"1.0\">";

    xml = [xml stringByAppendingFormat:@"\n%@\n", [self legendToXml]];
    
    for(DVLayer *layer in _layers)
    {
        if([layer.name isEqualToString:@"_Tools"])
            continue;
        CGFloat area = [modelLegend area:layer.name];
        xml = [NSString stringWithFormat:@"%@%@\t</Layer>\n",xml, [layer getLayerXML:layer==_activeLayer area:area  ]];

    }
    xml = [xml stringByAppendingString:@"</CADiRealProperty>"];

    return xml;
}
-(void)flipModel:(BOOL)vertical
{
    CGRect rect = CGRectZero;
    // get the largest rectangle
    for(DVLayer *layer in _layers)
    {
        CGRect frameRect = [layer getLayerFrame];
        if(CGRectEqualToRect(frameRect, CGRectZero))
            continue;
        if(CGRectEqualToRect(rect, CGRectZero))
            rect = frameRect;
        else
            rect = CGRectUnion(rect, frameRect);
    }
    if(CGRectEqualToRect(rect, CGRectZero))
        return;
    // Calculate the center
    CGPoint center = rect.origin;
    center.x += rect.size.width / 2.0;
    center.y += rect.size.height / 2.0;
    for(DVLayer *layer in _layers)
    {
        [layer flipVertical:vertical aroundPoint:center];
    }
        [self setNeedsDisplay];
}
// This function createa a PNG image that includes the all the images
// border is the number of pixes to include in the final image
-(NSData *)createImageFromModel:(CGFloat )border
{
    // Get the largest rectangle that includes all the drawing
    CGRect frameRect = CGRectZero;
    for(DVLayer *layer in _layers)
    {
        if([layer.name isEqualToString:@"_Tools"])
            continue;
        if(layer.hidden)
            continue;
        CGRect layerFrame = [layer getLayerFrame];
        if(CGRectEqualToRect(layerFrame, CGRectZero))
            continue;
        if(CGRectEqualToRect(frameRect, CGRectZero))
            frameRect = layerFrame;
        else
            frameRect = CGRectUnion(frameRect, [layer getLayerFrame]);
    }
    // Add the legend
    if(self.showLegend)
        frameRect = CGRectUnion(frameRect, modelLegend.frame);
    
    
    frameRect = CGRectInset(frameRect, -border, -border);
    
    CGSize offset = CGSizeMake(frameRect.origin.x , frameRect.origin.y );
    
	UIGraphicsBeginImageContext( frameRect.size );
	CGContextRef gc = UIGraphicsGetCurrentContext();
	
    // Clear the entire background with white
    CGContextSetFillColorWithColor(gc, [[UIColor whiteColor] CGColor]);
    CGRect rect = CGRectMake(0, 0, frameRect.size.width, frameRect.size.height);
    CGContextFillRect(gc, rect);
    
    CGFloat originalScale = _scale;
    CGSize originalOffset = offset;
    
    for(DVLayer *layer in _layers)
    {
        if([layer.name isEqualToString:@"_Tools"])
            continue;
        if(layer.hidden)
            continue;
        _scale = 1.0;
        _offset = offset;
        [layer drawLayer:gc scale:1.0 offset:offset transparency:1.0 showSelect:NO];
    }
    if(self.showLegend)
        [modelLegend drawLegend:gc];
    
    _scale = originalScale;
    _offset = originalOffset;
        
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    
    // Create a PNG image
    NSData* pngdata = UIImagePNGRepresentation (image); //PNG wrap 
	UIGraphicsPopContext();
    return pngdata;
}
-(void)setCurrentTool:(int)tool
{
    _currentTool = tool;
}
-(void)setHideDiagonal:(BOOL)value
{
    _hideDiagonal = value;
}
-(NSString *)legendToXml
{
    return [NSString stringWithFormat:@"<Legend visible=\"%@\" loc=\"%@\" textWidth=\"130\" lineWidth=\"130\" />", self.showLegend?@"YES":@"NO", NSStringFromCGPoint(modelLegend.frame.origin)];
}
#pragma mark - Legen management
-(NSString *)DVLegendGetParcel
{
    return [NSString stringWithFormat:@"%@-%@", _realPropInfo.major, _realPropInfo.minor];
}
-(NSArray *)DVLegendGetLayers
{
    return _layers;
}
-(CGFloat)DVLegendGetScale
{
    return _scale;
}

//2/18/14 cv from Regis
-(void)dealloc
{
    _backgroundColor = nil;
    _lineColor = nil;
    _extraColor = nil;
    _activePointColor = nil;
    
    _layers = nil;
    _activeLayer = nil;
    _toolLayer = nil;
    
    self.activeLayer = nil;
    self.backgroundImage = nil;
    self.activeShape = nil;
    self.layers = nil;
    self.realPropInfo = nil;
    self.modelLegend = nil;
    
    if(self.path)
        CGPathRelease(self.path);
    self.path = nil;
}
#pragma mark - Eagleview Technologies - Feb 2014

-(CGPathRef)scalePath:(CGPathRef)aPath scaleFactor:(CGFloat)scaleFactor lineWidth:(CGFloat)lineWidth
{
    // Scaling the path ...
    CGAffineTransform scaleTransform = CGAffineTransformIdentity;
    // Scale down the path first
    scaleTransform = CGAffineTransformScale(scaleTransform, scaleFactor, scaleFactor);
    
    
    CGPathRef scaledPath = CGPathCreateCopyByTransformingPath(aPath, &scaleTransform);
    // Reduce the stroke path
    CGPathRef thinPath = CGPathCreateCopyByStrokingPath(scaledPath, nil, lineWidth, kCGLineCapButt, kCGLineJoinMiter, 0);
    return thinPath;
}
void ExtractPoints (void *info, const CGPathElement *element)
{
    CGPoint pt = *(element->points);
    switch(element->type)
    {
        case kCGPathElementMoveToPoint:
            xPoints[numPoint] = pt.x;
            yPoints[numPoint] = pt.y;
            if(numPoint<maxPoints)
                numPoint++;
            break;
        case kCGPathElementAddLineToPoint:
            xPoints[numPoint] = pt.x;
            yPoints[numPoint] = pt.y;
            if(numPoint<maxPoints)
                numPoint++;
            break;
        case kCGPathElementAddQuadCurveToPoint:
            hasCurves = YES;
            break;
        case kCGPathElementAddCurveToPoint:
            hasCurves = YES;
            break;
        case kCGPathElementCloseSubpath:
            break;
    }
}
-(CGFloat)calculateAreaFromPath
{
    CGRect boundingBox = CGPathGetBoundingBox(path);
    UIGraphicsBeginImageContext(boundingBox.size);
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformTranslate(transform, -boundingBox.origin.x, -boundingBox.origin.y);
    CGPathRef localPath = CGPathCreateCopyByTransformingPath(path, &transform);
    
    maxPoints = 1000;
    hasCurves = NO;
    numPoint = 0;
    xPoints = malloc(sizeof(int)*maxPoints);
    yPoints = malloc(sizeof(int)*maxPoints);
    
    CGPathApply(localPath, nil, ExtractPoints);
    
    if(hasCurves)
    {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, [[UIColor blackColor]CGColor]);
        CGRect rect = CGRectMake(0, 0, boundingBox.size.width, boundingBox.size.height);
        CGContextFillRect(context, rect);
        
        CGContextSetFillColorWithColor(context, [[UIColor whiteColor]CGColor]);
        
        CGContextBeginPath(context);
        CGContextAddPath(context, localPath);
        CGContextFillPath(context);
        
        UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
        
        CFDataRef pixelData = CGDataProviderCopyData(CGImageGetDataProvider(img.CGImage));
        const UInt8* data = CFDataGetBytePtr(pixelData);
        
        // Check the pixel color
        double count = 0;
        for(int y=0;y<boundingBox.size.height;y++)
        {
            for(int x=0;x<boundingBox.size.width;x++)
            {
                int pixelInfo = ((img.size.width  * y) + x ) * 4;
                UInt8 red = data[pixelInfo];
                if(red)
                    count++;
            }
        }
        
        // end context
        UIGraphicsEndImageContext();
        img = nil;
        return count / (_pointsPerUnit * _pointsPerUnit);
    }
    CGFloat a = [self polygonArea:xPoints y:yPoints numPoints:numPoint-1];
    a = fabsf(a);
    a = a / (_pointsPerUnit*_pointsPerUnit);
    return a;
}
- (UIColor *)colorAtPixelX:(int)x Y:(int)y image:(UIImage *)img
{
    
    CFDataRef pixelData = CGDataProviderCopyData(CGImageGetDataProvider(img.CGImage));
    const UInt8* data = CFDataGetBytePtr(pixelData);
    
    int pixelInfo = ((img.size.width  * y) + x ) * 4;
    
    UInt8 red = data[pixelInfo];
    UInt8 green = data[(pixelInfo + 1)];
    UInt8 blue = data[pixelInfo + 2];
    UInt8 alpha = data[pixelInfo + 3];
    CFRelease(pixelData);
    
    UIColor *col = [UIColor colorWithRed:(red/255.0f) green:(green/255.0f) blue:(blue/255.0f) alpha:(alpha/255.0f)];
    
    return col;
    
}
-(CGFloat)polygonArea:(int *)X y:(int *)Y numPoints:(int)numPoints
{
    CGFloat area = 0;
    int j = numPoints-1;
    
    for (int i=0; i<numPoints; i++)
    {
        area = area +  (X[j]+X[i]) * (Y[j]-Y[i]);
        j = i;
    }
    return area/2;
}

@end




