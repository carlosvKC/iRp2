#import "DVLegend.h"
#import "RealPropertyApp.h"
#import "DVLayer.h"
#import "Helper.h"

@implementation DVLegend

@synthesize delegate, frame, hidden;
@synthesize location = _location;

-(id)initWithPoint:(CGPoint)loc
{
    self = [super init];
    
    if(self)
    {
        _location = loc;
        _areas = [[NSMutableDictionary alloc]init];
    }
    return self;
}
//
// Draw the legend automatically -- the legend automatically draws itself as a separate layer.
// The only information it needs is the point of origin (in the local coordinates)
//
-(void)drawLegend:(CGContextRef)gc
{
    CGPoint origin = _location;
    if(hidden)
        return;
    _scale = [delegate DVLegendGetScale];
    if(_scale==0)
        _scale = 1.0;
    
    UIColor *fontColor = [UIColor blackColor];
    CGContextSetFillColorWithColor(gc, [fontColor CGColor]);
    
    origin = [self drawTextAtLoc:@"LEGEND" location:origin fontSize:22.0 maxWidth:0];
    
    
    origin = [self drawTextAtLoc:[NSString stringWithFormat:@"%@",[delegate DVLegendGetParcel] ] location:origin];
    origin = [self drawTextAtLoc:[NSString stringWithFormat:@"Appraiser %@", [RealPropertyApp getUserName] ] location:origin];
    origin = [self drawTextAtLoc:[NSString stringWithFormat:@"Update Date %@", [Helper stringFromDate:[Helper localDate]]] location:origin];
    
    // Add some space...
    origin = CGPointMake(origin.x, origin.y + 20.0);
    
    // Draw the different layers (layers must have shapes)
    NSArray *layers = [delegate DVLegendGetLayers];
    CGFloat totalArea = 0;
    for(DVLayer *layer in layers)
    {
        if([layer.name caseInsensitiveCompare:@"_Tools"]==NSOrderedSame)
            continue;
        if(layer.shapes.count==0)
            continue;
        // draw the legend and the line
        CGFloat area = [self area:layer.name];
        if(area>0)
            totalArea += area;
        // CGPoint pt = [delegate locationInView:origin];
        origin = [layer drawLegend:gc dest:origin area:area];
    }
    // Draw the total (if any...)
    // force the total area to be 0 sine they don't want the total
    totalArea = 0;
    if(totalArea>0)
    {
        origin = CGPointMake(origin.x, origin.y + 10);
        origin = [self drawTextAtLoc:[NSString stringWithFormat:@"Total area: %d sq ft", (int)totalArea] location:origin fontSize:17.0 maxWidth:0];
    }
    frame = CGRectMake(_location.x, _location.y, 200.0, origin.y - _location.y);
}
-(CGPoint)drawTextAtLoc:(NSString *)text location:(CGPoint)loc
{
    return [self drawTextAtLoc:text location:loc fontSize:0 maxWidth:0];
}
// Draw one line and move the "cursor" to next line
-(CGPoint)drawTextAtLoc:(NSString *)text location:(CGPoint)loc fontSize:(CGFloat)fontSize maxWidth:(int)maxWidth
{
    NSString *fontName = @"Helvetica";
    CGPoint locInView = [delegate locationInView:loc];
    if(fontSize==0)
        fontSize = 19.0;    // Default size
    
    if(maxWidth==0)
        maxWidth = 10000;
    CGFloat fontHeight = fontSize + 5;
    CGRect rect = CGRectMake(locInView.x, locInView.y, maxWidth, fontHeight*_scale);
    [Helper drawTextInRect:text fontName:fontName fontSize:fontSize* _scale minimumFontSize:10.0*_scale destRect:rect textAlign:NSTextAlignmentLeft];
    
    return CGPointMake(loc.x, loc.y + fontHeight);
}
-(BOOL)inside:(CGPoint)pt
{
    if(hidden)
        return NO;
    pt = [delegate locationInModel:pt];
    return CGRectContainsPoint(frame, pt);
}
-(void)move:(CGPoint)delta
{
    if(hidden)
        return;
    _location = CGPointMake(_location.x + delta.x/_scale, _location.y + delta.y/_scale);
}
#pragma mark - manage areas
-(CGFloat)area:(NSString *)name
{
    NSNumber *number = [_areas valueForKey:name];
    if(number==nil)
        return -1;
    return [number floatValue];
}
-(void)newArea:(NSString *)name area:(CGFloat)area
{
    NSNumber *number = [NSNumber numberWithFloat:area];
    [_areas setValue:number forKey:name];
}
-(void)addArea:(NSString *)name area:(CGFloat)area
{
    CGFloat value = [self area:name];
    
    if(value == -1)
        return;
    value += area;
    [self newArea:name area:value];
}
-(void)substractArea:(NSString *)name area:(CGFloat)area
{
    CGFloat value = [self area:name];
    
    if(value == -1)
        return;
    value -= area;
    if(value<0)
        value = 0;
    [self newArea:name area:value];
}

@end

