
#import "DrawContent.h"
#import "IRNote.h"
#import "IRLine.h"
#import "AxDataManager.h"
#import "ColorPicker.h"
#import "BaseNote.h"

@implementation Line

@synthesize lineColor, lineWidth, path, pathData;
- (id)init
{
    self = [super init];
    if(self)
    {
        self.path = CGPathCreateMutable();
    }
    return self;
}

-(void) moveToPoint:(CGPoint)pt
{
    CGPathMoveToPoint(path, NULL, pt.x, pt.y);
}
-(void) lineToPoint:(CGPoint)pt
{
    CGPathAddLineToPoint(path, NULL, pt.x, pt.y);
}
-(void)dealloc
{
    if(self.path!=nil)
        CGPathRelease(self.path);
}
#pragma mark - Handle the file format


- (NSData *)savePathToData
{
    pathData = [[NSMutableData alloc]init];
	// Convert path to an array
	CGPathApply(path, (__bridge void *)pathData, saveApplier);
	return pathData;
}

static void saveApplier(void* info, const CGPathElement* element)
{
	NSMutableData* pathData = (__bridge NSMutableData*) info;
    
	int nPoints;
	switch (element->type)
	{
		case kCGPathElementMoveToPoint:
			nPoints = 1;
			break;
		case kCGPathElementAddLineToPoint:
			nPoints = 1;
			break;
		case kCGPathElementAddQuadCurveToPoint:
			nPoints = 2;
			break;
		case kCGPathElementAddCurveToPoint:
			nPoints = 3;
			break;
		case kCGPathElementCloseSubpath:
			nPoints = 0;
			break;
		default:
			return;
	}
    int type = element->type;
	NSData* points = [NSData dataWithBytes:element->points length:nPoints*sizeof(CGPoint)];
    [pathData appendBytes:&type length:sizeof(type)];
    [pathData appendData:points];
}
- (void)loadFromPathData:(NSData *)data
{
    int type;
    CGPoint points[4];
    
    
    
	// Recreate (and store) path
	path = CGPathCreateMutable();
    
    int loc = 0;
    while(loc+sizeof(int)<[data length])
    {
        // Get the type
        [data getBytes:&type range:NSMakeRange(loc, sizeof(type))];
        loc += sizeof(type);
        
        switch (type)
        {
            case kCGPathElementMoveToPoint:
                [data getBytes:&points range:NSMakeRange(loc, sizeof(CGPoint))];
                CGPathMoveToPoint(path, NULL, points[0].x, points[0].y);
                loc += sizeof(CGPoint);
                break;
            case kCGPathElementAddLineToPoint:
                [data getBytes:&points range:NSMakeRange(loc, sizeof(CGPoint))];
                CGPathAddLineToPoint(path, NULL, points[0].x, points[0].y);
                loc += sizeof(CGPoint);
                break;
            case kCGPathElementAddQuadCurveToPoint:
                [data getBytes:&points range:NSMakeRange(loc, 2*sizeof(CGPoint))];
                CGPathAddQuadCurveToPoint(path, NULL, points[0].x, points[0].y, points[1].x, points[1].y);
                loc += 2*sizeof(CGPoint);
                break;
            case kCGPathElementAddCurveToPoint:
                [data getBytes:&points  range:NSMakeRange(loc, 3*sizeof(CGPoint))];
                CGPathAddCurveToPoint(path, NULL, points[0].x, points[0].y, points[1].x, points[1].y, points[2].x, points[2].y);
                loc += 3*sizeof(CGPoint);
                break;
            case kCGPathElementCloseSubpath:
                CGPathCloseSubpath(path);
                break;
            default:
                return;
        }
    }
}

@end

@implementation DrawContent

