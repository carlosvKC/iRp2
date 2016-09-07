#import "SpatiaLiteLayer.h"
#include "shapefil.h"
#include "proj_api.h"
#include "shpgeo.h"
#include "prjopen.h"
#include "SQLite3.h"
#include "Spatialite.h"
#include "gaiageo.h"
#include "ColorPicker.h"
#import "RendererXmlLabel.h"
#import "TabMapDetail.h"

#import "TabMapController.h"
#import "MapLayerConfig.h"
#import "FMDatabase.h"
#import "RealPropertyApp.h"

#define LAYER_WATERBODY_MAX 25000

// ESRI MAPS PROJECTION
#define EPSG4326 "+proj=merc +lon_0=0 +k=1 +x_0=0 +y_0=0 +a=6378137 +b=6378137 +units=m +no_defs"
// King_County Projection
#define SRORG110 "+proj=lcc +lat_1=48.73333333333333 +lat_2=47.5 +lat_0=47 +lon_0=-120.8333333333333 +x_0=500000.0000000001 +y_0=0 +ellps=GRS80 +to_meter=0.3048006096012192 +no_defs"

 #define baseRandom() (arc4random() % 100) / 100.0f 

@implementation CenterOfShape

@synthesize x, y, realPropId;

@end


@interface SpatiaLiteLayer(privateMethods)
-(void)openSQLitefile:(NSString*) filePath forMap: (AGSMapView*) map withConfig:(MapLayerConfig *)config;
    -(void)respondToEnvChange: (NSNotification*) notification; // recalculate visible graphics base on the current visible region
    -(void)readQueryResultset;
    -(void)prepareGeographicQuery;
    -(void) readGeometryMetadata;
    -(void) readStyleMetadata;

    // parse geometries
- (AGSCompositeSymbol*) inlineTextSymbol: (NSMutableDictionary*)attributes;

-(void)parsePolygone:(gaiaGeomCollPtr) geo withAttributes: (NSMutableDictionary*)attributes;
-(void)parsePolyLine:(gaiaGeomCollPtr) geo withAttributes: (NSMutableDictionary*)attributes;
-(void)parsePoint:(gaiaGeomCollPtr) geo withAttributes: (NSMutableDictionary*)attributes;
@end

@implementation SpatiaLiteLayer

@synthesize showAnnotationPolygonContainers;
@synthesize showLabels = _showLabels;
@synthesize showShapes;
@synthesize clipping;
@synthesize removeLabelDuplicates;

@synthesize labelSets;
@synthesize defaultLabelSymbol;
@synthesize fontFamilyColumnName;
@synthesize fontBoldColumnName;
@synthesize fontSizeColumnName;
@synthesize fontColorColumnName;
@synthesize labelColumnName = _labelColumnName;
@synthesize labelAngleColumnName;

@synthesize renderValueBreaker;
@synthesize breakerSymbol;
@synthesize scaleLabels;

@synthesize selectedShapes;
@synthesize selectedMarkers;
@synthesize highlightSymbol;
@synthesize highlightShapesEnvelope;

@synthesize timeQuery;
@synthesize timeParsing;


@synthesize isParcel = _isParcel;
@synthesize isStreet = _isStreet;
@synthesize isWtrBdy = _isWtrBdy;

#pragma mark - Constructor

-(id)init
{
    self = [super init];
    if (self != NULL)
    {
        db = nil;
        //pj_conic = nil;
        //pj_latlong = nil;
        statement = nil;
        
        minResolution = 20;
        renderValueBreaker = 90000;
        breakerSymbol = self.renderSymbol;
        
        defaultLabelSymbol = nil;
        renderSymbol = nil;
        breakerSymbol = nil;
        realLayerfullEnvelope = nil;
        scaleLabels = NO;
        showShapes = YES;
        clipping = TRUE;
        customQuery = false;
        removeLabelDuplicates = false; // false because the catrastral need it in false, in the case of the st_address I will set it in try for that layer only.
        if (!(pj_conic = pj_init_plus(SRORG110)) )
            exit(1);
        if (!(pj_latlong = pj_init_plus(EPSG4326)) )
            exit(1);
        selectedShapes = [[NSMutableArray alloc] init];
        selectedMarkers = [[NSMutableArray alloc] init];
        
        _labels = [[NSMutableArray alloc] init];
        
        highlightSymbol = [AGSSimpleFillSymbol simpleFillSymbol];
        highlightSymbol.color = [UIColor colorWithRed:0.8 green:0.3 blue:0.3 alpha:0.5];
        ((AGSSimpleFillSymbol*)highlightSymbol).outline.color = [UIColor yellowColor];
        ((AGSSimpleFillSymbol*)highlightSymbol).style = AGSSimpleFillSymbolStyleSolid;
    }
    return self;
}

-(id)initWithFilePath:(NSString*) filePath andTableName: (NSString*)table andGeoColName:(NSString*)columnName forMap: (AGSMapView*) map withConfig:(MapLayerConfig *)config
{
    self = [self init];
    if (self != NULL)
    {
        tableName = table;
        geoColumnName = columnName;
        parentMap = map; 
        
        [self openSQLitefile:filePath forMap:parentMap withConfig:config];
        // register for "MapDidEndPanning" notifications
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(respondToEnvChange:)
                                                     name:@"MapDidEndPanning" object:nil];
        
        // register for "MapDidEndZooming" notifications
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(respondToEnvChange:) 
                                                     name:@"MapDidEndZooming" object:nil];
        
        labelsText = [[NSMutableArray alloc] init]; // labels = new NSMutableArray();
        
    }
    return self;
}
-(void)dealloc
{    
    // desregister of MapDidEndPanning and MapDidEndZooming
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"MapDidEndPanning" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"MapDidEndZooming" object:nil];
    
    if (statement != nil)
        sqlite3_finalize(statement);
    
    sqlite3_close(db);
}

