#import <Foundation/Foundation.h>
#import "BaseShapeCustomLayer.h"
#import "SQLite3.h"
#import "Spatialite.h"
#import "gaiageo.h"
#import "MapLayerConfig.h"

@class TabMapDetail;

@interface CenterOfShape:NSObject

@property(nonatomic) CGFloat x, y;
@property(nonatomic) int realPropId;
@end

@interface SpatiaLiteLayer : BaseShapeCustomLayer<AGSInfoTemplateDelegate> {
    
    // PRJ.4 lamber conical projection configuration classes (in case need to reproject the shapes in the layer)
    projPJ pj_conic;
    
    // PRJ.4 web mercator projection configuration classes (in case need to reproject the shapes in the layer)
    projPJ pj_latlong;
    
    // pointer to the spatialite database.
    sqlite3 * db;
    
    // prepare spatial query used to access the shapes inside of the visible area 
    sqlite3_stmt* statement;
    
    // pointer to the MapView that contains this layer. This is used to get the curent viewport.
    AGSMapView* parentMap;
    
    // Name of the table in the spatialite database that will be rendered by this layer
    NSString* tableName;
    
    // Name of the geometry column that will be rendered by this layer.
    NSString* geoColumnName;
    
    // type of the shape (MULTIPOINT, MULTICURVE, MULTIPOLYGON) that the geometry column contains.
    NSString* shapeType;
    
    // Mimimun map resolution whish the spatial query will support being query. if the map resolution is greather than this value the spatial query will not be executed.   
    double minResolution;
    
    //PK_UID of the selected shape (last shape where the user touch in this layer)
    NSMutableArray* selectedShapes;
    NSMutableArray* selectedMarkers;
    
    // force the layer to show the polygons that contains the annotations
    BOOL showAnnotationPolygonContainers;
    
    BOOL showShapes;
    BOOL showLabels;
    BOOL scaleLabels;
    BOOL clipping;        // the entire map is loaded in memory and is not clipped (or re-queried)
    BOOL removeLabelDuplicates; // if is true will use labels array to detect duplicate labes and removed. if false it will show all the labels (this is very important for the catastral layers).
    
    BOOL customQuery; // Indicates when the golbal statment is a custom query
    
    AGSTextSymbol* defaultLabelSymbol;
    NSString* fontFamilyColumnName;
    NSString* fontBoldColumnName;
    NSString* fontSizeColumnName;
    NSString* fontColorColumnName;
    NSString* labelAngleColumnName;
    NSString* _labelColumnName;
    NSMutableArray* labelsText;
    
    double renderValueBreaker;
    AGSSymbol* breakerSymbol;
    NSDictionary* AnnotationClasses;
    
    double timeQuery;        // How long it took to execute that query
    double timeParsing;
    
    // this will keep the information about the boundaries for the full layer.
    AGSEnvelope* realLayerfullEnvelope;
    
    AGSSymbol* highlightSymbol;
    
    AGSEnvelope* highlightShapesEnvelope;
    
    NSArray* labelSets;
    NSMutableArray* _labels;
    // Information about the layer
    BOOL _isParcel;
    BOOL _isStreet;
    BOOL _isWtrBdy;
    
    // Special case to display all the info about a parcel
    TabMapDetail *mapDetail;
}
@property (nonatomic) BOOL isParcel;
@property (nonatomic) BOOL isStreet;
@property (nonatomic) BOOL isWtrBdy;


@property (nonatomic, assign) BOOL showAnnotationPolygonContainers;

@property (nonatomic, assign) BOOL showShapes;
@property (nonatomic, assign) BOOL showLabels;
@property (nonatomic, assign) BOOL scaleLabels;
@property (nonatomic, assign) BOOL clipping;
@property (nonatomic, assign) BOOL removeLabelDuplicates;
@property (nonatomic, assign) double timeQuery;
@property (nonatomic, assign) double timeParsing;

@property (nonatomic, strong) NSArray* labelSets;
@property (nonatomic, strong) AGSTextSymbol* defaultLabelSymbol;
@property (nonatomic, strong) NSString* fontFamilyColumnName;
@property (nonatomic, strong) NSString* fontBoldColumnName;
@property (nonatomic, strong) NSString* fontSizeColumnName;
@property (nonatomic, strong) NSString* fontColorColumnName;
@property (nonatomic, strong) NSString* labelAngleColumnName;
@property (nonatomic, strong) NSString* labelColumnName;

@property (nonatomic, assign) double renderValueBreaker;
@property (nonatomic, strong) AGSSymbol* breakerSymbol;

@property (nonatomic, strong) NSMutableArray* selectedShapes;
@property (nonatomic, strong) NSMutableArray* selectedMarkers;
@property (nonatomic, strong) AGSSymbol* highlightSymbol;

@property (nonatomic, strong) AGSEnvelope* highlightShapesEnvelope;


// init the layer
-(id)initWithFilePath:(NSString*) filePath andTableName: (NSString*)table andGeoColName:(NSString*)columnName forMap: (AGSMapView*) map withConfig:(MapLayerConfig *)config;

// execute the current spatial query to retrieve the shapes that intersect the current viewport
-(void)executeGeographicQuery;
// Prepare the query
-(void)prepareGeographicQuery;

// sets the query and load the matching shapes in the layer. (THIS FUNCTION WAS NOT TESTED)
-(void)setQuery: (NSString*) query;

// remove the custom query, and allow to show again all the shapes
-(void)removeQuery;

// set a query quere only display shapes that are column has a value in the values array
-(void) filterByShapesWhereColumn: (NSString*)column hasValueIn:(NSArray*)values;

// Hightlight the shapes where the column contains a value in the values list.
-(NSArray*) highlightShapesWhereColumn: (NSString*)column hasValueIn:(NSArray*)values andIncludeTheAttributes:  (NSArray*)attributes;

-(void) performLabeling;

-(NSArray*)highlightShapes:(NSArray*)values withCenter:(NSArray *)centers;

// calculate all the centers
-(NSArray *)calculateCenterOfShape;
-(NSArray *)loadParcelCenters;

@end
