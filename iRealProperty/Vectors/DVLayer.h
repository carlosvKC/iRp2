#import <Foundation/Foundation.h>
#import "DVShape.h"
#import "DVShapeText.h"
@interface DVLayer : NSObject
{
    NSMutableArray *_shapes;
    NSString *_name;
    
    UIColor     *_color;    // Default color for its shapes
    CGFloat     _width;     // default width
    CGFloat     _dash[16];  // contains the different dash information
    int         _dashCount; // number of dash info
    BOOL        _hidden;
}

@property(nonatomic) BOOL hidden;
@property(nonatomic, strong) NSString *name;
@property(nonatomic) CGFloat width;
@property(nonatomic, getter = getDash) CGFloat *dash;
@property(nonatomic) int dashCount;
@property(nonatomic, strong) UIColor *color;
@property(nonatomic) BOOL isDefault;
@property(nonatomic, strong) NSMutableArray *shapes;
// Create a default layer
-(id)initWithName:(NSString *)name;
// More advanced layer
-(id)initWithName:(NSString *)name lineWidth:(CGFloat)lineWidth lineColor:(UIColor *)lineColor dashTable:(CGFloat *)dashes dashCount:(int)dashCount;
// Add a shape
-(void)addShape:(DVShape *)shape;
// draw the layer
-(void)drawLayer:(CGContextRef)cg scale:(CGFloat)scale offset:(CGSize)offset transparency:(CGFloat)transparency;
-(void)drawLayer:(CGContextRef)cg scale:(CGFloat)scale offset:(CGSize)offset transparency:(CGFloat)transparency showSelect:(BOOL)showSelect;

// Check if a rectangle intersects with shape
-(DVShape *)intersectWithShape:(CGRect )rect;
// Find out if an end point is found
-(int)findIntersectEndSegment:(CGRect)rect outPoint:(CGPoint *)pt;
-(int)findIntersectEndSegment:(CGRect)rect outPoint:(CGPoint *)pt excludeShape:(DVShape *)excludeShape;
// Mark a shape as selected (and deselect all the other shapes if necessary)
// Mark all the shapes as selected or not
-(void)selectShapes:(BOOL)selected;
// delete all the selected shape
-(void)deleteSelected;
// remove all objects
-(void)deleteAll;
// Remove one shape
-(void)deleteShape:(DVShape *)shape;
// find the shape with GUID
-(DVShape *)findShapeWithGuid:(NSString *)guid;


// Return the XML definition of the layer
-(NSString *)getLayerXML:(BOOL)isDefault area:(CGFloat)area;
// Return the rectangle englobing the other rectangels
-(CGRect)getLayerFrame;

-(CGMutablePathRef)calculateArea:(int *)error;
// return the first shape that contains the auto-text
-(DVShapeText *)shapeAutoText;

// draw the legend
-(CGPoint)drawLegend:(CGContextRef)cg dest:(CGPoint)dest area:(CGFloat)area;
// All the current selected shapes
-(NSArray *)getSelectedShapes;
-(void)flipVertical:(BOOL)vertical aroundPoint:(CGPoint)pt;
@end
