
#import "DVShapeText.h"
#import "MathHelper.h"
#import "Helper.h"

@implementation DVShapeText

@synthesize startCorner = _startCorner;
@synthesize endCorner = _endCorner;
@synthesize frame = _frame;
@synthesize text = _text;
@synthesize backColor = _backColor;
@synthesize isLength = _isLength;
@synthesize isAutoText = _isAutoText;


-(id)initWithText:(NSString *)text origin:(CGPoint)origin
{
    self = [super init];
    _fontName = @"Helvetica";
    _fontSize = 20.0;
    _fontColor = [UIColor blackColor];
    _backColor = [UIColor whiteColor];
    _text = text;
    
    CGSize textSize = [text sizeWithFont:[UIFont fontWithName:_fontName size:_fontSize] constrainedToSize:CGSizeMake(10000, 10000)];
    _frame = CGRectMake(origin.x, origin.y, textSize.width+10, textSize.height+10);
    return self;    
}

-(id)initWithFrame:(CGRect)frame
{
    self = [super init];
    _fontName = @"Helvetica";
    _fontSize = 20.0;
    _fontColor = [UIColor blackColor];
    _backColor = [UIColor whiteColor];
    _text = @"Text";
    _frame = frame;
    return self;
}
-(id)copyWithZone:(NSZone *)zone
{
    DVShapeText *copy = [[DVShapeText alloc]init];
    if(copy)
    {
        [super duplicateTo:copy];
        copy->_text = [_text copy];
        copy.startCorner = self.startCorner;
        copy.endCorner = self.endCorner;
        copy.frame = _frame; // CGRectMake(_frame.origin.x, _frame.origin.y, _frame.size.width, _frame.size.height);
        copy->_fontSize = _fontSize;
        copy->_fontColor = _fontColor;
        copy->_fontName = _fontName;
        copy->_backColor = _backColor;

        copy->_isLength = _isLength;
    }
    return copy;
}
-(NSString *)description
{
    return [NSString stringWithFormat:@"{ frame=%@, color=%@, text='%@' }", NSStringFromCGRect(_frame), [_backColor description], _text];
}
-(void)drawShape:(CGContextRef)cg scale:(CGFloat)scale offset:(CGSize)offset lineWidth:(CGFloat)lineWidth lineColor:(UIColor *)lineColor dashTable:(CGFloat *)dashes dashCount:(int)dashCount transparency:(CGFloat)transparency showSelect:(BOOL)showSelect
{
    
    if(self.selected || _text.length==0)
        CGContextSetFillColorWithColor(cg, [_backColor CGColor]);
    else
        CGContextSetFillColorWithColor(cg, [[UIColor clearColor] CGColor]);

    CGRect rect = [self.delegate shapeGetRectInScreenCoordinates:_frame];
    CGContextFillRect(cg, rect);

    CGContextSetFillColorWithColor(cg, [lineColor CGColor]);
    
    UIFont *font = [self getFontForScale:scale];
      [_text drawInRect:rect withFont:font  lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentLeft];
    //[_text drawInRect:rect withFont:font  lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentLeft];
    
    
    rect = _frame;
    if(self.selected && showSelect)
   {
       [self drawHandle:CGPointMake(rect.origin.x, rect.origin.y) context:cg scale:scale offset:offset];
       [self drawHandle:CGPointMake(rect.origin.x+rect.size.width, rect.origin.y) context:cg scale:scale offset:offset];
       [self drawHandle:CGPointMake(rect.origin.x, rect.origin.y+rect.size.height) context:cg scale:scale offset:offset];
       [self drawHandle:CGPointMake(rect.origin.x+rect.size.width, rect.origin.y+rect.size.height) context:cg scale:scale offset:offset];
   }
}
-(void)setStartCorner:(CGPoint)corner
{
    _startCorner = corner;
    _frame = CGRectMake(corner.x, corner.y, _frame.size.width, _frame.size.height);
}
-(void)setEndCorner:(CGPoint)corner
{
    _endCorner = corner;
    _frame = CGRectMake(_frame.origin.x, _frame.origin.y, corner.x - _frame.origin.x, corner.y - _frame.origin.y);    
}
-(BOOL)intersectWithShape:(CGRect )rect
{
    bool result = CGRectIntersectsRect(rect, _frame);
    return result;
}
-(int)findIntersectEndSegment:(CGRect)rect outPoint:(CGPoint *)point
{
    if( [self checkHandle:rect x:_frame.origin.x y:_frame.origin.y outPoint:point])
        return 1;
    if( [self checkHandle:rect x:_frame.origin.x+_frame.size.width y:_frame.origin.y outPoint:point])
        return 2;
    if( [self checkHandle:rect x:_frame.origin.x y:_frame.origin.y+_frame.size.height outPoint:point])
        return 3;
    if( [self checkHandle:rect x:_frame.origin.x+_frame.size.width y:_frame.origin.y+_frame.size.height outPoint:point])
        return 4;
    
    if( CGRectIntersectsRect(_frame, rect))
        return 5;
    return 0;

    // look for the frame
#define INTERSECT(X1,Y1,X2,Y2)   if([MathHelper lineIntersectWithRectangle:CGPointMake((X1),(Y1)) endPoint:CGPointMake((X2),(Y2)) withRect:rect]) return 5;

    CGPoint pt = _frame.origin;
    CGFloat width = _frame.size.width;
    CGFloat height = _frame.size.height;
    
    INTERSECT(pt.x,pt.y, pt.x+ width,pt.y);
    INTERSECT(pt.x+width, pt.y, pt.x+width, pt.y+height);
    INTERSECT(pt.x, pt.y+height, pt.x+width, pt.y+height);
    INTERSECT(pt.x, pt.y, pt.x, pt.y+height);
    
    if( CGRectIntersectsRect(_frame, rect))
        return 6;
    return 0;
}
-(int)checkHandle:(CGRect)rect x:(CGFloat)x y:(CGFloat)y outPoint:(CGPoint *)point
{
    CGRect handle = CGRectMake(x - _handleWidth, y - _handleWidth,  2*_handleWidth, 2*_handleWidth);
    bool result = CGRectIntersectsRect(rect, handle);
    if(result)
    {
        point->x = x;
        point->y = y;
    }
    return result?1:0;
}
-(void)adjustRect:(CGPoint)pt atCorner:(int)corner
{
    CGFloat dx, dy;
    switch (corner)
    {
        case 1:
            dx = _frame.origin.x - pt.x;
            dy = _frame.origin.y - pt.y;
            
            _frame = CGRectMake(pt.x, pt.y, _frame.size.width + dx, _frame.size.height + dy);
            
            break;
        case 2:
            dy = _frame.origin.y - pt.y;            

            _frame = CGRectMake(_frame.origin.x, pt.y, _frame.size.width, _frame.size.height + dy);
            break;
        case 3:
            dy = pt.y - _frame.origin.y;
            _frame = CGRectMake(_frame.origin.x, _frame.origin.y, _frame.size.width, dy);
            break;
        case 4:
            dx = pt.x - _frame.origin.x;
            dy = pt.y - _frame.origin.y;
            _frame = CGRectMake(_frame.origin.x, _frame.origin.y, dx, dy);
            
        default:
            break;
    }
    _frame = CGRectStandardize(_frame);
}
-(void)setCenter:(CGPoint)center
{
    // Move the shape appropriately
    _frame = CGRectMake(center.x - _frame.size.width/2, center.y - _frame.size.height/2,
                        _frame.size.width, _frame.size.height);
}
-(CGPoint) getCenter
{
    CGPoint center = CGPointMake(_frame.origin.x + _frame.size.width/2,
                                 _frame.origin.y + _frame.size.height/2);
    return center;
}
-(UIFont *)getFontForScale:(CGFloat)scale
{
    return [UIFont fontWithName:_fontName size:_fontSize*scale]; 
}
-(NSString *)getShapeXML
{
    // 3/19/13 HNN need to replace &,<,> with escape characters
//    XML has a special set of characters that cannot be used in normal XML strings. These characters are:
//    
//    & - &amp;
//    < - &lt;
//    > - &gt;
//    " - &quot;
//    ' - &#39; -- HNN seems to be ok
    NSString *validxml = _text;
    validxml=[validxml stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"];
    validxml=[validxml stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"];
    validxml=[validxml stringByReplacingOccurrencesOfString:@">" withString:@"&gt;"];
    validxml=[validxml stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"];
    //return [NSString stringWithFormat:@"<shape type=\"text\" frame=\"%@\" label=\"%@\" />", NSStringFromCGRect(_frame), validxml];
    return [NSString stringWithFormat:@"<shape type=\"text\" frame=\"%@\" label=\"%@\" />", NSStringFromCGRect(_frame), _text];
}
-(CGRect) getShapeFrame
{
    return _frame;
}
-(void)dealloc
{
    _text = nil;
    _fontColor = nil;
    _fontName = nil;
    _backColor = nil;
    self.text = nil;
    self.backColor = nil;
}
-(void)flipVertical:(BOOL)vertical aroundPoint:(CGPoint)center
{
    CGPoint textCenter = [self getCenter];
    if(vertical)
    {
        CGFloat delta = textCenter.x - center.x;
        textCenter.x -= 2*delta;
    }
    else
    {
        CGFloat delta = textCenter.y - center.y;
        textCenter.y -= 2*delta;
    }
    [self setCenter:textCenter];
}
@end
