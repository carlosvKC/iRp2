 // Copyright 2010 ESRI
//
// All rights reserved under the copyright laws of the United States
// and applicable international laws, treaties, and conventions.
//
// You may freely redistribute and use this sample code, with or
// without modification, provided you include the original copyright
// notice and use restrictions.
//
// See the use restrictions at http://help.arcgis.com/en/sdk/10.0/usageRestrictions.htm
//
#import "OfflineTiledLayer.h"
#import "OfflineTileOperation.h"
#import "OfflineCacheParserDelegate.h"
#import "NSData_Additions.h"
#import "ZipFile.h"
#import "ZipReadStream.h"
#import "FileInZipInfo.h"
#import "ReadPictures.h"

int MakeAGSUnits(NSString* wkt);

//Function to convert [UNIT] component in WKT to AGSUnits
int MakeAGSUnits(NSString* wkt){
	NSString* value ;
	BOOL _continue = YES;
 	NSScanner* scanner = [NSScanner scannerWithString:wkt];
	//Scan for the UNIT information in WKT. 
	//If WKT is for a Projected Coord System, expect two instances of UNIT, and use the second one
	while (_continue) {
		[scanner scanUpToString:@"UNIT[\"" intoString:NULL];
		[scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@"UNIT[\""]];
		_continue = [scanner scanUpToString:@"\"" intoString:&value];
	}
	if([@"Foot_US" isEqualToString:value] || [@"Foot" isEqualToString:value]){
		return AGSUnitsFeet;
	}else if([@"Meter" isEqualToString:value]){
		return AGSUnitsMeters;
	}else if([@"Degree" isEqualToString:value]){
		return AGSUnitsDecimalDegrees;
	}else{
		//TODO: Not handling other units like Yard, Chain, Grad, etc
		return -1;
	}
}


@implementation OfflineTiledLayer

@synthesize dataFramePath=_dataFramePath;
@synthesize appDocumentsPath=_appDocumentsPath;
@synthesize zipFileName=_zipFileName;

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
+(NSData *) getCDIFile:(NSString *)path andFile:(NSString *)file
{
    
    ReadPictures *dataFile = [ReadPictures getConnection:path];
    NSData *data = [dataFile getFileData:file];  //layers\conf.cdi did bring 367 b\conf.xml ok
    return data;
}

// working with .tiles file
- (id)initWithDataFramePath: (NSString *)path error:(NSError**) outError 
{
	if (self = [super init]) 
    {
        // Get public docs dir
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *publicDocumentsDir = [paths objectAtIndex:0];   
        self.dataFramePath = publicDocumentsDir;
        self.appDocumentsPath = publicDocumentsDir;
        self.zipFileName = path;
        
        NSData *theCDIFile = [OfflineTiledLayer getCDIFile:self.zipFileName andFile:@"Layers\\conf.cdi"];
		NSXMLParser*  xmlParser = [[NSXMLParser alloc] initWithData:theCDIFile];
        OfflineCacheParserDelegate* parserDelegate = [[OfflineCacheParserDelegate alloc] init] ;
		[xmlParser setDelegate:parserDelegate];
		[xmlParser parse];
		
        theCDIFile = [OfflineTiledLayer getCDIFile:self.zipFileName andFile:@"Layers\\conf.xml"];
		xmlParser = [[NSXMLParser alloc] initWithData:theCDIFile];
        [xmlParser setDelegate:parserDelegate];
		[xmlParser parse];
		
		//If XML files were parsed properly...
		if([parserDelegate tileInfo]!= nil && [parserDelegate fullEnvelope]!=nil )
        {
			//... get the metadata
			_tileInfo = [parserDelegate tileInfo];
			_fullEnvelope = [parserDelegate fullEnvelope];
			_units = MakeAGSUnits(_fullEnvelope.spatialReference.wkt);
			[self layerDidLoad];
		}
        else 
        {
			//... return error
            *outError = [parserDelegate error];
			return nil;
		}
    }
    return self;
}


#pragma mark -
- (NSOperation<AGSTileOperation>*) retrieveImageAsyncForTile:(AGSTile *) tile
{
	//Create an operation to fetch tile from local cache
	OfflineTileOperation *operation = [[OfflineTileOperation alloc] initWithTile:tile
                                 dataFramePath:_dataFramePath
                                        target:self 
                                        action:@selector(didFinishOperation:) andDocumentsDirectory:_appDocumentsPath andZipFileName:_zipFileName];
	//Add the operation to the queue for execution
    [self.operationQueue addOperation:operation];
    return operation;
}

- (void) didFinishOperation:(NSOperation<AGSTileOperation>*)op 
{
	//If tile was found ...
	if (op.tile.image!=nil) 
    {
		//... notify tileDelegate of success
		[self.tileDelegate tiledLayer:self operationDidGetTile:op];
	}
    else 
    {
		//... notify tileDelegate of failure
        //  if(op.tile.level < 10)
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


+ (NSString *)getMapsDirectory 
{
    NSString *finalPath = nil;
    // Get the tile images from private docs dir
    
    // Get public docs dir
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *publicDocumentsDir = [paths objectAtIndex:0];   
    
    // Get contents of documents directory
    NSError *error;
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:publicDocumentsDir error:&error];
    if (files == nil) 
    {
        return @"";
    }
    
    for (NSString *file in files) 
    {
        finalPath = [publicDocumentsDir stringByAppendingPathComponent:file];
        break;
    }
    
    return finalPath;
}


// DBaun 2014-08-04: zlibInflate does not exist anywhere that I can find, so commented out the code to avoid errors.
+(void) getMapTiles
{
    NSString *path = [OfflineTiledLayer getMapsDirectory];
    NSData *zippedData = [NSData dataWithContentsOfFile: path];
    
    NSData *unzippedData = NULL;
    //    if ([zippedData respondsToSelector:@selector(zlibInflate)])
    //    {
    //        unzippedData = [zippedData performSelector:@selector(zlibInflate)];
    //    }
    //    else {
        unzippedData = zippedData;
    //      }
    NSFileWrapper *dirWrapper = [[NSFileWrapper alloc] initWithSerializedRepresentation:unzippedData];
    if (dirWrapper == nil) 
    {
        return;
    }
    
}


#pragma mark -

@end