#pragma mark - initialize layer
-(void)openSQLitefile:(NSString*)srcPath forMap:(AGSMapView*)map withConfig:(MapLayerConfig *)config
{
    int rc = sqlite3_open([srcPath cStringUsingEncoding:[NSString defaultCStringEncoding]], &db);
    if (rc )
    {
        NSLog(@"Could not open the database.");
    }
    [self readGeometryMetadata];
    // [self readStyleMetadata];
    [self readConfigMetadata:config];
    
    
    //load annotation classes
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"AnnotationClasses" ofType:@"plist"];
    AnnotationClasses = [[NSDictionary alloc] initWithContentsOfFile:filePath];
    if (self.labelColumnName != nil && [self.labelColumnName hasPrefix:@"${"])
    {
        self.defaultLabelSymbol = [AGSTextSymbol textSymbolWithTextTemplate:self.labelColumnName color:[UIColor blackColor]];
    }
    else 
    {
        if (self.labelColumnName == nil)
        {
            self.defaultLabelSymbol = [AGSTextSymbol textSymbolWithTextTemplate:[NSString stringWithFormat:@"%@", self.labelColumnName] color:[UIColor blackColor]];
        }
        else 
        {
            self.defaultLabelSymbol = [AGSTextSymbol textSymbolWithTextTemplate:[NSString stringWithFormat:@"${%@}", self.labelColumnName] color:[UIColor blackColor]];
        }
    }

    AGSCompositeSymbol * composeSymbol = [[AGSCompositeSymbol alloc] init];
    [composeSymbol.symbols addObject:self.renderSymbol];
    
    self.renderer = [AGSSimpleRenderer simpleRendererWithSymbol:composeSymbol];

}
//
// Read the geormety data
//
-(void) readGeometryMetadata
{
    NSString* wtkNAN83HARNWashintongNort = @"PROJCS[""NAD_1983_HARN_StatePlane_Washington_North_FIPS_4601_Feet"",GEOGCS[""GCS_North_American_1983_HARN"",DATUM[""D_North_American_1983_HARN"",SPHEROID[""GRS_1980"",6378137.0,298.257222101]],PRIMEM[""Greenwich"",0.0],UNIT[""Degree"",0.0174532925199433]],PROJECTION[""Lambert_Conformal_Conic""],PARAMETER[""False_Easting"",1640416.666666667],PARAMETER[""False_Northing"",0.0],PARAMETER[""Central_Meridian"",-120.8333333333333],PARAMETER[""Standard_Parallel_1"",47.5],PARAMETER[""Standard_Parallel_2"",48.73333333333333],PARAMETER[""Latitude_Of_Origin"",47.0],UNIT[""Foot_US"",0.3048006096012192]]";
    AGSSpatialReference* originalProjection = [AGSSpatialReference spatialReferenceWithWKT:wtkNAN83HARNWashintongNort];
    
    const char* pzTail;
    const char* command = [[NSString stringWithFormat:@"select type, ref_sys_name from geom_cols_ref_sys where  f_table_name = '%@' and f_geometry_column = '%@'", tableName, geoColumnName] cStringUsingEncoding:[NSString defaultCStringEncoding]];
    sqlite3_stmt* readgeometryMetadata;
    int rc = sqlite3_prepare_v2(db, command, strlen(command), &readgeometryMetadata, &pzTail);
    if(rc == SQLITE_OK)
    {
        int rc = sqlite3_step(readgeometryMetadata); 
        if (rc == SQLITE_ROW)
        {
            shapeType = [NSString stringWithCString:(char *)(char*)sqlite3_column_text(readgeometryMetadata, 0) encoding:[NSString defaultCStringEncoding]];
            
        }
    }
    sqlite3_finalize(readgeometryMetadata);

    const char* command2 = [[NSString stringWithFormat:@"select min(xmin) xmin, min(ymin) ymin, max(xmax) xmax, max(ymax) ymax from idx_%@_%@", tableName, geoColumnName] cStringUsingEncoding:[NSString defaultCStringEncoding]];
    
    rc = sqlite3_prepare_v2(db, command2, strlen(command2), &readgeometryMetadata, &pzTail);
    if(rc == SQLITE_OK)
    {
        int rc = sqlite3_step(readgeometryMetadata); 
        if (rc == SQLITE_ROW)
        {
            double xmin = sqlite3_column_double(readgeometryMetadata, 0);
            double ymin = sqlite3_column_double(readgeometryMetadata, 1);
            double xmax = sqlite3_column_double(readgeometryMetadata, 2);
            double ymax = sqlite3_column_double(readgeometryMetadata, 3);
            
            realLayerfullEnvelope = [[AGSEnvelope alloc] initWithXmin:xmin ymin:ymin xmax:xmax ymax:ymax spatialReference:originalProjection];
        }
    }
    sqlite3_finalize(readgeometryMetadata);
    
    self.initialEnvelope = parentMap.visibleArea.envelope;
}
-(void)readConfigMetadata:(MapLayerConfig *)config
{
    NSString* mainColor = config.fillColor; 
    NSString* borderColor = config.lineColor;
    
    titleColumnName = nil;
    descriptionColumName = nil;
    
    _labelColumnName = config.columnLabel;
    showLabels = config.showLabels;
    showShapes = config.showShapes;
    
    NSString* fontFamily = config.fontFamily;
    self.fontFamilyColumnName = config.fontFamilyColumnName;
    BOOL font_bold = config.bold;
    //
     self.fontBoldColumnName = config.bolColumnName;
    float font_size = config.labelFontSize;
    //
    self.fontSizeColumnName = config.labelFontSizeColumnName;
    NSString* fontColor = config.labelColor;
    self.fontColorColumnName = config.labelColorColumnName;
    
    double label_angle = config.labelAngle;
    self.labelAngleColumnName = config.labelAngleColumnName;
    
    double xmin = 0;
    double ymin = 0;
    double xmax = 0;
    double ymax = 0;
    
    NSString* wtkNAN83HARNWashintongNort = @"PROJCS[""NAD_1983_HARN_StatePlane_Washington_North_FIPS_4601_Feet"",GEOGCS[""GCS_North_American_1983_HARN"",DATUM[""D_North_American_1983_HARN"",SPHEROID[""GRS_1980"",6378137.0,298.257222101]],PRIMEM[""Greenwich"",0.0],UNIT[""Degree"",0.0174532925199433]],PROJECTION[""Lambert_Conformal_Conic""],PARAMETER[""False_Easting"",1640416.666666667],PARAMETER[""False_Northing"",0.0],PARAMETER[""Central_Meridian"",-120.8333333333333],PARAMETER[""Standard_Parallel_1"",47.5],PARAMETER[""Standard_Parallel_2"",48.73333333333333],PARAMETER[""Latitude_Of_Origin"",47.0],UNIT[""Foot_US"",0.3048006096012192]]";
    AGSSpatialReference* originalProjection = [AGSSpatialReference spatialReferenceWithWKT:wtkNAN83HARNWashintongNort];
    
    self.initialEnvelope = [AGSEnvelope envelopeWithXmin:xmin ymin:ymin xmax:xmax ymax:ymax spatialReference:originalProjection];
    // labels configuration
    if (self.labelColumnName.length != 0)
    {
        UIColor* labelDefaultColor = (fontColor)?[UIColor colorWithString:fontColor]:[UIColor blackColor];
        self.defaultLabelSymbol = [AGSTextSymbol textSymbolWithTextTemplate:[NSString stringWithFormat:@"${%@}", self.labelColumnName] color:labelDefaultColor];
        if (fontFamily != nil)
            self.defaultLabelSymbol.fontFamily = fontFamily;
        
        if (font_bold)
            self.defaultLabelSymbol.fontWeight = AGSTextSymbolFontWeightBold;
        else
            self.defaultLabelSymbol.fontWeight = AGSTextSymbolFontWeightNormal;
        
        if (font_size > 0)
            self.defaultLabelSymbol.fontSize = font_size;
        
        self.defaultLabelSymbol.angle = label_angle;
        
    }
    else 
    {
        self.defaultLabelSymbol = [AGSTextSymbol textSymbolWithTextTemplate:@"" color:[UIColor blackColor]];
        self.showLabels = false;
    }
    if (([shapeType compare:@"MULTILINESTRING" options:NSCaseInsensitiveSearch] == NSOrderedSame) || ([shapeType compare:@"LINESTRING" options:NSCaseInsensitiveSearch] == NSOrderedSame))
    {
        if (mainColor != nil && [mainColor length] > 0)
        {
            self.renderSymbol = [AGSSimpleLineSymbol simpleLineSymbolWithColor:[UIColor colorWithString:mainColor] width:1.0];
        }
        else 
        {
            self.renderSymbol = [AGSSimpleLineSymbol simpleLineSymbolWithColor:[UIColor colorWithRed:baseRandom() green:baseRandom() blue:baseRandom() alpha:0.9] width:1.0];
        }
    }
    else if (([shapeType compare:@"MULTIPOINT" options:NSCaseInsensitiveSearch] == NSOrderedSame) || ([shapeType compare:@"POINT" options:NSCaseInsensitiveSearch] == NSOrderedSame))
    {
        if (mainColor != nil && [mainColor length] > 0)
        {
            self.renderSymbol = [AGSSimpleMarkerSymbol simpleMarkerSymbolWithColor:[UIColor colorWithString:mainColor]];
        }
        else 
        {
            self.renderSymbol = [AGSSimpleMarkerSymbol simpleMarkerSymbolWithColor:[UIColor colorWithRed:baseRandom() green:baseRandom() blue:baseRandom() alpha:0.9]];
        }
    }
    else // is a polygon
    {
        self.renderSymbol = [AGSSimpleFillSymbol simpleFillSymbol];
        if (mainColor != nil && [mainColor length] > 0)
        {
            self.renderSymbol.color = [UIColor colorWithString:mainColor];
        }
        else 
        {
            
            self.renderSymbol.color = [UIColor colorWithRed:baseRandom() green:baseRandom() blue:baseRandom() alpha:0.5];
        }
        if (borderColor != nil && [borderColor length] > 0)
        {
            ((AGSSimpleFillSymbol*)self.renderSymbol).outline.color = [UIColor colorWithString:borderColor];
        }
        else
        {
            ((AGSSimpleFillSymbol*)self.renderSymbol).outline.color = [UIColor blackColor];
        }
        ((AGSSimpleFillSymbol*)self.renderSymbol).style = AGSSimpleFillSymbolStyleSolid;
    }

    if (self.renderSymbol == nil)
    {
        if (([shapeType compare:@"MULTILINESTRING" options:NSCaseInsensitiveSearch] == NSOrderedSame) || ([shapeType compare:@"LINESTRING" options:NSCaseInsensitiveSearch] == NSOrderedSame))
        {
            self.renderSymbol = [AGSSimpleLineSymbol simpleLineSymbolWithColor:[UIColor colorWithRed:baseRandom() green:baseRandom()  blue:baseRandom()  alpha:0.9] width:1.0];
        }
        else if (([shapeType compare:@"MULTIPOINT" options:NSCaseInsensitiveSearch] == NSOrderedSame) || ([shapeType compare:@"POINT" options:NSCaseInsensitiveSearch] == NSOrderedSame))
        {
            self.renderSymbol = [AGSSimpleMarkerSymbol simpleMarkerSymbolWithColor:[UIColor colorWithRed:baseRandom()  green:baseRandom()  blue:baseRandom()  alpha:0.9] ];
        }
        else 
        {// is a polygon
            self.renderSymbol = [AGSSimpleFillSymbol simpleFillSymbol];
            self.renderSymbol.color = [UIColor colorWithRed:baseRandom()  green:baseRandom()  blue:baseRandom()  alpha:0.5];
            ((AGSSimpleFillSymbol*)self.renderSymbol).style = AGSSimpleFillSymbolStyleSolid;
        }
    }
    
}
#pragma mark - set query and highlight

-(void)setQuery: (NSString*) query
{
    // 1 301 900.051 - 213 605.859,  1 302 850.412 - 211 538.690
    const char* pzTail;
    const char* command = [query cStringUsingEncoding:[NSString defaultCStringEncoding]];
    customQuery = true;
    int rc = sqlite3_prepare_v2(db, command, strlen(command), &statement, &pzTail);
    if(rc == SQLITE_OK)
    {
        [self executeGeographicQuery];
    }
    self->_loaded = true;
    [self dataChanged];
}

-(void)removeQuery
{
    customQuery = false;
    [self prepareGeographicQuery];
}

