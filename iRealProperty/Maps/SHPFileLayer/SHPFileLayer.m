#import "SHPFileLayer.h"
#import "NSData_Additions.h"
#import "LayerInfo.h"
#import "proj_api.h"
#include "shpgeo.h"
#include "prjopen.h"



// ESRI MAPS PROJECTION
#define EPSG4326 "+proj=merc +lon_0=0 +k=1 +x_0=0 +y_0=0 +a=6378137 +b=6378137 +units=m +no_defs"
// King_County Projection
#define SRORG110 "+proj=lcc +lat_1=47.5 +lat_2=49.73333333333333 +lat_0=47 +lon_0=-120.8333333333333 +x_0=500000.0000000001 +y_0=0 +ellps=GRS80 +to_meter=0.3048006096012192 +no_defs"

@interface SHPFileLayer (private_methods)

@end


@implementation SHPFileLayer



-(id) initWithFileContents: (NSString*) filePath
{
    self = [super init];
    if (self != nil)
    {
        self->_loaded = false;
        self->fieldCount = 0;
        self->recordCount = 0;
        self->sfile = nil;
        self->dfile = nil;
       
        [self openShapefile:filePath];
    }
    return self;
}

-(void)dealloc
{
    //SHPFreeProjection(pj_conic);
    //SHPFreeProjection(pj_latlong);
    DBFClose(dfile);
    SHPClose(sfile);
}

