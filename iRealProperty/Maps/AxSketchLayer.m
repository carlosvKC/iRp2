
#import "AxSketchLayer.h"

@implementation AxSketchLayer

@synthesize undoManager = _undoManager;

-(id)init
{
    self = [super init];
    if (self != NULL)
    {
        _fillSymbol = [[AGSSimpleFillSymbol alloc] initWithColor:[UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:0.6] outlineColor:[UIColor blueColor]];
        [_fillSymbol setStyle:AGSSimpleFillSymbolStyleSolid];
        
        _lineSymbol = [[AGSSimpleLineSymbol alloc] initWithColor:[UIColor blueColor] width:2];
        [_lineSymbol setStyle:AGSSimpleLineSymbolStyleSolid];

        
        _selectedVertexSymbol = [[AGSSimpleMarkerSymbol alloc] initWithColor:[UIColor redColor]];
        [_selectedVertexSymbol setStyle:AGSSimpleMarkerSymbolStyleDiamond];
        [_selectedVertexSymbol setSize:24];
        _selectedVertexSymbol.outline.color = [UIColor blueColor];
        
        _selectedSegmentSymbol = [[AGSSimpleLineSymbol alloc] initWithColor:[UIColor redColor] width:2.0f];
        [_selectedSegmentSymbol setStyle:AGSSimpleLineSymbolStyleDash];
        
        _vertexSymbol = [[AGSSimpleMarkerSymbol alloc] initWithColor:[UIColor colorWithRed:0.3 green:0.3 blue:1.0 alpha:0.8]];
        [_vertexSymbol setStyle:AGSSimpleMarkerSymbolStyleCircle];
        [_vertexSymbol setSize:24];
        _vertexSymbol.outline.color = [UIColor blueColor];
        
        _midVertexSymbol = [[AGSSimpleMarkerSymbol alloc] initWithColor:[UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:0.8]];
        [_midVertexSymbol setStyle:AGSSimpleMarkerSymbolStyleCircle];
        [_midVertexSymbol setSize:24];
        _midVertexSymbol.outline.color = [UIColor blueColor];
        
        _vertexes = [[NSMutableArray alloc] init];
        
        _selectedVertex = -1;
    }
    return self;
}

-(void)setGeometry:(AGSGeometry *)geometry
{
    _geometry = geometry;
    if ([_geometry isKindOfClass:[AGSMutablePolygon class]])
    {
        [(AGSMutablePolygon*)_geometry addRingToPolygon];
        _graphic = [AGSGraphic graphicWithGeometry:_geometry symbol:_fillSymbol attributes:nil infoTemplateDelegate:nil];
    }
    else if ([_geometry isKindOfClass:[AGSMutablePolyline class]])
    {
        _graphic = [AGSGraphic graphicWithGeometry:_geometry symbol:_lineSymbol attributes:nil infoTemplateDelegate:nil];
        [(AGSMutablePolyline*)_geometry addPathToPolyline];
    }
    else if ([_geometry isKindOfClass:[AGSMutablePoint class]])
    {
        _graphic = [AGSGraphic graphicWithGeometry:_geometry symbol:_poinSymbol attributes:nil infoTemplateDelegate:nil];
    }
    
    [self.graphics removeAllObjects];
    [_vertexes removeAllObjects];
    [self.graphics addObject:_graphic];
    _selectedVertex = 0;
    _selectedSegmentGraphic = nil;
    _selectedVertexGraphic = nil;
    _undoManager = [[NSUndoManager alloc] init];
    _dragging = true;
    
    _loaded = true;
    [self dataChanged];
}

-(AGSGeometry *)geometry
{
    return _geometry;
}

- (void) markSelectedSegment
{
    BOOL validNextVertex = false;
    int nextVertex = _selectedVertex + 1;
    if (nextVertex >= [_vertexes count])
    {
        if ([_geometry isKindOfClass:[AGSMutablePolygon class]])
        {
            nextVertex = 0;
            if ([_vertexes count] > 0)
            {
                validNextVertex = true;
            }
        }
    }
    else {
        validNextVertex = true;
    }
    
    if (validNextVertex)
    {
        if (_selectedSegmentGraphic != nil)
        {
            [self.graphics removeObject:_selectedSegmentGraphic];
            _selectedSegmentGraphic = nil;
        }
        AGSMutablePolyline* lineseg = [[AGSMutablePolyline alloc] initWithSpatialReference:self.spatialReference];
        [lineseg addPathToPolyline];
        [lineseg addPointToPath:(AGSPoint*)[((AGSGraphic*)[_vertexes objectAtIndex:_selectedVertex]) geometry]];
        [lineseg addPointToPath:(AGSPoint*)[((AGSGraphic*)[_vertexes objectAtIndex:nextVertex]) geometry]];
        _selectedSegmentGraphic = [AGSGraphic graphicWithGeometry:lineseg symbol:_selectedSegmentSymbol attributes:nil infoTemplateDelegate:nil];
        [self addGraphic:_selectedSegmentGraphic];
    }
    
}

