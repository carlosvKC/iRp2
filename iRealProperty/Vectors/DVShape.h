
#import <Foundation/Foundation.h>

enum {
    kAngleNone = 0,
    kAngleStart = 1,
    kAngleEnd,
    kAngleCenter,
    kAngleShape,     // on the shape
    kLineLength1,
    kLineLength2
};


@protocol DVShapeDelegate <NSObject>
    // Return the current distance scale
    -(int)shapePixelPerUnit;
    // Display info
    -(void)shapeDisplayInfo:(NSString *)info;
    // Return the point in screen coordinates
    -(CGPoint)shapeGetPointInScreenCoordinates:(CGPoint)pt;
    // Return the point in screen coordinates
    -(CGRect)shapeGetRectInScreenCoordinates:(CGRect)pt;
    // Return a string in the current math system
    -(NSString *)shapeFloatToFeet:(CGFloat)length;
    // Return the current scale
    -(CGFloat)shapeGetScale;
@end


@class DVLabel;


@interface DVShape : NSObject<NSCopying>
    {
        CGFloat     _width;
        CGFloat     _length;
        UIColor     *_color;
        NSString    *_guid;
        enum
        {
            kPatternSolid,
            kPatternDash
        } _pattern;
        
        // Fill the handle
        UIColor     *_handleColor;
        CGFloat     _handleWidth;
        
        BOOL        _inheritLayer;

        DVLabel     *_label;
        BOOL        _hideLabel;
        __weak      id<DVShapeDelegate>_delegate;
    }

    @property(nonatomic, weak) id<DVShapeDelegate>delegate;
    // Select or deselect a shape
    @property(nonatomic) BOOL selected;
    // Access color and width
    @property(nonatomic, strong) UIColor *color;
    @property(nonatomic) CGFloat width;
    @property(nonatomic, strong) DVLabel *label;
    @property(nonatomic, getter = getLength) CGFloat length;
    @property(nonatomic, getter = getCenter) CGPoint center;
    @property(nonatomic, strong) NSString *guid;
    @property(nonatomic) BOOL inheritLayer;
    @property(nonatomic, getter = getStartPoint) CGPoint startPoint;
    @property(nonatomic, getter = getEndPoint) CGPoint endPoint;
    @property(nonatomic) int lastClick;
    @property(nonatomic) BOOL hideLabel;
    // Get the frame of the shape
    // Return the rectangle enclosing the shape
    -(CGRect)getShapeFrame;
    // Get the XML definition of the shape
    // Return the XML definition of the shape
    -(NSString *)getShapeXML;
    // Draw the default shape
    -(void)drawShape:(CGContextRef)gc scale:(CGFloat)scale offset:(CGSize)offset lineWidth:(CGFloat)lineWidth lineColor:(UIColor *)lineColor dashTable:(CGFloat *)dashes dashCount:(int)dashCount transparency:(CGFloat)transparency showSelect:(BOOL)showSelect;
    -(void)drawInPath:(CGMutablePathRef)path;

    // Check if the shape intersect with a rectangle
    -(BOOL)intersectWithShape:(CGRect )rect;
    // Check if the user clciks in the end
    -(int)findIntersectEndSegment:(CGRect)rect outPoint:(CGPoint *)point;
    // set the point as the end
    -(void)swapEnd:(CGPoint)pt;

    // Draw handle
    -(void)drawHandle:(CGPoint)pt context:(CGContextRef)gc scale:(CGFloat)scale offset:(CGSize)offset;
    -(void)drawHandleRound:(CGPoint)pt context:(CGContextRef)gc scale:(CGFloat)scale offset:(CGSize)offset;
    -(void)drawHandle:(CGPoint)pt context:(CGContextRef)gc scale:(CGFloat)scale offset:(CGSize)offset color:(UIColor *)color;

    // Retrieve the closest point (depends on the shape)
    -(CGPoint)findIntersectPoint:(int)segment;
    -(void)duplicateTo:(DVShape *)copy;

-(void)flipVertical:(BOOL)vertical aroundPoint:(CGPoint)center;

@end
