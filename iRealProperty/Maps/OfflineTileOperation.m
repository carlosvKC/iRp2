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
#import "OfflineTileOperation.h"
#import "ZipFile.h"
#import "ZipReadStream.h"

#import "ReadPictures.h"

@implementation OfflineTileOperation

static ReadPictures *readPictures = nil;

@synthesize tile=_tile;
@synthesize target=_target;
@synthesize action=_action;
@synthesize allLayersPath=_allLayersPath;
@synthesize documentsDirectory=_documentsDirectory;
@synthesize zipFileName=_zipFileName;

- (id)initWithTile:(AGSTile *)tile dataFramePath:(NSString *)path target:(id)target action:(SEL)action andDocumentsDirectory: (NSString *)documentsDirectory andZipFileName: (NSString *)zipFileName
{
	
	if (self = [super init])
    {
		self.target = target;
		self.action = action;
		self.allLayersPath = [path stringByAppendingPathComponent:@"_alllayers"]  ;
		self.tile = tile;
        self.documentsDirectory = documentsDirectory;
        self.zipFileName = zipFileName;
		
	}
	return self;
}
-(void)main 
{
	//Fetch the tile for the requested Level, Row, Column
	@try 
    {
		//Level ('L' followed by 2 decimal digits)
		NSString *decLevel = [NSString stringWithFormat:@"L%02d",self.tile.level];
		//Row ('R' followed by 8 hex digits)
		NSString *hexRow = [NSString stringWithFormat:@"R%08x",self.tile.row];
		//Column ('C' followed by 8 hex digits)  
		NSString *hexCol = [NSString stringWithFormat:@"C%08x",self.tile.column];
		
		NSString* dir = [NSString stringWithFormat:@"Layers\\_alllayers\\%@\\%@",decLevel,hexRow];
        
        // NSLog(@"_zipFileName='%@' readPictures=%x", _zipFileName, readPictures);
        // Check if a JPG file exits first
		NSString *tileImagePath =  nil;
        tileImagePath =  [dir stringByAppendingPathComponent:hexCol];
        tileImagePath = [tileImagePath stringByAppendingFormat:@".jpg"];
        
        
        tileImagePath = [tileImagePath stringByReplacingOccurrencesOfString:@"/" withString:@"\\"];
        readPictures = [ReadPictures getConnection:_zipFileName];
        _tile.image = [readPictures findImage:tileImagePath];
        
        if(_tile.image==nil)
        {
            // try with the PNG extension
            NSString *tileImagePathTemp = [NSString stringWithFormat:@"Layers\\_alllayers\\%@\\%@",decLevel,hexRow];
            
            tileImagePathTemp =  [tileImagePathTemp stringByAppendingPathComponent:hexCol];
            tileImagePathTemp = [tileImagePathTemp stringByAppendingFormat:@".png"];
            tileImagePathTemp = [tileImagePathTemp stringByReplacingOccurrencesOfString:@"/" withString:@"\\"];
            _tile.image = [readPictures findImage:tileImagePathTemp];
            if(_tile.image==nil)
                NSLog(@"Can't load '%@'", tileImagePathTemp);
        }
	}
	@catch (NSException *exception) 
    {
		NSLog(@"main: Caught Exception %@: %@", [exception name], [exception reason]);
	}	
	@finally 
    {
		//Invoke the layer's action method
        if (_action != nil)
        {

#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [_target performSelector:_action withObject:self];

        }
	}
}
- (void)dealloc 
{
	self.action = nil;
}

@end