-(void)openShapefile:(NSString*) filePath
{
    _filePath = [NSString stringWithString:filePath];
    NSString *genericPath = [_filePath stringByDeletingPathExtension];
    NSString *dbfFilePath = [genericPath stringByAppendingPathExtension:@"dbf"];
    NSString *prjFilePath = [genericPath stringByAppendingPathExtension:@"prj"];
    NSError* err = nil;
    NSStringEncoding encoding;
    
    //Get the file spacial reference.. I have to add a step to check if the prj file exist. 
    AGSSpatialReference* sr = [AGSSpatialReference spatialReferenceWithWKT:[NSString stringWithContentsOfFile:prjFilePath usedEncoding:&encoding error:&err]];
    if (sr != nil)
    {
        spacialReference = sr;
    }
    if ([sr isAnyWebMercator])
    {
        NSLog(@"Is web marcator");
    }
    AGSGeometryEngine *ge = [AGSGeometryEngine defaultGeometryEngine];
    NSString* wtkNAN83HARNWashintongNort = @"PROJCS[""NAD_1983_HARN_StatePlane_Washington_North_FIPS_4601_Feet"",GEOGCS[""GCS_North_American_1983_HARN"",DATUM[""D_North_American_1983_HARN"",SPHEROID[""GRS_1980"",6378137.0,298.257222101]],PRIMEM[""Greenwich"",0.0],UNIT[""Degree"",0.0174532925199433]],PROJECTION[""Lambert_Conformal_Conic""],PARAMETER[""False_Easting"",1640416.666666667],PARAMETER[""False_Northing"",0.0],PARAMETER[""Central_Meridian"",-120.8333333333333],PARAMETER[""Standard_Parallel_1"",47.5],PARAMETER[""Standard_Parallel_2"",48.73333333333333],PARAMETER[""Latitude_Of_Origin"",47.0],UNIT[""Foot_US"",0.3048006096012192]]";
    
#ifdef WEBMERCATOR
    AGSSpatialReference*  baseProjection = [AGSSpatialReference spatialReferenceWithWKID:102100]; 
#else
     AGSSpatialReference*  baseProjection = [AGSSpatialReference spatialReferenceWithWKT:wtkNAN83HARNWashintongNort];
#endif
    //AGSSpatialReference*  baseProjection = [AGSSpatialReference spatialReferenceWithWKID:4326 WKT:@"GEOGCS[""GCS_WGS_1984"",DATUM[""D_WGS_1984"",SPHEROID[""WGS_1984"",6378137.0,298.257223563]],PRIMEM[""Greenwich"",0.0],UNIT[""Degree"",0.0174532925199433],AUTHORITY[""EPSG"",4326]]"];
    pj_conic = nil;
    pj_latlong = nil;
	//if (!(pj_conic = pj_init_plus(SRORG110)) )
	//ß	exit(1);
	//if (!(pj_latlong = pj_init_plus(EPSG4326)) )
	//	exit(1);
    
    // get handlers to the shapes and attributes files.
    sfile = SHPOpen([_filePath cStringUsingEncoding:[NSString defaultCStringEncoding]],"rb");
    dfile = DBFOpen([dbfFilePath cStringUsingEncoding:[NSString defaultCStringEncoding]], "rb"); 
    
    // Get the info of the enties.
    fieldCount = DBFGetFieldCount(dfile);
    recordCount = DBFGetRecordCount(dfile);
    
    int nEntities;
    SHPGetInfo(sfile, &nEntities, &nShapeType, padfMinBound, padfMaxBound);
    
    if (nEntities != recordCount)
    {
        NSLog(@"Error, the attributes file and the shapes has different number of entries.");
        
        return;
    }
    if (nShapeType == SHPT_ARC || nShapeType == SHPT_ARCM || nShapeType == SHPT_ARCZ)
    {
        self.renderSymbol = [AGSSimpleLineSymbol simpleLineSymbolWithColor:[UIColor colorWithRed:0.3 green:1.0 blue:0.3 alpha:0.9] width:1.0];
    }
    else if (nShapeType == SHPT_POINT || nShapeType == SHPT_POINTM || nShapeType == SHPT_POINTZ)
    {
        self.renderSymbol = [AGSSimpleLineSymbol simpleLineSymbolWithColor:[UIColor colorWithRed:0.3 green:1.0 blue:0.3 alpha:0.9] width:1.0];
    }
    else // is a polygone
    {
        self.renderSymbol = [AGSSimpleFillSymbol simpleFillSymbol];
        self.renderSymbol.color = [UIColor colorWithRed:0.3 green:0.3 blue:1.0 alpha:0.5];
        ((AGSSimpleFillSymbol*)self.renderSymbol).style = AGSSimpleFillSymbolStyleSolid;
    }
    self.renderer = [AGSSimpleRenderer simpleRendererWithSymbol:self.renderSymbol];
    //pj_transform(pj_conic, pj_latlong, 1, 1, &padfMinBound[0], &padfMinBound[1], NULL );
    //pj_transform(pj_conic, pj_latlong, 1, 1, &padfMaxBound[0], &padfMaxBound[1], NULL );
    for (int i =0; i < MIN(2000, recordCount); i++) {
        // get all the geometries and add to the layer.
        SHPObject * shape = SHPReadObject(sfile, i);
        // SHPProject(shape, pj_conic, pj_latlong);
        AGSGraphic* myGraphic = nil;
        NSMutableDictionary* attributtes = [NSMutableDictionary dictionaryWithCapacity:fieldCount];
        for (int attIndex = 0; attIndex < fieldCount; attIndex ++) {
            int fieldWidth = 0 , fieldDecimals = 0;
            char fieldName[12];
            DBFFieldType fieldtype = DBFGetFieldInfo(dfile, attIndex, fieldName, &fieldWidth, &fieldDecimals);
            switch (fieldtype) {
                case FTString:
                {
                    const char* value = DBFReadStringAttribute(dfile, i, attIndex);
                    [attributtes setValue:[NSString stringWithCString:(char *)value encoding:[NSString defaultCStringEncoding]]
                                   forKey:[NSString stringWithCString:(char *)fieldName encoding:[NSString defaultCStringEncoding]]];
                }
                    break;
                case FTInteger:
                {
                    int intValue = DBFReadIntegerAttribute(dfile, i, attIndex);
                    [attributtes setValue:[NSNumber numberWithInt:intValue]
                                   forKey:[NSString stringWithCString:(char *)fieldName encoding:[NSString defaultCStringEncoding]]];
                    
                }
                    break;  
                case FTDouble:
                {
                    double doubleValue = DBFReadDoubleAttribute(dfile, i, attIndex);
                    [attributtes setValue:[NSNumber numberWithDouble:doubleValue]
                                   forKey:[NSString stringWithCString:(char *)fieldName encoding:[NSString defaultCStringEncoding]]];
                }
                    break; 
                default:
                    break;
            }
        }
        if (attributeNames == nil)
        {
            self.attributeNames = [attributtes allKeys];
        }
        if (shape->nSHPType == SHPT_POINT)
        {
            //create a marker symbol to be used by our Graphic
            AGSSimpleMarkerSymbol *myMarkerSymbol =
            [AGSSimpleMarkerSymbol simpleMarkerSymbol];
            myMarkerSymbol.color = [UIColor blueColor];
            if (renderSymbol == nil)
            {
                self.renderSymbol = myMarkerSymbol;
            }
            //Create an AGSPoint (which inherits from AGSGeometry) that
            //defines where the Graphic will be drawn
            AGSPoint* myMarkerPoint = nil; // use the default renderer symbol.
            
            //Create the Graphic, using the symbol and
            //geometry created earlier
            myGraphic =
            [AGSGraphic graphicWithGeometry:[ge projectGeometry:myMarkerPoint 
                                             toSpatialReference:baseProjection]
                                     symbol:myMarkerSymbol
                                 attributes:attributtes
                       infoTemplateDelegate:nil];
        }
        else if (shape->nSHPType == SHPT_ARC)
        {
            // CLLocationCoordinate2D *pointsCArray = calloc(nNumPoints, sizeof(CLLocationCoordinate2D));
            AGSMutablePolyline* polyline = [[AGSMutablePolyline alloc] initWithSpatialReference:sr];
            // read the elements
            int partIndex  =0;
            [polyline addPathToPolyline]; // add the first part.
            partIndex++;
            
            for(NSInteger index = 0; index < shape->nVertices; index++)
            {
                double x = 0, y = 0;
                x = shape->padfX[index];
                y = shape->padfY[index];
                if (partIndex < shape->nParts)
                {
                    if (index == shape->panPartStart[partIndex])
                    {
                        [polyline addPathToPolyline]; // add the first part.
                        partIndex++; 
                    }
                }
                //Create an AGSPoint (which inherits from AGSGeometry) that
                //defines where the Graphic will be drawn
                AGSPoint* myMarkerPoint =
                [AGSPoint pointWithX:x
                                   y:y
                    spatialReference:nil];
                
                [polyline addPointToPath:myMarkerPoint];
                
                //pointsCArray[index] = coords;
            }
            
            AGSSimpleLineSymbol *myMarkerLineSymbol = nil; //use the default renderer symbol
            
            myGraphic =
            [AGSGraphic graphicWithGeometry:[ge projectGeometry:polyline 
                                             toSpatialReference:baseProjection]//polyline
                                     symbol:myMarkerLineSymbol
                                 attributes:attributtes
                       infoTemplateDelegate:nil];
        }
        else if (shape->nSHPType == SHPT_POLYGON)
        {
            // CLLocationCoordinate2D *pointsCArray = calloc(nNumPoints, sizeof(CLLocationCoordinate2D));
            AGSMutablePolygon* polygone = [[AGSMutablePolygon alloc] initWithSpatialReference:sr];
            // read the elements
            int partIndex  =0;
            [polygone addRingToPolygon]; // add the first part.
            partIndex++;
            
            for(NSInteger index = 0; index < shape->nVertices; index++)
            {
                double x = 0, y = 0;
                x = shape->padfX[index];
                y = shape->padfY[index];
                if (partIndex < shape->nParts)
                {
                    if (index == shape->panPartStart[partIndex])
                    {
                        [polygone addRingToPolygon]; // add the first part.
                        partIndex++; 
                    }
                }
                //Create an AGSPoint (which inherits from AGSGeometry) that
                //defines where the Graphic will be drawn
                AGSPoint* myMarkerPoint =
                [AGSPoint pointWithX:x
                                   y:y
                    spatialReference:nil];
                
                [polygone addPointToRing:myMarkerPoint];
                
                //pointsCArray[index] = coords;
            }
            
            AGSSimpleFillSymbol *myMarkerPolySymbol = nil; // use the default renderer symbol
            /* AGSCalloutTemplate* template = [[AGSCalloutTemplate alloc] init] ;
             template.titleTemplate = @"${CITYNAME}"; //show the value for attribute key 'CITY NAME'
             template.detailTemplate = @"${OBJECTID}"; //show the value for attribute key 'OBJECT ID'*/
            
            myGraphic =
            [AGSGraphic graphicWithGeometry:[ge projectGeometry:polygone 
                                             toSpatialReference:baseProjection]//polygone
                                     symbol:myMarkerPolySymbol
                                 attributes:attributtes
                       infoTemplateDelegate:self];
            
            
        }
        if (myGraphic != nil)
        {
            [self addGraphic:myGraphic];
        }
        
        SHPDestroyObject ( shape );
    }
    
    self->_loaded = true;
}


#pragma Mark - overrides



- (NSString *)titleForGraphic:(AGSGraphic *)graphic screenPoint:(CGPoint)screen mapPoint:(AGSPoint *)map 
{
    //[graphic.symbol setColor:[UIColor redColor]];
    if ([[graphic.attributes allKeys] containsObject:titleColumnName])
    {
        return [graphic.attributes valueForKey:titleColumnName];
    }
    return @"No info available";
}

- (NSString *)detailForGraphic:(AGSGraphic *)graphic screenPoint:(CGPoint)screen mapPoint:(AGSPoint *)map 
{
    if ([[graphic.attributes allKeys] containsObject:descriptionColumName])
    {
        return [graphic.attributes valueForKey:descriptionColumName];
    }
    return @"<na>";
}


/*-(AGSEnvelope *)fullEnvelope
{
    return [AGSEnvelope envelopeWithXmin:padfMinBound[0] ymin:padfMinBound[1] xmax:padfMaxBound[0] ymax:padfMaxBound[1] spatialReference:[AGSSpatialReference spatialReferenceWithWKID:102100]];
}

*/

@end