// Query the sqlite database to retrieve the centers and Id and envelope of the shapes where the column containing any the values
// Return the list of AGSGraphics that are AGSPoint of the center of the envelopes and with the pkuid as only attribute, the symbol in this AGSGraphics is null.
#define _ALTITUDE_CUTOFF    7000
#ifdef _ZORRO_
-(NSArray*) highlightShapesWhereColumn: (NSString*)column hasValueIn:(NSArray*)values andIncludeTheAttributes:  (NSArray*)attributes
{
    const char* pzTail;
    NSString* strCommand = NULL;
    sqlite3_stmt* sqlcommand = NULL;

    if (values != NULL && [values count] > 0)
    {
        strCommand = @"select RealPropId, xmin, ymin, xmax, ymax";
        // strCommand = [NSString stringWithFormat: @"select RealPropId, xmin, ymin, xmax, ymax, %@", geoColumnName];
        if (attributes != NULL && [attributes count] > 0)
        {
            for (NSString* attribute in attributes) 
            {
                strCommand = [strCommand stringByAppendingFormat:@" ,%@", attribute];
            }
        }
        strCommand = [strCommand stringByAppendingFormat:@" from %@ inner join idx_%@_%@ on pkuid = pkid where %@ in (", tableName, tableName, geoColumnName, column];
        
        for (int i = 0; i < [values count]; i++) 
        {
            strCommand = [strCommand stringByAppendingFormat:@"'%@'", [values objectAtIndex:i]];
            if (i < [values count] - 1) 
            {
                strCommand = [strCommand stringByAppendingFormat:@",", [values objectAtIndex:i]];
            }
        }
        strCommand = [strCommand stringByAppendingString:@")"];
        
        const char* command =[strCommand cStringUsingEncoding:[NSString defaultCStringEncoding]];
        int rc = sqlite3_prepare_v2(db, command, strlen(command), &sqlcommand, &pzTail);
        if(rc != SQLITE_OK)
        {
            NSLog(@"3 Error executing spatialite query. %@",[NSString stringWithCString:(char *)sqlite3_errmsg(db) encoding:[NSString defaultCStringEncoding]] );
            sqlite3_finalize(sqlcommand);
            sqlcommand = nil;
        }
        
        // start reading results if any
        @try 
        {
            rc = sqlite3_step(sqlcommand);
            if (rc == SQLITE_ERROR)
            {
                NSLog(@"Error: %@", [NSString stringWithCString:(char *)sqlite3_errmsg(db) encoding:[NSString defaultCStringEncoding]]);
            }
            else 
            {
                [selectedShapes removeAllObjects];
                [selectedMarkers removeAllObjects];
            }
            
            self.highlightShapesEnvelope = NULL; 
            double xmin = MAXFLOAT, ymin = MAXFLOAT, xmax = -MAXFLOAT, ymax = -MAXFLOAT;
            while (rc == SQLITE_ROW ) 
            {
                int value = sqlite3_column_int(sqlcommand, 0);
                [selectedShapes addObject:[NSNumber numberWithInt:value]];
                double envxmin = sqlite3_column_double(sqlcommand, 1);
                double envymin = sqlite3_column_double(sqlcommand, 2);
                double envxmax = sqlite3_column_double(sqlcommand, 3);
                double envymax = sqlite3_column_double(sqlcommand, 4);
                
                // Read the geometry
                const unsigned char* blob = sqlite3_column_text(sqlcommand, 5);
                int blobsize = sqlite3_column_bytes(sqlcommand, 5);
                gaiaGeomCollPtr geo = gaiaFromSpatiaLiteBlobWkb(blob, blobsize);
                // generate geometry
                int geoType = gaiaGeometryType(geo);
                AGSMutablePolygon *polygon = nil;

                if (geoType == GAIA_POLYGON || geoType == GAIA_MULTIPOLYGON) 
                {
                    polygon = [self parsePolygone:geo->FirstPolygon];
                }
                
                gaiaFreeGeomColl(geo);
                
                
                xmin = MIN(xmin, envxmin);
                ymin = MIN(ymin, envymin);
                xmax = MAX(xmax, envxmax);
                ymax = MAX(ymax, envymax);
                
                // AGSEnvelope* shapeEnvelope = [[AGSEnvelope alloc] initWithXmin:envxmin ymin:envymin xmax:envxmax ymax:envymax spatialReference:self.spatialReference];
                // AGSPoint* center = [shapeEnvelope center];
                AGSGeometryEngine *ge = [AGSGeometryEngine defaultGeometryEngine];
                AGSPoint *center = [ge labelPointForPolygon:polygon];
                NSMutableDictionary* attsForPushPin = [[NSMutableDictionary alloc] init];
                [attsForPushPin setValue:[NSNumber numberWithInt:value] forKey:@"RealPropId"];
                if (attributes != NULL && [attributes count] > 0)
                {
                    int idx = 5;
                    for (NSString* attribute in attributes) 
                    {
                        int coltype = sqlite3_column_type(sqlcommand, idx);
                        switch (coltype) {
                            case SQLITE_INTEGER:
                                [attsForPushPin setValue:[NSNumber numberWithInt:sqlite3_column_int(sqlcommand,idx)] forKey:attribute];
                                break;
                             case SQLITE_FLOAT:
                                [attsForPushPin setValue:[NSNumber numberWithDouble:sqlite3_column_double(sqlcommand,idx)] forKey:attribute];
                                break;
                            case SQLITE_TEXT:
                                [attsForPushPin setValue:[NSString stringWithCString:(char *)sqlite3_column_text(sqlcommand,idx)  encoding:[NSString defaultCStringEncoding]] forKey:attribute];
                                break;
                           
                            default:
                                break;
                        }
                        idx ++;
                    }
                }
                AGSGraphic* marker = [[AGSGraphic alloc] initWithGeometry:center symbol:NULL attributes:attsForPushPin infoTemplateDelegate:self];
                [selectedMarkers addObject:marker];
                // get next row
                double t = CACurrentMediaTime();
                rc = sqlite3_step(sqlcommand);
                
                timeQuery += (CACurrentMediaTime() - t);
                
                if (rc == SQLITE_ERROR)
                {
                    NSLog(@"Error: %@", [NSString stringWithCString:(char *)sqlite3_errmsg(db) encoding:[NSString defaultCStringEncoding]]);
                }
                
            }
            
            self.highlightShapesEnvelope = [AGSEnvelope envelopeWithXmin:xmin ymin:ymin xmax:xmax ymax:ymax spatialReference:self.initialEnvelope.spatialReference];
        }
        @catch (NSException *exception) 
        {
            NSLog(@"exception was occur reading the query result. %@", [exception name]);
        }
        @finally 
        {
            sqlite3_finalize(sqlcommand);
        }
        [self executeGeographicQuery];
        return selectedMarkers;
    }
}
#endif


