#import "DVLabel.h"
#import "MathHelper.h"

@implementation DVLabel

@synthesize textColor = _labelColor;
@synthesize fontSize = _labelFontSize;
@synthesize hidden = _hidden;
@synthesize text = _text;
@synthesize fontName = _fontName;
@synthesize autoPosition = _autoPosition;
@synthesize delegate;
@synthesize offset = _offset;

-(id)init
{
    self = [super init];
    [self defaultValues];
    return self;
}
-(id)initWithText:(NSString *)str
{
    self = [super init];
    [self defaultValues];
    _text = str;
    return self;    
}
-(id)copyWithZone:(NSZone *)zone
{
    DVLabel *copy = [[DVLabel alloc]init];
    if(copy)
    {
        copy->_labelColor = _labelColor;
        copy->_labelFontSize = _labelFontSize;
        copy->_hidden = _hidden;
        copy->_text = [_text copy];
        copy->_fontName = [_fontName copy];
        copy->_frame = _frame;
        copy->_rotationCenter = _rotationCenter;
        copy->_slope = _slope;
        copy->_offset = _offset;
        copy->delegate = delegate;
    }
    return copy;
}

-(void)defaultValues
{
    _labelColor = [UIColor blackColor];
    _labelFontSize = 14.0;
    _hidden = NO;
    _text = @"";
    _fontName = @"Futura-Medium";
    _frame = CGRectZero;
    _autoPosition = YES;
    _offset = 0;
    
}
-(NSString *)description
{
    return [NSString stringWithFormat:@"Label='%@' fontSize=%f fontName='%@' offset=%f", _text, _labelFontSize, _fontName, _offset];
}
// Calculate the position of the object
-(void)positionLabel:(CGPoint)startPt endPoint:(CGPoint)endPt
{
    UIFont *font = [UIFont fontWithName:_fontName size:_labelFontSize];
    
    CGSize destSize = CGSizeMake(100000, 100000);
    // Calculate the rectangle containing the text
    CGSize textSize = [_text sizeWithFont:font constrainedToSize:destSize lineBreakMode:NSLineBreakByWordWrapping];
    textSize.width += 8;
    // textSize.height += 6;
    // Now i need to find the bottom left of the screen
    _rotationCenter.x = startPt.x + (endPt.x - startPt.x)/2;
    _rotationCenter.y = startPt.y + (endPt.y - startPt.y)/2;
    _frame = CGRectMake(_rotationCenter.x - textSize.width/2, _rotationCenter.y - textSize.height/2,
                        textSize.width, textSize.height);
        
    _slope = [MathHelper angleToRadian:startPt point:endPt];
#define ROUNDERROR  0.001

    if(_slope >=0 && _slope <= M_PI_2 + ROUNDERROR)
    {

    }
    else if(_slope >= M_PI_2 && _slope <= M_PI+ROUNDERROR)
    {
        _slope -= M_PI;
    }
    else if(_slope >= M_PI_2 && _slope <= M_PI + M_PI_2+ROUNDERROR)
    {
        _slope -= M_PI;
    }

    CGFloat scale = [delegate shapeGetScale];
    if(scale==0)
       scale = 1.0;
    CGFloat delta = _offset / scale;
    _frame = CGRectMake(_frame.origin.x, _frame.origin.y - delta, _frame.size.width, _frame.size.height);
}
//
// Draw the label based on a line..
//
-(void)drawLabel:(CGContextRef)gc  
{
    UIFont *font = [UIFont fontWithName:_fontName size:_labelFontSize];
    CGContextSetFillColorWithColor(gc, [_labelColor CGColor]);
    
    CGRect rect = [delegate shapeGetRectInScreenCoordinates:_frame];
    
    CGPoint center = [delegate shapeGetPointInScreenCoordinates:_rotationCenter];
    
    CGContextSaveGState(gc);
        
    CGContextTranslateCTM(gc, center.x, center.y);
    CGContextRotateCTM(gc, _slope);
    CGContextTranslateCTM(gc, -center.x, -center.y);
    
    
    [_text drawInRect:rect withFont:font lineBreakMode:NSLineBreakByClipping alignment:NSTextAlignmentCenter];
    //CGContextSetStrokeColorWithColor(gc, [[UIColor redColor]CGColor]);
    //CGContextStrokeRect(gc, rect);
    
    CGContextRestoreGState(gc);
}
-(void)setOffset:(CGFloat)deltax
{
    _offset = deltax;
}
@end