// adds a new point after the current selected vertex
- (void)addPoint:(AGSPoint*)mappoint
{
    if ([_geometry isKindOfClass:[AGSMutablePolygon class]])
    {
        int numOfVertexs = [(AGSMutablePolygon*)_geometry numPointsInRing:0];
        if (numOfVertexs == 0 || _selectedVertex == numOfVertexs - 1)
        {
            [(AGSMutablePolygon*)_geometry addPointToRing:[mappoint mutableCopy]];
            _selectedVertex = numOfVertexs;
        }
        else {
            [(AGSMutablePolygon*)_geometry insertPoint:[mappoint mutableCopy] onRing:0 atIndex:_selectedVertex + 1];
            _selectedVertex ++;
        }
    }
    else if ([_geometry isKindOfClass:[AGSMutablePolyline class]])
    {
        int numOfVertexs = [(AGSMutablePolyline*)_geometry numPointsInPath:0];
        if (numOfVertexs == 0 || _selectedVertex == numOfVertexs - 1)
        {
            [(AGSMutablePolyline*)_geometry addPointToPath:[mappoint mutableCopy]];
            _selectedVertex = numOfVertexs;
        }
        else {
            [(AGSMutablePolyline*)_geometry insertPoint:[mappoint mutableCopy] onPath:0 atIndex:_selectedVertex + 1];
            _selectedVertex ++;
        }
        
    }
    else if ([_geometry isKindOfClass:[AGSMutablePoint class]])
    {
        
    }
    
    if (_selectedVertexGraphic!= NULL)
    {
        [_selectedVertexGraphic setSymbol:_vertexSymbol];
    }
    _selectedVertexGraphic = [AGSGraphic graphicWithGeometry:[mappoint mutableCopy] symbol:_selectedVertexSymbol attributes:nil infoTemplateDelegate:nil];
    
    
    [_selectedVertexGraphic setAttributes:[NSMutableDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:@"isVertex"]];
    
    //[_vertexes addObject:_selectedVertexGraphic];
    [_vertexes insertObject:_selectedVertexGraphic atIndex:_selectedVertex];
    
    [self markSelectedSegment];
    
    [self.graphics addObject:_selectedVertexGraphic];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"GeometryChanged" object:self];
    [self dataChanged];
    
    // [[_undoManager prepareWithInvocationTarget:self] removeSelectedPoint];
    [_undoManager registerUndoWithTarget:self selector:@selector(removePointAtIndex:) object:[NSNumber numberWithInt:_selectedVertex]];
}

-(void)removePointAtIndex: (NSNumber*)vertexIndex
{
    int index = [vertexIndex intValue];
    if (_selectedVertexGraphic != NULL) {
        AGSPoint* removedPoint = NULL;
        if ([_geometry isKindOfClass:[AGSMutablePolygon class]])
        {
            int numOfVertexs = [(AGSMutablePolygon*)_geometry numPointsInRing:0];
            if (numOfVertexs > 0 && index < numOfVertexs && index >= 0)
            {
                removedPoint = [(AGSMutablePolygon*)_geometry pointOnRing:0 atIndex:index];
                [(AGSMutablePolygon*)_geometry removePointOnRing:0 atIndex:index];
                
            }
        }
        else if ([_geometry isKindOfClass:[AGSMutablePolyline class]])
        {
            int numOfVertexs = [(AGSMutablePolyline*)_geometry numPointsInPath:0];
            if (numOfVertexs > 0 && index < numOfVertexs && index >= 0)
            {
                removedPoint = [(AGSMutablePolyline*)_geometry pointOnPath:0 atIndex:index];
                [(AGSMutablePolyline*)_geometry removePointOnPath:0 atIndex:index];
                
            }

        }
        else if ([_geometry isKindOfClass:[AGSMutablePoint class]])
        {
            
        }
        if (removedPoint != NULL)
        {
            if (index >= 0 && index < [_vertexes count])
            {
                [_vertexes removeObjectAtIndex:index];
            }
            if (index == _selectedVertex)
            {
                if (_selectedVertex >= [_vertexes count])
                {
                    _selectedVertex = [_vertexes count] - 1;
                }
                
                if (_selectedVertex >= 0) {
                    _selectedVertexGraphic = [_vertexes objectAtIndex:_selectedVertex];
                    _selectedVertexGraphic.symbol = _selectedVertexSymbol;
                }
            }
            [self dataChanged];
            // [[_undoManager prepareWithInvocationTarget:self] addPoint:removedPoint];
            [_undoManager registerUndoWithTarget:self selector:@selector(addPoint:) object:removedPoint];
        }
    }
}