-(NSArray*) highlightShapesWhereColumn: (NSString*)column hasValueIn:(NSArray*)values andIncludeTheAttributes:(NSArray*)attributes
{
    const char* pzTail;
    NSString* strCommand = NULL;
    sqlite3_stmt* sqlcommand = NULL;
    
    if (values != NULL && [values count] > 0)
    {
        strCommand = @"select RealPropId, xmin, ymin, xmax, ymax";
        if (attributes != NULL && [attributes count] > 0)
        {
            for (NSString* attribute in attributes) 
            {
                strCommand = [strCommand stringByAppendingFormat:@" ,%@", attribute];
            }
        }
        strCommand = [strCommand stringByAppendingFormat:@" from %@ inner join idx_%@_%@ on %@.rowId = pkid where %@ in (",  tableName, tableName, geoColumnName, tableName, column];
        
        for (int i = 0; i < [values count]; i++) 
        {
            strCommand = [strCommand stringByAppendingFormat:@"'%@'", [values objectAtIndex:i]];
            if (i < [values count] - 1) 
            {
                strCommand = [strCommand stringByAppendingFormat:@",%@", [values objectAtIndex:i]];
            }
        }
        strCommand = [strCommand stringByAppendingString:@")"];
        
        const char* command =[strCommand cStringUsingEncoding:[NSString defaultCStringEncoding]];
        int rc = sqlite3_prepare_v2(db, command, strlen(command), &sqlcommand, &pzTail);
        if(rc != SQLITE_OK)
        {
            NSLog(@"5 Error executing spatialite query. %@",[NSString stringWithCString:(char *)sqlite3_errmsg(db) encoding:[NSString defaultCStringEncoding]] );
            sqlite3_finalize(sqlcommand);
            sqlcommand = nil;
        }
        
        // start reading results if any
        @try 
        {
            rc = sqlite3_step(sqlcommand);
            if (rc == SQLITE_ERROR)
            {
                NSLog(@"Error: %@", [NSString stringWithCString:(char *)sqlite3_errmsg(db) encoding:[NSString defaultCStringEncoding]]);
            }
            else 
            {
                [selectedShapes removeAllObjects];
                [selectedMarkers removeAllObjects];
            }
            
            self.highlightShapesEnvelope = NULL; 
            double xmin = MAXFLOAT, ymin = MAXFLOAT, xmax = -MAXFLOAT, ymax = -MAXFLOAT;
            while (rc == SQLITE_ROW ) 
            {
                int value = sqlite3_column_int(sqlcommand, 0);
                [selectedShapes addObject:[NSNumber numberWithInt:value]];
                double envxmin = sqlite3_column_double(sqlcommand, 1);
                double envymin = sqlite3_column_double(sqlcommand, 2);
                double envxmax = sqlite3_column_double(sqlcommand, 3);
                double envymax = sqlite3_column_double(sqlcommand, 4);
                xmin = MIN(xmin, envxmin);
                ymin = MIN(ymin, envymin);
                xmax = MAX(xmax, envxmax);
                ymax = MAX(ymax, envymax);
                
                AGSEnvelope* shapeEnvelope = [[AGSEnvelope alloc] initWithXmin:envxmin ymin:envymin xmax:envxmax ymax:envymax spatialReference:self.spatialReference];
                AGSPoint* center = [shapeEnvelope center];
                NSMutableDictionary* attsForPushPin = [[NSMutableDictionary alloc] init];
                [attsForPushPin setValue:[NSNumber numberWithInt:value] forKey:@"RealPropId"];
                if (attributes != NULL && [attributes count] > 0)
                {
                    int idx = 5;
                    for (NSString* attribute in attributes) 
                    {
                        int coltype = sqlite3_column_type(sqlcommand, idx);
                        switch (coltype) {
                            case SQLITE_INTEGER:
                                [attsForPushPin setValue:[NSNumber numberWithInt:sqlite3_column_int(sqlcommand,idx)] forKey:attribute];
                                break;
                            case SQLITE_FLOAT:
                                [attsForPushPin setValue:[NSNumber numberWithDouble:sqlite3_column_double(sqlcommand,idx)] forKey:attribute];
                                break;
                            case SQLITE_TEXT:
                                [attsForPushPin setValue:[NSString stringWithCString:(char *)sqlite3_column_text(sqlcommand,idx)  encoding:[NSString defaultCStringEncoding]] forKey:attribute];
                                break;
                                
                            default:
                                break;
                        }
                        idx ++;
                    }
                }
                AGSGraphic* marker = [[AGSGraphic alloc] initWithGeometry:center symbol:NULL attributes:attsForPushPin infoTemplateDelegate:self];
                [selectedMarkers addObject:marker];
                // get next row
                double t = CACurrentMediaTime();
                rc = sqlite3_step(sqlcommand);
                
                timeQuery += (CACurrentMediaTime() - t);
                
                if (rc == SQLITE_ERROR)
                {
                    NSLog(@"Error: %@", [NSString stringWithCString:(char *)sqlite3_errmsg(db) encoding:[NSString defaultCStringEncoding]]);
                }
                
            }
            
            self.highlightShapesEnvelope = [AGSEnvelope envelopeWithXmin:xmin ymin:ymin xmax:xmax ymax:ymax spatialReference:self.initialEnvelope.spatialReference];
        }
        @catch (NSException *exception) 
        {
            NSLog(@"exception was occur reading the query result. %@", [exception name]);
        }
        @finally 
        {
            sqlite3_finalize(sqlcommand);
        }

        return selectedMarkers;
    }
}
-(NSArray*)highlightShapes:(NSArray*)values withCenter:(NSArray *)centers
{
        // start reading results if any
    @try 
    {
       [selectedShapes removeAllObjects];
       [selectedMarkers removeAllObjects];
        self.highlightShapesEnvelope = NULL; 

        double xmin = MAXFLOAT, ymin = MAXFLOAT, xmax = -MAXFLOAT, ymax = -MAXFLOAT;
        
        for(int index=0;index<values.count;index++)
        {
            int realPropId = [[values objectAtIndex:index]intValue];
            CenterOfShape *foundShape = nil;
            // Look for the object
            for(CenterOfShape *shape in centers)
            {
                if(shape.realPropId == realPropId)
                {
                    foundShape = shape;
                    break;
                }
            }
            if(foundShape==nil)
                continue;

            [selectedShapes addObject:[NSNumber numberWithInt:realPropId]];

            xmin = MIN(xmin, foundShape.x);
            ymin = MIN(ymin, foundShape.y);
            xmax = MAX(xmax, foundShape.x);
            ymax = MAX(ymax, foundShape.y);
            
            NSMutableDictionary* attsForPushPin = [[NSMutableDictionary alloc] init];
            [attsForPushPin setValue:[NSNumber numberWithInt:realPropId] forKey:@"RealPropId"];

            AGSPoint *point = [[AGSPoint alloc]initWithX:foundShape.x y:foundShape.y spatialReference:self.spatialReference];
            
            AGSGraphic* marker = [[AGSGraphic alloc] initWithGeometry:point symbol:NULL attributes:attsForPushPin infoTemplateDelegate:self];
            [selectedMarkers addObject:marker];
        }
        int milesBorder  = MAX((xmax-xmin), (ymax-ymin)) * 0.20;
        self.highlightShapesEnvelope = [AGSEnvelope envelopeWithXmin:xmin-milesBorder ymin:ymin-milesBorder xmax:xmax+milesBorder ymax:ymax+milesBorder spatialReference:self.initialEnvelope.spatialReference];
       
    }
    @catch (NSException *exception) 
    {
        NSLog(@"exception was occur reading the query result. %@", [exception name]);
    }        
    return selectedMarkers;
}
//
// Return the centers for all the shapes. If the centers do not exist, then it returns 0
//
-(NSArray *)loadParcelCenters
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    
    
    NSString *fileName;
    fileName = [documentDirectory stringByAppendingFormat:@"/%@.Centers.sqlite",[RealPropertyApp getWorkingPath]];

    FMDatabase *dbPath = [FMDatabase databaseWithPath:fileName];
    
    if (![dbPath open]) 
    {
        return nil;
    }
    NSMutableArray *results = [[NSMutableArray alloc]init];
    FMResultSet *rs = [dbPath executeQuery:@"select * from centers "];
    while ([rs next]) 
    {
        CenterOfShape *center = [[CenterOfShape alloc]init];
        center.realPropId = [rs intForColumn:@"RealPropId"];
        center.x = [rs doubleForColumn:@"x"];
        center.y = [rs doubleForColumn:@"y"];
        [results addObject:center];
    }
    [rs close];  
    [dbPath close];
    return results;
}

//
// Calculate the center of all the shapes and add them to new table
//
-(NSArray *)calculateCenterOfShape
{
    const char* pzTail;
    NSString* strCommand = NULL;
    sqlite3_stmt* sqlcommand = NULL;
    
    NSMutableArray *results = [[NSMutableArray alloc]init];
    
    strCommand = [NSString stringWithFormat:@"select RealPropId, xmin, ymin, xmax, ymax from %@ inner join idx_%@_%@ on %@.rowId = pkid",  tableName, tableName, geoColumnName, tableName];
    
    
    const char* command =[strCommand cStringUsingEncoding:[NSString defaultCStringEncoding]];
    int rc = sqlite3_prepare_v2(db, command, strlen(command), &sqlcommand, &pzTail);
    if(rc != SQLITE_OK)
    {
        NSLog(@"5 Error executing spatialite query. %@",[NSString stringWithCString:(char *)sqlite3_errmsg(db) encoding:[NSString defaultCStringEncoding]] );
        sqlite3_finalize(sqlcommand);
        sqlcommand = nil;
    }
    
    // start reading results if any
    @try 
    {
        rc = sqlite3_step(sqlcommand);
        if (rc == SQLITE_ERROR)
        {
            NSLog(@"Error: %@", [NSString stringWithCString:(char *)sqlite3_errmsg(db) encoding:[NSString defaultCStringEncoding]]);
        }
        else 
        {
            [selectedShapes removeAllObjects];
            [selectedMarkers removeAllObjects];
        }
        
        self.highlightShapesEnvelope = NULL; 
        double xmin = MAXFLOAT, ymin = MAXFLOAT, xmax = -MAXFLOAT, ymax = -MAXFLOAT;
        while (rc == SQLITE_ROW ) 
        {
            int value = sqlite3_column_int(sqlcommand, 0);
            [selectedShapes addObject:[NSNumber numberWithInt:value]];
            double envxmin = sqlite3_column_double(sqlcommand, 1);
            double envymin = sqlite3_column_double(sqlcommand, 2);
            double envxmax = sqlite3_column_double(sqlcommand, 3);
            double envymax = sqlite3_column_double(sqlcommand, 4);
            xmin = MIN(xmin, envxmin);
            ymin = MIN(ymin, envymin);
            xmax = MAX(xmax, envxmax);
            ymax = MAX(ymax, envymax);
            
            AGSEnvelope* shapeEnvelope = [[AGSEnvelope alloc] initWithXmin:envxmin ymin:envymin xmax:envxmax ymax:envymax spatialReference:self.spatialReference];
            AGSPoint* center = [shapeEnvelope center];
            
            CenterOfShape *objectCenter = [[CenterOfShape alloc]init];
            objectCenter.x = center.x;
            objectCenter.y = center.y;
            objectCenter.realPropId = value;
            [results addObject:objectCenter];

            // get next row

            rc = sqlite3_step(sqlcommand);

            
            if (rc == SQLITE_ERROR)
            {
                NSLog(@"Error: %@", [NSString stringWithCString:(char *)sqlite3_errmsg(db) encoding:[NSString defaultCStringEncoding]]);
            }
            
        }
    }
    @catch (NSException *exception) 
    {
        NSLog(@"exception was occur reading the query result. %@", [exception name]);
    }
    @finally 
    {
        sqlite3_finalize(sqlcommand);
    }
    [self storeCenters:results];
    return results;

}
// Store the centers in the database
-(void)storeCenters:(NSArray *)centers
{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    
    
    NSString *fileName;
    fileName = [documentDirectory stringByAppendingFormat:@"/%@.Centers.sqlite",[RealPropertyApp getWorkingPath]];
    
    // Create a new database, assume that it does not exist yet
    // delete the old db.
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:fileName error:nil];
    
    FMDatabase *dbPath = [FMDatabase databaseWithPath:fileName];
    
    
    if (![dbPath open]) 
    {
        NSLog(@"Could not open db.");
        return ;
    }
    [dbPath executeUpdate:@"create table centers (realPropId integer, x double, y double)"];
    
    [dbPath beginTransaction];
    for(CenterOfShape *center in centers)
    {
        [dbPath executeUpdate:@"insert into centers (realPropId, x, y) values (?, ?, ?)" ,
             [NSNumber numberWithInt:center.realPropId],
             [NSNumber numberWithFloat:center.x],
             [NSNumber numberWithFloat:center.y]
         ];
    }
    [dbPath commit];
    
    [dbPath close];
}

