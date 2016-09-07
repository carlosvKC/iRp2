
#import "SidTiledLayer.hpp"
#import "SidTileOperation.h"
#import "SidParserDelegate.h"


#include "lt_fileSpec.h"
#include "lti_navigator.h"
#include "lti_utils.h"
#include "lt_utilStatusStrings.h"

#include "MrSIDImageReader.h"




LT_USE_NAMESPACE(LizardTech);

int MakeAGSUnits(NSString* wkt);

//Function to convert [UNIT] component in WKT to AGSUnits
int MakeAGSUnits(NSString* wkt)
{
	NSString* value ;
	BOOL _continue = YES;
 	NSScanner* scanner = [NSScanner scannerWithString:wkt];

	//Scan for the UNIT information in WKT. 
	//If WKT is for a Projected Coord System, expect two instances of UNIT, and use the second one
	while (_continue) 
    {
		[scanner scanUpToString:@"UNIT[\"" intoString:NULL];
		[scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@"UNIT[\""]];
		_continue = [scanner scanUpToString:@"\"" intoString:&value];
	}
	if([@"Foot_US" isEqualToString:value] || [@"Foot" isEqualToString:value])
    {
		return AGSUnitsFeet;
	}
    else if([@"Meter" isEqualToString:value])
    {
		return AGSUnitsMeters;
	}
    else if([@"Degree" isEqualToString:value])
    {
		return AGSUnitsDecimalDegrees;
	}
    else
    {
		//TODO: Not handling other units like Yard, Chain, Grad, etc
		return -1;
	}
}

@implementation SidTiledLayer

@synthesize dataFramePath=_dataFramePath;
@synthesize appDocumentsPath=_appDocumentsPath;
@synthesize sidFileName=_sidFileName;

-(AGSUnits)units{
	return _units;
}

-(AGSSpatialReference *)spatialReference{
	return _fullEnvelope.spatialReference;
}

-(AGSEnvelope *)fullEnvelope{
	return _fullEnvelope;
}

-(AGSEnvelope *)initialEnvelope{
	//Assuming our initial extent is the same as the full extent
	return _fullEnvelope;
}

-(AGSTileInfo*) tileInfo{
	return _tileInfo;
}


#pragma mark -

