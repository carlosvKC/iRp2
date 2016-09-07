#import <Foundation/Foundation.h>
#import "DVLayer.h"
#import "DVShape.h"
#import "DVShapeArc.h"
#import "DVShapeLine.h"
#import "DVShapeText.h"
#import "DVLegend.h"

enum DVModelConstant 
{
    DVModelMetric = 0,
    DVModelImperial = 1
};
enum DVMeasureConstant
{
    DVMeasureInch = 10,
    DVMeasureFoot = 11,
    DVMeasureYard = 12,
    DVMeasureMile = 13,
    
    DVMeasureCentimeter = 20,
    DVMeasureDecimeter = 21,
    DVMeasureMeter = 22,
    DVMeasureKilometer = 23
    };
enum crossMode
{
    DVCrossBlue,
    DVCrossRed,
    DVCrossSmall
};
#define ACTIVEPOINT_RADIUS  10.0
#define FINGER_WIDTH    30

@class RealPropInfo;
@class DVShapeArc;

@interface DVModelView : UIView<DVShapeDelegate, DVLegendDelegate>
{
    enum DVModelConstant _model;
    enum DVMeasureConstant _measure; // Measure per square
    
    CGPoint _activePoint;
    
    CGFloat _pointsPerUnit;
    
    CGFloat _pointPerSquare;    // number of points per square
    CGSize  _sheetSize;     // Sheet size expressed in squares

    CGFloat _lineWidth;     // Normal line width
    CGFloat _extraLineWidth;    // Extra line width (if any)
    int _extraBlocks;       // Extra blocks (i.e. 10 single blocks in one block)
    
    // Color model
    UIColor  *_backgroundColor;
    UIColor  *_lineColor;
    UIColor  *_extraColor;
    UIColor  *_activePointColor;
    
    // Scale model for display only
    CGFloat _scale;
    
    // Offset in points from the top,left coordinates
    CGSize  _offset;
    
    // List of layers
    NSMutableArray *_layers;
    DVLayer *_activeLayer;
    DVLayer *_toolLayer;
    
    
    // Constrain the measurements ...
    int         _constrainAngle;        // in degree
    int         _constrainLength;       // in pixel/measurement

    CGRect      _fingerRect;

    
    // Draw a cross
    BOOL        _drawCross;
    CGPoint     _crossPoint;
    
    // Manage the background image
    CGFloat     _imageScale;    // relative scale to the rest of the image
    CGPoint     _imageOffset;
    
    int         _currentTool;
    BOOL        _hideDiagonal;
    
    // Legend management
    BOOL        _showLegend;
    CGRect     _legendFrame;
    
    // A segment was clicked
    int         _intersectSegment;
    
    // align grid
    BOOL        _alignToGrid;
}
// Refresh the model
-(void)drawModel;
// Change the scale
@property(nonatomic) CGFloat scale;
@property(nonatomic, strong) DVLayer *activeLayer; 
@property(nonatomic) CGSize offset;
@property(nonatomic) int constrainLength;
@property(nonatomic) BOOL gridVisible;
@property(nonatomic) UIImage *backgroundImage;
@property(nonatomic) BOOL imageVisible;
@property(nonatomic) CGPoint crossPoint;
@property(nonatomic) CGPoint activePoint;
@property(nonatomic) CGFloat pointsPerUnit;
@property(nonatomic) BOOL hideDiagonal;
@property(nonatomic) int currentTool;
@property(nonatomic) BOOL hideCross;
@property(nonatomic) CGFloat imageScale;
@property(nonatomic) CGPoint imageOffset;
@property(nonatomic) int crossMode;
@property(nonatomic) DVShape *activeShape;
@property(nonatomic) CGSize sheetSize;
@property(nonatomic) CGMutablePathRef path;

@property(nonatomic, strong) NSArray *layers;
@property(nonatomic) BOOL showLegend;

@property(nonatomic, weak) RealPropInfo *realPropInfo;
@property(nonatomic) int intersectSegment;
@property(nonatomic, strong) DVLegend *modelLegend;

@property(nonatomic)    BOOL alignToGrid;


// Small helper function
+(UIColor *)UIColorFromRGB255: (int)red green:(int)green blue:(int)blue;

// Return the coordinates of a point in the model
// Constrain the point -- the point is in model coordinate
-(CGPoint)locationInModel:(CGPoint)pt;
// reverse
-(CGPoint)locationInView:(CGPoint)pt;

// Change the left,top delta offset
-(void)setDeltaOffset:(CGSize)deltaOffset;

// Find if a shape intersects with a point
-(DVShape *)findIntersectShape:(CGPoint)pt;

// Find if touch an end segement
-(int)findIntersectEndSegment:(CGPoint *)pt;
-(int)findIntersectEndSegment:(CGPoint *)pt excludeShape:(DVShape *)excludeShape;

// Mark all the shapes as selected or not
-(void)selectShapes:(BOOL)selected;

// Constrain the point -- the point is in model coordinate
//-(CGPoint)locationInModel:(CGPoint)pt;

// Constrain an angle
-(CGFloat)constrainAngle:(CGFloat)angle;
-(CGPoint)constrainLine:(CGPoint)pt;
-(CGPoint)constrainPoint:(CGPoint)pt;

// Delete all the shapes in the current layer
-(void)deleteSelected;

// Return all selected shapes
-(NSArray *)getSelectedShapes;

// add a shape to the default layer
-(void)addShape:(DVShape *)shape;

// Convert from float to feet/inches
-(NSString *)shapeFloatToFeet:(CGFloat)length;

// Return the model in XML
-(NSString *)modelToXML;

// Read a model from an NSData and recreates the different layers
-(BOOL)openModel:(NSData *)fileData error:(NSError **)error;

// Create a PNG image
-(NSData *)createImageFromModel:(CGFloat )border;

// Calculate the area
-(CGFloat)calculateAreaFromPath;

// Draw the rectangles
-(void)drawArcAngles:(DVShapeArc *)arc clean:(BOOL)clean;

// Return the default instance
+(DVModelView *)instance;
// Flip a vier vertical or horizontal
-(void)flipModel:(BOOL)vertical;
@end