-(void) filterByShapesWhereColumn: (NSString*)column hasValueIn:(NSArray*)values
{
    NSString* strCommand = NULL;
    if (values != NULL && [values count] > 0)
    {
        strCommand = [NSString stringWithFormat:@"select * from %@ where %@ in (", tableName, column];
        
        for (int i = 0; i < [values count]; i++) {
            strCommand = [strCommand stringByAppendingFormat:@"'%@'", [values objectAtIndex:i]];
            if (i < [values count] - 1) {
                strCommand = [strCommand stringByAppendingFormat:@",%@", [values objectAtIndex:i]];
            }
        }
        strCommand = [strCommand stringByAppendingString:@")"];
        [self setQuery:strCommand];
    }
}

#pragma mark - spatial query execution
-(void)prepareGeographicQuery
{
    if (!customQuery)
    {
        if (statement != nil)
            sqlite3_finalize(statement);
        
        const char* pzTail;
        NSString* strCommand = NULL;
        
        if(_isWtrBdy)
        {
            NSString *st_level;
            
            double zoomLevel = parentMap.mapScale;
            
            if(zoomLevel >= LAYER_WATERBODY_MAX)
            {
                st_level = @"SUBSET_CD >= 1";
            }
            else
            {
                st_level = @"1=1";
            }
            
            strCommand = [NSString stringWithFormat:@"select GEOMETRY from %@ where %@ AND ROWID in (select pkid from idx_%@_%@ WHERE ((xmin >= ?1 and xmin <= ?3) or (xmax >= ?1 and xmax <= ?3) or (xmin <= ?1 and xmax >= ?3)) and ((ymin >= ?2 and ymin <= ?4) or (ymax >= ?2 and ymax <= ?4) or (ymin <= ?2 and ymax >= ?4)))", tableName, st_level, tableName, geoColumnName ];
        }
        // Code to filter the streets based on the general scale 
        // Removed: too much dependences on data structure
        else if(_isStreet)
        {
            NSString* st_type = @"";

            double zoomLevel = parentMap.mapScale; 
            if(zoomLevel >= 100000)
            {
                st_type = @"(KC_FCC='F' AND FULLNAME<>'RAMP')";
            }
            else if(zoomLevel >=50000)
            {
                st_type = @"((KC_FCC='M' OR KC_FCC='F') AND FULLNAME<>'RAMP')";
            }
            else if(zoomLevel >=25000)
            {
                st_type = @"(KC_FCC='M' OR KC_FCC='F' OR KC_FCC='P')";
            }
            else
                st_type = @"1=1";
            
            strCommand = [NSString stringWithFormat:@"select * from %@ where %@ AND ROWID in (select pkid from idx_%@_%@ WHERE ((xmin >= ?1 and xmin <= ?3) or (xmax >= ?1 and xmax <= ?3) or (xmin <= ?1 and xmax >= ?3)) and ((ymin >= ?2 and ymin <= ?4) or (ymax >= ?2 and ymax <= ?4) or (ymin <= ?2 and ymax >= ?4)))", tableName, st_type, tableName, geoColumnName ]; 
        }
        else if (_isParcel)
        {
             strCommand = [NSString stringWithFormat:@"select * from %@ where %@.ROWID in (select pkid from idx_%@_%@ WHERE ((xmin >= ?1 and xmin <= ?3) or (xmax >= ?1 and xmax <= ?3) or (xmin <= ?1 and xmax >= ?3)) and ((ymin >= ?2 and ymin <= ?4) or (ymax >= ?2 and ymax <= ?4) or (ymin <= ?2 and ymax >= ?4)))", tableName, tableName, tableName, geoColumnName ];
        }
        else
        {
            strCommand = [NSString stringWithFormat:@"select * from %@ where ROWID in (select pkid from idx_%@_%@ WHERE ((xmin >= ?1 and xmin <= ?3) or (xmax >= ?1 and xmax <= ?3) or (xmin <= ?1 and xmax >= ?3)) and ((ymin >= ?2 and ymin <= ?4) or (ymax >= ?2 and ymax <= ?4) or (ymin <= ?2 and ymax >= ?4)))", tableName, tableName, geoColumnName ];
        }
        
        const char* command =[strCommand cStringUsingEncoding:[NSString defaultCStringEncoding]];
        int rc = sqlite3_prepare_v2(db, command, strlen(command), &statement, &pzTail);
        if(rc != SQLITE_OK)
        {
            NSLog(@"6 Error executing spatialite query. %@",[NSString stringWithCString:(char *)sqlite3_errmsg(db) encoding:[NSString defaultCStringEncoding]] );
            sqlite3_finalize(statement);
            statement = nil;
        }
    }
}

-(void)executeGeographicQuery
{
    double xmax,xmin, ymax, ymin;
    UIView<AGSLayerView>* layerView =  [[parentMap mapLayerViews] objectForKey:self.name];
   
    if (layerView != nil && ![layerView isHidden] && realLayerfullEnvelope != nil && parentMap != nil && labelsText != nil)
    {
       if(
          ((realLayerfullEnvelope != nil && [realLayerfullEnvelope intersectsWithEnvelope:parentMap.visibleArea.envelope] ) 
          &&  (parentMap.mapScale <= self.minScale && parentMap.mapScale >= self.maxScale))
          || customQuery)
        {
            [labelsText removeAllObjects];
            @try 
            {
                if(self.clipping)
                {
                    xmax = parentMap.visibleArea.envelope.xmax;
                    xmin = parentMap.visibleArea.envelope.xmin;
                    ymax = parentMap.visibleArea.envelope.ymax;
                    ymin = parentMap.visibleArea.envelope.ymin;
                }
                else
                {
                    // Here we need the full envelope -- those values are King COunty only!
                    // Note: we need to get them programatically! (See DanielR)
                    xmax = 1688545.234;
                    xmin = 981108;
                    ymax = 401236.469;
                    ymin = -7893.896;
                }
                self->_loaded = false;
                //AGSGraphicsLayerDrawingOperation* op = self->_currentOperation;
                //[op 
                if(statement!=nil && self.clipping)
                {
                    //sqlite3_stmt_status(<#sqlite3_stmt *#>, <#int op#>, <#int resetFlg#>)
                    sqlite3_reset(statement);
                    sqlite3_clear_bindings(statement);
                    sqlite3_bind_double(statement, 1, xmin);
                    sqlite3_bind_double(statement, 2, ymin);
                    sqlite3_bind_double(statement, 3, xmax);
                    sqlite3_bind_double(statement, 4, ymax);
                }
                
                [layerView setHidden:YES];
                double currentMinScale = self.minScale;
                self.minScale = 0.1;
                [self dataChanged];
                [self removeAllGraphics];
                if ((parentMap.mapScale <= currentMinScale && parentMap.mapScale >= self.maxScale) || currentMinScale==0 || customQuery)
                {
                    [self readQueryResultset];
                }
                [layerView setHidden:NO];
                self.minScale = currentMinScale;
                [self performLabeling];
                self->_loaded = true;
                [self dataChanged];
            }
            @catch (NSException *exception) 
            {
                NSLog(@"Error executing geoquery. %@", [exception name]);
            }
        }
    }
}

// recalculate visible graphics base on the current visible region
-(void)respondToEnvChange: (NSNotification*) notification 
{
    // Start to read the data -- start
    UIView<AGSLayerView>* layerView =  [[parentMap mapLayerViews] objectForKey:self.name];
    if (![layerView isHidden] && !customQuery)
    {		  
        sqlite3_finalize(statement);
        statement = nil;
        [self prepareGeographicQuery];

        if(self.clipping)
        {
            if ((parentMap.mapScale <= self.minScale && parentMap.mapScale >= self.maxScale) || self.minScale==0)
            {
                [self executeGeographicQuery];
            }
            else 
            {
                if ([[notification name] compare:@"MapDidEndZooming"] == NSOrderedSame) 
                {
                    [self performLabeling];
                }
            }
        }
    }
}