@synthesize lines, itsBaseNote;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
//
// Reload the all data from the lines
//
-(void)loadLines:(NSSet *)lineSet
{
    NSEnumerator *enumerator = [lineSet objectEnumerator];
    id value;
    
    lines = [[NSMutableArray alloc]initWithCapacity:[lineSet count]];
    
    while ((value = [enumerator nextObject])) 
    {
        // enumurate through the different Lines
        IRLine *irline = value;
        Line *line = [[Line alloc]init];
        
        [line loadFromPathData:irline.line];
        line.lineWidth = irline.width;
        line.lineColor = [UIColor colorWithString:irline.color];
        
        [lines addObject:line];
    }
    
}// draw the background for the hand drawing
-(void)drawBackground:(CGRect)rect
{
    CGContextRef gc = UIGraphicsGetCurrentContext();

    CGFloat backgroundColor[4] = { 253.0/255.0, 246.0/255.0, 164.0/255.0, 1.0 };
    CGContextSetFillColor(gc, backgroundColor);
    CGContextFillRect(gc, rect);
    
    CGFloat spacer = 22.0;
    
    CGContextSetAllowsAntialiasing(gc, NO); // Avoid anti aliasing on vertical and horizontal lines
    
    CGFloat lineColor[4] = { 250/255.0, 175/255.0, 175/255.0, 1.0 };
    CGContextSetStrokeColor(gc, lineColor);
    CGContextSetLineWidth(gc, 1.0);
    
    // Draw horizontal lines        
    for(int y=1;y<rect.size.height;y+=spacer)
    {
        CGContextMoveToPoint(gc, 0, y);
        CGContextAddLineToPoint(gc, rect.size.width, y);
        
    }
    CGContextStrokePath(gc);
    // Draw vertical lines
    CGFloat verticalColor[4] = { 250.0/255.0, 175/255.0, 175/255.0, 1.0 };
    CGContextSetStrokeColor(gc, verticalColor);

    for(int x = 0;x<rect.size.width;x+=spacer)
    {
        CGContextMoveToPoint(gc, x, 0);
        CGContextAddLineToPoint(gc, x, rect.size.height);        
    }
    // Make the drawing visible
    CGContextStrokePath(gc);

}
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    // turn on aliasing to smooth drawing
    CGContextSetAllowsAntialiasing(context, YES);
    
    // clean background
    [self drawBackground:self.frame];
    
    // draw each path
    for(Line *line in lines)
    {
        [self drawLine:line inContext:context];
    }
    if(_line)
        [self drawLine:_line inContext:context];
}
- (void)drawLine:(Line *)line inContext:(CGContextRef)context
{
    CGContextSetStrokeColorWithColor(context, line.lineColor.CGColor);
    CGContextSetLineWidth(context, line.lineWidth);
    CGContextAddPath(context, line.path);
    CGContextStrokePath(context);    
}
#pragma mark - Touch handling
-(void)eraseAroundPoint:(CGPoint)point
{
    NSMutableArray *linesToDelete = [[NSMutableArray alloc]initWithCapacity:lines.count];

    // Look for the lines that interset with that 
    for(Line *line in lines)
    {
        CGRect lineRect = CGPathGetBoundingBox(line.path);
        
        if(CGPathContainsPoint(line.path, nil, point, true))
        {
            [linesToDelete addObject:line];
            lineRect = CGRectInset(lineRect, -5.0, -5.0);
            [self setNeedsDisplayInRect:lineRect];
        }
    }
    
    for(Line *line in linesToDelete)
    {
        [lines removeObject:line];
        // Remove the line
        CGPathRelease(line.path);
        line.path = nil;
    }
    [linesToDelete removeAllObjects];
    linesToDelete = nil;
    
}
// Touch begins -- save the current point as the reference point
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(itsBaseNote.drawMode!=kBtnEraser)
    {
        _line = [[Line alloc]init];
        // Default color
        if(itsBaseNote.drawMode == kBtnBluePen)
            _line.lineColor = [UIColor blueColor];
        else if(itsBaseNote.drawMode == kBtnRedPen)
            _line.lineColor = [UIColor redColor];
        else {
            _line.lineColor = [UIColor blackColor];
        }
        _line.lineWidth = 1.0;
    }
    
    UITouch *aTouch = [touches anyObject];
    _currentPoint = [aTouch locationInView: self];
    if(itsBaseNote.drawMode!=kBtnEraser)
        [_line moveToPoint:_currentPoint];
    else
        [self eraseAroundPoint:_currentPoint];
    
}
// Abort any drawing
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    _line = nil;
}
// Done with the current segment -- save it to the list of segments
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(itsBaseNote.drawMode==kBtnEraser)
        return;
    // Add the complete path in the list of paths
    if(self.lines==nil)
        self.lines = [[NSMutableArray alloc]initWithCapacity:10];
    [self.lines addObject:_line];
    
    [self setNeedsDisplay];
}
// Still touching and moving.
-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *aTouch = [touches anyObject];
    _currentPoint = [aTouch locationInView: self];
    
    if(itsBaseNote.drawMode==kBtnEraser)
        [self eraseAroundPoint:_currentPoint];
    else
        [_line lineToPoint:_currentPoint];
    
    // Refresh that rect only
    CGRect rect = CGPathGetBoundingBox(_line.path);
    rect = CGRectInset(rect, -2.0, -2.0);
    [self setNeedsDisplayInRect:rect];
    //[self setNeedsDisplay];
}
#pragma mark - File handling
-(void)saveLinesTo:(IRNote *)note
{
    // Remove all the lines
    [note removeIRLine:note.iRLine];
    
    for(Line *line in lines)
    {
        NSData *data = [line savePathToData];
        if(data!=nil)
        {
            IRLine *irLine = [AxDataManager getNewEntityObject:@"IRLine" andContext:[AxDataManager noteContext]];
            CGFloat red, blue, green, alpha;
            [line.lineColor getRed:&red green:&green blue:&blue alpha:&alpha];
            irLine.color = [NSString stringWithFormat:@"{%f,%f,%f,%f}",alpha, red, green, blue];
            irLine.width = line.lineWidth;
            irLine.line = data;
            [note addIRLineObject:irLine];
        }
    }
}


@end