-(void)mapView:(AGSMapView *)mapView didClickAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint graphics:(NSDictionary *)graphics
{
    BOOL selectionChanged = false;
    if (_geometry != NULL)
    {
        // detect selected vertex.
        NSArray* thisLayerGraphics = [graphics valueForKey:[self name]];
        if (thisLayerGraphics != NULL && [thisLayerGraphics count] > 0)
        {
            for (AGSGraphic* gr in thisLayerGraphics) {
                if ([_vertexes containsObject:gr])
                {
                    _selectedVertexGraphic.symbol = _vertexSymbol;
                    _selectedVertex = [_vertexes indexOfObject:gr];
                    _selectedVertexGraphic = [_vertexes objectAtIndex:_selectedVertex];
                    _selectedVertexGraphic.symbol = _selectedVertexSymbol;
                    [self markSelectedSegment];
                    selectionChanged = true;
                    
                    break;
                }
            }
        }
        if (!selectionChanged)
        {
            [self addPoint:mappoint];
        }
    }
    [self dataChanged];
}

-(void)mapView:(AGSMapView *)mapView didTapAndHoldAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint graphics:(NSDictionary *)graphics
{
    // get the point over what I clicked.
    if(!_dragging)
    {
        // detect selected vertex.
        NSArray* thisLayerGraphics = [graphics valueForKey:[self name]];
        if (thisLayerGraphics != NULL && [thisLayerGraphics count] > 0)
        {
            for (AGSGraphic* gr in thisLayerGraphics) {
                if ([_vertexes containsObject:gr])
                {
                    _selectedVertexGraphic.symbol = _vertexSymbol;
                    _selectedVertex = [_vertexes indexOfObject:gr];
                    _selectedVertexGraphic = [_vertexes objectAtIndex:_selectedVertex];
                    _selectedVertexGraphic.symbol = _selectedVertexSymbol;
                    
                    [self dataChanged];
                    
                    break;
                }
            }
        }
        _dragging = true;
    }
}

-(void)mapView:(AGSMapView *)mapView didMoveTapAndHoldAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint graphics:(NSDictionary *)graphics
{
    if (_dragging)
    {
        if ([_geometry isKindOfClass:[AGSMutablePolygon class]])
        {
            if(_selectedVertex!= -1 && ((AGSMutablePolygon*)_geometry).numRings >0 && [((AGSMutablePolygon*)_geometry) numPointsInRing:0]>0)
            {
                [(AGSMutablePolygon*)_geometry pointOnRing:0 atIndex:_selectedVertex];
                [(AGSMutablePolygon*)_geometry updatePoint:[mappoint copy] onRing:0 atIndex:_selectedVertex];
            }
        }
        else  if ([_geometry isKindOfClass:[AGSMutablePolyline class]])
        {
            if(_selectedVertex!= -1 && ((AGSMutablePolyline*)_geometry).numPaths >0 && [((AGSMutablePolyline*)_geometry) numPointsInPath:0]>0)
            {
                [(AGSMutablePolyline*)_geometry pointOnPath:0 atIndex:_selectedVertex];
                [(AGSMutablePolyline*)_geometry updatePoint:[mappoint copy] onPath:0 atIndex:_selectedVertex];
            }
        }
        
        [(AGSMutablePoint*)_selectedVertexGraphic.geometry updateWithX:mappoint.x y:mappoint.y];
        
        [self markSelectedSegment];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"GeometryChanged" object:self];
        [self dataChanged];
    }
    
}

-(void)mapView:(AGSMapView *)mapView didEndTapAndHoldAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint graphics:(NSDictionary *)graphics
{
    _dragging = false;
}

@end