-(void)readQueryResultset
{
    @try 
    {
        int rc = sqlite3_step(statement);
        if (rc == SQLITE_ERROR)
        {
            NSLog(@"Error: %@", [NSString stringWithCString:(char *)sqlite3_errmsg(db) encoding:[NSString defaultCStringEncoding]]);
        }        timeQuery = CACurrentMediaTime() - timeQuery;
        
        int columns = sqlite3_column_count(statement);
        // while are not done or error.
        
        timeParsing = 0;
        
         while (rc == SQLITE_ROW ) 
        {
            double startParsing = CACurrentMediaTime();
            
            NSMutableDictionary* attributes =[NSMutableDictionary dictionaryWithCapacity:columns-1];
            int geoColumnIndex = -1;
            
            for (int j = 0; j < columns; j++) 
            {
                int coltype = sqlite3_column_type(statement, j);
                const char* columnName = sqlite3_column_name(statement, j);
                if (coltype != SQLITE_BLOB)
                {
                    if (columnName != nil)
                    {
                        NSString* colNameKey = [NSString stringWithCString:(char *)columnName encoding:[NSString defaultCStringEncoding]];

                        switch (coltype)
                        {
                            case SQLITE_INTEGER:
                                [attributes setValue:[NSNumber numberWithInt:sqlite3_column_int(statement,j)] forKey:colNameKey];
                                break;
                            case SQLITE_FLOAT:
                                [attributes setValue:[NSNumber numberWithDouble:sqlite3_column_double(statement,j)] forKey:colNameKey];
                                break;
                            case SQLITE_TEXT:
                                [attributes setValue:[NSString stringWithCString:(char *)sqlite3_column_text(statement,j)  encoding:[NSString defaultCStringEncoding]] forKey:colNameKey];
                                break;
                                
                            default:
                                break;
                        }
                    }
                }
                else
                {
                    if (strcmp(columnName, [geoColumnName cStringUsingEncoding:[NSString defaultCStringEncoding]]) == 0)
                    {
                        geoColumnIndex = j;
                    }
                } 
            }
            
            self.attributeNames = [attributes allKeys];
            if (geoColumnIndex != -1)
            {
                const unsigned char* blob = sqlite3_column_text(statement, geoColumnIndex);
                int blobsize = sqlite3_column_bytes(statement, geoColumnIndex);
                gaiaGeomCollPtr geo = gaiaFromSpatiaLiteBlobWkb(blob, blobsize);
                // generate geometry
                int geoType = gaiaGeometryType(geo);
                if (geoType == GAIA_POINT || geoType == GAIA_MULTIPOINT)
                {
                    [self parsePoint:geo withAttributes:attributes];
                }
                else if (geoType == GAIA_LINESTRING || geoType == GAIA_MULTILINESTRING) 
                {
                    [self parsePolyLine:geo withAttributes:attributes];
                }
                else if (geoType == GAIA_POLYGON || geoType == GAIA_MULTIPOLYGON) 
                {
                    [self parsePolygone:geo withAttributes:attributes];
                }
                
                gaiaFreeGeomColl(geo);
            }
            timeParsing += (CACurrentMediaTime() - startParsing);
            
            // get next row
            double t = CACurrentMediaTime();
            rc = sqlite3_step(statement);
            
            timeQuery += (CACurrentMediaTime() - t);
            
            if (rc == SQLITE_ERROR)
            {
                NSLog(@"Error: %@", [NSString stringWithCString:(char *)sqlite3_errmsg(db) encoding:[NSString defaultCStringEncoding]]);
            }
            
        }
        
    }
    @catch (NSException *exception) 
    {
        NSLog(@"exception was occur reading the query result. %@", [exception name]);
    }     
}

#pragma mark - parsing

