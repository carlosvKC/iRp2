
#import <Foundation/Foundation.h>
#import <ArcGIS/ArcGIS.h>

@interface AxSketchLayer : AGSGraphicsLayer<AGSMapViewTouchDelegate>
{

    AGSGeometry* _geometry;

    AGSGraphic* _graphic;
    AGSGraphic* _selectedVertexGraphic;
    AGSGraphic* _selectedSegmentGraphic;
    NSMutableArray* _vertexes;
    
    AGSSimpleFillSymbol* _fillSymbol;
    AGSSimpleLineSymbol* _lineSymbol;
    AGSSimpleMarkerSymbol* _poinSymbol;
    AGSSimpleMarkerSymbol* _vertexSymbol;
    AGSSimpleMarkerSymbol* _midVertexSymbol;
    AGSSimpleMarkerSymbol* _selectedVertexSymbol;
    AGSSimpleLineSymbol* _selectedSegmentSymbol;
    int _selectedVertex;
    BOOL _dragging;
    
    NSUndoManager *_undoManager;
}

@property (nonatomic, strong) AGSGeometry* geometry;
@property (nonatomic, strong) NSUndoManager* undoManager;

// adds a new point after the current selected vertex
- (void)addPoint:(AGSPoint*)mappoint;

// removes the vertex at the specify index from the geometry
-(void)removePointAtIndex: (NSNumber*)vertexIndex;

@end