- (id)initWithDataFramePath: (NSString *)path error:(NSError**) outError {
	
	if (self = [super init]) {
        
        // Get public docs dir
        self.sidFileName = path;
        
        
        const LizardTech::LTFileSpec fileSpec([self.sidFileName cStringUsingEncoding:[NSString defaultCStringEncoding]]);
        LizardTech::MrSIDImageReader* reader = MrSIDImageReader::create();
        if(reader == NULL){
            NSLog(@"Sid file was not found at %@", path);
            return NULL;
        }
        
        LT_STATUS sts = ((LizardTech::MrSIDImageReader*)reader)->initialize(fileSpec);
        if (sts != LT_STS_Success)
        {
            const char* status = getLastStatusString(sts);
            NSString* nsStatus = [NSString stringWithCString:status encoding:[NSString defaultCStringEncoding]];
            NSLog(@"ERROR initializing SidTileLayer: %@", nsStatus);
            return NULL;
        }
        const double pixelWidth = ((LizardTech::MrSIDImageReader*)reader)->getWidth();
        const double pixelHeight = ((LizardTech::MrSIDImageReader*)reader)->getHeight();
        // const double halfPixelWidth = pixelWidth / 2.0;
        // const double halfPixelHeight = pixelHeight / 2.0;
        
        const LizardTech::LTIGeoCoord& geo = ((LizardTech::MrSIDImageReader*)reader)->getGeoCoord();
        
        double _xmin = geo.getX();
        double _ymin = geo.getY();
        double _xmax = geo.getX() + (geo.getXRes() * pixelWidth);
        double _ymax = geo.getY() + (geo.getYRes() * pixelHeight);
        if (_xmax < _xmin)
        {
            double temp = _xmin;
            _xmin = _xmax;
            _xmax = temp;
        }
        if (_ymax < _ymin)
        {
            double temp = _ymin;
            _ymin = _ymax;
            _ymax = temp;
        }
        double _xorigin = _xmin;
        double _yorigin = _ymax;
        
        NSString* wtkNAN83HARNWashintongNort = @"PROJCS[\"NAD_1983_HARN_StatePlane_Washington_North_FIPS_4601_Feet\",GEOGCS[\"GCS_North_American_1983_HARN\",DATUM[\"D_North_American_1983_HARN\",SPHEROID[\"GRS_1980\",6378137.0,298.257222101]],PRIMEM[\"Greenwich\",0.0],UNIT[\"Degree\",0.0174532925199433]],PROJECTION[\"Lambert_Conformal_Conic\"],PARAMETER[\"False_Easting\",1640416.666666667],PARAMETER[\"False_Northing\",0.0],PARAMETER[\"Central_Meridian\",-120.8333333333333],PARAMETER[\"Standard_Parallel_1\",47.5],PARAMETER[\"Standard_Parallel_2\",48.73333333333333],PARAMETER[\"Latitude_Of_Origin\",47.0],UNIT[\"Foot_US\",0.3048006096012192]]";
        AGSSpatialReference* _spatialReference = [[AGSSpatialReference alloc] initWithWKID:2926 WKT:wtkNAN83HARNWashintongNort] ;
        AGSPoint* _origin = [[AGSPoint alloc] initWithX:_xorigin y:_yorigin spatialReference:_spatialReference] ;
        AGSEnvelope* fullEnvelope = [AGSEnvelope envelopeWithXmin:_xmin 
                                                             ymin:_ymin 
                                                             xmax:_xmax
                                                             ymax:_ymax
                                                 spatialReference:_spatialReference];
        double maxZoom = ((LizardTech::MrSIDImageReader*)reader)->getMaxMagnification();
        double minZoom = ((LizardTech::MrSIDImageReader*)reader)->getMinMagnification();
        double currentScale = maxZoom;
        
        double inchByFeet = 12.0;
        double dpi = (1.0 / geo.getXRes()) / inchByFeet;
        double dpf = geo.getXRes(); 
        int level = 0;
        NSMutableArray* _lods = [[NSMutableArray alloc] init];
        double resolution = (currentScale * dpf);
        
        while (currentScale >= minZoom && level < 33) 
        {
            AGSLOD* lod = [[AGSLOD alloc] initWithLevel:level resolution:resolution  scale:currentScale] ;
            [_lods addObject:lod];
            currentScale = currentScale / 2.0;
            resolution = resolution / 2.0;
            level++;

        }

        AGSTileInfo* tileInfo = [[AGSTileInfo alloc] initWithDpi: dpi 
                                                          format:@"Mixed" 
                                                            lods: _lods
                                                          origin:_origin 
                                                spatialReference:_spatialReference 
                                                        tileSize:CGSizeMake(512, 512)]; 
        [tileInfo computeTileBounds:fullEnvelope];
        
        _tileInfo = tileInfo;
        _fullEnvelope = fullEnvelope;
        _units = (AGSUnits)MakeAGSUnits(_fullEnvelope.spatialReference.wkt);
        [self layerDidLoad];
        
    }
    return self;
}


#pragma mark -
// Start reading the a tile
- (NSOperation<AGSTileOperation>*) retrieveImageAsyncForTile:(AGSTile *) tile
{
	//Create an operation to fetch tile from local cache
    if (tile.level < [self.tileInfo.lods count])
    {
        SidTileOperation *operation = 
        [[SidTileOperation alloc] initWithTile:tile
                                           lod:[self.tileInfo.lods objectAtIndex:tile.level]
                                        target:self 
                                        action:@selector(didFinishOperation:) andSidFileName:_sidFileName];
        //Add the operation to the queue for execution
        [self.operationQueue addOperation:operation];
        return operation;
    }
    return  NULL;
}

- (void) didFinishOperation:(NSOperation<AGSTileOperation>*)op 
{
	//If tile was found ...
	if (op.tile.image!=nil) {
		//... notify tileDelegate of success
		[self.tileDelegate tiledLayer:self operationDidGetTile:op];
	}else {
		//... notify tileDelegate of failure
        // if(op.tile.level < 10)
            [self.tileDelegate tiledLayer:self operationDidFailToGetTile:op];
    }
}

#pragma mark -Load File

+ (NSString *)getPrivateDocsDir 
{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    documentsDirectory = [documentsDirectory stringByAppendingPathComponent:@"Private Documents"];
    
    NSError *error;
    [[NSFileManager defaultManager] createDirectoryAtPath:documentsDirectory withIntermediateDirectories:YES attributes:nil error:&error];   
    
    return documentsDirectory;
    
}

#pragma mark -

@end