-(AGSCompositeSymbol*) inlineTextSymbol: (NSMutableDictionary*)attributes
{
    AGSCompositeSymbol* returnSymbol = nil;
    AGSTextSymbol* textSymbol = nil;
    
    if (showLabels && self.labelColumnName != nil)
    {
        int override = 0; //by default don't override anything
        if ([attributeNames containsObject:@"OVERRIDE"])
        {
            //override =  [[attributes valueForKey:@"OVERRIDE"] intValue];
        }
        int annotationId = 0;
        NSDictionary* annotationClass = nil;
        if ([attributeNames containsObject:@"ANNOTATION"])
        {
            annotationId =  [[attributes valueForKey:@"ANNOTATION"] intValue];
            annotationClass = [AnnotationClasses valueForKey:[NSString stringWithFormat:@"%d", annotationId]];
            
        }
        
        returnSymbol = [[AGSCompositeSymbol alloc] init];
        UIColor* fontColor = nil;
        @try 
        {
            if (fontColorColumnName.length!=0)
            {
                NSString* fontColorString = [attributes valueForKey:fontColorColumnName];
                fontColor = [UIColor colorWithString:fontColorString];
            }
            else 
            {
                if (annotationClass != nil)
                {
                    fontColor = [UIColor colorWithString:[annotationClass objectForKey:@"Color"]];
                }
                else 
                {
                    fontColor = defaultLabelSymbol.color;
                }
            }
        }
        @catch (NSException *exception) 
        {
            fontColor = defaultLabelSymbol.color;
        }
        
        int numText = 1;
        NSArray* textComponents = nil;
        
        NSString *newLabel = ((NSString*)[attributes valueForKey:self.labelColumnName]);
        
        if (removeLabelDuplicates)
        {
            // check if the label is already added to just return nil and avoid render a duplicate label.
            if([labelsText containsObject:newLabel]==YES)
            {
                return nil;
            }
            [labelsText addObject:newLabel];
        }
        
        if (self.labelColumnName != nil && [((NSString*)[attributes valueForKey:self.labelColumnName]) rangeOfString:@"\r\n"].length > 0)
        {
           // NSLog(@"The value for the text label has carried return %@", [attributes valueForKey:labelColumnName]);
            textComponents = [((NSString*)[attributes valueForKey:self.labelColumnName]) componentsSeparatedByString:@"\r\n"];
            numText = [textComponents count];
        }
        
        double newYValue = 0.0;
        for (int i = 0; i < numText; i++) 
        {
            NSString* text = nil;
            if (self.labelColumnName != nil && [self.labelColumnName hasPrefix:@"${"])
            {
                text = self.labelColumnName;
            }
            else {
                if (self.labelColumnName == nil)
                {
                    break; // stop for.. no text to display
                }
                text = (textComponents != nil)?[textComponents objectAtIndex:i]:[attributes valueForKey:self.labelColumnName];
            }
            text = [text stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\r\n"]];
            textSymbol = [AGSTextSymbol textSymbolWithTextTemplate:text color:fontColor];
            [textSymbol setRotateAroundOffset:YES];
            textSymbol.hAlignment = AGSTextSymbolHAlignmentCenter;
            textSymbol.vAlignment = AGSTextSymbolVAlignmentMiddle;
            
            @try {
                if (annotationClass != nil && ((override & 131072) != 131072))
                {
                    textSymbol.fontFamily = [annotationClass valueForKey:@"FontName"];
                }
                else if (fontFamilyColumnName != nil)
                {
                    textSymbol.fontFamily = [attributes valueForKey:fontFamilyColumnName];
                }
            }
            @catch (NSException *exception) {
                
            }
            @try {
                if (annotationClass != nil && ((override & 8192) != 8192))
                {
                    if ([[annotationClass valueForKey:@"Bold"] boolValue])
                        textSymbol.fontWeight = AGSTextSymbolFontWeightBold;
                    else 
                        textSymbol.fontWeight = AGSTextSymbolFontWeightNormal;
                }
                else if (fontBoldColumnName != nil)
                {
                    if ([[attributes valueForKey:fontBoldColumnName] boolValue])
                        textSymbol.fontWeight = AGSTextSymbolFontWeightBold;
                    else 
                        textSymbol.fontWeight = AGSTextSymbolFontWeightNormal;
                }
            }
            @catch (NSException *exception) {
                
            }
            @try {
                if (annotationClass != nil && ((override & 16384) != 16384))
                {
                    if ([[annotationClass valueForKey:@"Italic"] boolValue])
                        textSymbol.fontStyle = AGSTextSymbolFontStyleItalic;
                    else 
                        textSymbol.fontStyle = AGSTextSymbolFontStyleNormal;
                }
            }
            @catch (NSException *exception) {
                
            }
            @try 
            {

                if (annotationClass != nil && ((override & 64) != 64))
                {
                    if (scaleLabels)
                    {
                        textSymbol.fontSize = [[annotationClass valueForKey:@"FontSize"] intValue] / parentMap.resolution;
                    }
                    else {
                        textSymbol.fontSize = [[annotationClass valueForKey:@"FontSize"] intValue];
                    }
                } 
                else if (fontSizeColumnName.length != 0)
                {
                    if (scaleLabels)
                    {
                        textSymbol.fontSize = [[attributes valueForKey:fontSizeColumnName] floatValue] / parentMap.resolution;
                    }
                    else {
                        textSymbol.fontSize = [[attributes valueForKey:fontSizeColumnName] floatValue];
                    }
                }
                else 
                {
                    if (scaleLabels)
                    {
                        textSymbol.fontSize = self.defaultLabelSymbol.fontSize / parentMap.resolution;
                    }
                    else 
                    {
                        textSymbol.fontSize = self.defaultLabelSymbol.fontSize;
                    }
                }
            }
            @catch (NSException *exception) {
                
            }

            
            
            textSymbol.angle = 0;
            @try {
                if (labelAngleColumnName.length != 0)
                {
                    if (annotationClass != nil)
                    {
                        textSymbol.angle = [[annotationClass valueForKey:@"Angle"] intValue];
                    }
                    textSymbol.angle += [[attributes valueForKey:labelAngleColumnName] floatValue];
                }
            }
            @catch (NSException *exception) {
                
            }


            
            if (annotationClass != nil && ((override & 4) != 4))
            {
                if ([(NSString*)[annotationClass valueForKey:@"HorizontalAlignment"] compare:@"Left"] == NSOrderedSame)
                {
                    textSymbol.hAlignment = AGSTextSymbolHAlignmentLeft;
                }
                else if ([(NSString*)[annotationClass valueForKey:@"HorizontalAlignment"] compare:@"Center"] == NSOrderedSame)
                {
                    textSymbol.hAlignment = AGSTextSymbolHAlignmentCenter;
                }
                else if ([(NSString*)[annotationClass valueForKey:@"HorizontalAlignment"] compare:@"Right"] == NSOrderedSame)
                {
                    textSymbol.hAlignment = AGSTextSymbolHAlignmentRight;
                }
                else if ([(NSString*)[annotationClass valueForKey:@"HorizontalAlignment"] compare:@"Full"] == NSOrderedSame)
                {
                    textSymbol.hAlignment = AGSTextSymbolHAlignmentJustify;
                }
            }
            else if ([attributeNames containsObject:@"HORIZONTAL"])
            {
                if ((override & 4) == 4)
                {
                    switch ([[attributes valueForKey:@"HORIZONTAL"] intValue]) {
                        case 0:
                            textSymbol.hAlignment = AGSTextSymbolHAlignmentLeft;
                            break;
                        case 1:
                            textSymbol.hAlignment = AGSTextSymbolHAlignmentCenter;
                            break;
                        case 2:
                            textSymbol.hAlignment = AGSTextSymbolHAlignmentRight;
                            break;
                        case 3:
                            textSymbol.hAlignment = AGSTextSymbolHAlignmentJustify;
                            break;
                        default:
                            textSymbol.hAlignment = AGSTextSymbolHAlignmentCenter;
                            break;
                    }
                }
            }
            if (annotationClass != nil && ((override & 8) != 8))
            {
                if ([(NSString*)[annotationClass valueForKey:@"VerticalAlignment"] compare:@"Top"] == NSOrderedSame)
                {
                    textSymbol.vAlignment = AGSTextSymbolVAlignmentTop;
                }
                else if ([(NSString*)[annotationClass valueForKey:@"VerticalAlignment"] compare:@"Center"] == NSOrderedSame)
                {
                    textSymbol.vAlignment = AGSTextSymbolVAlignmentMiddle;
                }
                else if ([(NSString*)[annotationClass valueForKey:@"VerticalAlignment"] compare:@"Baseline"] == NSOrderedSame)
                {
                    textSymbol.vAlignment = AGSTextSymbolVAlignmentBaseline;
                }
                else if ([(NSString*)[annotationClass valueForKey:@"VerticalAlignment"] compare:@"Bottom"] == NSOrderedSame)
                {
                    textSymbol.vAlignment = AGSTextSymbolVAlignmentBottom;
                }
            }
            else if ([attributeNames containsObject:@"VERTICALAL"])
            {
                if ((override & 8) == 8)
                {
                    switch ([[attributes valueForKey:@"VERTICALAL"] intValue]) {
                        case 0:
                            textSymbol.vAlignment =  AGSTextSymbolVAlignmentTop;
                            break;
                        case 1:
                            textSymbol.vAlignment =  AGSTextSymbolVAlignmentMiddle;
                            break;
                        case 2:
                            textSymbol.vAlignment =  AGSTextSymbolVAlignmentBaseline;
                            break;
                        case 3:
                            textSymbol.vAlignment =  AGSTextSymbolVAlignmentBottom;
                            break;
                        default:
                            textSymbol.vAlignment =  AGSTextSymbolVAlignmentMiddle;
                            break;
                    }
                }
            
            }
            if ([attributeNames containsObject:@"XOFFSET"])
            {
                //textSymbol.xoffset =  [[attributes valueForKey:@"XOFFSET"] floatValue] / parentMap.resolution;
            }
            if ([attributeNames containsObject:@"YOFFSET"])
            {
                //textSymbol.yoffset =  -[[attributes valueForKey:@"YOFFSET"] floatValue] / parentMap.resolution;
            }
            textSymbol.yoffset = newYValue;
            newYValue += textSymbol.fontSize + 2;
            //NSLog(@"'%@' size=%f", textSymbol.textTemplate, textSymbol.fontSize);
            
            [returnSymbol.symbols addObject:textSymbol ];
        }
    }
    return returnSymbol;
}

-(AGSMutablePolygon *)parsePolygone:(gaiaPolygonPtr)polyPtr
{    
    NSString* wtkNAN83HARNWashintongNort = @"PROJCS[""NAD_1983_HARN_StatePlane_Washington_North_FIPS_4601_Feet"",GEOGCS[""GCS_North_American_1983_HARN"",DATUM[""D_North_American_1983_HARN"",SPHEROID[""GRS_1980"",6378137.0,298.257222101]],PRIMEM[""Greenwich"",0.0],UNIT[""Degree"",0.0174532925199433]],PROJECTION[""Lambert_Conformal_Conic""],PARAMETER[""False_Easting"",1640416.666666667],PARAMETER[""False_Northing"",0.0],PARAMETER[""Central_Meridian"",-120.8333333333333],PARAMETER[""Standard_Parallel_1"",47.5],PARAMETER[""Standard_Parallel_2"",48.73333333333333],PARAMETER[""Latitude_Of_Origin"",47.0],UNIT[""Foot_US"",0.3048006096012192]]";
    AGSSpatialReference* originalProjection = [AGSSpatialReference spatialReferenceWithWKT:wtkNAN83HARNWashintongNort];
#ifdef WEBMERCATOR
    AGSSpatialReference*  baseProjection = [AGSSpatialReference spatialReferenceWithWKID:102100];
#endif
    AGSMutablePolygon* polygon = [[AGSMutablePolygon alloc] initWithSpatialReference:originalProjection] ;
    // read the elements
    int partIndex  =0;
    [polygon addRingToPolygon]; // add the first part.
    partIndex++;
    
    // parse exterior
    for (int i = 0; i < polyPtr->Exterior->Points; i++) {
        double x = 0, y = 0;
        gaiaGetPoint(polyPtr->Exterior->Coords, i, &x, &y);
        AGSPoint* myMarkerPoint =
        [AGSPoint pointWithX:x
                           y:y
            spatialReference:nil];
        
        [polygon addPointToRing:myMarkerPoint];
        
    }
    // parse interior
    for (NSInteger index = 0; index < polyPtr->NumInteriors; index++) {
        [polygon addRingToPolygon];
        gaiaRingPtr interiors = polyPtr->Interiors;
        for (int i = 0; i < interiors[index].Points; i++) {
            double x = 0, y = 0;
            gaiaGetPoint(interiors[index].Coords, i, &x, &y);
            AGSPoint* myMarkerPoint =
            [AGSPoint pointWithX:x
                               y:y
                spatialReference:nil];
            
            [polygon addPointToRing:myMarkerPoint];
            
        }
    }

    return polygon;
}

-(void)parsePolygone:(gaiaGeomCollPtr) geo withAttributes: (NSMutableDictionary*)attributes
{
    AGSSymbol *myMarkerPolySymbol = nil;

    NSString* wtkNAN83HARNWashintongNort = @"PROJCS[""NAD_1983_HARN_StatePlane_Washington_North_FIPS_4601_Feet"",GEOGCS[""GCS_North_American_1983_HARN"",DATUM[""D_North_American_1983_HARN"",SPHEROID[""GRS_1980"",6378137.0,298.257222101]],PRIMEM[""Greenwich"",0.0],UNIT[""Degree"",0.0174532925199433]],PROJECTION[""Lambert_Conformal_Conic""],PARAMETER[""False_Easting"",1640416.666666667],PARAMETER[""False_Northing"",0.0],PARAMETER[""Central_Meridian"",-120.8333333333333],PARAMETER[""Standard_Parallel_1"",47.5],PARAMETER[""Standard_Parallel_2"",48.73333333333333],PARAMETER[""Latitude_Of_Origin"",47.0],UNIT[""Foot_US"",0.3048006096012192]]";
    AGSSpatialReference* originalProjection = [AGSSpatialReference spatialReferenceWithWKT:wtkNAN83HARNWashintongNort];
#ifdef WEBMERCATOR
    AGSSpatialReference*  baseProjection = [AGSSpatialReference spatialReferenceWithWKID:102100];
#endif
    gaiaPolygonPtr polyPtr = geo->FirstPolygon;
    while (polyPtr != nil) {
        AGSMutablePolygon* polygon = [self parsePolygone:polyPtr];
        
        // if has inline text symbol
        AGSSymbol* textSymbol = [self inlineTextSymbol:attributes];
        
        if (showShapes)
        {
            AGSGraphic* myGraphic =
            [AGSGraphic graphicWithGeometry:polygon
                                     symbol:myMarkerPolySymbol
                                 attributes:attributes
                       infoTemplateDelegate:self];
            [self addGraphic:myGraphic];
            
        }
        if (textSymbol != nil)
        {
            double x = 0, y = 0;
            gaiaRingCentroid(polyPtr->Exterior, &x, &y);
            //AGSPoint* labelPoint = [geoEngine labelPointForPolygon:polygon];
            AGSGraphic*  myLabel = nil;
            if ([(AGSTextSymbol*)[[(AGSCompositeSymbol*)textSymbol symbols] objectAtIndex:0] hAlignment] == AGSTextSymbolHAlignmentLeft)
            {
                x = [polygon pointOnRing:0 atIndex:0].x;
            }
            if ([(AGSTextSymbol*)[[(AGSCompositeSymbol*)textSymbol symbols] objectAtIndex:0] vAlignment] == AGSTextSymbolVAlignmentBaseline)
            {
                y = [polygon pointOnRing:0 atIndex:0].y;
            }
            if ([(AGSTextSymbol*)[[(AGSCompositeSymbol*)textSymbol symbols] objectAtIndex:0] angle] == 0)
            {
                double width = [[polygon envelope] xmax] -[[polygon envelope] xmin];
                double height = [[polygon envelope] ymax] -[[polygon envelope] ymin];
                if ((width * 2.5) < height)
                {
                    [(AGSTextSymbol*)[[(AGSCompositeSymbol*)textSymbol symbols] objectAtIndex:0] setAngle:-90];
                }
            }
            
            myLabel =
            [AGSGraphic graphicWithGeometry:[AGSPoint pointWithX:x y:y spatialReference:originalProjection]
                                     symbol:textSymbol
                                 attributes:nil
                       infoTemplateDelegate:nil];
            //}
            [self addGraphic:myLabel];
        }
        polyPtr = polyPtr->Next;
    }
}

-(void)parsePolyLine:(gaiaGeomCollPtr) geo withAttributes: (NSMutableDictionary*)attributes
{
    AGSSymbol *myMarkerLineSymbol =nil;
    NSString* wtkNAN83HARNWashintongNort = @"PROJCS[""NAD_1983_HARN_StatePlane_Washington_North_FIPS_4601_Feet"",GEOGCS[""GCS_North_American_1983_HARN"",DATUM[""D_North_American_1983_HARN"",SPHEROID[""GRS_1980"",6378137.0,298.257222101]],PRIMEM[""Greenwich"",0.0],UNIT[""Degree"",0.0174532925199433]],PROJECTION[""Lambert_Conformal_Conic""],PARAMETER[""False_Easting"",1640416.666666667],PARAMETER[""False_Northing"",0.0],PARAMETER[""Central_Meridian"",-120.8333333333333],PARAMETER[""Standard_Parallel_1"",47.5],PARAMETER[""Standard_Parallel_2"",48.73333333333333],PARAMETER[""Latitude_Of_Origin"",47.0],UNIT[""Foot_US"",0.3048006096012192]]";
    

    AGSSpatialReference*  originalProjection = [AGSSpatialReference spatialReferenceWithWKT:wtkNAN83HARNWashintongNort];
    AGSSpatialReference*  baseProjection = originalProjection;
    gaiaLinestringPtr polyPtr = geo->FirstLinestring;
    while (polyPtr != nil) {
        AGSMutablePolyline* polyline = [[AGSMutablePolyline alloc] initWithSpatialReference:baseProjection];
        // read the elements
        int partIndex  =0;
        [polyline addPathToPolyline]; // add the first part.
        partIndex++;
        
        // parse exterior
        for (int i = 0; i < polyPtr->Points; i++) {
            double x = 0, y = 0;
            gaiaGetPoint(polyPtr->Coords, i, &x, &y);
            AGSPoint* myMarkerPoint =
            [AGSPoint pointWithX:x
                               y:y
                spatialReference:nil];
            
            [polyline addPointToPath:myMarkerPoint];            
        }
        if (showShapes || showAnnotationPolygonContainers)
        {
            AGSGraphic* myGraphic =
            [AGSGraphic graphicWithGeometry:polyline
                                     symbol:myMarkerLineSymbol
                                 attributes:attributes
                       infoTemplateDelegate:self];
            [self addGraphic:myGraphic];
        }
        
        AGSCompositeSymbol* textSymbol = (AGSCompositeSymbol* )[self inlineTextSymbol:attributes];
        if (textSymbol != nil)
        {
            myMarkerLineSymbol = textSymbol;
            if ([[textSymbol.symbols objectAtIndex:0] angle] == 0)
            {
                float x1 = [polyline pointOnPath:0 atIndex:0].x;
                float y1 = [polyline pointOnPath:0 atIndex:0].y;
                int lastPath = 0;
                int lastIndex = [polyline numPointsInPath:lastPath] - 1;
                float x2 = [polyline pointOnPath:lastPath atIndex:lastIndex].x;
                float y2 = [polyline pointOnPath:lastPath atIndex:lastIndex].y;
                float possibleAngle = acosf((x2-x1)/sqrtf(powf((y2-y1), 2) + powf((x2-x1), 2) )) / 3.1415 * 180.0;
                
                
                if (y2 < y1)
                {
                    [[textSymbol.symbols objectAtIndex:0] setAngle:possibleAngle];
                }
                else {
                    [[textSymbol.symbols objectAtIndex:0] setAngle:-possibleAngle];
                }
                
            }
            AGSGraphic * myLabel =
            [AGSGraphic graphicWithGeometry:polyline
                                     symbol:textSymbol
                                 attributes:nil
                       infoTemplateDelegate:nil];
      
            [self addGraphic:myLabel];
        }
        
        polyPtr = polyPtr->Next;
    }
}

-(void)parsePoint:(gaiaGeomCollPtr) geo withAttributes: (NSMutableDictionary*)attributes
{
    AGSSymbol *myMarkerSymbol = nil;
    
    NSString* wtkNAN83HARNWashintongNort = @"PROJCS[""NAD_1983_HARN_StatePlane_Washington_North_FIPS_4601_Feet"",GEOGCS[""GCS_North_American_1983_HARN"",DATUM[""D_North_American_1983_HARN"",SPHEROID[""GRS_1980"",6378137.0,298.257222101]],PRIMEM[""Greenwich"",0.0],UNIT[""Degree"",0.0174532925199433]],PROJECTION[""Lambert_Conformal_Conic""],PARAMETER[""False_Easting"",1640416.666666667],PARAMETER[""False_Northing"",0.0],PARAMETER[""Central_Meridian"",-120.8333333333333],PARAMETER[""Standard_Parallel_1"",47.5],PARAMETER[""Standard_Parallel_2"",48.73333333333333],PARAMETER[""Latitude_Of_Origin"",47.0],UNIT[""Foot_US"",0.3048006096012192]]";
    AGSSpatialReference*  originalProjection = [AGSSpatialReference spatialReferenceWithWKT:wtkNAN83HARNWashintongNort];
    AGSSpatialReference*  baseProjection = originalProjection;
    
    gaiaPointPtr polyPtr = geo->FirstPoint;
    while (polyPtr != nil) 
    {
        
        //Create an AGSPoint (which inherits from AGSGeometry) that
        //defines where the Graphic will be drawn
        double x = 0, y = 0;
        x = polyPtr->X;
        y = polyPtr->Y;
        AGSPoint* myMarkerPoint = [AGSPoint pointWithX:x y:y
                                      spatialReference:baseProjection];
        
        if (showShapes || showAnnotationPolygonContainers)
        {
            AGSGraphic* myGraphic =
            [AGSGraphic graphicWithGeometry:myMarkerPoint
                                     symbol:myMarkerSymbol
                                 attributes:attributes
                       infoTemplateDelegate:self];
            [self addGraphic:myGraphic];
        }
        
        
        AGSCompositeSymbol* textSymbol = [self inlineTextSymbol:attributes];
        if (textSymbol != nil)
        {
            AGSGraphic* myLabel =
            [AGSGraphic graphicWithGeometry:myMarkerPoint
                                     symbol:textSymbol
                                 attributes:nil
                       infoTemplateDelegate:nil];
            [self addGraphic:myLabel];
        }
        
        polyPtr = polyPtr->Next;
    }
}
#pragma mark - labeling
-(void) performLabeling
{
    // remove any previous label
    if ([_labels count] > 0)
    {
        for (AGSGraphic* label in _labels) {
            [self removeGraphic:label];
        }
        [_labels removeAllObjects];
    }
    
    NSMutableArray* labelsToAdd = [[NSMutableArray alloc] init];
    NSMutableArray* labelSetsThatApply = [[NSMutableArray alloc] init];
    for (RendererLabel *labelSet in labelSets) 
    {
        // check if the label set is inside of the maximun and minimun zoom
        if (parentMap.mapScale >= labelSet.minAltitude && parentMap.mapScale <= labelSet.maxAltitude)
        {
            [labelSetsThatApply addObject:labelSet];
        }
    }
    if ([labelSetsThatApply count] > 0) 
    {
        for (AGSGraphic*graphic in self.graphics) 
        {
            // check for labelset defined
            for (RendererLabel* labelSet in labelSetsThatApply) 
            {
                NSArray* newLabels = [labelSet getLabelsForGraphic:graphic withCenter:[[graphic.geometry envelope] center] ];
                
                [labelsToAdd addObjectsFromArray:newLabels];
            }
        }
    }
    
    if ([labelsToAdd count] > 0)
    {
        [_labels addObjectsFromArray:labelsToAdd];
        [self.graphics addObjectsFromArray:labelsToAdd];
    }
    
}
#pragma mark - map callout delegate
- (NSString *)titleForGraphic:(AGSGraphic *)graphic screenPoint:(CGPoint)screen mapPoint:(AGSPoint *)map 
{
    if (selectedShapes != NULL)
    {
        NSString *key; 
        if([[graphic.attributes allKeys] containsObject:@"PKUID"])
            key = @"PKUID";
        else
            key = @"PK_UID";
        
        id value = [graphic.attributes valueForKey:key];
        
        if (value != NULL)
        {
            if ([selectedShapes containsObject:value])
            {
                [selectedShapes removeObject:value];
                graphic.symbol = nil;
            }
            else 
            {
                [selectedShapes addObject:[graphic.attributes valueForKey:key]];
                graphic.symbol = highlightSymbol;
            }
            [self dataChanged];
        }
    }
    if ([[graphic.attributes allKeys] containsObject:titleColumnName])
    {
        return [graphic.attributes valueForKey:titleColumnName];
    }
    return NULL;
}

- (NSString *)detailForGraphic:(AGSGraphic *)graphic screenPoint:(CGPoint)screen mapPoint:(AGSPoint *)map 
{
    if ([[graphic.attributes allKeys] containsObject:descriptionColumName])
    {
        return [graphic.attributes valueForKey:descriptionColumName];
    }
    return NULL;
}

-(UIView *)customViewForGraphic:(AGSGraphic *)graphic screenPoint:(CGPoint)screen mapPoint:(AGSPoint *)mapPoint
{
    return NULL;
}
-(void)setShowLabels:(BOOL)val
{
    _showLabels = val;
}
@end
